<?php

namespace App\Filament\Resources\Establishments;

use App\Filament\Resources\Establishments\Pages\EditEstablishment;
use App\Filament\Resources\Establishments\Pages\ListEstablishments;
use App\Filament\Resources\Establishments\RelationManagers\UsersRelationManager;
use App\Models\Establishment;
use App\Support\EstablishmentManager;
use App\Support\PlanLimits;
use Filament\Schemas\Components\Utilities\Get;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Actions\ActionGroup;
use Filament\Actions\EditAction;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
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
use Filament\Tables\Filters\SelectFilter;
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
        return parent::getEloquentQuery()->with('plan')->withCount(['families', 'cocktails']);
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
                    ->helperText('Aparece al final de su carta pública con enlaces al recetario y al alta de locales. '
                        .'Solo se oculta si su plan lo permite (p. ej. Pro).'),
                TextEntry::make('public_url')->label('Carta pública')
                    ->state(fn (Establishment $record) => self::publicUrl($record))
                    ->url(fn (Establishment $record) => self::publicUrl($record), shouldOpenInNewTab: true)
                    ->columnSpan(2),
            ]),
            // Preparado para cobrar más adelante (Stripe): de momento se gestiona a mano
            Section::make('Suscripción')->columns(3)->columnSpanFull()->schema([
                Select::make('plan_id')->label('Plan')->relationship('plan', 'name')
                    ->required()->preload()->native(false),
                Select::make('subscription_status')->label('Estado')->options(Establishment::STATUS_LABELS)
                    ->required()->native(false)->live(),
                TextEntry::make('usage')->label('Uso')
                    ->state(fn (?Establishment $record) => $record ? self::usageText($record) : null),
                DateTimePicker::make('trial_ends_at')->label('Fin de la prueba')->native(false)
                    ->visible(fn (Get $get) => $get('subscription_status') === Establishment::STATUS_TRIAL),
                DateTimePicker::make('subscription_ends_at')->label('Activa hasta')->native(false)
                    ->helperText('Si se cancela, mantiene su plan hasta esta fecha.')
                    ->visible(fn (Get $get) => $get('subscription_status') === Establishment::STATUS_CANCELED),
                TextEntry::make('effective_plan')->label('Límites que se aplican ahora')->columnSpanFull()
                    ->state(fn (?Establishment $record) => $record ? self::effectivePlanText($record) : null)
                    ->color(fn (?Establishment $record) => $record && ! $record->subscriptionIsCurrent() ? 'danger' : null),
                Textarea::make('subscription_notes')->label('Notas internas')->rows(2)->columnSpanFull()
                    ->placeholder('Ej.: precio especial, pago por transferencia...'),
            ]),
        ]);
    }

    /** "12/15 cócteles · 2/2 familias" (∞ si no hay límite). */
    public static function usageText(Establishment $establishment): string
    {
        $usage = PlanLimits::usage($establishment);
        $fmt = fn (array $u, string $what) => $u['used'].'/'.($u['max'] ?? '∞').' '.$what;

        return $fmt($usage['cocktails'], 'cócteles').' · '.$fmt($usage['families'], 'familias');
    }

    public static function effectivePlanText(Establishment $establishment): string
    {
        $plan = $establishment->effectivePlan()?->name ?? '—';

        return $establishment->subscriptionIsCurrent()
            ? "Los de su plan ($plan)."
            : "La suscripción no está al día: se aplican los límites del plan $plan. "
                .'No se borra nada, pero no podrá añadir más de lo que ese plan permite.';
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
                TextColumn::make('plan.name')->label('Plan')->badge()->color('gray'),
                TextColumn::make('subscription_status')->label('Suscripción')->badge()
                    ->formatStateUsing(fn (string $state) => Establishment::STATUS_LABELS[$state] ?? $state)
                    ->color(fn (string $state) => match ($state) {
                        Establishment::STATUS_ACTIVE => 'success',
                        Establishment::STATUS_TRIAL => 'info',
                        Establishment::STATUS_PAST_DUE => 'danger',
                        default => 'gray',
                    }),
                IconColumn::make('is_active')->label('Activo')->boolean()->alignCenter(),
            ])
            ->filters([
                TernaryFilter::make('is_active')->label('Estado')
                    ->trueLabel('Activos')->falseLabel('Suspendidos')->placeholder('Todos'),
                SelectFilter::make('plan_id')->label('Plan')->relationship('plan', 'name')->preload(),
                SelectFilter::make('subscription_status')->label('Suscripción')->options(Establishment::STATUS_LABELS),
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
