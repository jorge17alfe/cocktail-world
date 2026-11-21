<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\V1\AuthController as V1Auth;
use App\Http\Controllers\Api\V1\PublicController;
use App\Http\Controllers\Api\V1\Admin\CocktailController;
use App\Http\Controllers\Api\V1\Admin\CocktailImageController;
use App\Http\Controllers\Api\V1\Admin\FamilyController;
use App\Http\Controllers\Api\V1\Admin\LibraryController;
use App\Http\Controllers\Api\V1\Admin\SupportController;
use App\Http\Controllers\Api\V1\Admin\UtensilController;

// Ruta de salud para verificar que la API está funcionando
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'service' => 'Cocktail World API',
        'timestamp' => now()->toIso8601String(),
        'version' => '1.0.0',
    ]);
});

/*
|--------------------------------------------------------------------------
| API v1 — multi-establecimiento (familias, cócteles, biblioteca)
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {

    // Autenticación
    Route::prefix('auth')->group(function () {
        Route::middleware('throttle:10,1')->group(function () {
            Route::post('/register', [V1Auth::class, 'register']);
            Route::post('/login', [V1Auth::class, 'login']);
        });
        Route::middleware('auth:sanctum')->group(function () {
            Route::get('/me', [V1Auth::class, 'me']);
            Route::post('/logout', [V1Auth::class, 'logout']);
            Route::put('/password', [V1Auth::class, 'changePassword'])->middleware('throttle:10,1');
        });
    });

    // Vista pública: clientes y camareros (sin login, solo lectura)
    Route::prefix('public/{code}')->middleware('throttle:120,1')->group(function () {
        Route::get('/', [PublicController::class, 'show']);
        Route::get('/families/{family}', [PublicController::class, 'family'])->whereNumber('family');
        Route::get('/cocktails/{cocktail}', [PublicController::class, 'cocktail'])->whereNumber('cocktail');
    });

    // Panel del administrador del local
    Route::prefix('admin')->middleware(['auth:sanctum', 'establishment.admin'])->group(function () {
        Route::get('/families', [FamilyController::class, 'index']);
        Route::post('/families', [FamilyController::class, 'store']);
        Route::put('/families/{id}', [FamilyController::class, 'update'])->whereNumber('id');
        Route::delete('/families/{id}', [FamilyController::class, 'destroy'])->whereNumber('id');
        Route::post('/families/{id}/image', [FamilyController::class, 'uploadImage'])->whereNumber('id');

        Route::get('/cocktails', [CocktailController::class, 'index']);
        Route::post('/cocktails', [CocktailController::class, 'store']);
        Route::get('/cocktails/{id}', [CocktailController::class, 'show'])->whereNumber('id');
        Route::put('/cocktails/{id}', [CocktailController::class, 'update'])->whereNumber('id');
        Route::delete('/cocktails/{id}', [CocktailController::class, 'destroy'])->whereNumber('id');

        Route::post('/cocktails/{id}/images', [CocktailImageController::class, 'store'])->whereNumber('id');
        Route::put('/cocktails/{id}/images/order', [CocktailImageController::class, 'reorder'])->whereNumber('id');
        Route::delete('/cocktails/{id}/images/{image}', [CocktailImageController::class, 'destroy'])
            ->whereNumber(['id', 'image']);

        Route::get('/utensils', [UtensilController::class, 'index']);
        Route::post('/utensils', [UtensilController::class, 'store']);
        Route::put('/utensils/{id}', [UtensilController::class, 'update'])->whereNumber('id');
        Route::delete('/utensils/{id}', [UtensilController::class, 'destroy'])->whereNumber('id');
        Route::post('/utensils/{id}/image', [UtensilController::class, 'uploadImage'])->whereNumber('id');
        Route::post('/utensils/{id}/adopt', [UtensilController::class, 'adopt'])->whereNumber('id');

        Route::get('/library', [LibraryController::class, 'index']);
        Route::get('/library/{id}', [LibraryController::class, 'show'])->whereNumber('id');
        Route::post('/library/copy', [LibraryController::class, 'copy']);

        Route::get('/support', [SupportController::class, 'show']);
    });
});
