import '../../models/law/law_program.dart';

/// One courtroom objection drill item.
class LawObjectionItem {
  const LawObjectionItem({
    required this.stem,
    required this.options,
    required this.correctIndex,
    required this.explain,
  });

  final String stem;
  final List<String> options;
  final int correctIndex;
  final String explain;
}

/// One legal-writing practice prompt for a topic.
class LawWritingItem {
  const LawWritingItem({
    required this.prompt,
    required this.writingType,
  });

  final String prompt;
  final String writingType;
}

/// Builds multiple topic-based objection drills and writing prompts from a lesson.
class LawTopicPracticeBank {
  LawTopicPracticeBank._();

  static List<LawObjectionItem> objectionsFor(LawLesson lesson) {
    final String topic = lesson.title;
    final String hook = lesson.hook;
    final List<String> els = lesson.elements;
    final String e0 = els.isNotEmpty ? els.first : 'the key element';
    final String e1 = els.length > 1 ? els[1] : 'the next element';
    final String shortHook = hook.length > 110 ? '${hook.substring(0, 110)}…' : hook;

    final List<LawObjectionItem> items = <LawObjectionItem>[
      LawObjectionItem(
        stem: lesson.objectionStem,
        options: List<String>.from(lesson.objectionOptions),
        correctIndex: lesson.correctObjectionIndex.clamp(0, lesson.objectionOptions.length - 1),
        explain: lesson.objectionExplain,
      ),
      LawObjectionItem(
        stem:
            'Witness: "My friend told me that in this $topic dispute, the other side definitely violated $e0."',
        options: const <String>['Hearsay', 'Leading', 'Best evidence', 'Privilege'],
        correctIndex: 0,
        explain:
            'An out-of-court statement offered for the truth of the $e0 violation is classic hearsay unless an exception applies.',
      ),
      LawObjectionItem(
        stem:
            'On direct, counsel asks a friendly witness: "You agree $e1 clearly favors our side in this $topic case, right?"',
        options: const <String>['Leading', 'Hearsay', 'Relevance', 'Asked and answered'],
        correctIndex: 0,
        explain:
            'The question suggests the answer. Leading is generally improper on direct of a friendly witness.',
      ),
      LawObjectionItem(
        stem:
            'Counsel asks: "Isn\'t it true you\'ve always been the kind of person who loses $topic cases?"',
        options: const <String>['Improper character / prejudice', 'Hearsay', 'Best evidence', 'Privilege'],
        correctIndex: 0,
        explain:
            'Propensity character attacks and unfair prejudice are improper; object under relevance / 404-style limits.',
      ),
      LawObjectionItem(
        stem:
            'Witness starts narrating: "Let me tell you everything about $shortHook from the beginning of time…"',
        options: const <String>['Narrative / non-responsive', 'Hearsay', 'Privilege', 'Best evidence'],
        correctIndex: 0,
        explain:
            'A wandering narrative is non-responsive and invites unchecked hearsay. Ask the court to strike and require Q&A.',
      ),
      LawObjectionItem(
        stem:
            'Opposing counsel offers a screenshot of a text with no foundation: "This proves $e0 in the $topic dispute."',
        options: const <String>['Lack of foundation / authentication', 'Leading', 'Privilege', 'Asked and answered'],
        correctIndex: 0,
        explain:
            'Exhibits need authentication. Without foundation that the text is what they claim, object.',
      ),
      LawObjectionItem(
        stem:
            'Lawyer: "Tell the jury what your spouse said the defendant admitted about $e1."',
        options: const <String>['Hearsay', 'Leading', 'Relevance', 'Speculation'],
        correctIndex: 0,
        explain:
            'Layered out-of-court statements offered for truth are hearsay (often double hearsay).',
      ),
      LawObjectionItem(
        stem:
            'Expert begins: "Based on pure speculation about $topic, I\'m sure the plaintiff wins on every element."',
        options: const <String>['Speculation / improper opinion', 'Leading', 'Privilege', 'Best evidence'],
        correctIndex: 0,
        explain:
            'Experts must stay within reliable methods and helpful opinions — pure speculation is objectionable.',
      ),
    ];

    // Topic-flavored extras from doctrine keywords.
    final String d = '${lesson.doctrine} ${lesson.question}'.toLowerCase();
    if (d.contains('hearsay') || topic.toLowerCase().contains('evidence')) {
      items.add(
        LawObjectionItem(
          stem: 'Prosecutor offers a lab report without the analyst: "The report says the sample matched."',
          options: const <String>['Hearsay / confrontation', 'Leading', 'Privilege', 'Cumulative'],
          correctIndex: 0,
          explain: 'Testimonial lab reports offered for truth raise hearsay and confrontation problems without the analyst.',
        ),
      );
    }
    if (d.contains('contract') || d.contains('breach') || d.contains('offer')) {
      items.add(
        LawObjectionItem(
          stem: 'Witness: "The contract obviously means they owe consequential damages — everyone knows that."',
          options: const <String>['Speculation / legal conclusion', 'Hearsay', 'Best evidence', 'Privilege'],
          correctIndex: 0,
          explain: 'Witnesses generally may not testify to legal conclusions about what the contract "obviously" means.',
        ),
      );
    }
    if (d.contains('negligence') || d.contains('duty') || d.contains('tort')) {
      items.add(
        LawObjectionItem(
          stem: 'Counsel: "Tell the jury about other times the defendant was careless in unrelated matters."',
          options: const <String>['Improper character / other acts', 'Hearsay', 'Leading', 'Privilege'],
          correctIndex: 0,
          explain: 'Prior careless acts offered as propensity are generally barred; MIMIC exceptions need a proper purpose.',
        ),
      );
    }
    if (d.contains('search') || d.contains('seizure') || d.contains('mens rea') || d.contains('criminal')) {
      items.add(
        LawObjectionItem(
          stem: 'Officer: "Dispatch told me the defendant is a known offender in this kind of case."',
          options: const <String>['Hearsay', 'Leading', 'Best evidence', 'Privilege'],
          correctIndex: 0,
          explain: 'Dispatch statements offered for the truth of the defendant\'s status are hearsay (and often unfairly prejudicial).',
        ),
      );
    }

    return items;
  }

  static List<LawWritingItem> writingsFor(LawLesson lesson) {
    final String topic = lesson.title;
    final String type = lesson.writingType;
    final String hook = lesson.hook;
    final List<String> els = lesson.elements;
    final String elList = els.join('; ');
    final String e0 = els.isNotEmpty ? els.first : 'the first element';
    final String e1 = els.length > 1 ? els[1] : 'the second element';
    final String eWeak = els.isNotEmpty ? els.last : 'the weakest element';

    return <LawWritingItem>[
      LawWritingItem(prompt: lesson.writingPrompt, writingType: type),
      LawWritingItem(
        prompt:
            'For "$topic," draft a one-page client memo applying each element ($elList) to this dispute:\n\n$hook\n\n'
            'End with a clear recommendation and one counterargument.',
        writingType: 'Client memo',
      ),
      LawWritingItem(
        prompt:
            'Write a short demand letter (or charging/defense letter, as fits) on "$topic." '
            'Lead with the strongest facts for $e0, address $e1, and make a specific ask.',
        writingType: 'Demand letter',
      ),
      LawWritingItem(
        prompt:
            'Outline a motion or opposition on "$topic." Use headings for Facts, Rule, Application, and Relief. '
            'Explain why $eWeak is your biggest risk and how you blunt it.',
        writingType: 'Motion outline',
      ),
      LawWritingItem(
        prompt:
            'Draft a 6–8 sentence IRAC mini-answer for the professor\'s question:\n"${lesson.question}"\n\n'
            'Use the doctrine: ${lesson.doctrine}',
        writingType: 'IRAC practice',
      ),
      LawWritingItem(
        prompt:
            'Write a settlement counseling note for "$topic." Compare BATNA vs a modest offer, '
            'list 3 negotiation levers tied to the elements ($elList), and recommend accept / counter / litigate.',
        writingType: 'Settlement memo',
      ),
      LawWritingItem(
        prompt:
            'Create a courtroom theory paragraph (opening or closing seed) for "$topic" that '
            'tells a one-sentence theme, hits $e0 and $e1, and asks for a specific outcome.',
        writingType: 'Advocacy paragraph',
      ),
    ];
  }
}
