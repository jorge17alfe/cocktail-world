<?php

namespace App\Filament\Resources\Establishments\Pages;

use App\Filament\Resources\Establishments\EstablishmentResource;
use App\Models\Establishment;
use Filament\Actions\Action;
use Filament\Resources\Pages\EditRecord;
use Filament\Support\Icons\Heroicon;

class EditEstablishment extends EditRecord
{
    protected static string $resource = EstablishmentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('open_carta')->label('Ver carta')->icon(Heroicon::OutlinedArrowTopRightOnSquare)
                ->color('gray')
                ->url(fn (Establishment $record) => EstablishmentResource::publicUrl($record), shouldOpenInNewTab: true),
            EstablishmentResource::suspendAction()->after(fn () => $this->refreshFormData(['is_active'])),
            EstablishmentResource::reactivateAction()->after(fn () => $this->refreshFormData(['is_active'])),
        ];
    }
}
