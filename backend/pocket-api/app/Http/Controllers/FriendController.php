<?php

namespace App\Http\Controllers;

use App\Models\Friendship;
use App\Models\User;
use App\Support\Msg;
use App\Support\Presenter;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class FriendController extends Controller
{
    /** GET /friends */
    public function index(Request $request): JsonResponse
    {
        $me = $request->user();
        $users = User::query()->whereIn('id', $me->friendIds())->orderBy('name')->get();

        return response()->json(Presenter::users($users, (int) $me->id));
    }

    /** GET /friends/requests -> permintaan masuk */
    public function requests(Request $request): JsonResponse
    {
        $me = $request->user();
        $ids = Friendship::query()
            ->where('friend_id', $me->id)
            ->where('status', Friendship::PENDING)
            ->pluck('user_id')
            ->all();

        $users = User::query()->whereIn('id', $ids)->orderBy('name')->get();

        return response()->json(Presenter::users($users, (int) $me->id));
    }

    /** GET /friends/search?q=  (q kosong = saran teman) */
    public function search(Request $request): JsonResponse
    {
        $me = $request->user();
        $q = ltrim(trim((string) $request->query('q', '')), '@');

        $query = User::query()->where('id', '!=', $me->id);

        if ($q === '') {
            $query->whereNotIn('id', $me->friendIds())->orderByDesc('id')->limit(20);
        } else {
            $like = '%'.str_replace(['\\', '%', '_'], ['\\\\', '\\%', '\\_'], $q).'%';
            $query->where(function ($w) use ($like) {
                $w->where('name', 'like', $like)->orWhere('username', 'like', $like);
            })->orderBy('name')->limit(30);
        }

        return response()->json(Presenter::users($query->get(), (int) $me->id));
    }

    /** POST /friends/request {user_id} */
    public function sendRequest(Request $request): JsonResponse
    {
        $data = $request->validate([
            'user_id' => ['required', 'integer', 'exists:users,id'],
        ], Msg::messages(), Msg::attributes());

        $me = $request->user();
        $target = User::findOrFail($data['user_id']);

        if ((int) $target->id === (int) $me->id) {
            throw ValidationException::withMessages([
                'user_id' => ['Tidak bisa menambahkan diri sendiri.'],
            ]);
        }

        $existing = Friendship::between((int) $me->id, (int) $target->id)->first();

        if (! $existing) {
            Friendship::create([
                'user_id' => $me->id,
                'friend_id' => $target->id,
                'status' => Friendship::PENDING,
            ]);
        } elseif ($existing->status === Friendship::PENDING && (int) $existing->user_id === (int) $target->id) {
            // Dia sudah lebih dulu meminta pertemanan -> langsung jadi teman.
            $existing->update(['status' => Friendship::ACCEPTED]);
        }

        return response()->json(
            Presenter::user($target, Friendship::relationBetween((int) $me->id, (int) $target->id))
        );
    }

    /** POST /friends/{id}/accept */
    public function accept(Request $request, int $id): JsonResponse
    {
        $me = $request->user();

        $row = Friendship::query()
            ->where('user_id', $id)
            ->where('friend_id', $me->id)
            ->where('status', Friendship::PENDING)
            ->first();

        if (! $row) {
            return response()->json(['message' => 'Permintaan pertemanan tidak ditemukan.'], 404);
        }

        $row->update(['status' => Friendship::ACCEPTED]);

        return response()->json(Presenter::user(User::findOrFail($id), 'friend'));
    }

    /** POST /friends/{id}/decline */
    public function decline(Request $request, int $id): JsonResponse
    {
        $me = $request->user();

        Friendship::query()
            ->where('user_id', $id)
            ->where('friend_id', $me->id)
            ->where('status', Friendship::PENDING)
            ->delete();

        return response()->json(Presenter::user(User::findOrFail($id), 'none'));
    }

    /** DELETE /friends/{id} -> hapus teman / batalkan permintaan yang saya kirim */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $me = $request->user();

        Friendship::between((int) $me->id, $id)
            ->where(function ($q) use ($me) {
                $q->where('status', Friendship::ACCEPTED)->orWhere('user_id', $me->id);
            })
            ->delete();

        return response()->json(['message' => 'Pertemanan dihapus.']);
    }
}
