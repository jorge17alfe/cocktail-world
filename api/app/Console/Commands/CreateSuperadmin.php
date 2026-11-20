<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;

/**
 * Crea (o actualiza la contraseña de) un superadministrador de Alocraise, que entra en el
 * panel de gestión. Solo se puede hacer desde la consola del servidor: nunca desde la app.
 *
 *   php artisan cocktail:superadmin tu@email.com
 *   php artisan cocktail:superadmin tu@email.com --reset-2fa   (si pierdes el móvil y los códigos)
 */
class CreateSuperadmin extends Command
{
    protected $signature = 'cocktail:superadmin {email : Email del superadministrador} {--name=Alocraise : Nombre visible} {--reset-2fa : Quita la verificación en dos pasos (se volverá a configurar al entrar)}';

    protected $description = 'Crea o actualiza un superadministrador de la plataforma (Alocraise)';

    public function handle(): int
    {
        $email = strtolower(trim($this->argument('email')));
        if (! filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $this->error('El email no es válido.');

            return self::FAILURE;
        }

        $existing = User::where('email', $email)->first();
        if ($existing && $existing->establishment_id !== null) {
            $this->error('Ese email ya es administrador de un local. Usa otro email para el superadmin.');

            return self::FAILURE;
        }

        if ($this->option('reset-2fa')) {
            if (! $existing?->isSuperadmin()) {
                $this->error('No hay ningún superadmin con ese email.');

                return self::FAILURE;
            }
            $existing->saveAppAuthenticationSecret(null);
            $existing->saveAppAuthenticationRecoveryCodes(null);
            $this->info("Verificación en dos pasos quitada para {$email}. Al entrar en el panel se te pedirá configurarla de nuevo.");

            return self::SUCCESS;
        }

        $password = (string) $this->secret('Contraseña (mínimo 10 caracteres)');
        if (mb_strlen($password) < 10) {
            $this->error('La contraseña debe tener al menos 10 caracteres.');

            return self::FAILURE;
        }
        if ($this->secret('Repite la contraseña') !== $password) {
            $this->error('Las contraseñas no coinciden.');

            return self::FAILURE;
        }

        $user = User::updateOrCreate(['email' => $email], [
            'name' => $this->option('name'),
            'role' => User::ROLE_SUPERADMIN,
            'establishment_id' => null,
            'password' => $password, // el cast 'hashed' la cifra
            'is_active' => true,
        ]);

        // Si ya existía, cerramos sus sesiones abiertas (por si se cambia la contraseña por seguridad)
        if (! $user->wasRecentlyCreated) {
            $user->tokens()->delete();
        }

        $this->info(($user->wasRecentlyCreated ? 'Superadmin creado: ' : 'Superadmin actualizado: ').$email);

        $this->line('Entra en el panel de gestión con este email y tu contraseña; la primera vez te pedirá configurar la verificación en dos pasos.');

        return self::SUCCESS;
    }
}
