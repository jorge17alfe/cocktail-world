<?php

namespace Tests\Feature;

use App\Models\Cocktail;
use App\Models\Establishment;
use App\Models\User;
use App\Models\Utensil;
use Database\Seeders\LibrarySeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class Phase4Test extends TestCase
{
    use RefreshDatabase;

    private function admin(): User
    {
        $est = Establishment::create(['code' => '333333', 'name' => 'Bar <b>Tres</b>']);

        return $est->users()->create(['role' => 'admin', 'name' => 'A', 'email' => 'a@t.com', 'password' => 'secret123']);
    }

    private function cocktail(User $admin, array $attrs = []): Cocktail
    {
        $family = $admin->establishment->families()->firstOrCreate(['name' => 'Clásicos']);
        $c = new Cocktail($attrs + ['name' => 'Negroni', 'family_id' => $family->id, 'steps' => ['Remover']]);
        $c->establishment_id = $admin->establishment_id;
        $c->save();

        return $c;
    }

    public function test_establishment_exposes_public_carta_url(): void
    {
        $this->admin();
        $this->getJson('/api/v1/public/333333')
            ->assertJsonPath('establishment.public_url', url('/carta/333333'));
    }

    public function test_carta_links_serve_the_flutter_web_app(): void
    {
        $index = tempnam(sys_get_temp_dir(), 'web') . '.html';
        file_put_contents($index, '<!doctype html><title>Carta de cócteles</title><base href="/app/">');
        config(['app.web_app_index' => $index]);

        foreach (['/carta/333333', '/carta/333333/c/7', '/app'] as $url) {
            $this->get($url)->assertOk()->assertSee('Carta de cócteles')->assertHeader('Cache-Control');
        }
        $this->get('/carta/abc')->assertNotFound();

        unlink($index);
    }

    public function test_carta_without_compiled_web_app_explains_how_to_build(): void
    {
        config(['app.web_app_index' => '/no/existe/index.html']);
        $this->get('/carta/333333')->assertStatus(503);
    }

    public function test_adopting_global_utensil_replaces_it_everywhere(): void
    {
        $this->seed(LibrarySeeder::class);
        $admin = $this->admin();
        Sanctum::actingAs($admin);
        $global = Utensil::whereNull('establishment_id')->where('name', 'Coctelera')->first();
        $c = $this->cocktail($admin);
        $c->utensils()->attach($global->id);

        $ownId = $this->postJson("/api/v1/admin/utensils/{$global->id}/adopt")
            ->assertCreated()->assertJsonPath('data.is_global', false)->json('data.id');

        // El cóctel usa ahora la versión propia
        $this->assertEquals([$ownId], $c->fresh()->utensils->pluck('id')->all());

        // En el catálogo ya no aparece la global, solo la propia
        $names = collect($this->getJson('/api/v1/admin/utensils')->json('data'));
        $this->assertCount(1, $names->where('name', 'Coctelera'));
        $this->assertFalse($names->firstWhere('name', 'Coctelera')['is_global']);

        // Repetir no duplica
        $this->postJson("/api/v1/admin/utensils/{$global->id}/adopt")->assertOk()->assertJsonPath('data.id', $ownId);

        // Al copiar de la biblioteca se usa la personalizada
        $familyId = $c->family_id;
        $margarita = Cocktail::library()->where('name', 'Margarita')->first();
        $this->postJson('/api/v1/admin/library/copy', ['family_id' => $familyId, 'cocktail_ids' => [$margarita->id]])
            ->assertCreated();
        $copy = Cocktail::where('source_cocktail_id', $margarita->id)->first();
        $this->assertTrue($copy->utensils->contains('id', $ownId));
        $this->assertFalse($copy->utensils->contains('id', $global->id));

        // Otro local sigue viendo la global
        $other = Establishment::create(['code' => '444444', 'name' => 'Otro']);
        $this->assertTrue(Utensil::availableFor($other->id)->whereKey($global->id)->exists());
    }
}
