import 'dart:convert';
import 'config.dart';

/// Server palsu di memori yang meniru kontrak JSON Laravel (lihat docs/API.md).
/// Dipakai saat AppConfig.useMock = true sehingga UI bisa dites tanpa backend.
class MockBackend {
  MockBackend._();
  static final MockBackend I = MockBackend._();

  final Map<int, Map<String, dynamic>> _users = {};
  final Set<int> _friends = {};
  final Set<int> _incoming = {};
  final Set<int> _outgoing = {};
  final List<Map<String, dynamic>> _snaps = [];
  final Map<int, List<Map<String, dynamic>>> _msgs = {};
  final Map<int, int> _unread = {};
  final List<Map<String, dynamic>> _rolls = [];
  int _nextId = 1000;
  bool _seeded = false;

  String _ago(int minutes) => DateTime.now()
      .subtract(Duration(minutes: minutes))
      .toUtc()
      .toIso8601String();

  void _seed() {
    if (_seeded) return;
    _seeded = true;
    const names = [
      ['Dinda', 'dinda.a'], ['Raka', 'rakaprs'], ['Salsa', 'salsabila'],
      ['Bima', 'bimaaa'], ['Citra', 'citra.n'], ['Fajar', 'fajar_h'],
      ['Nadia', 'nadiaz'], ['Kevin', 'kevin.w'], ['Putri', 'putri.a'],
    ];
    for (var i = 0; i < names.length; i++) {
      final id = i + 2;
      _users[id] = {'id': id, 'name': names[i][0], 'username': names[i][1]};
    }
    if (AppConfig.mockEmpty) return;
    _friends.addAll([2, 3, 4, 5]);
    _incoming.addAll([7, 8]);
    const caps = [
      'ngopi dulu ☕', 'gas futsal', '', 'ngoding UTS 😭', 'sunset~',
      'makan siang', 'hujan lagi 🌧️', 'weekend vibes', 'baru bangun',
      'jalan sore', 'nugas bareng', '',
    ];
    const senders = [2, 3, 4, 5, 2, 3, 5, 4, 2, 3, 5, 4];
    const mins = [3, 40, 130, 320, 1500, 2900, 4300, 9000, 12000, 16000, 21000, 27000];
    for (var i = 0; i < caps.length; i++) {
      _snaps.add({
        'id': _nextId++,
        'sender_id': senders[i],
        'image_url': 'placeholder:$i',
        'caption': caps[i],
        'created_at': _ago(mins[i]),
        'recipient_ids': [1],
        'reactions': [],
      });
    }
    _msgs[2] = [
      {
        'id': _nextId++, 'sender_id': 2, 'body': 'jangan lupa UTS Flutter ya!',
        'snap_id': null, 'created_at': _ago(50),
      }
    ];
    _unread[2] = 1;
  }

  void _ensureMe() {
    if (!_users.containsKey(1)) {
      _users[1] = {
        'id': 1, 'name': 'Pocket User', 'username': 'pocketuser',
        'email': 'user@pocket.app',
      };
    }
  }

  String _rel(int id) {
    if (id == 1) return 'me';
    if (_friends.contains(id)) return 'friend';
    if (_outgoing.contains(id)) return 'pending_out';
    if (_incoming.contains(id)) return 'pending_in';
    return 'none';
  }

  Map<String, dynamic> _u(int id) => {..._users[id]!, 'relation': _rel(id)};

  Map<String, dynamic> _me() => {
        ..._u(1),
        'friends_count': _friends.length,
        'snaps_count': _snaps.where((s) => s['sender_id'] == 1).length,
      };

  Map<String, dynamic> _snapOut(Map<String, dynamic> s) =>
      {...s, 'sender': _u(s['sender_id'] as int)};

  Map<String, dynamic> _msgOut(Map<String, dynamic> m) {
    String? img;
    if (m['snap_id'] != null) {
      for (final s in _snaps) {
        if (s['id'] == m['snap_id']) img = s['image_url'] as String;
      }
    }
    return {...m, 'snap_image_url': img};
  }

  Never _fail(String msg, [int code = 422]) =>
      throw ApiException(msg, code);

  Future<dynamic> handle(String method, String path,
      {Map<String, String>? query, Map<String, dynamic>? body}) async {
    _seed();
    await Future.delayed(const Duration(milliseconds: 280));
    final r = _route(method, path, query ?? {}, body ?? {});
    return jsonDecode(jsonEncode(r));
  }

  Future<dynamic> upload(
      String path, Map<String, String> fields, String filePath) async {
    _seed();
    _ensureMe();
    await Future.delayed(const Duration(milliseconds: 700));
    final rec = fields.entries
        .where((e) => e.key.startsWith('recipient_ids'))
        .map((e) => int.parse(e.value))
        .toList();
    if (rec.isEmpty) _fail('Pilih minimal satu teman.');
    final s = <String, dynamic>{
      'id': _nextId++,
      'sender_id': 1,
      'image_url': filePath,
      'caption': fields['caption'] ?? '',
      'created_at': _ago(0),
      'recipient_ids': rec,
      'reactions': [],
    };
    _snaps.insert(0, s);
    // Simulasi: teman memberi reaksi 6 detik kemudian.
    Future.delayed(const Duration(seconds: 6), () {
      (s['reactions'] as List).add({'user_id': rec.first, 'emoji': '💛'});
    });
    return jsonDecode(jsonEncode(_snapOut(s)));
  }

  dynamic _route(String m, String path, Map<String, String> q,
      Map<String, dynamic> b) {
    if (!path.startsWith('/auth/')) _ensureMe();
    RegExpMatch? x;

    // ---------- AUTH ----------
    if (m == 'POST' && path == '/auth/register') {
      final name = '${b['name'] ?? ''}'.trim();
      final username = '${b['username'] ?? ''}'.trim();
      final email = '${b['email'] ?? ''}'.trim();
      if (name.isEmpty || username.isEmpty || email.isEmpty ||
          '${b['password'] ?? ''}'.length < 6) {
        _fail('Data belum lengkap atau kata sandi kurang dari 6 karakter.');
      }
      if (_users.values.any((u) => u['username'] == username && u['id'] != 1)) {
        _fail('Username sudah dipakai.');
      }
      _users[1] = {'id': 1, 'name': name, 'username': username, 'email': email};
      return {'token': 'mock-token', 'user': _me()};
    }
    if (m == 'POST' && path == '/auth/login') {
      final email = '${b['email'] ?? ''}'.trim();
      if (email.isEmpty || '${b['password'] ?? ''}'.isEmpty) {
        _fail('Email dan kata sandi wajib diisi.');
      }
      _ensureMe();
      if (_users[1]!['email'] != email && _users[1]!['name'] == 'Pocket User') {
        final p = email.split('@').first;
        _users[1] = {
          'id': 1,
          'name': p.isEmpty ? 'Pocket User' : p[0].toUpperCase() + p.substring(1),
          'username': p, 'email': email,
        };
      }
      return {'token': 'mock-token', 'user': _me()};
    }
    if (m == 'POST' && path == '/auth/logout') return {'message': 'ok'};
    if (m == 'POST' && path == '/auth/forgot') {
      return {'message': 'Tautan reset kata sandi dikirim ke email.'};
    }

    // ---------- PROFIL ----------
    if (m == 'GET' && path == '/me') return _me();
    if (m == 'PUT' && path == '/me') {
      final name = '${b['name'] ?? ''}'.trim();
      final username = '${b['username'] ?? ''}'.trim();
      if (name.isEmpty || username.isEmpty) _fail('Nama dan username wajib diisi.');
      if (_users.values.any((u) => u['username'] == username && u['id'] != 1)) {
        _fail('Username sudah dipakai.');
      }
      _users[1] = {..._users[1]!, 'name': name, 'username': username};
      return _me();
    }

    // ---------- TEMAN ----------
    if (m == 'GET' && path == '/friends') {
      return _friends.map(_u).toList();
    }
    if (m == 'GET' && path == '/friends/requests') {
      return _incoming.map(_u).toList();
    }
    if (m == 'GET' && path == '/friends/search') {
      final s = (q['q'] ?? '').trim().toLowerCase();
      return _users.values
          .where((u) {
            if (u['id'] == 1) return false;
            if (s.isEmpty) return !_friends.contains(u['id']);
            return '${u['name']}'.toLowerCase().contains(s) ||
                '${u['username']}'.toLowerCase().contains(s);
          })
          .map((u) => _u(u['id'] as int))
          .toList();
    }
    if (m == 'POST' && path == '/friends/request') {
      final id = b['user_id'] as int;
      _outgoing.add(id);
      // Simulasi: permintaan diterima otomatis setelah 5 detik.
      Future.delayed(const Duration(seconds: 5), () {
        if (_outgoing.remove(id)) _friends.add(id);
      });
      return _u(id);
    }
    x = RegExp(r'^/friends/(\d+)/(accept|decline)$').firstMatch(path);
    if (m == 'POST' && x != null) {
      final id = int.parse(x.group(1)!);
      _incoming.remove(id);
      if (x.group(2) == 'accept') _friends.add(id);
      return _u(id);
    }
    x = RegExp(r'^/friends/(\d+)$').firstMatch(path);
    if (m == 'DELETE' && x != null) {
      final id = int.parse(x.group(1)!);
      _friends.remove(id);
      _outgoing.remove(id);
      return {'message': 'ok'};
    }

    // ---------- SNAPS ----------
    if (m == 'GET' && path == '/snaps') {
      final list = _snaps
          .where((s) =>
              s['sender_id'] == 1 || (s['recipient_ids'] as List).contains(1))
          .toList()
        ..sort((a, c) =>
            (c['created_at'] as String).compareTo(a['created_at'] as String));
      return list.map(_snapOut).toList();
    }
    x = RegExp(r'^/snaps/(\d+)/reactions$').firstMatch(path);
    if (m == 'POST' && x != null) {
      final id = int.parse(x.group(1)!);
      final s = _snaps.firstWhere((e) => e['id'] == id,
          orElse: () => _fail('Pocket tidak ditemukan.', 404));
      final r = s['reactions'] as List;
      r.removeWhere((e) => e['user_id'] == 1);
      r.add({'user_id': 1, 'emoji': b['emoji']});
      return _snapOut(s);
    }
    x = RegExp(r'^/snaps/(\d+)$').firstMatch(path);
    if (m == 'DELETE' && x != null) {
      final id = int.parse(x.group(1)!);
      _snaps.removeWhere((e) => e['id'] == id && e['sender_id'] == 1);
      return {'message': 'ok'};
    }

    // ---------- OBROLAN ----------
    if (m == 'GET' && path == '/conversations') {
      final list = _friends.map((fid) {
        final l = _msgs[fid] ?? [];
        return <String, dynamic>{
          'friend': _u(fid),
          'last_message': l.isEmpty ? null : _msgOut(l.last),
          'unread': _unread[fid] ?? 0,
        };
      }).toList()
        ..sort((a, c) {
          final ta = a['last_message'] == null ? '' : a['last_message']['created_at'] as String;
          final tc = c['last_message'] == null ? '' : c['last_message']['created_at'] as String;
          return tc.compareTo(ta);
        });
      return list;
    }
    x = RegExp(r'^/conversations/(\d+)/messages$').firstMatch(path);
    if (x != null) {
      final fid = int.parse(x.group(1)!);
      final list = _msgs.putIfAbsent(fid, () => []);
      if (m == 'GET') {
        _unread[fid] = 0;
        return list.map(_msgOut).toList();
      }
      if (m == 'POST') {
        final text = '${b['body'] ?? ''}'.trim();
        if (text.isEmpty) _fail('Pesan kosong.');
        final msg = <String, dynamic>{
          'id': _nextId++, 'sender_id': 1, 'body': text,
          'snap_id': b['snap_id'], 'created_at': _ago(0),
        };
        list.add(msg);
        const replies = [
          'haha iya 😂', 'mantap!', 'wkwk', 'lagi di mana?', '💛',
          'nanti kabarin ya', 'gas!', 'ihh lucu banget',
        ];
        Future.delayed(const Duration(seconds: 2), () {
          list.add({
            'id': _nextId++, 'sender_id': fid,
            'body': replies[_nextId % replies.length],
            'snap_id': null, 'created_at': _ago(0),
          });
          _unread[fid] = (_unread[fid] ?? 0) + 1;
        });
        return _msgOut(msg);
      }
    }

    // ---------- ROLLCALL ----------
    if (m == 'GET' && path == '/rollcalls') return _rolls.reversed.toList();
    if (m == 'POST' && path == '/rollcalls') {
      final t = '${b['title'] ?? ''}'.trim();
      if (t.isEmpty) _fail('Judul Rollcall wajib diisi.');
      final r = {
        'id': _nextId++, 'title': t, 'created_by': _users[1]!['name'],
        'created_at': _ago(0), 'photo_count': 0,
      };
      _rolls.add(r);
      return r;
    }

    _fail('Endpoint mock tidak ditemukan: $m $path', 404);
  }
}
