<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Requests\V1\ImageUploadRequest;
use App\Http\Requests\V1\UtensilRequest;
use App\Http\Resources\V1\UtensilResource;
use App\Models\Utensil;
use App\Support\Media;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

/** Catálogo de utensilios: globales (solo lectura) + propios del local. */
class UtensilController extends AdminController
{
    public function index(): JsonResponse
    {
        $utensils = Utensil::availableFor($this->establishment()->id)->orderBy('name')->get();

        return response()->json(['success' => true, 'data' => UtensilResource::collection($utensils)]);
    }

    public function store(UtensilRequest $request): JsonResponse
    {
        $utensil = $this->establishment()->utensils()->create($request->validated());

        return response()->json(['success' => true, 'data' => new UtensilResource($utensil)], 201);
    }

    public function update(UtensilRequest $request, int $id): JsonResponse
    {
        $utensil = $this->own($id);
        $utensil->update($request->validated());

        return response()->json(['success' => true, 'data' => new UtensilResource($utensil)]);
    }

    public function destroy(int $id): JsonResponse
    {
        $utensil = $this->own($id);
        Media::delete($utensil->image);
        $utensil->delete();

        return response()->json(['success' => true, 'message' => 'Utensilio eliminado']);
    }

    public function uploadImage(ImageUploadRequest $request, int $id): JsonResponse
    {
        $utensil = $this->own($id);
        Media::delete($utensil->image);
        $utensil->update(['image' => Media::store($request->uploadedImages()[0], $this->mediaDir('utensils'))]);

        return response()->json(['success' => true, 'data' => new UtensilResource($utensil)]);
    }

    /**
     * Personalizar un utensilio de la biblioteca: crea una copia propia (para poder ponerle foto,
     * cambiarle el nombre...) y la sustituye en todos los cócteles del local.
     */
    public function adopt(int $id): JsonResponse
    {
        $establishment = $this->establishment();
        $global = Utensil::whereNull('establishment_id')->findOrFail($id);

        $existing = $establishment->utensils()->where('source_utensil_id', $global->id)->first();
        if ($existing) {
            return response()->json(['success' => true, 'data' => new UtensilResource($existing)]);
        }

        $own = DB::transaction(function () use ($establishment, $global) {
            $own = new Utensil($global->only(['name', 'description']));
            $own->establishment_id = $establishment->id;
            $own->source_utensil_id = $global->id;
            if ($global->image) {
                $own->image = Media::copy($global->image, $this->mediaDir('utensils'));
            }
            $own->save();

            DB::table('cocktail_utensil')
                ->where('utensil_id', $global->id)
                ->whereIn('cocktail_id', $establishment->cocktails()->select('id'))
                ->update(['utensil_id' => $own->id]);

            return $own;
        });

        return response()->json(['success' => true, 'data' => new UtensilResource($own)], 201);
    }

    /** Los utensilios globales no se pueden modificar desde un local. */
    private function own(int $id): Utensil
    {
        return $this->establishment()->utensils()->findOrFail($id);
    }
}
