<?php

namespace App\Support;

use App\Models\Establishment;
use App\Models\User;
use Illuminate\Support\Facades\DB;

/**
 * Operaciones de Alocraise sobre los locales (usadas desde el panel de gestión).
 * Separadas del panel para poder probarlas y reutilizarlas (p. ej. suspender por impago).
 */
class EstablishmentManager
{
    /**
     * Alta de un local con su administrador. Devuelve el local y la contraseña temporal
     * (solo se conoce en este momento: se guarda cifrada).
     *
     * @return array{establishment: Establishment, admin: User, password: string}
     */
    public function createWithAdmin(string $name, string $adminName, string $adminEmail): array
    {
        $password = self::temporaryPassword();

        [$establishment, $admin] = DB::transaction(function () use ($name, $adminName, $adminEmail, $password) {
            $establishment = Establishment::create([
                'code' => Establishment::generateCode(),
                'name' => $name,
            ]);
            $admin = $establishment->users()->create([
                'role' => User::ROLE_ADMIN,
                'name' => $adminName,
                'email' => strtolower(trim($adminEmail)),
                'password' => $password,
            ]);

            return [$establishment, $admin];
        });

        return ['establishment' => $establishment, 'admin' => $admin, 'password' => $password];
    }

    /** Suspende el local: sin login en la app, sin carta pública, y se cierran sus sesiones. */
    public function suspend(Establishment $establishment): void
    {
        $establishment->update(['is_active' => false]);
        $establishment->users->each(fn (User $user) => $user->tokens()->delete());
    }

    public function reactivate(Establishment $establishment): void
    {
        $establishment->update(['is_active' => true]);
    }

    /** Nueva contraseña temporal para un admin: cierra sus sesiones y la devuelve (se muestra una vez). */
    public function resetPassword(User $user): string
    {
        $password = self::temporaryPassword();
        $user->update(['password' => $password]);
        $user->tokens()->delete();

        return $password;
    }

    /** Desactiva o reactiva a un administrador concreto (sin tocar el resto del local). */
    public function setUserActive(User $user, bool $active): void
    {
        $user->update(['is_active' => $active]);
        if (! $active) {
            $user->tokens()->delete();
        }
    }

    /**
     * Contraseña temporal fácil de dictar: sin caracteres que se confundan (0/O, 1/l/I),
     * en bloques de 4 → p. ej. "kx7q-m3pa-9wtc".
     */
    public static function temporaryPassword(): string
    {
        $alphabet = 'abcdefghjkmnpqrstuvwxyz23456789';
        $chars = '';
        for ($i = 0; $i < 12; $i++) {
            $chars .= $alphabet[random_int(0, strlen($alphabet) - 1)];
        }

        return implode('-', str_split($chars, 4));
    }
}
