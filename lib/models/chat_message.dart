class ChatMessage {
  final String id;
  final String message;
  final bool isBot;
  final DateTime timestamp;
  final List<String> quickReplies;
  final double? confidence; // NEW: confidence value between 0.0 - 1.0

  ChatMessage({
    required this.id,
    required this.message,
    required this.isBot,
    required this.timestamp,
    this.quickReplies = const [],
    this.confidence,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'message': message,
        'isBot': isBot,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'quickReplies': quickReplies,
        'confidence': confidence,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'],
        message: json['message'],
        isBot: json['isBot'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
        quickReplies: List<String>.from(json['quickReplies'] ?? []),
        confidence: json['confidence'] != null ? (json['confidence'] as num).toDouble() : null,
      );
}
