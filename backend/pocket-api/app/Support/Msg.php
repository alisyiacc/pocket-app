<?php

namespace App\Support;

/** Pesan validasi berbahasa Indonesia (tampil langsung di snackbar Flutter). */
class Msg
{
    public static function messages(): array
    {
        return [
            'required' => ':attribute wajib diisi.',
            'string' => ':attribute tidak valid.',
            'email' => 'Format email tidak valid.',
            'unique' => ':attribute sudah dipakai.',
            'exists' => ':attribute tidak ditemukan.',
            'integer' => ':attribute tidak valid.',
            'distinct' => ':attribute berisi data ganda.',
            'array' => ':attribute tidak valid.',
            'file' => ':attribute harus berupa file.',
            'image' => ':attribute harus berupa gambar.',
            'mimes' => ':attribute harus berformat :values.',
            'uploaded' => 'Gagal mengunggah :attribute. Periksa ukuran file.',
            'confirmed' => 'Konfirmasi :attribute tidak cocok.',
            'regex' => 'Format :attribute tidak valid.',
            'min' => [
                'string' => ':attribute minimal :min karakter.',
                'array' => 'Pilih minimal :min teman.',
                'numeric' => ':attribute minimal :min.',
                'file' => ':attribute minimal :min KB.',
            ],
            'max' => [
                'string' => ':attribute maksimal :max karakter.',
                'array' => ':attribute maksimal :max item.',
                'numeric' => ':attribute maksimal :max.',
                'file' => 'Ukuran :attribute maksimal :max KB.',
            ],
            // Pesan khusus per kolom
            'username.regex' => 'Username 3-20 karakter: huruf, angka, titik, atau underscore.',
            'recipient_ids.required' => 'Pilih minimal satu teman.',
            'body.required' => 'Pesan kosong.',
            'title.required' => 'Judul Rollcall wajib diisi.',
            'image.required' => 'Foto wajib diisi.',
        ];
    }

    public static function attributes(): array
    {
        return [
            'name' => 'Nama',
            'username' => 'Username',
            'email' => 'Email',
            'password' => 'Kata sandi',
            'caption' => 'Keterangan',
            'image' => 'Foto',
            'recipient_ids' => 'Penerima',
            'body' => 'Pesan',
            'snap_id' => 'Foto',
            'title' => 'Judul',
            'emoji' => 'Emoji',
            'user_id' => 'Pengguna',
        ];
    }
}
