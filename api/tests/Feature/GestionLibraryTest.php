<?php

namespace Tests\Feature;

use App\Filament\Resources\LibraryCocktails\Pages\CreateLibraryCocktail;
use App\Filament\Resources\LibraryCocktails\Pages\EditLibraryCocktail;
use App\Filament\Resources\LibraryCocktails\Pages\ListLibraryCocktails;
use App\Filament\Resources\LibraryUtensils\LibraryUtensilResource;
use App\Filament\Resources\LibraryUtensils\Pages\ListLibraryUtensils;
use App\Models\Cocktail;
use App\Models\Establishment;
use App\Models\User;
use App\Models\Utensil;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Livewire\Livewire;
use Tests\TestCase;

/** Fase 2: gestión de la biblioteca desde el panel de Alocraise. */
class GestionLibraryTest extends TestCase
{
    use RefreshDatabase;

    private Establishment $local;

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

        $this->local = Establishment::create(['code' => '555555', 'name' => 'Bar']);
    }

    private function localCocktail(string $name, ?int $sourceId = null): Cocktail
    {
        $family = $this->local->families()->firstOrCreate(['name' => 'F']);
        $c = new Cocktail(['name' => $name, 'family_id' => $family->id]);
        $c->establishment_id = $this->local->id;
        $c->source_cocktail_id = $sourceId;
        $c->save();

        return $c;
    }

    public function test_list_shows_only_library_cocktails_with_copy_count(): void
    {
        $negroni = Cocktail::create(['name' => 'Negroni', 'tags' => ['Clásicos']]);
        $mine = $this->localCocktail('Negroni de la casa', $negroni->id);

        Livewire::test(ListLibraryCocktails::class)
            ->assertCanSeeTableRecords([$negroni])
            ->assertCanNotSeeTableRecords([$mine])
            ->assertSee('1 locales');
    }

    public function test_pages_open_for_superadmin_and_not_for_local_admins(): void
    {
        $this->get('/gestion/biblioteca/cocteles')->assertOk();
        $this->get('/gestion/biblioteca/cocteles/create')->assertOk();
        $this->get('/gestion/biblioteca/utensilios')->assertOk();

        $admin = $this->local->users()->create(['role' => 'admin', 'name' => 'A', 'email' => 'a@bar.com', 'password' => 'secret123']);
        $this->actingAs($admin->refresh())->get('/gestion/biblioteca/cocteles')->assertForbidden();
    }

    public function test_create_library_cocktail_with_ingredients_steps_and_utensils(): void
    {
        $shaker = Utensil::create(['name' => 'Coctelera']);

        Livewire::test(CreateLibraryCocktail::class)
            ->fillForm([
                'name' => 'Paloma',
                'tags' => ['Internacionales', 'Tequila'],
                'glass' => 'Vaso highball',
                'technique' => 'build',
                'ingredients' => [
                    ['name' => 'Tequila', 'amount' => 50, 'unit' => 'ml'],
                    ['name' => 'Refresco de pomelo', 'amount' => 120, 'unit' => 'ml'],
                ],
                // Así representa Filament cada paso en el formulario; al guardar queda como lista de textos
                'steps' => [['step' => 'Llenar de hielo'], ['step' => 'Añadir tequila y completar con pomelo']],
                'history' => 'Muy popular en México.',
                'utensils' => [$shaker->id],
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $paloma = Cocktail::where('name', 'Paloma')->first();
        $this->assertNull($paloma->establishment_id);
        $this->assertNull($paloma->family_id);
        $this->assertSame(['Internacionales', 'Tequila'], $paloma->tags);
        $this->assertSame(['Tequila', 'Refresco de pomelo'], $paloma->ingredients->pluck('name')->all());
        $this->assertSame(['Llenar de hielo', 'Añadir tequila y completar con pomelo'], $paloma->steps);
        $this->assertTrue($paloma->utensils->contains($shaker));

        // Y los locales ya lo ven en su biblioteca de la app
        $admin = $this->local->users()->create(['role' => 'admin', 'name' => 'A', 'email' => 'a@bar.com', 'password' => 'secret123']);
        Sanctum::actingAs($admin);
        $this->getJson('/api/v1/admin/library')->assertOk()->assertJsonFragment(['name' => 'Paloma']);
    }

    public function test_name_and_group_are_required(): void
    {
        Livewire::test(CreateLibraryCocktail::class)
            ->fillForm(['name' => '', 'tags' => []])
            ->call('create')
            ->assertHasFormErrors(['name' => 'required', 'tags' => 'required']);
    }

    public function test_editing_library_does_not_change_local_copies(): void
    {
        $negroni = Cocktail::create(['name' => 'Negroni', 'tags' => ['Clásicos'], 'history' => 'Antigua']);
        $copy = $this->localCocktail('Negroni', $negroni->id);
        $copy->update(['history' => 'Antigua']);

        Livewire::test(EditLibraryCocktail::class, ['record' => $negroni->getRouteKey()])
            ->fillForm(['history' => 'Historia nueva'])
            ->call('save')
            ->assertHasNoFormErrors();

        $this->assertSame('Historia nueva', $negroni->fresh()->history);
        $this->assertSame('Antigua', $copy->fresh()->history);
    }

    public function test_cannot_open_a_local_cocktail_in_the_library_editor(): void
    {
        $mine = $this->localCocktail('Secreto de la casa');
        $this->get("/gestion/biblioteca/cocteles/{$mine->id}/edit")->assertNotFound();
    }

    public function test_photo_files_are_cleaned_up(): void
    {
        Storage::fake('public');
        Storage::disk('public')->put('library/cocktails/a.jpg', 'x');
        Storage::disk('public')->put('library/cocktails/b.jpg', 'x');
        Storage::disk('public')->put('library/cocktails/c.jpg', 'x');

        $c = Cocktail::create(['name' => 'Con fotos', 'tags' => ['Clásicos']]);
        $img = $c->images()->create(['path' => 'library/cocktails/a.jpg', 'order' => 0]);
        $c->images()->create(['path' => 'library/cocktails/c.jpg', 'order' => 1]);

        // Sustituir la foto borra la anterior
        $img->update(['path' => 'library/cocktails/b.jpg']);
        Storage::disk('public')->assertMissing('library/cocktails/a.jpg');
        Storage::disk('public')->assertExists('library/cocktails/b.jpg');

        // Borrar el cóctel borra todas sus fotos
        $c->delete();
        Storage::disk('public')->assertMissing('library/cocktails/b.jpg');
        Storage::disk('public')->assertMissing('library/cocktails/c.jpg');
    }

    public function test_utensils_list_only_library_ones_and_warns_before_delete(): void
    {
        $global = Utensil::create(['name' => 'Coctelera']);
        $own = $this->local->utensils()->create(['name' => 'Ahumador de la casa']);
        $this->localCocktail('X')->utensils()->attach($global->id);

        Livewire::test(ListLibraryUtensils::class)
            ->assertCanSeeTableRecords([$global])
            ->assertCanNotSeeTableRecords([$own]);

        $this->assertStringContainsString('Lo usan 1 cócteles', LibraryUtensilResource::deleteWarning($global));
    }

    public function test_utensil_photo_replaced_deletes_old_file(): void
    {
        Storage::fake('public');
        Storage::disk('public')->put('library/utensils/old.png', 'x');
        $u = Utensil::create(['name' => 'Jigger', 'image' => 'library/utensils/old.png']);

        $u->update(['image' => 'library/utensils/new.png']);
        Storage::disk('public')->assertMissing('library/utensils/old.png');
    }
}
