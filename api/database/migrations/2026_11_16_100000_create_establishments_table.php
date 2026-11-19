<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('establishments', function (Blueprint $table) {
            $table->id();
            $table->string('code', 12)->unique(); // número de establecimiento (login + URL pública)
            $table->string('name');
            $table->string('logo')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::table('users', function (Blueprint $table) {
            $table->foreignId('establishment_id')->nullable()->after('id')
                ->constrained()->cascadeOnDelete();
            $table->string('role', 20)->default('admin')->after('establishment_id');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropConstrainedForeignId('establishment_id');
            $table->dropColumn('role');
        });
        Schema::dropIfExists('establishments');
    }
};
