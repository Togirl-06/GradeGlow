/// The aggregate game state and every rule-driven action.
///
/// Pure Dart. The UI calls these methods; money, time, inventory and
/// progression are all decided here deterministically. AI only ever writes
/// words (interview feedback, NPC chat) and never changes numbers.
library;

import '../avatar/avatar_profile.dart';
import '../business/company.dart';
import '../careers/career_catalog.dart';
import '../core/life_clock.dart';
import '../core/needs.dart';
import '../social/relationships.dart';
import '../economy/life_economy.dart';
import '../economy/shop_catalog.dart';
import '../education/skills.dart';
import '../education/university.dart';
import '../employment/application.dart';
import '../employment/contract.dart';
import '../employment/employers.dart';
import '../employment/job_listing.dart';
import '../employment/phone_inbox.dart';
import '../employment/qualifications.dart';
import '../employment/resume.dart';
import '../interview/interview_judge.dart';
import '../interview/interview_session.dart';
import '../workplace/job_state.dart';
import '../workplace/work_task.dart';
import '../world/city_map.dart';
import '../world/interiors.dart';
import '../world/world_model.dart';

/// A certificate collected at a graduation ceremony.
class GraduationCertificate {
  const GraduationCertificate({
    required this.degreeId,
    required this.title,
    required this.holder,
    required this.day,
    required this.gpa,
    this.honors = '',
  });

  final String degreeId;
  final String title;
  final String holder;
  final int day;
  final double gpa;
  final String honors;

  Map<String, Object?> toJson() => <String, Object?>{
        'degreeId': degreeId,
        'title': title,
        'holder': holder,
        'day': day,
        'gpa': gpa,
        'honors': honors,
      };

  factory GraduationCertificate.fromJson(Map<String, Object?> j) => GraduationCertificate(
        degreeId: j['degreeId'] as String? ?? '',
        title: j['title'] as String? ?? '',
        holder: j['holder'] as String? ?? '',
        day: (j['day'] as num?)?.toInt() ?? 0,
        gpa: (j['gpa'] as num?)?.toDouble() ?? 0,
        honors: j['honors'] as String? ?? '',
      );
}

class ActionResult {
  const ActionResult(this.ok, this.message);
  const ActionResult.ok(this.message) : ok = true;
  const ActionResult.fail(this.message) : ok = false;
  final bool ok;
  final String message;
}

class LifeGame {
  LifeGame({
    AvatarProfile? avatar,
    LifeClock? clock,
    PlayerNeeds? needs,
    LifeEconomy? economy,
    SkillSet? skills,
  })  : avatar = avatar ?? AvatarProfile(),
        clock = clock ?? LifeClock(),
        needs = needs ?? PlayerNeeds(),
        economy = economy ?? LifeEconomy(),
        skills = skills ?? SkillSet() {
    final Building home = CityMap.instance.buildingById('apartment_block')!;
    cityX = home.doorX;
    cityY = home.doorY;
  }

  /// New game with sensible starting skills from the avatar's traits.
  factory LifeGame.newGame(AvatarProfile avatar) {
    final LifeGame g = LifeGame(avatar: avatar);
    g.skills.gain('communication', 12);
    g.skills.gain('teamwork', 10);
    g.skills.gain('problem_solving', 10);
    if (avatar.hasTrait('curious')) g.skills.gain('problem_solving', 4);
    if (avatar.hasTrait('charismatic')) g.skills.gain('communication', 5);
    g.inbox.add(
      kind: MessageKind.email,
      from: 'GradeGlow Welcome Team',
      subject: 'Welcome to Glow City!',
      body: 'Welcome, ${avatar.name}! Study at the University, visit the Employment Centre to build a resume '
          'and find a job, and keep your energy, hunger and happiness healthy. Every building in the city is open to explore.',
      day: 1,
      minuteOfDay: 7 * 60,
    );
    return g;
  }

  static const int saveVersion = 2;

  /// Relationship levels with NPCs.
  Relationships relationships = Relationships();

  /// Degrees completed but whose ceremony has not been attended yet.
  final List<String> pendingCeremonies = <String>[];

  /// Certificates collected at ceremonies (simulation only — not accredited).
  final List<GraduationCertificate> certificates = <GraduationCertificate>[];

  // ---- State -----------------------------------------------------------
  final AvatarProfile avatar;
  final LifeClock clock;
  final PlayerNeeds needs;
  final LifeEconomy economy;
  final SkillSet skills;
  final Resume resume = Resume();
  final PhoneInbox inbox = PhoneInbox();
  final List<ApplicationRecord> applications = <ApplicationRecord>[];
  JobRecord? job;
  UniversityRecord university = UniversityRecord();
  Company? company;

  /// careerId → credited workdays.
  final Map<String, int> experience = <String, int>{};
  final List<ExperienceEntry> jobHistory = <ExperienceEntry>[];
  final Map<String, int> certMinutes = <String, int>{};
  final Set<String> certPaid = <String>{};

  /// Application ids whose offer has already been negotiated (one attempt).
  final Set<String> negotiatedOffers = <String>{};
  int nextApplicationNumber = 1;
  int lastBreakAbs = -9999;
  int companyWorkedDay = -1;

  /// Where the avatar is: outdoors (cityX/cityY) or inside [buildingId].
  String? buildingId;
  late int cityX;
  late int cityY;
  int inX = Interiors.exitX;
  int inY = Interiors.exitY;

  /// Recent messages for toasts / the activity feed (newest last).
  final List<String> feed = <String>[];
  final List<void Function()> _listeners = <void Function()>[];

  void addListener(void Function() l) => _listeners.add(l);
  void removeListener(void Function() l) => _listeners.remove(l);
  void notify() {
    for (final void Function() l in List<void Function()>.of(_listeners)) {
      l();
    }
  }

  void _say(String m) {
    feed.add(m);
    while (feed.length > 40) {
      feed.removeAt(0);
    }
  }

  // ---- Derived ---------------------------------------------------------
  int get day => clock.day;
  int get minute => clock.minuteOfDay;
  int get absMinute => clock.day * LifeClock.minutesPerDay + clock.minuteOfDay;

  int get educationRank {
    final int a = AvatarProfile.educationRank(avatar.educationLevel);
    final int b = UniversityEngine.educationRankOf(university);
    return a > b ? a : b;
  }

  PlayerQualifications qualifications() => PlayerQualifications(
        educationRank: educationRank,
        skills: skills,
        experienceDays: Map<String, int>.unmodifiable(experience),
        professionalism: economy.professionalism,
        traits: avatar.traits,
        degreeIds: university.completedDegrees,
        name: avatar.name,
      );

  Building? get currentBuilding => buildingId == null ? null : CityMap.instance.buildingById(buildingId!);
  bool get isIndoors => buildingId != null;
  bool get employed => job != null;

  String get statusLine {
    final JobRecord? j = job;
    if (j == null) return 'Unemployed';
    return '${j.contract.title} · ${j.employer.name}';
  }

  // ---- Time ------------------------------------------------------------

  /// Advances game time. All rollover rules run here.
  void advance(int minutes, {bool sleeping = false}) {
    int left = minutes;
    while (left > 0) {
      final int step = left > 60 ? 60 : left;
      left -= step;
      needs.tick(step, sleeping: sleeping, comfort: economy.comfort);
      final int rolled = clock.advance(step);
      for (int k = rolled; k >= 1; k--) {
        _endOfDay(clock.day - k);
      }
      _afterTick();
    }
    _processInbox();
  }

  void _afterTick() {
    if (needs.energy <= 1) {
      _say('You collapsed from exhaustion and slept for hours.');
      needs.energy = 40;
      final int rolled = clock.advance(360);
      for (int k = rolled; k >= 1; k--) {
        _endOfDay(clock.day - k);
      }
    }
    if (needs.health <= 1) {
      final double fee = economy.cash < 200 ? economy.cash : 200;
      economy.cash -= fee;
      needs.health = 45;
      _say('You were taken to hospital. Treatment cost \$${fee.round()}.');
    }
  }

  void _processInbox() {
    final List<PhoneMessage> fresh = ApplicationEngine.processResponses(
      applications: applications,
      inbox: inbox,
      today: clock.day,
      minuteOfDay: clock.minuteOfDay,
    );
    for (final PhoneMessage m in fresh) {
      _say('📩 ${m.subject}');
    }
  }

  void _endOfDay(int finished) {
    final JobRecord? j = job;
    if (j != null) {
      final double before = j.totalWorkdays;
      final List<JobEvent> events = JobEngine.endOfDay(j, finished);
      final int delta = (j.totalWorkdays - before).round();
      if (delta > 0) experience[j.contract.careerId] = (experience[j.contract.careerId] ?? 0) + delta;
      for (final JobEvent e in events) {
        bool ended = false;
        switch (e.kind) {
          case JobEventKind.pay:
            final double net = economy.payWage(e.amount, 'Salary · ${j.employer.name}', clock.day);
            _alert('Payday', 'Your salary from ${j.employer.name} arrived: \$${net.toStringAsFixed(2)} after tax.');
          case JobEventKind.employmentEnded:
            if (e.amount > 0) economy.earn(e.amount, 'Severance · ${j.employer.name}', 'income', clock.day);
            _logJob(j);
            _alert('Employment ended', e.message);
            job = null;
            ended = true;
          case JobEventKind.noticeGiven:
          case JobEventKind.warning:
          case JobEventKind.promotion:
          case JobEventKind.praise:
          case JobEventKind.info:
            _alert(e.kind == JobEventKind.warning ? 'Work warning' : 'Work update', e.message);
        }
        if (ended) break;
      }
    }
    for (final String m in economy.processBills(clock.day)) {
      _alert('Bills', m);
    }
    final Company? c = company;
    if (c != null && !c.closed) {
      final bool worked = companyWorkedDay == finished;
      final double skill = (skills.level('management') + skills.level('finance')) / 2;
      CompanyEngine.simulateDay(c, finished, ownerWorked: worked, skill: skill, creative: avatar.hasTrait('creative'));
      if (c.closed) _alert('Company closed', '${c.name} ran out of money and was shut down.');
    }
  }

  void _alert(String subject, String body) {
    inbox.add(kind: MessageKind.alert, from: 'GradeGlow', subject: subject, body: body, day: clock.day, minuteOfDay: clock.minuteOfDay);
    _say('🔔 $body');
  }

  void _logJob(JobRecord j) {
    jobHistory.add(ExperienceEntry(
      role: j.contract.title,
      employer: j.employer.name,
      workdays: j.totalWorkdays.round(),
      bullets: <String>['Reached performance rating ${j.performance.round()}/100.'],
    ));
  }

  // ---- Movement --------------------------------------------------------

  /// Minutes it takes to walk [steps] tiles (halved with a transit pass).
  int travelMinutes(int steps) {
    final int base = (steps / 3).ceil();
    final int m = economy.transitPass && steps > 15 ? (base / 2).ceil() : base;
    return m < 1 ? 1 : m;
  }

  List<(int, int)> pathToBuilding(String targetBuildingId) {
    final Building? b = CityMap.instance.buildingById(targetBuildingId);
    if (b == null) return <(int, int)>[];
    return CityMap.instance.path(cityX, cityY, b.doorX, b.doorY);
  }

  /// Walks to a building door and charges the travel time.
  ActionResult travelTo(String targetBuildingId) {
    if (isIndoors) return const ActionResult.fail('Leave the building first.');
    final List<(int, int)> p = pathToBuilding(targetBuildingId);
    if (p.isEmpty) return const ActionResult.fail('No route found.');
    final Building b = CityMap.instance.buildingById(targetBuildingId)!;
    advance(travelMinutes(p.length - 1));
    cityX = b.doorX;
    cityY = b.doorY;
    return ActionResult.ok('You arrive at ${b.name}.');
  }

  double _walkAcc = 0;

  /// Moves one tile outdoors (4-direction). Time passes at ~3 tiles/minute
  /// (6 with a transit pass). Returns false if the tile is blocked.
  bool stepOutdoors(int nx, int ny) {
    if (isIndoors) return false;
    if ((nx - cityX).abs() + (ny - cityY).abs() != 1) return false;
    if (!CityMap.instance.walkable(nx, ny)) return false;
    cityX = nx;
    cityY = ny;
    _walkAcc += economy.transitPass ? 1 / 5 : 1 / 3;
    _flushWalk();
    return true;
  }

  /// Moves one tile inside the current building.
  bool stepIndoors(int nx, int ny) {
    final String? id = buildingId;
    if (id == null) return false;
    if ((nx - inX).abs() + (ny - inY).abs() != 1) return false;
    if (Interiors.of(id).blocked(nx, ny)) return false;
    inX = nx;
    inY = ny;
    _walkAcc += 1 / 12;
    _flushWalk();
    return true;
  }

  void _flushWalk() {
    if (_walkAcc >= 1) {
      final int m = _walkAcc.floor();
      _walkAcc -= m;
      advance(m);
    }
  }

  /// Who may enter [b] right now? Returns an error or null.
  String? canEnter(Building b) {
    if (b.id == 'apartment_block') return null;
    if (b.isOpen(clock.day, clock.minuteOfDay)) return null;
    final JobRecord? j = job;
    if (j != null && b.employerId == j.contract.employerId) {
      final bool shiftDay = JobEngine.isShiftDay(j, clock.day);
      if (shiftDay && minute >= j.contract.startHour * 60 - 90 && minute < j.contract.endHour * 60 + 60) return null;
    }
    return '${b.name} is closed. Opening hours: ${_hour(b.openHour)}–${_hour(b.closeHour)}'
        '${b.openWeekends ? '' : ' (weekdays)'}.';
  }

  static String _hour(int h) => h == 0 || h == 24 ? '12am' : (h == 12 ? '12pm' : (h > 12 ? '${h - 12}pm' : '${h}am'));

  ActionResult enter(Building b) {
    if (isIndoors) return const ActionResult.fail('You are already inside.');
    if ((b.doorX - cityX).abs() + (b.doorY - cityY).abs() > 1) {
      return const ActionResult.fail('Walk to the entrance first.');
    }
    final String? err = canEnter(b);
    if (err != null) return ActionResult.fail(err);
    buildingId = b.id;
    inX = Interiors.exitX;
    inY = Interiors.exitY;
    advance(1);
    return ActionResult.ok('You enter ${b.name}.');
  }

  ActionResult leave() {
    final Building? b = currentBuilding;
    if (b == null) return const ActionResult.fail('You are outside.');
    buildingId = null;
    cityX = b.doorX;
    cityY = b.doorY;
    advance(1);
    return const ActionResult.ok('You step outside.');
  }

  // ---- Needs-driven everyday actions -----------------------------------

  ActionResult sleep() {
    int minutes;
    if (minute >= 20 * 60 || minute < 5 * 60) {
      minutes = clock.minutesUntil(7 * 60);
      if (minutes < 240) minutes = 240;
    } else {
      minutes = 120; // nap
    }
    advance(minutes, sleeping: true);
    return ActionResult.ok(minutes >= 240 ? 'You slept well. Energy ${needs.energy.round()}.' : 'You took a nap.');
  }

  ActionResult eatHome() {
    if (!economy.useMeal()) return const ActionResult.fail('The fridge is empty — buy groceries at Fresh Mart.');
    needs.apply(ShopCatalog.homeMealEffects);
    advance(ShopCatalog.homeMealMinutes);
    return const ActionResult.ok('You cooked and ate a home meal.');
  }

  ActionResult relaxHome({bool shower = false}) {
    if (shower) {
      needs.apply(<String, double>{'energy': 3, 'happiness': 4, 'hygiene': 75, 'stress': -6});
      advance(20);
      return const ActionResult.ok('You feel fresh.');
    }
    needs.apply(<String, double>{'happiness': 8, 'energy': 3, 'stress': -12});
    advance(45);
    return const ActionResult.ok('You relaxed for a while.');
  }

  /// Buys an item; food and entertainment are used immediately.
  ActionResult buyItem(String itemId) {
    final ShopItem? item = ShopCatalog.item(itemId);
    if (item == null) return const ActionResult.fail('Unknown item.');
    final String? err = economy.buy(item, clock.day);
    if (err != null) return ActionResult.fail(err);
    if ((item.category == ShopCategory.food && item.id != 'groceries') ||
        item.category == ShopCategory.entertainment) {
      needs.apply(item.effects);
      if (item.minutes > 0) advance(item.minutes);
      return ActionResult.ok('You enjoyed the ${item.name}.');
    }
    if (item.id == 'transit_pass') return const ActionResult.ok('Transit pass added to your monthly bills.');
    return ActionResult.ok('Bought ${item.name}.');
  }

  ActionResult socialize() {
    final double boost = avatar.hasTrait('social') ? 26 : 18;
    needs.apply(<String, double>{'social': boost, 'happiness': 6, 'energy': -3, 'stress': -5});
    advance(45);
    return const ActionResult.ok('You had a good time with people.');
  }

  ActionResult talkToNpc(NpcDef npc) {
    needs.apply(<String, double>{'social': 3, 'happiness': 1, 'stress': -1});
    final String before = Relationships.title(relationships.of(npc.id).level);
    final double gain = relationships.talk(npc.id, clock.day, friendly: avatar.hasTrait('social'));
    advance(3);
    final String after = Relationships.title(relationships.of(npc.id).level);
    if (after != before) return ActionResult.ok('You chatted with ${npc.name}. You are now: $after.');
    return ActionResult.ok(gain > 0 ? 'You chatted with ${npc.name} (+${gain.toStringAsFixed(1)} friendship).' : 'You chatted with ${npc.name}.');
  }

  /// Attends the graduation ceremony for the oldest pending degree.
  ActionResult attendCeremony() {
    if (pendingCeremonies.isEmpty) {
      return const ActionResult.fail('There is no graduation ceremony for you right now.');
    }
    final String degreeId = pendingCeremonies.first;
    final Degree? d = UniversityCatalog.degreeById(degreeId);
    if (d == null) {
      pendingCeremonies.removeAt(0);
      return const ActionResult.fail('That ceremony was cancelled.');
    }
    pendingCeremonies.removeAt(0);
    final double? gpa = UniversityEngine.gpa(university);
    final GraduationCertificate cert = GraduationCertificate(
      degreeId: d.id,
      title: d.name,
      holder: avatar.name,
      day: clock.day,
      gpa: gpa ?? 0,
      honors: UniversityEngine.honors(gpa),
    );
    certificates.add(cert);
    needs.apply(<String, double>{'happiness': 25, 'social': 12, 'stress': -20});
    advance(90);
    _alert('Certificate awarded', 'You received your ${d.name} certificate${cert.honors.isEmpty ? '' : ' ${cert.honors}'}. '
        'This is a GradeGlow game certificate, not an accredited qualification.');
    return ActionResult.ok('Congratulations, ${avatar.name}! You graduated${cert.honors.isEmpty ? '' : ' ${cert.honors}'}. 🎓');
  }

  ActionResult watchMovie() => buyItem('cinema_ticket');

  ActionResult workout({String kind = 'gym'}) {
    if (kind == 'jog') {
      needs.apply(<String, double>{'health': 4, 'happiness': 6, 'energy': -8, 'hunger': -6, 'stress': -10, 'hygiene': -8});
      advance(45);
      return const ActionResult.ok('A refreshing jog.');
    }
    if (needs.hunger < 20) return const ActionResult.fail('You are too hungry to train — eat first.');
    return buyItem('gym_pass');
  }

  ActionResult relaxPark() {
    needs.apply(<String, double>{'happiness': 10, 'energy': 4, 'social': 2, 'stress': -14});
    advance(45);
    return const ActionResult.ok('The fresh air does you good.');
  }

  ActionResult healthCheck() {
    const double fee = 40;
    if (!economy.spend(fee, 'Clinic check-up', 'health', clock.day)) {
      return const ActionResult.fail('A check-up costs \$40.');
    }
    needs.apply(<String, double>{'health': 30});
    advance(60);
    return const ActionResult.ok('The nurse checked you over. Health restored. (Educational simulation — not medical advice.)');
  }

  ActionResult observeCourt({bool records = false}) {
    skills.gain('legal', records ? 0.8 : 1.0);
    skills.gain('communication', 0.3);
    needs.apply(<String, double>{'energy': -4});
    advance(records ? 40 : 60);
    return const ActionResult.ok('You learned how court procedure works. (Fictional jurisdiction.)');
  }

  ActionResult breakRoom() {
    if (absMinute - lastBreakAbs < 60) return const ActionResult.fail('You just had a break — try again later.');
    lastBreakAbs = absMinute;
    needs.apply(<String, double>{'energy': 6, 'social': 3, 'happiness': 2});
    advance(10);
    return const ActionResult.ok('A quick coffee with colleagues.');
  }

  // ---- Bank / bills ----------------------------------------------------
  ActionResult deposit(double amount) => economy.deposit(amount, clock.day)
      ? ActionResult.ok('Moved \$${amount.toStringAsFixed(0)} to savings.')
      : const ActionResult.fail('Not enough cash.');

  ActionResult withdraw(double amount) => economy.withdraw(amount, clock.day)
      ? ActionResult.ok('Withdrew \$${amount.toStringAsFixed(0)}.')
      : const ActionResult.fail('Not enough savings.');

  ActionResult repayDebt(double amount) {
    if (economy.debt <= 0) return const ActionResult.fail('You have no debt.');
    final double paid = economy.repayDebt(amount, clock.day);
    return paid > 0 ? ActionResult.ok('Repaid \$${paid.toStringAsFixed(2)}.') : const ActionResult.fail('Not enough cash.');
  }

  ActionResult moveHome(String housingId) {
    final Housing h = ShopCatalog.housingById(housingId);
    final String? err = economy.moveTo(h, clock.day);
    return err == null ? ActionResult.ok('You moved into ${h.name}.') : ActionResult.fail(err);
  }

  // ---- University ------------------------------------------------------
  ActionResult enrolDegree(String degreeId) {
    final Degree? d = UniversityCatalog.degreeById(degreeId);
    if (d == null) return const ActionResult.fail('Unknown degree.');
    final String? err = UniversityEngine.canEnrolDegree(university, d, educationRank);
    if (err != null) return ActionResult.fail(err);
    university.activeDegreeId = d.id;
    return ActionResult.ok('Enrolled in ${d.name}.');
  }

  ActionResult enrolCourse(String courseId) {
    final Degree? d = UniversityCatalog.degreeOfCourse(courseId);
    final Course? c = UniversityCatalog.courseById(courseId);
    if (d == null || c == null) return const ActionResult.fail('Unknown course.');
    if (university.activeDegreeId != d.id) return ActionResult.fail('Enrol in ${d.shortName} first.');
    final CourseProgress p = university.progress(courseId);
    if (p.passed) return const ActionResult.fail('You already passed this course.');
    if (p.enrolled) return const ActionResult.fail('You are already enrolled.');
    if (!economy.spend(c.tuition, 'Tuition · ${c.name}', 'education', clock.day)) {
      return ActionResult.fail('Tuition is \$${c.tuition.round()}.');
    }
    UniversityEngine.enrolInCourse(university, d, c);
    return ActionResult.ok('Enrolled in ${c.name}.');
  }

  /// Why the player cannot start a lecture for [courseId] right now.
  String? lectureBlock(String courseId) {
    final Course? c = UniversityCatalog.courseById(courseId);
    if (c == null) return 'Unknown course.';
    if (needs.energy < 15) return 'You are too tired to concentrate.';
    return UniversityEngine.lectureBlock(university, c, clock.day, clock.minuteOfDay);
  }

  /// [checkScore] (0..1) is the result of the lecture's knowledge check; good
  /// answers turn into extra study time for the course.
  ActionResult attendLecture(String courseId, {double checkScore = 0.5}) {
    final Course? c = UniversityCatalog.courseById(courseId);
    if (c == null) return const ActionResult.fail('Unknown course.');
    if (needs.energy < 15) return const ActionResult.fail('You are too tired to concentrate.');
    final String? err = UniversityEngine.attendLecture(university, c, clock.day, clock.minuteOfDay);
    if (err != null) return ActionResult.fail(err);
    skills.gain(c.skill, 1.2 + checkScore * 0.6);
    skills.gain('communication', 0.2);
    needs.apply(<String, double>{'energy': -6, 'hunger': -3, 'stress': 2});
    final int bonusMinutes = (checkScore.clamp(0, 1) * 30).round();
    university.progress(courseId).studyMinutes += bonusMinutes;
    advance(UniversityEngine.lectureMinutes);
    return ActionResult.ok('Lecture attended (${university.progress(courseId).lectures}/${CourseRequirements.lecturesRequired})'
        '${bonusMinutes > 0 ? ' · knowledge check +$bonusMinutes study min' : ''}.');
  }

  ActionResult studyCourse(String courseId) {
    final Course? c = UniversityCatalog.courseById(courseId);
    if (c == null) return const ActionResult.fail('Unknown course.');
    if (needs.energy < 12) return const ActionResult.fail('You are too tired to study.');
    final int mins = avatar.hasTrait('curious') ? 66 : UniversityEngine.studySessionMinutes;
    final String? err = UniversityEngine.study(university, c, minutes: mins);
    if (err != null) return ActionResult.fail(err);
    skills.gain(c.skill, avatar.hasTrait('curious') ? 0.7 : 0.6);
    needs.apply(<String, double>{'energy': -7, 'hunger': -2});
    advance(UniversityEngine.studySessionMinutes);
    final CourseProgress p = university.progress(courseId);
    return ActionResult.ok('Studied (${p.studyMinutes}/${CourseRequirements.studyMinutesRequired} min).');
  }

  /// Self-study without a course (library shelves).
  ActionResult selfStudy() {
    if (needs.energy < 12) return const ActionResult.fail('You are too tired to read.');
    skills.gain('problem_solving', 0.5);
    skills.gain('communication', 0.25);
    needs.apply(<String, double>{'energy': -6, 'happiness': 1});
    advance(60);
    return const ActionResult.ok('You read for an hour.');
  }

  /// Practising in a school lab (Algorithm Arena, 3D anatomy, moot court ...).
  /// [seconds] is real time spent inside the activity: quick peeks earn nothing,
  /// so skill comes from actually doing the work.
  ActionResult practiceLab({required String title, required String skill, required int seconds}) {
    if (seconds < 45) {
      return ActionResult.fail('Spend a little longer in $title to earn skill.');
    }
    if (needs.energy < 10) return const ActionResult.fail('You are too tired to practise. Rest first.');
    final double minutes = (seconds / 60).clamp(1, 20).toDouble();
    skills.gain(skill, 0.8 + minutes * 0.25);
    skills.gain('problem_solving', 0.3);
    needs.apply(<String, double>{'energy': -8, 'stress': 2, 'happiness': 1});
    advance(60);
    return ActionResult.ok('You practised in $title. ${Skills.nameOf(skill)} is now ${skills.level(skill).round()}.');
  }

  /// Returns the exam to sit, charging the fee, or an error.
  ({List<ExamQuestion>? questions, String? error}) beginExam(String courseId) {
    final Course? c = UniversityCatalog.courseById(courseId);
    if (c == null) return (questions: null, error: 'Unknown course.');
    final CourseProgress p = university.progress(courseId);
    if (!p.examReady) {
      return (
        questions: null,
        error: 'Not ready: need ${CourseRequirements.lecturesRequired} lectures (${p.lectures}) and '
            '${CourseRequirements.studyMinutesRequired} study minutes (${p.studyMinutes}).'
      );
    }
    if (!UniversityEngine.lectureOpen(clock.day, clock.minuteOfDay)) {
      return (questions: null, error: 'Exams are held on weekdays between 9am and 5pm.');
    }
    if (!economy.spend(CourseRequirements.examFee, 'Exam fee · ${c.name}', 'education', clock.day)) {
      return (questions: null, error: 'The exam fee is \$${CourseRequirements.examFee.round()}.');
    }
    return (questions: UniversityEngine.examFor(c, p.attempts), error: null);
  }

  ({ExamResult result, Degree? graduated}) submitExam(String courseId, List<ExamQuestion> asked, List<int?> answers) {
    final Course c = UniversityCatalog.courseById(courseId)!;
    final Degree d = UniversityCatalog.degreeOfCourse(courseId)!;
    final ExamResult res = UniversityEngine.grade(c, asked, answers);
    final ({Degree? completed, bool associate}) out = UniversityEngine.recordExam(university, d, c, res);
    needs.apply(<String, double>{'energy': -5, 'stress': 8});
    advance(60);
    if (res.passed) {
      UniversityEngine.courseSkillGain(c, res.score).forEach(skills.gain);
      _alert('Exam passed', 'You passed ${c.name} with ${(res.score * 100).round()}%.');
      if (out.associate) {
        _bumpEducation('associate');
        _alert('Associate degree', 'You earned an associate degree in ${d.shortName}.');
      }
    } else {
      _alert('Exam failed', 'You scored ${(res.score * 100).round()}% in ${c.name}. Revise and try again.');
    }
    final Degree? g = out.completed;
    if (g != null) {
      final CareerDef? career = CareerCatalog.byId(g.careerId);
      UniversityEngine.graduationGain(g, career?.coreSkill ?? 'communication').forEach(skills.gain);
      _bumpEducation(AvatarProfile.educationLevels[g.awardRank.clamp(0, 4)]);
      _alert('Graduation', 'Congratulations! You graduated with ${g.name}. You are invited to the graduation ceremony at the University stage.');
      pendingCeremonies.add(g.id);
    }
    return (result: res, graduated: g);
  }

  void _bumpEducation(String level) {
    if (AvatarProfile.educationRank(level) > AvatarProfile.educationRank(avatar.educationLevel)) {
      avatar.educationLevel = level;
    }
  }

  ActionResult withdrawDegree() {
    if (university.activeDegreeId == null) return const ActionResult.fail('You are not enrolled.');
    UniversityEngine.withdraw(university);
    return const ActionResult.ok('You withdrew from your degree. Passed courses are kept.');
  }

  /// Study towards a certificate. One session = 60 minutes.
  ActionResult studyCertification(String certId) {
    final Certification? c = CertificationCatalog.byId(certId);
    if (c == null) return const ActionResult.fail('Unknown certificate.');
    if (skills.certifications.contains(certId)) return const ActionResult.fail('You already hold this certificate.');
    if (!skills.meets(c.requires)) {
      return ActionResult.fail('Prerequisites missing: ${skills.gaps(c.requires).join(', ')}');
    }
    if (needs.energy < 12) return const ActionResult.fail('You are too tired to study.');
    if (!certPaid.contains(certId)) {
      if (!economy.spend(c.cost, 'Certificate fee · ${c.name}', 'education', clock.day)) {
        return ActionResult.fail('Registration costs \$${c.cost.round()}.');
      }
      certPaid.add(certId);
    }
    certMinutes[certId] = (certMinutes[certId] ?? 0) + 60;
    needs.apply(<String, double>{'energy': -7, 'hunger': -2});
    advance(60);
    if (certMinutes[certId]! >= c.studyHours * 60) {
      skills.certifications.add(certId);
      skills.gain(c.skill, c.skillGain);
      _alert('Certificate earned', 'You earned ${c.name}!');
      return ActionResult.ok('You earned ${c.name}!');
    }
    return ActionResult.ok('Studied ${(certMinutes[certId]! / 60).floor()}/${c.studyHours} hours.');
  }

  // ---- Job hunting -----------------------------------------------------
  Resume syncedResume() {
    final List<EducationEntry> edu = <EducationEntry>[];
    for (final String id in university.completedDegrees) {
      final Degree? d = UniversityCatalog.degreeById(id);
      if (d != null) {
        edu.add(EducationEntry(
          degree: d.name,
          school: 'Glowland University',
          level: AvatarProfile.educationLabel(AvatarProfile.educationLevels[d.awardRank.clamp(0, 4)]),
        ));
      }
    }
    final JobRecord? j = job;
    final List<ExperienceEntry> jobs = <ExperienceEntry>[
      ...jobHistory,
      if (j != null)
        ExperienceEntry(
          role: j.contract.title,
          employer: j.employer.name,
          workdays: j.totalWorkdays.round(),
          bullets: <String>['Current performance rating ${j.performance.round()}/100.'],
        ),
    ];
    resume.syncFacts(avatar: avatar, q: qualifications(), degrees: edu, jobs: jobs);
    return resume;
  }

  ResumeReview reviewResume({JobListing? target, String? careerId}) =>
      ResumeCoach.review(syncedResume(), target: target, careerId: careerId);

  List<JobListing> openJobs({String? careerId}) => JobBoard.openListings(clock.day, careerId: careerId);

  String? whyCannotApply(JobListing l) => ApplicationEngine.blockReason(applications, l, clock.day);

  ActionResult apply(JobListing l) {
    final String? block = whyCannotApply(l);
    if (block != null) return ActionResult.fail(block);
    final ResumeReview rv = reviewResume(target: l);
    final ApplicationRecord a = ApplicationEngine.submit(
      id: 'app${nextApplicationNumber++}',
      q: qualifications(),
      listing: l,
      resumeScore: rv.score,
      today: clock.day,
    );
    applications.insert(0, a);
    inbox.add(
      kind: MessageKind.email,
      from: 'Recruitment · ${l.employer.name}',
      subject: 'Application received: ${l.title}',
      body: 'Thank you for applying for ${l.title}. We will review your application and reply in the next few days.',
      day: clock.day,
      minuteOfDay: clock.minuteOfDay,
    );
    advance(20);
    return ActionResult.ok('Application sent to ${l.employer.name}. Expect a reply within days.');
  }

  ApplicationRecord? applicationById(String id) {
    for (final ApplicationRecord a in applications) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// Why the interview for [a] cannot begin now, or null.
  String? interviewBlock(ApplicationRecord a) {
    if (a.status != ApplicationStatus.invited) return 'There is no pending interview for this application.';
    final JobListing l = a.listing!;
    if (a.interviewDay != clock.day) return 'Your interview is on Day ${a.interviewDay}.';
    final int start = (a.interviewHour ?? 9) * 60;
    if (minute < start - 30) return 'You are too early — come at ${_hour(a.interviewHour ?? 9)}.';
    if (minute > start + 90) return 'You missed the interview window.';
    if (buildingId != l.employer.buildingId) {
      return 'Go to ${CityMap.instance.buildingById(l.employer.buildingId)?.name ?? l.employer.name} for the interview.';
    }
    return null;
  }

  InterviewSession startInterview(ApplicationRecord a, {InterviewJudge judge = const HeuristicInterviewJudge()}) {
    return InterviewSession.start(
      listing: a.listing!,
      qualifications: qualifications(),
      judge: judge,
      matchScore: a.matchScore,
      seed: '${a.id}|${a.listingId}|r${a.round}',
      round: a.round,
    );
  }

  InterviewSession startPracticeInterview(JobListing l, {InterviewJudge judge = const HeuristicInterviewJudge()}) {
    return InterviewSession.start(
      listing: l,
      qualifications: qualifications(),
      judge: judge,
      matchScore: 60,
      practice: true,
      seed: 'practice|${clock.day}|${l.id}',
    );
  }

  /// Applies a finished practice interview (small skill gain, time spent).
  void finishPractice(InterviewResult r) {
    skills.gain('communication', 0.8 + r.interviewScore / 100);
    needs.apply(<String, double>{'energy': -6});
    advance(30);
  }

  /// Answers a recruiter's request for more information with the player's
  /// current profile: the application is re-screened deterministically.
  ActionResult sendApplicationUpdate(ApplicationRecord a) {
    if (a.status != ApplicationStatus.infoRequested) {
      return const ActionResult.fail('This application is not waiting for more information.');
    }
    final JobListing? l = a.listing;
    if (l == null) return const ActionResult.fail('That position no longer exists.');
    if (a.infoDeadlineDay != null && clock.day > a.infoDeadlineDay!) {
      return const ActionResult.fail('The deadline has passed.');
    }
    final ResumeReview rv = reviewResume(target: l);
    final ApplicationAssessment as = ApplicationEngine.assess(
      q: qualifications(),
      listing: l,
      resumeScore: rv.score,
      seedKey: '${a.id}|${a.listingId}|update|${clock.day}',
    );
    final bool strong = as.passes || as.score >= a.matchScore + 6;
    a.status = ApplicationStatus.pending;
    a.willAskInfo = false;
    a.willInvite = strong;
    a.respondDay = clock.day + 1;
    advance(20);
    return ActionResult.ok(strong
        ? 'You sent an updated profile. ${l.employer.name} will reply tomorrow.'
        : 'You sent your update, but gaps remain. ${l.employer.name} will reply tomorrow.');
  }

  /// Records the decision from a real interview and notifies the player.
  void finishInterview(ApplicationRecord a, InterviewResult r) {
    final JobListing l = a.listing!;
    final Employer e = l.employer;
    a.interviewScore = r.interviewScore;
    skills.gain('communication', 0.5 + r.interviewScore / 150);
    needs.apply(<String, double>{'energy': -8, 'happiness': r.decision == HireDecision.reject ? -6 : 4});
    advance(60);
    switch (r.decision) {
      case HireDecision.offer:
        a.status = ApplicationStatus.offer;
        a.offerSalary = r.offerSalary ?? l.monthlySalary;
        inbox.add(
          kind: MessageKind.email,
          from: '${e.interviewer.name} · ${e.name}',
          subject: 'Job offer: ${l.title}',
          body: 'Congratulations! We would like to offer you the ${l.title} role at ${e.name} at '
              '\$${a.offerSalary!.round()}/month. Open the offer to review the contract, negotiate or accept.',
          day: clock.day,
          minuteOfDay: clock.minuteOfDay,
          action: <String, String>{'type': 'offer', 'applicationId': a.id},
        );
      case HireDecision.secondInterview:
        a.round = 2;
        a.status = ApplicationStatus.invited;
        int d2 = clock.day + 1;
        while (((d2 - 1) % 7) >= 5) {
          d2++;
        }
        a.interviewDay = d2;
        a.interviewHour = (a.interviewHour ?? e.startHour + 2).clamp(e.startHour + 1, e.endHour - 2);
        inbox.add(
          kind: MessageKind.email,
          from: '${e.interviewer.name} · ${e.name}',
          subject: 'Final interview invitation: ${l.title}',
          body: 'Thank you for meeting us. We would like to invite you to a final interview.\n\n'
              'When: Day $d2, ${a.interviewHour}:00\nWhere: ${e.name} (reception)\n\n'
              'Expect tougher, more senior questions this time.',
          day: clock.day,
          minuteOfDay: clock.minuteOfDay,
          action: <String, String>{'type': 'interview', 'applicationId': a.id},
        );
      case HireDecision.waitlist:
        a.status = ApplicationStatus.waitlisted;
        a.waitlistResolveDay = clock.day + (r.waitlistDays ?? 3);
        a.waitlistWillOffer = r.waitlistWillOffer;
        a.offerSalary = l.monthlySalary;
        inbox.add(
          kind: MessageKind.email,
          from: '${e.interviewer.name} · ${e.name}',
          subject: 'You are on our waiting list',
          body: 'Thank you for interviewing. You are a strong candidate but we are finalising our decision. '
              'We will contact you within ${r.waitlistDays ?? 3} days.',
          day: clock.day,
          minuteOfDay: clock.minuteOfDay,
        );
      case HireDecision.reject:
        final int idx = applications.indexOf(a);
        // Restart the reapply cooldown from today.
        final ApplicationRecord fresh = ApplicationRecord(
          id: a.id,
          listingId: a.listingId,
          submittedDay: a.submittedDay,
          respondDay: clock.day,
          matchScore: a.matchScore,
          resumeScore: a.resumeScore,
          willInvite: a.willInvite,
          status: ApplicationStatus.rejected,
          interviewDay: a.interviewDay,
          interviewHour: a.interviewHour,
          interviewScore: a.interviewScore,
          feedback: <String>[...r.improvements],
        );
        if (idx >= 0) applications[idx] = fresh;
        inbox.add(
          kind: MessageKind.email,
          from: 'Recruitment · ${e.name}',
          subject: 'Interview outcome: ${l.title}',
          body: 'Thank you for interviewing. We have decided not to proceed.\n\nHow to improve:\n- '
              '${r.improvements.take(4).join('\n- ')}\n\nYou may reapply after a few days.',
          day: clock.day,
          minuteOfDay: clock.minuteOfDay,
        );
    }
    _say('📩 ${e.name} sent you their decision.');
  }

  /// Negotiation helper for new offers and raises.
  NegotiationOutcome negotiate({
    required double offer,
    required double askPercent,
    required double pitchScore,
    required bool isNewOffer,
    double? rating,
    String? careerId,
    bool competingOffer = false,
  }) {
    final String cid = careerId ?? job?.contract.careerId ?? 'software_engineer';
    final CareerDef? career = CareerCatalog.byId(cid);
    final double core = career == null ? 0 : skills.level(career.coreSkill);
    final double lev = SalaryNegotiation.leverage(
      rating: rating ?? job?.performance ?? 60,
      skillSurplus: (core / 100).clamp(0, 1).toDouble(),
      communication: skills.level('communication'),
      competingOffer: competingOffer || applications.any((ApplicationRecord x) => x.status == ApplicationStatus.offer),
    );
    return SalaryNegotiation.respond(
      offer: offer,
      askPercent: askPercent,
      leverage: lev,
      pitchScore: pitchScore,
      isNewOffer: isNewOffer,
    );
  }

  int nextWorkdayAfter(int d) {
    int x = d + 1;
    while (LifeClock.isWeekendDay(x)) {
      x++;
    }
    return x;
  }

  /// Signs the contract for an offered job. Resigns any current job.
  ActionResult acceptOffer(ApplicationRecord a, {double? salary}) {
    if (a.status != ApplicationStatus.offer) return const ActionResult.fail('There is no offer to accept.');
    final JobListing l = a.listing!;
    final Employer e = l.employer;
    final JobRecord? old = job;
    if (old != null) {
      _logJob(old);
      _say('You resigned from ${old.employer.name}.');
      job = null;
    }
    final EmploymentContract c = EmploymentContract(
      employerId: e.id,
      careerId: l.careerId,
      rank: l.rank,
      title: l.title,
      monthlySalary: salary ?? a.offerSalary ?? l.monthlySalary,
      startDay: nextWorkdayAfter(clock.day),
      startHour: e.startHour,
      endHour: e.endHour,
      signedDay: clock.day,
    );
    job = JobEngine.start(c);
    a.status = ApplicationStatus.hired;
    for (final ApplicationRecord other in applications) {
      if (other.id != a.id && (other.status == ApplicationStatus.offer || other.status == ApplicationStatus.waitlisted)) {
        other.status = ApplicationStatus.declined;
      }
    }
    inbox.add(
      kind: MessageKind.email,
      from: '${e.interviewer.name} · ${e.name}',
      subject: 'Welcome to ${e.name}!',
      body: 'Your contract is signed. Your first day is Day ${c.startDay} at ${c.startHour}:00. '
          'Check in at reception when you arrive. Dress professionally and be on time.',
      day: clock.day,
      minuteOfDay: clock.minuteOfDay,
    );
    advance(15);
    return ActionResult.ok('Contract signed! You start on Day ${c.startDay}.');
  }

  ActionResult declineOffer(ApplicationRecord a) {
    if (a.status != ApplicationStatus.offer) return const ActionResult.fail('There is no offer.');
    a.status = ApplicationStatus.declined;
    return const ActionResult.ok('You declined the offer.');
  }

  ActionResult resign() {
    final JobRecord? j = job;
    if (j == null) return const ActionResult.fail('You do not have a job.');
    _logJob(j);
    job = null;
    return ActionResult.ok('You resigned from ${j.employer.name}.');
  }

  // ---- Working ---------------------------------------------------------
  String? clockInBlock() {
    final JobRecord? j = job;
    if (j == null) return 'You do not have a job.';
    if (buildingId != j.employer.buildingId) return 'Go to ${j.employer.name} to clock in.';
    if (!JobEngine.isShiftDay(j, clock.day)) {
      return j.contract.startDay > clock.day ? 'Your contract starts on Day ${j.contract.startDay}.' : 'There is no shift today.';
    }
    if (minute < j.contract.startHour * 60 - 90) return 'Too early — your shift starts at ${j.contract.startHour}:00.';
    return null;
  }

  ({ActionResult result, List<WorkScenario> tasks}) clockIn() {
    final String? b = clockInBlock();
    if (b != null) return (result: ActionResult.fail(b), tasks: <WorkScenario>[]);
    final ({List<WorkScenario> tasks, bool late, String message}) r = JobEngine.checkIn(job!, clock.day, clock.minuteOfDay);
    if (r.late) job!.performance = (job!.performance - 2).clamp(0, 100).toDouble();
    advance(5);
    return (result: ActionResult.ok(r.message), tasks: r.tasks);
  }

  List<WorkScenario> todaysTasks() => job == null ? <WorkScenario>[] : JobEngine.assigned(job!);

  /// Why [s] cannot be done right now, or null.
  String? taskBlock(WorkScenario s) {
    final JobRecord? j = job;
    if (j == null) return 'You do not have a job.';
    if (!j.checkedIn) return 'Clock in at reception first.';
    if (j.doneScores.containsKey(s.id)) return 'You already did this task today.';
    if (minute >= j.contract.endHour * 60) return 'The working day is over.';
    return null;
  }

  /// Finishes a task with a 0..1 score. Takes the scenario's time.
  TaskOutcome? completeTask(WorkScenario s, double score) {
    final JobRecord? j = job;
    if (j == null || taskBlock(s) != null) return null;
    final TaskOutcome o = JobEngine.completeTask(j, s, score, clock.day, readiness: needs.workReadiness);
    o.skillGains.forEach(skills.gain);
    needs.apply(<String, double>{
      'energy': avatar.hasTrait('disciplined') ? -7 : -8,
      'hunger': -4,
      'happiness': score >= 0.75 ? 3 : (score < 0.4 ? -4 : 0),
      'stress': score < 0.4 ? 6 : 3,
    });
    advance(s.minutes);
    return o;
  }

  ActionResult callInSick() {
    final JobRecord? j = job;
    if (j == null) return const ActionResult.fail('You do not have a job.');
    final String? err = JobEngine.callInSick(j, clock.day);
    return err == null ? const ActionResult.ok('You called in sick. Rest up.') : ActionResult.fail(err);
  }

  PromotionStatus? promotionStatus() => job == null ? null : JobEngine.promotionStatus(job!, skills);

  ActionResult promote({double? salary}) {
    final JobRecord? j = job;
    if (j == null) return const ActionResult.fail('You do not have a job.');
    final PromotionStatus s = JobEngine.promote(j, skills, negotiatedSalary: salary);
    if (!s.eligible) return ActionResult.fail(s.unmet.join('\n'));
    _alert('Promotion', 'You were promoted to ${s.nextTitle} at \$${j.contract.monthlySalary.round()}/month!');
    return ActionResult.ok('Promoted to ${s.nextTitle}!');
  }

  // ---- Business --------------------------------------------------------
  String? canStartCompany(double capital) {
    if (company != null && !company!.closed) return 'You already run ${company!.name}.';
    if (capital < Company.minCapital) return 'Starting capital must be at least \$${Company.minCapital.round()}.';
    if (!economy.canAfford(capital + 100)) return 'You need the capital plus a \$100 registration fee in cash.';
    if (skills.level('management') < 8 && skills.level('finance') < 8 && skills.level('accounting') < 8) {
      return 'Build some business knowledge first (Management, Finance or Accounting 8+).';
    }
    return null;
  }

  ActionResult startCompany(String name, String industryId, double capital) {
    final String? err = canStartCompany(capital);
    if (err != null) return ActionResult.fail(err);
    final String clean = name.trim().isEmpty ? '${avatar.name}\'s Ventures' : name.trim();
    economy.spend(100, 'Company registration', 'business', clock.day);
    economy.spend(capital, 'Start-up capital · $clean', 'business', clock.day);
    company = Company(name: clean, industryId: industryId, cash: capital, foundedDay: clock.day);
    advance(60);
    return ActionResult.ok('$clean is now registered!');
  }

  ActionResult workOnCompany() {
    final Company? c = company;
    if (c == null || c.closed) return const ActionResult.fail('You have no active company.');
    if (needs.energy < 20) return const ActionResult.fail('You are too tired to work.');
    companyWorkedDay = clock.day;
    skills.gain('management', 0.8);
    skills.gain('finance', 0.4);
    needs.apply(<String, double>{'energy': -14, 'hunger': -8});
    advance(240);
    return const ActionResult.ok('You spent the morning running your business.');
  }

  ActionResult companyWithdraw() {
    final Company? c = company;
    if (c == null) return const ActionResult.fail('You have no company.');
    final double amt = CompanyEngine.withdrawable(c);
    if (amt <= 0) return const ActionResult.fail('Keep at least \$300 in the company.');
    c.cash -= amt;
    economy.earn(amt, 'Owner draw · ${c.name}', 'business', clock.day);
    return ActionResult.ok('Took \$${amt.round()} from the company.');
  }

  // ---- Save / load -----------------------------------------------------
  Map<String, Object?> toJson() => <String, Object?>{
        'version': saveVersion,
        'avatar': avatar.toJson(),
        'clock': clock.toJson(),
        'needs': needs.toJson(),
        'economy': economy.toJson(),
        'skills': skills.toJson(),
        'resume': resume.toJson(),
        'inbox': inbox.toJson(),
        'applications': applications.map((ApplicationRecord a) => a.toJson()).toList(),
        'job': job?.toJson(),
        'university': university.toJson(),
        'company': company?.toJson(),
        'experience': experience,
        'jobHistory': jobHistory.map((ExperienceEntry e) => e.toJson()).toList(),
        'certMinutes': certMinutes,
        'certPaid': certPaid.toList(),
        'negotiatedOffers': negotiatedOffers.toList(),
        'nextApplicationNumber': nextApplicationNumber,
        'lastBreakAbs': lastBreakAbs,
        'companyWorkedDay': companyWorkedDay,
        'relationships': relationships.toJson(),
        'pendingCeremonies': pendingCeremonies,
        'certificates': certificates.map((GraduationCertificate c) => c.toJson()).toList(),
        'buildingId': buildingId,
        'cityX': cityX,
        'cityY': cityY,
        'inX': inX,
        'inY': inY,
      };

  static Map<String, Object?> _map(Object? v) => v is Map ? Map<String, Object?>.from(v) : <String, Object?>{};

  factory LifeGame.fromJson(Map<String, Object?> j) {
    final LifeGame g = LifeGame(
      avatar: AvatarProfile.fromJson(_map(j['avatar'])),
      clock: LifeClock.fromJson(_map(j['clock'])),
      needs: PlayerNeeds.fromJson(_map(j['needs'])),
      economy: LifeEconomy.fromJson(_map(j['economy'])),
      skills: SkillSet.fromJson(_map(j['skills'])),
    );
    final Resume r = Resume.fromJson(_map(j['resume']));
    g.resume
      ..fullName = r.fullName
      ..email = r.email
      ..phone = r.phone
      ..city = r.city
      ..summary = r.summary
      ..education = r.education
      ..skills = r.skills
      ..experience = r.experience
      ..projects = r.projects
      ..certifications = r.certifications;
    final PhoneInbox ib = PhoneInbox.fromJson(_map(j['inbox']));
    g.inbox.messages
      ..clear()
      ..addAll(ib.messages);
    g.inbox.restoreNextId(ib.nextIdValue);
    final Object? apps = j['applications'];
    if (apps is List) {
      for (final Object? a in apps) {
        if (a is Map) g.applications.add(ApplicationRecord.fromJson(Map<String, Object?>.from(a)));
      }
    }
    final Object? jb = j['job'];
    if (jb is Map) g.job = JobRecord.fromJson(Map<String, Object?>.from(jb));
    g.university = UniversityRecord.fromJson(_map(j['university']));
    final Object? co = j['company'];
    if (co is Map) g.company = Company.fromJson(Map<String, Object?>.from(co));
    final Object? ex = j['experience'];
    if (ex is Map) {
      ex.forEach((Object? k, Object? v) => g.experience[k.toString()] = (v as num).toInt());
    }
    final Object? jh = j['jobHistory'];
    if (jh is List) {
      for (final Object? e in jh) {
        if (e is Map) g.jobHistory.add(ExperienceEntry.fromJson(Map<String, Object?>.from(e)));
      }
    }
    final Object? cm = j['certMinutes'];
    if (cm is Map) {
      cm.forEach((Object? k, Object? v) => g.certMinutes[k.toString()] = (v as num).toInt());
    }
    final Object? cp = j['certPaid'];
    if (cp is List) g.certPaid.addAll(cp.map((Object? e) => e.toString()));
    final Object? no = j['negotiatedOffers'];
    if (no is List) g.negotiatedOffers.addAll(no.map((Object? e) => e.toString()));
    g.nextApplicationNumber = (j['nextApplicationNumber'] as num?)?.toInt() ?? 1;
    g.lastBreakAbs = (j['lastBreakAbs'] as num?)?.toInt() ?? -9999;
    g.companyWorkedDay = (j['companyWorkedDay'] as num?)?.toInt() ?? -1;
    g.relationships = Relationships.fromJson(j['relationships']);
    final Object? pc = j['pendingCeremonies'];
    if (pc is List) g.pendingCeremonies.addAll(pc.map((Object? e) => e.toString()));
    final Object? cs = j['certificates'];
    if (cs is List) {
      for (final Object? c in cs) {
        if (c is Map) g.certificates.add(GraduationCertificate.fromJson(Map<String, Object?>.from(c)));
      }
    }
    g.buildingId = j['buildingId'] as String?;
    g.cityX = (j['cityX'] as num?)?.toInt() ?? g.cityX;
    g.cityY = (j['cityY'] as num?)?.toInt() ?? g.cityY;
    g.inX = (j['inX'] as num?)?.toInt() ?? g.inX;
    g.inY = (j['inY'] as num?)?.toInt() ?? g.inY;
    if (g.buildingId != null && CityMap.instance.buildingById(g.buildingId!) == null) g.buildingId = null;
    // Saves from an older map layout: never leave the avatar inside a wall or building.
    if (g.buildingId == null && !CityMap.instance.walkable(g.cityX, g.cityY)) {
      final Building home = CityMap.instance.buildingById('apartment_block')!;
      g.cityX = home.doorX;
      g.cityY = home.doorY;
    }
    if (g.buildingId != null && Interiors.of(g.buildingId!).blocked(g.inX, g.inY)) {
      g.inX = Interiors.exitX;
      g.inY = Interiors.exitY;
    }
    return g;
  }
}
