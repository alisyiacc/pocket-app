<?php

namespace App\Http\Controllers;

use App\Models\Message;
use App\Models\Snap;
use App\Models\User;
use App\Support\Msg;
use App\Support\Presenter;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class ConversationController extends Controller
{
    /** GET /conversations -> satu baris per teman, yang terbaru di atas */
    public function index(Request $request): JsonResponse
    {
        $me = $request->user();
        $meId = (int) $me->id;

        $friends = User::query()->whereIn('id', $me->friendIds())->get();
        if ($friends->isEmpty()) {
            return response()->json([]);
        }

        // Id pesan terakhir untuk tiap lawan bicara.
        $lastIds = Message::query()
            ->selectRaw('MAX(id) as last_id')
            ->where(function ($q) use ($meId) {
                $q->where('sender_id', $meId)->orWhere('receiver_id', $meId);
            })
            ->groupByRaw('CASE WHEN sender_id = ? THEN receiver_id ELSE sender_id END', [$meId])
            ->pluck('last_id');

        $lastByPeer = Message::query()
            ->with('snap')
            ->whereIn('id', $lastIds)
            ->get()
            ->keyBy(function ($m) use ($meId) {
                return (int) $m->sender_id === $meId ? (int) $m->receiver_id : (int) $m->sender_id;
            });

        // Jumlah pesan belum dibaca per pengirim.
        $unread = Message::query()
            ->where('receiver_id', $meId)
            ->whereNull('read_at')
            ->selectRaw('sender_id, COUNT(*) as c')
            ->groupBy('sender_id')
            ->pluck('c', 'sender_id');

        $items = $friends->map(function (User $f) use ($lastByPeer, $unread) {
            $last = $lastByPeer->get((int) $f->id);

            return [
                'friend' => Presenter::user($f, 'friend'),
                'last_message' => $last ? Presenter::message($last) : null,
                'unread' => (int) ($unread[(int) $f->id] ?? 0),
                'sort_key' => $last ? $last->created_at->getTimestamp() : 0,
            ];
        })
            ->sortByDesc('sort_key')
            ->values()
            ->map(function (array $item) {
                unset($item['sort_key']);

                return $item;
            })
            ->all();

        return response()->json($items);
    }

    /** GET /conversations/{friendId}/messages -> lama ke baru, otomatis menandai terbaca */
    public function messages(Request $request, int $friendId): JsonResponse
    {
        $me = $request->user();
        $this->ensureFriend($me, $friendId);

        $messages = Message::query()
            ->with('snap')
            ->between((int) $me->id, $friendId)
            ->orderByDesc('id')
            ->limit(300)
            ->get()
            ->reverse()
            ->values();

        Message::query()
            ->where('sender_id', $friendId)
            ->where('receiver_id', $me->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json($messages->map(fn (Message $m) => Presenter::message($m))->all());
    }

    /** POST /conversations/{friendId}/messages {body, snap_id?} */
    public function send(Request $request, int $friendId): JsonResponse
    {
        $me = $request->user();

        $data = $request->validate([
            'body' => ['required', 'string', 'max:2000'],
            'snap_id' => ['nullable', 'integer'],
        ], Msg::messages(), Msg::attributes());

        $this->ensureFriend($me, $friendId);

        $snapId = null;
        if (! empty($data['snap_id'])) {
            $snap = Snap::query()->visibleTo((int) $me->id)->find($data['snap_id']);
            if (! $snap) {
                throw ValidationException::withMessages(['snap_id' => ['Foto tidak ditemukan.']]);
            }
            $snapId = $snap->id;
        }

        $message = Message::create([
            'sender_id' => $me->id,
            'receiver_id' => $friendId,
            'body' => $data['body'],
            'snap_id' => $snapId,
        ]);
        $message->load('snap');

        return response()->json(Presenter::message($message), 201);
    }

    private function ensureFriend(User $me, int $friendId): void
    {
        if (! $me->isFriendWith($friendId)) {
            abort(403, 'Kalian belum berteman.');
        }
    }
}
