import '../data/vu_v2_topic_content_models.dart';
import 'textbook_architecture.dart';
import 'textbook_packs.dart';

enum TextbookKind {
  skeletal,
  membrane,
  cell,
  dna,
  chemistry,
  physics,
  clinical,
  law,
  business,
  biology,
  generic,
}

/// Domain teaching voice. Not a fill-in-the-blank around the lesson title.
class TextbookField {
  const TextbookField(this.kind);
  final TextbookKind kind;

  static TextbookField forTopic(String subjectId, String topic) {
    final String s = '${subjectId}_$topic'.toLowerCase();
    if (s.contains('skelet') || s.contains('bone') || s.contains('axial')) {
      return const TextbookField(TextbookKind.skeletal);
    }
    if (s.contains('membrane') ||
        s.contains('osmosis') ||
        s.contains('diffusion') ||
        (s.contains('transport') && s.contains('bio'))) {
      return const TextbookField(TextbookKind.membrane);
    }
    if (s.contains('dna') || s.contains('replicat') || s.contains('transcript')) {
      return const TextbookField(TextbookKind.dna);
    }
    if (s.contains('cell')) return const TextbookField(TextbookKind.cell);
    if (s.contains('titrat') || s.contains('molar') || s.contains('acid-base') ||
        (s.contains('chem') && (s.contains('acid') || s.contains('base')))) {
      return const TextbookField(TextbookKind.chemistry);
    }
    if (s.contains('chem')) return const TextbookField(TextbookKind.chemistry);
    if (s.contains('gravity') || s.contains('free fall') || s.contains('kinematic')) {
      return const TextbookField(TextbookKind.physics);
    }
    if (s.contains('phys')) return const TextbookField(TextbookKind.physics);
    if (s.contains('nurs') || s.contains('vital') || s.contains('chest') ||
        s.contains('cardiac') || s.contains('triage')) {
      return const TextbookField(TextbookKind.clinical);
    }
    if (s.contains('med') && !s.contains('membrane')) {
      return const TextbookField(TextbookKind.clinical);
    }
    if (s.contains('law') || s.contains('contract') || s.contains('tort') ||
        s.contains('evidence') || s.contains('negligen')) {
      return const TextbookField(TextbookKind.law);
    }
    if (s.contains('bus') || s.contains('revenue') || s.contains('market') ||
        s.contains('financ') || s.contains('account')) {
      return const TextbookField(TextbookKind.business);
    }
    if (s.contains('bio')) return const TextbookField(TextbookKind.biology);
    return const TextbookField(TextbookKind.generic);
  }

  List<VuV2TextbookSection> compose({
    required String topic,
    required String courseTitle,
    required String facultyTitle,
    required CourseOutline outline,
    String? subtitle,
  }) {
    final String t = topic;
    return <VuV2TextbookSection>[
      VuV2TextbookSection(
        title: 'Chapter overview',
        body:
            '**${outline.heading}**\n\n'
            '${subtitle == null || subtitle.isEmpty ? '' : '$subtitle\n\n'}'
            'Assigned reading for **$t** in **$courseTitle**. This chapter teaches in sequence. '
            'It is not a summary card. Work the example and the case before you claim you are done.',
      ),
      VuV2TextbookSection(title: 'Learning Objectives', body: _objectives(t)),
      VuV2TextbookSection(
        title: 'Prerequisites',
        body: _prereq(t, courseTitle),
      ),
      VuV2TextbookSection(title: '1.1 Introduction', body: _intro(t, courseTitle)),
      VuV2TextbookSection(title: '1.2 Organization of the subject', body: _org(t)),
      VuV2TextbookSection(title: '1.3 Mechanism and explanation', body: _mech(t)),
      VuV2TextbookSection(
        title: '1.4 Instructional development',
        body: TextbookPacks.essay(kind, t, courseTitle),
      ),
      VuV2TextbookSection(
        title: '1.5 Models, figures, and professional use',
        body: TextbookPacks.models(kind, t),
      ),
      VuV2TextbookSection(
        title: '1.6 Performing the work',
        body: _depth(t, courseTitle),
      ),
      VuV2TextbookSection(
        title: 'How to study this chapter',
        body: TextbookPacks.studio(kind, t, courseTitle),
      ),
      VuV2TextbookSection(title: 'Diagrams and figures', body: _fig(t)),
      VuV2TextbookSection(title: 'Precise definitions', body: _def(t)),
      VuV2TextbookSection(title: 'Clinical Connection', body: _clin(t)),
      VuV2TextbookSection(title: 'Worked Example', body: _work(t)),
      VuV2TextbookSection(title: 'Worked example 1 — guided', body: _work(t)),
      VuV2TextbookSection(
        title: 'Lecture — full treatment',
        body: _lecture(t, courseTitle),
      ),
      VuV2TextbookSection(title: 'Common Misconceptions', body: _myth(t)),
      VuV2TextbookSection(
        title: 'Check Your Understanding',
        body: _check(t),
      ),
      VuV2TextbookSection(title: 'Chapter Summary', body: _sum(t)),
      VuV2TextbookSection(title: 'Key Terms', body: _terms(t)),
      VuV2TextbookSection(title: 'Review Questions', body: _rev(t)),
      VuV2TextbookSection(title: 'Practice problems', body: _rev(t)),
      VuV2TextbookSection(title: 'Application Questions', body: _app(t)),
      VuV2TextbookSection(title: 'Case Study', body: _case(t)),
    ];
  }

  String expansion(String topic, String course, CourseOutline o) {
    return 'After **${o.heading}**, a competent reader of **$topic** in **$course** can redo the '
        'worked path without looking, name the failure mode the chapter exists to prevent, and '
        'state the first measurement, document, or action a supervisor would demand. '
        'Close the book and write that paragraph. If the paragraph still works after swapping a neighboring title, the reading is not done. '
        'Then connect the figure to the case: what would change in the lab, clinic, code, or file if the mechanism were false? '
        'That question is the bridge from this chapter to the laboratory — not a recap of headings.';
  }

  String _objectives(String t) {
    switch (kind) {
      case TextbookKind.skeletal:
        return 'By the end of this chapter, the student should be able to:\n\n'
            '1. identify the major divisions of the skeletal system;\n'
            '2. distinguish **axial** from **appendicular** skeleton;\n'
            '3. describe the structure of a typical long bone;\n'
            '4. explain bone remodeling;\n'
            '5. connect skeletal anatomy to movement and clinical practice.\n\n'
            'Reciting that bones provide support, protection, and movement does **not** meet these objectives.';
      case TextbookKind.membrane:
        return 'By the end of this chapter you will be able to:\n\n'
            '1. distinguish simple diffusion, facilitated diffusion, osmosis, and active transport;\n'
            '2. explain why the bilayer blocks ions but not O2;\n'
            '3. predict water movement from tonicity;\n'
            '4. describe the Na+/K+ ATPase and secondary transport;\n'
            '5. apply **$t** to ORS, edema, and IV fluid choice.';
      default:
        return 'By the end of this chapter you should be able to:\n\n'
            '1. define **$t** operationally, in language that would survive a professor’s follow-up “why?”;\n'
            '2. explain the mechanism, not only the label;\n'
            '3. use a figure to argue a prediction;\n'
            '4. diagnose a standard misconception;\n'
            '5. apply **$t** to a professional scenario with named steps and uncertainty.';
    }
  }

  String _prereq(String t, String c) {
    return 'Before **$t**, you need the vocabulary of this course’s previous unit in **$c** '
        '(scale, units, and the difference between an observation and a conclusion). '
        'If you cannot yet write a hypothesis that a lab could falsify, stop and review scientific method. '
        'This chapter assumes you will read slowly and redraw the figures.';
  }

  String _intro(String t, String c) => TextbookPacks.intro(kind, t, c);

  String _org(String t) => TextbookPacks.organization(kind, t);

  String _mech(String t) => TextbookPacks.mechanism(kind, t);

  String _depth(String t, String c) {
    return '${TextbookPacks.mechanism(kind, t)}\n\n'
        '${TextbookPacks.models(kind, t)}\n\n'
        'A student who can only quote a heading has not finished **$t** in **$c**. '
        'The next honest move is to rebuild the figure, redo the worked path with the numbers covered, '
        'and write the professional first action. Then enter the laboratory and perform it: '
        'the engine will remember skipped steps, overshoots, reversed comparators, and unopened documents. '
        'Assessment after that is a check that the model is in your head, not a replacement for the work.\n\n'
        'If you are reading this chapter as primary course text, treat each numbered section as a class you cannot skip. '
        'Redraw. Recalculate. Re-argue the case. Then — and only then — claim mastery of **$t**.';
  }

  String _fig(String t) => TextbookPacks.models(kind, t);

  String _def(String t) {
    switch (kind) {
      case TextbookKind.skeletal:
        return '**Axial skeleton.** Skull, vertebral column, thoracic cage.\n\n**Appendicular skeleton.** Girdles and limbs.\n\n**Long bone.** Diaphysis + epiphyses; leverage.\n\n**Remodeling.** Lifelong formation and resorption of bone matrix.\n\n**Anatomical position.** The reference stance that makes lateral/medial and radius/ulna unambiguous.';
      case TextbookKind.membrane:
        return '**Simple diffusion.** Down electrochemical gradient, no protein.\n\n**Facilitated diffusion.** Protein-mediated, still passive.\n\n**Osmosis.** Net water toward higher osmotic concentration.\n\n**Tonicity.** Effect on cell volume via non-penetrating solutes.\n\n**Primary / secondary active transport.** ATP at the pump versus use of an ion gradient.';
      default:
        return '**$t**.** An operational definition names the kind of thing, the contrast with near-misses, and the measurement or document that would change your mind. '
            'If the sentence still works after swapping a neighboring title, it is not a definition yet. '
            'Write: (1) genus, (2) differentia, (3) a boundary case a multiple-choice writer would exploit, (4) the unit, test, or legal posture this field actually uses. '
            'Then use the term in a sentence a supervisor would sign.';
    }
  }

  String _clin(String t) {
    switch (kind) {
      case TextbookKind.skeletal:
        return 'Lower-leg trauma after a bicycle fall: inspect **tibia and fibula** first (leg, not thigh). Anatomical position puts tibia medial, fibula lateral. The tibial shin is subcutaneous — fractures can often be palpated. Still clear the ankle mortise and knee because force transmits. You are not examining “the skeletal system.” You are examining named appendicular bones.';
      case TextbookKind.membrane:
        return 'ORS is glucose plus sodium because SGLT1 is secondary active transport; water follows. Water alone is a misunderstanding of **$t**. Hypotonic IV sterile water can lyse RBCs — tonicity, not “hydration vibes.”';
      case TextbookKind.clinical:
        return 'Chest discomfort is a time-critical branch: ABC, vitals, history, ECG, not a trivia question about normal heart rate while the patient deteriorates. Missing an action should change the patient state in the lab. That is the clinical connection.';
      case TextbookKind.law:
        return 'Admissibility, not mood. A sympathetic photograph that is more prejudicial than probative can wreck a record. **$t** is issue-spotting on a file, then a hearing.';
      case TextbookKind.business:
        return 'Company-level −18% with Region B −31% and Product X −42% after a price change is a **disaggregated** story. Treating “marketing” as the answer is malpractice.';
      default:
        return 'Name the workplace in which **$t** is dangerous if wrong (ED, hood, courtroom, cockpit of a firm). '
            'State the first observation a competent newcomer would take, the first action they would defer, and the sentence they would write in a chart, notebook, or memo. '
            'That paragraph is the professional connection. A slogan is not.';
    }
  }

  String _work(String t) {
    switch (kind) {
      case TextbookKind.skeletal:
        return '**Problem.** FOOSH, pain in distal forearm, shortened radially, dorsal tilt on lateral film.\n\n**Path.** Appendicular upper limb, not “arm” (humerus). Distal radius is the usual pattern. Articular involvement and median-nerve proximity make “just a broken wrist” poor counseling.\n\n**Defendable answer.** Distal radius, with a plan to inspect ulna/styloid and carpus.';
      case TextbookKind.membrane:
        return '**Problem.** Cell with non-penetrating proteins in hypotonic NaCl that cannot freely enter. Volume?\n\n**Path.** Osmotic concentration higher inside; water in; swell, possible lysis.\n\n**Trap.** “Salt always pulls water” without asking which solutes penetrate.';
      case TextbookKind.chemistry:
        return '**Problem.** 25.00 mL unknown monoprotic acid, titrated with 0.1000 M NaOH, endpoint at 22.40 mL.\n\n**Path.** mmol NaOH = 0.1000 × 22.40; equal mmol acid; M_acid = mmol / 25.00 mL.\n\n**If endpoint overshot.** Trial stands, M is biased; repeat. Do not “fix” the number.';
      case TextbookKind.physics:
        return '**Problem.** h = 1.70 m, mean t = 0.60 s.\n\n**Path.** g = 2h/t² = 2×1.70 / 0.36 ≈ 9.4 m/s². Percent error vs 9.81 is a discussion of timing, not a moral failure.\n\n**Next.** Show four more trials and a mean ± scatter.';
      default:
        return '**Problem.** A realistic prompt involving **$t** with one numeric or documentary hook.\n\n**Step 1.** Name the system and the unknown.\n**Step 2.** Choose the relation or rule that actually governs it.\n**Step 3.** Substitute, with units or citations.\n**Step 4.** Sanity-check against a limit (zero, infinite, opposite party’s best fact).\n**Answer.** A sentence a supervisor would sign.';
    }
  }

  String _lecture(String t, String c) {
    switch (kind) {
      case TextbookKind.skeletal:
        return 'Read this as instruction, not as a script the professor will recite. '
            'The skeleton is two stories that must not be collapsed. Axial structures house the CNS and the thorax; '
            'appendicular structures move you through the world. A FOOSH is an appendicular problem. Cervical precautions are axial. '
            'A typical long bone has a diaphysis, epiphyses, marrow cavity, periosteum, and, in the growing person, a growth plate. '
            'Remodeling is lifelong: unload a limb and density falls. On film you see mineral, not periosteum. '
            'That is why clinical correlation is method, not politeness. Work the cyclist case before you claim **$t** in **$c**.';
      case TextbookKind.membrane:
        return 'Every crossing event answers two questions: protein or not; ATP at this protein or not. '
            'The bilayer rejects hydrated ions. Channels and carriers are different machines. The Na+/K+ ATPase is the battery; SGLT spends it. '
            'Tonicity is about non-penetrating solutes and cell volume, not a slogan about salt. '
            'ORS works because glucose and sodium ride together and water follows. Water-only for diarrhea is a misunderstanding of **$t** in **$c**. '
            'The professor will hide those labels and ask you which membrane contains the electron transport chain, and why ORS is not “hydration vibes.”';
      case TextbookKind.chemistry:
        return 'A titration is a measurement under stoichiometric control. Rinse the glassware with the solution it will hold. '
            'Clear the burette tip. Record initial volume. Deliver until the indicator’s window, not until the flask is a moral verdict of “done.” '
            'If you overshoot, the trial stays in the notebook and M is biased high. Moles of titrant at the true endpoint divided by liters of unknown is the concentration. '
            'That is **$t** in **$c**. The laboratory will let you drag a stopcock and will not let you edit a titre after the fact.';
      case TextbookKind.physics:
        return 'The model is simple enough to tempt dishonesty: g = 2h/t², or a perfect parabola. '
            'The chapter forbids a single beautiful answer. You keep scatter. Timing error is squared in the denominator. Drag lengthens time and lowers calculated g. '
            '**$t** in **$c** is how a noisy table becomes a claim with an error story. The lab will make you launch, record, and explain residual, not hunt 9.81 in a dropdown.';
      case TextbookKind.clinical:
        return 'A fifty-four-year-old man holds his chest. The order of actions is the lesson: airway and circulation first, vitals, story, ECG, then the tests that change the next ten minutes. '
            'Missing an ECG while reciting a normal heart-rate range is not studying. The patient’s state can change while you hesitate. '
            '**$t** in **$c** is prioritization as a skill. The simulation will pause you if you skip vitals. That is teaching.';
      case TextbookKind.law:
        return 'A file is not a vocabulary list. Facts, issues, rules, admissible evidence, the inferences each exhibit supports, then the other side’s best reply. '
            'A sympathetic photograph that is more prejudicial than probative can wreck a record. **$t** in **$c** is IRAC done honestly. The lab will make you tap exhibits and argue without a stem that names the holding.';
      case TextbookKind.business:
        return 'Company-level −18% is a mixture. Region A +4% and Region B −31% is already a different story. Product X −42% after a price change, with complaints up, is a mechanism. '
            '**$t** in **$c** is diagnosis with disaggregated data, then a decision whose consequences you are willing to forecast. The HQ lab will not reward clicking the company total.';
      case TextbookKind.cell:
      case TextbookKind.dna:
      case TextbookKind.biology:
        return 'A smear is not a coloring book. You load a slide, light, 4×, coarse, fine, then climb power. You pin what you see. A wall plus chloroplasts is a plant argument. '
            'A nucleus is a eukaryotic clue, not an identification. **$t** in **$c** is inference from evidence, including DNA as chemistry when the chapter is information flow: antiparallel strands, 5′ to 3′ synthesis, distinct machines for transcription and translation. '
            'The microscope will punish 40× on an unfocused field.';
      case TextbookKind.generic:
        return 'Professionals do not learn **$t** by reading a slogan twice. They meet a problem, make a distinction, follow a mechanism with verbs, use a figure to predict, then do the work in an environment that can fail. '
            'In **$c** this chapter is that path. After 1.1–1.3 you should be able to say what would make you abandon your first claim. '
            'The professor will not read this paragraph aloud. The lab will not be a labeled organelle and a Submit button. '
            'Assessment will ask whether you can perform **$t**, not whether you recognized its name.';
    }
  }

  String _myth(String t) {
    switch (kind) {
      case TextbookKind.skeletal:
        return 'Bone is dead. Leg means thigh. Axial means important. Clavicle is axial. “Support, protection, movement” is enough.';
      case TextbookKind.membrane:
        return 'Diffusion requires ATP. Osmosis is salt movement. Tonicity equals osmolarity. Equilibrium means equal concentrations for ions. Active transport means “important.”';
      default:
        return 'The most expensive misconception in **$t** is treating a slogan as a model. The second is ignoring units, laterality, or the opposite inference. The third is skipping uncertainty. Name all three in your own words after this chapter.';
    }
  }

  String _check(String t) {
    return '1. State the chapter’s distinction (the one you would lose marks for collapsing).\n'
        '2. Point to Figure 2 and explain the inset without looking.\n'
        '3. Give the professional first move in the clinical/workplace connection.\n'
        '4. Break a misconception with a mechanism, not with “that’s wrong.”\n'
        '5. Write one sentence you would put in a lab notebook or chart after applying **$t**.\n\n'
        'If you miss 3–5, reread 1.2 and 1.3. Do not open the lab.';
  }

  String _sum(String t) {
    return '**$t** was taught as a model: parts, relations, process, failure, and professional use. '
        'The summary is not a shorter slogan. It is a promise that you can redo the figures and the worked example. '
        'If you cannot, the summary has lied to you — go back. '
        'Key commitments of the chapter: named structure, causal mechanism, a figure that does work, a workplace decision, and an honest misconception.';
  }

  String _terms(String t) {
    return 'Keep a running glossary for **$t** from the bolded terms in 1.1–1.3 and Precise definitions. '
        'Each term needs a use, not only a synonym. If a term does not change a decision, it is decoration.';
  }

  String _rev(String t) {
    return '1. Contrast the two most confused ideas in **$t**.\n'
        '2. Reproduce Figure 1 from memory.\n'
        '3. Work a close variant of the worked example.\n'
        '4. Explain one misconception with a mechanism.\n'
        '5. State what evidence would change your mind.';
  }

  String _app(String t) {
    return '1. Teach **$t** in ninety seconds to a peer who holds the main misconception.\n'
        '2. Design a measurement or a file review that would test your claim.\n'
        '3. Write the dangerous version of a decision (the one the lab should punish) and the recovery.';
  }

  String _case(String t) {
    switch (kind) {
      case TextbookKind.skeletal:
        return '**Case.** 22-year-old cyclist, tender distal forearm. Name the bones, axial vs appendicular, associated injuries you must not miss, and why articular involvement changes counseling.';
      case TextbookKind.membrane:
        return '**Case.** Infant with diarrhea given water only. Use SGLT and tonicity. Explain ORS. Attack the misconception that water is always safest.';
      case TextbookKind.chemistry:
        return '**Case.** Three titration trials: 22.40, 22.38, and 28.10 mL. Which do you keep, what happened to the third, and how do you report M with uncertainty?';
      case TextbookKind.physics:
        return '**Case.** Five drop times with the same height. Calculate g each time, mean, scatter, percent error, and two systematic suspects (clock, meter stick).';
      case TextbookKind.clinical:
        return '**Case.** 54-year-old chest discomfort. List actions in time order. State what you still do not know. State what change in vitals would make you escalate.';
      case TextbookKind.law:
        return '**Case.** A complaint plus three emails plus a photo. Issue-spot, flag one admissibility problem, write a one-paragraph argument and the other side’s best reply.';
      case TextbookKind.business:
        return '**Case.** Revenue −18%, Region B −31%, Product X −42% after a price change. Recommend one management action and forecast a consequence if you are wrong.';
      default:
        return '**Case.** You are the junior person on call for **$t**. Write Objective, Observations, Interpretation, Action, Uncertainty. If any line could fit another chapter unchanged, rewrite it.';
    }
  }
}
