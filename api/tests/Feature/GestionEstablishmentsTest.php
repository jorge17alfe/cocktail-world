<?php

namespace Tests\Feature;

use App\Filament\Resources\Establishments\EstablishmentResource;
use App\Filament\Resources\Establishments\Pages\EditEstablishment;
use App\Filament\Resources\Establishments\Pages\ListEstablishments;
use App\Filament\Resources\Establishments\RelationManagers\UsersRelationManager;
use App\Models\Establishment;
use App\Models\User;
use App\Support\EstablishmentManager;
use Filament\Actions\Testing\TestAction;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

/** Fase 3: gestión de establecimientos desde el panel de Alocraise. */
class GestionEstablishmentsTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $super = User::create([
            'name' => 'Alocraise', 'email' => 'super@alocraise.com', 'password' => 'superclave123',
            'role' => User::ROLE_SUPERADMIN, 'establishment_id' => null,
        ])->refresh();
        $super->saveAppAuthenticationSecret('JBSWY3DPEHPK3PXP');
        $this->actingAs($super);
        Filament::setCurrentPanel('gestion');
        config(['app.url' => 'https://cocktail-world.alocraise.com']);
    }

    /** @return array{0: Establishment, 1: User} */
    private function local(string $code = '555555'): array
    {
        $est = Establishment::create(['code' => $code, 'name' => "Bar $code"]);
        $admin = $est->users()->create(['role' => 'admin', 'name' => 'A', 'email' => "a$code@bar.com", 'password' => 'secret123']);

        return [$est, $admin->refresh()];
    }

    private function appLogin(string $code, string $email, string $password)
    {
        return $this->postJson('/api/v1/auth/login', ['establishment_code' => $code, 'email' => $email, 'password' => $password]);
    }

    public function test_temporary_password_is_easy_to_dictate(): void
    {
        $this->assertMatchesRegularExpression('/^[a-z2-9]{4}-[a-z2-9]{4}-[a-z2-9]{4}$/', EstablishmentManager::temporaryPassword());
        $this->assertDoesNotMatchRegularExpression('/[01oil]/', EstablishmentManager::temporaryPassword());
    }

    public function test_list_and_edit_pages_open(): void
    {
        [$est] = $this->local();
        $this->get('/gestion/establecimientos')->assertOk()->assertSee('Bar 555555');
        $this->get("/gestion/establecimientos/{$est->id}/edit")->assertOk()
            ->assertSee('https://cocktail-world.alocraise.com/carta/555555');
    }

    public function test_create_local_from_panel_gives_working_credentials(): void
    {
        Livewire::test(ListEstablishments::class)
            ->callAction('create_establishment', data: [
                'name' => 'La Fonda', 'admin_name' => 'Jorge', 'admin_email' => 'Jorge@Fonda.com',
            ])
            ->assertHasNoActionErrors()
            ->assertNotified();

        $est = Establishment::where('name', 'La Fonda')->first();
        $this->assertMatchesRegularExpression('/^\d{6}$/', $est->code);
        $this->assertSame('jorge@fonda.com', $est->users()->first()->email);

        // La contraseña que muestra el panel funciona en la app
        $result = app(EstablishmentManager::class)->createWithAdmin('Otro', 'Ana', 'ana@otro.com');
        $this->appLogin($result['establishment']->code, 'ana@otro.com', $result['password'])->assertOk();
    }

    public function test_create_local_rejects_duplicate_email(): void
    {
        $this->local();
        Livewire::test(ListEstablishments::class)
            ->callAction('create_establishment', data: ['name' => 'X', 'admin_name' => 'Y', 'admin_email' => 'a555555@bar.com'])
            ->assertHasActionErrors(['admin_email' => 'unique']);
    }

    public function test_filters_active_and_suspended(): void
    {
        [$active] = $this->local('111111');
        [$suspended] = $this->local('222222');
        $suspended->update(['is_active' => false]);

        Livewire::test(ListEstablishments::class)
            ->filterTable('is_active', false)
            ->assertCanSeeTableRecords([$suspended])
            ->assertCanNotSeeTableRecords([$active]);
    }

    public function test_suspend_blocks_app_and_public_carta_then_reactivate(): void
    {
        [$est, $admin] = $this->local();
        $admin->createToken('app');

        Livewire::test(ListEstablishments::class)
            ->callAction(TestAction::make('suspend')->table($est))
            ->assertNotified();

        $this->assertFalse($est->fresh()->is_active);
        $this->assertSame(0, $admin->tokens()->count());
        $this->getJson('/api/v1/public/555555')->assertNotFound();
        $this->appLogin('555555', 'a555555@bar.com', 'secret123')->assertStatus(422);

        Livewire::test(EditEstablishment::class, ['record' => $est->getRouteKey()])
            ->callAction('reactivate');

        $this->assertTrue($est->fresh()->is_active);
        $this->getJson('/api/v1/public/555555')->assertOk();
        $this->appLogin('555555', 'a555555@bar.com', 'secret123')->assertOk();
    }

    public function test_temporary_password_for_an_admin(): void
    {
        [$est, $admin] = $this->local();
        $admin->createToken('app');

        Livewire::test(UsersRelationManager::class, ['ownerRecord' => $est, 'pageClass' => EditEstablishment::class])
            ->callAction(TestAction::make('temporary_password')->table($admin))
            ->assertNotified();

        $this->assertSame(0, $admin->tokens()->count());
        $this->appLogin('555555', 'a555555@bar.com', 'secret123')->assertStatus(422);
    }

    public function test_deactivate_and_activate_an_admin(): void
    {
        [$est, $admin] = $this->local();

        Livewire::test(UsersRelationManager::class, ['ownerRecord' => $est, 'pageClass' => EditEstablishment::class])
            ->callAction(TestAction::make('deactivate')->table($admin));
        $this->appLogin('555555', 'a555555@bar.com', 'secret123')->assertStatus(422);

        Livewire::test(UsersRelationManager::class, ['ownerRecord' => $est, 'pageClass' => EditEstablishment::class])
            ->callAction(TestAction::make('activate')->table($admin->fresh()));
        $this->appLogin('555555', 'a555555@bar.com', 'secret123')->assertOk();
    }

    public function test_public_url_always_points_to_the_app_domain(): void
    {
        [$est] = $this->local();
        $this->assertSame('https://cocktail-world.alocraise.com/carta/555555', EstablishmentResource::publicUrl($est));
    }

    public function test_admin_changes_own_password_from_the_app(): void
    {
        [, $admin] = $this->local();
        $current = $this->appLogin('555555', 'a555555@bar.com', 'secret123')->json('token');
        $other = $this->appLogin('555555', 'a555555@bar.com', 'secret123')->json('token');
        $this->app['auth']->forgetGuards();

        $put = fn (array $body) => $this->withHeader('Authorization', "Bearer $current")
            ->putJson('/api/v1/auth/password', $body);

        $put(['current_password' => 'mala', 'password' => 'nuevaclave1', 'password_confirmation' => 'nuevaclave1'])
            ->assertStatus(422)->assertJsonPath('message', 'La contraseña actual no es correcta');
        $put(['current_password' => 'secret123', 'password' => 'corta', 'password_confirmation' => 'corta'])
            ->assertStatus(422);
        $put(['current_password' => 'secret123', 'password' => 'nuevaclave1', 'password_confirmation' => 'nuevaclave1'])
            ->assertOk();

        // La sesión actual sigue; la del otro dispositivo se cierra
        $tokenIds = $admin->tokens()->pluck('id')->all();
        $this->assertCount(1, $tokenIds);
        $this->assertSame((int) explode('|', $current)[0], $tokenIds[0]);
        $this->app['auth']->forgetGuards();
        $this->appLogin('555555', 'a555555@bar.com', 'nuevaclave1')->assertOk();
        $this->assertNotNull($other);
    }
}
