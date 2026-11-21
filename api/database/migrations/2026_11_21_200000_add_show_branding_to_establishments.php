<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Firma "Carta creada con Cocktail World" al final de la carta pública.
 * Por defecto se muestra; más adelante (planes de pago) un local podrá ocultarla.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('establishments', function (Blueprint $table) {
            $table->boolean('show_branding')->default(true)->after('is_active');
        });
    }

    public function down(): void
    {
        Schema::table('establishments', function (Blueprint $table) {
            $table->dropColumn('show_branding');
        });
    }
};
