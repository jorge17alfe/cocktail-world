<?php

return [
    /*
    | Subdominio del panel de gestión de Alocraise (Filament), p. ej. gestion-cw.alocraise.com.
    | Si se indica, el panel SOLO responde en ese dominio (en el de la app da 404).
    | Vacío (en local): el panel está en /gestion del mismo servidor.
    */
    'admin_panel_domain' => env('ADMIN_PANEL_DOMAIN'),
];
