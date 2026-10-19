<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Reset kata sandi - Pocket</title>
    <style>
        :root { color-scheme: dark; }
        * { box-sizing: border-box; }
        body {
            margin: 0; min-height: 100vh; display: flex; align-items: center; justify-content: center;
            background: #0f0f12; color: #f4f4f5; font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
            padding: 24px;
        }
        .card { width: 100%; max-width: 400px; background: #1b1b21; border-radius: 24px; padding: 32px 28px; }
        h1 { margin: 0 0 4px; font-size: 26px; color: #ffc933; }
        p { color: #a1a1aa; margin: 0 0 20px; line-height: 1.5; }
        label { display: block; font-size: 13px; color: #a1a1aa; margin: 14px 0 6px; }
        input {
            width: 100%; padding: 14px 16px; border-radius: 14px; border: 1px solid #2e2e38;
            background: #131318; color: #fff; font-size: 16px;
        }
        input:focus { outline: 2px solid #ffc933; border-color: transparent; }
        button {
            width: 100%; margin-top: 22px; padding: 14px; border: 0; border-radius: 999px;
            background: #ffc933; color: #1a1400; font-size: 16px; font-weight: 700; cursor: pointer;
        }
        .err { background: #3a1d22; color: #ff9aa8; padding: 12px 14px; border-radius: 12px; margin-bottom: 8px; font-size: 14px; }
        .ok { background: #1d3a2a; color: #8be5b0; padding: 16px; border-radius: 12px; line-height: 1.5; }
    </style>
</head>
<body>
<main class="card">
    <h1>Pocket 💛</h1>

    @if ($done ?? false)
        <div class="ok">
            Kata sandi berhasil diubah. Silakan kembali ke aplikasi Pocket dan masuk dengan kata sandi baru.
        </div>
    @else
        <p>Buat kata sandi baru untuk akunmu.</p>

        @if ($errors->any())
            <div class="err">{{ $errors->first() }}</div>
        @endif

        <form method="POST" action="{{ route('password.update') }}">
            @csrf
            <input type="hidden" name="token" value="{{ $token }}">

            <label for="email">Email</label>
            <input id="email" type="email" name="email" value="{{ old('email', $email) }}" required>

            <label for="password">Kata sandi baru (min. 6 karakter)</label>
            <input id="password" type="password" name="password" minlength="6" required>

            <label for="password_confirmation">Ulangi kata sandi baru</label>
            <input id="password_confirmation" type="password" name="password_confirmation" minlength="6" required>

            <button type="submit">Simpan kata sandi</button>
        </form>
    @endif
</main>
</body>
</html>
