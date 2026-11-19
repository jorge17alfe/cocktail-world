#!/usr/bin/env bash
# Regenera el icono de la app (Android, iOS y web) a partir del logo.
#
#   1. Sustituye assets/icons/iconbg.png por tu logo nuevo (PNG con fondo transparente,
#      a ser posible de 1024 px o más).
#   2. Ejecuta: ./update_icons.sh
#
# Para cambiar el color de fondo del icono, cámbialo aquí:
BACKGROUND="#EAECF7"
set -euo pipefail
cd "$(dirname "$0")"

python3 tools/make_app_icons.py assets/icons/iconbg.png "$BACKGROUND"
sed -i "s/^  adaptive_icon_background: .*/  adaptive_icon_background: \"$BACKGROUND\"/; s/^    background_color: .*/    background_color: \"$BACKGROUND\"/" flutter_launcher_icons.yaml
dart run flutter_launcher_icons
./build_web.sh

echo
echo "✓ Icono actualizado. En el móvil desinstala la app y vuelve a instalarla para ver el nuevo"
echo "  (Android guarda el icono anterior en caché). En el navegador recarga con Ctrl+Shift+R."
