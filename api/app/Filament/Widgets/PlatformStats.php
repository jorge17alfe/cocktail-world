<?php

namespace App\Filament\Widgets;

use App\Models\Cocktail;
use App\Models\Establishment;
use App\Models\User;
use App\Models\Utensil;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

/** Resumen de la plataforma en la página de inicio del panel. */
class PlatformStats extends StatsOverviewWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        $monthStart = now()->startOfMonth();
        $localCocktails = Cocktail::whereNotNull('establishment_id');

        return [
            Stat::make('Locales activos', Establishment::where('is_active', true)->count())
                ->description(Establishment::count().' dados de alta')
                ->icon('heroicon-o-building-storefront'),
            Stat::make('Altas este mes', Establishment::where('created_at', '>=', $monthStart)->count())
                ->description('locales nuevos')
                ->icon('heroicon-o-sparkles'),
            Stat::make('En uso (30 días)', Establishment::whereHas('users',
                fn ($q) => $q->where('last_login_at', '>=', now()->subDays(30)))->count())
                ->description('locales con acceso reciente')
                ->icon('heroicon-o-arrow-trending-up'),
            Stat::make('Cócteles publicados', (clone $localCocktails)->where('is_published', true)->count())
                ->description('de '.(clone $localCocktails)->count().' creados por los locales')
                ->icon('heroicon-o-beaker'),
            Stat::make('Cócteles este mes', (clone $localCocktails)->where('created_at', '>=', $monthStart)->count())
                ->description('nuevos en las cartas')
                ->icon('heroicon-o-plus-circle'),
            Stat::make('Biblioteca', Cocktail::library()->count().' cócteles')
                ->description(Utensil::whereNull('establishment_id')->count().' utensilios · '
                    .User::where('role', User::ROLE_ADMIN)->count().' administradores de locales')
                ->icon('heroicon-o-book-open'),
        ];
    }
}
