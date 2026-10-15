<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SnapReaction extends Model
{
    protected $fillable = ['snap_id', 'user_id', 'emoji'];
}
