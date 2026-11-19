<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Requests\V1\CocktailRequest;
use App\Http\Resources\V1\CocktailResource;
use App\Http\Resources\V1\CocktailSummaryResource;
use App\Models\Cocktail;
use App\Support\Media;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CocktailController extends AdminController
{
    /** Listado (opcionalmente por familia), incluye los no publicados. */
    public function index(Request $request): JsonResponse
    {
        $cocktails = $this->establishment()->cocktails()
            ->when($request->filled('family_id'), fn ($q) => $q->where('family_id', $request->integer('family_id')))
            ->with('images')->orderBy('order')->orderBy('id')->get();

        return response()->json(['success' => true, 'data' => CocktailSummaryResource::collection($cocktails)]);
    }

    public function show(int $id): JsonResponse
    {
        return $this->respond($this->find($id));
    }

    public function store(CocktailRequest $request): JsonResponse
    {
        $data = $request->validated();

        $cocktail = DB::transaction(function () use ($data) {
            $cocktail = new Cocktail(collect($data)->except(['ingredients', 'utensil_ids'])->all());
            $cocktail->establishment_id = $this->establishment()->id;
            $cocktail->order ??= Cocktail::where('family_id', $data['family_id'])->max('order') + 1;
            $cocktail->save();

            $this->syncRelations($cocktail, $data);

            return $cocktail;
        });

        return $this->respond($cocktail, 201);
    }

    public function update(CocktailRequest $request, int $id): JsonResponse
    {
        $cocktail = $this->find($id);
        $data = $request->validated();

        DB::transaction(function () use ($cocktail, $data) {
            $cocktail->update(collect($data)->except(['ingredients', 'utensil_ids'])->all());
            $this->syncRelations($cocktail, $data);
        });

        return $this->respond($cocktail);
    }

    public function destroy(int $id): JsonResponse
    {
        $cocktail = $this->find($id);

        DB::transaction(function () use ($cocktail) {
            $cocktail->images->each(fn ($img) => Media::delete($img->path));
            $cocktail->delete();
        });

        return response()->json(['success' => true, 'message' => 'Cóctel eliminado']);
    }

    /** Si se envían ingredients / utensil_ids se reemplazan enteros (el orden es el del array). */
    private function syncRelations(Cocktail $cocktail, array $data): void
    {
        if (array_key_exists('ingredients', $data)) {
            $cocktail->ingredients()->delete();
            foreach (array_values($data['ingredients']) as $i => $ingredient) {
                $cocktail->ingredients()->create($ingredient + ['order' => $i]);
            }
        }

        if (array_key_exists('utensil_ids', $data)) {
            $cocktail->utensils()->sync($data['utensil_ids']);
        }
    }

    private function find(int $id): Cocktail
    {
        return $this->establishment()->cocktails()->with('images')->findOrFail($id);
    }

    private function respond(Cocktail $cocktail, int $status = 200): JsonResponse
    {
        $cocktail->load(['family', 'images', 'ingredients', 'utensils']);

        return response()->json(['success' => true, 'data' => new CocktailResource($cocktail)], $status);
    }
}
