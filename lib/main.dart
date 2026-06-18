import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_bootstrap.dart';
import 'config/app_branding.dart';
import 'screens/app_shell.dart';
import 'widgets/recording_bar_overlay.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/appearance_service.dart';
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'services/course_service.dart';
import 'services/flashcard_service.dart';
import 'services/lecture_recording_service.dart';
import 'services/mic_capture_service.dart';
import 'services/recording_bin_service.dart';
import 'services/material_service.dart';
import 'services/notes_summarizer_service.dart';
import 'services/openai_service.dart';
import 'services/pomodoro_service.dart';
import 'services/practice_exam_service.dart';
import 'services/subscription_service.dart';
import 'services/question_service.dart';
import 'services/solution_service.dart';
import 'services/study_planner_service.dart';
import 'services/todo_service.dart';
import 'services/tutor_context_service.dart';
import 'services/user_service.dart';
import 'theme/study_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.initialize();
  final AppearanceService appearanceService = AppearanceService();
  await appearanceService.ensureLoaded();
  runApp(GradeGlowApp(appearanceService: appearanceService));
}

class GradeGlowApp extends StatefulWidget {
  const GradeGlowApp({super.key, required this.appearanceService});

  final AppearanceService appearanceService;

  @override
  State<GradeGlowApp> createState() => _GradeGlowAppState();
}

class _GradeGlowAppState extends State<GradeGlowApp> {
  late final AuthService _authService;
  late final UserService _userService;
  late final OpenAiService _openAiService;
  late final QuestionService _questionService;
  late final MaterialService _materialService;
  late final SolutionService _solutionService;
  late final CourseService _courseService;
  late final FlashcardService _flashcardService;
  late final TutorContextService _tutorContextService;
  late final ChatService _chatService;
  late final NotesSummarizerService _notesSummarizerService;
  late final StudyPlannerService _studyPlannerService;
  late final TodoService _todoService;
  late final PracticeExamService _practiceExamService;
  late final SubscriptionService _subscriptionService;
  late final PomodoroService _pomodoroService;
  late final LectureRecordingService _lectureRecordingService;
  late final RecordingBinService _recordingBinService;
  late final AppearanceService _appearanceService;

  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _userService = UserService(_authService);
    _openAiService = OpenAiService();
    _questionService = QuestionService(_openAiService);
    _materialService = MaterialService(_authService, _questionService);
    _solutionService = SolutionService(_authService);
    _courseService = CourseService(_authService);
    _flashcardService = FlashcardService(_authService, _openAiService);
    _subscriptionService = SubscriptionService(_authService);
    _practiceExamService = PracticeExamService(_openAiService, _subscriptionService);
    _tutorContextService = TutorContextService();
    _chatService = ChatService(
      _authService,
      _openAiService,
      _userService,
      _tutorContextService,
      _subscriptionService,
    );
    _notesSummarizerService = NotesSummarizerService(
      _authService,
      _openAiService,
      _flashcardService,
      _subscriptionService,
      _userService,
    );
    _studyPlannerService = StudyPlannerService(_authService, _openAiService, _subscriptionService);
    _todoService = TodoService(_authService);
    _pomodoroService = PomodoroService();
    _lectureRecordingService = LectureRecordingService();
    _recordingBinService = RecordingBinService();
    _appearanceService = widget.appearanceService;
    _bootstrap();
  }

  @override
  void dispose() {
    _pomodoroService.dispose();
    _lectureRecordingService.dispose();
    unawaited(MicCaptureService.instance.dispose());
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _authService.initialize();
    if (_authService.isAuthenticated) {
      await _userService.ensureUserDocument();
      await _subscriptionService.loadPlan();
    }
    await _recordingBinService.ensureLoaded();
    if (mounted) setState(() => _splashDone = true);
  }

  Future<void> _onSignedIn() async {
    await _authService.reloadUser();
    await _userService.ensureUserDocument();
    await _subscriptionService.loadPlan();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <ChangeNotifierProvider<dynamic>>[
        ChangeNotifierProvider<AppearanceService>.value(value: _appearanceService),
        ChangeNotifierProvider<AuthService>.value(value: _authService),
        ChangeNotifierProvider<UserService>.value(value: _userService),
        ChangeNotifierProvider<QuestionService>.value(value: _questionService),
        ChangeNotifierProvider<MaterialService>.value(value: _materialService),
        ChangeNotifierProvider<SolutionService>.value(value: _solutionService),
        ChangeNotifierProvider<CourseService>.value(value: _courseService),
        ChangeNotifierProvider<FlashcardService>.value(value: _flashcardService),
        ChangeNotifierProvider<PracticeExamService>.value(value: _practiceExamService),
        ChangeNotifierProvider<SubscriptionService>.value(value: _subscriptionService),
        ChangeNotifierProvider<TutorContextService>.value(value: _tutorContextService),
        ChangeNotifierProvider<ChatService>.value(value: _chatService),
        ChangeNotifierProvider<NotesSummarizerService>.value(value: _notesSummarizerService),
        ChangeNotifierProvider<StudyPlannerService>.value(value: _studyPlannerService),
        ChangeNotifierProvider<TodoService>.value(value: _todoService),
        ChangeNotifierProvider<PomodoroService>.value(value: _pomodoroService),
        ChangeNotifierProvider<LectureRecordingService>.value(value: _lectureRecordingService),
        ChangeNotifierProvider<RecordingBinService>.value(value: _recordingBinService),
      ],
      child: AnimatedBuilder(
        animation: _appearanceService,
        builder: (BuildContext context, Widget? _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppBranding.name,
            theme: buildStudyTheme(Brightness.light),
            darkTheme: buildStudyTheme(Brightness.dark),
            themeMode: _appearanceService.themeMode,
            builder: (BuildContext context, Widget? child) {
              if (child == null) return const SizedBox.shrink();

              final bool showRecorder =
                  context.select<AuthService, bool>((AuthService auth) => auth.isAuthenticated);
              if (!showRecorder) return child;

              return Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: <Widget>[
                  child,
                  const RecordingBarOverlay(),
                ],
              );
            },
            home: AnimatedBuilder(
              animation: _authService,
              builder: (BuildContext context, Widget? child) {
                if (!_splashDone || _authService.isLoading) {
                  return SplashScreen(onFinished: () {});
                }
                if (!_authService.isAuthenticated) {
                  return LoginScreen(onSignedIn: _onSignedIn);
                }
                return const AppShell();
              },
            ),
          );
        },
      ),
    );
  }
}
