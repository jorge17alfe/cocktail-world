<?php

namespace App\Http\Resources\V1;

use App\Support\Media;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FamilyResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'image_url' => Media::url($this->image),
            'order' => $this->order,
            'cocktails_count' => $this->whenCounted('cocktails'),
            'cocktails' => CocktailSummaryResource::collection($this->whenLoaded('cocktails')),
        ];
    }
}
