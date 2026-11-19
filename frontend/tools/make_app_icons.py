#!/usr/bin/env python3
"""
Genera las imágenes cuadradas para el icono de la app a partir del logo.

  python3 tools/make_app_icons.py [logo.png] [color_fondo]

Por defecto: assets/icons/iconbg.png (logo con fondo transparente) sobre fondo #EAECF7.
Crea en assets/icons/generated/:
  - app_icon.png             1024×1024, logo centrado sobre el color de fondo (iOS, web, Android antiguo)
  - app_icon_foreground.png  1024×1024, logo transparente con margen extra (icono adaptable de Android,
                             que el sistema recorta en círculo, gota, etc.)
"""
import sys
from pathlib import Path

from PIL import Image

SIZE = 1024
ROOT = Path(__file__).resolve().parent.parent
source = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / 'assets/icons/iconbg.png'
background = sys.argv[2] if len(sys.argv) > 2 else '#EAECF7'
out_dir = ROOT / 'assets/icons/generated'
out_dir.mkdir(parents=True, exist_ok=True)

logo = Image.open(source).convert('RGBA')
bbox = logo.getchannel('A').getbbox()  # recorta el margen transparente sobrante
if bbox:
    logo = logo.crop(bbox)

if max(logo.size) < 512:
    print(f'⚠ El logo mide {logo.width}×{logo.height}: el icono puede verse algo borroso. '
          'Lo ideal es un PNG de 1024 px o más.')


def place(scale: float, bg) -> Image.Image:
    """Logo escalado para ocupar `scale` del lado, centrado sobre un lienzo cuadrado."""
    canvas = Image.new('RGBA', (SIZE, SIZE), bg)
    box = int(SIZE * scale)
    ratio = min(box / logo.width, box / logo.height)
    resized = logo.resize((round(logo.width * ratio), round(logo.height * ratio)), Image.LANCZOS)
    canvas.alpha_composite(resized, ((SIZE - resized.width) // 2, (SIZE - resized.height) // 2))
    return canvas


place(0.78, background).convert('RGB').save(out_dir / 'app_icon.png')
place(0.60, (0, 0, 0, 0)).save(out_dir / 'app_icon_foreground.png')  # zona segura del icono adaptable
print(f'✓ Imágenes generadas en {out_dir.relative_to(ROOT)} (fondo {background})')
