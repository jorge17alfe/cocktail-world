<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Support\PlanLimits;
use App\Http\Requests\V1\FamilyRequest;
use App\Http\Requests\V1\ImageUploadRequest;
use App\Http\Resources\V1\FamilyResource;
use App\Support\Media;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FamilyController extends AdminController
{
    public function index(): JsonResponse
    {
        $families = $this->establishment()->families()->withCount('cocktails')->get();

        return response()->json(['success' => true, 'data' => FamilyResource::collection($families)]);
    }

    public function store(FamilyRequest $request): JsonResponse
    {
        $data = $request->validated();
        PlanLimits::ensureCanAddFamilies($this->establishment());
        $data['order'] ??= $this->establishment()->families()->max('order') + 1;

        $family = $this->establishment()->families()->create($data);

        return response()->json(['success' => true, 'data' => new FamilyResource($family)], 201);
    }

    public function update(FamilyRequest $request, int $id): JsonResponse
    {
        $family = $this->establishment()->families()->findOrFail($id);
        $family->update($request->validated());

        return response()->json(['success' => true, 'data' => new FamilyResource($family)]);
    }

    /** Si la familia tiene cócteles hay que confirmar con ?force=1 (se borran también). */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $family = $this->establishment()->families()->withCount('cocktails')->findOrFail($id);

        if ($family->cocktails_count > 0 && ! $request->boolean('force')) {
            return response()->json([
                'success' => false,
                'message' => "La familia tiene {$family->cocktails_count} cócteles. Confirma para borrarlos también.",
                'cocktails_count' => $family->cocktails_count,
            ], 409);
        }

        DB::transaction(function () use ($family) {
            foreach ($family->cocktails()->with('images')->get() as $cocktail) {
                $cocktail->images->each(fn ($img) => Media::delete($img->path));
            }
            Media::delete($family->image);
            $family->delete();
        });

        return response()->json(['success' => true, 'message' => 'Familia eliminada']);
    }

    public function uploadImage(ImageUploadRequest $request, int $id): JsonResponse
    {
        $family = $this->establishment()->families()->findOrFail($id);

        Media::delete($family->image);
        $family->update(['image' => Media::store($request->uploadedImages()[0], $this->mediaDir('families'))]);

        return response()->json(['success' => true, 'data' => new FamilyResource($family)]);
    }
}
