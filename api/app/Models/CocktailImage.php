<?php

namespace App\Models;

use App\Support\Media;
use Illuminate\Database\Eloquent\Model;

class CocktailImage extends Model
{
    protected $fillable = ['path', 'order'];

    public function getUrlAttribute(): ?string
    {
        return Media::url($this->path);
    }
}
