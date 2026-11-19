<?php

namespace App\Support;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class Media
{
    /** URL pública absoluta (usa el host de la petición, válido en red local). */
    public static function url(?string $path): ?string
    {
        return $path ? asset('storage/' . ltrim($path, '/')) : null;
    }

    /** Guarda una imagen subida en el disco público con un nombre seguro. */
    public static function store(UploadedFile $file, string $dir): string
    {
        // extension() se deduce del contenido real del archivo, no del nombre del cliente
        $name = Str::uuid() . '.' . ($file->extension() ?: 'jpg');

        return $file->storeAs($dir, $name, 'public');
    }

    /** Copia un archivo existente a otro directorio (al copiar cócteles de la biblioteca). */
    public static function copy(string $path, string $dir): ?string
    {
        $disk = Storage::disk('public');
        if (! $disk->exists($path)) {
            return null;
        }
        $new = $dir . '/' . Str::uuid() . '.' . pathinfo($path, PATHINFO_EXTENSION);
        $disk->copy($path, $new);

        return $new;
    }

    public static function delete(?string $path): void
    {
        if ($path) {
            Storage::disk('public')->delete($path);
        }
    }
}
