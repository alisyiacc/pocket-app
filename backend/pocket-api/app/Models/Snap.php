<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Snap extends Model
{
    protected $fillable = ['sender_id', 'image_path', 'caption'];

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    public function recipients(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'snap_recipients', 'snap_id', 'user_id');
    }

    public function reactions(): HasMany
    {
        return $this->hasMany(SnapReaction::class);
    }

    /** URL absolut mengikuti host yang dipakai klien (10.0.2.2, 127.0.0.1, atau IP LAN). */
    public function getImageUrlAttribute(): string
    {
        return url('uploads/snaps/'.basename((string) $this->image_path));
    }

    /** Foto yang boleh dilihat user: miliknya atau dikirim kepadanya. */
    public function scopeVisibleTo($query, int $userId)
    {
        return $query->where(function ($q) use ($userId) {
            $q->where('snaps.sender_id', $userId)
                ->orWhereIn('snaps.id', function ($sub) use ($userId) {
                    $sub->select('snap_id')->from('snap_recipients')->where('user_id', $userId);
                });
        });
    }
}
