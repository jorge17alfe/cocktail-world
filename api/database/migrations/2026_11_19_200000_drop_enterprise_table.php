<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Elimina la tabla del menú antiguo (API /mobile), sustituida por establishments/families/cocktails.
 * Copia de los datos en storage/app/backup/datos_antiguos_2026-11-19.json
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::dropIfExists('enterprise');
    }

    public function down(): void
    {
        Schema::create('enterprise', function (Blueprint $table) {
            $table->unsignedBigInteger('id')->primary();
            $table->string('enterprise_name')->nullable();
            $table->json('configuration')->nullable();
            $table->json('sections')->nullable();
            $table->timestamps();
        });
    }
};
