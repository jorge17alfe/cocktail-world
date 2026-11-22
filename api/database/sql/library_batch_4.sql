-- Biblioteca de Cocktail World · library_batch_4 (20 cócteles)
-- Generado con database/sql/build_library_sql.php. Solo añade los que no existen.
SET NAMES utf8mb4;
START TRANSACTION;

-- Hugo
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Hugo', 'Copa de vino', 'build', 'Cubos', 'Ramita de menta y rodaja de lima', 'Nació en 2005 en el Tirol del Sur (norte de Italia), de la mano del barman Roland Gruber, como alternativa más ligera y floral al Spritz de Aperol. La primera versión usaba sirope de melisa; el de flor de saúco acabó imponiéndose y lo hizo famoso en toda Europa.', '["Pon la menta en la copa y presiónala un poco con la cuchara para que suelte aroma, sin romperla.","Añade el saúco y la lima, y llena la copa de hielo.","Vierte el prosecco y completa con la soda.","Remueve suavemente de abajo arriba y decora con menta."]', '["Aperitivo","Spritz","Espumoso"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Hugo');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Prosecco' AS name, 120 AS amount, 'ml' AS unit, 'bien frío' AS note, 0 AS ord
  UNION ALL SELECT 'Licor o sirope de flor de saúco', 20, 'ml', 'por ejemplo St-Germain', 1
  UNION ALL SELECT 'Soda', 30, 'ml', NULL, 2
  UNION ALL SELECT 'Hojas de menta', 8, 'hojas', NULL, 3
  UNION ALL SELECT 'Lima', 1, 'unidad', 'en rodajas', 4
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Cuchillo y tabla');

-- St-Germain Spritz
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'St-Germain Spritz', 'Copa de vino', 'build', 'Cubos', 'Piel de limón', 'El licor St-Germain, hecho con flores de saúco recogidas a mano en primavera, se lanzó en 2007 y en pocos años se volvió imprescindible en las barras. Su receta de "spritz" con espumoso y soda es la forma más sencilla y popular de tomarlo.', '["Llena la copa de hielo.","Añade el St-Germain y después el espumoso.","Completa con la soda y remueve suavemente.","Exprime la piel de limón encima y déjala dentro."]', '["Aperitivo","Spritz","Espumoso"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'St-Germain Spritz');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Prosecco o cava' AS name, 60 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'St-Germain', 40, 'ml', 'licor de flor de saúco', 1
  UNION ALL SELECT 'Soda', 60, 'ml', NULL, 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Pelador');

-- Limoncello Spritz
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Limoncello Spritz', 'Copa de vino', 'build', 'Cubos', 'Rodaja de limón y hojas de menta o albahaca', 'El limoncello es el licor de piel de limón típico de la costa de Amalfi, Sorrento y Capri, que tradicionalmente se toma solo y helado después de comer. Su versión spritz es una creación reciente que lo convierte en un aperitivo veraniego, más dulce y cítrico que el de Aperol.', '["Llena la copa de hielo.","Añade el limoncello y después el prosecco.","Completa con la soda y remueve suavemente.","Decora con el limón y las hierbas."]', '["Aperitivo","Spritz","Cítrico"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Limoncello Spritz');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Prosecco' AS name, 90 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Limoncello', 60, 'ml', 'bien frío', 1
  UNION ALL SELECT 'Soda', 30, 'ml', NULL, 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Cuchillo y tabla');

-- Campari Spritz
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Campari Spritz', 'Copa de vino', 'build', 'Cubos', 'Rodaja de naranja', 'Es el spritz preferido en Milán, la ciudad del Campari. Tiene la misma estructura que el Spritz de Aperol, pero el Campari lo hace más amargo, más intenso y de un rojo más oscuro.', '["Llena la copa de hielo.","Añade el prosecco y después el Campari.","Completa con la soda.","Remueve suavemente y decora con la naranja."]', '["Aperitivo","Spritz","Amargo"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Campari Spritz');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Prosecco' AS name, 90 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Campari', 60, 'ml', NULL, 1
  UNION ALL SELECT 'Soda', 30, 'ml', NULL, 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Cuchillo y tabla');

-- Lillet Tonic
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Lillet Tonic', 'Copa de vino', 'build', 'Cubos', 'Rodaja de pepino, fresa y hojas de menta', 'El Lillet es un aperitivo de vino aromatizado con frutas y quinina que se elabora desde 1872 en Podensac, cerca de Burdeos. Con tónica, fruta y hierbas se convirtió en uno de los aperitivos de moda en Francia.', '["Llena la copa de hielo y coloca la fruta y la menta.","Añade el Lillet.","Completa con la tónica y remueve suavemente."]', '["Aperitivo","Spritz","Refrescante"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Lillet Tonic');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Lillet Blanc' AS name, 50 AS amount, 'ml' AS unit, 'o Lillet Rosé' AS note, 0 AS ord
  UNION ALL SELECT 'Tónica', 100, 'ml', NULL, 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Cuchillo y tabla');

-- Negroni Sbagliato
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Negroni Sbagliato', 'Vaso old fashioned', 'build', 'Bloque grande o cubos', 'Media rodaja de naranja', '"Sbagliato" significa "equivocado" en italiano. Según la historia del Bar Basso de Milán, a finales de los años 60 un barman cogió por error una botella de espumoso en lugar de la ginebra al preparar un Negroni. El resultado gustó tanto que se quedó en la carta.', '["Pon el hielo en el vaso.","Añade el Campari y el vermut y remueve unos segundos.","Completa con el prosecco y remueve una sola vez, con cuidado de no quitarle la burbuja.","Decora con la naranja."]', '["Aperitivo","Clásicos","Espumoso"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Negroni Sbagliato');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Campari' AS name, 30 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Vermut rojo', 30, 'ml', NULL, 1
  UNION ALL SELECT 'Prosecco', 30, 'ml', 'o más, al gusto', 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Cuchillo y tabla');

-- Garibaldi
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Garibaldi', 'Vaso highball', 'build', 'Cubos', 'Rodaja de naranja', 'Homenaje a Giuseppe Garibaldi, héroe de la unificación de Italia: el Campari representa el norte (Milán) y la naranja, el sur (Sicilia). La versión moderna con zumo batido y "esponjoso" la popularizaron bares de cócteles de Nueva York.', '["Llena el vaso de hielo y añade el Campari.","Exprime la naranja y bate el zumo unos segundos (con batidora o agitándolo fuerte) para que quede espumoso.","Vierte el zumo sobre el Campari.","Decora con la naranja."]', '["Aperitivo","Clásicos","Afrutado"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Garibaldi');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Campari' AS name, 45 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de naranja', 120, 'ml', 'recién exprimido', 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Exprimidor', 'Cuchillo y tabla');

-- Bicicletta
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Bicicletta', 'Copa de vino', 'build', 'Cubos', 'Rodaja de limón o naranja', 'Un aperitivo de bar de pueblo del norte de Italia, anterior a la moda del spritz con espumoso. Cuenta la leyenda que su nombre viene de los señores mayores que, después de unos cuantos, volvían a casa en bicicleta haciendo eses.', '["Llena la copa de hielo.","Añade el Campari y el vino.","Completa con la soda y remueve suavemente.","Decora con el cítrico."]', '["Aperitivo","Clásicos","Amargo"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Bicicletta');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Campari' AS name, 45 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Vino blanco seco', 90, 'ml', 'bien frío', 1
  UNION ALL SELECT 'Soda', 30, 'ml', NULL, 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Cuchillo y tabla');

-- Kir
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Kir', 'Copa de vino', 'build', 'Sin hielo en copa', 'Sin decoración', 'Lleva el nombre de Félix Kir, sacerdote y alcalde de Dijon tras la Segunda Guerra Mundial, que lo servía en las recepciones oficiales para promocionar dos productos de su región: el vino blanco de Borgoña y el licor de cassis.', '["Vierte el crème de cassis en la copa.","Completa con el vino blanco muy frío.","Remueve una vez con la cuchara."]', '["Aperitivo","IBA","Clásicos"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Kir');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Vino blanco seco' AS name, 90 AS amount, 'ml' AS unit, 'tradicionalmente aligoté de Borgoña, bien frío' AS note, 0 AS ord
  UNION ALL SELECT 'Crème de cassis', 10, 'ml', 'licor de grosella negra', 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar');

-- Kir Royal
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Kir Royal', 'Copa flauta', 'build', 'Sin hielo en copa', 'Una frambuesa o mora (opcional)', 'Es la versión "de lujo" del Kir: se cambia el vino blanco por champán. Se convirtió en el aperitivo de celebración clásico de Francia.', '["Vierte el crème de cassis en la copa.","Completa despacio con el champán, inclinando un poco la copa para no perder burbuja.","Decora con la fruta si quieres."]', '["Aperitivo","IBA","Espumoso"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Kir Royal');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Champán' AS name, 120 AS amount, 'ml' AS unit, 'o cava, bien frío' AS note, 0 AS ord
  UNION ALL SELECT 'Crème de cassis', 10, 'ml', NULL, 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger');

-- Rossini
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Rossini', 'Copa flauta', 'build', 'Sin hielo en copa', 'Media fresa en el borde', 'Es "primo" del Bellini, que se hace con melocotón. Lleva el nombre del compositor italiano Gioachino Rossini, autor de "El barbero de Sevilla", y es uno de los aperitivos con prosecco más populares de Italia.', '["Pon el puré de fresa en la copa.","Añade el prosecco despacio, removiendo suavemente para que se mezcle sin perder burbuja.","Decora con la fresa."]', '["Aperitivo","Clásicos","Espumoso"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Rossini');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Puré de fresa' AS name, 50 AS amount, 'ml' AS unit, 'fresas trituradas y coladas, con un poco de azúcar' AS note, 0 AS ord
  UNION ALL SELECT 'Prosecco', 100, 'ml', 'bien frío', 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Batidora de vaso', 'Colador fino', 'Jigger', 'Cuchara de bar');

-- Aperol Sour
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Aperol Sour', 'Vaso old fashioned', 'shake', 'Cubos', 'Piel de naranja', 'Una forma moderna de tomar Aperol fuera del spritz: aplicar la fórmula clásica "sour" (licor, cítrico y dulce). El resultado es suave, afrutado y con un toque amargo, muy fácil de beber.', '["Si usas clara, agita primero todo sin hielo unos segundos para montar la espuma.","Añade hielo a la coctelera y agita con fuerza.","Cuela sobre hielo nuevo en el vaso.","Exprime la piel de naranja encima y úsala de decoración."]', '["Aperitivo","Modernos","Cítrico"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Aperol Sour');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Aperol' AS name, 50 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de limón', 25, 'ml', 'recién exprimido', 1
  UNION ALL SELECT 'Sirope simple', 15, 'ml', NULL, 2
  UNION ALL SELECT 'Clara de huevo', 1, 'unidad', 'opcional, para la espuma', 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Exprimidor', 'Pelador');

-- Amaretto Sour
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Amaretto Sour', 'Vaso old fashioned', 'shake', 'Cubos', 'Piel de limón y cereza', 'Fue muy popular en los años 70 como cóctel dulce y fácil. Años después, bármanes como Jeffrey Morgenthaler lo "rescataron" añadiendo un poco de bourbon y zumo fresco para que no fuera tan empalagoso. Esa es la versión que se sirve hoy en las buenas barras.', '["Agita primero todo sin hielo unos segundos para montar la clara.","Añade hielo y agita con fuerza.","Cuela sobre hielo nuevo en el vaso.","Decora con la piel de limón y la cereza."]', '["Licores","Modernos","Cítrico"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Amaretto Sour');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Amaretto' AS name, 45 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Bourbon', 20, 'ml', 'opcional, equilibra el dulzor', 1
  UNION ALL SELECT 'Zumo de limón', 30, 'ml', 'recién exprimido', 2
  UNION ALL SELECT 'Sirope simple', 1, 'cucharaditas', NULL, 3
  UNION ALL SELECT 'Clara de huevo', 1, 'unidad', 'opcional', 4
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Exprimidor', 'Pelador');

-- Tinto de verano
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Tinto de verano', 'Vaso highball', 'build', 'Cubos', 'Rodaja de limón', 'Se atribuye a la Venta de Vargas, en Córdoba, a principios del siglo XX, donde se servía a los clientes como "un Vargas". Hoy es la bebida de terraza por excelencia del verano en España, más ligera y sencilla que la sangría.', '["Llena el vaso de hielo.","Añade el vino tinto.","Completa con la gaseosa o el refresco de limón.","Remueve una vez y decora con el limón."]', '["Españoles","Vino","Refrescante"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Tinto de verano');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Vino tinto joven' AS name, 100 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Gaseosa', 100, 'ml', 'o refresco de limón, al gusto', 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Cuchillo y tabla');

-- Rebujito
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Rebujito', 'Vaso highball', 'build', 'Cubos', 'Ramita de hierbabuena', 'Es la bebida de las ferias andaluzas, sobre todo de la Feria de Abril de Sevilla y la de Jerez. Se popularizó en los años 80 y 90 como una forma refrescante de aguantar el calor y la larga noche de feria con el vino de la tierra. Se sirve en jarras para compartir.', '["Llena el vaso de hielo.","Añade la manzanilla.","Completa con el refresco y remueve suavemente.","Decora con la hierbabuena."]', '["Españoles","Vino","Refrescante"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Rebujito');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Manzanilla o fino' AS name, 100 AS amount, 'ml' AS unit, 'bien frío' AS note, 0 AS ord
  UNION ALL SELECT 'Refresco de lima-limón', 200, 'ml', 'o gaseosa', 1
  UNION ALL SELECT 'Hojas de hierbabuena', 4, 'hojas', 'opcional', 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar');

-- Kalimotxo
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Kalimotxo', 'Vaso highball', 'build', 'Cubos', 'Rodaja de limón (opcional)', 'Según la versión más conocida, nació en 1972 en las fiestas del Puerto Viejo de Algorta (Getxo, Bizkaia): un grupo de amigos tenía que vender un vino que había salido malo y lo mezclaron con cola para disimularlo. El nombre uniría los apodos de dos de ellos, "Kalimero" y "Motxo".', '["Llena el vaso de hielo.","Añade el vino tinto.","Completa con la cola y remueve una vez."]', '["Españoles","Vino","Refrescante"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Kalimotxo');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Vino tinto joven' AS name, 100 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Refresco de cola', 100, 'ml', 'bien frío', 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar');

-- Sangría
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Sangría', 'Jarra y vaso de vino', 'build', 'Cubos', 'La propia fruta de la jarra', 'Mezclar vino con fruta, especias y agua es una costumbre muy antigua en la Península. La sangría moderna se hizo famosa en todo el mundo en los años 60, cuando el turismo y la Feria Mundial de Nueva York de 1964 la convirtieron en símbolo de España.', '["En una jarra, mezcla el azúcar con el zumo de naranja, el brandy y el licor hasta disolverlo.","Añade la fruta, la canela y el vino, y remueve.","Déjala reposar en la nevera al menos 2 horas para que la fruta suelte sabor.","Al servir, añade la gaseosa y hielo, y sirve con un poco de fruta en cada vaso."]', '["Españoles","Vino","Afrutado"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Sangría');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Vino tinto joven' AS name, 750 AS amount, 'ml' AS unit, 'una botella, para una jarra de 6 vasos' AS note, 0 AS ord
  UNION ALL SELECT 'Brandy', 50, 'ml', NULL, 1
  UNION ALL SELECT 'Licor de naranja', 30, 'ml', 'tipo triple seco', 2
  UNION ALL SELECT 'Zumo de naranja', 100, 'ml', NULL, 3
  UNION ALL SELECT 'Azúcar', 4, 'cucharaditas', 'al gusto', 4
  UNION ALL SELECT 'Naranja', 1, 'unidad', 'en trozos', 5
  UNION ALL SELECT 'Limón', 1, 'unidad', 'en rodajas', 6
  UNION ALL SELECT 'Melocotón o manzana', 1, 'unidad', 'en dados', 7
  UNION ALL SELECT 'Canela en rama', 1, 'unidad', NULL, 8
  UNION ALL SELECT 'Gaseosa', 250, 'ml', 'justo antes de servir', 9
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Cuchillo y tabla', 'Exprimidor');

-- Agua de Valencia
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Agua de Valencia', 'Jarra y copa de cóctel', 'build', 'Cubos', 'Rodaja de naranja', 'Lo creó en 1959 Constante Gil en el Café Madrid de Valencia. Unos clientes vascos le pedían en broma "agua de Valencia" (es decir, zumo de naranja) y él les preparó esta mezcla de naranja con cava. Hoy es la bebida más típica de la ciudad.', '["Pon hielo en la jarra.","Añade el zumo de naranja, el azúcar, el vodka y la ginebra, y remueve hasta disolver el azúcar.","Completa con el cava muy frío y remueve con suavidad para no perder la burbuja.","Sirve en copas con una rodaja de naranja."]', '["Españoles","Espumoso","Afrutado"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Agua de Valencia');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Cava' AS name, 375 AS amount, 'ml' AS unit, 'media botella, para una jarra de 4 copas' AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de naranja', 375, 'ml', 'recién exprimido', 1
  UNION ALL SELECT 'Vodka', 50, 'ml', NULL, 2
  UNION ALL SELECT 'Ginebra', 50, 'ml', NULL, 3
  UNION ALL SELECT 'Azúcar', 2, 'cucharaditas', 'opcional, según el dulzor de la naranja', 4
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Exprimidor', 'Cuchillo y tabla');

-- Carajillo
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Carajillo', 'Vaso de carajillo o vaso old fashioned', 'build', 'Sin hielo en el vaso', 'Piel de limón (opcional)', 'Es el café "con algo" clásico de los bares españoles. Una leyenda muy repetida dice que viene de los soldados españoles en Cuba, que mezclaban café con ron para tener "coraje" (de ahí "corajillo"). La versión fría con Licor 43 se ha hecho muy popular en México y en las barras de cócteles.', '["Calienta el brandy con el azúcar (con el vapor de la cafetera o flambeándolo con cuidado si lo haces \\"quemado\\").","Añade el café espresso recién hecho.","Remueve y sirve enseguida.","Versión fría (muy de moda): agita 30 ml de espresso y 45 ml de Licor 43 con hielo y sírvelo sobre hielo."]', '["Españoles","Café","Brandy"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Carajillo');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Café espresso' AS name, 30 AS amount, 'ml' AS unit, 'recién hecho' AS note, 0 AS ord
  UNION ALL SELECT 'Brandy', 30, 'ml', 'o ron, anís o whisky', 1
  UNION ALL SELECT 'Azúcar', 1, 'cucharaditas', 'opcional', 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Coctelera');

-- Gin Tonic
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Gin Tonic', 'Copa balón', 'build', 'Cubos', 'Piel de lima o limón (y botánicos al gusto: enebro, pimienta rosa, pepino…)', 'Los soldados británicos en la India del siglo XIX tomaban quinina contra la malaria y la disolvían en agua con azúcar y ginebra para hacerla más llevadera. En España vivió un "boom" a partir de los años 2000, con la copa balón, mucho hielo y decenas de ginebras y botánicos.', '["Llena la copa de hielo y remueve para enfriarla; tira el agua que suelte.","Añade la ginebra.","Vierte la tónica despacio, deslizándola por la cuchara de bar para conservar la burbuja.","Remueve una sola vez y perfuma con la piel del cítrico."]', '["Internacionales","Ginebra","Refrescante"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Gin Tonic');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ginebra' AS name, 50 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Tónica', 200, 'ml', 'bien fría', 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Pelador');

COMMIT;
