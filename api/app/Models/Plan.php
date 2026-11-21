<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * Plan de suscripción de un local. Los límites a null significan "sin límite".
 * Se editan desde el panel de gestión (Plataforma → Planes).
 */
class Plan extends Model
{
    public const UNLIMITED = 'unlimited';

    public const FREE = 'free';

    protected $fillable = [
        'slug', 'name', 'description', 'price_monthly', 'max_families', 'max_cocktails',
        'max_images_per_cocktail', 'can_hide_branding', 'is_public', 'sort',
    ];

    protected $casts = [
        'price_monthly' => 'decimal:2',
        'max_families' => 'integer',
        'max_cocktails' => 'integer',
        'max_images_per_cocktail' => 'integer',
        'can_hide_branding' => 'boolean',
        'is_public' => 'boolean',
    ];

    public function establishments(): HasMany
    {
        return $this->hasMany(Establishment::class);
    }

    /** Plan para los locales nuevos (ajuste "default_plan" del panel; por defecto Ilimitado). */
    public static function forNewEstablishments(): ?self
    {
        return static::bySlug(Setting::get(Setting::DEFAULT_PLAN, self::UNLIMITED));
    }

    /** Plan que se aplica si la suscripción no está al día (ajuste "fallback_plan"; por defecto Gratis). */
    public static function fallback(): ?self
    {
        return static::bySlug(Setting::get(Setting::FALLBACK_PLAN, self::FREE));
    }

    public static function bySlug(?string $slug): ?self
    {
        return $slug ? static::where('slug', $slug)->first() : null;
    }
}
