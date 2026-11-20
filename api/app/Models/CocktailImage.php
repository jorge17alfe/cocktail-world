<?php

namespace App\Models;

use App\Support\Media;
use Illuminate\Database\Eloquent\Model;

class CocktailImage extends Model
{
    protected $fillable = ['path', 'order'];

    protected static function booted(): void
    {
        // Foto sustituida: se borra la anterior del disco
        static::updated(function (CocktailImage $image) {
            if ($image->wasChanged('path')) {
                Media::delete($image->getOriginal('path'));
            }
        });
        // Foto quitada: se borra del disco
        static::deleted(fn (CocktailImage $image) => Media::delete($image->path));
    }

    public function getUrlAttribute(): ?string
    {
        return Media::url($this->path);
    }
}
