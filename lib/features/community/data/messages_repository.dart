import 'package:wisdom/api/api_client.dart';
import 'package:wisdom/core/errors/app_failure.dart';

class MessagesRepository {
  MessagesRepository(this._client);

  final ApiClient _client;

  Future<List<MessageRecord>> listMessages(String channel) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/community/messages',
        queryParameters: {
          'channel': channel,
        },
      );
      final items = (response['items'] as List? ?? [])
          .map((item) => MessageRecord.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(growable: false);
      return items;
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<MessageRecord> sendMessage({
    required String channel,
    required String content,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/community/messages',
        body: {
          'channel': channel,
          'content': content,
        },
      );
      return MessageRecord.fromJson(response);
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }
}

class MessageRecord {
  const MessageRecord({
    required this.id,
    required this.channel,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String channel;
  final String senderId;
  final String content;
  final DateTime createdAt;

  factory MessageRecord.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'];
    return MessageRecord(
      id: json['id'] as String,
      channel: json['channel'] as String,
      senderId: json['sender_id'] as String,
      content: (json['content'] ?? '') as String,
      createdAt: created is String
          ? DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0)
          : created is DateTime
              ? created
              : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
