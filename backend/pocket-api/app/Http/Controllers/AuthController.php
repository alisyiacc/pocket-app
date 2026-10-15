<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Support\Msg;
use App\Support\Presenter;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Password;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\PersonalAccessToken;

class AuthController extends Controller
{
    /** POST /auth/register -> {token, user} */
    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'username' => ['required', 'string', 'regex:/^[A-Za-z0-9._]{3,20}$/', 'unique:users,username'],
            'email' => ['required', 'string', 'email', 'max:150', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6', 'max:100'],
        ], Msg::messages(), Msg::attributes());

        $user = User::create([
            'name' => trim($data['name']),
            'username' => $data['username'],
            'email' => strtolower(trim($data['email'])),
            'password' => Hash::make($data['password']),
        ]);

        return response()->json([
            'token' => $user->createToken('pocket-app')->plainTextToken,
            'user' => Presenter::me($user),
        ], 201);
    }

    /** POST /auth/login -> {token, user}. Kolom `email` juga boleh berisi username. */
    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'string'],
            'password' => ['required', 'string'],
        ], Msg::messages(), Msg::attributes());

        $login = trim($data['email']);
        $user = User::query()
            ->where(str_contains($login, '@') ? 'email' : 'username', $login)
            ->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Email atau kata sandi salah.'],
            ]);
        }

        return response()->json([
            'token' => $user->createToken('pocket-app')->plainTextToken,
            'user' => Presenter::me($user),
        ]);
    }

    /** POST /auth/logout -> hapus token yang sedang dipakai. */
    public function logout(Request $request): JsonResponse
    {
        $token = $request->user()->currentAccessToken();
        if ($token instanceof PersonalAccessToken) {
            $token->delete();
        }

        return response()->json(['message' => 'Berhasil keluar.']);
    }

    /**
     * POST /auth/forgot -> selalu membalas sukses (tidak membocorkan email terdaftar).
     * Tautan reset dikirim lewat email; dengan MAIL_MAILER=log tautan bisa dilihat
     * di storage/logs/laravel.log (cari "RESET LINK").
     */
    public function forgot(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'string', 'email'],
        ], Msg::messages(), Msg::attributes());

        try {
            Password::sendResetLink(['email' => $data['email']], function ($user, $token) {
                $url = route('password.reset', ['token' => $token, 'email' => $user->email]);

                Log::info('RESET LINK untuk '.$user->email.': '.$url);

                Mail::raw(
                    "Halo {$user->name},\n\nKlik tautan berikut untuk membuat kata sandi baru Pocket:\n{$url}\n\n"
                    ."Abaikan email ini jika kamu tidak memintanya.",
                    function ($message) use ($user) {
                        $message->to($user->email)->subject('Reset kata sandi Pocket');
                    }
                );
            });
        } catch (\Throwable $e) {
            Log::warning('Gagal memproses lupa kata sandi: '.$e->getMessage());
        }

        return response()->json([
            'message' => 'Jika email terdaftar, tautan reset kata sandi sudah dikirim.',
        ]);
    }
}
