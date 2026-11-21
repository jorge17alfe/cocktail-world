<?php

namespace Tests\Feature;

use App\Filament\Pages\Auth\EditProfile;
use App\Filament\Resources\Establishments\Pages\EditEstablishment;
use App\Filament\Resources\Plans\Pages\EditPlan;
use App\Filament\Resources\Plans\Pages\ListPlans;
use App\Models\Cocktail;
use App\Models\Establishment;
use App\Models\Plan;
use App\Models\Setting;
use App\Models\User;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Livewire\Livewire;
use Tests\TestCase;

/** Fase 5: planes y suscripciones (preparado, sin cobro). */
class SubscriptionsTest extends TestCase
{
    use RefreshDatabase;

    private function local(string $plan = Plan::FREE, array $attrs = []): Establishment
    {
        $est = Establishment::create($attrs + [
            'code' => (string) random_int(100000, 999999), 'name' => 'Bar', 'plan_id' => Plan::bySlug($plan)->id,
        ]);
        $admin = $est->users()->create(['role' => 'admin', 'name' => 'A', 'email' => "a{$est->code}@bar.com", 'password' => 'secret123']);
        Sanctum::actingAs($admin);

        return $est;
    }

    private function addCocktails(Establishment $est, int $count): void
    {
        $family = $est->families()->firstOrCreate(['name' => 'Clásicos']);
        for ($i = 0; $i < $count; $i++) {
            $c = new Cocktail(['name' => "Cóctel $i", 'family_id' => $family->id]);
            $c->establishment_id = $est->id;
            $c->save();
        }
    }

    private function superadmin(): void
    {
        $super = User::create([
            'name' => 'Alocraise', 'email' => 'super@alocraise.com', 'password' => 'superclave123',
            'role' => User::ROLE_SUPERADMIN, 'establishment_id' => null,
        ])->refresh();
        $super->saveAppAuthenticationSecret('JBSWY3DPEHPK3PXP');
        $this->actingAs($super);
        Filament::setCurrentPanel('gestion');
    }

    public function test_los_locales_nuevos_reciben_el_plan_por_defecto(): void
    {
        $this->assertSame(Plan::UNLIMITED, Establishment::create(['code' => '100001', 'name' => 'A'])->plan->slug);

        Setting::put(Setting::DEFAULT_PLAN, Plan::FREE);
        $code = $this->postJson('/api/v1/auth/register', [
            'establishment_name' => 'La Fonda', 'name' => 'J', 'email' => 'j@test.com',
            'password' => 'secret123', 'password_confirmation' => 'secret123',
        ])->assertCreated()->json('establishment.code');

        $this->assertSame(Plan::FREE, Establishment::where('code', $code)->first()->plan->slug);
    }

    public function test_el_plan_ilimitado_no_pone_limites(): void
    {
        $est = $this->local(Plan::UNLIMITED);
        $this->addCocktails($est, 30);

        $this->postJson('/api/v1/admin/families', ['name' => 'Otra'])->assertCreated();
        $this->postJson('/api/v1/admin/cocktails', ['name' => 'Uno más', 'family_id' => $est->families()->first()->id])
            ->assertCreated();
    }

    public function test_limite_de_familias(): void
    {
        $this->local(Plan::FREE); // 2 familias
        $this->postJson('/api/v1/admin/families', ['name' => 'Uno'])->assertCreated();
        $this->postJson('/api/v1/admin/families', ['name' => 'Dos'])->assertCreated();

        $this->postJson('/api/v1/admin/families', ['name' => 'Tres'])
            ->assertForbidden()
            ->assertJsonPath('message', 'Tu plan Gratis permite 2 familias. Escríbenos si necesitas más.');
    }

    public function test_limite_de_cocteles_al_crear_y_al_copiar_de_la_biblioteca(): void
    {
        $est = $this->local(Plan::FREE); // 15 cócteles
        $this->addCocktails($est, 14);
        $family = $est->families()->first();
        $library = collect(['Mojito', 'Daiquiri'])->map(fn ($n) => Cocktail::create(['name' => $n]));

        // Copiar 2 pasaría de 15: no se copia ninguno
        $this->postJson('/api/v1/admin/library/copy', ['family_id' => $family->id, 'cocktail_ids' => $library->pluck('id')->all()])
            ->assertForbidden()->assertJsonPath('limit', true);
        $this->assertSame(14, $est->cocktails()->count());

        $this->postJson('/api/v1/admin/cocktails', ['name' => 'El 15', 'family_id' => $family->id])->assertCreated();
        $this->postJson('/api/v1/admin/cocktails', ['name' => 'El 16', 'family_id' => $family->id])
            ->assertForbidden()
            ->assertJsonPath('message', 'Tu plan Gratis permite 15 cócteles. Escríbenos si necesitas más.');
    }

    public function test_limite_de_fotos_por_coctel(): void
    {
        Storage::fake('public');
        $est = $this->local(Plan::FREE); // 2 fotos por cóctel
        $this->addCocktails($est, 1);
        $id = $est->cocktails()->first()->id;

        $this->post("/api/v1/admin/cocktails/$id/images", [
            'images' => [UploadedFile::fake()->image('a.jpg'), UploadedFile::fake()->image('b.jpg'), UploadedFile::fake()->image('c.jpg')],
        ], ['Accept' => 'application/json'])
            ->assertForbidden()
            ->assertJsonPath('message', 'Tu plan Gratis permite 2 fotos por cóctel. Escríbenos si necesitas más.');

        $this->post("/api/v1/admin/cocktails/$id/images", [
            'images' => [UploadedFile::fake()->image('a.jpg'), UploadedFile::fake()->image('b.jpg')],
        ], ['Accept' => 'application/json'])->assertCreated();
    }

    public function test_al_copiar_de_la_biblioteca_solo_se_copian_las_fotos_que_permite_el_plan(): void
    {
        Storage::fake('public');
        $est = $this->local(Plan::FREE);
        $family = $est->families()->create(['name' => 'Clásicos']);
        $source = Cocktail::create(['name' => 'Mojito']);
        foreach (range(1, 4) as $i) {
            Storage::disk('public')->put("library/cocktails/$i.jpg", 'x');
            $source->images()->create(['path' => "library/cocktails/$i.jpg", 'order' => $i]);
        }

        $this->postJson('/api/v1/admin/library/copy', ['family_id' => $family->id, 'cocktail_ids' => [$source->id]])
            ->assertCreated();

        $this->assertSame(2, $est->cocktails()->first()->images()->count());
    }

    public function test_si_la_suscripcion_no_esta_al_dia_se_aplica_el_plan_de_respaldo(): void
    {
        $est = $this->local(Plan::UNLIMITED, ['subscription_status' => Establishment::STATUS_PAST_DUE]);
        $this->addCocktails($est, 15);

        $this->assertFalse($est->subscriptionIsCurrent());
        $this->assertSame(Plan::FREE, $est->effectivePlan()->slug);
        $this->postJson('/api/v1/admin/cocktails', ['name' => 'Otro', 'family_id' => $est->families()->first()->id])
            ->assertForbidden();
        $this->assertSame(15, $est->cocktails()->count()); // no se borra nada
    }

    public function test_estados_de_la_suscripcion(): void
    {
        $basic = Plan::bySlug('basic')->id;
        $make = fn (array $a) => new Establishment($a + ['plan_id' => $basic]);

        $this->assertTrue($make(['subscription_status' => 'active'])->subscriptionIsCurrent());
        $this->assertTrue($make(['subscription_status' => 'trial', 'trial_ends_at' => now()->addDays(3)])->subscriptionIsCurrent());
        $this->assertFalse($make(['subscription_status' => 'trial', 'trial_ends_at' => now()->subDay()])->subscriptionIsCurrent());
        $this->assertTrue($make(['subscription_status' => 'canceled', 'subscription_ends_at' => now()->addWeek()])->subscriptionIsCurrent());
        $this->assertFalse($make(['subscription_status' => 'canceled', 'subscription_ends_at' => now()->subDay()])->subscriptionIsCurrent());
        $this->assertFalse($make(['subscription_status' => 'past_due'])->subscriptionIsCurrent());
    }

    public function test_solo_los_planes_que_lo_permiten_quitan_la_firma(): void
    {
        $basic = $this->local('basic', ['show_branding' => false]);
        $pro = $this->local('pro', ['show_branding' => false]);

        $this->getJson("/api/v1/public/{$basic->code}")->assertJsonPath('establishment.show_branding', true);
        $this->getJson("/api/v1/public/{$pro->code}")->assertJsonPath('establishment.show_branding', false);

        // Pro con pago pendiente: vuelve la firma (se aplica el plan Gratis)
        $pro->update(['subscription_status' => Establishment::STATUS_PAST_DUE]);
        $this->getJson("/api/v1/public/{$pro->code}")->assertJsonPath('establishment.show_branding', true);
    }

    public function test_panel_planes_y_suscripcion_del_local(): void
    {
        $est = Establishment::create(['code' => '200002', 'name' => 'Bar Panel']);
        $this->superadmin();

        Livewire::test(ListPlans::class)->assertOk()->assertCanSeeTableRecords(Plan::all());

        $free = Plan::bySlug(Plan::FREE);
        Livewire::test(EditPlan::class, ['record' => $free->getRouteKey()])
            ->fillForm(['max_cocktails' => 20])->call('save')->assertHasNoFormErrors();
        $this->assertSame(20, $free->refresh()->max_cocktails);

        Livewire::test(EditEstablishment::class, ['record' => $est->getRouteKey()])
            ->assertSee('0/∞ cócteles')
            ->fillForm(['plan_id' => $free->id, 'subscription_status' => 'trial', 'trial_ends_at' => now()->addDays(14)])
            ->call('save')->assertHasNoFormErrors();

        $est->refresh();
        $this->assertSame(Plan::FREE, $est->plan->slug);
        $this->assertSame('trial', $est->subscription_status);
        $this->assertTrue($est->trial_ends_at->isFuture());
    }

    public function test_el_perfil_guarda_los_planes_por_defecto(): void
    {
        $this->superadmin();

        Livewire::test(EditProfile::class)
            ->assertSchemaStateSet(['default_plan' => Plan::UNLIMITED, 'fallback_plan' => Plan::FREE])
            ->fillForm(['default_plan' => Plan::FREE, 'fallback_plan' => 'basic'])
            ->call('save')->assertHasNoFormErrors();

        $this->assertSame(Plan::FREE, Setting::get(Setting::DEFAULT_PLAN));
        $this->assertSame('basic', Setting::get(Setting::FALLBACK_PLAN));
    }
}
