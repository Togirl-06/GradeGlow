class ChatSession {
  const ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ChatSession.fromMap(String id, Map<String, dynamic> data) {
    return ChatSession(
      id: id,
      title: data['title'] as String? ?? 'New chat',
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  ChatSession copyWith({
    String? title,
    DateTime? updatedAt,
  }) {
    return ChatSession(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
