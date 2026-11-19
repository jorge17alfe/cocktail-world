<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\CocktailResource;
use App\Http\Resources\V1\CocktailSummaryResource;
use App\Http\Resources\V1\EstablishmentResource;
use App\Http\Resources\V1\FamilyResource;
use App\Models\Establishment;
use Illuminate\Http\JsonResponse;

/** Vista pública (clientes y camareros): solo lectura y solo cócteles publicados. */
class PublicController extends Controller
{
    /** Datos del local + sus familias. */
    public function show(string $code): JsonResponse
    {
        $establishment = $this->establishment($code);

        $families = $establishment->families()
            ->withCount(['cocktails' => fn ($q) => $q->published()])
            ->get();

        return response()->json([
            'success' => true,
            'establishment' => new EstablishmentResource($establishment),
            'families' => FamilyResource::collection($families),
        ]);
    }

    /** Cócteles publicados de una familia. */
    public function family(string $code, int $familyId): JsonResponse
    {
        $family = $this->establishment($code)->families()->findOrFail($familyId);

        $cocktails = $family->cocktails()->published()->with('images')->get();

        return response()->json([
            'success' => true,
            'family' => new FamilyResource($family),
            'cocktails' => CocktailSummaryResource::collection($cocktails),
        ]);
    }

    /** Ficha completa: carrusel, ingredientes, elaboración, historia, utensilios. */
    public function cocktail(string $code, int $cocktailId): JsonResponse
    {
        $cocktail = $this->establishment($code)->cocktails()->published()
            ->with(['family', 'images', 'ingredients', 'utensils'])
            ->findOrFail($cocktailId);

        return response()->json(['success' => true, 'data' => new CocktailResource($cocktail)]);
    }

    private function establishment(string $code): Establishment
    {
        return Establishment::where('code', $code)->where('is_active', true)->firstOrFail();
    }
}
