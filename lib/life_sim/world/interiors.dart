/// Building interiors: every interactable is bound to a real [ActionType].
library;

import '../core/stable_random.dart';
import '../employment/employers.dart';
import 'world_model.dart';

class StationDef {
  const StationDef(this.id, this.name, this.emoji);
  final String id;
  final String name;
  final String emoji;
}

/// Work stations per career; ids match the task content.
const Map<String, List<StationDef>> kStations = <String, List<StationDef>>{
  'software_engineer': <StationDef>[
    StationDef('standup', 'Stand-up Corner', '🗣️'),
    StationDef('desk', 'Developer Desk', '💻'),
    StationDef('review', 'Code Review Wall', '🔎'),
    StationDef('manager', 'Manager Office', '🧑‍💼'),
  ],
  'nurse': <StationDef>[
    StationDef('bedside', 'Patient Bedside', '🛏️'),
    StationDef('nurse_station', 'Nurses\' Station', '📋'),
    StationDef('med_cart', 'Medication Cart', '💊'),
    StationDef('emergency_bay', 'Emergency Bay', '🚨'),
  ],
  'doctor': <StationDef>[
    StationDef('consult_room', 'Consultation Room', '🩺'),
    StationDef('lab_terminal', 'Lab Terminal', '🧪'),
    StationDef('ward_round', 'Ward Round', '🚶'),
  ],
  'lawyer': <StationDef>[
    StationDef('client_room', 'Client Meeting Room', '🤝'),
    StationDef('law_library', 'Law Library', '📚'),
    StationDef('office_desk', 'Office Desk', '🗂️'),
    StationDef('courtroom', 'Courtroom', '⚖️'),
  ],
  'accountant': <StationDef>[
    StationDef('ledger_desk', 'Ledger Desk', '📒'),
    StationDef('audit_room', 'Audit Room', '🔍'),
    StationDef('reporting_desk', 'Reporting Desk', '📈'),
  ],
  'business_manager': <StationDef>[
    StationDef('meeting_room', 'Meeting Room', '👥'),
    StationDef('manager_desk', 'Manager Desk', '🖥️'),
    StationDef('complaints_desk', 'Complaints Desk', '☎️'),
    StationDef('strategy_room', 'Strategy Room', '🧭'),
  ],
};

const List<String> _first = <String>['Amara', 'Diego', 'Priya', 'Tomás', 'Yuki', 'Kofi', 'Elena', 'Marcus', 'Nadia', 'Owen', 'Zara', 'Felix'];
const List<String> _last = <String>['Okafor', 'Lindqvist', 'Rao', 'Moreau', 'Tanaka', 'Mensah', 'Rossi', 'Bennett', 'Haddad', 'Novak'];

String _name(String seed) {
  final StableRandom r = StableRandom.fromString(seed);
  return '${r.pick(_first)} ${r.pick(_last)}';
}

class Interiors {
  const Interiors._();

  static const int w = 12;
  static const int h = 9;
  static const int exitX = 5;
  static const int exitY = 8;

  static final Map<String, Interior> _cache = <String, Interior>{};

  static Interior of(String buildingId) => _cache.putIfAbsent(buildingId, () => _make(buildingId));

  static Interior _room(String id, List<Interactable> items, List<NpcDef> npcs, {int floor = 0xFFE5E7EB, int wall = 0xFF94A3B8}) =>
      Interior(buildingId: id, width: w, height: h, exitX: exitX, exitY: exitY, interactables: items, npcs: npcs, floorColor: floor, wallColor: wall);

  static Interactable _i(String id, String name, String emoji, int x, int y, ActionType t, {String? arg, String hint = ''}) =>
      Interactable(id: id, name: name, emoji: emoji, x: x, y: y, type: t, arg: arg, hint: hint);

  static NpcDef _n(String id, String name, String role, int x, int y, String persona, List<String> lines,
          {int skin = 2, int hair = 1, int outfit = 0xFF6366F1, String? employer}) =>
      NpcDef(id: id, name: name, role: role, x: x, y: y, persona: persona, lines: lines, skinTone: skin, hairColor: hair, outfitColor: outfit, employerId: employer);

  static Interior _make(String id) {
    final Employer? emp = _employerFor(id);
    if (emp != null) return _workplace(id, emp);
    switch (id) {
      case 'apartment_block':
        return _room(id, <Interactable>[
          _i('bed', 'Bed', '🛏️', 1, 1, ActionType.sleep, hint: 'Sleep to restore energy.'),
          _i('fridge', 'Fridge', '🧊', 3, 1, ActionType.eatHome, hint: 'Cook with groceries you bought.'),
          _i('laptop', 'Laptop', '💻', 5, 1, ActionType.laptop, hint: 'Job board, resume and email.'),
          _i('wardrobe', 'Wardrobe', '🚪', 7, 1, ActionType.wardrobe, hint: 'Change your look and outfit.'),
          _i('desk', 'Study Desk', '📖', 9, 1, ActionType.studyHome, hint: 'Study at home.'),
          _i('sofa', 'Sofa', '🛋️', 1, 4, ActionType.relaxHome, hint: 'Relax and unwind.'),
          _i('decor', 'Decorate', '🪴', 4, 4, ActionType.decorate, hint: 'Customise your apartment.'),
          _i('mailbox', 'Bills & Rent', '📬', 9, 4, ActionType.payBills, hint: 'Pay rent and bills.'),
        ], <NpcDef>[
          _n('neighbor', 'Mrs. Adeyemi', 'Neighbour', 7, 6, 'A kind, chatty neighbour who gives practical life tips about budgeting and cooking.',
              <String>['Welcome to the building! Budget your rent first — everything else follows.', 'I cook in bulk on Sundays. Saves money and energy.', 'Interviews go better when you sleep well the night before.'], outfit: 0xFFF59E0B),
        ], floor: 0xFFFDE8D0, wall: 0xFFB08968);
      case 'corner_cafe':
        return _room(id, <Interactable>[
          _i('counter', 'Café Counter', '☕', 4, 1, ActionType.shop, arg: 'cafe', hint: 'Coffee and snacks.'),
          _i('table1', 'Café Table', '🪑', 2, 4, ActionType.socialize, hint: 'Chat with a friend.'),
          _i('table2', 'Window Table', '🪑', 8, 4, ActionType.socialize, hint: 'Meet someone new.'),
        ], <NpcDef>[
          _n('barista', 'Sam', 'Barista', 6, 1, 'A cheerful barista who knows the whole neighbourhood.', <String>['The usual? Coffee keeps you sharp for the workday.', 'I hear Pixelforge is hiring juniors again.']),
          _n('friend_leo', 'Leo', 'Friendly local', 3, 5, 'A relaxed, curious local who enjoys swapping career stories.', <String>['I switched careers last year — scary but worth it.', 'Do not skip your breaks. Burnout is real.'], outfit: 0xFF10B981),
        ], floor: 0xFFF3E5D0, wall: 0xFF92400E);
      case 'university':
        return _room(id, <Interactable>[
          _i('registrar', 'Registrar Desk', '🎫', 2, 1, ActionType.enrolDesk, hint: 'Enrol in degrees and courses.'),
          _i('lecture', 'Lecture Hall', '🧑‍🏫', 5, 1, ActionType.lectureHall, hint: 'Attend lectures (weekdays 9–5).'),
          _i('exam', 'Exam Hall', '📝', 8, 1, ActionType.examHall, hint: 'Sit course exams.'),
          _i('lounge', 'Student Lounge', '🛋️', 2, 5, ActionType.socialize, hint: 'Meet other students.'),
          _i('study', 'Quiet Study Room', '📖', 9, 5, ActionType.studyDesk, hint: 'Study for your exams.'),
          _i('stage', 'Graduation Stage', '🎓', 5, 5, ActionType.graduation, hint: 'Attend your graduation ceremony and collect your certificate.'),
        ], <NpcDef>[
          _n('professor', 'Prof. Okonkwo', 'Professor', 7, 3, 'A passionate professor who explains how classes link to real jobs.', <String>['Attend lectures, then study, then take the exam — that is the path.', 'Every degree here unlocks real careers in the city.'], outfit: 0xFF7C3AED),
          _n('advisor', 'Ms. Delacroix', 'Academic advisor', 3, 3, 'A supportive advisor who recommends degrees based on interests.', <String>['Law and Medicine need a bachelor\'s degree first.', 'Not sure what to study? Visit the Employment Centre to explore careers.'], outfit: 0xFF0EA5E9),
        ], floor: 0xFFFEF3C7, wall: 0xFFCA8A04);
      case 'library':
        return _room(id, <Interactable>[
          _i('desk', 'Study Desk', '📖', 2, 2, ActionType.studyDesk, hint: 'Focused study (needs a course).'),
          _i('shelf', 'Bookshelves', '📚', 5, 1, ActionType.studyHome, arg: 'self', hint: 'Self-study to build knowledge.'),
          _i('certs', 'Certification Desk', '🏅', 9, 2, ActionType.certDesk, hint: 'Study for professional certificates.'),
        ], <NpcDef>[
          _n('librarian', 'Mr. Abernathy', 'Librarian', 7, 3, 'A quiet librarian who recommends books and certificates.', <String>['Shh — but certificates help your resume a lot.', 'Self-study raises your knowledge and skills slowly but surely.'], outfit: 0xFF78350F),
        ], floor: 0xFFEADBC8, wall: 0xFF78350F);
      case 'mall':
        return _room(id, <Interactable>[
          _i('clothes', 'Clothing Store', '👔', 2, 1, ActionType.shop, arg: 'mall_clothing', hint: 'Outfits for interviews and work.'),
          _i('furniture', 'Furniture Store', '🛋️', 5, 1, ActionType.shop, arg: 'mall_furniture', hint: 'Furnish your apartment.'),
          _i('foodcourt', 'Food Court', '🍔', 8, 1, ActionType.shop, arg: 'mall_food', hint: 'Eat out.'),
          _i('transit', 'Transit Kiosk', '🚇', 10, 4, ActionType.shop, arg: 'transit', hint: 'Buy a transit pass.'),
          _i('bench', 'Mall Bench', '🪑', 3, 5, ActionType.socialize, hint: 'People-watch and chat.'),
        ], <NpcDef>[
          _n('shopper', 'Ines', 'Shopper', 6, 4, 'A style-savvy shopper who gives outfit tips for interviews.', <String>['A smart outfit adds to professionalism — interviewers notice.', 'Scrubs for nursing shifts, suits for law and business.'], outfit: 0xFFEC4899),
        ], floor: 0xFFFCE7F3, wall: 0xFFBE185D);
      case 'grocery':
        return _room(id, <Interactable>[
          _i('shelves', 'Grocery Shelves', '🥦', 3, 2, ActionType.shop, arg: 'grocery', hint: 'Buy groceries to cook at home.'),
          _i('snacks', 'Snack Aisle', '🍫', 7, 2, ActionType.shop, arg: 'grocery', hint: 'Quick snacks.'),
        ], <NpcDef>[
          _n('clerk', 'Mr. Chen', 'Store clerk', 5, 5, 'A friendly clerk who knows every price.', <String>['Groceries are cheaper than eating out — stretch that salary.', 'Buy enough for the week.'], outfit: 0xFF16A34A),
        ], floor: 0xFFDCFCE7, wall: 0xFF15803D);
      case 'bank':
        return _room(id, <Interactable>[
          _i('teller', 'Teller Counter', '🏧', 3, 1, ActionType.bank, hint: 'Deposit, withdraw, savings, loans.'),
          _i('atm', 'ATM', '💳', 8, 1, ActionType.bank, hint: 'Quick cash services.'),
          _i('advice', 'Budget Advisor', '📊', 9, 5, ActionType.bank, arg: 'budget', hint: 'Review your budget.'),
        ], <NpcDef>[
          _n('teller_npc', 'Ms. Okoye', 'Bank teller', 5, 3, 'A professional teller who explains savings, loans and interest simply.', <String>['Save a little of every payday — even 10% helps.', 'Debt grows interest. Pay it down early.'], outfit: 0xFF059669),
        ], floor: 0xFFD1FAE5, wall: 0xFF047857);
      case 'employment_center':
        return _room(id, <Interactable>[
          _i('board', 'Job Board', '📌', 2, 1, ActionType.jobBoard, hint: 'Browse and apply for jobs.'),
          _i('resume', 'Resume Desk', '📄', 5, 1, ActionType.resumeDesk, hint: 'Build your resume with AI feedback.'),
          _i('practice', 'Interview Practice', '🎤', 8, 1, ActionType.interviewPractice, hint: 'Mock interviews, no risk.'),
          _i('kiosk', 'Phone Kiosk', '📱', 10, 4, ActionType.laptop, hint: 'Check applications and email.'),
        ], <NpcDef>[
          _n('counselor', 'Ms. Grant', 'Career counsellor', 5, 4, 'An encouraging career counsellor who gives resume and interview advice.', <String>['Tailor your resume to each job.', 'Rejected? Read the feedback, build the missing skills and reapply.'], outfit: 0xFFF97316),
        ], floor: 0xFFFFEDD5, wall: 0xFFC2410C);
      case 'company_registry':
        return _room(id, <Interactable>[
          _i('register', 'Register a Company', '🏭', 4, 1, ActionType.companyRegistry, hint: 'Start your own business.'),
          _i('plan', 'Business Plan Desk', '🗒️', 8, 1, ActionType.companyRegistry, arg: 'plan', hint: 'Review your company.'),
        ], <NpcDef>[
          _n('registrar_npc', 'Mr. Vance', 'Registrar', 6, 4, 'A precise registrar who explains how to start a company.', <String>['You need capital and a business plan before you register.', 'Most small businesses fail on cash flow, not ideas.'], outfit: 0xFF0EA5E9),
        ], floor: 0xFFE0F2FE, wall: 0xFF0369A1);
      case 'cinema':
        return _room(id, <Interactable>[
          _i('tickets', 'Ticket Desk', '🎟️', 3, 1, ActionType.watchMovie, hint: 'Watch a film — boosts happiness.'),
          _i('snack', 'Snack Bar', '🍿', 8, 1, ActionType.shop, arg: 'cafe', hint: 'Popcorn and drinks.'),
          _i('lobby', 'Lobby Seats', '🪑', 2, 5, ActionType.socialize, hint: 'Chat before the show.'),
        ], <NpcDef>[
          _n('usher', 'Ravi', 'Usher', 6, 4, 'A film buff usher.', <String>['Rest matters. A good film recharges you.', 'Go with friends to boost your social life.'], outfit: 0xFFDC2626),
        ], floor: 0xFF3B0A0A, wall: 0xFF7F1D1D);
      case 'gym':
        return _room(id, <Interactable>[
          _i('treadmill', 'Treadmill', '🏃', 2, 2, ActionType.workout, hint: 'Cardio — health up, energy down.'),
          _i('weights', 'Weights', '🏋️', 5, 2, ActionType.workout, arg: 'weights', hint: 'Strength training.'),
          _i('locker', 'Locker Room', '🚿', 9, 2, ActionType.relaxHome, arg: 'shower', hint: 'Freshen up.'),
        ], <NpcDef>[
          _n('trainer', 'Coach Dana', 'Trainer', 7, 5, 'An energetic trainer who explains why exercise helps work focus.', <String>['Regular exercise improves health and mood.', 'Do not train on an empty stomach.'], outfit: 0xFF0D9488),
        ], floor: 0xFFCCFBF1, wall: 0xFF0F766E);
      case 'park':
        return _room(id, <Interactable>[
          _i('bench', 'Park Bench', '🪑', 2, 2, ActionType.relaxPark, hint: 'Relax in the fresh air.'),
          _i('fountain', 'Fountain', '⛲', 6, 2, ActionType.socialize, hint: 'Meet people.'),
          _i('path', 'Jogging Path', '🏃', 9, 5, ActionType.workout, arg: 'jog', hint: 'Gentle jog.'),
        ], <NpcDef>[
          _n('dogwalker', 'Hana', 'Dog walker', 4, 5, 'A friendly local with a dog named Biscuit.', <String>['Fresh air resets a stressful week.', 'Biscuit says hello!'], outfit: 0xFF65A30D),
        ], floor: 0xFFD9F99D, wall: 0xFF4D7C0F);
      case 'courthouse':
        return _room(id, <Interactable>[
          _i('gallery', 'Public Gallery', '👥', 3, 2, ActionType.observeCourt, hint: 'Watch a hearing and learn.'),
          _i('records', 'Records Office', '🗄️', 9, 1, ActionType.observeCourt, arg: 'records', hint: 'Browse public case records.'),
        ], <NpcDef>[
          _n('clerk_court', 'Clerk Ibarra', 'Court clerk', 6, 4, 'A formal clerk who explains court procedure (fictional jurisdiction Glowland).', <String>['Silence in the gallery, please.', 'Everyone is presumed innocent until proven guilty.'], outfit: 0xFF44403C),
        ], floor: 0xFFE7E5E4, wall: 0xFF57534E);
    }
    return _room(id, <Interactable>[], <NpcDef>[]);
  }

  static Employer? _employerFor(String buildingId) {
    for (final Employer e in EmployerCatalog.all) {
      if (e.buildingId == buildingId) return e;
    }
    return null;
  }

  /// All stations an employer offers, tagged by career.
  static List<(String career, StationDef)> stationsOf(Employer e) => <(String, StationDef)>[
        for (final String c in e.hires)
          for (final StationDef s in kStations[c] ?? const <StationDef>[]) (c, s),
      ];

  static Interior _workplace(String id, Employer e) {
    final List<Interactable> items = <Interactable>[
      _i('reception', 'Reception', '🛎️', 1, 6, ActionType.clockIn, arg: e.id, hint: 'Clock in / out.'),
      _i('hr', 'HR Office', '📇', 10, 6, ActionType.hrDesk, arg: e.id, hint: 'Interviews, contracts, raises, resignation.'),
      _i('break', 'Break Room', '☕', 10, 1, ActionType.breakRoom, hint: 'Coffee and a chat.'),
    ];
    if (e.hires.contains('nurse') || e.hires.contains('doctor')) {
      items.add(_i('clinic', 'Walk-in Clinic', '🩹', 7, 6, ActionType.healthCheck, hint: 'Paid health check-up that restores health.'));
    }
    final List<(String, StationDef)> st = stationsOf(e);
    for (int k = 0; k < st.length; k++) {
      final int x = 1 + 2 * (k % 4);
      final int y = 1 + 2 * (k ~/ 4);
      items.add(_i(st[k].$2.id + '@' + st[k].$1, st[k].$2.name, st[k].$2.emoji, x, y, ActionType.workStation, arg: st[k].$2.id, hint: 'Work station for ${st[k].$1.replaceAll('_', ' ')}s.'));
    }
    final List<NpcDef> npcs = <NpcDef>[
      _n('hr_${e.id}', e.interviewer.name, e.interviewer.title, 9, 6,
          'The ${e.interviewer.title} at ${e.name}. Style: ${e.interviewer.style}. Culture: ${e.culture}.',
          <String>['Welcome to ${e.name}. ${e.blurb}', 'Our values: ${e.values.join(', ')}.', 'Check the job board for current openings.'],
          skin: e.interviewer.skinTone, hair: e.interviewer.hairColor, outfit: e.interviewer.outfitColor, employer: e.id),
      for (int c = 0; c < e.hires.length; c++)
        _n('col_${e.id}_$c', _name('${e.id}|$c'), 'Colleague', 3 + 4 * (c % 2), 7 - (c ~/ 2),
            'A coworker at ${e.name} who helps new hires settle in.',
            <String>['Ask questions early — nobody expects you to know everything.', 'Finish your tasks before deadlines and the boss notices.', 'Lunch is at the break room.'],
            skin: 1 + c % 4, hair: c % 5, outfit: e.accent, employer: e.id),
    ];
    return _room(id, items, npcs, floor: 0xFFF1F5F9, wall: e.accent);
  }
}
