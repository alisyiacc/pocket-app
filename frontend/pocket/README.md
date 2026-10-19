# Pocket 💛 (plesetan dari Locket Widget)

Proyek **UTS Pemrograman Aplikasi Bergerak 2026/2027** – Program Studi Sistem Informasi

| | |
|---|---|
| **Aplikasi asli** | Locket Widget |
| **Nama plesetan** | **Pocket** |
| **Kelompok** | 7 |
| **Tech stack** | Flutter (Dart) • REST API Laravel • MySQL (Laragon) |

## Anggota Kelompok

| No | Nama | NIM |
|----|------|-----|
| 1 | Alisya Bilbina | 24051214218 |
| 2 | Sharul Maulana S.B | 24051214219 |
| 3 | Rafi Ibrahim | 24051214224 |
| 4 | Ahmad Zidan | 24051214236 |

## Fitur (UI meniru Locket asli)

- Splash, onboarding 3 slide, daftar, masuk, lupa kata sandi (validasi form)
- **Kamera asli** (paket `camera`): preview squircle, flash off/auto/on, zoom 1x/2x/3x, flip kamera (tombol atau double-tap), pilih dari galeri; otomatis jatuh ke galeri jika kamera tidak tersedia (emulator/web tanpa kamera)
- Kirim foto: keterangan, pilih penerima (Semua / per teman), upload multipart
- **Riwayat**: penampil foto vertikal, filter pengirim, reaksi emoji, balas pesan, hapus Locket sendiri
- **Pockets**: kalender per bulan (titik = hari kosong, thumbnail = hari ada foto), tab **Rollcalls** (buat & lihat)
- **Obrolan**: daftar percakapan, badge belum dibaca, chat (polling 4 detik), balasan membawa thumbnail foto
- **Teman**: daftar, permintaan masuk (terima/tolak), cari username (debounce), saran, tautan undangan, hapus teman
- Profil, edit profil, panduan pasang widget, notifikasi & privasi (lokal), keluar
- Empty state persis Locket (belum ada teman / belum ada Locket)
- Layout HP di semua platform: di web/desktop tampilan dikunci selebar HP (430 px), penuh tinggi, tanpa celah

## Menjalankan Proyek

### 1. Siapkan (sekali saja)
```bash
python tools/setup_platform.py     # Windows: py tools/setup_platform.py
flutter pub get
```
Script ini otomatis menjalankan `flutter create .` (kalau folder `android/` belum ada), lalu menambah izin
`INTERNET` + `CAMERA` dan `usesCleartextTraffic="true"` (API Laragon memakai `http://`) di `AndroidManifest.xml`.
> Tanpa Python? Jalankan `flutter create . --project-name pocket_app --org com.kelompok7 --platforms=android,ios,web`, lalu di
> `android/app/src/main/AndroidManifest.xml` tambahkan `<uses-permission android:name="android.permission.INTERNET"/>`,
> `<uses-permission android:name="android.permission.CAMERA"/>` (di dalam `<manifest>`) dan `android:usesCleartextTraffic="true"` (di tag `<application>`).
> `minSdk` Android minimal 21.

### Menjalankan di Android Emulator
```bash
flutter emulators --launch <id_emulator>     # atau start dari Android Studio > Device Manager
flutter run --dart-define=USE_MOCK=true      # cek UI tanpa backend
flutter run                                  # dengan Laravel/Laragon (alamat otomatis 10.0.2.2)
```
Cek dari browser emulator: buka `http://10.0.2.2/pocket-api/public/api/ping`, harus tampil `{"app":"Pocket API","status":"ok",...}`.
Kalau memakai `php artisan serve` (bukan Apache Laragon), jalankan `php artisan serve --host=0.0.0.0 --port=8000` lalu
`flutter run --dart-define=API_URL=http://10.0.2.2:8000/api`.

### 2. Jalankan (mode Mock, tanpa backend – hanya untuk cek UI)
```bash
flutter run --dart-define=USE_MOCK=true                # pilih perangkat: Android / iOS / Chrome
flutter run -d chrome --dart-define=USE_MOCK=true      # Web (kamera butuh izin browser; localhost sudah aman)
```
Akun bebas: isi email apa saja + sandi minimal 6 karakter. Tambahkan `--dart-define=MOCK_EMPTY=true` untuk melihat tampilan akun baru tanpa teman.

### 3. Jalankan dengan Laravel + Laragon (default)
1. Laragon → **Start All** (Apache + MySQL), taruh API di `C:\laragon\www\pocket-api`.
2. Buat database `pocket`, lalu di folder `pocket-api` jalankan `php artisan migrate` (tanpa `--seed`). Setelah itu:
```bash
# Android Emulator (10.0.2.2 = laptop)
flutter run
# HP fisik: pakai IP LAN laptop
flutter run --dart-define=API_URL=http://192.168.1.10/pocket-api/public/api
```
Kontrak endpoint & bentuk JSON ada di [`docs/API.md`](docs/API.md). Frontend sudah memakai kontrak itu, jadi backend cukup mengikutinya.

## Troubleshooting Kamera

| Gejala | Solusi |
|---|---|
| Web: `cameraNotReadable` | Kamera dipakai program/tab lain. Tutup Zoom/Meet/Teams/OBS/app Camera Windows dan **semua tab lain** yang membuka Pocket, hentikan `flutter run` (tekan `q`), jalankan ulang, klik **Allow** saat Chrome meminta izin. Cek Windows: Settings → Privacy & security → Camera → izinkan aplikasi desktop. Jangan pakai hot restart berulang di web karena stream lama bisa tertinggal. |
| Web: tidak ada kamera | Gunakan tombol **Pilih dari galeri** (shutter otomatis membuka galeri). |
| Android: izin ditolak | Pengaturan → Aplikasi → Pocket → Izin → Kamera. Pastikan sudah menjalankan `tools/setup_platform.py`. |
| iOS: layar hitam / crash | Pastikan `NSCameraUsageDescription` ada di `Info.plist` (dibuat oleh `tools/setup_platform.py`). Kamera tidak ada di Simulator iOS, pakai iPhone asli. |
| Android Emulator | Kamera belakang default = kamera virtual (ruangan animasi). Untuk webcam: AVD Manager → Advanced Settings → Camera. |

## Arsitektur

```
lib/
├─ core/          config, theme, api_client (HTTP + multipart), mock_backend
├─ models/        User, Snap, Message, Conversation, Rollcall
├─ repositories/  akses endpoint (Auth, Friend, Snap, Chat, Rollcall)
├─ providers/     state (Provider/ChangeNotifier)
├─ widgets/       komponen UI bersama (squircle, shutter, nav pill, dll.)
└─ screens/       auth, camera, lockets, chat, friends, profile
```
Alur data: `Screen → Provider → Repository → ApiClient → (Mock | Laravel REST)`.
Mode Laravel adalah default; mode mock hanya aktif dengan `--dart-define=USE_MOCK=true`. Tidak ada kode UI yang berubah.

## Catatan
- Widget layar utama (home screen widget) belum dibuat; akan memakai paket `home_widget` setelah database tersambung.
- Foto dari kamera dikirim apa adanya; pemotongan persegi dilakukan di server/tahap berikutnya.
