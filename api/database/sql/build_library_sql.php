<?php

/**
 * Convierte una tanda de cócteles (library_batch_N.php) en un .sql para MariaDB/MySQL.
 *
 *   php database/sql/build_library_sql.php library_batch_1 > database/sql/library_batch_1.sql
 *
 * El SQL resultante:
 * - Solo AÑADE cócteles a la biblioteca (establishment_id NULL). Si ya existe uno con el mismo
 *   nombre, lo salta sin tocarlo (así no pisa lo que hayas editado en el panel).
 * - Crea sus ingredientes y los enlaza con los utensilios de la biblioteca por nombre.
 * - Va dentro de una transacción: o entra todo o nada.
 */
$batch = $argv[1] ?? exit("Uso: php build_library_sql.php library_batch_1\n");
$cocktails = require __DIR__."/$batch.php";

$q = function ($value): string {
    if ($value === null) {
        return 'NULL';
    }
    if (is_int($value) || is_float($value)) {
        return (string) $value;
    }

    return "'".str_replace(['\\', "'"], ['\\\\', "''"], $value)."'";
};
$json = fn (array $value) => $q(json_encode($value, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));

$out = [];
$out[] = '-- Biblioteca de Cocktail World · '.$batch.' ('.count($cocktails).' cócteles)';
$out[] = '-- Generado con database/sql/build_library_sql.php. Solo añade los que no existen.';
$out[] = 'SET NAMES utf8mb4;';
$out[] = 'START TRANSACTION;';

foreach ($cocktails as $c) {
    $name = $q($c['name']);
    $out[] = '';
    $out[] = '-- '.$c['name'];
    $out[] = 'INSERT INTO cocktails (establishment_id, family_id, source_cocktail_id, name, glass, technique, ice, garnish, history, steps, tags, price, is_published, `order`, created_at, updated_at)';
    $out[] = 'SELECT NULL, NULL, NULL, '.implode(', ', [
        $name, $q($c['glass']), $q($c['technique']), $q($c['ice']), $q($c['garnish']), $q($c['history']),
        $json($c['steps']), $json($c['tags']),
    ]).', NULL, 1, 0, NOW(), NOW() FROM DUAL';
    $out[] = "WHERE NOT EXISTS (SELECT 1 FROM cocktails WHERE establishment_id IS NULL AND name = $name);";
    // Si se ha saltado (ya existía), @id queda NULL y lo siguiente no inserta nada
    $out[] = 'SET @id = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);';

    $rows = [];
    foreach ($c['ingredients'] as $i => [$ingName, $amount, $unit, $note]) {
        $rows[] = ($i === 0 ? 'SELECT ' : '  UNION ALL SELECT ')
            .$q($ingName).($i === 0 ? ' AS name, ' : ', ')
            .$q($amount).($i === 0 ? ' AS amount, ' : ', ')
            .$q($unit).($i === 0 ? ' AS unit, ' : ', ')
            .$q($note).($i === 0 ? ' AS note, ' : ', ')
            .$i.($i === 0 ? ' AS ord' : '');
    }
    $out[] = 'INSERT INTO ingredients (cocktail_id, name, amount, unit, note, `order`, created_at, updated_at)';
    $out[] = 'SELECT @id, t.name, t.amount, t.unit, t.note, t.ord, NOW(), NOW() FROM (';
    $out[] = '  '.implode("\n", $rows);
    $out[] = ') AS t WHERE @id IS NOT NULL;';

    $out[] = 'INSERT INTO cocktail_utensil (cocktail_id, utensil_id)';
    $out[] = 'SELECT @id, id FROM utensils WHERE establishment_id IS NULL AND @id IS NOT NULL';
    $out[] = '  AND name IN ('.implode(', ', array_map($q, $c['utensils'])).');';
}

$out[] = '';
$out[] = 'COMMIT;';
echo implode("\n", $out)."\n";
