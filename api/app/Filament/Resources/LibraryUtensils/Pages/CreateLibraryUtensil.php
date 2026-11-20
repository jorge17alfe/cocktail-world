<?php

namespace App\Filament\Resources\LibraryUtensils\Pages;

use App\Filament\Resources\LibraryUtensils\LibraryUtensilResource;
use Filament\Resources\Pages\CreateRecord;

class CreateLibraryUtensil extends CreateRecord
{
    protected static string $resource = LibraryUtensilResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
