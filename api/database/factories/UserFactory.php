<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class UserFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'phone' => fake()->phoneNumber(),
            'email_verified_at' => now(),
            'password' => Hash::make('password123'),
            'device_name' => fake()->randomElement(['iPhone 13', 'Samsung Galaxy', 'Pixel 6', 'iPad']),
            'fcm_token' => Str::random(100),
            'last_login_at' => fake()->dateTimeBetween('-1 month', 'now'),
            'last_login_ip' => fake()->ipv4(),
            'is_active' => true,
            'remember_token' => Str::random(10),
        ];
    }
}