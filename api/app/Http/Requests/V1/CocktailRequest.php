<?php

namespace App\Http\Requests\V1;

use App\Models\Cocktail;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CocktailRequest extends FormRequest
{
    public function rules(): array
    {
        $establishmentId = $this->user()->establishment_id;
        $required = $this->isMethod('POST') ? 'required' : 'sometimes';

        return [
            'name' => [$required, 'string', 'max:120'],
            'family_id' => [$required, 'integer',
                Rule::exists('families', 'id')->where('establishment_id', $establishmentId)],
            'glass' => ['nullable', 'string', 'max:120'],
            'technique' => ['nullable', Rule::in(Cocktail::TECHNIQUES)],
            'ice' => ['nullable', 'string', 'max:120'],
            'garnish' => ['nullable', 'string', 'max:255'],
            'history' => ['nullable', 'string', 'max:10000'],
            'steps' => ['nullable', 'array', 'max:30'],
            'steps.*' => ['string', 'max:1000'],
            'tags' => ['nullable', 'array', 'max:15'],
            'tags.*' => ['string', 'max:40'],
            'price' => ['nullable', 'numeric', 'min:0', 'max:9999'],
            'is_published' => ['sometimes', 'boolean'],
            'order' => ['sometimes', 'integer', 'min:0'],

            'ingredients' => ['sometimes', 'array', 'max:30'],
            'ingredients.*.name' => ['required', 'string', 'max:120'],
            'ingredients.*.amount' => ['nullable', 'numeric', 'min:0'],
            'ingredients.*.unit' => ['nullable', 'string', 'max:20'],
            'ingredients.*.note' => ['nullable', 'string', 'max:120'],

            'utensil_ids' => ['sometimes', 'array'],
            'utensil_ids.*' => ['integer', Rule::exists('utensils', 'id')->where(
                fn ($q) => $q->whereNull('establishment_id')->orWhere('establishment_id', $establishmentId)
            )],
        ];
    }
}
