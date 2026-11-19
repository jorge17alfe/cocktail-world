<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Cocktail extends Model
{
    public const TECHNIQUES = ['shake', 'stir', 'build', 'blend', 'muddle', 'throw', 'layer', 'rolling'];

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

    public function scopeLibrary(Builder $query): Builder
    {
        return $query->whereNull('establishment_id');
    }

    public function scopePublished(Builder $query): Builder
    {
        return $query->where('is_published', true);
    }
}
