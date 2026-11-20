<?php

namespace App\Models;

use Filament\Auth\MultiFactor\App\Concerns\InteractsWithAppAuthentication;
use Filament\Auth\MultiFactor\App\Concerns\InteractsWithAppAuthenticationRecovery;
use Filament\Auth\MultiFactor\App\Contracts\HasAppAuthentication;
use Filament\Auth\MultiFactor\App\Contracts\HasAppAuthenticationRecovery;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable implements FilamentUser, HasAppAuthentication, HasAppAuthenticationRecovery
{
    use HasFactory, Notifiable, HasApiTokens;

    // 2FA del panel de gestión: secreto y códigos de recuperación (cifrados)
    use InteractsWithAppAuthentication, InteractsWithAppAuthenticationRecovery;

    /** Administrador de un local (gestiona su carta desde la app). */
    public const ROLE_ADMIN = 'admin';

    /** Alocraise: gestiona la plataforma desde el panel de gestión. No pertenece a ningún local. */
    public const ROLE_SUPERADMIN = 'superadmin';

    protected $fillable = [
        'establishment_id',
        'role',
        'name',
        'email',
        'phone',
        'password',
        'device_name',
        'fcm_token',
        'last_login_at',
        'last_login_ip',
        'is_active',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'fcm_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'last_login_at' => 'datetime',
        'is_active' => 'boolean',
    ];

    public function establishment(): BelongsTo
    {
        return $this->belongsTo(Establishment::class);
    }

    public function isAdmin(): bool
    {
        return $this->role === self::ROLE_ADMIN;
    }

    public function isSuperadmin(): bool
    {
        return $this->role === self::ROLE_SUPERADMIN && $this->establishment_id === null;
    }

    /** Filament: al panel de gestión solo entran superadmins activos. */
    public function canAccessPanel(Panel $panel): bool
    {
        return $this->isSuperadmin() && $this->is_active !== false;
    }
}
