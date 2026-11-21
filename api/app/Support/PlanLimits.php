<?php

namespace App\Support;

use App\Http\Controllers\Api\V1\Admin\CocktailImageController;
use App\Models\Cocktail;
use App\Models\Establishment;

/**
 * Único sitio donde se comprueban los límites del plan de un local.
 * Los controladores de la API llaman a estos métodos antes de crear familias, cócteles o fotos.
 */
class PlanLimits
{
    /** Uso actual frente a los límites del plan (null = sin límite). */
    public static function usage(Establishment $establishment): array
    {
        $plan = $establishment->effectivePlan();

        return [
            'families' => ['used' => $establishment->families()->count(), 'max' => $plan?->max_families],
            'cocktails' => ['used' => $establishment->cocktails()->count(), 'max' => $plan?->max_cocktails],
            'images_per_cocktail' => ['max' => self::maxImagesPerCocktail($establishment)],
        ];
    }

    public static function ensureCanAddFamilies(Establishment $establishment, int $count = 1): void
    {
        $max = $establishment->effectivePlan()?->max_families;
        if ($max !== null && $establishment->families()->count() + $count > $max) {
            throw new PlanLimitExceeded(self::message($establishment, "$max ".($max === 1 ? 'familia' : 'familias')));
        }
    }

    public static function ensureCanAddCocktails(Establishment $establishment, int $count = 1): void
    {
        $max = $establishment->effectivePlan()?->max_cocktails;
        if ($max !== null && $establishment->cocktails()->count() + $count > $max) {
            throw new PlanLimitExceeded(self::message($establishment, "$max ".($max === 1 ? 'cóctel' : 'cócteles')));
        }
    }

    /** Solo el límite del plan; el máximo técnico (10) lo sigue comprobando CocktailImageController. */
    public static function ensureCanAddImages(Cocktail $cocktail, int $count = 1): void
    {
        $max = $cocktail->establishment->effectivePlan()?->max_images_per_cocktail;
        if ($max !== null && $cocktail->images()->count() + $count > $max) {
            throw new PlanLimitExceeded(self::message($cocktail->establishment, "$max ".($max === 1 ? 'foto' : 'fotos').' por cóctel'));
        }
    }

    /** Límite del plan, sin pasar nunca del máximo técnico de la app. */
    public static function maxImagesPerCocktail(Establishment $establishment): int
    {
        $max = $establishment->effectivePlan()?->max_images_per_cocktail;

        return min($max ?? CocktailImageController::MAX_IMAGES, CocktailImageController::MAX_IMAGES);
    }

    private static function message(Establishment $establishment, string $limit): string
    {
        $plan = $establishment->effectivePlan()?->name ?? 'actual';

        return "Tu plan $plan permite $limit. Escríbenos si necesitas más.";
    }
}
