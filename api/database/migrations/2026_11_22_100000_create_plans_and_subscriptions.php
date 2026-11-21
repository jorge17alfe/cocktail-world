<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Suscripciones (preparadas, sin cobro todavía):
 * - plans: Gratis, Básico, Pro... con sus límites (null = sin límite). Se editan en el panel.
 * - establishments: plan, estado de la suscripción y fechas.
 * Todos los locales existentes pasan al plan "Ilimitado".
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('plans', function (Blueprint $table) {
            $table->id();
            $table->string('slug')->unique();
            $table->string('name');
            $table->string('description')->nullable();
            $table->decimal('price_monthly', 8, 2)->nullable(); // null = sin precio definido
            $table->unsignedInteger('max_families')->nullable();
            $table->unsignedInteger('max_cocktails')->nullable();
            $table->unsignedInteger('max_images_per_cocktail')->nullable();
            $table->boolean('can_hide_branding')->default(false);
            $table->boolean('is_public')->default(true); // se ofrece a los locales (Ilimitado no)
            $table->unsignedInteger('sort')->default(0);
            $table->timestamps();
        });

        $now = now();
        DB::table('plans')->insert([
            ['slug' => 'unlimited', 'name' => 'Ilimitado', 'description' => 'Sin límites. Para los primeros locales y casos especiales.',
                'price_monthly' => null, 'max_families' => null, 'max_cocktails' => null, 'max_images_per_cocktail' => null,
                'can_hide_branding' => true, 'is_public' => false, 'sort' => 0, 'created_at' => $now, 'updated_at' => $now],
            ['slug' => 'free', 'name' => 'Gratis', 'description' => 'Para probar Cocktail World con una carta pequeña.',
                'price_monthly' => 0, 'max_families' => 2, 'max_cocktails' => 15, 'max_images_per_cocktail' => 2,
                'can_hide_branding' => false, 'is_public' => true, 'sort' => 1, 'created_at' => $now, 'updated_at' => $now],
            ['slug' => 'basic', 'name' => 'Básico', 'description' => 'Para la carta completa de un bar.',
                'price_monthly' => null, 'max_families' => 10, 'max_cocktails' => 100, 'max_images_per_cocktail' => 5,
                'can_hide_branding' => false, 'is_public' => true, 'sort' => 2, 'created_at' => $now, 'updated_at' => $now],
            ['slug' => 'pro', 'name' => 'Pro', 'description' => 'Sin límites y sin la firma de Cocktail World.',
                'price_monthly' => null, 'max_families' => null, 'max_cocktails' => null, 'max_images_per_cocktail' => null,
                'can_hide_branding' => true, 'is_public' => true, 'sort' => 3, 'created_at' => $now, 'updated_at' => $now],
        ]);

        Schema::table('establishments', function (Blueprint $table) {
            $table->foreignId('plan_id')->nullable()->after('show_branding')->constrained('plans')->restrictOnDelete();
            $table->string('subscription_status', 20)->default('active')->after('plan_id');
            $table->timestamp('trial_ends_at')->nullable()->after('subscription_status');
            $table->timestamp('subscription_ends_at')->nullable()->after('trial_ends_at');
            $table->text('subscription_notes')->nullable()->after('subscription_ends_at');
        });

        $unlimited = DB::table('plans')->where('slug', 'unlimited')->value('id');
        DB::table('establishments')->update(['plan_id' => $unlimited, 'subscription_status' => 'active']);
    }

    public function down(): void
    {
        Schema::table('establishments', function (Blueprint $table) {
            $table->dropConstrainedForeignId('plan_id');
            $table->dropColumn(['subscription_status', 'trial_ends_at', 'subscription_ends_at', 'subscription_notes']);
        });
        Schema::dropIfExists('plans');
    }
};
