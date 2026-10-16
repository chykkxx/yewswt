import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
class UserItem {
  UserItem({
    required this.id,
    required this.name,
    required this.keyid,
    this.avatar='',
    this.tel='',
    this.nickname='',
    this.zhiwu='',
    this.created_at = '',
  });

  final int id;
  final String name;
  final String keyid;
  final String tel;
  final String nickname;
  final String zhiwu;
  final String avatar;
  final String created_at;
}
class ChatItem {
  ChatItem({
    required this.id,
    required this.name,
    required this.keyid,
    this.avatar='',
    this.time = 0,
    this.message = '',
    this.num = 0,
    this.zhiding = 0,
    this.nochuli = 0
  });

  final int id;
  final String name;
  final String keyid;
  final String avatar;
  final int time;
  final String message;
  final int num;
  final int zhiding;
  final int nochuli;
}

class Message {
  Message({
    required this.id,
    required this.name,
    required this.keyid,
    this.avatar='',
    this.time = '',
    this.message = '',
    this.num = 0,
  });

  final int id;
  final String name;
  final String keyid;
  final String avatar;
  final String time;
  final String message;
  final int num;
}

class ChatMessage {
  ChatMessage({
    required this.createdAt,
    required this.type,
    required this.status,
    required this.id,
    this.text='',
    required this.data ,
  });

  final int createdAt;
  final String type;
  final types.Status status;
  final String id;
  final String text;
  final Object data;
}

class FriendItem {
  FriendItem({
    required this.id,
    required this.name,
    required this.keyid,
    this.avatar='',
    this.created_at = '',
  });

  final int id;
  final String name;
  final String keyid;
  final String avatar;
  final String created_at;
}