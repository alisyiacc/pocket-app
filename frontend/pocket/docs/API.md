# Kontrak REST API Pocket (untuk Laravel)

Base URL: `http://<host>/pocket-api/public/api`  •  Auth: `Authorization: Bearer <token>` (Laravel Sanctum)
Semua respons JSON. Error validasi: HTTP 422 `{"message": "...", "errors": {"field": ["pesan"]}}`.
Respons boleh dibungkus `{"data": ...}` (Laravel Resource) atau tidak; Flutter menerima keduanya.

## Objek
- **User**: `{id, name, username, email?, avatar_url?, relation?, friends_count?, snaps_count?}`
  `relation`: `none | friend | pending_out | pending_in | me`
- **Snap**: `{id, sender: User, image_url, caption, created_at(ISO8601), recipient_ids:[int], reactions:[{user_id, emoji}]}`
- **Message**: `{id, sender_id, body, snap_id|null, snap_image_url|null, created_at}`
- **Conversation**: `{friend: User, last_message: Message|null, unread: int}`
- **Rollcall**: `{id, title, created_by(string), created_at, photo_count}`

## Endpoint

| Method | Path | Body / Query | Respons |
|---|---|---|---|
| POST | /auth/register | name, username, email, password | `{token, user}` |
| POST | /auth/login | email, password | `{token, user}` |
| POST | /auth/logout | – | `{message}` |
| POST | /auth/forgot | email | `{message}` |
| GET | /me | – | User (+friends_count, snaps_count) |
| PUT | /me | name, username | User |
| GET | /friends | – | [User] |
| GET | /friends/requests | – | [User] (permintaan masuk) |
| GET | /friends/search?q= | q kosong = saran | [User] dengan `relation` |
| POST | /friends/request | user_id | User |
| POST | /friends/{id}/accept | – | User |
| POST | /friends/{id}/decline | – | User |
| DELETE | /friends/{id} | – | `{message}` |
| GET | /snaps | – | [Snap] terkirim + diterima, terbaru dulu |
| POST | /snaps | **multipart**: `image` (file), `caption`, `recipient_ids[0]`, `recipient_ids[1]`… | Snap |
| POST | /snaps/{id}/reactions | emoji | Snap |
| DELETE | /snaps/{id} | – | `{message}` (hanya pemilik) |
| GET | /conversations | – | [Conversation] |
| GET | /conversations/{friendId}/messages | – | [Message] (urut lama→baru, tandai terbaca) |
| POST | /conversations/{friendId}/messages | body, snap_id? | Message |
| GET | /rollcalls | – | [Rollcall] |
| POST | /rollcalls | title | Rollcall |

## Skema tabel MySQL yang disarankan
`users`, `friendships(user_id, friend_id, status)`, `snaps(sender_id, image_path, caption)`,
`snap_recipients(snap_id, user_id)`, `snap_reactions(snap_id, user_id, emoji)`,
`messages(sender_id, receiver_id, body, snap_id, read_at)`, `rollcalls(title, created_by)`.
Jalankan `php artisan storage:link` agar `image_url` dapat diakses publik.
