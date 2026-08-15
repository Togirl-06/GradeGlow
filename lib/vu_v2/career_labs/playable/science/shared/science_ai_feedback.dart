/// Static coaching strings for science labs (labels, forces, valence).
class ScienceAiFeedback {
  ScienceAiFeedback._();

  /// Wrong-label coaching: student pointed near [nearLabel], wanted [wantedLabel].
  static String wrongLabel({
    required String nearLabel,
    required String wantedLabel,
    String? hint,
  }) {
    final String look = (hint == null || hint.trim().isEmpty)
        ? 'look carefully at relative position and surrounding structures'
        : hint.trim();
    return 'Your label is pointing near $nearLabel. '
        'The structure you want is $wantedLabel — look for $look.';
  }

  /// Generic miss when no nearby structure is known.
  static String wrongLabelGeneric({
    required String wantedLabel,
    String? hint,
  }) {
    final String look = (hint == null || hint.trim().isEmpty)
        ? 'shape, location, and neighbors on the diagram'
        : hint.trim();
    return 'Not quite. The structure you want is $wantedLabel — look for $look.';
  }

  /// Physics force / free-body coaching.
  static String forceDirection({
    required String expected,
    required String given,
    String? contextHint,
  }) {
    final String extra = (contextHint == null || contextHint.trim().isEmpty)
        ? ''
        : ' $contextHint';
    return 'Force direction "$given" is off. Expect "$expected".$extra '
        'Ask: which interaction pushes or pulls, and along which axis?';
  }

  static String forceMagnitude({
    required String expected,
    required String given,
  }) {
    return 'Magnitude "$given" does not match "$expected". '
        'Check units, components, and whether friction or normal force is included.';
  }

  /// Chemistry valence / bonding coaching.
  static String valenceHint({
    required String element,
    required int expectedValence,
    int? givenValence,
  }) {
    if (givenValence == null) {
      return '$element typically forms $expectedValence bond(s). '
          'Count valence electrons and apply the octet (or duet) rule.';
    }
    return 'You assigned valence $givenValence to $element, but it usually wants '
        '$expectedValence. Recount outer electrons and lone pairs.';
  }

  static String bondTypeHint({
    required String expected,
    required String given,
  }) {
    return 'Bond type "$given" is incorrect — look for "$expected". '
        'Compare electronegativity difference and whether electrons are shared or transferred.';
  }

  static String titrationHint({
    required String stage,
  }) {
    switch (stage.toLowerCase()) {
      case 'endpoint':
        return 'You are near the endpoint — watch the indicator color change carefully.';
      case 'overshot':
        return 'You overshot the endpoint. Record the volume, then reason about excess titrant.';
      case 'buffer':
        return 'In the buffer region, pH changes slowly. Keep adding dropwise.';
      default:
        return 'Stay systematic: volume in, color out, then calculate moles.';
    }
  }

  static String microscopeHint({required String focusIssue}) {
    return 'Optics tip: $focusIssue. Lower magnification, center the field, then refocus.';
  }

  static String hypothesisCoach({required bool hasControls}) {
    if (!hasControls) {
      return 'A strong hypothesis names IV, DV, and what you hold constant. Add controls.';
    }
    return 'Good structure. Make the prediction falsifiable: if IV changes, DV should…';
  }
}
