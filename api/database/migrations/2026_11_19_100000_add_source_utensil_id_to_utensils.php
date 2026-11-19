<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /** Utensilio global que un local ha "personalizado" (copia propia con su foto). */
    public function up(): void
    {
        Schema::table('utensils', function (Blueprint $table) {
            $table->foreignId('source_utensil_id')->nullable()->after('establishment_id')
                ->constrained('utensils')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('utensils', function (Blueprint $table) {
            $table->dropConstrainedForeignId('source_utensil_id');
        });
    }
};
