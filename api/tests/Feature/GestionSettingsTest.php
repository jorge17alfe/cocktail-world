<?php

namespace Tests\Feature;

use App\Filament\Pages\Auth\EditProfile;
use App\Models\Establishment;
use App\Models\Setting;
use App\Models\User;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Livewire\Livewire;
use Tests\TestCase;

/** Email de soporte: editable en el perfil del superadmin y visible para los locales en la API. */
class GestionSettingsTest extends TestCase
{
    use RefreshDatabase;

    private function superadmin(): User
    {
        $super = User::create([
            'name' => 'Alocraise', 'email' => 'super@alocraise.com', 'password' => 'superclave123',
            'role' => User::ROLE_SUPERADMIN, 'establishment_id' => null,
        ])->refresh();
        $super->saveAppAuthenticationSecret('JBSWY3DPEHPK3PXP');

        return $super;
    }

    private function localAdmin(): User
    {
        $est = Establishment::create(['code' => '555555', 'name' => 'Bar Prueba']);

        return $est->users()->create(['role' => 'admin', 'name' => 'A', 'email' => 'a@bar.com', 'password' => 'secret123']);
    }

    public function test_por_defecto_usa_el_email_de_la_configuracion(): void
    {
        config(['cocktail.support_email' => 'alocraise@gmail.com']);

        $this->assertSame('alocraise@gmail.com', Setting::supportEmail());
    }

    public function test_el_superadmin_cambia_el_email_desde_su_perfil(): void
    {
        config(['cocktail.support_email' => 'alocraise@gmail.com']);
        $this->actingAs($super = $this->superadmin());
        Filament::setCurrentPanel('gestion');

        Livewire::test(EditProfile::class)
            ->assertSchemaStateSet(['support_email' => 'alocraise@gmail.com'])
            ->fillForm(['support_email' => 'soporte@alocraise.com'])
            ->call('save')
            ->assertHasNoFormErrors();

        $this->assertSame('soporte@alocraise.com', Setting::supportEmail());
        $this->assertSame('Alocraise', $super->refresh()->name); // el resto del perfil sigue igual
    }

    public function test_el_email_de_soporte_debe_ser_valido(): void
    {
        $this->actingAs($this->superadmin());
        Filament::setCurrentPanel('gestion');

        Livewire::test(EditProfile::class)
            ->fillForm(['support_email' => 'no-es-un-email'])
            ->call('save')
            ->assertHasFormErrors(['support_email' => 'email']);
    }

    public function test_la_app_del_local_recibe_el_email_de_soporte(): void
    {
        Setting::put(Setting::SUPPORT_EMAIL, 'soporte@alocraise.com');
        Sanctum::actingAs($this->localAdmin());

        $this->getJson('/api/v1/admin/support')
            ->assertOk()
            ->assertJsonPath('data.email', 'soporte@alocraise.com');
    }

    public function test_sin_login_no_se_puede_consultar(): void
    {
        $this->getJson('/api/v1/admin/support')->assertUnauthorized();
    }
}
