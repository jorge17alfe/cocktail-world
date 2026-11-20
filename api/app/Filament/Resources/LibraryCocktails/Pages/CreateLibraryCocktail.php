<?php

namespace App\Filament\Resources\LibraryCocktails\Pages;

use App\Filament\Resources\LibraryCocktails\LibraryCocktailResource;
use Filament\Resources\Pages\CreateRecord;

class CreateLibraryCocktail extends CreateRecord
{
    protected static string $resource = LibraryCocktailResource::class;

    /** Los cócteles de la biblioteca no pertenecen a ningún local ni familia. */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        return [...$data, 'family_id' => null];
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('edit', ['record' => $this->getRecord()]);
    }
}
