#!/usr/bin/env bash
# Compila la app para web y la copia a Laravel (api/public/app), que la sirve en
# /app (inicio + administración) y /carta/{número} (la carta del QR).
set -euo pipefail
cd "$(dirname "$0")"

flutter build web --release --base-href /app/

rm -rf ../api/public/app
cp -r build/web ../api/public/app
echo "✓ App web copiada a api/public/app"
