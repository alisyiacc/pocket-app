<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ConversationController;
use App\Http\Controllers\FriendController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\RollcallController;
use App\Http\Controllers\SnapController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Pocket API  ->  http://HOST/pocket-api/public/api/...
|--------------------------------------------------------------------------
| Awalan /api otomatis. Kontrak lengkap: docs/API.md (proyek Flutter).
*/

Route::get('/ping', fn () => response()->json([
    'app' => 'Pocket API',
    'status' => 'ok',
    'time' => now()->toIso8601String(),
]));

// ---------- AUTH ----------
Route::prefix('auth')->group(function () {
    Route::middleware('throttle:30,1')->group(function () {
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login', [AuthController::class, 'login']);
        Route::post('/forgot', [AuthController::class, 'forgot']);
    });
    Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
});

// ---------- BUTUH LOGIN (Bearer token) ----------
Route::middleware('auth:sanctum')->group(function () {
    // Profil
    Route::get('/me', [ProfileController::class, 'show']);
    Route::put('/me', [ProfileController::class, 'update']);

    // Teman
    Route::get('/friends', [FriendController::class, 'index']);
    Route::get('/friends/requests', [FriendController::class, 'requests']);
    Route::get('/friends/search', [FriendController::class, 'search']);
    Route::post('/friends/request', [FriendController::class, 'sendRequest']);
    Route::post('/friends/{id}/accept', [FriendController::class, 'accept'])->whereNumber('id');
    Route::post('/friends/{id}/decline', [FriendController::class, 'decline'])->whereNumber('id');
    Route::delete('/friends/{id}', [FriendController::class, 'destroy'])->whereNumber('id');

    // Foto (Locket / Snap)
    Route::get('/snaps', [SnapController::class, 'index']);
    Route::post('/snaps', [SnapController::class, 'store']);
    Route::post('/snaps/{id}/reactions', [SnapController::class, 'react'])->whereNumber('id');
    Route::delete('/snaps/{id}', [SnapController::class, 'destroy'])->whereNumber('id');

    // Obrolan
    Route::get('/conversations', [ConversationController::class, 'index']);
    Route::get('/conversations/{friendId}/messages', [ConversationController::class, 'messages'])->whereNumber('friendId');
    Route::post('/conversations/{friendId}/messages', [ConversationController::class, 'send'])->whereNumber('friendId');

    // Rollcalls
    Route::get('/rollcalls', [RollcallController::class, 'index']);
    Route::post('/rollcalls', [RollcallController::class, 'store']);
});
