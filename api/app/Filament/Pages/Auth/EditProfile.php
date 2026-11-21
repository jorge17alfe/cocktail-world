<?php

namespace App\Filament\Pages\Auth;

use App\Models\Plan;
use App\Models\Setting;
use Filament\Auth\Pages\EditProfile as BaseEditProfile;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use SensitiveParameter;

/**
 * Perfil del superadmin + ajustes de la plataforma (email de soporte...).
 * Los ajustes no son columnas del usuario: se leen y guardan en la tabla "settings".
 */
class EditProfile extends BaseEditProfile
{
    public function form(Schema $schema): Schema
    {
        return $schema->components([
            $this->getNameFormComponent(),
            $this->getEmailFormComponent(),
            $this->getPasswordFormComponent(),
            $this->getPasswordConfirmationFormComponent(),
            $this->getCurrentPasswordFormComponent(),
            Section::make('Plataforma')
                ->description('Ajustes que ven los locales en la app.')
                ->schema([
                    TextInput::make(Setting::SUPPORT_EMAIL)
                        ->label('Email de soporte')
                        ->helperText('Se usa en "¿Echas de menos un cóctel?" de la biblioteca.')
                        ->email()->required()->maxLength(255),
                    Select::make(Setting::DEFAULT_PLAN)
                        ->label('Plan para los locales nuevos')
                        ->options(fn () => Plan::orderBy('sort')->pluck('name', 'slug'))
                        ->required()->native(false),
                    Select::make(Setting::FALLBACK_PLAN)
                        ->label('Plan si la suscripción no está al día')
                        ->helperText('Pago pendiente, prueba terminada o cancelada. No se borra nada: solo no podrán añadir más de lo que permita este plan.')
                        ->options(fn () => Plan::orderBy('sort')->pluck('name', 'slug'))
                        ->required()->native(false),
                ]),
        ]);
    }

    protected function mutateFormDataBeforeFill(array $data): array
    {
        $data[Setting::SUPPORT_EMAIL] = Setting::supportEmail();
        $data[Setting::DEFAULT_PLAN] = Setting::get(Setting::DEFAULT_PLAN, Plan::UNLIMITED);
        $data[Setting::FALLBACK_PLAN] = Setting::get(Setting::FALLBACK_PLAN, Plan::FREE);

        return $data;
    }

    protected function mutateFormDataBeforeSave(#[SensitiveParameter] array $data): array
    {
        foreach ([Setting::SUPPORT_EMAIL, Setting::DEFAULT_PLAN, Setting::FALLBACK_PLAN] as $key) {
            Setting::put($key, $data[$key]);
            unset($data[$key]);
        }

        return $data;
    }
}
