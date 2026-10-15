import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../models/models.dart';

List<T> _parse<T>(dynamic r, T Function(Map<String, dynamic>) f) =>
    listOf(r).map((e) => f(e as Map<String, dynamic>)).toList();

class AuthRepository {
  Future<String?> savedToken() async =>
      (await SharedPreferences.getInstance()).getString('token');

  Future<void> _save(String t) async {
    ApiClient.I.token = t;
    await (await SharedPreferences.getInstance()).setString('token', t);
  }

  Future<void> clearToken() async {
    ApiClient.I.token = null;
    await (await SharedPreferences.getInstance()).remove('token');
  }

  Future<User> login(String email, String password) async {
    final r = await ApiClient.I
        .post('/auth/login', {'email': email, 'password': password});
    await _save(r['token'] as String);
    return User.fromJson(mapOf(r['user']));
  }

  Future<User> register(
      String name, String username, String email, String password) async {
    final r = await ApiClient.I.post('/auth/register', {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
    });
    await _save(r['token'] as String);
    return User.fromJson(mapOf(r['user']));
  }

  Future<User> me() async => User.fromJson(mapOf(await ApiClient.I.get('/me')));

  Future<User> updateProfile(String name, String username) async =>
      User.fromJson(mapOf(
          await ApiClient.I.put('/me', {'name': name, 'username': username})));

  Future<void> forgot(String email) =>
      ApiClient.I.post('/auth/forgot', {'email': email});

  Future<void> logout() async {
    try {
      await ApiClient.I.post('/auth/logout');
    } finally {
      await clearToken();
    }
  }
}

class FriendRepository {
  Future<List<User>> friends() async =>
      _parse(await ApiClient.I.get('/friends'), User.fromJson);
  Future<List<User>> requests() async =>
      _parse(await ApiClient.I.get('/friends/requests'), User.fromJson);
  Future<List<User>> search(String q) async => _parse(
      await ApiClient.I.get('/friends/search', query: {'q': q}), User.fromJson);
  Future<void> sendRequest(int userId) =>
      ApiClient.I.post('/friends/request', {'user_id': userId});
  Future<void> accept(int id) => ApiClient.I.post('/friends/$id/accept');
  Future<void> decline(int id) => ApiClient.I.post('/friends/$id/decline');
  Future<void> remove(int id) => ApiClient.I.delete('/friends/$id');
}

class SnapRepository {
  Future<List<Snap>> list() async =>
      _parse(await ApiClient.I.get('/snaps'), Snap.fromJson);

  Future<Snap> send(String filePath, String caption, List<int> recipients) async {
    final fields = <String, String>{'caption': caption};
    for (var i = 0; i < recipients.length; i++) {
      fields['recipient_ids[$i]'] = '${recipients[i]}';
    }
    final r = await ApiClient.I.upload('/snaps',
        fields: fields, fileField: 'image', filePath: filePath);
    return Snap.fromJson(mapOf(r));
  }

  Future<void> react(int snapId, String emoji) =>
      ApiClient.I.post('/snaps/$snapId/reactions', {'emoji': emoji});
  Future<void> delete(int snapId) => ApiClient.I.delete('/snaps/$snapId');
}

class ChatRepository {
  Future<List<Conversation>> conversations() async =>
      _parse(await ApiClient.I.get('/conversations'), Conversation.fromJson);

  Future<List<Message>> messages(int friendId) async => _parse(
      await ApiClient.I.get('/conversations/$friendId/messages'),
      Message.fromJson);

  Future<Message> send(int friendId, String body, {int? snapId}) async =>
      Message.fromJson(mapOf(await ApiClient.I.post(
          '/conversations/$friendId/messages',
          {'body': body, 'snap_id': snapId})));
}

class RollcallRepository {
  Future<List<Rollcall>> list() async =>
      _parse(await ApiClient.I.get('/rollcalls'), Rollcall.fromJson);
  Future<Rollcall> create(String title) async => Rollcall.fromJson(
      mapOf(await ApiClient.I.post('/rollcalls', {'title': title})));
}
