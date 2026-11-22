-- Biblioteca de Cocktail World · library_batch_1 (20 cócteles)
-- Generado con database/sql/build_library_sql.php. Solo añade los que no existen.
SET NAMES utf8mb4;
START TRANSACTION;

-- Manhattan
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Manhattan', 'Copa de cóctel', 'stir', 'Sin hielo en copa', 'Cereza al marrasquino', 'Nació en Nueva York en la década de 1870 y su nombre se suele relacionar con el Manhattan Club. La anécdota de que se creó para una fiesta de Jennie Jerome, madre de Winston Churchill, es muy popular pero las fechas no encajan. Es el gran clásico removido de whisky y la base de muchas variantes, como el Rob Roy con whisky escocés.', '["Enfría la copa con hielo o en el congelador.","Añade el whisky, el vermut y la angostura al vaso mezclador con hielo.","Remueve 20-30 segundos hasta que esté bien frío.","Cuela en la copa fría.","Decora con una cereza al marrasquino."]', '["Clásicos","Whisky","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Manhattan');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Whisky de centeno (rye)' AS name, 50 AS amount, 'ml' AS unit, 'o bourbon' AS note, 0 AS ord
  UNION ALL SELECT 'Vermut rojo', 20, 'ml', NULL, 1
  UNION ALL SELECT 'Angostura bitters', 1, 'golpes', NULL, 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Vaso mezclador', 'Cuchara de bar', 'Colador Julep', 'Jigger');

-- Boulevardier
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Boulevardier', 'Vaso old fashioned', 'stir', 'Bloque grande o cubos', 'Piel de naranja', 'Es el "primo" del Negroni con whisky en lugar de ginebra. Aparece en un libro de 1927 de Harry MacElhone, del Harry''s New York Bar de París, que lo atribuye a Erskine Gwynne, un escritor estadounidense que editaba allí una revista mensual llamada precisamente "Boulevardier".', '["Añade todos los ingredientes al vaso mezclador con hielo.","Remueve unos 20-30 segundos.","Cuela sobre un vaso old fashioned con hielo nuevo (o en copa de cóctel sin hielo).","Exprime la piel de naranja por encima y úsala de decoración."]', '["Clásicos","Whisky","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Boulevardier');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Bourbon' AS name, 45 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Campari', 30, 'ml', NULL, 1
  UNION ALL SELECT 'Vermut rojo', 30, 'ml', NULL, 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Vaso mezclador', 'Cuchara de bar', 'Colador Julep', 'Jigger', 'Pelador');

-- Americano
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Americano', 'Vaso old fashioned', 'build', 'Cubos', 'Media rodaja de naranja y piel de limón', 'Desciende del "Milano-Torino", que unía el Campari de Milán con el vermut de Turín. Se dice que tomó el nombre de "Americano" por lo mucho que gustaba a los turistas estadounidenses en Italia a principios del siglo XX. Es el antecesor directo del Negroni y el primer cóctel que pide James Bond en la primera novela de Ian Fleming.', '["Llena el vaso de hielo.","Añade el Campari y el vermut.","Completa con un chorrito de soda.","Remueve suavemente y decora con la naranja y la piel de limón."]', '["Clásicos","Aperitivo","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Americano');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Campari' AS name, 30 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Vermut rojo', 30, 'ml', NULL, 1
  UNION ALL SELECT 'Soda', NULL, NULL, 'hasta completar', 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Cuchillo y tabla');

-- Sidecar
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Sidecar', 'Copa de cóctel', 'shake', 'Sin hielo en copa', 'Borde de azúcar (opcional) y piel de naranja', 'Surgió hacia el final de la Primera Guerra Mundial y París y Londres se disputan su origen. Aparece en libros de 1922 de Harry MacElhone y de Robert Vermeire. La leyenda cuenta que se creó para un capitán que llegaba al bar en el sidecar de una moto. Es uno de los "sours" más elegantes.', '["Si quieres, escarcha el borde de la copa con azúcar y enfríala.","Añade todos los ingredientes a la coctelera con hielo.","Agita con fuerza 10-15 segundos.","Sirve con doble colado en la copa fría."]', '["Clásicos","Brandy","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Sidecar');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Coñac' AS name, 50 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Triple sec (Cointreau)', 20, 'ml', NULL, 1
  UNION ALL SELECT 'Zumo de limón', 20, 'ml', 'recién exprimido', 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor');

-- Gimlet
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Gimlet', 'Copa de cóctel', 'shake', 'Sin hielo en copa', 'Rodaja o piel de lima', 'Se asocia a la Marina británica del siglo XIX, que daba a sus marineros zumo de lima para prevenir el escorbuto; mezclarlo con ginebra lo hacía más agradable. La versión clásica se hacía con cordial de lima (Rose''s), y hoy es habitual prepararla con lima fresca y sirope. Su nombre a veces se relaciona con un médico naval apellidado Gimlette.', '["Añade todos los ingredientes a la coctelera con hielo.","Agita con fuerza 10-15 segundos.","Sirve con doble colado en la copa fría.","Decora con la lima."]', '["Clásicos","Ginebra"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Gimlet');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ginebra' AS name, 50 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de lima', 20, 'ml', 'recién exprimido', 1
  UNION ALL SELECT 'Sirope de azúcar', 15, 'ml', NULL, 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor');

-- Aviation
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Aviation', 'Copa de cóctel', 'shake', 'Sin hielo en copa', 'Cereza al marrasquino', 'Lo publicó en 1916 Hugo Ensslin, barman del Hotel Wallick de Nueva York, en plena fascinación por los primeros aviones. El licor de violeta le da su tono azul cielo. Durante décadas se preparó sin violeta porque ese licor desapareció del mercado, y volvió a hacerse con la receta original cuando se recuperó a principios de los 2000.', '["Añade todos los ingredientes a la coctelera con hielo.","Agita con fuerza 10-15 segundos.","Sirve con doble colado en la copa fría.","Decora con una cereza."]', '["Clásicos","Ginebra","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Aviation');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ginebra' AS name, 45 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Licor de marrasquino', 15, 'ml', NULL, 1
  UNION ALL SELECT 'Zumo de limón', 15, 'ml', 'recién exprimido', 2
  UNION ALL SELECT 'Crème de violette', 1, 'cucharaditas', NULL, 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor');

-- Last Word
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Last Word', 'Copa de cóctel', 'shake', 'Sin hielo en copa', 'Sin decoración (o cereza)', 'Se servía en el Detroit Athletic Club en los años de la Ley Seca. Cayó en el olvido hasta que, a comienzos de los 2000, un barman de Seattle lo rescató de un libro antiguo y lo volvió a poner de moda. Sus cuatro ingredientes a partes iguales inspiraron muchas variantes modernas, como el Naked and Famous.', '["Añade los cuatro ingredientes, a partes iguales, a la coctelera con hielo.","Agita con fuerza 10-15 segundos.","Sirve con doble colado en la copa fría."]', '["Clásicos","Ginebra","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Last Word');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ginebra' AS name, 22.5 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Chartreuse verde', 22.5, 'ml', NULL, 1
  UNION ALL SELECT 'Licor de marrasquino', 22.5, 'ml', NULL, 2
  UNION ALL SELECT 'Zumo de lima', 22.5, 'ml', 'recién exprimido', 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor');

-- French 75
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'French 75', 'Copa flauta', 'shake', 'Sin hielo en copa', 'Piel de limón', 'Su nombre viene del cañón francés de 75 mm de la Primera Guerra Mundial: se decía que tomarlo era como recibir un cañonazo. Aparece en los libros de cócteles de los años 20 y quedó fijado en el famoso libro del Savoy de Londres de 1930. Hay quien lo prepara con coñac en lugar de ginebra.', '["Agita la ginebra, el limón y el sirope en la coctelera con hielo.","Cuela en la copa flauta fría.","Completa despacio con el champán.","Decora con una piel de limón."]', '["Clásicos","Ginebra","Espumoso","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'French 75');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ginebra' AS name, 30 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de limón', 15, 'ml', 'recién exprimido', 1
  UNION ALL SELECT 'Sirope de azúcar', 10, 'ml', NULL, 2
  UNION ALL SELECT 'Champán o cava brut', 60, 'ml', 'bien frío', 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor', 'Pelador');

-- Clover Club
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Clover Club', 'Copa de cóctel', 'shake', 'Sin hielo en copa', 'Frambuesas frescas', 'Toma el nombre de un club de caballeros de Filadelfia que se reunía en el hotel Bellevue-Stratford antes de la Ley Seca. Tuvo mucha fama a principios del siglo XX, después se olvidó y volvió con fuerza con el renacer de la coctelería clásica. La clara de huevo le da su espuma sedosa.', '["Añade todos los ingredientes a la coctelera sin hielo.","Agita en seco 10 segundos para montar la clara.","Añade hielo y agita otra vez con fuerza.","Sirve con doble colado en la copa fría y decora con las frambuesas."]', '["Clásicos","Ginebra","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Clover Club');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ginebra' AS name, 45 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Sirope de frambuesa', 15, 'ml', NULL, 1
  UNION ALL SELECT 'Zumo de limón', 15, 'ml', 'recién exprimido', 2
  UNION ALL SELECT 'Clara de huevo', 1, 'chorrito', 'unas gotas, o aquafaba', 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor');

-- Sazerac
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Sazerac', 'Vaso old fashioned', 'stir', 'Sin hielo en el vaso', 'Piel de limón (se exprime y se retira)', 'Es uno de los cócteles más antiguos de Estados Unidos y el símbolo de Nueva Orleans, que lo declaró su cóctel oficial en 2008. Toma el nombre de un coñac, Sazerac de Forge et Fils, y lleva los bitters de Antoine Peychaud, boticario de la ciudad. Cuando la filoxera arruinó los viñedos franceses, el coñac se sustituyó a menudo por whisky de centeno.', '["Enfría el vaso, enjuágalo con la absenta y tira el sobrante.","En el vaso mezclador, deshaz el terrón con los golpes de bitters y unas gotas de agua.","Añade el coñac y hielo, y remueve hasta enfriar.","Cuela en el vaso perfumado, sin hielo.","Exprime la piel de limón por encima y retírala."]', '["Clásicos","Brandy","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Sazerac');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Coñac' AS name, 50 AS amount, 'ml' AS unit, 'o whisky de centeno' AS note, 0 AS ord
  UNION ALL SELECT 'Absenta', 10, 'ml', 'para perfumar el vaso', 1
  UNION ALL SELECT 'Terrón de azúcar', 1, 'unidad', NULL, 2
  UNION ALL SELECT 'Peychaud''s bitters', 2, 'golpes', NULL, 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Vaso mezclador', 'Cuchara de bar', 'Colador Julep', 'Jigger', 'Pelador');

-- Mint Julep
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Mint Julep', 'Vaso julep o highball', 'muddle', 'Hielo picado', 'Ramillete de hierbabuena', 'Es la bebida del sur de Estados Unidos y la oficial del Derby de Kentucky, donde se sirven miles cada año desde hace casi un siglo. La palabra "julep" viene del persa "gulab", agua de rosas, y en origen se refería a una bebida dulce medicinal. Se sirve tradicionalmente en vaso de plata o de metal, que se escarcha con el frío.', '["En el vaso, presiona suavemente la hierbabuena con el azúcar y el agua, sin romperla.","Llena el vaso de hielo picado.","Añade el bourbon y remueve hasta que el vaso se escarche por fuera.","Corona con más hielo picado y decora con un ramillete de hierbabuena."]', '["Clásicos","Whisky","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Mint Julep');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Bourbon' AS name, 60 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Hierbabuena', 8, 'hojas', NULL, 1
  UNION ALL SELECT 'Azúcar', 1, 'cucharaditas', NULL, 2
  UNION ALL SELECT 'Agua', 2, 'cucharaditas', NULL, 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Mortero de bar', 'Cuchara de bar', 'Jigger', 'Pajita');

-- Mai Tai
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Mai Tai', 'Vaso old fashioned', 'shake', 'Hielo picado', 'Ramita de hierbabuena y media lima exprimida', 'Lo creó Victor Bergeron, "Trader Vic", en su restaurante de Oakland (California) en 1944. Según la historia, al probarlo una amiga tahitiana exclamó "maita''i roa ae", algo así como "¡lo mejor, fuera de este mundo!". Donn Beach, el otro pionero de la coctelería tiki, siempre reclamó haber inventado una bebida parecida antes.', '["Añade todos los ingredientes a la coctelera con hielo.","Agita con fuerza 10-15 segundos.","Sirve en el vaso lleno de hielo picado.","Decora con la hierbabuena y la media lima exprimida."]', '["Internacionales","Ron","Tiki","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Mai Tai');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ron añejo jamaicano' AS name, 30 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Ron agrícola de Martinica', 30, 'ml', 'o ron añejo', 1
  UNION ALL SELECT 'Curaçao de naranja', 15, 'ml', NULL, 2
  UNION ALL SELECT 'Sirope de almendra (orgeat)', 15, 'ml', NULL, 3
  UNION ALL SELECT 'Zumo de lima', 30, 'ml', 'recién exprimido', 4
  UNION ALL SELECT 'Sirope de azúcar', 7.5, 'ml', NULL, 5
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Exprimidor', 'Pajita');

-- Paloma
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Paloma', 'Vaso highball', 'build', 'Cubos', 'Rodaja de lima o de pomelo (borde de sal opcional)', 'Es probablemente el cóctel de tequila más popular dentro de México, por encima incluso de la Margarita. Su origen no está claro: se popularizó a mediados del siglo XX con la llegada de los refrescos de pomelo, y a menudo se atribuye a Don Javier Delgado Corona, de la cantina La Capilla, en el pueblo de Tequila.', '["Si quieres, escarcha medio borde del vaso con sal.","Llena el vaso de hielo.","Añade el tequila, la lima y la pizca de sal.","Completa con el refresco de pomelo, remueve suavemente y decora."]', '["Internacionales","Tequila","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Paloma');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Tequila blanco 100% agave' AS name, 50 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de lima', 15, 'ml', 'recién exprimido', 1
  UNION ALL SELECT 'Sal', 1, 'chorrito', 'una pizca', 2
  UNION ALL SELECT 'Refresco de pomelo', 100, 'ml', 'hasta completar', 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Exprimidor', 'Cuchillo y tabla');

-- Cuba Libre
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Cuba Libre', 'Vaso highball', 'build', 'Cubos', 'Gajo de lima', 'Nació en La Habana hacia 1900, tras la guerra hispano-estadounidense, cuando la cola empezó a llegar a Cuba. Se cuenta que unos soldados brindaron con ron y cola gritando "¡Por Cuba libre!", el lema de la independencia. La lima es lo que lo distingue de un simple ron con cola.', '["Llena el vaso de hielo.","Exprime la lima y añádela con el ron.","Completa con la cola.","Remueve suavemente y decora con un gajo de lima."]', '["Internacionales","Ron","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Cuba Libre');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Ron blanco' AS name, 50 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Refresco de cola', 120, 'ml', NULL, 1
  UNION ALL SELECT 'Zumo de lima', 10, 'ml', 'recién exprimido', 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Exprimidor', 'Cuchillo y tabla');

-- Bellini
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Bellini', 'Copa flauta', 'build', 'Sin hielo en copa', 'Sin decoración', 'Lo creó Giuseppe Cipriani en el Harry''s Bar de Venecia a finales de los años 40. Su tono rosado le recordó a los colores de un cuadro del pintor renacentista Giovanni Bellini, y de ahí el nombre. Lo ideal es hacerlo en temporada de melocotón blanco.', '["Pon el puré de melocotón en la copa flauta fría.","Añade el prosecco poco a poco, inclinando la copa.","Remueve muy suavemente para integrar sin perder la burbuja."]', '["Internacionales","Espumoso","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Bellini');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Puré de melocotón blanco' AS name, 50 AS amount, 'ml' AS unit, 'bien frío' AS note, 0 AS ord
  UNION ALL SELECT 'Prosecco', 100, 'ml', 'bien frío', 1
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar');

-- Long Island Iced Tea
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Long Island Iced Tea', 'Vaso highball', 'build', 'Cubos', 'Rodaja de limón', 'Se suele atribuir a Robert Butt, barman del Oak Beach Inn de Long Island (Nueva York), en los años 70. A pesar del nombre no lleva té: el chorrito de cola le da el color del té helado. Es famoso por su graduación, así que conviene servirlo con medida.', '["Llena el vaso de hielo.","Añade los cinco destilados, el limón y el sirope.","Remueve bien.","Termina con un chorrito de cola y decora con el limón."]', '["Internacionales","Vodka","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Long Island Iced Tea');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Vodka' AS name, 15 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Ginebra', 15, 'ml', NULL, 1
  UNION ALL SELECT 'Ron blanco', 15, 'ml', NULL, 2
  UNION ALL SELECT 'Tequila blanco', 15, 'ml', NULL, 3
  UNION ALL SELECT 'Triple sec (Cointreau)', 15, 'ml', NULL, 4
  UNION ALL SELECT 'Zumo de limón', 25, 'ml', 'recién exprimido', 5
  UNION ALL SELECT 'Sirope de azúcar', 30, 'ml', NULL, 6
  UNION ALL SELECT 'Refresco de cola', 1, 'chorrito', 'para dar color', 7
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Jigger', 'Cuchara de bar', 'Exprimidor', 'Pajita');

-- Penicillin
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Penicillin', 'Vaso old fashioned', 'shake', 'Bloque grande o cubos', 'Jengibre confitado', 'Lo creó Sam Ross en 2005 en Milk & Honey, uno de los bares que impulsaron la nueva coctelería en Nueva York. Es uno de los "clásicos modernos" más copiados del mundo: el whisky ahumado de arriba da el aroma y el limón, la miel y el jengibre hacen el resto. Su nombre juega con la idea de un remedio "para todo".', '["Agita el whisky blended, el limón y el sirope de miel y jengibre en la coctelera con hielo.","Cuela sobre el vaso con hielo.","Vierte el whisky de Islay con cuidado sobre una cuchara para que quede flotando.","Decora con el jengibre confitado."]', '["Modernos","Whisky","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Penicillin');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Whisky escocés de mezcla (blended)' AS name, 60 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de limón', 25, 'ml', 'recién exprimido', 1
  UNION ALL SELECT 'Sirope de miel y jengibre', 25, 'ml', NULL, 2
  UNION ALL SELECT 'Whisky escocés de Islay (ahumado)', 7.5, 'ml', 'flotando por encima', 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Cuchara de bar', 'Exprimidor');

-- Paper Plane
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Paper Plane', 'Copa de cóctel', 'shake', 'Sin hielo en copa', 'Sin decoración (o un avioncito de papel)', 'Otro clásico moderno de Sam Ross, creado hacia 2008 para el bar The Violet Hour de Chicago. Su nombre viene de la canción "Paper Planes" de M.I.A., que sonaba mucho mientras lo diseñaba. Sigue la fórmula de partes iguales del Last Word.', '["Añade los cuatro ingredientes, a partes iguales, a la coctelera con hielo.","Agita con fuerza 10-15 segundos.","Sirve con doble colado en la copa fría."]', '["Modernos","Whisky","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Paper Plane');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Bourbon' AS name, 22.5 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Aperol', 22.5, 'ml', NULL, 1
  UNION ALL SELECT 'Amaro Nonino', 22.5, 'ml', NULL, 2
  UNION ALL SELECT 'Zumo de limón', 22.5, 'ml', 'recién exprimido', 3
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino', 'Exprimidor');

-- Tommy's Margarita
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Tommy''s Margarita', 'Vaso old fashioned', 'shake', 'Cubos', 'Gajo de lima', 'Julio Bermejo la creó a principios de los 90 en Tommy''s, el restaurante mexicano de su familia en San Francisco. Cambió el licor de naranja por sirope de agave para que el protagonista fuera el tequila. Se hizo tan popular que hoy muchos bares la sirven como su Margarita por defecto.', '["Añade todos los ingredientes a la coctelera con hielo.","Agita con fuerza 10-15 segundos.","Cuela sobre el vaso con hielo nuevo.","Decora con un gajo de lima."]', '["Modernos","Tequila","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Tommy''s Margarita');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Tequila reposado 100% agave' AS name, 60 AS amount, 'ml' AS unit, 'o blanco' AS note, 0 AS ord
  UNION ALL SELECT 'Zumo de lima', 30, 'ml', 'recién exprimido', 1
  UNION ALL SELECT 'Sirope de agave', 15, 'ml', NULL, 2
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Exprimidor');

-- Porn Star Martini
INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)
SELECT NULL, NULL, NULL, 'Porn Star Martini', 'Copa de cóctel', 'shake', 'Sin hielo en copa', 'Medio maracuyá y un chupito de cava o prosecco aparte', 'Lo creó Douglas Ankrah en Londres a principios de los 2000, en su bar Townhouse. Al principio se llamó "Maverick Martini" y después adoptó el nombre con el que se hizo famoso. Se convirtió en uno de los cócteles más pedidos del Reino Unido. Algunos bares lo sirven con el nombre de "Passion Star Martini".', '["Añade todos los ingredientes menos el prosecco a la coctelera con hielo.","Agita con fuerza 10-15 segundos.","Sirve con doble colado en la copa fría.","Decora con medio maracuyá y acompaña con el prosecco en un vasito aparte."]', '["Modernos","Vodka","IBA"]', NULL, 1, 0, NOW(), NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = 'Porn Star Martini');
SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)
SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (
  SELECT 'Vodka de vainilla' AS name, 45 AS amount, 'ml' AS unit, NULL AS note, 0 AS ord
  UNION ALL SELECT 'Licor de maracuyá (Passoã)', 15, 'ml', NULL, 1
  UNION ALL SELECT 'Puré de maracuyá', 30, 'ml', NULL, 2
  UNION ALL SELECT 'Sirope de vainilla', 10, 'ml', NULL, 3
  UNION ALL SELECT 'Prosecco o cava', 60, 'ml', 'se sirve aparte', 4
) AS t WHERE @id IS NOT NULL;
INSERT INTO cocktail_utensil (cocktail_id, utensil_id)
SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL
  AND name IN ('Coctelera', 'Jigger', 'Colador Hawthorne', 'Colador fino');

COMMIT;
