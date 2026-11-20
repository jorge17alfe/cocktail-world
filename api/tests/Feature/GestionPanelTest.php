<?php

namespace Tests\Feature;

use App\Filament\Widgets\PlatformStats;
use App\Models\Establishment;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

/** Panel de gestión de Alocraise (Filament). */
class GestionPanelTest extends TestCase
{
    use RefreshDatabase;

    private function superadmin(): User
    {
        return User::create([
            'name' => 'Alocraise', 'email' => 'super@alocraise.com', 'password' => 'superclave123',
            'role' => User::ROLE_SUPERADMIN, 'establishment_id' => null,
        ])->refresh();
    }

    private function localAdmin(): User
    {
        $est = Establishment::create(['code' => '555555', 'name' => 'Bar']);

        return $est->users()->create(['role' => 'admin', 'name' => 'A', 'email' => 'a@bar.com', 'password' => 'secret123'])->refresh();
    }

    public function test_guests_are_sent_to_the_panel_login(): void
    {
        $this->get('/gestion')->assertRedirect('/gestion/login');
        $this->get('/gestion/login')->assertOk()->assertSee('Cocktail World · Gestión');
    }

    public function test_local_admins_cannot_enter_the_panel(): void
    {
        $this->actingAs($this->localAdmin())->get('/gestion')->assertForbidden();
    }

    public function test_superadmin_must_set_up_two_factor_before_entering(): void
    {
        $this->actingAs($this->superadmin())->get('/gestion')
            ->assertRedirect()
            ->assertRedirectContains('multi-factor-authentication');
    }

    public function test_superadmin_with_two_factor_sees_the_dashboard(): void
    {
        $user = $this->superadmin();
        $user->saveAppAuthenticationSecret('JBSWY3DPEHPK3PXP');

        $this->actingAs($user)->get('/gestion')->assertOk();

        Livewire::test(PlatformStats::class)
            ->assertSee('Locales activos')
            ->assertSee('Biblioteca');
    }

    public function test_two_factor_secret_is_stored_encrypted(): void
    {
        $user = $this->superadmin();
        $user->saveAppAuthenticationSecret('JBSWY3DPEHPK3PXP');

        $raw = \DB::table('users')->where('id', $user->id)->value('app_authentication_secret');
        $this->assertNotSame('JBSWY3DPEHPK3PXP', $raw);
        $this->assertSame('JBSWY3DPEHPK3PXP', $user->fresh()->getAppAuthenticationSecret());
        $this->assertArrayNotHasKey('app_authentication_secret', $user->fresh()->toArray());
    }

    public function test_console_command_creates_superadmin(): void
    {
        $this->artisan('cocktail:superadmin', ['email' => 'Jorge@Alocraise.com'])
            ->expectsQuestion('Contraseña (mínimo 10 caracteres)', 'superclave123')
            ->expectsQuestion('Repite la contraseña', 'superclave123')
            ->assertSuccessful();
        $this->assertTrue(User::where('email', 'jorge@alocraise.com')->first()->isSuperadmin());

        $this->artisan('cocktail:superadmin', ['email' => 'otro@alocraise.com'])
            ->expectsQuestion('Contraseña (mínimo 10 caracteres)', 'corta')
            ->assertFailed();
        $this->assertDatabaseMissing('users', ['email' => 'otro@alocraise.com']);
    }

    public function test_command_refuses_to_promote_a_local_admin(): void
    {
        $this->localAdmin();
        $this->artisan('cocktail:superadmin', ['email' => 'a@bar.com'])->assertFailed();
        $this->assertSame('admin', User::where('email', 'a@bar.com')->value('role'));
    }

    public function test_reset_two_factor_from_console(): void
    {
        $user = $this->superadmin();
        $user->saveAppAuthenticationSecret('JBSWY3DPEHPK3PXP');
        $user->saveAppAuthenticationRecoveryCodes(['aaa', 'bbb']);

        $this->artisan('cocktail:superadmin', ['email' => 'super@alocraise.com', '--reset-2fa' => true])
            ->assertSuccessful();

        $fresh = $user->fresh();
        $this->assertNull($fresh->getAppAuthenticationSecret());
        $this->assertNull($fresh->getAppAuthenticationRecoveryCodes());
    }

    public function test_api_for_local_admins_still_works(): void
    {
        $this->postJson('/api/v1/auth/login', ['establishment_code' => '555555', 'email' => 'a@bar.com', 'password' => 'secret123'])
            ->assertStatus(422); // aún no existe
        $this->localAdmin();
        $this->postJson('/api/v1/auth/login', ['establishment_code' => '555555', 'email' => 'a@bar.com', 'password' => 'secret123'])
            ->assertOk()->assertJsonPath('user.role', 'admin');
    }
}
