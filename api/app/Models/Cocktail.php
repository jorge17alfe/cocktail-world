<?php

namespace App\Models;

use App\Support\Media;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Cocktail extends Model
{
    public const TECHNIQUES = ['shake', 'stir', 'build', 'blend', 'muddle', 'throw', 'layer', 'rolling'];

    /** Nombres en español de cada técnica (los mismos que muestra la app). */
    public const TECHNIQUE_LABELS = [
        'shake' => 'Agitado',
        'stir' => 'Removido',
        'build' => 'Directo en vaso',
        'blend' => 'Batido',
        'muddle' => 'Macerado',
        'throw' => 'Lanzado',
        'layer' => 'En capas',
        'rolling' => 'Rolling',
    ];

    protected static function booted(): void
    {
        // Al borrar un cóctel se borran también sus fotos del disco
        // (las filas de cocktail_images las borra la base de datos en cascada).
        static::deleting(function (Cocktail $cocktail) {
            $cocktail->images()->get()->each(fn ($image) => Media::delete($image->path));
        });
    }

    protected $fillable = [
        'family_id', 'name', 'glass', 'technique', 'ice', 'garnish',
        'history', 'steps', 'tags', 'price', 'is_published', 'order',
    ];

    protected $casts = [
        'steps' => 'array',
        'tags' => 'array',
        'price' => 'float',
        'is_published' => 'boolean',
    ];

    public function establishment(): BelongsTo
    {
        return $this->belongsTo(Establishment::class);
    }

    public function family(): BelongsTo
    {
        return $this->belongsTo(Family::class);
    }

    public function ingredients(): HasMany
    {
        return $this->hasMany(Ingredient::class)->orderBy('order')->orderBy('id');
    }

    public function images(): HasMany
    {
        return $this->hasMany(CocktailImage::class)->orderBy('order')->orderBy('id');
    }

    public function utensils(): BelongsToMany
    {
        return $this->belongsToMany(Utensil::class)->orderBy('name');
    }

    /** Copias que los locales han hecho de este cóctel de la biblioteca. */
    public function copies(): HasMany
    {
        return $this->hasMany(Cocktail::class, 'source_cocktail_id');
    }

    public function scopeLibrary(Builder $query): Builder
    {
        return $query->whereNull('establishment_id');
    }

    public function scopePublished(Builder $query): Builder
    {
        return $query->where('is_published', true);
    }
}
