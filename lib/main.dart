import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_bootstrap.dart';
import 'config/app_branding.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/web_landing_screen.dart';
import 'widgets/authenticated_gate.dart';
import 'widgets/recording_bar_overlay.dart';
import 'services/appearance_service.dart';
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'services/course_service.dart';
import 'services/flashcard_service.dart';
import 'services/lecture_recording_service.dart';
import 'services/mic_capture_service.dart';
import 'services/recording_bin_service.dart';
import 'services/cs_curriculum_progress_service.dart';
import 'services/law_daily_progress_service.dart';
import 'services/law_case_history_service.dart';
import 'services/biology_progress_service.dart';
import 'services/business_school_progress_service.dart';
import 'services/physics_progress_service.dart';
import 'services/chemistry_progress_service.dart';
import 'services/mathematics_progress_service.dart';
import 'services/material_service.dart';
import 'services/notes_summarizer_service.dart';
import 'services/openai_service.dart';
import 'services/pomodoro_service.dart';
import 'services/practice_lab_service.dart';
import 'services/ai_practice_service.dart';
import 'services/practice_exam_service.dart';
import 'services/subscription_service.dart';
import 'services/question_service.dart';
import 'services/solution_service.dart';
import 'services/study_planner_service.dart';
import 'services/todo_service.dart';
import 'services/tutor_context_service.dart';
import 'services/health_faculty_progress_service.dart';
import 'services/virtual_university_dashboard_service.dart';
import 'services/vu_notes_service.dart';
import 'services/world_curriculum_progress_service.dart';
import 'services/user_service.dart';
import 'theme/study_theme.dart';
import 'utils/test_environment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GradeGlowApp(appearanceService: AppearanceService()));
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
  late final PracticeLabService _practiceLabService;
  late final AiPracticeService _aiPracticeService;
  late final SubscriptionService _subscriptionService;
  late final PomodoroService _pomodoroService;
  late final LectureRecordingService _lectureRecordingService;
  late final RecordingBinService _recordingBinService;
  late final MathematicsProgressService _mathematicsProgressService;
  ChemistryProgressService? _chemistryProgressService;
  PhysicsProgressService? _physicsProgressService;
  BiologyProgressService? _biologyProgressService;
  BusinessSchoolProgressService? _businessSchoolProgressService;
  HealthFacultyProgressService? _healthFacultyProgressService;
  WorldCurriculumProgressService? _worldCurriculumProgressService;
  VirtualUniversityDashboardService? _vuDashboardService;
  late final AppearanceService _appearanceService;

  bool _ready = false;
  bool _webShowLogin = false;

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
    _practiceExamService = PracticeExamService(
      _openAiService,
      _subscriptionService,
    );
    _practiceLabService = PracticeLabService(
      _authService,
      _openAiService,
      _subscriptionService,
    );
    _aiPracticeService = AiPracticeService(
      _authService,
      _openAiService,
      _subscriptionService,
    );
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
    _studyPlannerService = StudyPlannerService(
      _authService,
      _openAiService,
      _subscriptionService,
    );
    _todoService = TodoService(_authService);
    _pomodoroService = PomodoroService();
    _lectureRecordingService = LectureRecordingService();
    _recordingBinService = RecordingBinService();
    _mathematicsProgressService = MathematicsProgressService();
    _chemistryProgressService = ChemistryProgressService();
    _physicsProgressService = PhysicsProgressService();
    _biologyProgressService = BiologyProgressService();
    _businessSchoolProgressService = BusinessSchoolProgressService();
    _healthFacultyProgressService = HealthFacultyProgressService();
    _worldCurriculumProgressService = WorldCurriculumProgressService();
    _vuDashboardService = VirtualUniversityDashboardService(
      business: _businessSchoolProgressService,
    );
    _appearanceService = widget.appearanceService;
    _appearanceService.bindAuth(_authService);
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
    final DateTime started = DateTime.now();

    try {
      await Future.wait(<Future<void>>[
        AppBootstrap.initialize(),
        _appearanceService.ensureLoaded(),
        LawDailyProgressService.instance.ensureLoaded(),
        LawCaseHistoryService.instance.ensureLoaded(),
      ]).timeout(const Duration(seconds: 12));

      await _authService.initialize().timeout(const Duration(seconds: 8));

      if (_authService.isAuthenticated) {
        await _userService
            .ensureUserDocument()
            .timeout(const Duration(seconds: 8));
        await _userService
            .finalizeDeletionIfDue()
            .timeout(const Duration(seconds: 8));
        if (_authService.isAuthenticated) {
          await Future.wait(<Future<void>>[
            _subscriptionService.loadPlan(),
            _appearanceService.syncFromCloud(),
          ]).timeout(const Duration(seconds: 8));
        }
      }

      await Future.wait(<Future<void>>[
        _recordingBinService.ensureLoaded(),
        (_vuDashboardService ??= VirtualUniversityDashboardService(
          business: _businessSchoolProgressService,
        )).load(),
        (_healthFacultyProgressService ??= HealthFacultyProgressService())
            .load(),
        (_worldCurriculumProgressService ??= WorldCurriculumProgressService())
            .load(),
        VuNotesService.instance.ensureLoaded(),
      ]).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('App bootstrap recovered from startup error: $e');
    } finally {
      try {
        const Duration minSplash = Duration(milliseconds: 800);
        final Duration elapsed = DateTime.now().difference(started);
        if (!isFlutterTest && elapsed < minSplash) {
          await Future<void>.delayed(minSplash - elapsed);
        }
      } catch (_) {
        // Never block leaving splash (e.g. Platform.environment on web).
      }
      if (mounted) setState(() => _ready = true);
    }
  }

  Future<void> _onSignedIn() async {
    await _authService.reloadUser();
    await _userService.ensureUserDocument();
    await _userService.finalizeDeletionIfDue();
    if (!_authService.isAuthenticated) return;
    await Future.wait(<Future<void>>[
      _subscriptionService.loadPlan(),
      _appearanceService.syncFromCloud(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<OpenAiService>.value(value: _openAiService),
        ChangeNotifierProvider<AppearanceService>.value(
          value: _appearanceService,
        ),
        ChangeNotifierProvider<AuthService>.value(value: _authService),
        ChangeNotifierProvider<UserService>.value(value: _userService),
        ChangeNotifierProvider<QuestionService>.value(value: _questionService),
        ChangeNotifierProvider<MaterialService>.value(value: _materialService),
        ChangeNotifierProvider<SolutionService>.value(value: _solutionService),
        ChangeNotifierProvider<CourseService>.value(value: _courseService),
        ChangeNotifierProvider<FlashcardService>.value(
          value: _flashcardService,
        ),
        ChangeNotifierProvider<PracticeExamService>.value(
          value: _practiceExamService,
        ),
        ChangeNotifierProvider<PracticeLabService>.value(
          value: _practiceLabService,
        ),
        ChangeNotifierProvider<AiPracticeService>.value(
          value: _aiPracticeService,
        ),
        ChangeNotifierProvider<SubscriptionService>.value(
          value: _subscriptionService,
        ),
        ChangeNotifierProvider<TutorContextService>.value(
          value: _tutorContextService,
        ),
        ChangeNotifierProvider<ChatService>.value(value: _chatService),
        ChangeNotifierProvider<NotesSummarizerService>.value(
          value: _notesSummarizerService,
        ),
        ChangeNotifierProvider<StudyPlannerService>.value(
          value: _studyPlannerService,
        ),
        ChangeNotifierProvider<TodoService>.value(value: _todoService),
        ChangeNotifierProvider<PomodoroService>.value(value: _pomodoroService),
        ChangeNotifierProvider<LectureRecordingService>.value(
          value: _lectureRecordingService,
        ),
        ChangeNotifierProvider<RecordingBinService>.value(
          value: _recordingBinService,
        ),
        ChangeNotifierProvider<MathematicsProgressService>.value(
          value: _mathematicsProgressService,
        ),
        ChangeNotifierProvider<ChemistryProgressService>.value(
          value: _chemistryProgressService ??= ChemistryProgressService(),
        ),
        ChangeNotifierProvider<PhysicsProgressService>.value(
          value: _physicsProgressService ??= PhysicsProgressService(),
        ),
        ChangeNotifierProvider<BiologyProgressService>.value(
          value: _biologyProgressService ??= BiologyProgressService(),
        ),
        ChangeNotifierProvider<BusinessSchoolProgressService>.value(
          value: _businessSchoolProgressService ??=
              BusinessSchoolProgressService(),
        ),
        ChangeNotifierProvider<HealthFacultyProgressService>.value(
          value: _healthFacultyProgressService ??=
              HealthFacultyProgressService(),
        ),
        ChangeNotifierProvider<WorldCurriculumProgressService>.value(
          value: _worldCurriculumProgressService ??=
              WorldCurriculumProgressService(),
        ),
        ChangeNotifierProvider<VirtualUniversityDashboardService>.value(
          value: _vuDashboardService ??= VirtualUniversityDashboardService(
            business: _businessSchoolProgressService,
          ),
        ),
        ChangeNotifierProvider<VuNotesService>.value(
          value: VuNotesService.instance,
        ),
        ChangeNotifierProvider<CsCurriculumProgressService>.value(
          value: CsCurriculumProgressService.instance,
        ),
        ChangeNotifierProvider<LawDailyProgressService>.value(
          value: LawDailyProgressService.instance,
        ),
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

              final bool showRecorder = context.select<AuthService, bool>(
                (AuthService auth) => auth.isAuthenticated,
              );
              if (!showRecorder) return child;

              return Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: <Widget>[child, const RecordingBarOverlay()],
              );
            },
            home: AnimatedBuilder(
              animation: _authService,
              builder: (BuildContext context, Widget? child) {
                if (!_ready) {
                  return const SplashScreen();
                }
                if (!_authService.isAuthenticated) {
                  if (kIsWeb && !_webShowLogin) {
                    return WebLandingScreen(
                      onSignIn: () => setState(() => _webShowLogin = true),
                      onGetStarted: () => setState(() => _webShowLogin = true),
                    );
                  }
                  return LoginScreen(
                    onSignedIn: _onSignedIn,
                    onBackToSite: kIsWeb
                        ? () => setState(() => _webShowLogin = false)
                        : null,
                  );
                }
                return AuthenticatedGate(
                  userService: _userService,
                  authService: _authService,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
