<?php

namespace App\Filament\Resources\Establishments;

use App\Filament\Resources\Establishments\Pages\EditEstablishment;
use App\Filament\Resources\Establishments\Pages\ListEstablishments;
use App\Filament\Resources\Establishments\RelationManagers\UsersRelationManager;
use App\Models\Establishment;
use App\Support\EstablishmentManager;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Actions\ActionGroup;
use Filament\Actions\EditAction;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Infolists\Components\TextEntry;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\Filter;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use UnitEnum;

/** Locales dados de alta en la plataforma. */
class EstablishmentResource extends Resource
{
    protected static ?string $model = Establishment::class;

    protected static ?string $slug = 'establecimientos';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedBuildingStorefront;

    protected static string|UnitEnum|null $navigationGroup = 'Plataforma';

    protected static ?int $navigationSort = 1;

    protected static ?string $navigationLabel = 'Establecimientos';

    protected static ?string $modelLabel = 'establecimiento';

    protected static ?string $pluralModelLabel = 'establecimientos';

    protected static ?string $recordTitleAttribute = 'name';

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->withCount(['families', 'cocktails']);
    }

    /** Carta pública del local: siempre en el dominio de la app (APP_URL), no en el del panel. */
    public static function publicUrl(Establishment $establishment): string
    {
        return rtrim(config('app.url'), '/').'/carta/'.$establishment->code;
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            Section::make('Local')->columns(3)->columnSpanFull()->schema([
                TextInput::make('name')->label('Nombre')->required()->maxLength(120)->columnSpan(2),
                TextEntry::make('code')->label('Nº de establecimiento')->copyable()->weight('bold'),
                TextEntry::make('is_active')->label('Estado')->badge()
                    ->formatStateUsing(fn (bool $state) => $state ? 'Activo' : 'Suspendido')
                    ->color(fn (bool $state) => $state ? 'success' : 'danger'),
                TextEntry::make('families_count')->label('Familias'),
                TextEntry::make('cocktails_count')->label('Cócteles'),
                TextEntry::make('created_at')->label('Alta')->dateTime('d/m/Y H:i'),
                Toggle::make('show_branding')->label('Firma "Carta creada con Cocktail World"')
                    ->helperText('Aparece al final de su carta pública con enlaces al recetario y al alta de locales.'),
                TextEntry::make('public_url')->label('Carta pública')
                    ->state(fn (Establishment $record) => self::publicUrl($record))
                    ->url(fn (Establishment $record) => self::publicUrl($record), shouldOpenInNewTab: true)
                    ->columnSpan(2),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('name')
            ->defaultSort('created_at', 'desc')
            ->columns([
                TextColumn::make('name')->label('Local')->searchable()->sortable()->weight('bold'),
                TextColumn::make('code')->label('Número')->searchable()->copyable()->fontFamily('mono'),
                TextColumn::make('users.email')->label('Administrador')->searchable()
                    ->listWithLineBreaks()->limitList(2),
                TextColumn::make('families_count')->label('Familias')->alignCenter()->sortable(),
                TextColumn::make('cocktails_count')->label('Cócteles')->alignCenter()->sortable(),
                TextColumn::make('users_max_last_login_at')->label('Último acceso')
                    ->max('users', 'last_login_at')->since()->sortable()->placeholder('Nunca'),
                TextColumn::make('created_at')->label('Alta')->date('d/m/Y')->sortable(),
                IconColumn::make('is_active')->label('Activo')->boolean()->alignCenter(),
            ])
            ->filters([
                TernaryFilter::make('is_active')->label('Estado')
                    ->trueLabel('Activos')->falseLabel('Suspendidos')->placeholder('Todos'),
                Filter::make('new_this_month')->label('Altas este mes')
                    ->query(fn (Builder $query) => $query->where('created_at', '>=', now()->startOfMonth())),
                Filter::make('inactive_30_days')->label('Sin acceso en 30 días')
                    ->query(fn (Builder $query) => $query->whereDoesntHave('users',
                        fn (Builder $users) => $users->where('last_login_at', '>=', now()->subDays(30)))),
            ])
            ->recordActions([
                EditAction::make()->label('Ficha'),
                ActionGroup::make([
                    Action::make('open_carta')->label('Ver carta')->icon(Heroicon::OutlinedArrowTopRightOnSquare)
                        ->url(fn (Establishment $record) => self::publicUrl($record), shouldOpenInNewTab: true),
                    self::suspendAction(),
                    self::reactivateAction(),
                ]),
            ]);
    }

    public static function suspendAction(): Action
    {
        return Action::make('suspend')->label('Suspender')->icon(Heroicon::OutlinedNoSymbol)->color('danger')
            ->visible(fn (Establishment $record) => $record->is_active)
            ->requiresConfirmation()
            ->modalHeading(fn (Establishment $record) => "Suspender «{$record->name}»")
            ->modalDescription('Sus administradores no podrán entrar en la app y su carta pública dejará de verse. Se cierran sus sesiones abiertas. Se puede reactivar en cualquier momento; no se borra nada.')
            ->modalSubmitActionLabel('Suspender')
            ->action(function (Establishment $record) {
                app(EstablishmentManager::class)->suspend($record);
                Notification::make()->title('Local suspendido')->success()->send();
            });
    }

    public static function reactivateAction(): Action
    {
        return Action::make('reactivate')->label('Reactivar')->icon(Heroicon::OutlinedCheckCircle)->color('success')
            ->visible(fn (Establishment $record) => ! $record->is_active)
            ->requiresConfirmation()
            ->modalHeading(fn (Establishment $record) => "Reactivar «{$record->name}»")
            ->modalSubmitActionLabel('Reactivar')
            ->action(function (Establishment $record) {
                app(EstablishmentManager::class)->reactivate($record);
                Notification::make()->title('Local reactivado')->success()->send();
            });
    }

    public static function getRelations(): array
    {
        return [
            UsersRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListEstablishments::route('/'),
            'edit' => EditEstablishment::route('/{record}/edit'),
        ];
    }
}
