<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'username',
        'email',
        'password',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
    ];

    /** ID semua teman yang sudah saling menerima. */
    public function friendIds(): array
    {
        $me = (int) $this->id;

        return Friendship::query()
            ->where('status', Friendship::ACCEPTED)
            ->where(function ($q) use ($me) {
                $q->where('user_id', $me)->orWhere('friend_id', $me);
            })
            ->get(['user_id', 'friend_id'])
            ->map(function ($f) use ($me) {
                return (int) $f->user_id === $me ? (int) $f->friend_id : (int) $f->user_id;
            })
            ->unique()
            ->values()
            ->all();
    }

    public function isFriendWith(int $otherId): bool
    {
        return Friendship::between((int) $this->id, $otherId)
            ->where('status', Friendship::ACCEPTED)
            ->exists();
    }
}
