<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** Ficha completa del cóctel. */
class CocktailResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'family_id' => $this->family_id,
            'family_name' => $this->whenLoaded('family', fn () => $this->family?->name),
            'name' => $this->name,
            'images' => $this->images->map(fn ($img) => ['id' => $img->id, 'url' => $img->url])->values(),
            'ingredients' => $this->ingredients->map(fn ($i) => [
                'id' => $i->id,
                'name' => $i->name,
                'amount' => $i->amount,
                'unit' => $i->unit,
                'note' => $i->note,
            ])->values(),
            'steps' => $this->steps ?? [],
            'history' => $this->history,
            'utensils' => UtensilResource::collection($this->utensils),
            'glass' => $this->glass,
            'technique' => $this->technique,
            'ice' => $this->ice,
            'garnish' => $this->garnish,
            'price' => $this->price,
            'tags' => $this->tags ?? [],
            'is_published' => $this->is_published,
            'order' => $this->order,
            'source_cocktail_id' => $this->source_cocktail_id,
        ];
    }
}
