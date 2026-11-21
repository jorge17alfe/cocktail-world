<?php

namespace App\Filament\Resources\Establishments\RelationManagers;

use App\Models\User;
use App\Support\EstablishmentManager;
use Filament\Actions\Action;
use Filament\Actions\ActionGroup;
use Filament\Actions\EditAction;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

/** Administradores del local. */
class UsersRelationManager extends RelationManager
{
    protected static string $relationship = 'users';

    protected static ?string $title = 'Administradores';

    protected static ?string $modelLabel = 'administrador';

    public function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('name')->label('Nombre')->required()->maxLength(120),
            TextInput::make('email')->label('Email')->email()->required()->maxLength(255)
                ->unique('users', 'email', ignoreRecord: true),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('email')
            ->columns([
                TextColumn::make('name')->label('Nombre')->weight('bold'),
                TextColumn::make('email')->label('Email')->copyable(),
                TextColumn::make('last_login_at')->label('Último acceso')->since()->placeholder('Nunca'),
                TextColumn::make('created_at')->label('Alta')->date('d/m/Y'),
                IconColumn::make('is_active')->label('Activo')->boolean()->alignCenter(),
            ])
            ->recordActions([
                EditAction::make(),
                ActionGroup::make([
                    Action::make('temporary_password')->label('Contraseña temporal')->icon(Heroicon::OutlinedKey)
                        ->requiresConfirmation()
                        ->modalHeading(fn (User $record) => "Nueva contraseña para {$record->email}")
                        ->modalDescription('Se genera una contraseña temporal y se cierran sus sesiones abiertas. Te la mostraremos una sola vez para que se la pases.')
                        ->modalSubmitActionLabel('Generar')
                        ->action(function (User $record) {
                            $password = app(EstablishmentManager::class)->resetPassword($record);
                            Notification::make()
                                ->title('Contraseña temporal generada')
                                ->body('Email: <strong>'.e($record->email).'</strong><br>'
                                    .'Contraseña: <strong>'.e($password).'</strong><br><br>'
                                    .'Cópiala ahora: no se vuelve a mostrar. Podrá cambiarla desde la app.')
                                ->success()->persistent()->send();
                        }),
                    Action::make('deactivate')->label('Desactivar')->icon(Heroicon::OutlinedNoSymbol)->color('danger')
                        ->visible(fn (User $record) => $record->is_active !== false)
                        ->requiresConfirmation()
                        ->modalDescription('No podrá entrar en la app y se cierran sus sesiones. El local sigue funcionando.')
                        ->action(fn (User $record) => app(EstablishmentManager::class)->setUserActive($record, false)),
                    Action::make('activate')->label('Activar')->icon(Heroicon::OutlinedCheckCircle)->color('success')
                        ->visible(fn (User $record) => $record->is_active === false)
                        ->action(fn (User $record) => app(EstablishmentManager::class)->setUserActive($record, true)),
                ]),
            ]);
    }
}
