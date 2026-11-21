<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Cache;

/**
 * Ajustes de la plataforma guardados en la tabla "settings".
 * Uso: Setting::get('support_email'), Setting::put('support_email', 'soporte@...').
 */
class Setting extends Model
{
    public const SUPPORT_EMAIL = 'support_email';

    /** Plan (slug) que reciben los locales nuevos. */
    public const DEFAULT_PLAN = 'default_plan';

    /** Plan (slug) que se aplica a un local cuya suscripción no está al día. */
    public const FALLBACK_PLAN = 'fallback_plan';

    protected $primaryKey = 'key';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = ['key', 'value'];

    public static function get(string $key, ?string $default = null): ?string
    {
        $value = Cache::rememberForever("setting.$key", fn () => static::query()->find($key)?->value);

        return filled($value) ? $value : $default;
    }

    public static function put(string $key, ?string $value): void
    {
        static::query()->updateOrCreate(['key' => $key], ['value' => $value]);
        Cache::forget("setting.$key");
    }

    /** Email al que los locales escriben (p. ej. "¿Echas de menos un cóctel?"). */
    public static function supportEmail(): string
    {
        return static::get(self::SUPPORT_EMAIL, config('cocktail.support_email'));
    }
}
