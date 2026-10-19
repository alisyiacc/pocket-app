<?php

namespace App\Http\Controllers;

use App\Models\Snap;
use App\Models\SnapReaction;
use App\Support\Msg;
use App\Support\Presenter;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class SnapController extends Controller
{
    private const RELATIONS = ['sender', 'recipients', 'reactions'];

    /** GET /snaps -> foto terkirim + diterima, terbaru dulu */
    public function index(Request $request): JsonResponse
    {
        $me = $request->user();

        $snaps = Snap::query()
            ->visibleTo((int) $me->id)
            ->with(self::RELATIONS)
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->limit(500)
            ->get();

        return response()->json(Presenter::snaps($snaps, (int) $me->id));
    }

    /** POST /snaps (multipart): image, caption, recipient_ids[] */
    public function store(Request $request): JsonResponse
    {
        $me = $request->user();

        $request->validate([
            'image' => ['required', 'file', 'image', 'mimes:jpg,jpeg,png,webp,gif', 'max:10240'],
            'caption' => ['nullable', 'string', 'max:60'],
            'recipient_ids' => ['required', 'array', 'min:1'],
            'recipient_ids.*' => ['integer', 'distinct'],
        ], Msg::messages(), Msg::attributes());

        // Foto hanya boleh dikirim ke teman yang sudah saling menerima.
        $recipientIds = collect($request->input('recipient_ids'))
            ->map(fn ($i) => (int) $i)
            ->unique()
            ->values();

        $notFriends = $recipientIds->diff($me->friendIds());
        if ($notFriends->isNotEmpty()) {
            throw ValidationException::withMessages([
                'recipient_ids' => ['Foto hanya bisa dikirim ke teman.'],
            ]);
        }

        // Simpan file langsung di public/uploads/snaps (tanpa symlink storage:link,
        // sehingga aman di Windows/Laragon).
        $file = $request->file('image');
        $ext = strtolower((string) ($file->guessExtension() ?: 'jpg'));
        if ($ext === 'jpeg') {
            $ext = 'jpg';
        }
        $name = (string) Str::uuid().'.'.$ext;
        $dir = public_path('uploads/snaps');
        if (! is_dir($dir)) {
            mkdir($dir, 0775, true);
        }
        $file->move($dir, $name);

        try {
            $snap = DB::transaction(function () use ($me, $name, $request, $recipientIds) {
                $snap = Snap::create([
                    'sender_id' => $me->id,
                    'image_path' => $name,
                    'caption' => (string) $request->input('caption', ''),
                ]);
                $snap->recipients()->attach($recipientIds->all());

                return $snap;
            });
        } catch (\Throwable $e) {
            if (is_file($dir.DIRECTORY_SEPARATOR.$name)) {
                @unlink($dir.DIRECTORY_SEPARATOR.$name);
            }
            throw $e;
        }

        $snap->load(self::RELATIONS);

        return response()->json(Presenter::snaps([$snap], (int) $me->id)[0], 201);
    }

    /** POST /snaps/{id}/reactions {emoji} -> reaksi baru menggantikan yang lama */
    public function react(Request $request, int $id): JsonResponse
    {
        $me = $request->user();

        $data = $request->validate([
            'emoji' => ['required', 'string', 'max:16'],
        ], Msg::messages(), Msg::attributes());

        $snap = Snap::query()->visibleTo((int) $me->id)->findOrFail($id);

        SnapReaction::updateOrCreate(
            ['snap_id' => $snap->id, 'user_id' => $me->id],
            ['emoji' => $data['emoji']]
        );

        $snap->load(self::RELATIONS);

        return response()->json(Presenter::snaps([$snap], (int) $me->id)[0]);
    }

    /** DELETE /snaps/{id} -> hanya pemilik */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $me = $request->user();
        $snap = Snap::query()->findOrFail($id);

        if ((int) $snap->sender_id !== (int) $me->id) {
            return response()->json(['message' => 'Hanya pemilik yang bisa menghapus foto ini.'], 403);
        }

        $path = public_path('uploads/snaps/'.basename((string) $snap->image_path));
        $snap->delete();

        if (is_file($path)) {
            @unlink($path);
        }

        return response()->json(['message' => 'Foto dihapus.']);
    }
}
