import 'package:ai_study_buddy/utils/lecture_math_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LectureMathFormat', () {
    test('converts limit notation', () {
      expect(
        LectureMathFormat.toLatex('lim (x→a) f(x) = L'),
        r'\lim_{x \to a} f(x) = L',
      );
    });

    test('converts infinity and fractions', () {
      expect(
        LectureMathFormat.toLatex('lim (x→∞) (2x+1)/(x−3) = 2'),
        contains(r'\lim_{x \to \infty}'),
      );
      expect(
        LectureMathFormat.toLatex('lim (x→∞) (2x+1)/(x−3) = 2'),
        contains(r'\frac{'),
      );
    });

    test('converts superscripts', () {
      expect(
        LectureMathFormat.toLatex('lim (x→4) (x²−16)/(x−4) = 8'),
        contains('x^{2}'),
      );
    });

    test('preserves existing latex', () {
      expect(
        LectureMathFormat.toLatex(r'\lim_{x \to 0} \frac{\sin x}{x}'),
        r'\lim_{x \to 0} \frac{\sin x}{x}',
      );
    });

    test('detects math content', () {
      expect(LectureMathFormat.containsMath('lim (x→a) f(x) = L'), isTrue);
      expect(LectureMathFormat.containsMath('Textbook depth'), isFalse);
      expect(
        LectureMathFormat.containsMath('Why Medical-Surgical Nursing needs it'),
        isFalse,
      );
      expect(
        LectureMathFormat.containsMath('Plan: theory → examples → practice'),
        isFalse,
      );
      expect(
        LectureMathFormat.containsMath('Assess → Act → Reassess → Document'),
        isFalse,
      );
    });
  });
}
