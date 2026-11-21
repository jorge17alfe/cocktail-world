<?php

namespace App\Providers\Filament;

use App\Filament\Pages\Auth\EditProfile;
use App\Filament\Widgets\PlatformStats;
use Filament\Auth\MultiFactor\App\AppAuthentication;
use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\AuthenticateSession;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Pages\Dashboard;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\Widgets\AccountWidget;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;

/**
 * Panel de gestión de Alocraise (superadmin): biblioteca, establecimientos, ajustes, planes...
 * Solo entran usuarios con rol "superadmin" (ver User::canAccessPanel) y con 2FA obligatorio.
 */
class GestionPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        $domain = config('cocktail.admin_panel_domain');

        $panel = $panel
            ->default()
            ->id('gestion')
            ->brandName('Cocktail World · Gestión')
            ->brandLogo(asset('images/logo.png'))
            ->brandLogoHeight('2.5rem')
            ->favicon(asset('images/logo.png'))
            ->colors([
                'primary' => Color::hex('#B5542D'), // mismo terracota que la app
            ])
            ->login()
            ->profile(EditProfile::class)
            // Verificación en dos pasos con app de autenticación (Google Authenticator, Authy...)
            ->multiFactorAuthentication([
                AppAuthentication::make()
                    ->brandName('Cocktail World')
                    ->recoverable(),
            ], isRequired: true)
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\Filament\Resources')
            ->discoverPages(in: app_path('Filament/Pages'), for: 'App\Filament\Pages')
            ->pages([
                Dashboard::class,
            ])
            ->widgets([
                AccountWidget::class,
                PlatformStats::class,
            ])
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                VerifyCsrfToken::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ]);

        // En el servidor: solo en su subdominio. En local: http://127.0.0.1:8000/gestion
        return $domain
            ? $panel->domain($domain)->path('')
            : $panel->path('gestion');
    }
}
