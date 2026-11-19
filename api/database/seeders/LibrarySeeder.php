<?php

namespace Database\Seeders;

use App\Models\Cocktail;
use App\Models\Utensil;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

/**
 * Biblioteca base: utensilios globales + cócteles clásicos (recetas basadas en las
 * especificaciones IBA). Los locales los copian a sus familias y los adaptan.
 * Se puede ejecutar varias veces: actualiza por nombre, no duplica.
 */
class LibrarySeeder extends Seeder
{
    private const UTENSILS = [
        'Coctelera' => 'Coctelera Boston o cobbler para agitar con hielo.',
        'Jigger' => 'Medidor doble para dosificar con precisión.',
        'Colador Hawthorne' => 'Colador de muelle para retener el hielo al servir.',
        'Colador fino' => 'Colador de malla para un doble colado sin pulpa ni hielo picado.',
        'Vaso mezclador' => 'Para remover cócteles que se sirven sin agitar.',
        'Cuchara de bar' => 'Cuchara larga para remover y construir capas.',
        'Colador Julep' => 'Colador de cuchara para el vaso mezclador.',
        'Mortero de bar' => 'Muddler para machacar fruta, hierbas y azúcar.',
        'Exprimidor' => 'Para zumos cítricos frescos.',
        'Batidora de vaso' => 'Para cócteles frozen o batidos.',
        'Pinzas' => 'Para colocar hielo y decoraciones.',
        'Cuchillo y tabla' => 'Para cortar fruta y preparar pieles de cítricos.',
        'Pelador' => 'Para sacar pieles de cítricos sin la parte blanca.',
        'Pajita' => 'Pajita para servir.',
    ];

    public function run(): void
    {
        DB::transaction(function () {
            $utensils = [];
            foreach (self::UTENSILS as $name => $description) {
                $utensils[$name] = Utensil::updateOrCreate(
                    ['establishment_id' => null, 'name' => $name],
                    ['description' => $description]
                )->id;
            }

            foreach ($this->cocktails() as $data) {
                $cocktail = Cocktail::library()->firstOrNew(['name' => $data['name']]);
                $cocktail->fill(collect($data)->except(['ingredients', 'utensils', 'image'])->all());
                $cocktail->establishment_id = null;
                $cocktail->family_id = null;
                $cocktail->save();

                $cocktail->ingredients()->delete();
                foreach ($data['ingredients'] as $i => [$name, $amount, $unit, $note]) {
                    $cocktail->ingredients()->create(compact('name', 'amount', 'unit', 'note') + ['order' => $i]);
                }

                $cocktail->utensils()->sync(array_map(fn ($u) => $utensils[$u], $data['utensils']));

                // Reutiliza las fotos que ya hay en storage/app/public/images/cocktails
                $image = $data['image'] ?? null;
                if ($image && Storage::disk('public')->exists($image) && ! $cocktail->images()->where('path', $image)->exists()) {
                    $cocktail->images()->create(['path' => $image, 'order' => 0]);
                }
            }
        });
    }

    private function cocktails(): array
    {
        return [
            [
                'name' => 'Margarita',
                'tags' => ['Clásicos', 'Tequila', 'IBA'],
                'glass' => 'Copa margarita', 'technique' => 'shake', 'ice' => 'Sin hielo en copa',
                'garnish' => 'Medio borde escarchado con sal y gajo de lima',
                'image' => 'images/cocktails/margarita/margarita.png',
                'ingredients' => [
                    ['Tequila blanco 100% agave', 50, 'ml', null],
                    ['Triple sec (Cointreau)', 20, 'ml', null],
                    ['Zumo de lima', 15, 'ml', 'recién exprimido'],
                ],
                'steps' => [
                    'Escarcha medio borde de la copa con lima y sal y enfríala.',
                    'Añade todos los ingredientes a la coctelera.',
                    'Llena de hielo y agita con fuerza 10-15 segundos.',
                    'Sirve con doble colado en la copa fría.',
                    'Decora con un gajo de lima.',
                ],
                'history' => 'Su origen es discutido. Una de las versiones más citadas lo sitúa en México a finales de los años 30 o en los 40, cuando un barman habría creado la mezcla de tequila, licor de naranja y lima para una clienta. Es una variante de la familia de los "sours" y se convirtió en el cóctel de tequila más famoso del mundo.',
                'utensils' => ['Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor'],
            ],
            [
                'name' => 'Negroni',
                'tags' => ['Clásicos', 'Ginebra', 'IBA'],
                'glass' => 'Vaso old fashioned', 'technique' => 'stir', 'ice' => 'Cubos o bloque grande',
                'garnish' => 'Piel o media rodaja de naranja',
                'image' => 'images/cocktails/negroni/negroni.png',
                'ingredients' => [
                    ['Ginebra', 30, 'ml', null],
                    ['Campari', 30, 'ml', null],
                    ['Vermut rojo', 30, 'ml', null],
                ],
                'steps' => [
                    'Añade los tres ingredientes al vaso mezclador con hielo.',
                    'Remueve unos 20-30 segundos hasta enfriar y diluir ligeramente.',
                    'Cuela sobre un vaso old fashioned con hielo nuevo.',
                    'Exprime la piel de naranja sobre el cóctel y úsala de decoración.',
                ],
                'history' => 'Se atribuye al conde Camillo Negroni, que hacia 1919 en el Caffè Casoni de Florencia pidió reforzar su Americano (Campari, vermut y soda) cambiando la soda por ginebra. Partes iguales, fácil de recordar y uno de los aperitivos italianos más icónicos.',
                'utensils' => ['Vaso mezclador', 'Cuchara de bar', 'Colador Julep', 'Jigger', 'Pelador'],
            ],
            [
                'name' => 'Mojito',
                'tags' => ['Internacionales', 'Ron', 'IBA'],
                'glass' => 'Vaso highball', 'technique' => 'muddle', 'ice' => 'Hielo picado',
                'garnish' => 'Ramita de hierbabuena y gajo de lima',
                'ingredients' => [
                    ['Ron blanco', 45, 'ml', null],
                    ['Zumo de lima', 20, 'ml', 'recién exprimido'],
                    ['Azúcar blanco', 2, 'cucharaditas', null],
                    ['Hierbabuena', 6, 'hojas', null],
                    ['Soda', null, null, 'para completar'],
                ],
                'steps' => [
                    'Pon la hierbabuena, el azúcar y el zumo de lima en el vaso.',
                    'Presiona suavemente con el mortero para liberar el aroma, sin romper las hojas.',
                    'Añade el ron y llena el vaso de hielo picado.',
                    'Completa con un chorrito de soda y remueve de abajo arriba.',
                    'Decora con una ramita de hierbabuena y sirve con pajita.',
                ],
                'history' => 'Originario de Cuba. Suele relacionarse con "El Draque", una bebida de aguardiente, lima y hierbabuena del siglo XVI asociada a los marineros de Francis Drake. En el siglo XX se hizo famoso en La Habana, especialmente en La Bodeguita del Medio.',
                'utensils' => ['Mortero de bar', 'Jigger', 'Cuchara de bar', 'Exprimidor', 'Pajita'],
            ],
            [
                'name' => 'Old Fashioned',
                'tags' => ['Clásicos', 'Whisky', 'IBA'],
                'glass' => 'Vaso old fashioned', 'technique' => 'stir', 'ice' => 'Bloque grande o cubos',
                'garnish' => 'Piel de naranja y cereza',
                'ingredients' => [
                    ['Bourbon o whisky de centeno', 45, 'ml', null],
                    ['Terrón de azúcar', 1, 'unidad', null],
                    ['Angostura bitters', 3, 'golpes', null],
                    ['Agua', 1, 'chorrito', null],
                ],
                'steps' => [
                    'Pon el terrón en el vaso, empápalo con la Angostura y un chorrito de agua.',
                    'Machaca hasta disolver el azúcar.',
                    'Añade hielo y el whisky.',
                    'Remueve unos 30 segundos.',
                    'Exprime la piel de naranja por encima y decora con piel y cereza.',
                ],
                'history' => 'Representa la fórmula original de "cocktail" de principios del siglo XIX: licor, azúcar, agua y bitters. Hacia finales de ese siglo los clientes empezaron a pedir sus cócteles "a la antigua" (old fashioned) frente a las versiones nuevas, y el nombre se quedó.',
                'utensils' => ['Mortero de bar', 'Cuchara de bar', 'Jigger', 'Pelador'],
            ],
            [
                'name' => 'Daiquirí',
                'tags' => ['Clásicos', 'Ron', 'IBA'],
                'glass' => 'Copa de cóctel', 'technique' => 'shake', 'ice' => 'Sin hielo en copa',
                'garnish' => 'Rueda de lima (opcional)',
                'ingredients' => [
                    ['Ron blanco', 60, 'ml', null],
                    ['Zumo de lima', 20, 'ml', 'recién exprimido'],
                    ['Almíbar simple', 10, 'ml', 'ajustar al gusto'],
                ],
                'steps' => [
                    'Enfría la copa.',
                    'Añade todos los ingredientes a la coctelera con hielo.',
                    'Agita con fuerza 10-15 segundos.',
                    'Sirve con doble colado en la copa fría.',
                ],
                'history' => 'Toma el nombre de la zona de Daiquirí, cerca de Santiago de Cuba. Se atribuye al ingeniero estadounidense Jennings Cox, a principios del siglo XX. El bar El Floridita de La Habana lo hizo famoso y Ernest Hemingway fue uno de sus clientes más conocidos.',
                'utensils' => ['Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor'],
            ],
            [
                'name' => 'Moscow Mule',
                'tags' => ['Internacionales', 'Vodka', 'IBA'],
                'glass' => 'Taza de cobre', 'technique' => 'build', 'ice' => 'Cubos',
                'garnish' => 'Rueda de lima',
                'image' => 'images/cocktails/moscowMule/moscowMule.png',
                'ingredients' => [
                    ['Vodka', 45, 'ml', null],
                    ['Zumo de lima', 10, 'ml', 'recién exprimido'],
                    ['Ginger beer', 120, 'ml', 'muy fría'],
                ],
                'steps' => [
                    'Llena la taza de cobre de hielo.',
                    'Añade el vodka y el zumo de lima.',
                    'Completa con ginger beer.',
                    'Remueve suavemente y decora con una rueda de lima.',
                ],
                'history' => 'Nació en Estados Unidos a principios de los años 40, en el bar Cock \'n\' Bull de Los Ángeles. Se creó para dar salida al vodka Smirnoff y a la ginger beer de la casa, y la taza de cobre se convirtió en su seña de identidad.',
                'utensils' => ['Jigger', 'Cuchara de bar', 'Exprimidor'],
            ],
            [
                'name' => 'Espresso Martini',
                'tags' => ['Modernos', 'Vodka', 'Café', 'IBA'],
                'glass' => 'Copa de cóctel', 'technique' => 'shake', 'ice' => 'Sin hielo en copa',
                'garnish' => '3 granos de café',
                'image' => 'images/cocktails/espressoMartini/espressoMartini.png',
                'ingredients' => [
                    ['Vodka', 50, 'ml', null],
                    ['Licor de café', 30, 'ml', null],
                    ['Café espresso', 30, 'ml', 'recién hecho'],
                    ['Almíbar simple', 5, 'ml', 'opcional'],
                ],
                'steps' => [
                    'Prepara el espresso y deja que pierda algo de temperatura.',
                    'Añade todo a la coctelera con mucho hielo.',
                    'Agita muy fuerte unos 15 segundos para crear espuma.',
                    'Sirve con doble colado en la copa fría.',
                    'Decora con 3 granos de café.',
                ],
                'history' => 'Creado por el bartender británico Dick Bradsell en Londres a finales de los años 80. Según la anécdota, una clienta le pidió una bebida que la despertara y la animara a la vez. Es uno de los cócteles modernos más populares.',
                'utensils' => ['Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino'],
            ],
            [
                'name' => 'Bloody Mary',
                'tags' => ['Clásicos', 'Vodka', 'IBA'],
                'glass' => 'Vaso highball', 'technique' => 'rolling', 'ice' => 'Cubos',
                'garnish' => 'Rama de apio y gajo de limón',
                'image' => 'images/cocktails/blodyMary/blodyMary.png',
                'ingredients' => [
                    ['Vodka', 45, 'ml', null],
                    ['Zumo de tomate', 90, 'ml', null],
                    ['Zumo de limón', 15, 'ml', 'recién exprimido'],
                    ['Salsa Worcestershire', 3, 'golpes', null],
                    ['Tabasco', 2, 'golpes', 'al gusto'],
                    ['Sal de apio y pimienta negra', null, null, 'una pizca'],
                ],
                'steps' => [
                    'Añade todos los ingredientes a una mitad de la coctelera con hielo.',
                    'Pasa la mezcla de un recipiente a otro varias veces (rolling), sin agitar.',
                    'Sirve en el vaso con hielo.',
                    'Decora con la rama de apio y el gajo de limón.',
                ],
                'history' => 'Se atribuye a Fernand Petiot, del Harry\'s New York Bar de París, en los años 20. Petiot lo llevó después al hotel St. Regis de Nueva York. Es el cóctel de brunch por excelencia y existen infinitas versiones de su mezcla especiada.',
                'utensils' => ['Coctelera', 'Jigger', 'Colador Hawthorne', 'Exprimidor', 'Cuchillo y tabla'],
            ],
            [
                'name' => 'Piña Colada',
                'tags' => ['Internacionales', 'Ron', 'IBA'],
                'glass' => 'Vaso hurricane o highball', 'technique' => 'blend', 'ice' => 'Hielo picado',
                'garnish' => 'Trozo de piña y cereza',
                'ingredients' => [
                    ['Ron blanco', 50, 'ml', null],
                    ['Crema de coco', 30, 'ml', null],
                    ['Zumo de piña', 50, 'ml', null],
                ],
                'steps' => [
                    'Pon todos los ingredientes en la batidora con un vaso de hielo picado.',
                    'Bate hasta obtener una textura cremosa (o agita fuerte en coctelera).',
                    'Sirve en el vaso.',
                    'Decora con piña y cereza y sirve con pajita.',
                ],
                'history' => 'Es la bebida nacional de Puerto Rico. Suele atribuirse a Ramón "Monchito" Marrero, del hotel Caribe Hilton de San Juan, en 1954. El restaurante Barrachina también reclama su origen.',
                'utensils' => ['Batidora de vaso', 'Jigger', 'Cuchillo y tabla', 'Pajita'],
            ],
            [
                'name' => 'Cosmopolitan',
                'tags' => ['Modernos', 'Vodka', 'IBA'],
                'glass' => 'Copa de cóctel', 'technique' => 'shake', 'ice' => 'Sin hielo en copa',
                'garnish' => 'Piel de lima o de naranja',
                'ingredients' => [
                    ['Vodka citron', 40, 'ml', null],
                    ['Cointreau', 15, 'ml', null],
                    ['Zumo de lima', 15, 'ml', 'recién exprimido'],
                    ['Zumo de arándano rojo', 30, 'ml', null],
                ],
                'steps' => [
                    'Enfría la copa.',
                    'Añade todos los ingredientes a la coctelera con hielo.',
                    'Agita bien 10-15 segundos.',
                    'Sirve con doble colado y decora con la piel.',
                ],
                'history' => 'Se popularizó en Estados Unidos en los años 80 y 90. Varios bartenders reclaman su autoría, entre ellos Toby Cecchini, del restaurante The Odeon de Nueva York. La serie "Sexo en Nueva York" lo convirtió en un icono.',
                'utensils' => ['Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Pelador'],
            ],
            [
                'name' => 'Dry Martini',
                'tags' => ['Clásicos', 'Ginebra', 'IBA'],
                'glass' => 'Copa martini', 'technique' => 'stir', 'ice' => 'Sin hielo en copa',
                'garnish' => 'Aceituna o piel de limón',
                'ingredients' => [
                    ['Ginebra', 60, 'ml', null],
                    ['Vermut seco', 10, 'ml', null],
                ],
                'steps' => [
                    'Enfría la copa.',
                    'Añade la ginebra y el vermut al vaso mezclador con mucho hielo.',
                    'Remueve unos 30 segundos.',
                    'Cuela en la copa fría.',
                    'Decora con aceituna o exprime una piel de limón.',
                ],
                'history' => 'Evolución de cócteles de finales del siglo XIX como el Martinez, cada vez más secos y con menos vermut. Durante el siglo XX se convirtió en el símbolo de la coctelería elegante.',
                'utensils' => ['Vaso mezclador', 'Cuchara de bar', 'Colador Julep', 'Jigger', 'Pelador'],
            ],
            [
                'name' => 'Caipirinha',
                'tags' => ['Internacionales', 'Cachaça', 'IBA'],
                'glass' => 'Vaso old fashioned', 'technique' => 'muddle', 'ice' => 'Hielo picado',
                'garnish' => 'Los propios trozos de lima',
                'ingredients' => [
                    ['Cachaça', 60, 'ml', null],
                    ['Lima', 0.5, 'unidad', 'en 4 trozos'],
                    ['Azúcar blanco', 2, 'cucharaditas', null],
                ],
                'steps' => [
                    'Pon la lima troceada y el azúcar en el vaso.',
                    'Machaca para extraer el zumo y los aceites de la piel.',
                    'Llena de hielo picado y añade la cachaça.',
                    'Remueve bien y sirve.',
                ],
                'history' => 'Es el cóctel nacional de Brasil. Suele relacionarse con un remedio popular de São Paulo de principios del siglo XX, hecho con lima, ajo y miel, que con el tiempo se transformó en la mezcla actual de cachaça, lima y azúcar.',
                'utensils' => ['Mortero de bar', 'Cuchara de bar', 'Jigger', 'Cuchillo y tabla'],
            ],
            [
                'name' => 'Whisky Sour',
                'tags' => ['Clásicos', 'Whisky', 'IBA'],
                'glass' => 'Vaso old fashioned', 'technique' => 'shake', 'ice' => 'Cubos',
                'garnish' => 'Media rodaja de naranja y cereza',
                'ingredients' => [
                    ['Bourbon', 45, 'ml', null],
                    ['Zumo de limón', 25, 'ml', 'recién exprimido'],
                    ['Almíbar simple', 20, 'ml', null],
                    ['Clara de huevo', 20, 'ml', 'opcional'],
                ],
                'steps' => [
                    'Si usas clara, agita primero sin hielo (dry shake) para emulsionar.',
                    'Añade hielo y agita de nuevo con fuerza.',
                    'Cuela sobre el vaso con hielo.',
                    'Decora con naranja y cereza.',
                ],
                'history' => 'Los "sours" ya aparecen en el libro de coctelería de Jerry Thomas de 1862. El Whisky Sour es uno de los más antiguos y sirvió de base para muchos otros cócteles.',
                'utensils' => ['Coctelera', 'Jigger', 'Colador Hawthorne', 'Exprimidor'],
            ],
            [
                'name' => 'Pisco Sour',
                'tags' => ['Internacionales', 'Pisco', 'IBA'],
                'glass' => 'Copa de cóctel o vaso old fashioned', 'technique' => 'shake', 'ice' => 'Sin hielo en copa',
                'garnish' => 'Unas gotas de Angostura sobre la espuma',
                'ingredients' => [
                    ['Pisco', 60, 'ml', null],
                    ['Zumo de lima', 30, 'ml', 'recién exprimido'],
                    ['Almíbar simple', 20, 'ml', null],
                    ['Clara de huevo', 1, 'unidad', null],
                    ['Angostura bitters', 3, 'gotas', 'para decorar'],
                ],
                'steps' => [
                    'Agita todos los ingredientes sin hielo (dry shake) para montar la clara.',
                    'Añade hielo y agita de nuevo con fuerza.',
                    'Sirve con doble colado.',
                    'Pon unas gotas de Angostura sobre la espuma.',
                ],
                'history' => 'Se atribuye al estadounidense Victor Morris, que tenía un bar en Lima en los años 20. Perú y Chile se disputan tanto el pisco como el cóctel.',
                'utensils' => ['Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor'],
            ],
            [
                'name' => 'Spritz Veneziano',
                'tags' => ['Internacionales', 'Aperitivo', 'IBA'],
                'glass' => 'Copa de vino', 'technique' => 'build', 'ice' => 'Cubos',
                'garnish' => 'Media rodaja de naranja',
                'ingredients' => [
                    ['Prosecco', 60, 'ml', null],
                    ['Aperol', 40, 'ml', null],
                    ['Soda', 1, 'chorrito', null],
                ],
                'steps' => [
                    'Llena la copa de hielo.',
                    'Añade el prosecco y después el Aperol.',
                    'Completa con un chorrito de soda.',
                    'Remueve suavemente y decora con naranja.',
                ],
                'history' => 'Viene del Véneto. En el siglo XIX los soldados austriacos rebajaban el vino local con agua ("spritzen" significa salpicar). Más tarde se le añadieron aperitivos amargos como el Aperol.',
                'utensils' => ['Jigger', 'Cuchara de bar', 'Cuchillo y tabla'],
            ],
        ];
    }
}
