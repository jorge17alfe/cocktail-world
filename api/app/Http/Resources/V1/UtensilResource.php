<?php

namespace App\Http\Resources\V1;

use App\Support\Media;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UtensilResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'image_url' => Media::url($this->image),
            'is_global' => $this->isGlobal(),
            'source_utensil_id' => $this->source_utensil_id,
        ];
    }
}
