<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Familias: "Clásicos", "Internacionales", "De la casa"...
        Schema::create('families', function (Blueprint $table) {
            $table->id();
            $table->foreignId('establishment_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('image')->nullable();
            $table->unsignedInteger('order')->default(0);
            $table->timestamps();
        });

        // Catálogo de utensilios. establishment_id NULL = utensilio global (biblioteca).
        Schema::create('utensils', function (Blueprint $table) {
            $table->id();
            $table->foreignId('establishment_id')->nullable()->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('image')->nullable();
            $table->timestamps();
        });

        // Cócteles. establishment_id NULL = cóctel de la biblioteca base.
        Schema::create('cocktails', function (Blueprint $table) {
            $table->id();
            $table->foreignId('establishment_id')->nullable()->constrained()->cascadeOnDelete();
            $table->foreignId('family_id')->nullable()->constrained()->cascadeOnDelete();
            $table->foreignId('source_cocktail_id')->nullable()->constrained('cocktails')->nullOnDelete();
            $table->string('name');
            $table->string('glass')->nullable();      // copa / vaso
            $table->string('technique')->nullable();  // shake, stir, build, blend, muddle...
            $table->string('ice')->nullable();
            $table->string('garnish')->nullable();
            $table->text('history')->nullable();
            $table->json('steps')->nullable();        // elaboración paso a paso
            $table->json('tags')->nullable();
            $table->decimal('price', 8, 2)->nullable();
            $table->boolean('is_published')->default(true);
            $table->unsignedInteger('order')->default(0);
            $table->timestamps();
        });

        Schema::create('ingredients', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cocktail_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->decimal('amount', 8, 2)->nullable();
            $table->string('unit', 20)->nullable();   // ml, cl, oz, golpes, hojas...
            $table->string('note')->nullable();       // "recién exprimido", "opcional"...
            $table->unsignedInteger('order')->default(0);
            $table->timestamps();
        });

        Schema::create('cocktail_images', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cocktail_id')->constrained()->cascadeOnDelete();
            $table->string('path');
            $table->unsignedInteger('order')->default(0);
            $table->timestamps();
        });

        Schema::create('cocktail_utensil', function (Blueprint $table) {
            $table->foreignId('cocktail_id')->constrained()->cascadeOnDelete();
            $table->foreignId('utensil_id')->constrained()->cascadeOnDelete();
            $table->primary(['cocktail_id', 'utensil_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cocktail_utensil');
        Schema::dropIfExists('cocktail_images');
        Schema::dropIfExists('ingredients');
        Schema::dropIfExists('cocktails');
        Schema::dropIfExists('utensils');
        Schema::dropIfExists('families');
    }
};
