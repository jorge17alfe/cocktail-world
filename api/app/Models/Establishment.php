<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Establishment extends Model
{
    /** Estados de la suscripción. */
    public const STATUS_TRIAL = 'trial';

    public const STATUS_ACTIVE = 'active';

    public const STATUS_PAST_DUE = 'past_due';

    public const STATUS_CANCELED = 'canceled';

    public const STATUS_LABELS = [
        self::STATUS_TRIAL => 'En prueba',
        self::STATUS_ACTIVE => 'Activa',
        self::STATUS_PAST_DUE => 'Pago pendiente',
        self::STATUS_CANCELED => 'Cancelada',
    ];

    protected $fillable = [
        'code', 'name', 'logo', 'is_active', 'show_branding',
        'plan_id', 'subscription_status', 'trial_ends_at', 'subscription_ends_at', 'subscription_notes',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'show_branding' => 'boolean',
        'trial_ends_at' => 'datetime',
        'subscription_ends_at' => 'datetime',
    ];

    protected $attributes = [
        'subscription_status' => self::STATUS_ACTIVE,
    ];

    protected static function booted(): void
    {
        // Todo local nuevo (alta desde la app o desde el panel) recibe el plan por defecto
        static::creating(function (Establishment $establishment) {
            $establishment->plan_id ??= Plan::forNewEstablishments()?->id;
        });
    }

    public function plan(): BelongsTo
    {
        return $this->belongsTo(Plan::class);
    }

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

    /**
     * ¿La suscripción está al día?
     * - Activa: sí.
     * - En prueba: mientras no pase la fecha de fin de prueba.
     * - Cancelada: hasta la fecha de fin (lo ya pagado).
     * - Pago pendiente: no.
     */
    public function subscriptionIsCurrent(): bool
    {
        return match ($this->subscription_status) {
            self::STATUS_ACTIVE => true,
            self::STATUS_TRIAL => $this->trial_ends_at === null || $this->trial_ends_at->isFuture(),
            self::STATUS_CANCELED => $this->subscription_ends_at?->isFuture() ?? false,
            default => false,
        };
    }

    /** Plan cuyos límites se aplican ahora: el suyo si está al día; si no, el plan de respaldo. */
    public function effectivePlan(): ?Plan
    {
        return $this->subscriptionIsCurrent() ? $this->plan : (Plan::fallback() ?? $this->plan);
    }

    /** La firma "Carta creada con Cocktail World" solo se puede quitar con un plan que lo permita. */
    public function showsBranding(): bool
    {
        if ($this->show_branding ?? true) {
            return true;
        }

        return ! ($this->effectivePlan()?->can_hide_branding ?? false);
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
