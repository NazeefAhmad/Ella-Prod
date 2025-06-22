class NotificationModel {
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final String? image;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.title,
    required this.body,
    this.data,
    this.image,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as Map<String, dynamic>?,
      image: json['image'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'data': data,
      'image': image,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
    };
  }

  NotificationModel copyWith({
    String? title,
    String? body,
    Map<String, dynamic>? data,
    String? image,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationModel(
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      image: image ?? this.image,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
} 