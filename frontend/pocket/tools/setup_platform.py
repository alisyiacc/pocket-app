#!/usr/bin/env python3
"""Tambahkan izin kamera/internet ke folder android/ dan ios/ setelah `flutter create .`
Aman dijalankan berulang kali (idempotent).  Pakai:  python tools/setup_platform.py
"""
import os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def patch_android():
    p = os.path.join(ROOT, 'android', 'app', 'src', 'main', 'AndroidManifest.xml')
    if not os.path.exists(p):
        print('[android] AndroidManifest.xml belum ada (jalankan flutter create . dulu)'); return
    s = open(p, encoding='utf-8').read()
    perms = [
        'android.permission.INTERNET',
        'android.permission.CAMERA',
    ]
    add = ''
    for perm in perms:
        if perm not in s:
            add += f'    <uses-permission android:name="{perm}"/>\n'
    if add:
        s = re.sub(r'(<manifest[^>]*>\s*)', lambda m: m.group(1) + '\n' + add, s, count=1)
    if 'usesCleartextTraffic' not in s:
        s = s.replace('<application', '<application\n        android:usesCleartextTraffic="true"', 1)
    open(p, 'w', encoding='utf-8').write(s)
    print('[android] OK')

def patch_ios():
    p = os.path.join(ROOT, 'ios', 'Runner', 'Info.plist')
    if not os.path.exists(p):
        print('[ios] Info.plist belum ada (jalankan flutter create . dulu)'); return
    s = open(p, encoding='utf-8').read()
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
        s = s.replace('</dict>\n</plist>', add + '</dict>\n</plist>')
    open(p, 'w', encoding='utf-8').write(s)
    print('[ios] OK')

if __name__ == '__main__':
    patch_android(); patch_ios()
    print('Selesai. Jalankan: flutter pub get && flutter run')
