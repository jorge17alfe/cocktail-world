<?php

namespace App\Http\Requests\V1;

use Illuminate\Foundation\Http\FormRequest;

/** Subida de una o varias imágenes: campo "image" o "images[]". */
class ImageUploadRequest extends FormRequest
{
    public const RULE = ['image', 'mimes:jpg,jpeg,png,webp', 'max:5120']; // 5 MB

    public function rules(): array
    {
        return [
            'image' => ['required_without:images', ...self::RULE],
            'images' => ['required_without:image', 'array', 'max:10'],
            'images.*' => self::RULE,
        ];
    }

    /** @return \Illuminate\Http\UploadedFile[] */
    public function uploadedImages(): array
    {
        return $this->hasFile('images') ? $this->file('images') : [$this->file('image')];
    }
}
