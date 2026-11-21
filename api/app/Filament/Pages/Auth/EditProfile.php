<?php

namespace App\Filament\Pages\Auth;

use App\Models\Setting;
use Filament\Auth\Pages\EditProfile as BaseEditProfile;
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
                ]),
        ]);
    }

    protected function mutateFormDataBeforeFill(array $data): array
    {
        $data[Setting::SUPPORT_EMAIL] = Setting::supportEmail();

        return $data;
    }

    protected function mutateFormDataBeforeSave(#[SensitiveParameter] array $data): array
    {
        Setting::put(Setting::SUPPORT_EMAIL, $data[Setting::SUPPORT_EMAIL]);
        unset($data[Setting::SUPPORT_EMAIL]);

        return $data;
    }
}
