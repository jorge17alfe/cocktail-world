<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Agregar columnas para móvil
            $table->string('phone')->nullable()->after('email');
            $table->string('device_name')->nullable()->after('phone');
            $table->text('fcm_token')->nullable()->after('device_name');
            
            // Columnas adicionales útiles
            $table->timestamp('last_login_at')->nullable()->after('fcm_token');
            $table->string('last_login_ip')->nullable()->after('last_login_at');
            $table->boolean('is_active')->default(true)->after('last_login_ip');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'phone',
                'device_name',
                'fcm_token',
                'last_login_at',
                'last_login_ip',
                'is_active'
            ]);
        });
    }
};