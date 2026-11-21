<?php

namespace App\Http\Resources\V1;

use App\Support\Media;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EstablishmentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'code' => $this->code,
            'name' => $this->name,
            'logo_url' => Media::url($this->logo),
            // Enlace de la carta web (el que lleva el QR)
            'public_url' => route('carta.show', $this->code),
            // Firma "Carta creada con Cocktail World" al final de la carta
            'show_branding' => $this->show_branding ?? true,
        ];
    }
}
