#!/usr/bin/env python3
"""Siapkan Pocket untuk Android (dan iOS) dalam SATU perintah:

    python tools/setup_platform.py          (Windows: bisa juga `py tools/setup_platform.py`)

Yang dilakukan:
  1. Kalau folder android/ belum ada -> jalankan `flutter create .` otomatis.
  2. Tambah izin INTERNET + CAMERA, fitur kamera (opsional), dan
     usesCleartextTraffic ke AndroidManifest.xml (API Laragon memakai http://, bukan https://).
  3. Tambah teks izin kamera/galeri ke ios/Runner/Info.plist.
  4. Cek minSdk Android >= 21 (syarat plugin `camera`).

Aman dijalankan berulang kali (idempotent).
"""
import os
import re
import shutil
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def read(p):
    with open(p, encoding='utf-8', newline='') as f:   # newline='' -> CRLF Windows tidak rusak
        return f.read()


def write(p, s):
    with open(p, 'w', encoding='utf-8', newline='') as f:
        f.write(s)


def ensure_platforms():
    if os.path.isdir(os.path.join(ROOT, 'android')):
        return True
    flutter = shutil.which('flutter')
    if not flutter:
        print('[!] Perintah `flutter` tidak ditemukan di PATH.')
        print('    Jalankan manual:  flutter create . --project-name pocket_app '
              '--org com.kelompok7 --platforms=android,ios,web')
        return False
    print('[android] Folder android/ belum ada -> menjalankan `flutter create .` ...')
    r = subprocess.run([flutter, 'create', '.', '--project-name', 'pocket_app',
                        '--org', 'com.kelompok7', '--platforms=android,ios,web'],
                       cwd=ROOT)
    return r.returncode == 0


def patch_android():
    p = os.path.join(ROOT, 'android', 'app', 'src', 'main', 'AndroidManifest.xml')
    if not os.path.exists(p):
        print('[android] AndroidManifest.xml belum ada (flutter create gagal?)')
        return
    s = read(p)
    nl = '\r\n' if '\r\n' in s else '\n'

    add = ''
    for perm in ('android.permission.INTERNET', 'android.permission.CAMERA'):
        if perm not in s:
            add += f'    <uses-permission android:name="{perm}"/>{nl}'
    if 'android.hardware.camera' not in s:
        add += (f'    <uses-feature android:name="android.hardware.camera" '
                f'android:required="false"/>{nl}')
    if add:
        s, n = re.subn(r'(<manifest\b[^>]*>[ \t]*\r?\n)', lambda m: m.group(1) + add,
                       s, count=1)
        if n == 0:
            print('[android] Tag <manifest> tidak ditemukan, tambahkan izin manual.')

    if 'usesCleartextTraffic' not in s:
        s = re.sub(r'<application\b', '<application' + nl +
                   '        android:usesCleartextTraffic="true"', s, count=1)
    write(p, s)
    print('[android] AndroidManifest.xml OK (INTERNET, CAMERA, cleartext http)')

    # minSdk harus >= 21 untuk plugin camera
    for name in ('build.gradle.kts', 'build.gradle'):
        g = os.path.join(ROOT, 'android', 'app', name)
        if os.path.exists(g):
            m = re.search(r'minSdk(?:Version)?\s*(?:=\s*)?(\d+)', read(g))
            if m and int(m.group(1)) < 21:
                print(f'[android] PERINGATAN: minSdk = {m.group(1)}, ubah menjadi 21 di {name}')
            break


def patch_ios():
    p = os.path.join(ROOT, 'ios', 'Runner', 'Info.plist')
    if not os.path.exists(p):
        print('[ios] Info.plist belum ada (dilewati)')
        return
    s = read(p)
    keys = {
        'NSCameraUsageDescription': 'Pocket butuh kamera untuk mengambil foto yang dikirim ke temanmu.',
        'NSPhotoLibraryUsageDescription': 'Pocket butuh akses galeri agar kamu bisa memilih foto.',
        'NSMicrophoneUsageDescription': 'Dibutuhkan oleh komponen kamera.',
    }
    add = ''
    for k, v in keys.items():
        if k not in s:
            add += f'\t<key>{k}</key>\n\t<string>{v}</string>\n'
    if 'NSAppTransportSecurity' not in s:
        add += ('\t<key>NSAppTransportSecurity</key>\n\t<dict>\n'
                '\t\t<key>NSAllowsArbitraryLoads</key>\n\t\t<true/>\n\t</dict>\n')
    if add:
        s = re.sub(r'(</dict>\s*</plist>)', lambda m: add + m.group(1), s, count=1)
        write(p, s)
    print('[ios] Info.plist OK')


if __name__ == '__main__':
    if ensure_platforms():
        patch_android()
        patch_ios()
        print('\nSelesai. Berikutnya:  flutter pub get  &&  flutter run')
    else:
        sys.exit(1)
