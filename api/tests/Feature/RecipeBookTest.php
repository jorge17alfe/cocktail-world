<?php

namespace Tests\Feature;

use App\Models\Cocktail;
use App\Models\Establishment;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/** Recetario público (biblioteca para cualquiera) y firma de Cocktail World en las cartas. */
class RecipeBookTest extends TestCase
{
    use RefreshDatabase;

    private function libraryCocktail(array $attrs = []): Cocktail
    {
        $c = Cocktail::create($attrs + ['name' => 'Mojito', 'tags' => ['Clásicos', 'Ron'], 'steps' => ['Macerar']]);
        $c->ingredients()->create(['name' => 'Ron blanco', 'amount' => 50, 'unit' => 'ml', 'order' => 1]);

        return $c;
    }

    public function test_cualquiera_ve_el_recetario_sin_login(): void
    {
        $this->libraryCocktail();
        $this->libraryCocktail(['name' => 'Daiquiri']);

        $this->getJson('/api/v1/public/library')
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.name', 'Daiquiri') // por orden alfabético
            ->assertJsonMissingPath('data.0.copies_count');
    }

    public function test_ficha_completa_de_un_coctel_del_recetario(): void
    {
        $c = $this->libraryCocktail();

        $this->getJson("/api/v1/public/library/{$c->id}")
            ->assertOk()
            ->assertJsonPath('data.name', 'Mojito')
            ->assertJsonPath('data.ingredients.0.name', 'Ron blanco')
            ->assertJsonPath('data.steps.0', 'Macerar');
    }

    public function test_los_cocteles_de_los_locales_no_salen_en_el_recetario(): void
    {
        $est = Establishment::create(['code' => '444444', 'name' => 'Bar']);
        $family = $est->families()->create(['name' => 'Autor']);
        $own = new Cocktail(['name' => 'Secreto de la casa', 'family_id' => $family->id]);
        $own->establishment_id = $est->id;
        $own->save();
        $hidden = $this->libraryCocktail(['name' => 'Borrador', 'is_published' => false]);

        $this->getJson('/api/v1/public/library')->assertOk()->assertJsonCount(0, 'data');
        $this->getJson("/api/v1/public/library/{$own->id}")->assertNotFound();
        $this->getJson("/api/v1/public/library/{$hidden->id}")->assertNotFound();
    }

    public function test_los_enlaces_del_recetario_abren_la_app_web(): void
    {
        $index = tempnam(sys_get_temp_dir(), 'idx');
        file_put_contents($index, '<html>app</html>');
        config(['app.web_app_index' => $index]);

        foreach (['/recetario', '/recetario/c/7'] as $url) {
            $this->get($url)->assertOk()->assertSee('app');
        }
        unlink($index);
    }

    public function test_la_carta_indica_si_mostrar_la_firma(): void
    {
        Establishment::create(['code' => '555555', 'name' => 'Bar Firma']);
        Establishment::create(['code' => '666666', 'name' => 'Bar Pro', 'show_branding' => false]);

        $this->getJson('/api/v1/public/555555')->assertJsonPath('establishment.show_branding', true);
        $this->getJson('/api/v1/public/666666')->assertJsonPath('establishment.show_branding', false);
    }
}
