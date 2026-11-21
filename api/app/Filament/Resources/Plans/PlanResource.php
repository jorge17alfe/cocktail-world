<?php

namespace App\Filament\Resources\Plans;

use App\Filament\Resources\Plans\Pages\CreatePlan;
use App\Filament\Resources\Plans\Pages\EditPlan;
use App\Filament\Resources\Plans\Pages\ListPlans;
use App\Models\Plan;
use BackedEnum;
use Filament\Actions\EditAction;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use UnitEnum;

/**
 * Planes de suscripción (Gratis, Básico, Pro...). Los límites vacíos significan "sin límite".
 * Los cambios se aplican al momento a todos los locales de ese plan.
 */
class PlanResource extends Resource
{
    protected static ?string $model = Plan::class;

    protected static ?string $slug = 'planes';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedCreditCard;

    protected static string|UnitEnum|null $navigationGroup = 'Plataforma';

    protected static ?int $navigationSort = 2;

    protected static ?string $navigationLabel = 'Planes';

    protected static ?string $modelLabel = 'plan';

    protected static ?string $pluralModelLabel = 'planes';

    protected static ?string $recordTitleAttribute = 'name';

    public static function form(Schema $schema): Schema
    {
        $limit = fn (string $name, string $label) => TextInput::make($name)->label($label)
            ->numeric()->integer()->minValue(0)->placeholder('Sin límite');

        return $schema->components([
            Section::make('Plan')->columns(2)->columnSpanFull()->schema([
                TextInput::make('name')->label('Nombre')->required()->maxLength(60),
                TextInput::make('slug')->label('Identificador')->required()->maxLength(40)
                    ->alphaDash()->unique(ignoreRecord: true)
                    ->helperText('Interno, sin espacios (p. ej. "basic"). No lo cambies si ya hay locales con este plan.'),
                TextInput::make('description')->label('Descripción')->maxLength(255)->columnSpanFull(),
                TextInput::make('price_monthly')->label('Precio al mes')->numeric()->minValue(0)
                    ->suffix('€')->placeholder('Sin definir'),
                TextInput::make('sort')->label('Orden')->numeric()->integer()->default(0),
            ]),
            Section::make('Límites')->description('Déjalo vacío para "sin límite".')->columns(3)->columnSpanFull()->schema([
                $limit('max_families', 'Familias'),
                $limit('max_cocktails', 'Cócteles'),
                $limit('max_images_per_cocktail', 'Fotos por cóctel')->maxValue(10)
                    ->helperText('Máximo técnico: 10.'),
                Toggle::make('can_hide_branding')->label('Puede quitar la firma "Carta creada con Cocktail World"')
                    ->columnSpanFull(),
                Toggle::make('is_public')->label('Se ofrece a los locales')
                    ->helperText('Desactívalo para planes especiales, como "Ilimitado".')->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        $limit = fn (string $name, string $label) => TextColumn::make($name)->label($label)
            ->alignCenter()->placeholder('∞');

        return $table
            ->defaultSort('sort')
            ->reorderable('sort')
            ->columns([
                TextColumn::make('name')->label('Plan')->weight('bold')->description(fn (Plan $record) => $record->description),
                TextColumn::make('price_monthly')->label('Precio/mes')->money('EUR')->placeholder('Sin definir'),
                $limit('max_families', 'Familias'),
                $limit('max_cocktails', 'Cócteles'),
                $limit('max_images_per_cocktail', 'Fotos/cóctel'),
                IconColumn::make('can_hide_branding')->label('Sin firma')->boolean()->alignCenter(),
                IconColumn::make('is_public')->label('Se ofrece')->boolean()->alignCenter(),
                TextColumn::make('establishments_count')->label('Locales')->counts('establishments')->alignCenter(),
            ])
            ->recordActions([EditAction::make()]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListPlans::route('/'),
            'create' => CreatePlan::route('/create'),
            'edit' => EditPlan::route('/{record}/edit'),
        ];
    }
}
