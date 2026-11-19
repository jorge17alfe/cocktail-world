<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Ingredient extends Model
{
    protected $fillable = ['name', 'amount', 'unit', 'note', 'order'];

    protected $casts = ['amount' => 'float'];
}
