<?php

namespace App\Filament\Resources\LibraryCocktails;

use App\Filament\Resources\LibraryCocktails\Pages\CreateLibraryCocktail;
use App\Filament\Resources\LibraryCocktails\Pages\EditLibraryCocktail;
use App\Filament\Resources\LibraryCocktails\Pages\ListLibraryCocktails;
use App\Models\Cocktail;
use BackedEnum;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TagsInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Tabs;
use Filament\Schemas\Components\Tabs\Tab;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use UnitEnum;

/**
 * Cócteles de la biblioteca base (establishment_id = NULL): los que los locales
 * copian a sus cartas. Editarlos aquí NO cambia las copias que ya hicieron los locales.
 */
class LibraryCocktailResource extends Resource
{
    protected static ?string $model = Cocktail::class;

    protected static ?string $slug = 'biblioteca/cocteles';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedBeaker;

    protected static string|UnitEnum|null $navigationGroup = 'Biblioteca';

    protected static ?int $navigationSort = 1;

    protected static ?string $navigationLabel = 'Cócteles';

    protected static ?string $modelLabel = 'cóctel de la biblioteca';

    protected static ?string $pluralModelLabel = 'cócteles de la biblioteca';

    protected static ?string $recordTitleAttribute = 'name';

    /** Grupos habituales (la primera etiqueta de cada cóctel es su grupo en la app). */
    public const GROUPS = ['Clásicos', 'Internacionales', 'Modernos', 'Tropicales', 'Sin alcohol'];

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->whereNull('establishment_id');
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            Tabs::make()->columnSpanFull()->persistTabInQueryString()->tabs([
                Tab::make('Datos')->icon(Heroicon::OutlinedIdentification)->schema([
                    TextInput::make('name')->label('Nombre')->required()->maxLength(120),
                    TagsInput::make('tags')->label('Grupo y etiquetas')
                        ->suggestions([...self::GROUPS, 'Ginebra', 'Ron', 'Vodka', 'Tequila', 'Whisky', 'IBA'])
                        ->helperText('La primera etiqueta es el grupo con el que se filtra en la app (p. ej. "Clásicos"). Después: licor base, "IBA"...')
                        ->required(),
                    Grid::make(2)->schema([
                        TextInput::make('glass')->label('Copa / vaso')->maxLength(120)
                            ->datalist(['Copa de cóctel', 'Copa martini', 'Copa margarita', 'Copa de vino', 'Vaso old fashioned', 'Vaso highball', 'Vaso hurricane', 'Taza de cobre']),
                        Select::make('technique')->label('Técnica')->options(Cocktail::TECHNIQUE_LABELS)->native(false),
                        TextInput::make('ice')->label('Hielo')->maxLength(120)
                            ->datalist(['Cubos', 'Hielo picado', 'Bloque grande', 'Sin hielo en copa']),
                        TextInput::make('garnish')->label('Decoración')->maxLength(255),
                    ]),
                ]),

                Tab::make('Ingredientes')->icon(Heroicon::OutlinedListBullet)->schema([
                    Repeater::make('ingredients')->hiddenLabel()
                        ->relationship()
                        ->orderColumn('order')
                        ->schema([
                            TextInput::make('name')->label('Ingrediente')->required()->maxLength(120)->columnSpan(3),
                            TextInput::make('amount')->label('Cantidad')->numeric()->minValue(0),
                            TextInput::make('unit')->label('Unidad')->maxLength(20)
                                ->datalist(['ml', 'cl', 'oz', 'golpes', 'gotas', 'hojas', 'unidad', 'cucharaditas', 'chorrito']),
                            TextInput::make('note')->label('Nota')->maxLength(120)->placeholder('opcional')->columnSpan(2),
                        ])
                        ->columns(7)
                        ->itemLabel(fn (array $state) => trim(($state['amount'] ?? '').' '.($state['unit'] ?? '').' '.($state['name'] ?? '')) ?: null)
                        ->collapsible()
                        ->addActionLabel('Añadir ingrediente')
                        ->defaultItems(0),
                ]),

                Tab::make('Elaboración')->icon(Heroicon::OutlinedNumberedList)->schema([
                    Repeater::make('steps')->hiddenLabel()
                        ->simple(Textarea::make('step')->rows(2)->required()->maxLength(1000))
                        ->reorderable()
                        ->addActionLabel('Añadir paso')
                        ->defaultItems(0),
                ]),

                Tab::make('Historia')->icon(Heroicon::OutlinedBookOpen)->schema([
                    Textarea::make('history')->hiddenLabel()->rows(10)->maxLength(10000)
                        ->placeholder('Origen, anécdotas, quién lo creó...'),
                ]),

                Tab::make('Utensilios')->icon(Heroicon::OutlinedWrenchScrewdriver)->schema([
                    Select::make('utensils')->label('Utensilios que se usan')
                        ->relationship('utensils', 'name', fn (Builder $query) => $query->whereNull('establishment_id'))
                        ->multiple()->preload()->searchable()
                        ->helperText('Solo utensilios de la biblioteca. Se crean en Biblioteca → Utensilios.'),
                ]),

                Tab::make('Fotos')->icon(Heroicon::OutlinedPhoto)->schema([
                    Repeater::make('images')->hiddenLabel()
                        ->relationship()
                        ->orderColumn('order')
                        ->schema([
                            FileUpload::make('path')->hiddenLabel()
                                ->image()
                                ->disk('public')->directory('library/cocktails')->visibility('public')
                                ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/webp'])
                                ->maxSize(5120)
                                ->imageEditor()
                                ->required(),
                        ])
                        ->grid(3)
                        ->maxItems(10)
                        ->addActionLabel('Añadir foto')
                        ->helperText('Arrastra para ordenar: la primera es la portada. Máximo 10 fotos de 5 MB.')
                        ->defaultItems(0),
                ]),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('name')
            ->defaultSort('name')
            ->columns([
                ImageColumn::make('images.path')->label('Fotos')
                    ->disk('public')->circular()->stacked()->limit(3),
                TextColumn::make('name')->label('Nombre')->searchable()->sortable()->weight('bold'),
                TextColumn::make('tags')->label('Grupo y etiquetas')->badge()
                    ->separator(',')->limitList(3),
                TextColumn::make('technique')->label('Técnica')
                    ->formatStateUsing(fn (?string $state) => Cocktail::TECHNIQUE_LABELS[$state] ?? $state)
                    ->toggleable(),
                TextColumn::make('ingredients_count')->label('Ingredientes')->counts('ingredients')
                    ->alignCenter()->toggleable(),
                TextColumn::make('copies_count')->label('Copiado por')->counts('copies')
                    ->suffix(' locales')->alignCenter()->sortable(),
                TextColumn::make('updated_at')->label('Modificado')->since()->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('group')->label('Grupo')
                    ->options(array_combine(self::GROUPS, self::GROUPS))
                    ->query(fn (Builder $query, array $data) => filled($data['value'])
                        ? $query->whereJsonContains('tags', $data['value'])
                        : $query),
                SelectFilter::make('technique')->label('Técnica')->options(Cocktail::TECHNIQUE_LABELS),
            ])
            ->recordActions([
                EditAction::make(),
                DeleteAction::make()
                    ->modalDescription('Se borra de la biblioteca con sus fotos. Las copias que ya tengan los locales NO se borran.'),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make()
                        ->modalDescription('Las copias que ya tengan los locales NO se borran.'),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListLibraryCocktails::route('/'),
            'create' => CreateLibraryCocktail::route('/create'),
            'edit' => EditLibraryCocktail::route('/{record}/edit'),
        ];
    }
}
