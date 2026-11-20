<?php

namespace App\Filament\Resources\LibraryCocktails\Pages;

use App\Filament\Resources\LibraryCocktails\LibraryCocktailResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditLibraryCocktail extends EditRecord
{
    protected static string $resource = LibraryCocktailResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make()
                ->modalDescription('Se borra de la biblioteca con sus fotos. Las copias que ya tengan los locales NO se borran.'),
        ];
    }
}
