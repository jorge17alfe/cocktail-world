<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Models\Setting;
use Illuminate\Http\JsonResponse;

/** Datos de contacto de Alocraise para los locales (se cambian en el panel de gestión). */
class SupportController extends AdminController
{
    public function show(): JsonResponse
    {
        return response()->json(['success' => true, 'data' => ['email' => Setting::supportEmail()]]);
    }
}
