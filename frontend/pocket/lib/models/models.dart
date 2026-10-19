import 'package:flutter/material.dart';
import '../core/utils.dart';

class User {
  final int id;
  final String name;
  final String username;
  final String? email;
  final String? avatarUrl;
  final String relation; // none | friend | pending_out | pending_in | me
  final int friendsCount;
  final int snapsCount;

  const User({
    required this.id,
    required this.name,
    required this.username,
    this.email,
    this.avatarUrl,
    this.relation = 'none',
    this.friendsCount = 0,
    this.snapsCount = 0,
  });

  Color get color => colorForId(id);

  String get initials {
    final t = name.trim().isEmpty ? username : name.trim();
    if (t.isEmpty) return '?';
    return (t.length >= 2 ? t.substring(0, 2) : t).toLowerCase();
  }

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'] as int,
        name: (j['name'] as String?) ?? '',
        username: (j['username'] as String?) ?? '',
        email: j['email'] as String?,
        avatarUrl: j['avatar_url'] as String?,
        relation: (j['relation'] as String?) ?? 'none',
        friendsCount: (j['friends_count'] as int?) ?? 0,
        snapsCount: (j['snaps_count'] as int?) ?? 0,
      );
}

class Reaction {
  final int userId;
  final String emoji;
  Reaction(this.userId, this.emoji);
  factory Reaction.fromJson(Map<String, dynamic> j) =>
      Reaction(j['user_id'] as int, j['emoji'] as String);
}

class Snap {
  final int id;
  final User sender;
  final String imageUrl;
  final String caption;
  final DateTime createdAt;
  final List<int> recipientIds;
  final List<Reaction> reactions;

  Snap({
    required this.id,
    required this.sender,
    required this.imageUrl,
    required this.caption,
    required this.createdAt,
    required this.recipientIds,
    required this.reactions,
  });

  factory Snap.fromJson(Map<String, dynamic> j) => Snap(
        id: j['id'] as int,
        sender: User.fromJson(j['sender'] as Map<String, dynamic>),
        imageUrl: (j['image_url'] as String?) ?? '',
        caption: (j['caption'] as String?) ?? '',
        createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
        recipientIds: ((j['recipient_ids'] as List?) ?? [])
            .map((e) => e as int)
            .toList(),
        reactions: ((j['reactions'] as List?) ?? [])
            .map((e) => Reaction.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Message {
  final int id;
  final int senderId;
  final String body;
  final int? snapId;
  final String? snapImageUrl;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.body,
    this.snapId,
    this.snapImageUrl,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> j) => Message(
        id: j['id'] as int,
        senderId: j['sender_id'] as int,
        body: (j['body'] as String?) ?? '',
        snapId: j['snap_id'] as int?,
        snapImageUrl: j['snap_image_url'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
      );
}

class Conversation {
  final User friend;
  final Message? lastMessage;
  final int unread;
  Conversation(this.friend, this.lastMessage, this.unread);

  factory Conversation.fromJson(Map<String, dynamic> j) => Conversation(
        User.fromJson(j['friend'] as Map<String, dynamic>),
        j['last_message'] == null
            ? null
            : Message.fromJson(j['last_message'] as Map<String, dynamic>),
        (j['unread'] as int?) ?? 0,
      );
}

class Rollcall {
  final int id;
  final String title;
  final String createdBy;
  final DateTime createdAt;
  final int photoCount;
  Rollcall(this.id, this.title, this.createdBy, this.createdAt, this.photoCount);

  factory Rollcall.fromJson(Map<String, dynamic> j) => Rollcall(
        j['id'] as int,
        (j['title'] as String?) ?? '',
        (j['created_by'] as String?) ?? '',
        DateTime.parse(j['created_at'] as String).toLocal(),
        (j['photo_count'] as int?) ?? 0,
      );
}
