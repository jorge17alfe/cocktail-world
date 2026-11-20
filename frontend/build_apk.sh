#!/usr/bin/env bash
# Compila el APK final para repartir (sin Google Play), apuntando al servidor de producción.
#
#   ./build_apk.sh
#
# Antes de cada versión nueva sube el número en pubspec.yaml (version: 1.0.1+2):
# el número tras el "+" tiene que ser MAYOR que el anterior o el móvil no la instalará encima.
set -euo pipefail
cd "$(dirname "$0")"

SERVER="https://cocktail-world.alocraise.com"

if [ ! -f android/key.properties ]; then
  echo "✗ Falta android/key.properties (tu firma). Mira android/key.properties.example"
  exit 1
fi
store=$(grep -E '^storeFile=' android/key.properties | cut -d= -f2-)
if [ ! -f "$store" ]; then
  echo "✗ No encuentro la llave $store indicada en android/key.properties"
  exit 1
fi

version=$(grep -E '^version:' pubspec.yaml | awk '{print $2}')
echo "→ Compilando Cocktail World $version contra $SERVER"

flutter build apk --release --dart-define=API_HOST="$SERVER"

mkdir -p dist
out="dist/cocktail-world-${version%%+*}.apk"
cp build/app/outputs/flutter-apk/app-release.apk "$out"

echo
echo "✓ APK listo: frontend/$out ($(du -h "$out" | cut -f1))"
echo "  Pásalo por WhatsApp, Drive o correo. En el móvil: abrir → permitir instalar → Instalar."
echo "  Recuerda: para la próxima versión sube 'version:' en pubspec.yaml (ahora $version)."
