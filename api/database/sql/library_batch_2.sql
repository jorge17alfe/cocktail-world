-- Biblioteca de Cocktail World · library_batch_2 (20 cócteles)
-- Generado con database/sql/build_library_sql.php. Solo añade los que no existen.
SET NAMES utf8mb4;
START TRANSACTION;

-- Martinez
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Martinez', 'Copa de cóctel', 'stir', 'Sin hielo en copa', 'Piel de limón', 'Aparece en libros de cócteles estadounidenses de la década de 1880 y se considera el antecesor del Dry Martini. Era más dulce y aromático que su descendiente: más vermut, ginebra Old Tom y un toque de marrasquino. Su origen se disputa entre San Francisco y la ciudad californiana de Martinez.', '["Enfría la copa.","Añade todos los ingredientes al vaso mezclador con hielo.","Remueve unos 30 segundos.","Cuela en la copa fría y perfuma con la piel de limón."]', '["Clásicos","Ginebra","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Martinez');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ginebra' AS name, 45 AS amount, 'ml' AS unit, 'mejor Old Tom' AS note, 0 AS ord
  UNION ALL SELECT 'Vermut rojo', 45, 'ml', NULL, 1
  UNION ALL SELECT 'Licor de marrasquino', 1, 'cucharaditas', NULL, 2
  UNION ALL SELECT 'Orange bitters', 2, 'golpes', NULL, 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Vaso mezclador', 'Cuchara de bar', 'Colador Julep', 'Jigger', 'Pelador');

-- Vieux Carré
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Vieux Carré', 'Vaso old fashioned', 'stir', 'Bloque grande o cubos', 'Piel de limón y cereza al marrasquino', 'Lo creó Walter Bergeron en los años 30 en el bar del Hotel Monteleone de Nueva Orleans. "Vieux Carré" significa "barrio viejo" en francés, el nombre con el que se conoce al Barrio Francés de la ciudad. Mezcla los dos destilados de la historia de Nueva Orleans, el coñac francés y el whisky de centeno.', '["Añade todos los ingredientes al vaso mezclador con hielo.","Remueve unos 30 segundos.","Cuela sobre el vaso con hielo nuevo.","Decora con la piel de limón y la cereza."]', '["Clásicos","Whisky","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Vieux Carré');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Whisky de centeno (rye)' AS name, 30 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Coñac', 30, 'ml', NULL, 1
  UNION ALL SELECT 'Vermut rojo', 30, 'ml', NULL, 2
  UNION ALL SELECT 'Bénédictine', 1, 'cucharaditas', NULL, 3
  UNION ALL SELECT 'Peychaud''s bitters', 2, 'golpes', NULL, 4
  UNION ALL SELECT 'Angostura bitters', 2, 'golpes', NULL, 5
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Vaso mezclador', 'Cuchara de bar', 'Colador Julep', 'Jigger', 'Pelador');

-- Rob Roy
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Rob Roy', 'Copa de cóctel', 'stir', 'Sin hielo en copa', 'Cereza al marrasquino', 'Es el Manhattan hecho con whisky escocés. Se creó en el Waldorf-Astoria de Nueva York hacia 1894, con motivo del estreno de una opereta sobre Rob Roy MacGregor, el forajido escocés convertido en héroe popular.', '["Enfría la copa.","Añade los ingredientes al vaso mezclador con hielo.","Remueve 20-30 segundos.","Cuela en la copa fría y decora con la cereza."]', '["Clásicos","Whisky","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Rob Roy');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Whisky escocés' AS name, 45 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Vermut rojo', 25, 'ml', NULL, 1
  UNION ALL SELECT 'Angostura bitters', 1, 'golpes', NULL, 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Vaso mezclador', 'Cuchara de bar', 'Colador Julep', 'Jigger');

-- Corpse Reviver nº 2
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Corpse Reviver nº 2', 'Copa de cóctel', 'shake', 'Sin hielo en copa', 'Piel de naranja', 'Los "corpse revivers" ("resucitamuertos") eran tragos para la resaca de la mañana siguiente. Esta versión se hizo famosa con el libro del Savoy de Londres de 1930, en el que Harry Craddock advertía con humor que tomar varios seguidos tenía el efecto contrario. Lleva partes iguales y un toque de absenta.', '["Añade todos los ingredientes a la coctelera con hielo.","Agita con fuerza 10-15 segundos.","Sirve con doble colado en la copa fría.","Perfuma con la piel de naranja."]', '["Clásicos","Ginebra","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Corpse Reviver nº 2');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ginebra' AS name, 30 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Triple sec (Cointreau)', 30, 'ml', NULL, 1
  UNION ALL SELECT 'Lillet Blanc', 30, 'ml', NULL, 2
  UNION ALL SELECT 'Zumo de limón', 30, 'ml', 'recién exprimido', 3
  UNION ALL SELECT 'Absenta', 1, 'golpes', NULL, 4
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor');

-- White Lady
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'White Lady', 'Copa de cóctel', 'shake', 'Sin hielo en copa', 'Sin decoración (o piel de limón)', 'Harry MacElhone lo creó hacia 1919 en Londres con licor de menta, y más tarde lo rehízo con ginebra, que es la receta que ha llegado hasta hoy. También se hizo famoso en el bar del Savoy. Es la versión con ginebra de la familia del Sidecar. Algunos bares le añaden clara de huevo para darle espuma.', '["Añade todos los ingredientes a la coctelera con hielo.","Agita con fuerza 10-15 segundos.","Sirve con doble colado en la copa fría."]', '["Clásicos","Ginebra","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'White Lady');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ginebra' AS name, 40 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Triple sec (Cointreau)', 30, 'ml', NULL, 1
  UNION ALL SELECT 'Zumo de limón', 20, 'ml', 'recién exprimido', 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor');

-- Ramos Gin Fizz
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Ramos Gin Fizz', 'Vaso highball', 'shake', 'Sin hielo en el vaso', 'Sin decoración', 'Lo creó Henry C. Ramos en 1888 en Nueva Orleans. Se agitaba durante tanto tiempo que su bar llegó a tener una fila de "shaker boys", chicos que se pasaban la coctelera unos a otros. Su espuma alta y sedosa lo hace inconfundible, y es uno de los cócteles que más trabajo dan en la barra.', '["Añade todo menos la soda a la coctelera sin hielo y agita en seco para montar la clara.","Añade hielo y agita con mucha fuerza durante al menos 30 segundos.","Cuela en el vaso frío, sin hielo.","Deja reposar un momento y completa con soda poco a poco para que suba la espuma."]', '["Clásicos","Ginebra","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Ramos Gin Fizz');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ginebra' AS name, 45 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de limón', 15, 'ml', 'recién exprimido', 1
  UNION ALL SELECT 'Zumo de lima', 15, 'ml', 'recién exprimido', 2
  UNION ALL SELECT 'Sirope de azúcar', 30, 'ml', NULL, 3
  UNION ALL SELECT 'Nata líquida', 60, 'ml', NULL, 4
  UNION ALL SELECT 'Clara de huevo', 1, 'unidad', NULL, 5
  UNION ALL SELECT 'Agua de azahar', 3, 'golpes', NULL, 6
  UNION ALL SELECT 'Soda', NULL, NULL, 'hasta completar', 7
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor');

-- Brandy Alexander
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Brandy Alexander', 'Copa de cóctel', 'shake', 'Sin hielo en copa', 'Nuez moscada rallada', 'El "Alexander" original, de principios del siglo XX en Nueva York, se hacía con ginebra. La versión con coñac se hizo más popular y acabó siendo la más conocida. Es un cóctel de sobremesa, cremoso y dulce, pensado como postre.', '["Añade todos los ingredientes a la coctelera con hielo.","Agita con fuerza 10-15 segundos.","Sirve con doble colado en la copa fría.","Ralla un poco de nuez moscada por encima."]', '["Clásicos","Brandy","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Brandy Alexander');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Coñac' AS name, 30 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Crema de cacao oscura', 30, 'ml', NULL, 1
  UNION ALL SELECT 'Nata líquida', 30, 'ml', NULL, 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino');

-- Hanky Panky
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Hanky Panky', 'Copa de cóctel', 'stir', 'Sin hielo en copa', 'Piel de naranja', 'Lo creó Ada Coleman, jefa del American Bar del Savoy de Londres a principios del siglo XX y una de las primeras grandes bartenders. Lo preparó para el actor Charles Hawtrey, que le pidió algo "con chispa"; al probarlo exclamó que aquello era "el auténtico hanky-panky", y le quedó el nombre.', '["Añade los ingredientes al vaso mezclador con hielo.","Remueve unos 30 segundos.","Cuela en la copa fría.","Perfuma con la piel de naranja."]', '["Clásicos","Ginebra","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Hanky Panky');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ginebra' AS name, 45 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Vermut rojo', 45, 'ml', NULL, 1
  UNION ALL SELECT 'Fernet-Branca', 7.5, 'ml', NULL, 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Vaso mezclador', 'Cuchara de bar', 'Colador Julep', 'Jigger', 'Pelador');

-- Bee's Knees
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Bee''s Knees', 'Copa de cóctel', 'shake', 'Sin hielo en copa', 'Piel de limón', 'Es un cóctel de la época de la Ley Seca. "The bee''s knees" ("las rodillas de la abeja") era una expresión de moda que significaba "lo mejor". Se suele decir que la miel y el limón servían para disimular el mal sabor de la ginebra casera de aquellos años.', '["Añade todos los ingredientes a la coctelera con hielo.","Agita con fuerza 10-15 segundos.","Sirve con doble colado en la copa fría.","Decora con la piel de limón."]', '["Clásicos","Ginebra","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Bee''s Knees');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ginebra' AS name, 50 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de limón', 20, 'ml', 'recién exprimido', 1
  UNION ALL SELECT 'Sirope de miel', 20, 'ml', 'miel diluida en agua caliente a partes iguales', 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor');

-- Rusty Nail
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Rusty Nail', 'Vaso old fashioned', 'build', 'Bloque grande o cubos', 'Piel de limón', 'Se hizo muy popular en Estados Unidos en los años 60. El Drambuie es un licor escocés de whisky con miel y hierbas, y aquí suaviza el escocés sin taparlo. Su nombre, "clavo oxidado", se suele relacionar con el color ámbar de la mezcla.', '["Llena el vaso de hielo.","Añade el whisky y el Drambuie.","Remueve suavemente unos segundos.","Perfuma con la piel de limón."]', '["Clásicos","Whisky","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Rusty Nail');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Whisky escocés' AS name, 45 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Drambuie', 25, 'ml', NULL, 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Pelador');

-- Godfather
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Godfather', 'Vaso old fashioned', 'build', 'Bloque grande o cubos', 'Sin decoración', 'Se popularizó en los años 70 y su nombre se asocia a la película "El Padrino", por el toque italiano del amaretto, un licor de almendra. Con vodka en lugar de whisky se llama Godmother, y con coñac, French Connection.', '["Llena el vaso de hielo.","Añade el whisky y el amaretto.","Remueve suavemente unos segundos."]', '["Clásicos","Whisky","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Godfather');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Whisky escocés' AS name, 35 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Amaretto', 35, 'ml', NULL, 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar');

-- Grasshopper
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Grasshopper', 'Copa de cóctel', 'shake', 'Sin hielo en copa', 'Hoja de menta (opcional)', 'Se atribuye a Philibert Guichet, del bar Tujague''s de Nueva Orleans, a principios del siglo XX. Su color verde le da el nombre ("saltamontes"). Fue muy popular en Estados Unidos como cóctel de sobremesa, con sabor a menta y chocolate.', '["Añade todos los ingredientes a la coctelera con hielo.","Agita con fuerza 10-15 segundos.","Sirve con doble colado en la copa fría."]', '["Clásicos","Licores","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Grasshopper');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Crema de menta verde' AS name, 20 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Crema de cacao blanca', 20, 'ml', NULL, 1
  UNION ALL SELECT 'Nata líquida', 20, 'ml', NULL, 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino');

-- Black Russian
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Black Russian', 'Vaso old fashioned', 'build', 'Cubos', 'Sin decoración', 'Lo creó Gustave Tops en 1949 en el Hotel Metropole de Bruselas, en honor a Perle Mesta, embajadora de Estados Unidos en Luxemburgo. El nombre juega con el vodka, de origen ruso, y el color oscuro del café, en plena Guerra Fría.', '["Llena el vaso de hielo.","Añade el vodka y el licor de café.","Remueve suavemente."]', '["Internacionales","Vodka","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Black Russian');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Vodka' AS name, 50 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Licor de café', 20, 'ml', NULL, 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar');

-- White Russian
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'White Russian', 'Vaso old fashioned', 'build', 'Cubos', 'Sin decoración', 'Es el Black Russian con nata, una variante que apareció en los años 60. Volvió a ponerse de moda a finales de los 90 gracias a la película "El gran Lebowski", donde es la bebida del protagonista.', '["Llena el vaso de hielo.","Añade el vodka y el licor de café y remueve.","Vierte la nata con cuidado sobre una cuchara para que quede por encima."]', '["Internacionales","Vodka","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'White Russian');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Vodka' AS name, 50 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Licor de café', 20, 'ml', NULL, 1
  UNION ALL SELECT 'Nata líquida', 30, 'ml', 'ligeramente montada', 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar');

-- Irish Coffee
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Irish Coffee', 'Copa de Irish coffee', 'build', 'Sin hielo', 'Nata por encima', 'Lo creó Joe Sheridan en los años 40 en el aeropuerto de Foynes (Irlanda), para reconfortar a unos pasajeros que llegaban helados tras un vuelo cancelado. Un periodista lo llevó después al Buena Vista Café de San Francisco, que lo hizo famoso en todo el mundo.', '["Calienta la copa con agua caliente y tírala.","Añade el azúcar y el café y remueve hasta disolver.","Añade el whiskey.","Vierte la nata sobre el dorso de una cuchara para que flote. No se remueve: se bebe a través de la nata."]', '["Internacionales","Whisky","Café","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Irish Coffee');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Whiskey irlandés' AS name, 50 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Café caliente', 120, 'ml', 'recién hecho', 1
  UNION ALL SELECT 'Azúcar moreno', 1, 'cucharaditas', NULL, 2
  UNION ALL SELECT 'Nata líquida', 50, 'ml', 'ligeramente montada', 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar');

-- Hemingway Special
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Hemingway Special', 'Copa de cóctel', 'shake', 'Sin hielo en copa', 'Sin decoración (o rueda de lima)', 'Es un daiquirí sin azúcar, con pomelo y marrasquino, nacido en El Floridita de La Habana. Ernest Hemingway, cliente habitual, lo pedía con doble de ron y sin azúcar; por eso también se conoce como "Papa Doble". Se puede servir colado o frozen.', '["Añade todos los ingredientes a la coctelera con hielo.","Agita con fuerza 10-15 segundos.","Sirve con doble colado en la copa fría."]', '["Internacionales","Ron","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Hemingway Special');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ron blanco' AS name, 60 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de pomelo', 40, 'ml', 'recién exprimido', 1
  UNION ALL SELECT 'Licor de marrasquino', 15, 'ml', NULL, 2
  UNION ALL SELECT 'Zumo de lima', 15, 'ml', 'recién exprimido', 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor');

-- Mimosa
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Mimosa', 'Copa flauta', 'build', 'Sin hielo en copa', 'Piel de naranja (opcional)', 'Se atribuye a Frank Meier, del bar del Hotel Ritz de París, hacia 1925. Toma el nombre de la flor de la mimosa, por su color amarillo. Es muy parecido al Buck''s Fizz británico, que lleva más espumoso que zumo, y es el clásico de los desayunos y brunch.', '["Vierte el zumo de naranja en la copa flauta fría.","Completa despacio con el espumoso.","Remueve muy suavemente si hace falta."]', '["Internacionales","Espumoso","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Mimosa');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Zumo de naranja' AS name, 75 AS amount, 'ml' AS unit, 'recién exprimido y frío' AS note, 0 AS ord
  UNION ALL SELECT 'Champán o cava brut', 75, 'ml', 'bien frío', 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Exprimidor');

-- Dark 'n' Stormy
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Dark ''n'' Stormy', 'Vaso highball', 'build', 'Cubos', 'Gajo de lima', 'Es la bebida nacional de las Bermudas. Nació a principios del siglo XX, cuando los marineros mezclaban ron oscuro con la ginger beer que se elaboraba en la isla. Su nombre describe el aspecto del ron flotando como una tormenta. Es una marca registrada de la casa de ron bermudeña Gosling''s.', '["Llena el vaso de hielo.","Añade la ginger beer.","Vierte el ron oscuro por encima para que quede flotando, como una nube de tormenta.","Decora con un gajo de lima."]', '["Internacionales","Ron","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Dark ''n'' Stormy');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ron oscuro' AS name, 60 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Ginger beer', 100, 'ml', NULL, 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Cuchillo y tabla');

-- Naked and Famous
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Naked and Famous', 'Copa de cóctel', 'shake', 'Sin hielo en copa', 'Sin decoración', 'Lo creó Joaquín Simó en 2011 en Death & Co, en Nueva York. Es hijo del Last Word y del Paper Plane: mantiene sus partes iguales, pero cambia la base por mezcal ahumado. Se convirtió rápidamente en un clásico moderno.', '["Añade los cuatro ingredientes, a partes iguales, a la coctelera con hielo.","Agita con fuerza 10-15 segundos.","Sirve con doble colado en la copa fría."]', '["Modernos","Mezcal","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Naked and Famous');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Mezcal' AS name, 22.5 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Chartreuse amarilla', 22.5, 'ml', NULL, 1
  UNION ALL SELECT 'Aperol', 22.5, 'ml', NULL, 2
  UNION ALL SELECT 'Zumo de lima', 22.5, 'ml', 'recién exprimido', 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor');

-- Bramble
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Bramble', 'Vaso old fashioned', 'shake', 'Hielo picado', 'Moras y rodaja de limón', 'Lo creó Dick Bradsell en 1984 en el Fred''s Club de Londres, inspirado en los recuerdos de recoger moras de niño en la isla de Wight. "Bramble" es el nombre de la zarzamora en inglés. Bradsell también es el creador del Espresso Martini.', '["Agita la ginebra, el limón y el sirope en la coctelera con hielo.","Cuela en el vaso lleno de hielo picado.","Vierte el licor de mora por encima para que caiga entre el hielo.","Corona con más hielo picado y decora con moras y limón."]', '["Modernos","Ginebra","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Bramble');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ginebra' AS name, 50 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de limón', 25, 'ml', 'recién exprimido', 1
  UNION ALL SELECT 'Sirope de azúcar', 12.5, 'ml', NULL, 2
  UNION ALL SELECT 'Licor de mora (crème de mûre)', 15, 'ml', NULL, 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Exprimidor', 'Pajita');

COMMIT;
