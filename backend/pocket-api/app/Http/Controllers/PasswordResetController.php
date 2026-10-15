<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Support\Msg;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;

/** Halaman web sederhana untuk tautan "Lupa kata sandi". */
class PasswordResetController extends Controller
{
    public function show(Request $request, string $token)
    {
        return view('auth.reset-password', [
            'token' => $token,
            'email' => (string) $request->query('email', ''),
            'done' => false,
        ]);
    }

    public function update(Request $request)
    {
        $request->validate([
            'token' => ['required', 'string'],
            'email' => ['required', 'string', 'email'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
        ], Msg::messages(), Msg::attributes());

        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function (User $user, string $password) {
                $user->forceFill(['password' => Hash::make($password)])->save();
                // Keluarkan semua perangkat yang masih login dengan sandi lama.
                $user->tokens()->delete();
            }
        );

        if ($status === Password::PASSWORD_RESET) {
            return view('auth.reset-password', ['token' => '', 'email' => '', 'done' => true]);
        }

        $message = match ($status) {
            Password::INVALID_TOKEN => 'Tautan tidak valid atau sudah kedaluwarsa. Minta tautan baru dari aplikasi.',
            Password::INVALID_USER => 'Email tidak terdaftar.',
            default => 'Terlalu banyak percobaan. Coba lagi sebentar lagi.',
        };

        return back()->withInput($request->only('email'))->withErrors(['email' => $message]);
    }
}
