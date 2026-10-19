import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class AuthProvider extends ChangeNotifier {
  final _repo = AuthRepository();
  User? user;
  bool get loggedIn => user != null;

  Future<void> init() async {
    final t = await _repo.savedToken();
    if (t != null) {
      ApiClient.I.token = t;
      try {
        user = await _repo.me();
      } catch (_) {
        await _repo.clearToken();
      }
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    user = await _repo.login(email, password);
    notifyListeners();
  }

  Future<void> register(
      String name, String username, String email, String password) async {
    user = await _repo.register(name, username, email, password);
    notifyListeners();
  }

  Future<void> forgot(String email) => _repo.forgot(email);

  Future<void> refresh() async {
    try {
      user = await _repo.me();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> updateProfile(String name, String username) async {
    user = await _repo.updateProfile(name, username);
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (_) {}
    user = null;
    notifyListeners();
  }
}

class FriendsProvider extends ChangeNotifier {
  final _repo = FriendRepository();
  List<User> friends = [];
  List<User> requests = [];
  List<User> suggestions = [];
  bool loading = false;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      final r = await Future.wait([_repo.friends(), _repo.requests(), _repo.search('')]);
      friends = r[0];
      requests = r[1];
      suggestions = r[2];
    } catch (_) {}
    loading = false;
    notifyListeners();
  }

  Future<List<User>> search(String q) => _repo.search(q);

  Future<void> sendRequest(User u) async {
    await _repo.sendRequest(u.id);
    await load();
  }

  Future<void> accept(User u) async {
    await _repo.accept(u.id);
    await load();
  }

  Future<void> decline(User u) async {
    await _repo.decline(u.id);
    await load();
  }

  Future<void> remove(User u) async {
    await _repo.remove(u.id);
    await load();
  }

  void clear() {
    friends = [];
    requests = [];
    suggestions = [];
    notifyListeners();
  }
}

class SnapsProvider extends ChangeNotifier {
  final _repo = SnapRepository();
  List<Snap> all = [];
  int meId = 0;
  bool loading = false;

  List<Snap> get received => all.where((s) => s.sender.id != meId).toList();

  String? get lastPhotoPath {
    for (final s in all) {
      if (s.sender.id == meId && s.imageUrl.isNotEmpty) return s.imageUrl;
    }
    return all.isEmpty ? null : all.first.imageUrl;
  }

  Future<void> load(int me) async {
    meId = me;
    loading = true;
    notifyListeners();
    try {
      all = await _repo.list();
    } catch (_) {}
    loading = false;
    notifyListeners();
  }

  Future<int> send(String path, String caption, List<int> recipients) async {
    final s = await _repo.send(path, caption, recipients);
    all.insert(0, s);
    notifyListeners();
    return recipients.length;
  }

  Future<void> react(Snap s, String emoji) async {
    await _repo.react(s.id, emoji);
    s.reactions.removeWhere((r) => r.userId == meId);
    s.reactions.add(Reaction(meId, emoji));
    notifyListeners();
  }

  Future<void> remove(Snap s) async {
    await _repo.delete(s.id);
    all.removeWhere((e) => e.id == s.id);
    notifyListeners();
  }

  void clear() {
    all = [];
    notifyListeners();
  }
}

class ChatProvider extends ChangeNotifier {
  final _repo = ChatRepository();
  List<Conversation> conversations = [];
  bool loading = false;

  int get unread => conversations.fold(0, (a, c) => a + c.unread);

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      loading = true;
      notifyListeners();
    }
    try {
      conversations = await _repo.conversations();
    } catch (_) {}
    loading = false;
    notifyListeners();
  }

  Future<Message> send(int friendId, String body, {int? snapId}) async {
    final m = await _repo.send(friendId, body, snapId: snapId);
    load(silent: true);
    return m;
  }

  Future<List<Message>> messages(int friendId) => _repo.messages(friendId);

  void clear() {
    conversations = [];
    notifyListeners();
  }
}
