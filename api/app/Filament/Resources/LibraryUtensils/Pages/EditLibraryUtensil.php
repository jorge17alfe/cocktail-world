<?php

namespace App\Filament\Resources\LibraryUtensils\Pages;

use App\Filament\Resources\LibraryUtensils\LibraryUtensilResource;
use App\Models\Utensil;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditLibraryUtensil extends EditRecord
{
    protected static string $resource = LibraryUtensilResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make()
                ->modalDescription(fn (Utensil $record) => LibraryUtensilResource::deleteWarning($record)),
        ];
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
