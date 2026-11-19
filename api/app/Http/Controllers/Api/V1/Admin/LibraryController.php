<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Resources\V1\CocktailResource;
use App\Http\Resources\V1\CocktailSummaryResource;
use App\Models\Cocktail;
use App\Models\Utensil;
use App\Support\Media;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

/** Biblioteca base de cócteles que cada local puede copiar y adaptar. */
class LibraryController extends AdminController
{
    public function index(Request $request): JsonResponse
    {
        $cocktails = Cocktail::library()->with('images')
            ->when($request->filled('q'), fn ($q) => $q->where('name', 'like', '%' . $request->string('q') . '%'))
            ->orderBy('name')->get();

        return response()->json(['success' => true, 'data' => CocktailSummaryResource::collection($cocktails)]);
    }

    public function show(int $id): JsonResponse
    {
        $cocktail = Cocktail::library()->with(['images', 'ingredients', 'utensils'])->findOrFail($id);

        return response()->json(['success' => true, 'data' => new CocktailResource($cocktail)]);
    }

    /** Body: { "family_id": 1, "cocktail_ids": [4, 7, 9] } */
    public function copy(Request $request): JsonResponse
    {
        $establishment = $this->establishment();
        $data = $request->validate([
            'family_id' => ['required', 'integer',
                Rule::exists('families', 'id')->where('establishment_id', $establishment->id)],
            'cocktail_ids' => ['required', 'array', 'min:1', 'max:100'],
            'cocktail_ids.*' => ['integer', Rule::exists('cocktails', 'id')->whereNull('establishment_id')],
        ]);

        $sources = Cocktail::library()->with(['images', 'ingredients', 'utensils'])
            ->whereIn('id', $data['cocktail_ids'])->get();

        // Utensilios globales que el local ha personalizado: global_id => propio_id
        $adopted = Utensil::where('establishment_id', $establishment->id)
            ->whereNotNull('source_utensil_id')->pluck('id', 'source_utensil_id');

        $copies = DB::transaction(function () use ($sources, $data, $establishment, $adopted) {
            $order = (int) Cocktail::where('family_id', $data['family_id'])->max('order');

            return $sources->map(function (Cocktail $source) use ($data, $establishment, $adopted, &$order) {
                $copy = $source->replicate(['establishment_id', 'family_id', 'source_cocktail_id', 'order']);
                $copy->establishment_id = $establishment->id;
                $copy->family_id = $data['family_id'];
                $copy->source_cocktail_id = $source->id;
                $copy->order = ++$order;
                $copy->save();

                foreach ($source->ingredients as $ingredient) {
                    $copy->ingredients()->create($ingredient->only(['name', 'amount', 'unit', 'note', 'order']));
                }
                $copy->utensils()->sync($source->utensils->pluck('id')->map(fn ($id) => $adopted[$id] ?? $id));

                // Copia física de las fotos: así el local puede borrarlas sin afectar a la biblioteca
                foreach ($source->images as $image) {
                    if ($path = Media::copy($image->path, $this->mediaDir("cocktails/{$copy->id}"))) {
                        $copy->images()->create(['path' => $path, 'order' => $image->order]);
                    }
                }

                return $copy->load('images');
            });
        });

        return response()->json([
            'success' => true,
            'message' => count($copies) . ' cócteles copiados',
            'data' => CocktailSummaryResource::collection($copies),
        ], 201);
    }
}
