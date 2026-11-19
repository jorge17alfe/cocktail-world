<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/** Solo deja pasar a administradores de un establecimiento activo. */
class EnsureEstablishmentAdmin
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (! $user || ! $user->establishment_id || ! $user->establishment?->is_active) {
            return response()->json(['success' => false, 'message' => 'Establecimiento no válido'], 403);
        }

        if (! $user->isAdmin()) {
            return response()->json(['success' => false, 'message' => 'Solo el administrador puede editar'], 403);
        }

        return $next($request);
    }
}
