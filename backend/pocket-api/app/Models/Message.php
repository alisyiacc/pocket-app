<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Message extends Model
{
    protected $fillable = ['sender_id', 'receiver_id', 'body', 'snap_id', 'read_at'];

    protected $casts = [
        'read_at' => 'datetime',
    ];

    public function snap(): BelongsTo
    {
        return $this->belongsTo(Snap::class);
    }

    /** Semua pesan antara dua user, dua arah. */
    public function scopeBetween($query, int $a, int $b)
    {
        return $query->where(function ($outer) use ($a, $b) {
            $outer->where(function ($q) use ($a, $b) {
                $q->where('sender_id', $a)->where('receiver_id', $b);
            })->orWhere(function ($q) use ($a, $b) {
                $q->where('sender_id', $b)->where('receiver_id', $a);
            });
        });
    }
}
