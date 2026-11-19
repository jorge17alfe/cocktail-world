<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * La app web se sirve desde el mismo dominio que la API (APP_URL). El navegador envía
 * Origin/Referer de ese dominio y la API (que usa tokens Bearer, no cookies) no debe pedir CSRF.
 */
class CsrfTest extends TestCase
{
    use RefreshDatabase;

    public function test_web_app_on_same_domain_can_register_without_csrf_token(): void
    {
        // En producción Sanctum marca como "stateful" (cookies + CSRF) el dominio de APP_URL
        config(['app.url' => 'https://cocktail-world.alocraise.com', 'sanctum.stateful' => ['cocktail-world.alocraise.com']]);

        $this->withHeaders([
            'Origin' => 'https://cocktail-world.alocraise.com',
            'Referer' => 'https://cocktail-world.alocraise.com/app/',
        ])->postJson('/api/v1/auth/register', [
            'establishment_name' => 'Bar', 'name' => 'Jorge', 'email' => 'j@t.com',
            'password' => 'secret123', 'password_confirmation' => 'secret123',
        ])->assertCreated()
            // Si la API entrara en modo "stateful" (sesión + CSRF) dejaría estas cookies;
            // en producción eso provoca "CSRF token mismatch" (en tests Laravel no comprueba CSRF).
            ->assertCookieMissing('XSRF-TOKEN')
            ->assertCookieMissing(config('session.cookie'));
    }
}
