<?php

namespace App\Support;

use Illuminate\Http\JsonResponse;
use RuntimeException;

/** Se lanza cuando una acción superaría el límite del plan. La app muestra el mensaje tal cual. */
class PlanLimitExceeded extends RuntimeException
{
    public function render(): JsonResponse
    {
        return response()->json(['success' => false, 'message' => $this->getMessage(), 'limit' => true], 403);
    }
}
