import '../../models/physics/physics_program.dart';
import 'physics_chapter_navigation.dart';
import 'physics_formula_engine.dart';
import 'physics_textbook_diagrams.dart';
import 'physics_topic_deep_content.dart';
import 'physics_topic_lab_engine.dart';
import '../../models/physics/physics_lab_models.dart';

/// Generates complete digital textbook chapters — not summaries.
class PhysicsTextbookChapterEngine {
  PhysicsTextbookChapterEngine._();

  static String build({
    required PhysicsCourse course,
    required PhysicsTopic topic,
    required String levelLabel,
  }) {
    final int chapterNum = _chapterNumber(course, topic);
    final String n = chapterNum.toString();
    final String t = topic.title;
    final String tl = t.toLowerCase();
    final List<PhysicsFormula> formulas =
        PhysicsFormulaEngine.formulasFor(courseId: course.id, topic: topic);
    final PhysicsTopicLabProfile labProfile =
        PhysicsTopicLabEngine.profileFor(course: course, topic: topic);
    final PhysicsLabRoom room = labProfile.virtualLab;
    final PhysicsChapterNav nav = PhysicsChapterNav.forTopic(course: course, topic: topic);

    final StringBuffer buf = StringBuffer()
      ..writeln('# Chapter $n: $t')
      ..writeln()
      ..writeln('*${course.title} · $levelLabel · Virtual University Physics*')
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## Reading Path')
      ..writeln()
      ..writeln(nav.pathBanner(course.title))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.0 Learning Objectives')
      ..writeln()
      ..writeln(_learningObjectives(t, topic, formulas.length))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.1 Introduction')
      ..writeln()
      ..writeln(
        '**$t** is a foundational concept in **${course.title}**. '
        '${topic.hook} '
        'A student who masters this chapter can define every term, derive the governing relations, '
        'solve quantitative problems, interpret graphs, connect the idea to engineering practice, '
        'and verify predictions in the virtual laboratory — without needing an external textbook.',
      )
      ..writeln()
      ..writeln(_introductionDepth(t, course.title, topic, levelLabel))
      ..writeln()
      ..writeln(
        '$t matters because physics describes measurable reality. '
        'From microscopic systems to planetary missions, professionals rely on precise language, '
        'SI units, and testable models built on ideas like **$t**.',
      )
      ..writeln()
      ..writeln(nav.bridgeSection(t))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.2 Historical Background')
      ..writeln()
      ..writeln(_historySection(course.id, tl))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.3 Definitions')
      ..writeln()
      ..writeln(PhysicsTopicDeepContent.definitions(topic: topic, title: t))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.4 Core Concepts')
      ..writeln()
      ..writeln(_coreConceptsSection(t, topic, course.id, tl))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.4b Deep Dive')
      ..writeln()
      ..writeln(PhysicsTopicDeepContent.deepDive(topic: topic, title: t, courseId: course.id))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.5 Mathematical Derivations')
      ..writeln()
      ..writeln(_derivationsSection(t, formulas, tl))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.6 Formulas')
      ..writeln();

    if (formulas.isEmpty) {
      buf.writeln(
        'State the governing relation for **$t** by identifying physical variables, '
        'writing a symbolic equation, and defining every symbol with SI units.',
      );
    } else {
      for (int i = 0; i < formulas.length; i++) {
        final PhysicsFormula f = formulas[i];
        buf
          ..writeln('### $n.6.${i + 1} ${f.name}')
          ..writeln()
          ..writeln('**Formula**')
          ..writeln()
          ..writeln(r'$$')
          ..writeln(f.latex)
          ..writeln(r'$$')
          ..writeln()
          ..writeln('**Variable explanation**')
          ..writeln()
          ..writeln(f.symbols)
          ..writeln()
          ..writeln('**Units**')
          ..writeln()
          ..writeln(_formulaUnits(f, course.id))
          ..writeln()
          ..writeln('**Derivation sketch**')
          ..writeln()
          ..writeln(_derivationSketch(f, t))
          ..writeln()
          ..writeln('**When to use**')
          ..writeln()
          ..writeln(f.whenToUse ?? 'Apply when the physical situation matches the assumptions stated in the definition.')
          ..writeln()
          ..writeln('**When NOT to use**')
          ..writeln()
          ..writeln(_whenNotToUse(f, tl));
        if (f.unitCheck != null) {
          buf
            ..writeln()
            ..writeln('**Unit check**')
            ..writeln()
            ..writeln(f.unitCheck);
        }
        buf.writeln();
      }
    }

    buf
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.7 Visual Explanations & Diagrams')
      ..writeln()
      ..writeln(_visualSection(course.id, tl))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.7b Diagram Gallery')
      ..writeln()
      ..writeln(PhysicsTextbookDiagrams.gallery(courseId: course.id, topicTitle: t, topicLower: tl))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.8 Worked Examples')
      ..writeln()
      ..writeln(PhysicsTopicDeepContent.workedExamples(
        topic: topic,
        title: t,
        formulas: formulas,
        topicLower: tl,
      ))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.9 Common Errors')
      ..writeln()
      ..writeln(PhysicsTopicDeepContent.commonErrors(title: t, topicLower: tl, topicId: topic.id))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.10 Real-World Applications')
      ..writeln()
      ..writeln(_applicationsSection(course.id, t, topic))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.11 Advanced Concepts — Beyond the Classroom')
      ..writeln()
      ..writeln(_advancedSection(course.id, levelLabel, tl))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.12 Virtual Laboratory')
      ..writeln()
      ..writeln('**Room:** ${room.emoji} ${room.name}')
      ..writeln()
      ..writeln('**Experiment:** ${room.experimentTitle}')
      ..writeln()
      ..writeln(_labSteps(t, room.name))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.13 Simulation')
      ..writeln()
      ..writeln('Open **3D Simulation & Lab** for **${labProfile.simulationTitle}**.')
      ..writeln()
      ..writeln(labProfile.simulationDescription)
      ..writeln()
      ..writeln('1. Set initial conditions for **$t**.')
      ..writeln('2. Predict the measurable outcome before running.')
      ..writeln('3. Launch the simulation and compare data to your calculation.')
      ..writeln('4. Change one variable at a time and record the trend.')
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.14 Practice Problems')
      ..writeln()
      ..writeln(_practiceProblems(t, formulas, levelLabel))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.15 Exam Questions')
      ..writeln()
      ..writeln(_examQuestions(t, levelLabel))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.16 Research Challenge')
      ..writeln()
      ..writeln(_researchChallenge(t, course.title, levelLabel))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.17 Summary')
      ..writeln()
      ..writeln(_summary(t, topic.keyConcepts, formulas.length))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.18 Mastery Checklist')
      ..writeln()
      ..writeln(_checklist(t, topic.keyConcepts))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.19 Formula Quick Reference')
      ..writeln()
      ..writeln(_formulaReferenceTable(formulas, t))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.20 Extended Practice Set')
      ..writeln()
      ..writeln(_extendedPractice(t, formulas, levelLabel))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## $n.21 Continue Your Study')
      ..writeln()
      ..writeln(_continueStudy(nav, t, course.title));

    return buf.toString();
  }

  static int _chapterNumber(PhysicsCourse course, PhysicsTopic topic) {
    final int idx = course.topics.indexWhere((PhysicsTopic x) => x.id == topic.id);
    return idx >= 0 ? idx + 1 : 1;
  }

  static String _learningObjectives(String title, PhysicsTopic topic, int formulaCount) {
    final StringBuffer buf = StringBuffer(
      'After studying this chapter completely, you will be able to:\n\n',
    );
    buf
      ..writeln('- Define **$title** in formal textbook language with correct SI units.')
      ..writeln('- Distinguish **$title** from related quantities that students commonly confuse.')
      ..writeln('- Derive or justify the governing equation${formulaCount == 1 ? '' : 's'} from definitions.')
      ..writeln('- Solve multi-step numerical problems with unit checks at every step.')
      ..writeln('- Interpret position, velocity, force, or field diagrams (as applicable).')
      ..writeln('- Predict outcomes in the **3D Simulation & Lab** before running trials.')
      ..writeln('- Complete a formal **Experiment Report** with hypothesis, data, and conclusion.')
      ..writeln('- Pass the topic **Quiz** and **Mastery Checklist** without external notes.');
    for (final String c in topic.keyConcepts.take(4)) {
      buf.writeln('- Explain and apply **$c** in word and equation form.');
    }
    return buf.toString().trim();
  }

  static String _introductionDepth(
    String title,
    String courseTitle,
    PhysicsTopic topic,
    String levelLabel,
  ) {
    return 'This chapter is written for **$levelLabel** students in **$courseTitle**. '
        'Read it in order — do not jump to formulas before definitions. '
        'Every symbol introduced in Section ${topic.keyConcepts.isNotEmpty ? '3' : '3'} is used again in derivations, examples, and exam questions. '
        'When the text shows a diagram, reproduce it on paper and label axes before continuing.\n\n'
        '**Physical picture:** ${topic.summary}\n\n'
        '**Why engineers care:** ${topic.realWorld.isNotEmpty ? topic.realWorld : 'Quantitative models of $title appear in design, safety analysis, and instrumentation.'}';
  }

  static String _formulaReferenceTable(List<PhysicsFormula> formulas, String title) {
    if (formulas.isEmpty) {
      return '| Quantity | Symbol | SI unit | Relation |\n| --- | --- | --- | --- |\n'
          '| $title | — | (topic-specific) | Define from first principles |';
    }
    final StringBuffer buf = StringBuffer(
      '| Formula | Equation | When to use |\n| --- | --- | --- |\n',
    );
    for (final PhysicsFormula f in formulas) {
      buf.writeln('| ${f.name} | \$${f.latex}\$ | ${f.whenToUse ?? 'See Section 6'} |');
    }
    return buf.toString().trim();
  }

  static String _extendedPractice(String title, List<PhysicsFormula> formulas, String level) {
    final StringBuffer buf = StringBuffer()
      ..writeln('### Tier 1 — Definitions (no calculator)')
      ..writeln('- Define **$title** without looking.')
      ..writeln('- List all SI units involved.')
      ..writeln('- State one assumption of the standard model for **$title**.')
      ..writeln()
      ..writeln('### Tier 2 — Symbolic manipulation')
      ..writeln('- Rearrange the main equation to solve for each variable in turn.')
      ..writeln('- Show a limiting case (e.g., time interval → 0, friction → 0).')
      ..writeln()
      ..writeln('### Tier 3 — Numerical problems')
      ..writeln('- Three problems with realistic numbers and unit checks.')
      ..writeln('- One unit-conversion problem (e.g., km/h ↔ m/s).')
      ..writeln()
      ..writeln('### Tier 4 — Graph interpretation')
      ..writeln('- Given a sketch, read slope and area and connect to **$title**.')
      ..writeln()
      ..writeln('### Tier 5 — Engineering ($level)')
      ..writeln('- Design a measurement or safety criterion that depends on **$title**.');
    if (formulas.isNotEmpty) {
      buf.writeln('- Use **${formulas.first.name}** in a two-step design calculation.');
    }
    return buf.toString().trim();
  }

  static String _continueStudy(PhysicsChapterNav nav, String title, String courseTitle) {
    final StringBuffer buf = StringBuffer(
      'You have finished **Chapter: $title** in **$courseTitle**.\n\n',
    );
    if (nav.next != null) {
      buf.writeln(
        '**Next:** Open the AI Professor for **${nav.next!.title}** (Chapter ${nav.chapterNumber + 1}). '
        'Skim this chapter\'s Formula Quick Reference once before you start.',
      );
    } else {
      buf.writeln(
        '**Course complete:** Review all chapters in order, then take quizzes topic by topic.',
      );
    }
    buf
      ..writeln()
      ..writeln('**Recommended sequence for every chapter:**')
      ..writeln('1. AI Professor (read + voice) → 2. Formula Notebook → 3. 3D Simulation → 4. Experiment Report → 5. Quiz');
    return buf.toString().trim();
  }

  static String _historySection(String courseId, String tl) {
    final String base = switch (courseId) {
      'kinematics' || 'newtonian_mechanics' =>
        'Galileo\'s experiments on inclined planes challenged Aristotelian ideas about motion. '
        'Newton\'s *Principia* unified terrestrial and celestial mechanics with precise mathematical laws. '
        'Modern GPS, robotics, and aerospace engineering depend on this classical foundation.',
      'electric_circuits' || 'electrostatics' || 'magnetism' || 'em_induction' =>
        'Coulomb, Faraday, and Maxwell built the electromagnetic framework that powers modern civilization. '
        'From Volta\'s battery to semiconductor fabs, quantitative electrical theory drives technology.',
      'thermodynamics' || 'statistical_mechanics' =>
        'Carnot, Clausius, and Boltzmann connected heat, work, and microscopic disorder. '
        'Steam engines motivated the science; today it governs power plants, materials, and climate models.',
      'quantum_mechanics' || 'atomic_physics' || 'nuclear_physics' || 'particle_physics' =>
        'Planck, Einstein, Bohr, Schrödinger, and Dirac reshaped physics at atomic and subatomic scales. '
        'Lasers, MRI, semiconductors, and particle colliders emerged from this revolution.',
      'optics' => 'Huygens, Young, and Maxwell explained light as wave and field phenomena. '
          'Fiber optics, microscopy, and photonics extend those insights.',
      'gravitation' => 'Newton\'s law of gravitation and Einstein\'s general relativity explain orbits, tides, and GPS corrections.',
      _ => 'Physicists refined **$tl** through centuries of experiment, mathematical modeling, and engineering application.',
    };
    return '$base\n\nFor **$tl** specifically, trace how definitions tightened as measurement technology improved.';
  }

  static String _definitionsSection(String title, PhysicsTopic topic) {
    final StringBuffer buf = StringBuffer()
      ..writeln('### Primary definition: $title')
      ..writeln()
      ..writeln(topic.summary)
      ..writeln()
      ..writeln(
        '**Operational definition:** Describe exactly what you would **measure** in a laboratory '
        'to determine **$title**, including instruments and units.',
      )
      ..writeln();
    for (final String concept in topic.keyConcepts) {
      buf
        ..writeln('### $concept')
        ..writeln()
        ..writeln(
          '**$concept** — a central idea in **$title**. '
          'Write a complete textbook definition (one to three sentences). '
          'State whether it is scalar or vector, include SI units if applicable, '
          'and give one measurable example from engineering or science.',
        )
        ..writeln()
        ..writeln(
          '**Example sentence:** In a formal report, you might write: '
          '"The measured **$concept** was … (unit) under the following conditions: …"',
        )
        ..writeln();
    }
    if (topic.formulas.isNotEmpty) {
      buf.writeln('### Symbol preview');
      buf.writeln();
      for (final String line in topic.formulas) {
        buf.writeln('- $line');
      }
    }
    return buf.toString().trim();
  }

  static String _coreConceptsSection(String title, PhysicsTopic topic, String courseId, String tl) {
    return '${_distinctions(courseId, tl)}\n\n'
        '**Quantitative prediction:** Use definitions and governing relations to compute unknown quantities. '
        'Always list **knowns**, **unknowns**, and **assumptions** before algebra.\n\n'
        '**Experimental verification:** Compare predictions to simulation and laboratory data. '
        'If theory and data disagree by more than experimental uncertainty, revise the model — do not force the numbers.\n\n'
        '**Model limits:** Every model for **$title** fails outside stated assumptions — identify those limits before trusting an answer. '
        'Ask: Is friction negligible? Is the object a point particle? Is the field uniform?\n\n'
        '**Concept map:** ${topic.keyConcepts.join(' → ')} → quantitative prediction → lab/simulation check.\n\n'
        '**Key ideas for this topic:** ${topic.keyConcepts.join(' · ')}';
  }

  static String _distinctions(String courseId, String tl) {
    if (tl.contains('velocity') || tl.contains('speed')) {
      return '**Velocity vs speed:** Velocity is a vector (magnitude and direction); speed is the scalar magnitude only. '
          'Average velocity uses displacement, not total path length.';
    }
    if (tl.contains('distance') || tl.contains('displacement')) {
      return '**Distance vs displacement:** Distance is path length (scalar); displacement is the vector from start to finish.';
    }
    if (tl.contains('force') || tl.contains('weight')) {
      return '**Mass vs weight:** Mass (kg) measures inertia; weight (N) is the gravitational force on an object.';
    }
    if (tl.contains('heat') || tl.contains('temperature')) {
      return '**Temperature vs heat:** Temperature is a state variable (K); heat is energy transfer due to temperature difference (J).';
    }
    return 'Distinguish **related quantities** in $courseId by what is measured, which units apply, and which conservation laws constrain the system.';
  }

  static String _derivationsSection(String title, List<PhysicsFormula> formulas, String tl) {
    if (formulas.isEmpty) {
      return '**Full derivation outline for $title**\n\n'
          '1. State the physical definition in words.\n'
          '2. Write the definition as a ratio or rate (change in one quantity per unit of another).\n'
          '3. Introduce symbols for each measurable quantity.\n'
          '4. Apply conservation laws or geometric constraints if relevant.\n'
          '5. Isolate the target variable algebraically.\n'
          '6. Verify SI dimensions on both sides.\n'
          '7. Identify the limiting cases (e.g., interval → 0, friction → 0).';
    }
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < formulas.length; i++) {
      final PhysicsFormula f = formulas[i];
      buf
        ..writeln('### Derivation ${i + 1}: ${f.name}')
        ..writeln()
        ..writeln('1. Start from the definition of **$title**.')
        ..writeln('2. Express the definition as a ratio or rate.')
        ..writeln('3. Substitute symbols: ${f.symbols}.')
        ..writeln('4. Obtain \$\$${f.latex}\$\$ under stated assumptions.')
        ..writeln('5. **Dimensional check:** both sides must carry the same SI dimensions.')
        ..writeln('6. **Limiting case:** describe behavior when one parameter → 0 or ∞.')
        ..writeln();
    }
    return buf.toString().trim();
  }

  static String _formulaUnits(PhysicsFormula f, String courseId) {
    if (courseId.contains('circuit') || courseId.contains('electro')) {
      return 'Use SI electrical units: V, A, Ω, W, C as appropriate for ${f.name}.';
    }
    if (_mechanics(courseId)) return 'Typical SI units: m, s, m/s, m/s², N, J, kg.';
    return 'Express every symbol in SI base or derived units before substituting numbers.';
  }

  static String _derivationSketch(PhysicsFormula f, String title) {
    return 'Derived from the definition of **$title** and the meaning of each symbol in ${f.name}. '
        'See Section derivations for the full logical chain.';
  }

  static String _whenNotToUse(PhysicsFormula f, String tl) {
    return 'Do not apply **${f.name}** when the physical assumptions fail — e.g., non-uniform conditions, '
        'neglected interactions, or using scalar formulas for inherently vector phenomena in $tl problems.';
  }

  static String _visualSection(String courseId, String tl) {
    if (_mechanics(courseId)) {
      return '**Velocity–time graph (conceptual)**\n\n'
          '```\nVelocity\n  ^\n  |     _________  constant velocity\n  |    /\n  |   /\n  +--------------------> Time\n```\n\n'
          '**Position–time graph:** slope at any point equals instantaneous velocity.\n\n'
          '**Velocity–time graph:** slope equals acceleration; area under curve equals displacement.';
    }
    if (courseId.contains('circuit')) {
      return '**V–I characteristic:** slope relates to resistance.\n\n'
          '**Capacitor charging:** voltage vs time follows an exponential curve.';
    }
    return 'Sketch axes, label physical quantities with SI units, then interpret **slope** and **area** before fitting equations.';
  }

  static String _workedExamples(String title, List<PhysicsFormula> formulas, String tl) {
    final StringBuffer buf = StringBuffer();
    if (tl.contains('velocity') || tl.contains('speed')) {
      buf.writeln('### Example 1 — Average velocity');
      buf.writeln();
      buf.writeln('**Problem:** A vehicle travels **500 m east** in **25 s**. Find average velocity.');
      buf.writeln();
      buf.writeln('**Given:** ' r'$\Delta x = 500\,\mathrm{m}$' ' east, ' r'$\Delta t = 25\,\mathrm{s}$');
      buf.writeln();
      buf.writeln(r'**Equation:** $ \bar{v} = \dfrac{\Delta x}{\Delta t} $');
      buf.writeln();
      buf.writeln(r'**Calculation:** $ \bar{v} = \dfrac{500}{25} = 20\,\mathrm{m/s} $ east');
      buf.writeln();
      buf.writeln(r'**Answer:** $20\,\mathrm{m/s}$ east.');
      buf.writeln();
      buf.writeln('### Example 2 — Unit conversion');
      buf.writeln();
      buf.writeln(r'**Problem:** Convert $72\,\mathrm{km/h}$ to m/s.');
      buf.writeln();
      buf.writeln(r'**Solution:** $72 \times \dfrac{1000}{3600} = 20\,\mathrm{m/s}$.');
      buf.writeln();
      buf.writeln('### Example 3 — Displacement vs path length');
      buf.writeln();
      buf.writeln('**Problem:** A runner goes 400 m north then 400 m south in 200 s total. Find average velocity.');
      buf.writeln();
      buf.writeln(r'**Solution:** Displacement $= 0$, so $\bar{v} = 0$ (not average speed!).');
    } else if (formulas.isNotEmpty) {
      for (int i = 0; i < formulas.length && i < 3; i++) {
        final PhysicsFormula f = formulas[i];
        buf
          ..writeln('### Example ${i + 1} — ${f.name}')
          ..writeln()
          ..writeln('**Problem:** Apply **${f.name}** to a realistic **$title** scenario with numerical values.')
          ..writeln()
          ..writeln('**Given:** List known quantities with SI units (${f.symbols}).')
          ..writeln()
          ..writeln(r'**Equation:** $$')
          ..writeln(f.latex)
          ..writeln(r'$$')
          ..writeln()
          ..writeln('**Step 1:** Substitute known values.')
          ..writeln('**Step 2:** Solve for the unknown.')
          ..writeln('**Step 3:** Unit-check and sanity-check magnitude.')
          ..writeln()
          ..writeln(r'**Answer:** (complete with units).')
          ..writeln();
      }
    } else {
      buf.writeln('**Problem:** Define symbols, state knowns and unknowns for a **$title** scenario.');
      buf.writeln();
      buf.writeln('**Solution:** Select the governing relation, substitute SI values, and verify units.');
    }

    buf
      ..writeln('### Example — Conceptual')
      ..writeln()
      ..writeln('**Problem:** Name one situation where **$title** appears constant but a related quantity still changes.')
      ..writeln()
      ..writeln('**Solution:** Explain using definitions from Section 3 and identify the hidden assumption.')
      ..writeln()
      ..writeln('### Example — Graph reading')
      ..writeln()
      ..writeln('**Problem:** From a diagram in Section 7, read slope and area and interpret them physically for **$title**.')
      ..writeln()
      ..writeln('**Solution:** Connect graph geometry to definitions — show the calculation on the diagram.');

    return buf.toString();
  }

  static String _commonErrors(String tl, String title) {
    return '❌ **Mistake:** Treating **$title** as unrelated to measurement and units.\n'
        '✅ **Correct:** Define every symbol and carry SI units through the entire calculation.\n\n'
        '❌ **Mistake:** Confusing closely related quantities (see Section 4).\n'
        '✅ **Correct:** State what is measured, whether it is scalar or vector, and which graph feature represents it.\n\n'
        '❌ **Mistake:** Memorizing equations without knowing when they fail.\n'
        '✅ **Correct:** List assumptions before using any formula for $tl problems.';
  }

  static String _applicationsSection(String courseId, String title, PhysicsTopic topic) {
    final String rw = topic.realWorld.isNotEmpty ? topic.realWorld : '';
    final String careers = topic.career.isNotEmpty ? topic.career : '';
    return '### Engineering & science\n$rw\n\n'
        '### Careers\n$careers\n\n'
        '### Industry examples\n${_engineering(courseId, title)}';
  }

  static String _engineering(String courseId, String title) {
    return switch (courseId) {
      'kinematics' || 'newtonian_mechanics' =>
        '**Aerospace:** trajectory and orbital velocity. **Robotics:** motion planning. **Automotive:** braking and safety. **Medicine:** blood-flow diagnostics.',
      'electric_circuits' || 'electrostatics' => 'Electronics design, power grids, medical imaging, sensors.',
      'optics' => 'Cameras, telescopes, fiber networks, laser surgery.',
      'thermodynamics' => 'Engines, HVAC, power plants, materials processing.',
      'quantum_mechanics' => 'Semiconductors, lasers, MRI, quantum computing research.',
      'gravitation' => 'Satellite orbits, GPS, planetary missions.',
      _ => 'Apply **$title** in design, measurement, and failure analysis.',
    };
  }

  static String _advancedSection(String courseId, String level, String tl) {
    if (tl.contains('velocity') || courseId == 'kinematics') {
      return r'**Relativistic velocity addition:** At speeds approaching the speed of light, Galilean addition fails; use relativistic transformations.'
          '\n\n**Reference frames:** Velocity is not absolute — always state the observer.'
          '\n\n**Light speed limit:** No massive object reaches the speed of light in special relativity.';
    }
    if (level == 'Graduate' || level == 'Research') {
      return 'Graduate-level extensions of **$tl** include formal mathematical structure, approximation methods, and open research questions.';
    }
    return '**Beyond introductory treatment:** Explore how **$tl** extends in modern physics, computational modeling, and frontier research after mastering this chapter.';
  }

  static String _labSteps(String topic, String room) {
    return '1. **Setup** — Enter **$room** and calibrate sensors.\n'
        '2. **Measure** — Record data for **$topic** (multiple trials).\n'
        '3. **Analyze** — Plot results; compare to theoretical prediction.\n'
        '4. **Report** — Complete an **Experiment Report** with uncertainty analysis.';
  }

  static String _practiceProblems(String title, List<PhysicsFormula> formulas, String level) {
    final String eq = formulas.isNotEmpty ? ' using \$${formulas.first.latex}\$' : '';
    return '### Concept questions (answer in complete sentences)\n'
        '- Define **$title** in textbook language.\n'
        '- What is measured, and in which SI units?\n'
        '- Name two assumptions of the standard model.\n'
        '- Explain one diagram from Section 7 in words.\n\n'
        '### Calculation problems\n'
        '- Solve five numerical problems on **$title**$eq.\n'
        '- Convert between common unit systems (include one non-SI unit).\n'
        '- One inverse problem: given the result, find an input.\n\n'
        '### Graph problems\n'
        '- Sketch a graph for **$title** and label slope/area meaning.\n'
        '- Given a graph, read values and compute **$title**.\n\n'
        '### Engineering problems\n'
        '- Design a measurement or safety system that depends on **$title**.\n'
        '- Write a one-paragraph design memo for an engineer.\n\n'
        '### Research questions ($level)\n'
        '- How would you test a limiting case experimentally?\n'
        '- What observation would falsify the model used in this chapter?';
  }

  static String _examQuestions(String title, String level) {
    return '**Short answer:** Define **$title** and list two applications.\n\n'
        '**Problem:** Multi-step calculation combining definitions and governing relations.\n\n'
        '**Essay ($level):** Explain when the standard model for **$title** breaks down and what observation would falsify it.';
  }

  static String _researchChallenge(String title, String course, String level) {
    return 'Propose an original experiment or simulation study that advances understanding of **$title** in **$course**. '
        'State the hypothesis, apparatus or simulation setup, measurable variables, and expected signature of success. ($level track)';
  }

  static String _summary(String title, List<String> concepts, int formulaCount) {
    return '- **$title** is defined precisely with SI units and physical meaning.\n'
        '- $formulaCount governing relation${formulaCount == 1 ? '' : 's'} cover the quantitative core.\n'
        '- Graphs, labs, and simulations verify predictions.\n'
        '- Applications span engineering, medicine, and research.\n'
        '- Key concepts: ${concepts.take(4).join(', ')}.';
  }

  static String _checklist(String title, List<String> concepts) {
    final StringBuffer buf = StringBuffer('You have mastered **$title** when you can:\n\n');
    buf.writeln('- State a complete textbook definition with units');
    for (final String c in concepts.take(5)) {
      buf.writeln('- Explain and apply **$c**');
    }
    buf
      ..writeln('- Derive or justify the main equations')
      ..writeln('- Solve worked examples without notes')
      ..writeln('- Identify and correct common errors')
      ..writeln('- Complete the virtual lab and topic quiz')
      ..writeln('- Connect the topic to a real engineering system');
    return buf.toString();
  }

  static bool _mechanics(String id) => <String>{
        'kinematics',
        'newtonian_mechanics',
        'work_energy_power',
        'momentum_collisions',
        'rotational_mechanics',
        'gravitation',
        'oscillations',
        'fluid_mechanics',
      }.contains(id);
}
