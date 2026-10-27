/// Customizable character for the life simulation.
class AvatarProfile {
  AvatarProfile({
    this.name = 'Student',
    this.genderPresentation = 'neutral',
    this.skinTone = 0xFFE8B796,
    this.faceShape = 'oval',
    this.eyeStyle = 'round',
    this.hairStyle = 'short',
    this.hairColor = 0xFF2C1810,
    this.outfitColor = 0xFF10B981,
    this.shoeColor = 0xFF263238,
    this.accessory = 'none',
    List<String>? traits,
    this.educationLevel = 'high_school',
    List<String>? careerInterests,
  })  : traits = traits ?? <String>[],
        careerInterests = careerInterests ?? <String>[];

  String name;
  String genderPresentation;
  int skinTone;
  String faceShape;
  String eyeStyle;
  String hairStyle;
  int hairColor;
  int outfitColor;
  int shoeColor;
  String accessory;
  List<String> traits;
  String educationLevel;
  List<String> careerInterests;

  static const List<String> genderOptions = <String>['feminine', 'masculine', 'neutral'];
  static const List<String> faceShapes = <String>['oval', 'round', 'square', 'heart'];
  static const List<String> eyeStyles = <String>['round', 'almond', 'wide', 'sleepy'];
  static const List<String> hairStyles = <String>[
    'short',
    'long',
    'curly',
    'braids',
    'afro',
    'bun',
    'bald',
  ];
  static const List<String> accessories = <String>['none', 'glasses', 'cap', 'earrings', 'scarf'];

  static const List<int> skinTones = <int>[
    0xFFFFDFC4,
    0xFFF1C27D,
    0xFFE0AC69,
    0xFFC68642,
    0xFF8D5524,
    0xFF5A3825,
  ];
  static const List<int> hairColors = <int>[
    0xFF1B1B1B,
    0xFF2C1810,
    0xFF6B4423,
    0xFFB7872F,
    0xFFB5341F,
    0xFF9E9E9E,
    0xFF3F51B5,
  ];
  static const List<int> outfitColors = <int>[
    0xFF10B981,
    0xFF3B82F6,
    0xFFF97316,
    0xFFEC4899,
    0xFF8B5CF6,
    0xFF111827,
    0xFFEAB308,
  ];

  /// Trait → what it does in game logic (small, visible bonuses).
  static const Map<String, String> traitCatalog = <String, String>{
    'curious': 'Study sessions give +10% skill.',
    'charismatic': 'Interview answers get a small confidence bonus.',
    'frugal': 'Groceries last longer: each bag gives 6 meals.',
    'disciplined': 'Energy drains 10% slower at work.',
    'social': 'Social activities restore more.',
    'creative': 'Business ideas earn +5% revenue.',
  };

  static const List<String> educationLevels = <String>[
    'high_school',
    'associate',
    'bachelor',
    'master',
    'doctorate',
  ];

  static String educationLabel(String id) {
    switch (id) {
      case 'associate':
        return 'Associate degree';
      case 'bachelor':
        return "Bachelor's degree";
      case 'master':
        return "Master's degree";
      case 'doctorate':
        return 'Doctorate';
      default:
        return 'High school';
    }
  }

  /// 0..4 rank used to compare against job requirements.
  static int educationRank(String id) {
    final int i = educationLevels.indexOf(id);
    return i < 0 ? 0 : i;
  }

  int get educationRankValue => educationRank(educationLevel);
  bool hasTrait(String t) => traits.contains(t);

  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        'genderPresentation': genderPresentation,
        'skinTone': skinTone,
        'faceShape': faceShape,
        'eyeStyle': eyeStyle,
        'hairStyle': hairStyle,
        'hairColor': hairColor,
        'outfitColor': outfitColor,
        'shoeColor': shoeColor,
        'accessory': accessory,
        'traits': traits,
        'educationLevel': educationLevel,
        'careerInterests': careerInterests,
      };

  factory AvatarProfile.fromJson(Map<String, Object?> j) {
    List<String> strings(Object? v) =>
        v is List ? v.map((Object? e) => e.toString()).toList() : <String>[];
    return AvatarProfile(
      name: j['name'] as String? ?? 'Student',
      genderPresentation: j['genderPresentation'] as String? ?? 'neutral',
      skinTone: (j['skinTone'] as num?)?.toInt() ?? 0xFFE8B796,
      faceShape: j['faceShape'] as String? ?? 'oval',
      eyeStyle: j['eyeStyle'] as String? ?? 'round',
      hairStyle: j['hairStyle'] as String? ?? 'short',
      hairColor: (j['hairColor'] as num?)?.toInt() ?? 0xFF2C1810,
      outfitColor: (j['outfitColor'] as num?)?.toInt() ?? 0xFF10B981,
      shoeColor: (j['shoeColor'] as num?)?.toInt() ?? 0xFF263238,
      accessory: j['accessory'] as String? ?? 'none',
      traits: strings(j['traits']),
      educationLevel: j['educationLevel'] as String? ?? 'high_school',
      careerInterests: strings(j['careerInterests']),
    );
  }
}

/// What the character is doing — drives animation and emotion in the world.
enum AvatarAction { idle, walk, sit, talk, useComputer, eat, sleep, work, study, celebrate, frustrated }

enum AvatarEmotion { neutral, happy, tired, stressed, proud, sad }

AvatarEmotion emotionForNeeds({
  required double happiness,
  required double energy,
  required double hunger,
}) {
  if (energy < 20) return AvatarEmotion.tired;
  if (hunger < 20 || happiness < 25) return AvatarEmotion.sad;
  if (happiness > 75) return AvatarEmotion.happy;
  if (happiness < 45) return AvatarEmotion.stressed;
  return AvatarEmotion.neutral;
}
