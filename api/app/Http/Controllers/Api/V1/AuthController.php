<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\V1\LoginRequest;
use App\Http\Requests\V1\RegisterEstablishmentRequest;
use App\Http\Resources\V1\EstablishmentResource;
use App\Models\Establishment;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    /** Alta de un establecimiento nuevo + su administrador. */
    public function register(RegisterEstablishmentRequest $request): JsonResponse
    {
        $user = DB::transaction(function () use ($request) {
            $establishment = Establishment::create([
                'code' => Establishment::generateCode(),
                'name' => $request->establishment_name,
            ]);

            return $establishment->users()->create([
                'role' => User::ROLE_ADMIN,
                'name' => $request->name,
                'email' => $request->email,
                'password' => $request->password, // el cast 'hashed' lo cifra
            ]);
        });

        return $this->tokenResponse($user, $request->device_name, 201, 'Establecimiento creado');
    }

    /** Login: número de establecimiento + email + contraseña. */
    public function login(LoginRequest $request): JsonResponse
    {
        $establishment = Establishment::where('code', $request->establishment_code)
            ->where('is_active', true)->first();

        $user = $establishment?->users()->where('email', $request->email)->first();

        if (! $user || ! $user->is_active || ! Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Número de establecimiento, email o contraseña incorrectos',
            ], 422);
        }

        $user->forceFill(['last_login_at' => now(), 'last_login_ip' => $request->ip()])->save();

        return $this->tokenResponse($user, $request->device_name);
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load('establishment');

        return response()->json([
            'success' => true,
            'user' => $this->userPayload($user),
            'establishment' => new EstablishmentResource($user->establishment),
        ]);
    }

    /**
     * Cambiar la propia contraseña (p. ej. tras recibir una temporal de Alocraise).
     * Cierra las sesiones en los demás dispositivos; la actual sigue abierta.
     */
    public function changePassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'current_password' => ['required', 'string'],
            'password' => ['required', 'confirmed', Password::min(8), 'different:current_password'],
        ], [
            'password.different' => 'La nueva contraseña tiene que ser distinta de la actual.',
            'password.confirmed' => 'Las contraseñas nuevas no coinciden.',
            'password.min' => 'La nueva contraseña debe tener al menos 8 caracteres.',
        ]);

        $user = $request->user();
        if (! Hash::check($data['current_password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'La contraseña actual no es correcta',
                'errors' => ['current_password' => ['La contraseña actual no es correcta']],
            ], 422);
        }

        $user->update(['password' => $data['password']]);
        $user->tokens()->where('id', '!=', $user->currentAccessToken()->id)->delete();

        return response()->json(['success' => true, 'message' => 'Contraseña cambiada']);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['success' => true, 'message' => 'Sesión cerrada']);
    }

    private function tokenResponse(User $user, ?string $device, int $status = 200, string $message = 'Login correcto'): JsonResponse
    {
        $token = $user->createToken($device ?: 'app')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => $message,
            'token' => $token,
            'token_type' => 'Bearer',
            'user' => $this->userPayload($user),
            'establishment' => new EstablishmentResource($user->establishment),
        ], $status);
    }

    private function userPayload(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
        ];
    }
}
