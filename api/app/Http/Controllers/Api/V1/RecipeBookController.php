<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\CocktailResource;
use App\Http\Resources\V1\CocktailSummaryResource;
use App\Models\Cocktail;
use Illuminate\Http\JsonResponse;

/**
 * Recetario público: la biblioteca de cócteles clásicos para cualquiera, sin login.
 * Solo lectura y sin datos internos (copias de los locales, etc.).
 */
class RecipeBookController extends Controller
{
    public function index(): JsonResponse
    {
        $cocktails = Cocktail::library()->published()->with('images')->orderBy('name')->get();

        return response()->json(['success' => true, 'data' => CocktailSummaryResource::collection($cocktails)]);
    }

    public function show(int $id): JsonResponse
    {
        $cocktail = Cocktail::library()->published()
            ->with(['images', 'ingredients', 'utensils'])
            ->findOrFail($id);

        return response()->json(['success' => true, 'data' => new CocktailResource($cocktail)]);
    }
}
