import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../config/app_branding.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../services/subscription_service.dart';
import '../services/tutor_context_service.dart';
import '../services/tutor_voice_service.dart';
import '../services/user_service.dart';
import '../theme/study_theme.dart';
import '../utils/api_error_messages.dart';
import '../utils/premium_access.dart';
import '../utils/tutor_limits.dart';
import '../widgets/api_error_banner.dart';
import '../widgets/study_surface.dart';
import '../widgets/tutor_limit_banner.dart';
import '../widgets/tutor_sidebar.dart';
import '../widgets/tutor_chat_bubbles.dart';
import '../widgets/tutor_composer.dart';
import '../widgets/tutor_message_edit_card.dart';
import '../widgets/tutor_uploads_sheet.dart';
import '../widgets/voice_note_recorder_bar.dart';

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key, this.initialPrompt});

  final String? initialPrompt;

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  final List<String> _pendingImages = <String>[];
  String? _pendingVideo;
  bool _hasScrolledToResume = false;
  int _lastRenderedMessageCount = 0;
  String? _lastSessionId;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _editController = TextEditingController();
  String? _editingMessageId;
  bool _savingEdit = false;
  final TutorVoiceService _voice = TutorVoiceService();
  bool _canListen = false;
  String? _voiceStatus;
  bool _voiceMode = false;
  bool _voiceNoteRecording = false;
  bool _transcribingVoiceNote = false;
  bool _processingVoiceTurn = false;
  String _partialTranscript = '';
  String _lastLiveVoiceSent = '';
  double _voiceNoteLevel = 0;
  int _listenElapsedSeconds = 0;
  Timer? _listenTimer;
  Timer? _voiceNoteMaxTimer;
  StreamSubscription<double>? _voiceNoteLevelSub;
  DateTime? _voiceModeStartedAt;
  DateTime? _lastSpeechActivityAt;

  bool _usingWhisperLive = false;

  static const Duration _liveVoicePauseFor = Duration(milliseconds: 800);
  static const Duration _liveVoiceListenFor = Duration(seconds: 45);
  static const Duration _liveVoiceIdleTimeout = Duration(seconds: 5);
  static const Duration _liveVoiceSessionTimeout = Duration(minutes: 8);
  static const Duration _voiceNoteMaxDuration = Duration(minutes: 2);
  static const Duration _postSpeakDelay = Duration.zero;
  static const Duration _liveVoiceMinCapture = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt != null) {
      _controller.text = widget.initialPrompt!;
    }
    _initVoice();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ChatService chat = context.read<ChatService>();
      final UserService users = context.read<UserService>();
      final SubscriptionService subs = context.read<SubscriptionService>();
      await chat.ensureInitialized();
      await users.refreshTutorUsage(subs.plan);
      if (widget.initialPrompt != null) {
        await chat.startNewChat();
        if (mounted) _controller.text = widget.initialPrompt!;
      }
      if (mounted) setState(() {});
    });
  }

  void _showMediaLimitSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(TutorLimits.mediaLimitReached.message)),
    );
  }

  int _pendingAttachmentCount() =>
      _pendingImages.length + (_pendingVideo != null ? 1 : 0);

  Future<bool> _canAddAttachments(int additional) async {
    final UserService users = context.read<UserService>();
    final SubscriptionService subs = context.read<SubscriptionService>();
    return users.canSendTutorMedia(subs.plan, _pendingAttachmentCount() + additional);
  }

  Future<void> _refreshTutorUsage() async {
    if (!mounted) return;
    final UserService users = context.read<UserService>();
    final SubscriptionService subs = context.read<SubscriptionService>();
    await users.refreshTutorUsage(subs.plan);
  }

  void _startEditingMessage(ChatMessage message) {
    setState(() {
      _editingMessageId = message.id;
      _editController.text = message.text;
      _editController.selection = TextSelection.fromPosition(
        TextPosition(offset: _editController.text.length),
      );
    });
  }

  void _cancelEditingMessage() {
    setState(() {
      _editingMessageId = null;
      _editController.clear();
    });
  }

  Future<void> _saveEditingMessage(ChatMessage message, int messageIndex, ChatService chat) async {
    final String text = _editController.text.trim();
    if (text.isEmpty || _savingEdit) return;

    setState(() => _savingEdit = true);
    try {
      await chat.editUserMessage(
        message: message,
        messageIndex: messageIndex,
        newText: text,
      );
      if (mounted) {
        setState(() {
          _editingMessageId = null;
          _editController.clear();
        });
        await _scrollToEnd();
      }
    } finally {
      if (mounted) setState(() => _savingEdit = false);
    }
  }

  VoidCallback _buildEditCallback(ChatMessage message) {
    return () {
      _startEditingMessage(message);
    };
  }

  Widget _buildUserMessageBubble({
    required ChatMessage message,
    required int index,
    required ChatService chat,
  }) {
    if (_editingMessageId == message.id) {
      return TutorMessageEditCard(
        controller: _editController,
        isSaving: _savingEdit || chat.isSending,
        onCancel: _cancelEditingMessage,
        onSave: () => _saveEditingMessage(message, index, chat),
      );
    }

    final int branches = chat.branchVersionCount(index);
    final int activeBranch = chat.activeBranchIndex(index);

    return TutorUserBubble(
      message: message,
      onEdit: _buildEditCallback(message),
      branchCount: branches,
      activeBranch: activeBranch,
      onPrevBranch: () => chat.switchBranch(anchorIndex: index, direction: -1),
      onNextBranch: () => chat.switchBranch(anchorIndex: index, direction: 1),
    );
  }

  Future<void> _regenerateReply(
    ChatService chat, {
    required ChatMessage userMessage,
    required ChatMessage assistantMessage,
  }) async {
    await chat.regenerateAssistantReply(
      userMessage: userMessage,
      assistantMessage: assistantMessage,
    );
    if (mounted) await _scrollToEnd();
  }

  @override
  void dispose() {
    _listenTimer?.cancel();
    _voiceNoteMaxTimer?.cancel();
    _voiceNoteLevelSub?.cancel();
    _voice.dispose();
    _controller.dispose();
    _editController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _ensureVoiceReady() async {
    final VoiceCapabilities cap = await _voice.initialize();
    if (!mounted) return false;
    setState(() {
      _canListen = cap.canListen;
      _voiceStatus = cap.statusMessage;
    });
    return cap.canListen;
  }

  void _showMicPermissionSnackBar(String message) {
    if (!mounted) return;
    final String text = kIsWeb
        ? '$message In your browser, click the lock icon in the address bar and allow Microphone.'
        : message;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 6),
        action: kIsWeb
            ? null
            : SnackBarAction(
                label: 'Settings',
                onPressed: openAppSettings,
              ),
      ),
    );
  }

  Future<void> _initVoice() async {
    await _ensureVoiceReady();
  }

  void _startListenTimer({bool forVoiceMode = false}) {
    _listenTimer?.cancel();
    _listenElapsedSeconds = 0;
    _listenTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _listenElapsedSeconds += 1);
      if (forVoiceMode) _checkVoiceModeTimeouts();
    });
  }

  void _checkVoiceModeTimeouts() {
    if (!mounted || !_voiceMode || _voiceModeStartedAt == null) return;
    final DateTime now = DateTime.now();
    if (now.difference(_voiceModeStartedAt!) >= _liveVoiceSessionTimeout) {
      _endVoiceModeWithMessage('Voice session ended after 8 minutes.');
      return;
    }
    // Don't idle-out while mic is open, tutor is replying, or a turn is processing.
    if (_usingWhisperLive ||
        _processingVoiceTurn ||
        _voice.isSpeaking ||
        _voice.isAudioCapturing ||
        context.read<ChatService>().isSending) {
      return;
    }
    if (_lastSpeechActivityAt == null) return;
    if (now.difference(_lastSpeechActivityAt!) >= _liveVoiceIdleTimeout) {
      _endVoiceModeWithMessage('Voice mode paused — no speech detected.');
    }
  }

  void _noteSpeechActivity([String? text]) {
    if (text != null && text.trim().isEmpty) return;
    _lastSpeechActivityAt = DateTime.now();
  }

  Future<void> _endVoiceModeWithMessage(String message) async {
    await _stopVoiceMode();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _stopListenTimer() {
    _listenTimer?.cancel();
    _listenTimer = null;
    _listenElapsedSeconds = 0;
  }

  void _startVoiceNoteLevelWatch() {
    _voiceNoteLevelSub?.cancel();
    if (_voice.isAudioCapturing) {
      _voiceNoteLevelSub = _voice.watchVoiceNoteLevel().listen((double level) {
        if (!mounted) return;
        setState(() => _voiceNoteLevel = level);
      });
    }
  }

  void _stopVoiceNoteLevelWatch() {
    _voiceNoteLevelSub?.cancel();
    _voiceNoteLevelSub = null;
    _voiceNoteLevel = 0;
  }

  Future<void> _pickImage() async {
    if (!await _canAddAttachments(1)) {
      _showMediaLimitSnackBar();
      return;
    }
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null || !mounted) return;
    setState(() {
      _pendingImages.add(file.path);
      _pendingVideo = null;
    });
  }

  Future<void> _pickVideo() async {
    if (!await _canAddAttachments(1)) {
      _showMediaLimitSnackBar();
      return;
    }
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    setState(() {
      _pendingVideo = file.path;
      _pendingImages.clear();
    });
  }

  Future<void> _sendMessage(
    ChatService chat, {
    String? forcedText,
    bool fromVoice = false,
    bool speakReply = false,
    bool preferFastTts = false,
  }) async {
    final String text = (forcedText ?? _controller.text).trim();
    if (text.isEmpty && _pendingImages.isEmpty && _pendingVideo == null) return;
    if (chat.isSending) return;

    final ChatSendRequest request = ChatSendRequest(
      text: text,
      imagePaths: List<String>.from(_pendingImages),
      videoPath: _pendingVideo,
      isVoice: fromVoice,
    );

    _controller.clear();
    setState(() {
      _pendingImages.clear();
      _pendingVideo = null;
    });

    await chat.sendMessage(request);
    await _refreshTutorUsage();
    await _scrollToEnd();

    if (!mounted || !speakReply) return;
    final String reply = chat.lastAssistantReply?.trim() ?? '';
    if (reply.isEmpty) return;
    final bool spoke = await _voice.speak(reply);
    if (!spoke && mounted) {
      final String detail = _voice.lastSpeakError ?? 'No available TTS voice.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not play voice reply: $detail')),
      );
    }
  }

  Future<void> _startVoiceNote() async {
    if (_voiceMode) await _stopVoiceMode();
    if (!mounted) return;
    if (_voiceNoteRecording || _transcribingVoiceNote) return;

    if (!await _voice.prepareForVoiceNoteCapture()) {
      _showMicPermissionSnackBar(
        kIsWeb
            ? 'Allow microphone access when your browser asks.'
            : (_voiceStatus ?? 'Allow microphone access for GradeGlow to use voice input.'),
      );
      return;
    }

    setState(() {
      _voiceNoteRecording = true;
      _partialTranscript = '';
      _voiceNoteLevel = 0.12;
    });
    _startListenTimer();

    if (_voice.usesWhisperVoiceNotes) {
      final bool startedAudio = await _voice.startVoiceNoteAudio();
      if (!startedAudio) {
        _voiceNoteMaxTimer?.cancel();
        _stopListenTimer();
        if (mounted) {
          setState(() {
            _voiceNoteRecording = false;
            _partialTranscript = '';
          });
          _showMicPermissionSnackBar(
            'Could not start recording. Allow microphone permission, then try again.',
          );
        }
        return;
      }
      _startVoiceNoteLevelWatch();
    } else {
      final bool startedPreview = await _voice.startVoiceNotePreview(
        onWords: (String words) {
          if (!mounted) return;
          _noteSpeechActivity(words);
          setState(() {
            _partialTranscript = words;
            if (words.trim().isNotEmpty) _voiceNoteLevel = 0.65;
          });
        },
      );
      if (!startedPreview && mounted) {
        _voiceNoteMaxTimer?.cancel();
        _stopListenTimer();
        setState(() {
          _voiceNoteRecording = false;
          _partialTranscript = '';
        });
        _showMicPermissionSnackBar(
          kIsWeb
              ? 'Could not access your browser microphone.'
              : (_voiceStatus ?? 'Could not start microphone for voice input.'),
        );
        return;
      }
    }

    _voiceNoteMaxTimer?.cancel();
    _voiceNoteMaxTimer = Timer(_voiceNoteMaxDuration, () {
      if (mounted && _voiceNoteRecording && !_transcribingVoiceNote) {
        _confirmVoiceNote();
      }
    });
  }

  Future<void> _cancelVoiceNote() async {
    _voiceNoteMaxTimer?.cancel();
    await _voice.stopVoiceNotePreview();
    await _voice.cancelVoiceNoteAudio();
    _stopVoiceNoteLevelWatch();
    _stopListenTimer();
    if (!mounted) return;
    setState(() {
      _voiceNoteRecording = false;
      _transcribingVoiceNote = false;
      _partialTranscript = '';
    });
  }

  Future<void> _confirmVoiceNote() async {
    if (!_voiceNoteRecording || _transcribingVoiceNote) return;
    _voiceNoteMaxTimer?.cancel();
    _stopListenTimer();
    setState(() => _transcribingVoiceNote = true);

    String text = '';
    try {
      if (_voice.isAudioCapturing) {
        text = (await _voice.finishVoiceNoteAudio())?.trim() ?? '';
      }
    } catch (error) {
      if (mounted) {
        final ApiErrorInfo info = ApiErrorMessages.fromException(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${info.title}: ${info.message}')),
        );
      }
    }
    await _voice.stopVoiceNotePreview();
    _stopVoiceNoteLevelWatch();

    final String fallback = _partialTranscript.trim();
    final String recognized = text.isNotEmpty ? text : fallback;
    if (mounted) {
      setState(() {
        _voiceNoteRecording = false;
        _transcribingVoiceNote = false;
        _partialTranscript = '';
      });
      if (recognized.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No speech detected. Speak for at least 2 seconds, then tap ✓.'),
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }
      _controller.text = recognized;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  Future<void> _toggleVoiceMode() async {
    if (_voiceMode) {
      await _stopVoiceMode();
      return;
    }
    if (_voiceNoteRecording || _transcribingVoiceNote) {
      await _cancelVoiceNote();
    }
    if (!mounted) return;

    final SubscriptionService subs = context.read<SubscriptionService>();
    if (!await PremiumAccess.checkAndPrompt(context, subs, feature: PremiumFeature.voiceTutor)) {
      return;
    }

    if (!await _voice.prepareForVoiceNoteCapture()) {
      _showMicPermissionSnackBar(
        kIsWeb
            ? 'Allow microphone access when your browser asks.'
            : (_voiceStatus ?? 'Voice mode needs microphone access.'),
      );
      return;
    }
    setState(() {
      _voiceMode = true;
      _partialTranscript = '';
      _voiceNoteLevel = 0.12;
      _lastLiveVoiceSent = '';
    });
    _voiceModeStartedAt = DateTime.now();
    _lastSpeechActivityAt = DateTime.now();
    await _beginLiveListening();
  }

  Future<void> _stopVoiceMode() async {
    await _voice.stopListening();
    await _voice.cancelVoiceNoteAudio();
    await _voice.stopSpeaking();
    _stopListenTimer();
    _voiceModeStartedAt = null;
    _lastSpeechActivityAt = null;
    _usingWhisperLive = false;
    if (!mounted) return;
    setState(() {
      _voiceMode = false;
      _partialTranscript = '';
      _voiceNoteLevel = 0;
      _processingVoiceTurn = false;
    });
  }

  Future<void> _beginLiveListening() async {
    if (!_voiceMode || _processingVoiceTurn || _usingWhisperLive) return;
    _usingWhisperLive = true;
    _startListenTimer(forVoiceMode: true);

    try {
      while (mounted && _voiceMode && !_processingVoiceTurn) {
        _lastSpeechActivityAt = DateTime.now();
        if (mounted) {
          setState(() {
            _partialTranscript = 'Speak now...';
            _voiceNoteLevel = 0.15;
          });
        }

        String? answer;
        try {
          answer = await _voice.captureSpokenAnswer(
            shouldContinue: () => mounted && _voiceMode && !_processingVoiceTurn,
            preferDeviceSpeech: true,
            onLevel: (double level) {
              if (!mounted) return;
              if (level >= 0.12) _noteSpeechActivity('speaking');
              setState(() => _voiceNoteLevel = level);
            },
            onPartial: (String words) {
              if (!mounted) return;
              _noteSpeechActivity(words);
              setState(() {
                _partialTranscript = words.trim().isEmpty ? 'Speak now...' : words;
              });
            },
            silenceFor: _liveVoicePauseFor,
            maxDuration: _liveVoiceListenFor,
            minCaptureDuration: _liveVoiceMinCapture,
            fastResume: true,
          );
        } catch (error) {
          if (mounted) {
            final ApiErrorInfo info = ApiErrorMessages.fromException(error);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${info.title}: ${info.message}')),
            );
          }
          break;
        }

        if (!mounted || !_voiceMode) break;

        if (answer == null) {
          _showMicPermissionSnackBar(
            'Microphone unavailable. Allow mic permission for GradeGlow, then try again.',
          );
          await _stopVoiceMode();
          return;
        }

        final String trimmed = answer.trim();
        if (trimmed.isNotEmpty) {
          await _handleLiveTranscript(trimmed);
          continue;
        }

        _lastSpeechActivityAt = DateTime.now();
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    } finally {
      _usingWhisperLive = false;
    }
  }

  Future<void> _handleLiveTranscript(String text) async {
    if (!mounted || !_voiceMode || _processingVoiceTurn) return;
    if (text == _lastLiveVoiceSent) return;

    _processingVoiceTurn = true;
    _lastLiveVoiceSent = text;
    final ChatService chat = context.read<ChatService>();

    await _voice.stopListening();
    await _voice.cancelVoiceNoteAudio();
    await _sendMessage(
      chat,
      forcedText: text,
      fromVoice: true,
      speakReply: true,
      preferFastTts: true,
    );

    if (!mounted) return;
    setState(() {
      _partialTranscript = '';
      _voiceNoteLevel = 0.12;
    });
    _processingVoiceTurn = false;
    _lastLiveVoiceSent = '';

    if (_voiceMode) {
      await Future<void>.delayed(_postSpeakDelay);
      if (mounted && _voiceMode) {
        _lastSpeechActivityAt = DateTime.now();
      }
    }
  }

  void _showMediaPicker() {
    TutorMediaPickerSheet.show(
      context,
      onPhoto: _pickImage,
      onVideo: _pickVideo,
    );
  }

  Future<void> _scrollToEnd({bool jump = false}) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!_scrollController.hasClients) return;
    final double target = _scrollController.position.maxScrollExtent;
    if (jump) {
      _scrollController.jumpTo(target);
      return;
    }
    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _scrollToResumePoint(List<ChatMessage> messages) {
    if (messages.isEmpty) return;
    final bool firstOpen = !_hasScrolledToResume;
    final bool newMessages = messages.length > _lastRenderedMessageCount;
    if (!firstOpen && !newMessages) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _lastRenderedMessageCount = messages.length;
      await _scrollToEnd(jump: firstOpen);
      _hasScrolledToResume = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ChatService chat = context.watch<ChatService>();
    final UserService users = context.watch<UserService>();
    final SubscriptionService subs = context.watch<SubscriptionService>();
    final TutorContextService tutorContext = context.watch<TutorContextService>();
    final TutorMediaUsage? usage = users.tutorUsage;
    final bool mediaLimitReached = usage?.isAtLimit ?? false;
    final bool liveVoicePremiumLocked = !subs.isPremium;
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final Brightness brightness = Theme.of(context).brightness;

    if (chat.activeSessionId != _lastSessionId) {
      _lastSessionId = chat.activeSessionId;
      _hasScrolledToResume = false;
      _lastRenderedMessageCount = 0;
      _editingMessageId = null;
    }

    if (liveVoicePremiumLocked && _voiceMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _voiceMode) unawaited(_stopVoiceMode());
      });
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth >= 720;
        final Widget sidebar = TutorSidebar(
          onCloseDrawer: wide ? null : () => Navigator.of(context).pop(),
        );

        return Scaffold(
          key: _scaffoldKey,
          drawer: wide
              ? null
              : Drawer(
                  width: 280,
                  child: sidebar,
                ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (wide)
                SizedBox(
                  width: 260,
                  child: sidebar,
                ),
              if (wide)
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: StudyColors.border(brightness),
                ),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                    _TutorTopBar(
                      wide: wide,
                      onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                      subtitle: chat.isInitialized ? 'AI ${AppBranding.name}' : 'Loading...',
                    ),
                    if (tutorContext.context.hasContext)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: StudySurfaceCard(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.school_outlined, color: StudyColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Context: ${tutorContext.context.displayLabel}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                              TextButton(onPressed: tutorContext.clear, child: const Text('Clear')),
                            ],
                          ),
                        ),
                      ),
                    if (usage != null && mediaLimitReached)
                      TutorLimitBanner(usage: usage)
                    else if (usage != null && !usage.isPremium)
                      TutorUsageHint(usage: usage),
                    if (_voiceStatus != null && !_canListen)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                        child: Text(
                          _voiceStatus!,
                          style: TextStyle(color: textSecondary, fontSize: 12),
                        ),
                      ),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 820),
                          child: _buildMessageList(chat, textSecondary),
                        ),
                      ),
                    ),
                    if (chat.lastError != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: ApiErrorBanner(error: chat.lastError!, onDismiss: chat.clearError),
                      ),
                    if (_pendingImages.isNotEmpty || _pendingVideo != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: _PendingMediaStrip(
                          imagePaths: _pendingImages,
                          videoPath: _pendingVideo,
                          onRemoveImage: (int index) => setState(() => _pendingImages.removeAt(index)),
                          onRemoveVideo: () => setState(() => _pendingVideo = null),
                        ),
                      ),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: TutorComposer(
                          controller: _controller,
                          isSending: chat.isSending,
                          isListening: (_voice.isListening || (_voiceMode && _voice.isAudioCapturing)) &&
                              !_voiceNoteRecording,
                          isVoiceNoteRecording: _voiceNoteRecording,
                          isTranscribing: _transcribingVoiceNote,
                          mediaLimitReached: mediaLimitReached,
                          liveTranscript: _partialTranscript,
                          voiceNoteLevel: _voiceNoteLevel,
                          voiceModeActive: _voiceMode,
                          isSpeaking: _voice.isSpeaking,
                          liveVoicePremiumLocked: liveVoicePremiumLocked,
                          onSend: () => _sendMessage(chat),
                          onAddPhotosAndFiles: _showMediaPicker,
                          onUploads: () => TutorUploadsSheet.show(context),
                          onStartVoiceNote: _startVoiceNote,
                          onCancelVoiceNote: _cancelVoiceNote,
                          onConfirmVoiceNote: _confirmVoiceNote,
                          onToggleVoiceMode: _toggleVoiceMode,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Text(
                        '${AppBranding.name} can make mistakes. Check important info.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textSecondary, fontSize: 11),
                      ),
                    ),
                      ],
                    ),
                    if (_voiceMode)
                      _LiveVoiceOverlay(
                        transcript: _partialTranscript,
                        isListening: _voice.isListening || (_voice.isAudioCapturing && _voiceMode),
                        isSpeaking: _voice.isSpeaking,
                        isProcessing: _processingVoiceTurn || chat.isSending,
                        level: _voiceNoteLevel,
                        onClose: _stopVoiceMode,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageList(ChatService chat, Color textSecondary) {
    return StreamBuilder<List<ChatMessage>>(
      key: ValueKey<String?>(chat.activeSessionId),
      stream: chat.watchMessages(),
      builder: (BuildContext context, AsyncSnapshot<List<ChatMessage>> snapshot) {
        final List<ChatMessage> messages = snapshot.data ?? <ChatMessage>[];
        _scrollToResumePoint(messages);

        if (messages.isEmpty && !chat.isSending) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Tap mic to speak or waveform for live voice mode.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, height: 1.4),
              ),
            ),
          );
        }

        final int extra = chat.isSending ? 1 : 0;

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length + extra,
          itemBuilder: (BuildContext context, int index) {
            if (chat.isSending && index == messages.length) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: StudySurfaceCard(
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Thinking...'),
                    ],
                  ),
                ),
              );
            }

            final ChatMessage message = messages[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Align(
                alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: message.isUser
                    ? _buildUserMessageBubble(message: message, index: index, chat: chat)
                    : TutorAssistantBubble(
                        message: message,
                        isSpeaking: _voice.isSpeaking,
                        onSpeak: () => _voice.speak(message.text),
                        onRegenerate: index > 0 && messages[index - 1].isUser
                            ? () => _regenerateReply(
                                  chat,
                                  userMessage: messages[index - 1],
                                  assistantMessage: message,
                                )
                            : null,
                      ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TutorTopBar extends StatelessWidget {
  const _TutorTopBar({
    required this.wide,
    required this.onMenu,
    required this.subtitle,
  });

  final bool wide;
  final VoidCallback onMenu;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: <Widget>[
          if (!wide)
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: onMenu,
              tooltip: 'Chat history',
            ),
          Expanded(
            child: Column(
              children: <Widget>[
                const Text(
                  'AI Tutor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(subtitle, style: TextStyle(color: textSecondary, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: textSecondary),
            onPressed: () {},
            tooltip: 'Options',
          ),
        ],
      ),
    );
  }
}

class _PendingMediaStrip extends StatelessWidget {
  const _PendingMediaStrip({
    required this.imagePaths,
    required this.videoPath,
    required this.onRemoveImage,
    required this.onRemoveVideo,
  });

  final List<String> imagePaths;
  final String? videoPath;
  final void Function(int index) onRemoveImage;
  final VoidCallback onRemoveVideo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          ...imagePaths.asMap().entries.map(
            (MapEntry<int, String> e) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(File(e.value), width: 72, height: 72, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => onRemoveImage(e.key),
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (videoPath != null)
            Stack(
              children: <Widget>[
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: StudyColors.primaryTint(Theme.of(context).brightness),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.videocam_rounded, color: StudyColors.primary, size: 32),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: onRemoveVideo,
                    child: const CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LiveVoiceOverlay extends StatelessWidget {
  const _LiveVoiceOverlay({
    required this.transcript,
    required this.isListening,
    required this.isSpeaking,
    required this.isProcessing,
    required this.level,
    required this.onClose,
  });

  final String transcript;
  final bool isListening;
  final bool isSpeaking;
  final bool isProcessing;
  final double level;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color bg = brightness == Brightness.dark ? const Color(0xFF121212) : Colors.white;
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final String status = isProcessing
        ? 'Thinking...'
        : isSpeaking
            ? 'AI is speaking...'
            : isListening
                ? 'Listening — pause when done'
                : 'Starting microphone...';
    return Positioned.fill(
      child: ColoredBox(
        color: bg.withValues(alpha: 0.96),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Text(
                      'AI Study Buddy',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text('How can I help today?', style: TextStyle(color: textSecondary)),
                const SizedBox(height: 24),
                VoiceNoteWaveform(level: level.clamp(0.1, 1.0), barCount: 38, height: 84),
                const SizedBox(height: 22),
                Text(status, style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Text(
                  transcript.isEmpty ? 'Start speaking...' : transcript,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: StudyColors.textPrimary(brightness), fontSize: 16, height: 1.35),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
