<?php

namespace Database\Seeders;

use App\Models\Establishment;
use App\Models\User;
use Illuminate\Database\Seeder;

/** Local de prueba: nº 100001 · admin@demo.com / demo1234 */
class DemoEstablishmentSeeder extends Seeder
{
    public function run(): void
    {
        $establishment = Establishment::firstOrCreate(['code' => '100001'], ['name' => 'Alocraise Demo']);

        User::updateOrCreate(
            ['email' => 'admin@demo.com'],
            [
                'establishment_id' => $establishment->id,
                'role' => User::ROLE_ADMIN,
                'name' => 'Admin Demo',
                'password' => 'demo1234',
            ]
        );

        foreach (['Clásicos', 'Internacionales'] as $i => $name) {
            $establishment->families()->firstOrCreate(['name' => $name], ['order' => $i + 1]);
        }
    }
}
