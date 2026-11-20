<?php

namespace App\Filament\Resources\LibraryUtensils;

use App\Filament\Resources\LibraryUtensils\Pages\CreateLibraryUtensil;
use App\Filament\Resources\LibraryUtensils\Pages\EditLibraryUtensil;
use App\Filament\Resources\LibraryUtensils\Pages\ListLibraryUtensils;
use App\Models\Utensil;
use BackedEnum;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use UnitEnum;

/**
 * Utensilios de la biblioteca (establishment_id = NULL), comunes a todos los locales.
 * Su foto la ven todos los locales que no lo hayan "personalizado".
 */
class LibraryUtensilResource extends Resource
{
    protected static ?string $model = Utensil::class;

    protected static ?string $slug = 'biblioteca/utensilios';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedWrenchScrewdriver;

    protected static string|UnitEnum|null $navigationGroup = 'Biblioteca';

    protected static ?int $navigationSort = 2;

    protected static ?string $navigationLabel = 'Utensilios';

    protected static ?string $modelLabel = 'utensilio de la biblioteca';

    protected static ?string $pluralModelLabel = 'utensilios de la biblioteca';

    protected static ?string $recordTitleAttribute = 'name';

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->whereNull('establishment_id');
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            Section::make()->columns(2)->columnSpanFull()->schema([
                TextInput::make('name')->label('Nombre')->required()->maxLength(120),
                Textarea::make('description')->label('Descripción')->rows(3)->maxLength(2000),
                FileUpload::make('image')->label('Foto')
                    ->image()
                    ->disk('public')->directory('library/utensils')->visibility('public')
                    ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/webp'])
                    ->maxSize(5120)
                    ->imageEditor()
                    ->helperText('La verán todos los locales que no hayan personalizado este utensilio.')
                    ->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('name')
            ->defaultSort('name')
            ->columns([
                ImageColumn::make('image')->label('Foto')->disk('public')->square(),
                TextColumn::make('name')->label('Nombre')->searchable()->sortable()->weight('bold'),
                TextColumn::make('description')->label('Descripción')->limit(60)->toggleable(),
                TextColumn::make('cocktails_count')->label('En cócteles')->counts('cocktails')
                    ->alignCenter()->sortable(),
            ])
            ->recordActions([
                EditAction::make(),
                DeleteAction::make()
                    ->modalDescription(fn (Utensil $record) => self::deleteWarning($record)),
            ]);
    }

    /** Aviso al borrar: desaparece de todos los cócteles que lo usan. */
    public static function deleteWarning(Utensil $utensil): string
    {
        $count = $utensil->cocktails()->count();

        return $count === 0
            ? 'No lo usa ningún cóctel.'
            : "Lo usan {$count} cócteles (de la biblioteca y de los locales). Desaparecerá de todos ellos. "
                .'Los locales que lo hayan personalizado conservan su versión.';
    }

    public static function getPages(): array
    {
        return [
            'index' => ListLibraryUtensils::route('/'),
            'create' => CreateLibraryUtensil::route('/create'),
            'edit' => EditLibraryUtensil::route('/{record}/edit'),
        ];
    }
}
