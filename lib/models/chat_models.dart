class ChatRequest {
  final String userId;
  final String userName;
  final String message;

  ChatRequest({
    required this.userId,
    required this.userName,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'username': userName,
        'message': message,
      };
}

class ChatResponse {
  final String response;

  ChatResponse({required this.response});

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(response: json['response'] as String);
  }
}

class Message {
  final String content;
  final bool isUser;
  final String? emotion;
  final String? timestamp;

  Message({
    required this.content,
    required this.isUser,
    this.emotion,
    this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'] as String,
      isUser: json['type'] == 'human',
      emotion: json['emotion'] as String?,
      timestamp: json['timestamp'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'content': content,
        'type': isUser ? 'human' : 'ai',
        if (emotion != null) 'emotion': emotion,
        if (timestamp != null) 'timestamp': timestamp,
      };
}

class ChatHistoryResponse {
  final List<Message> messages;

  ChatHistoryResponse({required this.messages});

  factory ChatHistoryResponse.fromJson(dynamic json) {
    if (json is List) {
      // Handle direct list of messages
      return ChatHistoryResponse(
        messages: json.map((msg) => Message.fromJson(msg)).toList(),
      );
    } else if (json is Map<String, dynamic>) {
      // Handle response with messages object
      return ChatHistoryResponse(
        messages: (json['messages'] as List<dynamic>?)
            ?.map((msg) => Message.fromJson(msg))
            .toList() ?? [],
      );
    } else {
      throw Exception('Invalid response format: $json');
    }
  }
} 