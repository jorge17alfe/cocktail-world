<?php

use App\Http\Controllers\Web\WebAppController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// App Flutter web: inicio + administración (/app) y carta pública del QR (/carta/{número}).
// Los archivos de la app (/app/main.dart.js, /app/assets/...) los sirve directamente el servidor web.
Route::get('/app', WebAppController::class);
Route::get('/carta/{code}/{rest?}', WebAppController::class)
    ->where(['code' => '\d{4,12}', 'rest' => '.*'])
    ->name('carta.show');
// Recetario público: /recetario y /recetario/c/{cóctel}
Route::get('/recetario/{rest?}', WebAppController::class)->where('rest', '.*')->name('recetario');
