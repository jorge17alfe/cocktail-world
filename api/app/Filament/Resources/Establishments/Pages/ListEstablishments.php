<?php

namespace App\Filament\Resources\Establishments\Pages;

use App\Filament\Resources\Establishments\EstablishmentResource;
use App\Support\EstablishmentManager;
use Filament\Actions\Action;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ListRecords;
use Filament\Support\Icons\Heroicon;

class ListEstablishments extends ListRecords
{
    protected static string $resource = EstablishmentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            // Alta de un local por Alocraise (p. ej. para un cliente): crea local + administrador
            Action::make('create_establishment')->label('Dar de alta un local')->icon(Heroicon::OutlinedPlus)
                ->modalHeading('Dar de alta un local')
                ->modalDescription('Se crea el local con su número y un administrador con contraseña temporal. Pásale los datos: podrá cambiar la contraseña desde la app.')
                ->modalSubmitActionLabel('Crear local')
                ->schema([
                    TextInput::make('name')->label('Nombre del local')->required()->maxLength(120),
                    TextInput::make('admin_name')->label('Nombre del administrador')->required()->maxLength(120),
                    TextInput::make('admin_email')->label('Email del administrador')->email()->required()
                        ->maxLength(255)->unique('users', 'email'),
                ])
                ->action(function (array $data) {
                    $result = app(EstablishmentManager::class)
                        ->createWithAdmin($data['name'], $data['admin_name'], $data['admin_email']);

                    Notification::make()
                        ->title("Local «{$result['establishment']->name}» creado")
                        ->body('Nº de establecimiento: <strong>'.e($result['establishment']->code).'</strong><br>'
                            .'Email: <strong>'.e($result['admin']->email).'</strong><br>'
                            .'Contraseña temporal: <strong>'.e($result['password']).'</strong><br><br>'
                            .'Cópialos ahora: la contraseña no se vuelve a mostrar.')
                        ->success()
                        ->persistent()
                        ->send();
                }),
        ];
    }
}
