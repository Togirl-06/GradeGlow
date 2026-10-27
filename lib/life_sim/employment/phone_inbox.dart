/// The player's smartphone inbox: emails, texts and alerts.
library;

enum MessageKind { email, sms, alert }

class PhoneMessage {
  PhoneMessage({
    required this.id,
    required this.kind,
    required this.from,
    required this.subject,
    required this.body,
    required this.day,
    required this.minuteOfDay,
    this.read = false,
    this.action,
  });

  final int id;
  final MessageKind kind;
  final String from;
  final String subject;
  final String body;
  final int day;
  final int minuteOfDay;
  bool read;

  /// Optional deep link, e.g. `{'type': 'interview', 'applicationId': 'a3'}`.
  final Map<String, String>? action;

  String get timeLabel {
    final int h = minuteOfDay ~/ 60;
    final int m = minuteOfDay % 60;
    final int h12 = h % 12 == 0 ? 12 : h % 12;
    return 'Day $day · $h12:${m.toString().padLeft(2, '0')} ${h < 12 ? 'AM' : 'PM'}';
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'kind': kind.name,
        'from': from,
        'subject': subject,
        'body': body,
        'day': day,
        'minuteOfDay': minuteOfDay,
        'read': read,
        'action': action,
      };

  factory PhoneMessage.fromJson(Map<String, Object?> j) {
    final Object? a = j['action'];
    return PhoneMessage(
      id: (j['id'] as num?)?.toInt() ?? 0,
      kind: MessageKind.values.firstWhere(
        (MessageKind k) => k.name == j['kind'],
        orElse: () => MessageKind.alert,
      ),
      from: j['from'] as String? ?? '',
      subject: j['subject'] as String? ?? '',
      body: j['body'] as String? ?? '',
      day: (j['day'] as num?)?.toInt() ?? 1,
      minuteOfDay: (j['minuteOfDay'] as num?)?.toInt() ?? 0,
      read: j['read'] as bool? ?? false,
      action: a is Map
          ? a.map((Object? k, Object? v) => MapEntry<String, String>(k.toString(), v.toString()))
          : null,
    );
  }
}

class PhoneInbox {
  PhoneInbox({List<PhoneMessage>? messages, int nextId = 1})
      : messages = messages ?? <PhoneMessage>[],
        _nextId = nextId;

  static const int maxMessages = 120;

  final List<PhoneMessage> messages;
  int _nextId;

  int get nextIdValue => _nextId;
  void restoreNextId(int v) => _nextId = v;

  int get unreadCount => messages.where((PhoneMessage m) => !m.read).length;

  PhoneMessage add({
    required MessageKind kind,
    required String from,
    required String subject,
    required String body,
    required int day,
    required int minuteOfDay,
    Map<String, String>? action,
  }) {
    final PhoneMessage m = PhoneMessage(
      id: _nextId++,
      kind: kind,
      from: from,
      subject: subject,
      body: body,
      day: day,
      minuteOfDay: minuteOfDay,
      action: action,
    );
    messages.insert(0, m);
    while (messages.length > maxMessages) {
      messages.removeLast();
    }
    return m;
  }

  void markRead(int id) {
    for (final PhoneMessage m in messages) {
      if (m.id == id) m.read = true;
    }
  }

  void markAllRead() {
    for (final PhoneMessage m in messages) {
      m.read = true;
    }
  }

  List<PhoneMessage> ofKind(MessageKind k) =>
      messages.where((PhoneMessage m) => m.kind == k).toList();

  Map<String, Object?> toJson() => <String, Object?>{
        'nextId': _nextId,
        'messages': messages.map((PhoneMessage m) => m.toJson()).toList(),
      };

  factory PhoneInbox.fromJson(Map<String, Object?> j) {
    final Object? raw = j['messages'];
    return PhoneInbox(
      nextId: (j['nextId'] as num?)?.toInt() ?? 1,
      messages: raw is List
          ? raw
              .whereType<Map>()
              .map((Map m) => PhoneMessage.fromJson(Map<String, Object?>.from(m)))
              .toList()
          : <PhoneMessage>[],
    );
  }
}
