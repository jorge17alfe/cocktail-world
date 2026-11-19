<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** Versión ligera para listados (tarjeta con nombre + foto). */
class CocktailSummaryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'family_id' => $this->family_id,
            'name' => $this->name,
            'image_url' => $this->relationLoaded('images') ? $this->images->first()?->url : null,
            'price' => $this->price,
            'tags' => $this->tags ?? [],
            'is_published' => $this->is_published,
            'order' => $this->order,
            'source_cocktail_id' => $this->source_cocktail_id,
        ];
    }
}
