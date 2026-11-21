<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Establishment extends Model
{
    protected $fillable = ['code', 'name', 'logo', 'is_active', 'show_branding'];

    protected $casts = ['is_active' => 'boolean', 'show_branding' => 'boolean'];

    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }

    public function families(): HasMany
    {
        return $this->hasMany(Family::class)->orderBy('order')->orderBy('id');
    }

    public function cocktails(): HasMany
    {
        return $this->hasMany(Cocktail::class);
    }

    public function utensils(): HasMany
    {
        return $this->hasMany(Utensil::class);
    }

    /** Genera un número de establecimiento único de 6 cifras. */
    public static function generateCode(): string
    {
        do {
            $code = (string) random_int(100000, 999999);
        } while (static::where('code', $code)->exists());

        return $code;
    }
}
