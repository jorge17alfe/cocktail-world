<?php

namespace App\Filament\Resources\LibraryCocktails\Pages;

use App\Filament\Resources\LibraryCocktails\LibraryCocktailResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListLibraryCocktails extends ListRecords
{
    protected static string $resource = LibraryCocktailResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make()->label('Nuevo cóctel'),
        ];
    }
}
