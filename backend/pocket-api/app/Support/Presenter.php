<?php

namespace App\Support;

use App\Models\Friendship;
use App\Models\Message;
use App\Models\Rollcall;
use App\Models\Snap;
use App\Models\User;

/**
 * Mengubah model menjadi JSON persis seperti kontrak docs/API.md.
 * Semua ID/angka di-cast ke int agar `as int` di Flutter tidak error.
 */
class Presenter
{
    public static function user(User $u, string $relation = 'none', ?array $counts = null): array
    {
        $data = [
            'id' => (int) $u->id,
            'name' => (string) $u->name,
            'username' => (string) $u->username,
            'email' => $relation === 'me' ? $u->email : null,
            'avatar_url' => null,
            'relation' => $relation,
        ];

        if ($counts !== null) {
            $data['friends_count'] = (int) $counts['friends_count'];
            $data['snaps_count'] = (int) $counts['snaps_count'];
        }

        return $data;
    }

    /** User yang sedang login (+ jumlah teman & foto). */
    public static function me(User $u): array
    {
        return self::user($u, 'me', [
            'friends_count' => count($u->friendIds()),
            'snaps_count' => Snap::query()->where('sender_id', $u->id)->count(),
        ]);
    }

    /** Banyak user sekaligus, lengkap dengan `relation` terhadap $meId. */
    public static function users($users, int $meId): array
    {
        $users = collect($users)->values();
        $ids = $users->pluck('id')->map(fn ($i) => (int) $i)->all();
        $relations = Friendship::relationsFor($meId, $ids);

        return $users->map(function (User $u) use ($relations, $meId) {
            $id = (int) $u->id;
            $rel = $id === $meId ? 'me' : ($relations[$id] ?? 'none');

            return self::user($u, $rel);
        })->all();
    }

    /** Snap harus sudah di-load: sender, recipients, reactions. */
    public static function snaps($snaps, int $meId): array
    {
        $snaps = collect($snaps)->values();
        $senderIds = $snaps->pluck('sender_id')->map(fn ($i) => (int) $i)->unique()->values()->all();
        $relations = Friendship::relationsFor($meId, $senderIds);

        return $snaps->map(function (Snap $s) use ($relations, $meId) {
            $sid = (int) $s->sender_id;
            $rel = $sid === $meId ? 'me' : ($relations[$sid] ?? 'none');

            return [
                'id' => (int) $s->id,
                'sender' => self::user($s->sender, $rel),
                'image_url' => $s->image_url,
                'caption' => (string) $s->caption,
                'created_at' => $s->created_at->toIso8601String(),
                'recipient_ids' => $s->recipients->pluck('id')->map(fn ($i) => (int) $i)->values()->all(),
                'reactions' => $s->reactions->map(function ($r) {
                    return ['user_id' => (int) $r->user_id, 'emoji' => (string) $r->emoji];
                })->values()->all(),
            ];
        })->all();
    }

    /** Message sebaiknya di-load relasi `snap`. */
    public static function message(Message $m): array
    {
        return [
            'id' => (int) $m->id,
            'sender_id' => (int) $m->sender_id,
            'body' => (string) $m->body,
            'snap_id' => $m->snap_id !== null ? (int) $m->snap_id : null,
            'snap_image_url' => $m->snap ? $m->snap->image_url : null,
            'created_at' => $m->created_at->toIso8601String(),
        ];
    }

    /** Rollcall sebaiknya di-load relasi `creator`. */
    public static function rollcall(Rollcall $r): array
    {
        return [
            'id' => (int) $r->id,
            'title' => (string) $r->title,
            'created_by' => (string) ($r->creator->name ?? ''),
            'created_at' => $r->created_at->toIso8601String(),
            'photo_count' => (int) $r->photo_count,
        ];
    }
}
