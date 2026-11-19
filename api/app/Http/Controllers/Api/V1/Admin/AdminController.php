<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\Establishment;

abstract class AdminController extends Controller
{
    /** Establecimiento del admin logueado: todo se busca a través de él (aislamiento entre locales). */
    protected function establishment(): Establishment
    {
        return request()->user()->establishment;
    }

    protected function mediaDir(string $sub): string
    {
        return "establishments/{$this->establishment()->id}/{$sub}";
    }
}
