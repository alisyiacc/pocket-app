<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Friendship extends Model
{
    public const PENDING = 'pending';
    public const ACCEPTED = 'accepted';

    protected $fillable = ['user_id', 'friend_id', 'status'];

    /** Query baris pertemanan antara dua user (arah mana pun). */
    public static function between(int $a, int $b)
    {
        return static::query()->where(function ($outer) use ($a, $b) {
            $outer->where(function ($q) use ($a, $b) {
                $q->where('user_id', $a)->where('friend_id', $b);
            })->orWhere(function ($q) use ($a, $b) {
                $q->where('user_id', $b)->where('friend_id', $a);
            });
        });
    }

    /**
     * Relasi saya terhadap banyak user sekaligus (1 query).
     * Hasil: [idLain => 'friend' | 'pending_out' | 'pending_in']; yang tidak ada = 'none'.
     */
    public static function relationsFor(int $meId, array $otherIds): array
    {
        $map = [];
        if (count($otherIds) === 0) {
            return $map;
        }

        $rows = static::query()
            ->where(function ($q) use ($meId, $otherIds) {
                $q->where('user_id', $meId)->whereIn('friend_id', $otherIds);
            })
            ->orWhere(function ($q) use ($meId, $otherIds) {
                $q->where('friend_id', $meId)->whereIn('user_id', $otherIds);
            })
            ->get();

        foreach ($rows as $row) {
            $outgoing = (int) $row->user_id === $meId;
            $other = $outgoing ? (int) $row->friend_id : (int) $row->user_id;

            if ($row->status === self::ACCEPTED) {
                $map[$other] = 'friend';
            } else {
                $map[$other] = $outgoing ? 'pending_out' : 'pending_in';
            }
        }

        return $map;
    }

    public static function relationBetween(int $meId, int $otherId): string
    {
        if ($meId === $otherId) {
            return 'me';
        }

        return static::relationsFor($meId, [$otherId])[$otherId] ?? 'none';
    }
}
