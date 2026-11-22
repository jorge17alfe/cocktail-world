-- Biblioteca de Cocktail World · library_batch_3 (15 cócteles)
-- Generado con database/sql/build_library_sql.php. Solo añade los que no existen.
SET NAMES utf8mb4;
START TRANSACTION;

-- Shirley Temple
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Shirley Temple', 'Vaso highball', 'build', 'Cubos', 'Cereza al marrasquino y rodaja de naranja', 'Es probablemente el cóctel sin alcohol más famoso del mundo. Se creó en los años 30 para la niña actriz Shirley Temple, que acompañaba a los adultos en restaurantes de Hollywood y quería algo "de mayores". Varios locales se atribuyen su invención.', '["Llena el vaso de hielo.","Añade el ginger ale y la lima.","Vierte la granadina por encima: caerá al fondo y dará el degradado rojo.","Decora con la cereza y la naranja."]', '["Sin alcohol","Clásico","Refrescante"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Shirley Temple');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ginger ale' AS name, 150 AS amount, 'ml' AS unit, 'o refresco de lima-limón' AS note, 0 AS ord
  UNION ALL SELECT 'Granadina', 15, 'ml', NULL, 1
  UNION ALL SELECT 'Zumo de lima', 10, 'ml', 'opcional', 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Cuchillo y tabla');

-- Roy Rogers
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Roy Rogers', 'Vaso highball', 'build', 'Cubos', 'Cereza al marrasquino', 'Es el "hermano" del Shirley Temple, pensado para los niños que no querían algo tan dulce. Toma el nombre de Roy Rogers, el famoso actor de películas del Oeste de los años 40 y 50.', '["Llena el vaso de hielo.","Añade la cola.","Vierte la granadina y remueve suavemente.","Decora con una cereza."]', '["Sin alcohol","Clásico","Refrescante"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Roy Rogers');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Refresco de cola' AS name, 180 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Granadina', 15, 'ml', NULL, 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar');

-- San Francisco
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'San Francisco', 'Vaso highball', 'shake', 'Cubos', 'Rodaja de naranja y cereza', 'Es el cóctel sin alcohol más pedido en España, imprescindible en bodas, comuniones y chiringuitos. Su origen no está documentado y, pese al nombre, no se relaciona con la ciudad estadounidense. Cada bar tiene su proporción de zumos; esta es una de las más habituales.', '["Agita los zumos en la coctelera con hielo.","Sirve en el vaso con hielo nuevo.","Vierte la granadina por encima para que baje formando el degradado.","Decora con la naranja y la cereza."]', '["Sin alcohol","Clásico","Afrutado"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'San Francisco');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Zumo de naranja' AS name, 60 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de piña', 60, 'ml', NULL, 1
  UNION ALL SELECT 'Zumo de melocotón', 60, 'ml', NULL, 2
  UNION ALL SELECT 'Zumo de limón', 10, 'ml', 'recién exprimido', 3
  UNION ALL SELECT 'Granadina', 15, 'ml', NULL, 4
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Exprimidor', 'Pajita');

-- Cenicienta
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Cenicienta', 'Vaso highball', 'shake', 'Cubos', 'Rodaja de naranja', 'También conocido como "Cinderella", es otro clásico de las fiestas y de las cartas sin alcohol de toda la vida. Se parece al San Francisco, pero sin melocotón y con un toque de soda que lo hace más ligero.', '["Agita los zumos y la granadina en la coctelera con hielo.","Sirve en el vaso con hielo nuevo.","Completa con un chorrito de soda.","Decora con la naranja."]', '["Sin alcohol","Clásico","Afrutado"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Cenicienta');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Zumo de naranja' AS name, 60 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de piña', 60, 'ml', NULL, 1
  UNION ALL SELECT 'Zumo de limón', 20, 'ml', 'recién exprimido', 2
  UNION ALL SELECT 'Granadina', 10, 'ml', NULL, 3
  UNION ALL SELECT 'Soda', NULL, NULL, 'hasta completar', 4
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Exprimidor', 'Pajita');

-- Pussyfoot
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Pussyfoot', 'Copa de cóctel', 'shake', 'Sin hielo en copa', 'Piel de naranja', 'Se creó a principios de los años 20 y su nombre es un guiño a William "Pussyfoot" Johnson, un famoso activista estadounidense contra el alcohol. Es uno de los cócteles sin alcohol más antiguos que se conocen.', '["Añade todos los ingredientes a la coctelera con hielo.","Agita con mucha fuerza 15 segundos.","Sirve con doble colado en la copa fría.","Perfuma con la piel de naranja."]', '["Sin alcohol","Clásico","Cítrico"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Pussyfoot');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Zumo de naranja' AS name, 60 AS amount, 'ml' AS unit, 'recién exprimido' AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de limón', 20, 'ml', 'recién exprimido', 1
  UNION ALL SELECT 'Zumo de lima', 20, 'ml', 'recién exprimido', 2
  UNION ALL SELECT 'Granadina', 10, 'ml', NULL, 3
  UNION ALL SELECT 'Yema de huevo', 1, 'unidad', 'opcional, le da textura', 4
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor');

-- Arnold Palmer
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Arnold Palmer', 'Vaso highball', 'build', 'Cubos', 'Rodaja de limón', 'Toma el nombre del golfista estadounidense Arnold Palmer, que solía pedir esta mezcla de té helado y limonada en los años 60. Se popularizó tanto que hoy se sirve en Estados Unidos simplemente pidiéndolo por su nombre.', '["Llena el vaso de hielo.","Añade el té frío y la limonada a partes iguales.","Remueve y decora con el limón."]', '["Sin alcohol","Clásico","Refrescante"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Arnold Palmer');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Té negro frío' AS name, 100 AS amount, 'ml' AS unit, 'infusionado y enfriado' AS note, 0 AS ord
  UNION ALL SELECT 'Limonada', 100, 'ml', 'mejor casera', 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar');

-- Virgin Mojito
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Virgin Mojito', 'Vaso highball', 'muddle', 'Hielo picado', 'Ramita de hierbabuena y rodaja de lima', 'Es la versión sin ron del Mojito cubano, también llamada "Nojito". Mantiene todo lo que hace refrescante al original: la hierbabuena, la lima y la burbuja. Con ginger ale en lugar de soda queda más aromático.', '["Presiona suavemente la hierbabuena con la lima y el sirope en el vaso, sin romperla.","Llena el vaso de hielo picado.","Completa con la soda y remueve de abajo arriba.","Decora con la hierbabuena y la lima."]', '["Sin alcohol","Virgin","Refrescante"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Virgin Mojito');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Hierbabuena' AS name, 8 AS amount, 'hojas' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de lima', 25, 'ml', 'recién exprimido', 1
  UNION ALL SELECT 'Sirope de azúcar', 20, 'ml', 'o 2 cucharaditas de azúcar', 2
  UNION ALL SELECT 'Soda', 120, 'ml', 'o ginger ale', 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Mortero de bar', 'Jigger', 'Cuchara de bar', 'Exprimidor', 'Pajita');

-- Virgin Piña Colada
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Virgin Piña Colada', 'Vaso hurricane o highball', 'blend', 'Hielo picado', 'Triángulo de piña y cereza', 'Es la Piña Colada de Puerto Rico sin ron, conocida también como "Piña Colada virgen". La crema de coco y la piña son las protagonistas, así que mantiene todo el sabor tropical del original.', '["Pon todos los ingredientes en la batidora con el hielo.","Bate hasta que quede cremoso y sin trozos de hielo.","Sirve en el vaso y decora con la piña y la cereza."]', '["Sin alcohol","Virgin","Cremoso"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Virgin Piña Colada');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Zumo de piña' AS name, 120 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Crema de coco', 50, 'ml', NULL, 1
  UNION ALL SELECT 'Zumo de lima', 10, 'ml', 'opcional', 2
  UNION ALL SELECT 'Hielo picado', 1, 'unidad', 'un vaso', 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Batidora de vaso', 'Jigger', 'Cuchillo y tabla', 'Pajita');

-- Virgin Mary
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Virgin Mary', 'Vaso highball', 'rolling', 'Cubos', 'Rama de apio y gajo de limón', 'Es el Bloody Mary sin vodka. Al no llevar alcohol, el sabor depende de un buen equilibrio de especias, así que cada bar suele tener su propia mezcla. Ojo con las alergias: la salsa Worcestershire lleva anchoa.', '["Pon todos los ingredientes en un vaso con hielo.","Pásalo a otro vaso varias veces (\\"rolling\\") para mezclar sin agitar.","Sirve en el vaso con hielo.","Decora con el apio y el limón."]', '["Sin alcohol","Virgin","Salado"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Virgin Mary');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Zumo de tomate' AS name, 150 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de limón', 15, 'ml', 'recién exprimido', 1
  UNION ALL SELECT 'Salsa Worcestershire', 3, 'golpes', 'contiene anchoa', 2
  UNION ALL SELECT 'Tabasco', 2, 'golpes', 'al gusto', 3
  UNION ALL SELECT 'Sal de apio y pimienta negra', 1, 'chorrito', 'una pizca', 4
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Exprimidor', 'Cuchillo y tabla');

-- Virgin Mule
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Virgin Mule', 'Taza de cobre', 'build', 'Cubos', 'Rodaja de lima y ramita de hierbabuena', 'Es el Moscow Mule sin vodka. La ginger beer, picante y aromática, hace casi todo el trabajo, así que conviene usar una de calidad. Servido en su taza de cobre, nadie diría que no lleva alcohol.', '["Llena la taza de hielo.","Añade la lima y completa con la ginger beer.","Remueve suavemente.","Decora con la lima y la hierbabuena."]', '["Sin alcohol","Virgin","Refrescante"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Virgin Mule');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ginger beer' AS name, 150 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de lima', 20, 'ml', 'recién exprimido', 1
  UNION ALL SELECT 'Hierbabuena', 4, 'hojas', 'opcional', 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Exprimidor', 'Cuchillo y tabla');

-- Virgin Sunrise
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Virgin Sunrise', 'Vaso highball', 'build', 'Cubos', 'Rodaja de naranja y cereza', 'Es el Tequila Sunrise sin tequila. Su gracia está en el degradado de rojo a naranja, que recuerda a un amanecer. Es sencillo, vistoso y gusta mucho a los niños.', '["Llena el vaso de hielo y añade el zumo de naranja.","Vierte la granadina despacio por el borde: se irá al fondo.","No remuevas, para que se vea el \\"amanecer\\" de colores.","Decora con la naranja y la cereza."]', '["Sin alcohol","Virgin","Afrutado"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Virgin Sunrise');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Zumo de naranja' AS name, 150 AS amount, 'ml' AS unit, 'recién exprimido' AS note, 0 AS ord
  UNION ALL SELECT 'Granadina', 15, 'ml', NULL, 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Exprimidor', 'Cuchillo y tabla');

-- Safe Sex on the Beach
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Safe Sex on the Beach', 'Vaso highball', 'shake', 'Cubos', 'Rodaja de naranja', 'Es la versión sin alcohol del Sex on the Beach, un cóctel que se hizo famoso en los años 80. Sin vodka ni licor de melocotón, el arándano y el melocotón mantienen su sabor afrutado y su color.', '["Agita todos los zumos en la coctelera con hielo.","Sirve en el vaso con hielo nuevo.","Decora con la naranja."]', '["Sin alcohol","Virgin","Afrutado"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Safe Sex on the Beach');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Zumo de arándano rojo' AS name, 60 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de naranja', 60, 'ml', NULL, 1
  UNION ALL SELECT 'Zumo de melocotón', 40, 'ml', NULL, 2
  UNION ALL SELECT 'Zumo de lima', 10, 'ml', 'opcional', 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Pajita');

-- Daiquirí de fresa sin alcohol
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Daiquirí de fresa sin alcohol', 'Copa de cóctel', 'blend', 'Hielo picado', 'Fresa en el borde', 'Es la versión frozen y sin ron del Daiquirí de fresa, que se popularizó en la segunda mitad del siglo XX. Con fresas congeladas queda más espeso y no hace falta tanto hielo.', '["Pon las fresas, la lima, el sirope y el hielo en la batidora.","Bate hasta que quede una textura granizada.","Sirve en la copa y decora con una fresa."]', '["Sin alcohol","Virgin","Afrutado"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Daiquirí de fresa sin alcohol');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Fresas' AS name, 6 AS amount, 'unidad' AS unit, 'frescas o congeladas' AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de lima', 25, 'ml', 'recién exprimido', 1
  UNION ALL SELECT 'Sirope de azúcar', 20, 'ml', NULL, 2
  UNION ALL SELECT 'Hielo picado', 1, 'unidad', 'medio vaso', 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Batidora de vaso', 'Jigger', 'Exprimidor', 'Cuchillo y tabla');

-- Espresso Tonic
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Espresso Tonic', 'Vaso highball', 'build', 'Cubos', 'Piel de naranja', 'Nació en Suecia hacia 2007, en el mundo de las cafeterías de especialidad, y se ha extendido por todo el mundo como bebida de verano. El amargor de la tónica y las notas del café combinan sorprendentemente bien.', '["Llena el vaso de hielo y añade la tónica.","Vierte el espresso despacio por encima: quedará flotando en capas.","Perfuma con la piel de naranja."]', '["Sin alcohol","Moderno","Café"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Espresso Tonic');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Tónica' AS name, 120 AS amount, 'ml' AS unit, 'bien fría' AS note, 0 AS ord
  UNION ALL SELECT 'Café espresso', 30, 'ml', 'recién hecho', 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Pelador');

-- Limonada de fresa y albahaca
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Limonada de fresa y albahaca', 'Vaso highball', 'muddle', 'Cubos', 'Fresa y hoja de albahaca', 'Es una limonada de autor de las que hoy se ven en muchas cartas sin alcohol. La fresa aporta dulzor y color, y la albahaca un toque fresco y herbal que la hace diferente.', '["Machaca las fresas con la albahaca y el sirope en la coctelera.","Añade el limón y hielo, y agita unos segundos.","Cuela con doble colado en el vaso con hielo nuevo.","Completa con soda y decora con la fresa y la albahaca."]', '["Sin alcohol","Moderno","Refrescante"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Limonada de fresa y albahaca');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Fresas' AS name, 3 AS amount, 'unidad' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Albahaca', 4, 'hojas', NULL, 1
  UNION ALL SELECT 'Zumo de limón', 30, 'ml', 'recién exprimido', 2
  UNION ALL SELECT 'Sirope de azúcar', 20, 'ml', NULL, 3
  UNION ALL SELECT 'Soda', 100, 'ml', NULL, 4
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Mortero de bar', 'Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor');

COMMIT;
