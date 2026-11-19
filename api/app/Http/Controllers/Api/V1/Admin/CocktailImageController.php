<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Requests\V1\ImageUploadRequest;
use App\Models\Cocktail;
use App\Support\Media;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

/** Imágenes del carrusel de cada cóctel. */
class CocktailImageController extends AdminController
{
    public const MAX_IMAGES = 10;

    public function store(ImageUploadRequest $request, int $cocktailId): JsonResponse
    {
        $cocktail = $this->cocktail($cocktailId);
        $files = $request->uploadedImages();

        if ($cocktail->images()->count() + count($files) > self::MAX_IMAGES) {
            return response()->json([
                'success' => false,
                'message' => 'Máximo ' . self::MAX_IMAGES . ' imágenes por cóctel',
            ], 422);
        }

        $order = (int) $cocktail->images()->max('order');
        foreach ($files as $file) {
            $cocktail->images()->create([
                'path' => Media::store($file, $this->mediaDir("cocktails/{$cocktail->id}")),
                'order' => ++$order,
            ]);
        }

        return $this->respond($cocktail, 201);
    }

    public function destroy(int $cocktailId, int $imageId): JsonResponse
    {
        $image = $this->cocktail($cocktailId)->images()->findOrFail($imageId);
        Media::delete($image->path);
        $image->delete();

        return $this->respond($this->cocktail($cocktailId));
    }

    /** Body: { "ids": [3, 1, 2] } → nuevo orden del carrusel. */
    public function reorder(Request $request, int $cocktailId): JsonResponse
    {
        $cocktail = $this->cocktail($cocktailId);
        $data = $request->validate([
            'ids' => ['required', 'array'],
            'ids.*' => ['integer', Rule::exists('cocktail_images', 'id')->where('cocktail_id', $cocktail->id)],
        ]);

        foreach (array_values($data['ids']) as $i => $id) {
            $cocktail->images()->whereKey($id)->update(['order' => $i]);
        }

        return $this->respond($cocktail);
    }

    private function cocktail(int $id): Cocktail
    {
        return $this->establishment()->cocktails()->findOrFail($id);
    }

    private function respond(Cocktail $cocktail, int $status = 200): JsonResponse
    {
        $images = $cocktail->images()->get()->map(fn ($img) => ['id' => $img->id, 'url' => $img->url]);

        return response()->json(['success' => true, 'data' => $images], $status);
    }
}
