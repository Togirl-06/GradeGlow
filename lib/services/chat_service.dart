import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../utils/api_error_messages.dart';
import '../utils/gamification.dart';
import '../utils/premium_access.dart';
import '../utils/tutor_limits.dart';
import 'subscription_service.dart';
import 'auth_service.dart';
import 'openai_service.dart';
import 'tutor_context_service.dart';
import 'user_service.dart';

class ChatSendRequest {
  const ChatSendRequest({
    this.text = '',
    this.imagePaths = const <String>[],
    this.videoPath,
    this.isVoice = false,
    this.voiceDurationSeconds,
  });

  final String text;
  final List<String> imagePaths;
  final String? videoPath;
  final bool isVoice;
  final int? voiceDurationSeconds;

  bool get isEmpty => text.trim().isEmpty && imagePaths.isEmpty && videoPath == null;
}

class ChatService extends ChangeNotifier {
  ChatService(
    this._auth,
    this._openAi,
    this._userService,
    this._tutorContext,
    this._subscription,
  );

  static const int historyLimit = 20;
  static const String _defaultTitle = 'New chat';

  final AuthService _auth;
  final OpenAiService _openAi;
  final UserService _userService;
  final TutorContextService _tutorContext;
  final SubscriptionService _subscription;

  String? _activeSessionId;
  String? get activeSessionId => _activeSessionId;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  final List<ChatSession> _demoSessions = <ChatSession>[];
  final Map<String, List<ChatMessage>> _demoMessagesBySession = <String, List<ChatMessage>>{};

  bool _isSending = false;
  bool get isSending => _isSending;

  ApiErrorInfo? _lastError;
  ApiErrorInfo? get lastError => _lastError;

  String? _lastAssistantReply;
  String? get lastAssistantReply => _lastAssistantReply;

  void clearError() {
    if (_lastError == null) return;
    _lastError = null;
    notifyListeners();
  }

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    final String? uid = _auth.uid;
    if (uid == null) {
      _initialized = true;
      return;
    }

    if (_auth.isDemoMode) {
      if (_demoSessions.isEmpty) {
        final ChatSession session = _createDemoSession();
        _demoSessions.add(session);
        _demoMessagesBySession[session.id] = <ChatMessage>[
          ChatMessage(
            id: '1',
            isUser: true,
            text: 'Explain integration by parts.',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          ChatMessage(
            id: '2',
            isUser: false,
            text:
                '## Integration by parts — Overview\n\n'
                '### The formula\n\n'
                '- **Key idea**: Swap a hard integral for an easier one using ∫ u dv = uv − ∫ v du.\n'
                '- **Pick `u` and `dv`**: choose `u` so its derivative gets simpler.\n'
                '- **Why it works**:\n'
                '  > "We\'re trading one integral for another that\'s usually easier to solve."\n\n'
                '### Example\n\n'
                '```python\n'
                '# ∫ x·e^x dx\n'
                'u = x          # du = dx\n'
                'dv = e**x      # v = e**x\n'
                'result = u * v - integral(v * du)\n'
                '```',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ];
        _activeSessionId = session.id;
      } else {
        _activeSessionId ??= _demoSessions.first.id;
      }
      _initialized = true;
      notifyListeners();
      return;
    }

    final QuerySnapshot<Map<String, dynamic>> sessions = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .get();

    if (sessions.docs.isEmpty) {
      await _migrateLegacyMessages(uid);
    }

    final QuerySnapshot<Map<String, dynamic>> afterMigrate = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .get();

    if (afterMigrate.docs.isEmpty) {
      await _createFirestoreSession(uid, title: _defaultTitle);
    } else {
      _activeSessionId = afterMigrate.docs.first.id;
    }

    _initialized = true;
    notifyListeners();
  }

  ChatSession _createDemoSession({String title = _defaultTitle}) {
    final DateTime now = DateTime.now();
    return ChatSession(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> _migrateLegacyMessages(String uid) async {
    final QuerySnapshot<Map<String, dynamic>> legacy = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chat_messages')
        .orderBy('createdAt', descending: false)
        .get();

    if (legacy.docs.isEmpty) return;

    final DateTime now = DateTime.now();
    final String sessionId = 'legacy-${now.millisecondsSinceEpoch}';
    await FirebaseFirestore.instance.collection('users').doc(uid).collection('chat_sessions').doc(sessionId).set(
      ChatSession(id: sessionId, title: 'Previous chat', createdAt: now, updatedAt: now).toMap(),
    );

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in legacy.docs) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chat_sessions')
          .doc(sessionId)
          .collection('messages')
          .doc(doc.id)
          .set(doc.data());
    }
    _activeSessionId = sessionId;
  }

  Stream<List<ChatSession>> watchSessions() {
    final String? uid = _auth.uid;
    if (uid == null) return Stream<List<ChatSession>>.value(<ChatSession>[]);

    if (_auth.isDemoMode) {
      return Stream<List<ChatSession>>.multi((StreamController<List<ChatSession>> controller) {
        void emit() {
          final List<ChatSession> sorted = List<ChatSession>.from(_demoSessions)
            ..sort((ChatSession a, ChatSession b) => b.updatedAt.compareTo(a.updatedAt));
          controller.add(sorted);
        }

        emit();
        void listener() => emit();
        addListener(listener);
        controller.onCancel = () => removeListener(listener);
      });
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => ChatSession.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<ChatMessage>> watchMessages() {
    final String? uid = _auth.uid;
    final String? sessionId = _activeSessionId;
    if (uid == null || sessionId == null) {
      return Stream<List<ChatMessage>>.value(<ChatMessage>[]);
    }

    if (_auth.isDemoMode) {
      return Stream<List<ChatMessage>>.multi((StreamController<List<ChatMessage>> controller) {
        void emit() {
          controller.add(List<ChatMessage>.from(_demoMessagesBySession[sessionId] ?? <ChatMessage>[]));
        }

        emit();
        void listener() => emit();
        addListener(listener);
        controller.onCancel = () => removeListener(listener);
      });
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => ChatMessage.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> startNewChat() async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    if (_auth.isDemoMode) {
      final ChatSession session = _createDemoSession();
      _demoSessions.insert(0, session);
      _demoMessagesBySession[session.id] = <ChatMessage>[];
      _activeSessionId = session.id;
      notifyListeners();
      return;
    }

    await _createFirestoreSession(uid, title: _defaultTitle);
    notifyListeners();
  }

  Future<void> selectSession(String sessionId) async {
    if (_activeSessionId == sessionId) return;
    _activeSessionId = sessionId;
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    if (_auth.isDemoMode) {
      _demoSessions.removeWhere((ChatSession s) => s.id == sessionId);
      _demoMessagesBySession.remove(sessionId);
      if (_activeSessionId == sessionId) {
        if (_demoSessions.isEmpty) {
          final ChatSession session = _createDemoSession();
          _demoSessions.add(session);
          _demoMessagesBySession[session.id] = <ChatMessage>[];
          _activeSessionId = session.id;
        } else {
          _activeSessionId = _demoSessions.first.id;
        }
      }
      notifyListeners();
      return;
    }

    final DocumentReference<Map<String, dynamic>> ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .doc(sessionId);

    final QuerySnapshot<Map<String, dynamic>> messages = await ref.collection('messages').get();
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in messages.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(ref);
    await batch.commit();

    if (_activeSessionId == sessionId) {
      final QuerySnapshot<Map<String, dynamic>> remaining = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chat_sessions')
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();
      if (remaining.docs.isEmpty) {
        await _createFirestoreSession(uid, title: _defaultTitle);
      } else {
        _activeSessionId = remaining.docs.first.id;
      }
    }
    notifyListeners();
  }

  Future<void> _createFirestoreSession(String uid, {required String title}) async {
    final DateTime now = DateTime.now();
    final String id = now.millisecondsSinceEpoch.toString();
    final ChatSession session = ChatSession(id: id, title: title, createdAt: now, updatedAt: now);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .doc(id)
        .set(session.toMap());
    _activeSessionId = id;
  }

  Future<void> sendMessage(ChatSendRequest request) async {
    if (request.isEmpty) return;

    final String? uid = _auth.uid;
    if (uid == null) return;

    await ensureInitialized();
    final String? sessionId = _activeSessionId;
    if (sessionId == null) return;

    final int mediaCount = TutorLimits.mediaCountInRequest(
      imagePaths: request.imagePaths,
      videoPath: request.videoPath,
    );
    if (mediaCount > 0 && !await _userService.canSendTutorMedia(_subscription.plan, mediaCount)) {
      _lastError = TutorLimits.mediaLimitReached;
      notifyListeners();
      return;
    }

    _isSending = true;
    _lastError = null;
    notifyListeners();

    try {
      final List<String> visionPaths = List<String>.from(request.imagePaths);
      String displayText = request.text.trim();
      String? mediaPath;
      ChatMediaType mediaType = ChatMediaType.none;

      if (request.videoPath != null) {
        mediaPath = request.videoPath;
        mediaType = ChatMediaType.video;
        final String? frame = await VideoThumbnail.thumbnailFile(
          video: request.videoPath!,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 720,
          quality: 80,
        );
        if (frame != null) {
          visionPaths.add(frame);
        }
        if (displayText.isEmpty) {
          displayText = 'Please help me with this video.';
        } else {
          displayText = '$displayText\n(Attached video — using a preview frame for vision.)';
        }
      } else if (request.imagePaths.isNotEmpty) {
        mediaPath = request.imagePaths.first;
        mediaType = ChatMediaType.image;
        if (displayText.isEmpty) {
          displayText = 'What do you see in this image? Help me study it.';
        }
      }

      final ChatMessage userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isUser: true,
        text: displayText,
        createdAt: DateTime.now(),
        mediaPath: mediaPath,
        mediaType: mediaType,
        isVoice: request.isVoice,
        voiceDurationSeconds: request.voiceDurationSeconds,
      );

      final List<Map<String, dynamic>> history =
          _auth.isDemoMode ? _buildDemoHistory(sessionId) : await _loadHistory(uid, sessionId);

      if (_auth.isDemoMode) {
        _demoMessagesBySession[sessionId]!.add(userMessage);
        _touchDemoSession(sessionId, displayText);
        notifyListeners();
      } else {
        await _saveMessage(uid, sessionId, userMessage);
        await _touchSession(uid, sessionId, displayText);
      }

      await _userService.recordTutorMedia(_subscription.plan, mediaCount);

      final String reply = await _openAi.tutorReply(
        history,
        displayText,
        courseContext: _tutorContext.context.toSystemPrompt(),
        imageFilePaths: visionPaths,
        premium: _subscription.isPremium,
      );

      _lastAssistantReply = reply;

      final ChatMessage aiMessage = ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}-ai',
        isUser: false,
        text: reply,
        createdAt: DateTime.now(),
      );

      if (_auth.isDemoMode) {
        _demoMessagesBySession[sessionId]!.add(aiMessage);
        _touchDemoSession(sessionId, null);
      } else {
        await _saveMessage(uid, sessionId, aiMessage);
        await _touchSession(uid, sessionId, null);
      }

      await _userService.recordStudyActivity(uid);
      await _userService.addXp(Gamification.xpTutorMessage);
      await _userService.incrementWeeklyStat(tutorSessions: 1);
    } on PremiumRequiredException catch (error) {
      _lastError = error.info;
      notifyListeners();
    } on Exception catch (error) {
      _lastError = ApiErrorMessages.fromException(error);
      notifyListeners();
    } catch (error) {
      _lastError = ApiErrorMessages.fromException(error);
      notifyListeners();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void _touchDemoSession(String sessionId, String? firstUserText) {
    final int index = _demoSessions.indexWhere((ChatSession s) => s.id == sessionId);
    if (index < 0) return;
    final ChatSession current = _demoSessions[index];
    String title = current.title;
    if (firstUserText != null && (title == _defaultTitle || title.isEmpty)) {
      title = _titleFromMessage(firstUserText);
    }
    _demoSessions[index] = current.copyWith(title: title, updatedAt: DateTime.now());
    _demoSessions.sort((ChatSession a, ChatSession b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> _touchSession(String uid, String sessionId, String? firstUserText) async {
    final DocumentReference<Map<String, dynamic>> ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .doc(sessionId);
    final DocumentSnapshot<Map<String, dynamic>> snap = await ref.get();
    if (!snap.exists) return;

    final ChatSession session = ChatSession.fromMap(sessionId, snap.data()!);
    String title = session.title;
    if (firstUserText != null && (title == _defaultTitle || title.isEmpty)) {
      title = _titleFromMessage(firstUserText);
    }
    await ref.update(<String, dynamic>{
      'title': title,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  String _titleFromMessage(String text) {
    final String cleaned = text.replaceAll('\n', ' ').trim();
    if (cleaned.length <= 48) return cleaned;
    return '${cleaned.substring(0, 48)}…';
  }

  List<Map<String, dynamic>> _buildDemoHistory(String sessionId) {
    final List<ChatMessage> all = _demoMessagesBySession[sessionId] ?? <ChatMessage>[];
    final List<ChatMessage> recent =
        all.length <= historyLimit ? all : all.sublist(all.length - historyLimit);
    return recent
        .map(
          (ChatMessage message) => <String, dynamic>{
            'role': message.isUser ? 'user' : 'assistant',
            'content': _historyText(message),
          },
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> _loadHistory(String uid, String sessionId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(historyLimit)
        .get();

    final List<Map<String, dynamic>> history = snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          final ChatMessage message = ChatMessage.fromMap(doc.id, doc.data());
          return <String, dynamic>{
            'role': message.isUser ? 'user' : 'assistant',
            'content': _historyText(message),
          };
        })
        .toList();

    return history.reversed.toList();
  }

  String _historyText(ChatMessage message) {
    if (message.mediaType == ChatMediaType.image) {
      return '${message.text}\n[Student attached a photo]';
    }
    if (message.mediaType == ChatMediaType.video) {
      return '${message.text}\n[Student attached a video]';
    }
    return message.text;
  }

  Future<List<Map<String, dynamic>>> _historyBeforeUserMessage({
    required String? uid,
    required String sessionId,
    required String userMessageId,
  }) async {
    final List<ChatMessage> ordered = _auth.isDemoMode
        ? List<ChatMessage>.from(_demoMessagesBySession[sessionId] ?? <ChatMessage>[])
        : await _loadOrderedMessages(uid!, sessionId);

    final int userIndex = ordered.indexWhere((ChatMessage m) => m.id == userMessageId);
    if (userIndex <= 0) return const <Map<String, dynamic>>[];

    final List<ChatMessage> prior = ordered.sublist(0, userIndex);
    final List<ChatMessage> recent =
        prior.length <= historyLimit ? prior : prior.sublist(prior.length - historyLimit);
    return recent
        .map(
          (ChatMessage message) => <String, dynamic>{
            'role': message.isUser ? 'user' : 'assistant',
            'content': _historyText(message),
          },
        )
        .toList();
  }

  Future<List<ChatMessage>> _loadOrderedMessages(String uid, String sessionId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('createdAt')
        .get();

    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => ChatMessage.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> _saveMessage(String uid, String sessionId, ChatMessage message) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .doc(sessionId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());
  }

  Future<void> _deleteMessage(String uid, String sessionId, String messageId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .doc(sessionId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> _deleteMessagesFromIndex(String uid, String sessionId, int fromIndex) async {
    final List<ChatMessage> ordered = await _loadOrderedMessages(uid, sessionId);
    if (fromIndex >= ordered.length) return;
    for (final ChatMessage message in ordered.sublist(fromIndex)) {
      await _deleteMessage(uid, sessionId, message.id);
    }
  }

  final Map<String, _BranchSlot> _branchSlots = <String, _BranchSlot>{};

  String _branchKey(String sessionId, int anchorIndex) => '$sessionId:$anchorIndex';

  int branchVersionCount(int anchorIndex) {
    final String? sessionId = _activeSessionId;
    if (sessionId == null) return 0;
    return _branchSlots[_branchKey(sessionId, anchorIndex)]?.versions.length ?? 0;
  }

  int activeBranchIndex(int anchorIndex) {
    final String? sessionId = _activeSessionId;
    if (sessionId == null) return 0;
    return _branchSlots[_branchKey(sessionId, anchorIndex)]?.activeIndex ?? 0;
  }

  Future<void> switchBranch({required int anchorIndex, required int direction}) async {
    final String? uid = _auth.uid;
    final String? sessionId = _activeSessionId;
    if (uid == null || sessionId == null) return;

    final _BranchSlot? slot = _branchSlots[_branchKey(sessionId, anchorIndex)];
    if (slot == null || slot.versions.length < 2) return;

    final int next = (slot.activeIndex + direction).clamp(0, slot.versions.length - 1);
    if (next == slot.activeIndex) return;

    slot.activeIndex = next;
    await _applyMessageTail(uid, sessionId, anchorIndex, slot.versions[next]);
    notifyListeners();
  }

  Future<void> _applyMessageTail(
    String uid,
    String sessionId,
    int anchorIndex,
    List<ChatMessage> tail,
  ) async {
    if (_auth.isDemoMode) {
      final List<ChatMessage> all = _demoMessagesBySession[sessionId] ?? <ChatMessage>[];
      _demoMessagesBySession[sessionId] = <ChatMessage>[
        ...all.sublist(0, anchorIndex),
        ...tail,
      ];
      return;
    }

    await _deleteMessagesFromIndex(uid, sessionId, anchorIndex);
    for (final ChatMessage message in tail) {
      await _saveMessage(uid, sessionId, message);
    }
  }

  /// ChatGPT-style edit: branch old tail, replace from this message onward.
  Future<void> editUserMessage({
    required ChatMessage message,
    required int messageIndex,
    required String newText,
  }) async {
    final String trimmed = newText.trim();
    if (_isSending || trimmed.isEmpty || !message.isUser) return;

    final String? uid = _auth.uid;
    if (uid == null) return;

    await ensureInitialized();
    final String? sessionId = _activeSessionId;
    if (sessionId == null) return;

    _isSending = true;
    _lastError = null;
    notifyListeners();

    try {
      final List<ChatMessage> ordered = _auth.isDemoMode
          ? List<ChatMessage>.from(_demoMessagesBySession[sessionId] ?? <ChatMessage>[])
          : await _loadOrderedMessages(uid, sessionId);

      if (messageIndex < 0 || messageIndex >= ordered.length) return;

      final List<ChatMessage> oldTail = ordered.sublist(messageIndex);
      final String branchKey = _branchKey(sessionId, messageIndex);
      final _BranchSlot slot = _branchSlots.putIfAbsent(branchKey, () => _BranchSlot());

      if (slot.versions.isEmpty || !_tailsEqual(slot.versions[slot.activeIndex], oldTail)) {
        slot.versions.add(_cloneTail(oldTail));
      }

      if (_auth.isDemoMode) {
        _demoMessagesBySession[sessionId] = ordered.sublist(0, messageIndex);
      } else {
        await _deleteMessagesFromIndex(uid, sessionId, messageIndex);
      }

      final List<Map<String, dynamic>> history = messageIndex == 0
          ? const <Map<String, dynamic>>[]
          : ordered
              .sublist(0, messageIndex)
              .map(
                (ChatMessage m) => <String, dynamic>{
                  'role': m.isUser ? 'user' : 'assistant',
                  'content': _historyText(m),
                },
              )
              .toList();

      final ChatMessage userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isUser: true,
        text: trimmed,
        createdAt: DateTime.now(),
        isVoice: message.isVoice,
        voiceDurationSeconds: message.voiceDurationSeconds,
      );

      if (_auth.isDemoMode) {
        _demoMessagesBySession[sessionId]!.add(userMessage);
        _touchDemoSession(sessionId, trimmed);
        notifyListeners();
      } else {
        await _saveMessage(uid, sessionId, userMessage);
        await _touchSession(uid, sessionId, trimmed);
      }

      final String reply = await _openAi.tutorReply(
        history,
        trimmed,
        courseContext: _tutorContext.context.toSystemPrompt(),
        imageFilePaths: const <String>[],
        premium: _subscription.isPremium,
      );

      _lastAssistantReply = reply;

      final ChatMessage aiMessage = ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}-ai',
        isUser: false,
        text: reply,
        createdAt: DateTime.now(),
      );

      if (_auth.isDemoMode) {
        _demoMessagesBySession[sessionId]!.add(aiMessage);
        _touchDemoSession(sessionId, null);
      } else {
        await _saveMessage(uid, sessionId, aiMessage);
        await _touchSession(uid, sessionId, null);
      }

      final List<ChatMessage> newTail = _auth.isDemoMode
          ? _demoMessagesBySession[sessionId]!.sublist(messageIndex)
          : <ChatMessage>[userMessage, aiMessage];

      if (slot.versions.isEmpty || !_tailsEqual(slot.versions.last, newTail)) {
        slot.versions.add(_cloneTail(newTail));
      }
      slot.activeIndex = slot.versions.length - 1;

      await _userService.recordStudyActivity(uid);
      await _userService.addXp(Gamification.xpTutorMessage);
      await _userService.incrementWeeklyStat(tutorSessions: 1);
    } on Exception catch (error) {
      _lastError = ApiErrorMessages.fromException(error);
      notifyListeners();
    } catch (error) {
      _lastError = ApiErrorMessages.fromException(error);
      notifyListeners();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  List<ChatMessage> _cloneTail(List<ChatMessage> tail) {
    return tail
        .map(
          (ChatMessage m) => ChatMessage(
            id: m.id,
            isUser: m.isUser,
            text: m.text,
            createdAt: m.createdAt,
            mediaPath: m.mediaPath,
            mediaType: m.mediaType,
            isVoice: m.isVoice,
            voiceDurationSeconds: m.voiceDurationSeconds,
          ),
        )
        .toList();
  }

  bool _tailsEqual(List<ChatMessage> a, List<ChatMessage> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].text != b[i].text || a[i].isUser != b[i].isUser) return false;
    }
    return true;
  }

  /// Replace one assistant reply (ChatGPT-style regenerate).
  Future<void> regenerateAssistantReply({
    required ChatMessage userMessage,
    required ChatMessage assistantMessage,
  }) async {
    if (_isSending) return;

    final String? uid = _auth.uid;
    if (uid == null) return;

    await ensureInitialized();
    final String? sessionId = _activeSessionId;
    if (sessionId == null) return;

    _isSending = true;
    _lastError = null;
    notifyListeners();

    try {
      if (_auth.isDemoMode) {
        _demoMessagesBySession[sessionId]?.removeWhere((ChatMessage m) => m.id == assistantMessage.id);
        notifyListeners();
      } else {
        await _deleteMessage(uid, sessionId, assistantMessage.id);
      }

      final List<Map<String, dynamic>> history = await _historyBeforeUserMessage(
        uid: uid,
        sessionId: sessionId,
        userMessageId: userMessage.id,
      );

      final String reply = await _openAi.tutorReply(
        history,
        userMessage.text,
        courseContext: _tutorContext.context.toSystemPrompt(),
        imageFilePaths: const <String>[],
        premium: _subscription.isPremium,
      );

      _lastAssistantReply = reply;

      final ChatMessage aiMessage = ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}-ai',
        isUser: false,
        text: reply,
        createdAt: DateTime.now(),
      );

      if (_auth.isDemoMode) {
        _demoMessagesBySession[sessionId]!.add(aiMessage);
      } else {
        await _saveMessage(uid, sessionId, aiMessage);
      }
    } on Exception catch (error) {
      _lastError = ApiErrorMessages.fromException(error);
      notifyListeners();
    } catch (error) {
      _lastError = ApiErrorMessages.fromException(error);
      notifyListeners();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}

class _BranchSlot {
  final List<List<ChatMessage>> versions = <List<ChatMessage>>[];
  int activeIndex = 0;
}
