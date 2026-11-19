<?php

namespace Tests\Feature;

use App\Models\Cocktail;
use App\Models\Establishment;
use App\Models\User;
use Database\Seeders\LibrarySeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class V1ApiTest extends TestCase
{
    use RefreshDatabase;

    private function admin(string $code = '111111'): User
    {
        $est = Establishment::create(['code' => $code, 'name' => "Bar $code"]);

        return $est->users()->create([
            'role' => 'admin', 'name' => 'Admin', 'email' => "admin$code@test.com", 'password' => 'secret123',
        ]);
    }

    public function test_register_creates_establishment_and_login_requires_its_code(): void
    {
        $res = $this->postJson('/api/v1/auth/register', [
            'establishment_name' => 'La Fonda', 'name' => 'Jorge', 'email' => 'j@test.com',
            'password' => 'secret123', 'password_confirmation' => 'secret123',
        ])->assertCreated()->assertJsonStructure(['token', 'establishment' => ['code']]);

        $code = $res->json('establishment.code');
        $this->assertMatchesRegularExpression('/^\d{6}$/', $code);

        $this->postJson('/api/v1/auth/login', ['establishment_code' => $code, 'email' => 'j@test.com', 'password' => 'secret123'])
            ->assertOk()->assertJsonPath('user.role', 'admin');

        $this->postJson('/api/v1/auth/login', ['establishment_code' => '000000', 'email' => 'j@test.com', 'password' => 'secret123'])
            ->assertStatus(422);
        $this->postJson('/api/v1/auth/login', ['establishment_code' => $code, 'email' => 'j@test.com', 'password' => 'mala'])
            ->assertStatus(422);
    }

    public function test_admin_creates_family_and_cocktail_and_public_sees_full_card(): void
    {
        $admin = $this->admin();
        Sanctum::actingAs($admin);

        $familyId = $this->postJson('/api/v1/admin/families', ['name' => 'Clásicos'])->assertCreated()->json('data.id');

        $cocktailId = $this->postJson('/api/v1/admin/cocktails', [
            'family_id' => $familyId,
            'name' => 'Negroni',
            'technique' => 'stir',
            'glass' => 'Old fashioned',
            'history' => 'Florencia, 1919.',
            'steps' => ['Remover con hielo', 'Colar'],
            'ingredients' => [
                ['name' => 'Ginebra', 'amount' => 30, 'unit' => 'ml'],
                ['name' => 'Campari', 'amount' => 30, 'unit' => 'ml'],
            ],
        ])->assertCreated()
            ->assertJsonPath('data.ingredients.1.name', 'Campari')
            ->json('data.id');

        // Edición: reemplaza ingredientes
        $this->putJson("/api/v1/admin/cocktails/$cocktailId", [
            'name' => 'Negroni Sbagliato',
            'ingredients' => [['name' => 'Prosecco', 'amount' => 30, 'unit' => 'ml']],
        ])->assertOk()->assertJsonCount(1, 'data.ingredients')->assertJsonPath('data.name', 'Negroni Sbagliato');

        // Vista pública sin login
        $this->app['auth']->forgetGuards();
        $code = $admin->establishment->code;

        $this->getJson("/api/v1/public/$code")->assertOk()
            ->assertJsonPath('families.0.name', 'Clásicos')
            ->assertJsonPath('families.0.cocktails_count', 1);
        $this->getJson("/api/v1/public/$code/families/$familyId")->assertOk()->assertJsonCount(1, 'cocktails');
        $this->getJson("/api/v1/public/$code/cocktails/$cocktailId")->assertOk()
            ->assertJsonPath('data.history', 'Florencia, 1919.')
            ->assertJsonPath('data.steps.0', 'Remover con hielo');
    }

    public function test_unpublished_cocktails_are_hidden_from_public(): void
    {
        $admin = $this->admin();
        $family = $admin->establishment->families()->create(['name' => 'Casa']);
        $c = new Cocktail(['name' => 'Secreto', 'family_id' => $family->id, 'is_published' => false]);
        $c->establishment_id = $admin->establishment_id;
        $c->save();

        $code = $admin->establishment->code;
        $this->getJson("/api/v1/public/$code/cocktails/{$c->id}")->assertNotFound();
        $this->getJson("/api/v1/public/$code/families/{$family->id}")->assertJsonCount(0, 'cocktails');
    }

    public function test_establishments_are_isolated(): void
    {
        $a = $this->admin('111111');
        $b = $this->admin('222222');
        $familyB = $b->establishment->families()->create(['name' => 'De B']);

        Sanctum::actingAs($a);
        $this->putJson("/api/v1/admin/families/{$familyB->id}", ['name' => 'hackeado'])->assertNotFound();
        $this->deleteJson("/api/v1/admin/families/{$familyB->id}")->assertNotFound();
        $this->postJson('/api/v1/admin/cocktails', ['family_id' => $familyB->id, 'name' => 'X'])->assertStatus(422);
        $this->getJson('/api/v1/admin/families')->assertJsonCount(0, 'data');

        // Y el público de A no ve la familia de B
        $this->getJson("/api/v1/public/111111/families/{$familyB->id}")->assertNotFound();
    }

    public function test_admin_routes_require_login(): void
    {
        $this->getJson('/api/v1/admin/families')->assertUnauthorized();
    }

    public function test_family_with_cocktails_needs_force_to_delete(): void
    {
        $admin = $this->admin();
        Sanctum::actingAs($admin);
        $familyId = $this->postJson('/api/v1/admin/families', ['name' => 'F'])->json('data.id');
        $this->postJson('/api/v1/admin/cocktails', ['family_id' => $familyId, 'name' => 'C'])->assertCreated();

        $this->deleteJson("/api/v1/admin/families/$familyId")->assertStatus(409);
        $this->deleteJson("/api/v1/admin/families/$familyId?force=1")->assertOk();
        $this->assertDatabaseCount('cocktails', 0);
    }

    public function test_carousel_images_upload_reorder_delete_and_reject_non_images(): void
    {
        Storage::fake('public');
        $admin = $this->admin();
        Sanctum::actingAs($admin);
        $familyId = $this->postJson('/api/v1/admin/families', ['name' => 'F'])->json('data.id');
        $id = $this->postJson('/api/v1/admin/cocktails', ['family_id' => $familyId, 'name' => 'C'])->json('data.id');

        $images = $this->post("/api/v1/admin/cocktails/$id/images", [
            'images' => [UploadedFile::fake()->image('a.jpg'), UploadedFile::fake()->image('b.png')],
        ], ['Accept' => 'application/json'])->assertCreated()->assertJsonCount(2, 'data')->json('data');

        $this->putJson("/api/v1/admin/cocktails/$id/images/order", ['ids' => [$images[1]['id'], $images[0]['id']]])
            ->assertOk()->assertJsonPath('data.0.id', $images[1]['id']);

        $this->deleteJson("/api/v1/admin/cocktails/$id/images/{$images[0]['id']}")->assertOk()->assertJsonCount(1, 'data');
        $this->assertCount(1, Storage::disk('public')->allFiles());

        // Un .php disfrazado no pasa
        $this->post("/api/v1/admin/cocktails/$id/images", [
            'image' => UploadedFile::fake()->create('shell.php', 1, 'application/x-php'),
        ], ['Accept' => 'application/json'])->assertStatus(422);
    }

    public function test_library_copy_into_family(): void
    {
        $this->seed(LibrarySeeder::class);
        $admin = $this->admin();
        Sanctum::actingAs($admin);
        $familyId = $this->postJson('/api/v1/admin/families', ['name' => 'Clásicos'])->json('data.id');

        $library = $this->getJson('/api/v1/admin/library')->assertOk()->json('data');
        $this->assertGreaterThanOrEqual(15, count($library));
        $negroni = collect($library)->firstWhere('name', 'Negroni');

        $this->postJson('/api/v1/admin/library/copy', ['family_id' => $familyId, 'cocktail_ids' => [$negroni['id']]])
            ->assertCreated();

        $copy = Cocktail::where('establishment_id', $admin->establishment_id)->first();
        $this->assertSame($negroni['id'], $copy->source_cocktail_id);
        $this->assertCount(3, $copy->ingredients);
        $this->assertNotEmpty($copy->utensils);

        // Editar la copia no toca la biblioteca
        $this->putJson("/api/v1/admin/cocktails/{$copy->id}", ['name' => 'Negroni de la casa'])->assertOk();
        $this->assertTrue(Cocktail::library()->where('name', 'Negroni')->exists());

        // La biblioteca no es visible ni editable como cóctel propio
        $this->getJson("/api/v1/admin/cocktails/{$negroni['id']}")->assertNotFound();
    }
}
