<?php

use App\Http\Controllers\PasswordResetController;
use Illuminate\Support\Facades\Route;

Route::get('/', fn () => response()->json([
    'app' => 'Pocket API',
    'status' => 'ok',
    'docs' => 'Endpoint ada di /api (contoh: /api/ping)',
]));

// Halaman reset kata sandi (tautan dikirim lewat email "Lupa kata sandi").
Route::get('/reset-password/{token}', [PasswordResetController::class, 'show'])->name('password.reset');
Route::post('/reset-password', [PasswordResetController::class, 'update'])->name('password.update');
