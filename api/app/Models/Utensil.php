<?php

namespace App\Models;

use App\Support\Media;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Utensil extends Model
{
    protected $fillable = ['name', 'description', 'image'];

    protected static function booted(): void
    {
        static::updated(function (Utensil $utensil) {
            if ($utensil->wasChanged('image')) {
                Media::delete($utensil->getOriginal('image'));
            }
        });
        static::deleted(fn (Utensil $utensil) => Media::delete($utensil->image));
    }

    /** Cócteles (de la biblioteca y de los locales) que usan este utensilio. */
    public function cocktails(): BelongsToMany
    {
        return $this->belongsToMany(Cocktail::class);
    }

    /**
     * Utensilios propios del establecimiento + los globales que no haya personalizado
     * (si ha personalizado "Coctelera", solo se ve su versión).
     */
    public function scopeAvailableFor(Builder $query, int $establishmentId): Builder
    {
        return $query->where(fn ($q) => $q->where('establishment_id', $establishmentId)
            ->orWhere(fn ($g) => $g->whereNull('establishment_id')->whereNotIn('id',
                static::query()->select('source_utensil_id')
                    ->where('establishment_id', $establishmentId)->whereNotNull('source_utensil_id'))));
    }

    public function isGlobal(): bool
    {
        return $this->establishment_id === null;
    }
}
