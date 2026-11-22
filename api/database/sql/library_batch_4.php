<?php

/**
 * Biblioteca · tanda 4: 20 spritz, aperitivos y clásicos españoles (textos propios).
 * Los spritz y aperitivos llevan el tag "Aperitivo" (como el Spritz Veneziano que ya existe)
 * para que salgan juntos en el filtro del recetario. Los españoles llevan "Españoles".
 *
 * Genera el SQL:  php database/sql/build_library_sql.php library_batch_4 > database/sql/library_batch_4.sql
 * Formato de ingredientes: [nombre, cantidad, unidad, nota]
 */

return [
    // ---------------------------------------------------------------- Spritz
    [
        'name' => 'Hugo',
        'tags' => ['Aperitivo', 'Spritz', 'Espumoso'],
        'glass' => 'Copa de vino', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Ramita de menta y rodaja de lima',
        'ingredients' => [
            ['Prosecco', 120, 'ml', 'bien frío'],
            ['Licor o sirope de flor de saúco', 20, 'ml', 'por ejemplo St-Germain'],
            ['Soda', 30, 'ml', null],
            ['Hojas de menta', 8, 'hojas', null],
            ['Lima', 1, 'unidad', 'en rodajas'],
        ],
        'steps' => [
            'Pon la menta en la copa y presiónala un poco con la cuchara para que suelte aroma, sin romperla.',
            'Añade el saúco y la lima, y llena la copa de hielo.',
            'Vierte el prosecco y completa con la soda.',
            'Remueve suavemente de abajo arriba y decora con menta.',
        ],
        'history' => 'Nació en 2005 en el Tirol del Sur (norte de Italia), de la mano del barman Roland Gruber, como alternativa más ligera y floral al Spritz de Aperol. La primera versión usaba sirope de melisa; el de flor de saúco acabó imponiéndose y lo hizo famoso en toda Europa.',
        'utensils' => ['Jigger', 'Cuchara de bar', 'Cuchillo y tabla'],
    ],
    [
        'name' => 'St-Germain Spritz',
        'tags' => ['Aperitivo', 'Spritz', 'Espumoso'],
        'glass' => 'Copa de vino', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Piel de limón',
        'ingredients' => [
            ['Prosecco o cava', 60, 'ml', null],
            ['St-Germain', 40, 'ml', 'licor de flor de saúco'],
            ['Soda', 60, 'ml', null],
        ],
        'steps' => [
            'Llena la copa de hielo.',
            'Añade el St-Germain y después el espumoso.',
            'Completa con la soda y remueve suavemente.',
            'Exprime la piel de limón encima y déjala dentro.',
        ],
        'history' => 'El licor St-Germain, hecho con flores de saúco recogidas a mano en primavera, se lanzó en 2007 y en pocos años se volvió imprescindible en las barras. Su receta de "spritz" con espumoso y soda es la forma más sencilla y popular de tomarlo.',
        'utensils' => ['Jigger', 'Cuchara de bar', 'Pelador'],
    ],
    [
        'name' => 'Limoncello Spritz',
        'tags' => ['Aperitivo', 'Spritz', 'Cítrico'],
        'glass' => 'Copa de vino', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Rodaja de limón y hojas de menta o albahaca',
        'ingredients' => [
            ['Prosecco', 90, 'ml', null],
            ['Limoncello', 60, 'ml', 'bien frío'],
            ['Soda', 30, 'ml', null],
        ],
        'steps' => [
            'Llena la copa de hielo.',
            'Añade el limoncello y después el prosecco.',
            'Completa con la soda y remueve suavemente.',
            'Decora con el limón y las hierbas.',
        ],
        'history' => 'El limoncello es el licor de piel de limón típico de la costa de Amalfi, Sorrento y Capri, que tradicionalmente se toma solo y helado después de comer. Su versión spritz es una creación reciente que lo convierte en un aperitivo veraniego, más dulce y cítrico que el de Aperol.',
        'utensils' => ['Jigger', 'Cuchara de bar', 'Cuchillo y tabla'],
    ],
    [
        'name' => 'Campari Spritz',
        'tags' => ['Aperitivo', 'Spritz', 'Amargo'],
        'glass' => 'Copa de vino', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Rodaja de naranja',
        'ingredients' => [
            ['Prosecco', 90, 'ml', null],
            ['Campari', 60, 'ml', null],
            ['Soda', 30, 'ml', null],
        ],
        'steps' => [
            'Llena la copa de hielo.',
            'Añade el prosecco y después el Campari.',
            'Completa con la soda.',
            'Remueve suavemente y decora con la naranja.',
        ],
        'history' => 'Es el spritz preferido en Milán, la ciudad del Campari. Tiene la misma estructura que el Spritz de Aperol, pero el Campari lo hace más amargo, más intenso y de un rojo más oscuro.',
        'utensils' => ['Jigger', 'Cuchara de bar', 'Cuchillo y tabla'],
    ],
    [
        'name' => 'Lillet Tonic',
        'tags' => ['Aperitivo', 'Spritz', 'Refrescante'],
        'glass' => 'Copa de vino', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Rodaja de pepino, fresa y hojas de menta',
        'ingredients' => [
            ['Lillet Blanc', 50, 'ml', 'o Lillet Rosé'],
            ['Tónica', 100, 'ml', null],
        ],
        'steps' => [
            'Llena la copa de hielo y coloca la fruta y la menta.',
            'Añade el Lillet.',
            'Completa con la tónica y remueve suavemente.',
        ],
        'history' => 'El Lillet es un aperitivo de vino aromatizado con frutas y quinina que se elabora desde 1872 en Podensac, cerca de Burdeos. Con tónica, fruta y hierbas se convirtió en uno de los aperitivos de moda en Francia.',
        'utensils' => ['Jigger', 'Cuchara de bar', 'Cuchillo y tabla'],
    ],

    // ---------------------------------------------------------------- Aperitivos italianos y franceses
    [
        'name' => 'Negroni Sbagliato',
        'tags' => ['Aperitivo', 'Clásicos', 'Espumoso'],
        'glass' => 'Vaso old fashioned', 'technique' => 'build', 'ice' => 'Bloque grande o cubos',
        'garnish' => 'Media rodaja de naranja',
        'ingredients' => [
            ['Campari', 30, 'ml', null],
            ['Vermut rojo', 30, 'ml', null],
            ['Prosecco', 30, 'ml', 'o más, al gusto'],
        ],
        'steps' => [
            'Pon el hielo en el vaso.',
            'Añade el Campari y el vermut y remueve unos segundos.',
            'Completa con el prosecco y remueve una sola vez, con cuidado de no quitarle la burbuja.',
            'Decora con la naranja.',
        ],
        'history' => '"Sbagliato" significa "equivocado" en italiano. Según la historia del Bar Basso de Milán, a finales de los años 60 un barman cogió por error una botella de espumoso en lugar de la ginebra al preparar un Negroni. El resultado gustó tanto que se quedó en la carta.',
        'utensils' => ['Jigger', 'Cuchara de bar', 'Cuchillo y tabla'],
    ],
    [
        'name' => 'Garibaldi',
        'tags' => ['Aperitivo', 'Clásicos', 'Afrutado'],
        'glass' => 'Vaso highball', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Rodaja de naranja',
        'ingredients' => [
            ['Campari', 45, 'ml', null],
            ['Zumo de naranja', 120, 'ml', 'recién exprimido'],
        ],
        'steps' => [
            'Llena el vaso de hielo y añade el Campari.',
            'Exprime la naranja y bate el zumo unos segundos (con batidora o agitándolo fuerte) para que quede espumoso.',
            'Vierte el zumo sobre el Campari.',
            'Decora con la naranja.',
        ],
        'history' => 'Homenaje a Giuseppe Garibaldi, héroe de la unificación de Italia: el Campari representa el norte (Milán) y la naranja, el sur (Sicilia). La versión moderna con zumo batido y "esponjoso" la popularizaron bares de cócteles de Nueva York.',
        'utensils' => ['Jigger', 'Exprimidor', 'Cuchillo y tabla'],
    ],
    [
        'name' => 'Bicicletta',
        'tags' => ['Aperitivo', 'Clásicos', 'Amargo'],
        'glass' => 'Copa de vino', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Rodaja de limón o naranja',
        'ingredients' => [
            ['Campari', 45, 'ml', null],
            ['Vino blanco seco', 90, 'ml', 'bien frío'],
            ['Soda', 30, 'ml', null],
        ],
        'steps' => [
            'Llena la copa de hielo.',
            'Añade el Campari y el vino.',
            'Completa con la soda y remueve suavemente.',
            'Decora con el cítrico.',
        ],
        'history' => 'Un aperitivo de bar de pueblo del norte de Italia, anterior a la moda del spritz con espumoso. Cuenta la leyenda que su nombre viene de los señores mayores que, después de unos cuantos, volvían a casa en bicicleta haciendo eses.',
        'utensils' => ['Jigger', 'Cuchara de bar', 'Cuchillo y tabla'],
    ],
    [
        'name' => 'Kir',
        'tags' => ['Aperitivo', 'IBA', 'Clásicos'],
        'glass' => 'Copa de vino', 'technique' => 'build', 'ice' => 'Sin hielo en copa',
        'garnish' => 'Sin decoración',
        'ingredients' => [
            ['Vino blanco seco', 90, 'ml', 'tradicionalmente aligoté de Borgoña, bien frío'],
            ['Crème de cassis', 10, 'ml', 'licor de grosella negra'],
        ],
        'steps' => [
            'Vierte el crème de cassis en la copa.',
            'Completa con el vino blanco muy frío.',
            'Remueve una vez con la cuchara.',
        ],
        'history' => 'Lleva el nombre de Félix Kir, sacerdote y alcalde de Dijon tras la Segunda Guerra Mundial, que lo servía en las recepciones oficiales para promocionar dos productos de su región: el vino blanco de Borgoña y el licor de cassis.',
        'utensils' => ['Jigger', 'Cuchara de bar'],
    ],
    [
        'name' => 'Kir Royal',
        'tags' => ['Aperitivo', 'IBA', 'Espumoso'],
        'glass' => 'Copa flauta', 'technique' => 'build', 'ice' => 'Sin hielo en copa',
        'garnish' => 'Una frambuesa o mora (opcional)',
        'ingredients' => [
            ['Champán', 120, 'ml', 'o cava, bien frío'],
            ['Crème de cassis', 10, 'ml', null],
        ],
        'steps' => [
            'Vierte el crème de cassis en la copa.',
            'Completa despacio con el champán, inclinando un poco la copa para no perder burbuja.',
            'Decora con la fruta si quieres.',
        ],
        'history' => 'Es la versión "de lujo" del Kir: se cambia el vino blanco por champán. Se convirtió en el aperitivo de celebración clásico de Francia.',
        'utensils' => ['Jigger'],
    ],
    [
        'name' => 'Rossini',
        'tags' => ['Aperitivo', 'Clásicos', 'Espumoso'],
        'glass' => 'Copa flauta', 'technique' => 'build', 'ice' => 'Sin hielo en copa',
        'garnish' => 'Media fresa en el borde',
        'ingredients' => [
            ['Puré de fresa', 50, 'ml', 'fresas trituradas y coladas, con un poco de azúcar'],
            ['Prosecco', 100, 'ml', 'bien frío'],
        ],
        'steps' => [
            'Pon el puré de fresa en la copa.',
            'Añade el prosecco despacio, removiendo suavemente para que se mezcle sin perder burbuja.',
            'Decora con la fresa.',
        ],
        'history' => 'Es "primo" del Bellini, que se hace con melocotón. Lleva el nombre del compositor italiano Gioachino Rossini, autor de "El barbero de Sevilla", y es uno de los aperitivos con prosecco más populares de Italia.',
        'utensils' => ['Batidora de vaso', 'Colador fino', 'Jigger', 'Cuchara de bar'],
    ],
    [
        'name' => 'Aperol Sour',
        'tags' => ['Aperitivo', 'Modernos', 'Cítrico'],
        'glass' => 'Vaso old fashioned', 'technique' => 'shake', 'ice' => 'Cubos',
        'garnish' => 'Piel de naranja',
        'ingredients' => [
            ['Aperol', 50, 'ml', null],
            ['Zumo de limón', 25, 'ml', 'recién exprimido'],
            ['Sirope simple', 15, 'ml', null],
            ['Clara de huevo', 1, 'unidad', 'opcional, para la espuma'],
        ],
        'steps' => [
            'Si usas clara, agita primero todo sin hielo unos segundos para montar la espuma.',
            'Añade hielo a la coctelera y agita con fuerza.',
            'Cuela sobre hielo nuevo en el vaso.',
            'Exprime la piel de naranja encima y úsala de decoración.',
        ],
        'history' => 'Una forma moderna de tomar Aperol fuera del spritz: aplicar la fórmula clásica "sour" (licor, cítrico y dulce). El resultado es suave, afrutado y con un toque amargo, muy fácil de beber.',
        'utensils' => ['Coctelera', 'Jigger', 'Colador Hawthorne', 'Exprimidor', 'Pelador'],
    ],
    [
        'name' => 'Amaretto Sour',
        'tags' => ['Licores', 'Modernos', 'Cítrico'],
        'glass' => 'Vaso old fashioned', 'technique' => 'shake', 'ice' => 'Cubos',
        'garnish' => 'Piel de limón y cereza',
        'ingredients' => [
            ['Amaretto', 45, 'ml', null],
            ['Bourbon', 20, 'ml', 'opcional, equilibra el dulzor'],
            ['Zumo de limón', 30, 'ml', 'recién exprimido'],
            ['Sirope simple', 1, 'cucharaditas', null],
            ['Clara de huevo', 1, 'unidad', 'opcional'],
        ],
        'steps' => [
            'Agita primero todo sin hielo unos segundos para montar la clara.',
            'Añade hielo y agita con fuerza.',
            'Cuela sobre hielo nuevo en el vaso.',
            'Decora con la piel de limón y la cereza.',
        ],
        'history' => 'Fue muy popular en los años 70 como cóctel dulce y fácil. Años después, bármanes como Jeffrey Morgenthaler lo "rescataron" añadiendo un poco de bourbon y zumo fresco para que no fuera tan empalagoso. Esa es la versión que se sirve hoy en las buenas barras.',
        'utensils' => ['Coctelera', 'Jigger', 'Colador Hawthorne', 'Exprimidor', 'Pelador'],
    ],

    // ---------------------------------------------------------------- Españoles
    [
        'name' => 'Tinto de verano',
        'tags' => ['Españoles', 'Vino', 'Refrescante'],
        'glass' => 'Vaso highball', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Rodaja de limón',
        'ingredients' => [
            ['Vino tinto joven', 100, 'ml', null],
            ['Gaseosa', 100, 'ml', 'o refresco de limón, al gusto'],
        ],
        'steps' => [
            'Llena el vaso de hielo.',
            'Añade el vino tinto.',
            'Completa con la gaseosa o el refresco de limón.',
            'Remueve una vez y decora con el limón.',
        ],
        'history' => 'Se atribuye a la Venta de Vargas, en Córdoba, a principios del siglo XX, donde se servía a los clientes como "un Vargas". Hoy es la bebida de terraza por excelencia del verano en España, más ligera y sencilla que la sangría.',
        'utensils' => ['Jigger', 'Cuchara de bar', 'Cuchillo y tabla'],
    ],
    [
        'name' => 'Rebujito',
        'tags' => ['Españoles', 'Vino', 'Refrescante'],
        'glass' => 'Vaso highball', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Ramita de hierbabuena',
        'ingredients' => [
            ['Manzanilla o fino', 100, 'ml', 'bien frío'],
            ['Refresco de lima-limón', 200, 'ml', 'o gaseosa'],
            ['Hojas de hierbabuena', 4, 'hojas', 'opcional'],
        ],
        'steps' => [
            'Llena el vaso de hielo.',
            'Añade la manzanilla.',
            'Completa con el refresco y remueve suavemente.',
            'Decora con la hierbabuena.',
        ],
        'history' => 'Es la bebida de las ferias andaluzas, sobre todo de la Feria de Abril de Sevilla y la de Jerez. Se popularizó en los años 80 y 90 como una forma refrescante de aguantar el calor y la larga noche de feria con el vino de la tierra. Se sirve en jarras para compartir.',
        'utensils' => ['Jigger', 'Cuchara de bar'],
    ],
    [
        'name' => 'Kalimotxo',
        'tags' => ['Españoles', 'Vino', 'Refrescante'],
        'glass' => 'Vaso highball', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Rodaja de limón (opcional)',
        'ingredients' => [
            ['Vino tinto joven', 100, 'ml', null],
            ['Refresco de cola', 100, 'ml', 'bien frío'],
        ],
        'steps' => [
            'Llena el vaso de hielo.',
            'Añade el vino tinto.',
            'Completa con la cola y remueve una vez.',
        ],
        'history' => 'Según la versión más conocida, nació en 1972 en las fiestas del Puerto Viejo de Algorta (Getxo, Bizkaia): un grupo de amigos tenía que vender un vino que había salido malo y lo mezclaron con cola para disimularlo. El nombre uniría los apodos de dos de ellos, "Kalimero" y "Motxo".',
        'utensils' => ['Jigger', 'Cuchara de bar'],
    ],
    [
        'name' => 'Sangría',
        'tags' => ['Españoles', 'Vino', 'Afrutado'],
        'glass' => 'Jarra y vaso de vino', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'La propia fruta de la jarra',
        'ingredients' => [
            ['Vino tinto joven', 750, 'ml', 'una botella, para una jarra de 6 vasos'],
            ['Brandy', 50, 'ml', null],
            ['Licor de naranja', 30, 'ml', 'tipo triple seco'],
            ['Zumo de naranja', 100, 'ml', null],
            ['Azúcar', 4, 'cucharaditas', 'al gusto'],
            ['Naranja', 1, 'unidad', 'en trozos'],
            ['Limón', 1, 'unidad', 'en rodajas'],
            ['Melocotón o manzana', 1, 'unidad', 'en dados'],
            ['Canela en rama', 1, 'unidad', null],
            ['Gaseosa', 250, 'ml', 'justo antes de servir'],
        ],
        'steps' => [
            'En una jarra, mezcla el azúcar con el zumo de naranja, el brandy y el licor hasta disolverlo.',
            'Añade la fruta, la canela y el vino, y remueve.',
            'Déjala reposar en la nevera al menos 2 horas para que la fruta suelte sabor.',
            'Al servir, añade la gaseosa y hielo, y sirve con un poco de fruta en cada vaso.',
        ],
        'history' => 'Mezclar vino con fruta, especias y agua es una costumbre muy antigua en la Península. La sangría moderna se hizo famosa en todo el mundo en los años 60, cuando el turismo y la Feria Mundial de Nueva York de 1964 la convirtieron en símbolo de España.',
        'utensils' => ['Jigger', 'Cuchara de bar', 'Cuchillo y tabla', 'Exprimidor'],
    ],
    [
        'name' => 'Agua de Valencia',
        'tags' => ['Españoles', 'Espumoso', 'Afrutado'],
        'glass' => 'Jarra y copa de cóctel', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Rodaja de naranja',
        'ingredients' => [
            ['Cava', 375, 'ml', 'media botella, para una jarra de 4 copas'],
            ['Zumo de naranja', 375, 'ml', 'recién exprimido'],
            ['Vodka', 50, 'ml', null],
            ['Ginebra', 50, 'ml', null],
            ['Azúcar', 2, 'cucharaditas', 'opcional, según el dulzor de la naranja'],
        ],
        'steps' => [
            'Pon hielo en la jarra.',
            'Añade el zumo de naranja, el azúcar, el vodka y la ginebra, y remueve hasta disolver el azúcar.',
            'Completa con el cava muy frío y remueve con suavidad para no perder la burbuja.',
            'Sirve en copas con una rodaja de naranja.',
        ],
        'history' => 'Lo creó en 1959 Constante Gil en el Café Madrid de Valencia. Unos clientes vascos le pedían en broma "agua de Valencia" (es decir, zumo de naranja) y él les preparó esta mezcla de naranja con cava. Hoy es la bebida más típica de la ciudad.',
        'utensils' => ['Jigger', 'Cuchara de bar', 'Exprimidor', 'Cuchillo y tabla'],
    ],
    [
        'name' => 'Carajillo',
        'tags' => ['Españoles', 'Café', 'Brandy'],
        'glass' => 'Vaso de carajillo o vaso old fashioned', 'technique' => 'build', 'ice' => 'Sin hielo en el vaso',
        'garnish' => 'Piel de limón (opcional)',
        'ingredients' => [
            ['Café espresso', 30, 'ml', 'recién hecho'],
            ['Brandy', 30, 'ml', 'o ron, anís o whisky'],
            ['Azúcar', 1, 'cucharaditas', 'opcional'],
        ],
        'steps' => [
            'Calienta el brandy con el azúcar (con el vapor de la cafetera o flambeándolo con cuidado si lo haces "quemado").',
            'Añade el café espresso recién hecho.',
            'Remueve y sirve enseguida.',
            'Versión fría (muy de moda): agita 30 ml de espresso y 45 ml de Licor 43 con hielo y sírvelo sobre hielo.',
        ],
        'history' => 'Es el café "con algo" clásico de los bares españoles. Una leyenda muy repetida dice que viene de los soldados españoles en Cuba, que mezclaban café con ron para tener "coraje" (de ahí "corajillo"). La versión fría con Licor 43 se ha hecho muy popular en México y en las barras de cócteles.',
        'utensils' => ['Jigger', 'Cuchara de bar', 'Coctelera'],
    ],

    // ---------------------------------------------------------------- Imprescindible
    [
        'name' => 'Gin Tonic',
        'tags' => ['Internacionales', 'Ginebra', 'Refrescante'],
        'glass' => 'Copa balón', 'technique' => 'build', 'ice' => 'Cubos',
        'garnish' => 'Piel de lima o limón (y botánicos al gusto: enebro, pimienta rosa, pepino…)',
        'ingredients' => [
            ['Ginebra', 50, 'ml', null],
            ['Tónica', 200, 'ml', 'bien fría'],
        ],
        'steps' => [
            'Llena la copa de hielo y remueve para enfriarla; tira el agua que suelte.',
            'Añade la ginebra.',
            'Vierte la tónica despacio, deslizándola por la cuchara de bar para conservar la burbuja.',
            'Remueve una sola vez y perfuma con la piel del cítrico.',
        ],
        'history' => 'Los soldados británicos en la India del siglo XIX tomaban quinina contra la malaria y la disolvían en agua con azúcar y ginebra para hacerla más llevadera. En España vivió un "boom" a partir de los años 2000, con la copa balón, mucho hielo y decenas de ginebras y botánicos.',
        'utensils' => ['Jigger', 'Cuchara de bar', 'Pelador'],
    ],
];
