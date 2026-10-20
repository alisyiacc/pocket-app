<?php

namespace Database\Seeders;

use App\Models\Friendship;
use App\Models\Message;
use App\Models\Rollcall;
use App\Models\Snap;
use App\Models\SnapReaction;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

/**
 * Data demo Pocket. Semua akun memakai kata sandi: password123
 * Akun utama untuk demo: alisya@pocket.app
 */
class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $hash = Hash::make('password123');

        // ---------- USERS ----------
        $people = [
            ['alisya', 'Alisya Bilbina', 'alisya@pocket.app'],
            ['sharul', 'Sharul Maulana S.B', 'sharul@pocket.app'],
            ['rafi', 'Rafi Ibrahim', 'rafi@pocket.app'],
            ['zidan', 'Ahmad Zidan', 'zidan@pocket.app'],
            ['dinda.a', 'Dinda', 'dinda@pocket.app'],
            ['rakaprs', 'Raka', 'raka@pocket.app'],
            ['salsabila', 'Salsa', 'salsa@pocket.app'],
            ['bimaaa', 'Bima', 'bima@pocket.app'],
            ['citra.n', 'Citra', 'citra@pocket.app'],
            ['fajar_h', 'Fajar', 'fajar@pocket.app'],
            ['kevin.w', 'Kevin', 'kevin@pocket.app'],
            ['putri.a', 'Putri', 'putri@pocket.app'],
        ];

        $u = [];
        foreach ($people as [$username, $name, $email]) {
            $u[$username] = User::create([
                'name' => $name,
                'username' => $username,
                'email' => $email,
                'password' => $hash,
            ]);
        }

        // ---------- PERTEMANAN ----------
        $accepted = [
            ['alisya', 'sharul'], ['alisya', 'rafi'], ['alisya', 'zidan'],
            ['alisya', 'dinda.a'], ['alisya', 'rakaprs'],
            ['sharul', 'rafi'], ['rafi', 'zidan'],
        ];
        foreach ($accepted as [$a, $b]) {
            Friendship::create([
                'user_id' => $u[$a]->id,
                'friend_id' => $u[$b]->id,
                'status' => Friendship::ACCEPTED,
            ]);
        }

        // [pengirim, penerima] masih menunggu: kevin & putri meminta alisya, alisya meminta bima.
        $pending = [['kevin.w', 'alisya'], ['putri.a', 'alisya'], ['alisya', 'bimaaa']];
        foreach ($pending as [$from, $to]) {
            Friendship::create([
                'user_id' => $u[$from]->id,
                'friend_id' => $u[$to]->id,
                'status' => Friendship::PENDING,
            ]);
        }

        // ---------- FOTO (butuh ekstensi GD untuk membuat gambar contoh) ----------
        $snaps = [];
        if (function_exists('imagecreatetruecolor') && function_exists('imagejpeg')) {
            $dir = public_path('uploads/snaps');
            if (! is_dir($dir)) {
                mkdir($dir, 0775, true);
            }

            $items = [
                ['dinda.a', ['alisya'], 'ngopi dulu ☕', 3],
                ['rakaprs', ['alisya'], 'gas futsal', 40],
                ['sharul', ['alisya', 'rafi'], '', 130],
                ['rafi', ['alisya'], 'ngoding UTS 😭', 320],
                ['zidan', ['alisya', 'rafi'], 'sunset~', 1500],
                ['dinda.a', ['alisya'], 'makan siang', 2900],
                ['rafi', ['alisya'], 'hujan lagi 🌧️', 4300],
                ['alisya', ['sharul', 'rafi', 'zidan'], 'nugas bareng', 600],
                ['alisya', ['dinda.a'], 'weekend vibes', 9000],
            ];

            foreach ($items as $i => [$sender, $recipients, $caption, $minutesAgo]) {
                $file = 'demo-'.($i + 1).'.jpg';
                $this->makeImage($dir.DIRECTORY_SEPARATOR.$file, $i);

                $snap = new Snap([
                    'sender_id' => $u[$sender]->id,
                    'image_path' => $file,
                    'caption' => $caption,
                ]);
                $snap->created_at = now()->subMinutes($minutesAgo);
                $snap->updated_at = now()->subMinutes($minutesAgo);
                $snap->save();
                $snap->recipients()->attach(array_map(fn ($r) => $u[$r]->id, $recipients));

                $snaps[] = $snap;
            }

            SnapReaction::create(['snap_id' => $snaps[0]->id, 'user_id' => $u['alisya']->id, 'emoji' => '💛']);
            SnapReaction::create(['snap_id' => $snaps[7]->id, 'user_id' => $u['sharul']->id, 'emoji' => '😂']);
            SnapReaction::create(['snap_id' => $snaps[7]->id, 'user_id' => $u['rafi']->id, 'emoji' => '🔥']);
        } else {
            $this->command->warn('Ekstensi PHP "gd" tidak aktif: foto contoh dilewati (fitur lain tetap jalan).');
        }

        // ---------- PESAN ----------
        $this->msg($u['dinda.a'], $u['alisya'], 'eh udah liat foto kopinya?', 55, true, $snaps[0]->id ?? null);
        $this->msg($u['alisya'], $u['dinda.a'], 'udah dong, lucu banget 😂', 52, true);
        $this->msg($u['dinda.a'], $u['alisya'], 'jangan lupa UTS Flutter ya!', 50, false);
        $this->msg($u['dinda.a'], $u['alisya'], 'ngumpul jam 7 di kafe biasa', 49, false);
        $this->msg($u['sharul'], $u['alisya'], 'laporan UTS udah kamu kirim?', 300, true);
        $this->msg($u['alisya'], $u['sharul'], 'udah tadi malem', 290, true);

        // ---------- ROLLCALL ----------
        $rolls = [
            ['Futsal Sabtu', 'rakaprs', 4000],
            ['Liburan Semester', 'alisya', 2000],
            ['Nugas Bareng', 'dinda.a', 500],
        ];
        foreach ($rolls as [$title, $creator, $minutesAgo]) {
            $r = new Rollcall(['title' => $title, 'created_by' => $u[$creator]->id]);
            $r->created_at = now()->subMinutes($minutesAgo);
            $r->updated_at = now()->subMinutes($minutesAgo);
            $r->save();
        }

        $this->command->info('Data demo siap. Masuk dengan alisya@pocket.app / password123');
    }

    private function msg(User $from, User $to, string $body, int $minutesAgo, bool $read, ?int $snapId = null): void
    {
        $m = new Message([
            'sender_id' => $from->id,
            'receiver_id' => $to->id,
            'body' => $body,
            'snap_id' => $snapId,
            'read_at' => $read ? now()->subMinutes($minutesAgo) : null,
        ]);
        $m->created_at = now()->subMinutes($minutesAgo);
        $m->updated_at = now()->subMinutes($minutesAgo);
        $m->save();
    }

    /** Gambar persegi bergradasi warna hangat (pengganti foto asli untuk demo). */
    private function makeImage(string $path, int $seed): void
    {
        $palettes = [
            [255, 196, 86, 255, 112, 90],
            [96, 165, 250, 139, 92, 246],
            [74, 222, 128, 20, 184, 166],
            [251, 146, 60, 244, 63, 94],
            [244, 114, 182, 168, 85, 247],
            [253, 224, 71, 249, 115, 22],
        ];
        [$r1, $g1, $b1, $r2, $g2, $b2] = $palettes[$seed % count($palettes)];

        $size = 640;
        $im = imagecreatetruecolor($size, $size);

        for ($y = 0; $y < $size; $y++) {
            $t = $y / ($size - 1);
            $color = imagecolorallocate(
                $im,
                (int) ($r1 + ($r2 - $r1) * $t),
                (int) ($g1 + ($g2 - $g1) * $t),
                (int) ($b1 + ($b2 - $b1) * $t)
            );
            imageline($im, 0, $y, $size, $y, $color);
        }

        $white = imagecolorallocate($im, 255, 255, 255);
        imagefilledellipse($im, (int) ($size * 0.5), (int) ($size * 0.42), 240, 240, $white);
        imagestring($im, 5, 24, $size - 44, 'Pocket demo #'.($seed + 1), $white);

        imagejpeg($im, $path, 88);
    }
}
