<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Symfony\Component\HttpFoundation\Response;

/**
 * Sirve la app Flutter compilada para web (frontend/build_web.sh → public/app).
 * La misma app es la carta del QR (/carta/{número}) y el panel de administración (/app).
 */
class WebAppController extends Controller
{
    public function __invoke(): Response
    {
        $index = config('app.web_app_index') ?: public_path('app/index.html');

        if (! is_file($index)) {
            abort(503, 'La app web no está compilada. Ejecuta frontend/build_web.sh');
        }

        return response(file_get_contents($index), 200, [
            'Content-Type' => 'text/html; charset=utf-8',
            'Cache-Control' => 'no-cache', // así siempre carga la última versión publicada
        ]);
    }
}
