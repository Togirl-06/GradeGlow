class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.createdAt,
    this.mediaPath,
    this.mediaType = ChatMediaType.none,
    this.isVoice = false,
    this.voiceDurationSeconds,
  });

  final String id;
  final bool isUser;
  final String text;
  final DateTime createdAt;
  /// Local file path for image/video preview in the chat bubble.
  final String? mediaPath;
  final ChatMediaType mediaType;
  /// Spoken user message (shows mic + duration like ChatGPT).
  final bool isVoice;
  final int? voiceDurationSeconds;

  bool get hasMedia => mediaPath != null && mediaPath!.isNotEmpty && mediaType != ChatMediaType.none;

  factory ChatMessage.fromMap(String id, Map<String, dynamic> data) {
    return ChatMessage(
      id: id,
      isUser: data['isUser'] as bool? ?? false,
      text: data['text'] as String? ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
      mediaPath: data['mediaPath'] as String?,
      mediaType: ChatMediaType.fromString(data['mediaType'] as String?),
      isVoice: data['isVoice'] as bool? ?? false,
      voiceDurationSeconds: (data['voiceDurationSeconds'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'isUser': isUser,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        if (mediaPath != null) 'mediaPath': mediaPath,
        if (mediaType != ChatMediaType.none) 'mediaType': mediaType.name,
        if (isVoice) 'isVoice': true,
        if (voiceDurationSeconds != null) 'voiceDurationSeconds': voiceDurationSeconds,
      };
}

enum ChatMediaType {
  none,
  image,
  video;

  static ChatMediaType fromString(String? value) {
    if (value == 'image') return ChatMediaType.image;
    if (value == 'video') return ChatMediaType.video;
    return ChatMediaType.none;
  }
}
