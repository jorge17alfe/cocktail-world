<?php
use App\Http\Middleware\Cors;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php', 
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // CORS en todas las respuestas
        $middleware->append(Cors::class);

        // Nota: la API se autentica con tokens Bearer (Sanctum), no con cookies de sesión.
        // No se usa EnsureFrontendRequestsAreStateful: la app web se sirve desde el mismo dominio
        // y ese middleware le exigiría un token CSRF ("CSRF token mismatch").

        $middleware->alias([
            'establishment.admin' => \App\Http\Middleware\EnsureEstablishmentAdmin::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        // La API siempre responde JSON (también en 404, 422, 500...)
        $exceptions->shouldRenderJsonWhen(fn ($request) => $request->is('api/*') || $request->expectsJson());
    })->create();
