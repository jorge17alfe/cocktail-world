<?php

/**
 * Biblioteca · tanda 3: 15 cócteles SIN ALCOHOL (textos propios).
 * El primer tag es "Sin alcohol" para que salgan juntos en el filtro del recetario.
 *
 * Genera el SQL:  php database/sql/build_library_sql.php library_batch_3 > database/sql/library_batch_3.sql
 * Formato de ingredientes: [nombre, cantidad, unidad, nota]
 */

return [
    // ---------------------------------------------------------------- Clásicos sin alcohol
    [
        'name' => 'Shirley Temple',
        'tags' => ['Sin alcohol', 'Clásico', 'Refrescante'],
        'glass' => 'Vaso highball', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Cereza al marrasquino y rodaja de naranja',
        'ingredients' => [
            ['Ginger ale', 150, 'ml', 'o refresco de lima-limón'],
            ['Granadina', 15, 'ml', null],
            ['Zumo de lima', 10, 'ml', 'opcional'],
        ],
        'steps' => [
            'Llena el vaso de hielo.',
            'Añade el ginger ale y la lima.',
            'Vierte la granadina por encima: caerá al fondo y dará el degradado rojo.',
            'Decora con la cereza y la naranja.',
        ],
        'history' => 'Es probablemente el cóctel sin alcohol más famoso del mundo. Se creó en los años 30 para la niña actriz Shirley Temple, que acompañaba a los adultos en restaurantes de Hollywood y quería algo "de mayores". Varios locales se atribuyen su invención.',
        'utensils' => ['Jigger', 'Cuchara de bar', 'Cuchillo y tabla'],
    ],
    [
        'name' => 'Roy Rogers',
        'tags' => ['Sin alcohol', 'Clásico', 'Refrescante'],
        'glass' => 'Vaso highball', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Cereza al marrasquino',
        'ingredients' => [
            ['Refresco de cola', 180, 'ml', null],
            ['Granadina', 15, 'ml', null],
        ],
        'steps' => [
            'Llena el vaso de hielo.',
            'Añade la cola.',
            'Vierte la granadina y remueve suavemente.',
            'Decora con una cereza.',
        ],
        'history' => 'Es el "hermano" del Shirley Temple, pensado para los niños que no querían algo tan dulce. Toma el nombre de Roy Rogers, el famoso actor de películas del Oeste de los años 40 y 50.',
        'utensils' => ['Jigger', 'Cuchara de bar'],
    ],
    [
        'name' => 'San Francisco',
        'tags' => ['Sin alcohol', 'Clásico', 'Afrutado'],
        'glass' => 'Vaso highball', 'technique' => 'shake', 'ice' => 'Cubos',
        'garnish' => 'Rodaja de naranja y cereza',
        'ingredients' => [
            ['Zumo de naranja', 60, 'ml', null],
            ['Zumo de piña', 60, 'ml', null],
            ['Zumo de melocotón', 60, 'ml', null],
            ['Zumo de limón', 10, 'ml', 'recién exprimido'],
            ['Granadina', 15, 'ml', null],
        ],
        'steps' => [
            'Agita los zumos en la coctelera con hielo.',
            'Sirve en el vaso con hielo nuevo.',
            'Vierte la granadina por encima para que baje formando el degradado.',
            'Decora con la naranja y la cereza.',
        ],
        'history' => 'Es el cóctel sin alcohol más pedido en España, imprescindible en bodas, comuniones y chiringuitos. Su origen no está documentado y, pese al nombre, no se relaciona con la ciudad estadounidense. Cada bar tiene su proporción de zumos; esta es una de las más habituales.',
        'utensils' => ['Coctelera', 'Jigger', 'Colador Hawthorne', 'Exprimidor', 'Pajita'],
    ],
    [
        'name' => 'Cenicienta',
        'tags' => ['Sin alcohol', 'Clásico', 'Afrutado'],
        'glass' => 'Vaso highball', 'technique' => 'shake', 'ice' => 'Cubos',
        'garnish' => 'Rodaja de naranja',
        'ingredients' => [
            ['Zumo de naranja', 60, 'ml', null],
            ['Zumo de piña', 60, 'ml', null],
            ['Zumo de limón', 20, 'ml', 'recién exprimido'],
            ['Granadina', 10, 'ml', null],
            ['Soda', null, null, 'hasta completar'],
        ],
        'steps' => [
            'Agita los zumos y la granadina en la coctelera con hielo.',
            'Sirve en el vaso con hielo nuevo.',
            'Completa con un chorrito de soda.',
            'Decora con la naranja.',
        ],
        'history' => 'También conocido como "Cinderella", es otro clásico de las fiestas y de las cartas sin alcohol de toda la vida. Se parece al San Francisco, pero sin melocotón y con un toque de soda que lo hace más ligero.',
        'utensils' => ['Coctelera', 'Jigger', 'Colador Hawthorne', 'Exprimidor', 'Pajita'],
    ],
    [
        'name' => 'Pussyfoot',
        'tags' => ['Sin alcohol', 'Clásico', 'Cítrico'],
        'glass' => 'Copa de cóctel', 'technique' => 'shake', 'ice' => 'Sin hielo en copa',
        'garnish' => 'Piel de naranja',
        'ingredients' => [
            ['Zumo de naranja', 60, 'ml', 'recién exprimido'],
            ['Zumo de limón', 20, 'ml', 'recién exprimido'],
            ['Zumo de lima', 20, 'ml', 'recién exprimido'],
            ['Granadina', 10, 'ml', null],
            ['Yema de huevo', 1, 'unidad', 'opcional, le da textura'],
        ],
        'steps' => [
            'Añade todos los ingredientes a la coctelera con hielo.',
            'Agita con mucha fuerza 15 segundos.',
            'Sirve con doble colado en la copa fría.',
            'Perfuma con la piel de naranja.',
        ],
        'history' => 'Se creó a principios de los años 20 y su nombre es un guiño a William "Pussyfoot" Johnson, un famoso activista estadounidense contra el alcohol. Es uno de los cócteles sin alcohol más antiguos que se conocen.',
        'utensils' => ['Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor'],
    ],
    [
        'name' => 'Arnold Palmer',
        'tags' => ['Sin alcohol', 'Clásico', 'Refrescante'],
        'glass' => 'Vaso highball', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Rodaja de limón',
        'ingredients' => [
            ['Té negro frío', 100, 'ml', 'infusionado y enfriado'],
            ['Limonada', 100, 'ml', 'mejor casera'],
        ],
        'steps' => [
            'Llena el vaso de hielo.',
            'Añade el té frío y la limonada a partes iguales.',
            'Remueve y decora con el limón.',
        ],
        'history' => 'Toma el nombre del golfista estadounidense Arnold Palmer, que solía pedir esta mezcla de té helado y limonada en los años 60. Se popularizó tanto que hoy se sirve en Estados Unidos simplemente pidiéndolo por su nombre.',
        'utensils' => ['Jigger', 'Cuchara de bar'],
    ],

    // ---------------------------------------------------------------- Versiones "virgin"
    [
        'name' => 'Virgin Mojito',
        'tags' => ['Sin alcohol', 'Virgin', 'Refrescante'],
        'glass' => 'Vaso highball', 'technique' => 'muddle', 'ice' => 'Hielo picado',
        'garnish' => 'Ramita de hierbabuena y rodaja de lima',
        'ingredients' => [
            ['Hierbabuena', 8, 'hojas', null],
            ['Zumo de lima', 25, 'ml', 'recién exprimido'],
            ['Sirope de azúcar', 20, 'ml', 'o 2 cucharaditas de azúcar'],
            ['Soda', 120, 'ml', 'o ginger ale'],
        ],
        'steps' => [
            'Presiona suavemente la hierbabuena con la lima y el sirope en el vaso, sin romperla.',
            'Llena el vaso de hielo picado.',
            'Completa con la soda y remueve de abajo arriba.',
            'Decora con la hierbabuena y la lima.',
        ],
        'history' => 'Es la versión sin ron del Mojito cubano, también llamada "Nojito". Mantiene todo lo que hace refrescante al original: la hierbabuena, la lima y la burbuja. Con ginger ale en lugar de soda queda más aromático.',
        'utensils' => ['Mortero de bar', 'Jigger', 'Cuchara de bar', 'Exprimidor', 'Pajita'],
    ],
    [
        'name' => 'Virgin Piña Colada',
        'tags' => ['Sin alcohol', 'Virgin', 'Cremoso'],
        'glass' => 'Vaso hurricane o highball', 'technique' => 'blend', 'ice' => 'Hielo picado',
        'garnish' => 'Triángulo de piña y cereza',
        'ingredients' => [
            ['Zumo de piña', 120, 'ml', null],
            ['Crema de coco', 50, 'ml', null],
            ['Zumo de lima', 10, 'ml', 'opcional'],
            ['Hielo picado', 1, 'unidad', 'un vaso'],
        ],
        'steps' => [
            'Pon todos los ingredientes en la batidora con el hielo.',
            'Bate hasta que quede cremoso y sin trozos de hielo.',
            'Sirve en el vaso y decora con la piña y la cereza.',
        ],
        'history' => 'Es la Piña Colada de Puerto Rico sin ron, conocida también como "Piña Colada virgen". La crema de coco y la piña son las protagonistas, así que mantiene todo el sabor tropical del original.',
        'utensils' => ['Batidora de vaso', 'Jigger', 'Cuchillo y tabla', 'Pajita'],
    ],
    [
        'name' => 'Virgin Mary',
        'tags' => ['Sin alcohol', 'Virgin', 'Salado'],
        'glass' => 'Vaso highball', 'technique' => 'rolling', 'ice' => 'Cubos',
        'garnish' => 'Rama de apio y gajo de limón',
        'ingredients' => [
            ['Zumo de tomate', 150, 'ml', null],
            ['Zumo de limón', 15, 'ml', 'recién exprimido'],
            ['Salsa Worcestershire', 3, 'golpes', 'contiene anchoa'],
            ['Tabasco', 2, 'golpes', 'al gusto'],
            ['Sal de apio y pimienta negra', 1, 'chorrito', 'una pizca'],
        ],
        'steps' => [
            'Pon todos los ingredientes en un vaso con hielo.',
            'Pásalo a otro vaso varias veces ("rolling") para mezclar sin agitar.',
            'Sirve en el vaso con hielo.',
            'Decora con el apio y el limón.',
        ],
        'history' => 'Es el Bloody Mary sin vodka. Al no llevar alcohol, el sabor depende de un buen equilibrio de especias, así que cada bar suele tener su propia mezcla. Ojo con las alergias: la salsa Worcestershire lleva anchoa.',
        'utensils' => ['Jigger', 'Exprimidor', 'Cuchillo y tabla'],
    ],
    [
        'name' => 'Virgin Mule',
        'tags' => ['Sin alcohol', 'Virgin', 'Refrescante'],
        'glass' => 'Taza de cobre', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Rodaja de lima y ramita de hierbabuena',
        'ingredients' => [
            ['Ginger beer', 150, 'ml', null],
            ['Zumo de lima', 20, 'ml', 'recién exprimido'],
            ['Hierbabuena', 4, 'hojas', 'opcional'],
        ],
        'steps' => [
            'Llena la taza de hielo.',
            'Añade la lima y completa con la ginger beer.',
            'Remueve suavemente.',
            'Decora con la lima y la hierbabuena.',
        ],
        'history' => 'Es el Moscow Mule sin vodka. La ginger beer, picante y aromática, hace casi todo el trabajo, así que conviene usar una de calidad. Servido en su taza de cobre, nadie diría que no lleva alcohol.',
        'utensils' => ['Jigger', 'Cuchara de bar', 'Exprimidor', 'Cuchillo y tabla'],
    ],
    [
        'name' => 'Virgin Sunrise',
        'tags' => ['Sin alcohol', 'Virgin', 'Afrutado'],
        'glass' => 'Vaso highball', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Rodaja de naranja y cereza',
        'ingredients' => [
            ['Zumo de naranja', 150, 'ml', 'recién exprimido'],
            ['Granadina', 15, 'ml', null],
        ],
        'steps' => [
            'Llena el vaso de hielo y añade el zumo de naranja.',
            'Vierte la granadina despacio por el borde: se irá al fondo.',
            'No remuevas, para que se vea el "amanecer" de colores.',
            'Decora con la naranja y la cereza.',
        ],
        'history' => 'Es el Tequila Sunrise sin tequila. Su gracia está en el degradado de rojo a naranja, que recuerda a un amanecer. Es sencillo, vistoso y gusta mucho a los niños.',
        'utensils' => ['Jigger', 'Exprimidor', 'Cuchillo y tabla'],
    ],
    [
        'name' => 'Safe Sex on the Beach',
        'tags' => ['Sin alcohol', 'Virgin', 'Afrutado'],
        'glass' => 'Vaso highball', 'technique' => 'shake', 'ice' => 'Cubos',
        'garnish' => 'Rodaja de naranja',
        'ingredients' => [
            ['Zumo de arándano rojo', 60, 'ml', null],
            ['Zumo de naranja', 60, 'ml', null],
            ['Zumo de melocotón', 40, 'ml', null],
            ['Zumo de lima', 10, 'ml', 'opcional'],
        ],
        'steps' => [
            'Agita todos los zumos en la coctelera con hielo.',
            'Sirve en el vaso con hielo nuevo.',
            'Decora con la naranja.',
        ],
        'history' => 'Es la versión sin alcohol del Sex on the Beach, un cóctel que se hizo famoso en los años 80. Sin vodka ni licor de melocotón, el arándano y el melocotón mantienen su sabor afrutado y su color.',
        'utensils' => ['Coctelera', 'Jigger', 'Colador Hawthorne', 'Pajita'],
    ],
    [
        'name' => 'Daiquirí de fresa sin alcohol',
        'tags' => ['Sin alcohol', 'Virgin', 'Afrutado'],
        'glass' => 'Copa de cóctel', 'technique' => 'blend', 'ice' => 'Hielo picado',
        'garnish' => 'Fresa en el borde',
        'ingredients' => [
            ['Fresas', 6, 'unidad', 'frescas o congeladas'],
            ['Zumo de lima', 25, 'ml', 'recién exprimido'],
            ['Sirope de azúcar', 20, 'ml', null],
            ['Hielo picado', 1, 'unidad', 'medio vaso'],
        ],
        'steps' => [
            'Pon las fresas, la lima, el sirope y el hielo en la batidora.',
            'Bate hasta que quede una textura granizada.',
            'Sirve en la copa y decora con una fresa.',
        ],
        'history' => 'Es la versión frozen y sin ron del Daiquirí de fresa, que se popularizó en la segunda mitad del siglo XX. Con fresas congeladas queda más espeso y no hace falta tanto hielo.',
        'utensils' => ['Batidora de vaso', 'Jigger', 'Exprimidor', 'Cuchillo y tabla'],
    ],

    // ---------------------------------------------------------------- Modernos
    [
        'name' => 'Espresso Tonic',
        'tags' => ['Sin alcohol', 'Moderno', 'Café'],
        'glass' => 'Vaso highball', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Piel de naranja',
        'ingredients' => [
            ['Tónica', 120, 'ml', 'bien fría'],
            ['Café espresso', 30, 'ml', 'recién hecho'],
        ],
        'steps' => [
            'Llena el vaso de hielo y añade la tónica.',
            'Vierte el espresso despacio por encima: quedará flotando en capas.',
            'Perfuma con la piel de naranja.',
        ],
        'history' => 'Nació en Suecia hacia 2007, en el mundo de las cafeterías de especialidad, y se ha extendido por todo el mundo como bebida de verano. El amargor de la tónica y las notas del café combinan sorprendentemente bien.',
        'utensils' => ['Jigger', 'Cuchara de bar', 'Pelador'],
    ],
    [
        'name' => 'Limonada de fresa y albahaca',
        'tags' => ['Sin alcohol', 'Moderno', 'Refrescante'],
        'glass' => 'Vaso highball', 'technique' => 'muddle', 'ice' => 'Cubos',
        'garnish' => 'Fresa y hoja de albahaca',
        'ingredients' => [
            ['Fresas', 3, 'unidad', null],
            ['Albahaca', 4, 'hojas', null],
            ['Zumo de limón', 30, 'ml', 'recién exprimido'],
            ['Sirope de azúcar', 20, 'ml', null],
            ['Soda', 100, 'ml', null],
        ],
        'steps' => [
            'Machaca las fresas con la albahaca y el sirope en la coctelera.',
            'Añade el limón y hielo, y agita unos segundos.',
            'Cuela con doble colado en el vaso con hielo nuevo.',
            'Completa con soda y decora con la fresa y la albahaca.',
        ],
        'history' => 'Es una limonada de autor de las que hoy se ven en muchas cartas sin alcohol. La fresa aporta dulzor y color, y la albahaca un toque fresco y herbal que la hace diferente.',
        'utensils' => ['Mortero de bar', 'Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor'],
    ],
];
