<?php

namespace App\Filament\Resources\LibraryUtensils\Pages;

use App\Filament\Resources\LibraryUtensils\LibraryUtensilResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListLibraryUtensils extends ListRecords
{
    protected static string $resource = LibraryUtensilResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make()->label('Nuevo utensilio'),
        ];
    }
}
