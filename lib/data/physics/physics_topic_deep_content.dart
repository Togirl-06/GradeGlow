import '../../models/physics/physics_program.dart';
import 'physics_formula_engine.dart';

/// Textbook-depth prose, definitions, and worked examples per physics topic.
class PhysicsTopicDeepContent {
  PhysicsTopicDeepContent._();

  static String definitions({
    required PhysicsTopic topic,
    required String title,
  }) {
    final String? custom = _definitionBlocks[topic.id];
    if (custom != null) return custom;

    final StringBuffer buf = StringBuffer()
      ..writeln('### Primary definition: $title')
      ..writeln()
      ..writeln(_primaryDefinition(title, topic))
      ..writeln()
      ..writeln(
        '**Operational definition:** To measure **$title** in a laboratory, identify the physical quantity, '
        'select calibrated instruments, record SI units, and repeat trials to estimate uncertainty.',
      )
      ..writeln();

    for (final String concept in topic.keyConcepts) {
      if (concept == title || concept == 'Quantitative prediction' || concept == 'Experimental verification' || concept == 'Model limits') {
        continue;
      }
      buf
        ..writeln('### $concept')
        ..writeln()
        ..writeln(_conceptDefinition(concept, title, topic))
        ..writeln();
    }

    buf
      ..writeln('### Quantitative prediction')
      ..writeln()
      ..writeln(
        'Given known initial conditions and governing relations, **quantitative prediction** means '
        'calculating unknown values for **$title** before running a simulation or experiment. '
        'List knowns, unknowns, and assumptions; substitute into the appropriate equation; '
        'carry units through every step.',
      )
      ..writeln()
      ..writeln('### Experimental verification')
      ..writeln()
      ..writeln(
        '**Experimental verification** compares theoretical predictions for **$title** to measured data. '
        'If disagreement exceeds estimated uncertainty, revise the model (friction neglected? instrument bias?) '
        'rather than forcing the numbers to match.',
      )
      ..writeln()
      ..writeln('### Model limits')
      ..writeln()
      ..writeln(
        'Every model for **$title** has **model limits** — conditions where the simplified equations fail. '
        'Examples: relativistic speeds, non-uniform fields, quantum scales, or turbulent flow. '
        'State limits before trusting an answer on an exam or in design.',
      );

    if (topic.formulas.isNotEmpty) {
      buf
        ..writeln()
        ..writeln('### Symbol reference')
        ..writeln();
      for (final String line in topic.formulas) {
        if (line.startsWith('Define') || line.startsWith('Check') || line.startsWith('Apply')) {
          continue;
        }
        buf.writeln('- $line');
      }
    }
    return buf.toString().trim();
  }

  static String deepDive({
    required PhysicsTopic topic,
    required String title,
    required String courseId,
  }) {
    final String? custom = _deepDiveBlocks[topic.id];
    if (custom != null) return custom;
    return _genericDeepDive(title, topic, courseId);
  }

  static String workedExamples({
    required PhysicsTopic topic,
    required String title,
    required List<PhysicsFormula> formulas,
    required String topicLower,
  }) {
    final String? custom = _exampleBlocks[topic.id];
    if (custom != null) return custom;

    if (topicLower.contains('acceleration')) return _accelerationExamples();
    if (topicLower.contains('velocity') || topicLower.contains('speed')) return _velocityExamples();
    if (topicLower.contains('displacement') || topicLower.contains('distance')) return _displacementExamples();
    if (topicLower.contains('projectile')) return _projectileExamples();
    if (topicLower.contains('circular')) return _circularExamples();
    if (topicLower.contains('graph')) return _graphExamples();
    if (formulas.isNotEmpty) return _formulaExamples(title, formulas);

    return _genericExamples(title);
  }

  static String commonErrors({
    required String title,
    required String topicLower,
    required String topicId,
  }) {
    final String? custom = _errorBlocks[topicId];
    if (custom != null) return custom;

    if (topicLower.contains('acceleration')) {
      return r'''❌ **Mistake:** Treating acceleration as always positive.
✅ **Correct:** Acceleration is a vector; sign indicates direction along the chosen axis.

❌ **Mistake:** Using $v/t$ when velocity changes direction.
✅ **Correct:** Use $\Delta v$ (vector change), not speed change only.

❌ **Mistake:** Assuming zero acceleration means zero velocity.
✅ **Correct:** Constant nonzero velocity has zero acceleration.''';
    }
    if (topicLower.contains('velocity') || topicLower.contains('speed')) {
      return '❌ **Mistake:** Using total path length for average velocity.\n'
          '✅ **Correct:** Average velocity uses **displacement**.\n\n'
          '❌ **Mistake:** Omitting direction from velocity answers.\n'
          '✅ **Correct:** Velocity is a vector — always include direction or component signs.';
    }
    return '❌ **Mistake:** Treating **$title** as unrelated to measurement and units.\n'
        '✅ **Correct:** Define every symbol and carry SI units through the entire calculation.\n\n'
        '❌ **Mistake:** Confusing closely related quantities (see Section 4).\n'
        '✅ **Correct:** State what is measured, whether it is scalar or vector, and which graph feature represents it.\n\n'
        '❌ **Mistake:** Memorizing equations without knowing when they fail.\n'
        '✅ **Correct:** List assumptions before using any formula for $topicLower problems.';
  }

  static String _primaryDefinition(String title, PhysicsTopic topic) {
    return switch (title.toLowerCase()) {
      'acceleration' =>
        '**Acceleration** is the rate of change of velocity with respect to time. '
        'It is a **vector** quantity measured in **m/s²**. '
        'Whenever velocity changes in magnitude **or** direction, acceleration is nonzero.',
      'velocity' =>
        '**Velocity** is the rate of change of position with respect to time in a specific direction. '
        'It is a **vector** (m/s); speed is its scalar magnitude only.',
      'speed' =>
        '**Speed** is the scalar rate at which an object covers distance: distance divided by time (m/s). '
        'It carries no direction.',
      'displacement' =>
        r'**Displacement** is the vector from initial to final position: $\Delta\vec{x} = \vec{x}_f - \vec{x}_i$ (m). '
        r'It is not the same as total path length.',
      'distance' =>
        '**Distance** is the total path length traveled (scalar, m). '
        r'It is always nonnegative and can exceed $|\Delta x|$ when the path reverses.',
      'position' =>
        '**Position** specifies where an object is relative to a chosen origin on a coordinate system (m).',
      'motion graphs' =>
        '**Motion graphs** plot kinematic variables (position, velocity, acceleration) versus time '
        'so slope and area carry physical meaning.',
      'projectile motion' =>
        '**Projectile motion** describes an object launched with initial velocity under gravity alone '
        '(ideal model: no air drag). Horizontal and vertical motions are independent.',
      'circular motion' =>
        '**Circular motion** is motion along a circular path with continuously changing velocity direction, '
        'hence centripetal acceleration toward the center.',
      _ => topic.summary.isNotEmpty
          ? topic.summary
          : '**$title** is a core physical quantity in this course. Define it with precise language, '
              'SI units, and a measurable operational procedure.',
    };
  }

  static String _conceptDefinition(String concept, String title, PhysicsTopic topic) {
    return '**$concept** supports a complete understanding of **$title**. '
        'In textbook language: relate **$concept** to measurable quantities, state SI units, '
        'and give one engineering example where an incorrect treatment of **$concept** would cause design failure. '
        '${topic.hook}';
  }

  static String _genericDeepDive(String title, PhysicsTopic topic, String courseId) {
    return '### Physical picture\n\n${topic.summary}\n\n'
        '### Why this matters\n\n${topic.realWorld.isNotEmpty ? topic.realWorld : 'Engineers and scientists use **$title** in design, safety analysis, and instrumentation.'}\n\n'
        '### Career connections\n\n${topic.career.isNotEmpty ? topic.career : 'Research labs, industry R&D, and national science programs rely on accurate models of **$title**.'}\n\n'
        '### Study strategy\n\n'
        '1. Read definitions aloud and write each symbol by hand.\n'
        '2. Sketch every diagram in Section 7 on paper before the quiz.\n'
        '3. Run the **3D Simulation & Lab** and compare data to your calculation.\n'
        '4. Complete the **Experiment Report** with hypothesis, data table, and conclusion.\n\n'
        '### Connection to $courseId\n\n'
        'This topic is one link in the **$courseId** chain — master it before advancing to the next chapter.';
  }

  static final Map<String, String> _definitionBlocks = <String, String>{
    'kinematics_acceleration': r'''
### Primary definition: Acceleration

**Acceleration** is the rate of change of velocity with respect to time. It is a **vector** measured in **m/s²** (meters per second squared). If either the speed or the direction of velocity changes, acceleration is nonzero.

$$a = \frac{\Delta v}{\Delta t} \quad \text{(average)} \qquad a = \frac{dv}{dt} \quad \text{(instantaneous)}$$

**Operational definition:** Use a motion sensor or video analysis to record velocity at two times; divide the change in velocity by the time interval. Report direction along the axis of motion.

### Average vs instantaneous acceleration

**Average acceleration** describes the whole interval: $a_{\mathrm{avg}} = \Delta v / \Delta t$.

**Instantaneous acceleration** is the limit as $\Delta t \to 0$ — the slope of the velocity–time graph at one instant.

### Positive, negative, and centripetal acceleration

On a straight axis: positive acceleration means velocity component increases along +x; negative means it decreases.

**Centripetal acceleration** $a_c = v^2/r$ points toward the center when speed is constant but direction changes (turning car, satellite orbit).

### Kinematic equations (constant acceleration)

When $a$ is constant along a line:

- $v_f = v_i + at$
- $\Delta x = v_i t + \tfrac{1}{2}at^2$
- $v_f^2 = v_i^2 + 2a\Delta x$

### Quantitative prediction

Given $v_i$, $a$, and $t$, predict $v_f$ and $\Delta x$ before launching the simulation.

### Experimental verification

Measure velocity vs time in the virtual lab; compute slope of the best-fit line and compare to the set acceleration.

### Model limits

These equations fail for variable acceleration, relativistic speeds, or rotation without using the correct component along the path.
''',
    'kinematics_motion_graphs': r'''
### Primary definition: Motion graphs

A **motion graph** displays a kinematic variable (position $x$, velocity $v$, or acceleration $a$) on the vertical axis versus **time** $t$ on the horizontal axis.

**Key readings:**
- **Slope of $x$–$t$** → velocity
- **Slope of $v$–$t$** → acceleration
- **Area under $v$–$t$** → displacement $\Delta x$

Always label axes with quantity **and** SI unit before interpreting.
''',
  };

  static final Map<String, String> _deepDiveBlocks = <String, String>{
    'kinematics_acceleration': r'''
### Uniform vs non-uniform acceleration

**Uniform (constant) acceleration** produces straight-line $v$–$t$ graphs. Most introductory problems assume constant $a$ so the three kinematic equations apply.

**Non-uniform acceleration** requires calculus: $a(t) = dv/dt$, $v(t) = \int a\,dt$. Jerk is the rate of change of acceleration.

### Acceleration without speed change

A car at constant speed **around a curve** has changing velocity **direction** — therefore nonzero acceleration (centripetal, toward the center). Speed alone does not tell the whole story.

### Free fall

Near Earth's surface, objects in free fall (neglecting air drag) have $a \approx -9.8\,\mathrm{m/s^2}$ downward. Mass cancels — all objects fall with the same acceleration in vacuum.

### Engineering applications

- **Automotive:** crash tests use $a = \Delta v/\Delta t$ from accelerometers.
- **Aerospace:** rocket staging depends on thrust-to-weight and resulting acceleration.
- **Elevators:** comfort limits cap vertical acceleration (~1–1.5 m/s² for passengers).

### Graph mastery

Reproduce a $v$–$t$ graph from a given $a$–$t$ graph by integrating (area). Reproduce $x$–$t$ from $v$–$t$ the same way.
''',
    'kinematics_projectile_motion': r'''
### Independence of motion

Horizontal motion: $a_x = 0$ → $x = v_0\cos\theta\, t$.

Vertical motion: $a_y = -g$ → $y = v_0\sin\theta\, t - \tfrac{1}{2}gt^2$.

Solve vertical and horizontal equations separately, linked only by common time $t$.

### Range and maximum height

Level ground range: $R = v_0^2\sin(2\theta)/g$. Maximum range at $\theta = 45°$ without drag.

Maximum height: $H = v_0^2\sin^2\theta/(2g)$.

### Real-world limits

Air drag, spin, and wind break the ideal model — sports ballistics and artillery use numerical simulation.
''',
  };

  static final Map<String, String> _exampleBlocks = <String, String>{
    'kinematics_acceleration': _accelerationExamplesStatic,
    'kinematics_motion_graphs': _graphExamplesStatic,
    'kinematics_projectile_motion': _projectileExamplesStatic,
    'kinematics_circular_motion': _circularExamplesStatic,
  };

  static final Map<String, String> _errorBlocks = <String, String>{
    'kinematics_acceleration': r'''
❌ **Mistake:** Confusing acceleration with velocity.
✅ **Correct:** Velocity is rate of position change; acceleration is rate of **velocity** change.

❌ **Mistake:** Thinking deceleration is a separate physical quantity.
✅ **Correct:** "Deceleration" means acceleration opposite to velocity — still just $a$ with a sign.

❌ **Mistake:** Using $v/t$ instead of $\Delta v/\Delta t$ when $v$ changes.
✅ **Correct:** Always use the **change** in velocity over the interval.

❌ **Mistake:** Forgetting centripetal acceleration in turns at constant speed.
✅ **Correct:** Direction change implies $\vec{a}$ toward the center: $a_c = v^2/r$.
''',
  };

  static String _accelerationExamples() => _accelerationExamplesStatic;

  static const String _accelerationExamplesStatic = r'''
### Example 1 — Average acceleration

**Problem:** A train increases speed from $10\,\mathrm{m/s}$ to $30\,\mathrm{m/s}$ in $5\,\mathrm{s}$ along a straight track. Find average acceleration.

**Given:** $v_i = 10\,\mathrm{m/s}$, $v_f = 30\,\mathrm{m/s}$, $\Delta t = 5\,\mathrm{s}$

**Equation:** $a_{\mathrm{avg}} = \dfrac{\Delta v}{\Delta t}$

**Calculation:** $a = \dfrac{30 - 10}{5} = 4\,\mathrm{m/s^2}$ along the track

**Answer:** $4\,\mathrm{m/s^2}$ in the direction of motion.

---

### Example 2 — Braking (negative acceleration)

**Problem:** A car slows from $25\,\mathrm{m/s}$ to $5\,\mathrm{m/s}$ in $4\,\mathrm{s}$. Find acceleration.

**Solution:** $a = \dfrac{5 - 25}{4} = -5\,\mathrm{m/s^2}$ (opposite to initial velocity — braking).

---

### Example 3 — Kinematic equation

**Problem:** A rocket starts from rest with $a = 3\,\mathrm{m/s^2}$. How far does it travel in $10\,\mathrm{s}$?

**Equation:** $\Delta x = v_i t + \tfrac{1}{2}at^2$

**Solution:** $\Delta x = 0 + \tfrac{1}{2}(3)(10^2) = 150\,\mathrm{m}$

---

### Example 4 — Find time from velocity

**Problem:** $v_i = 2\,\mathrm{m/s}$, $v_f = 18\,\mathrm{m/s}$, $a = 4\,\mathrm{m/s^2}$. Find $t$.

**Solution:** $t = \dfrac{v_f - v_i}{a} = \dfrac{16}{4} = 4\,\mathrm{s}$

---

### Example 5 — Centripetal acceleration

**Problem:** A car rounds a curve of radius $50\,\mathrm{m}$ at $20\,\mathrm{m/s}$. Find $a_c$.

**Equation:** $a_c = v^2/r$

**Solution:** $a_c = 400/50 = 8\,\mathrm{m/s^2}$ toward the center.

---

### Example 6 — Graph reading

**Problem:** A $v$–$t$ graph is a straight line from $(0, 5\,\mathrm{m/s})$ to $(4\,\mathrm{s}, 13\,\mathrm{m/s})$. Find $a$ and $\\Delta x$.

**Solution:** Slope $a = (13-5)/4 = 2\,\mathrm{m/s^2}$. Area $\\Delta x = \tfrac{1}{2}(5+13)(4) = 36\,\mathrm{m}$.
''';

  static String _velocityExamples() => r'''
### Example 1 — Average velocity

**Problem:** A vehicle travels **500 m east** in **25 s**. Find average velocity.

**Solution:** $\bar{v} = 500/25 = 20\,\mathrm{m/s}$ east.

### Example 2 — Unit conversion

**Problem:** Convert $72\,\mathrm{km/h}$ to m/s.

**Solution:** $72 \times \dfrac{1000}{3600} = 20\,\mathrm{m/s}$.

### Example 3 — Displacement vs path

**Problem:** A runner goes 400 m north then 400 m south in 200 s. Find average velocity.

**Solution:** Displacement $= 0$, so $\bar{v} = 0$ (not average speed!).
''';

  static String _displacementExamples() => r'''
### Example 1 — Straight line

**Problem:** A walker moves from $x_i = 3\,\mathrm{m}$ to $x_f = 18\,\mathrm{m}$. Find displacement.

**Solution:** $\Delta x = 18 - 3 = 15\,\mathrm{m}$ along +x.

### Example 2 — Round trip

**Problem:** Drive 30 km north, then 30 km south. Find displacement and distance.

**Solution:** Displacement $= 0$; distance $= 60\,\mathrm{km}$.

### Example 3 — From velocity

**Problem:** Constant $\bar{v} = 12\,\mathrm{m/s}$ for $7.5\,\mathrm{s}$. Find $\Delta x$.

**Solution:** $\Delta x = 12 \times 7.5 = 90\,\mathrm{m}$.
''';

  static String _projectileExamples() => _projectileExamplesStatic;

  static const String _projectileExamplesStatic = r'''
### Example 1 — Horizontal and vertical components

**Problem:** Ball launched at $v_0 = 50\,\mathrm{m/s}$ at $\theta = 37°$ ($\sin\theta = 0.6$, $\cos\theta = 0.8$). Find $v_x$ and initial $v_y$.

**Solution:** $v_x = 50(0.8) = 40\,\mathrm{m/s}$; $v_{y0} = 50(0.6) = 30\,\mathrm{m/s}$.

### Example 2 — Time of flight (level ground)

**Problem:** Find time to return to launch height for $v_{y0} = 30\,\mathrm{m/s}$, $g = 10\,\mathrm{m/s^2}$.

**Solution:** $0 = v_{y0} t - \tfrac{1}{2}gt^2$ → $t = 0$ or $t = 2v_{y0}/g = 6\,\mathrm{s}$.

### Example 3 — Range

**Problem:** $v_0 = 40\,\mathrm{m/s}$, $\theta = 45°$, $g = 10\,\mathrm{m/s^2}$. Estimate range.

**Solution:** $R = v_0^2\sin(2\theta)/g = 1600/10 = 160\,\mathrm{m}$.
''';

  static String _circularExamples() => _circularExamplesStatic;

  static const String _circularExamplesStatic = r'''
### Example 1 — Tangential speed

**Problem:** Wheel radius $r = 0.35\,\mathrm{m}$, period $T = 0.7\,\mathrm{s}$. Find $v$.

**Solution:** $v = 2\pi r/T = 2\pi(0.35)/0.7 \approx 3.14\,\mathrm{m/s}$.

### Example 2 — Centripetal acceleration

**Problem:** $v = 10\,\mathrm{m/s}$, $r = 25\,\mathrm{m}$. Find $a_c$.

**Solution:** $a_c = v^2/r = 100/25 = 4\,\mathrm{m/s^2}$ inward.

### Example 3 — Angular speed

**Problem:** $\omega = 4\,\mathrm{rad/s}$, $r = 2\,\mathrm{m}$. Find $v$.

**Solution:** $v = r\omega = 8\,\mathrm{m/s}$.
''';

  static String _graphExamples() => _graphExamplesStatic;

  static const String _graphExamplesStatic = r'''
### Example 1 — Slope of $x$–$t$

**Problem:** Position increases from $10\,\mathrm{m}$ to $34\,\mathrm{m}$ in $6\,\mathrm{s}$ (straight line). Find average velocity.

**Solution:** $\bar{v} = (34-10)/6 = 4\,\mathrm{m/s}$.

### Example 2 — Area under $v$–$t$

**Problem:** $v$ constant at $15\,\mathrm{m/s}$ for $8\,\mathrm{s}$. Find displacement.

**Solution:** Rectangle area: $\Delta x = 15 \times 8 = 120\,\mathrm{m}$.

### Example 3 — Piecewise motion

**Problem:** $v = 10\,\mathrm{m/s}$ for $3\,\mathrm{s}$, then $v = 4\,\mathrm{m/s}$ for $5\,\mathrm{s}$. Total displacement?

**Solution:** $10(3) + 4(5) = 50\,\mathrm{m}$.
''';

  static String _formulaExamples(String title, List<PhysicsFormula> formulas) {
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < formulas.length && i < 4; i++) {
      final PhysicsFormula f = formulas[i];
      buf
        ..writeln('### Example ${i + 1} — ${f.name}')
        ..writeln()
        ..writeln('**Problem:** Apply **${f.name}** to a realistic **$title** scenario.')
        ..writeln()
        ..writeln('**Given:** Choose numerical values consistent with ${f.symbols}.')
        ..writeln()
        ..writeln(r'**Equation:** $$')
        ..writeln(f.latex)
        ..writeln(r'$$')
        ..writeln()
        ..writeln('**Step 1:** Substitute values with SI units.')
        ..writeln('**Step 2:** Solve for the unknown.')
        ..writeln('**Step 3:** Verify dimensions and physical reasonableness.')
        ..writeln()
        ..writeln('**Answer:** State the result with units and one-sentence interpretation.')
        ..writeln();
    }
    return buf.toString().trim();
  }

  static String _genericExamples(String title) {
    return '### Example 1 — Definition in use\n\n'
        '**Problem:** Write a formal measurement report sentence that uses **$title** with units.\n\n'
        '**Solution:** "The measured **$title** was … (SI unit) under controlled conditions …"\n\n'
        '### Example 2 — Conceptual\n\n'
        '**Problem:** Name one situation where **$title** is constant but a related quantity changes.\n\n'
        '**Solution:** Explain using Section 3 definitions and identify the hidden assumption.';
  }
}
