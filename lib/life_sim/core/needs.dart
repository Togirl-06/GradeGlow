/// Personal needs: energy, hunger, happiness, health, social.
///
/// All values are 0..100 (100 is best; hunger 100 = full stomach).
class PlayerNeeds {
  PlayerNeeds({
    this.energy = 85,
    this.hunger = 70,
    this.happiness = 70,
    this.health = 95,
    this.social = 60,
    this.hygiene = 80,
    this.stress = 15,
  });

  double energy;
  double hunger;
  double happiness;
  double health;
  double social;

  /// 100 = freshly showered.
  double hygiene;

  /// 0 = calm, 100 = overwhelmed (lower is better).
  double stress;

  static const List<String> keys = <String>[
    'energy',
    'hunger',
    'happiness',
    'health',
    'social',
    'hygiene',
    'stress',
  ];

  double operator [](String key) {
    switch (key) {
      case 'energy':
        return energy;
      case 'hunger':
        return hunger;
      case 'happiness':
        return happiness;
      case 'health':
        return health;
      case 'social':
        return social;
      case 'hygiene':
        return hygiene;
      case 'stress':
        return stress;
    }
    return 0;
  }

  void _set(String key, double v) {
    final double c = v.clamp(0, 100).toDouble();
    switch (key) {
      case 'energy':
        energy = c;
      case 'hunger':
        hunger = c;
      case 'happiness':
        happiness = c;
      case 'health':
        health = c;
      case 'social':
        social = c;
      case 'hygiene':
        hygiene = c;
      case 'stress':
        stress = c;
    }
  }

  /// Applies a map of deltas such as `{'hunger': 30, 'happiness': 5}`.
  void apply(Map<String, double> deltas) {
    deltas.forEach((String k, double d) {
      if (keys.contains(k)) _set(k, this[k] + d);
    });
  }

  /// Natural decay over [minutes] of game time.
  ///
  /// [comfort] (0..10) from the player's home slows happiness loss and speeds
  /// sleep recovery.
  void tick(int minutes, {bool sleeping = false, double comfort = 0}) {
    if (minutes <= 0) return;
    final double m = minutes.toDouble();
    if (sleeping) {
      energy = (energy + m * (0.16 + comfort * 0.006)).clamp(0, 100).toDouble();
      hunger = (hunger - m * 0.025).clamp(0, 100).toDouble();
      social = (social - m * 0.004).clamp(0, 100).toDouble();
      stress = (stress - m * 0.08).clamp(0, 100).toDouble();
      hygiene = (hygiene - m * 0.006).clamp(0, 100).toDouble();
    } else {
      energy = (energy - m * 0.045).clamp(0, 100).toDouble();
      hunger = (hunger - m * 0.06).clamp(0, 100).toDouble();
      social = (social - m * 0.018).clamp(0, 100).toDouble();
      hygiene = (hygiene - m * 0.02).clamp(0, 100).toDouble();
      // Exhaustion and loneliness slowly build stress; rest relieves it.
      final double pressure = (energy < 30 ? 0.02 : 0) + (social < 25 ? 0.01 : 0) - (energy > 60 ? 0.005 : 0);
      stress = (stress + m * pressure).clamp(0, 100).toDouble();
    }

    // Happiness drifts toward the average of the other needs.
    final double mood = (energy + hunger + social + health) / 4;
    final double target = mood * 0.8 + comfort * 2;
    final double pull = (target - happiness) * 0.0015 * m;
    happiness = (happiness + pull).clamp(0, 100).toDouble();

    // Neglect hurts health; being well-fed and rested slowly heals.
    if (hunger < 15 || energy < 10) {
      health = (health - m * 0.03).clamp(0, 100).toDouble();
    } else if (hunger > 50 && energy > 40) {
      health = (health + m * 0.004).clamp(0, 100).toDouble();
    }
  }

  /// Short warnings the UI can surface.
  List<String> warnings() {
    final List<String> out = <String>[];
    if (hunger < 20) out.add('You are starving — eat something.');
    if (energy < 20) out.add('You are exhausted — get some sleep.');
    if (health < 30) out.add('Your health is low — rest and eat well.');
    if (happiness < 25) out.add('You are miserable — do something you enjoy.');
    if (social < 20) out.add('You feel lonely — spend time with people.');
    if (hygiene < 25) out.add('You could really use a shower.');
    if (stress > 75) out.add('You are overwhelmed — take a break.');
    return out;
  }

  /// 0..1 performance multiplier at work. Tired, hungry people perform worse.
  double get workReadiness {
    final double base = (energy * 0.4 + hunger * 0.2 + happiness * 0.2 + health * 0.2) / 100;
    final double calm = stress > 70 ? 0.05 : 0;
    return (0.55 + base * 0.45 - calm).clamp(0.5, 1.0).toDouble();
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'energy': energy,
        'hunger': hunger,
        'happiness': happiness,
        'health': health,
        'social': social,
        'hygiene': hygiene,
        'stress': stress,
      };

  factory PlayerNeeds.fromJson(Map<String, Object?> json) {
    double read(String k, double d) => (json[k] as num?)?.toDouble() ?? d;
    return PlayerNeeds(
      energy: read('energy', 85),
      hunger: read('hunger', 70),
      happiness: read('happiness', 70),
      health: read('health', 95),
      social: read('social', 60),
      hygiene: read('hygiene', 80),
      stress: read('stress', 15),
    );
  }
}
