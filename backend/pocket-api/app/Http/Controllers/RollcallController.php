<?php

namespace App\Http\Controllers;

use App\Models\Rollcall;
use App\Support\Msg;
use App\Support\Presenter;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RollcallController extends Controller
{
    /** GET /rollcalls -> buatan saya dan teman-teman saya, terbaru dulu */
    public function index(Request $request): JsonResponse
    {
        $me = $request->user();
        $ids = array_merge([(int) $me->id], $me->friendIds());

        $rolls = Rollcall::query()
            ->with('creator')
            ->whereIn('created_by', $ids)
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->limit(100)
            ->get();

        return response()->json($rolls->map(fn (Rollcall $r) => Presenter::rollcall($r))->all());
    }

    /** POST /rollcalls {title} */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title' => ['required', 'string', 'max:100'],
        ], Msg::messages(), Msg::attributes());

        $roll = Rollcall::create([
            'title' => trim($data['title']),
            'created_by' => $request->user()->id,
        ]);
        $roll->load('creator');

        return response()->json(Presenter::rollcall($roll), 201);
    }
}
