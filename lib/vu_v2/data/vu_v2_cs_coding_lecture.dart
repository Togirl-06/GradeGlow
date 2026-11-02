import 'vu_v2_cs_try_it.dart';

enum VuV2MimoKind {
  /// Short tip + code, tap Continue.
  teach,
  /// Tap the missing piece into a blank.
  fillBlank,
  /// Multiple choice about the code.
  quiz,
  /// Tap chips in order to build a line.
  arrange,
}

/// One Mimo-style interactive beat.
class VuV2CsLectureStep {
  const VuV2CsLectureStep({
    required this.kind,
    required this.coach,
    required this.title,
    this.code,
    this.blankToken = '____',
    this.choices = const <String>[],
    this.correctAnswer,
    this.correctOrder = const <String>[],
    this.successLine = 'Nice! That\'s it.',
    this.failLine = 'Not quite — try again.',
    this.emoji = '💻',
  });

  final VuV2MimoKind kind;
  final String coach;
  final String title;
  /// Code with `____` where the blank goes (fillBlank), or full snippet (teach/quiz).
  final String? code;
  final String blankToken;
  final List<String> choices;
  final String? correctAnswer;
  final List<String> correctOrder;
  final String successLine;
  final String failLine;
  final String emoji;

  bool get needsSolve =>
      kind == VuV2MimoKind.fillBlank ||
      kind == VuV2MimoKind.quiz ||
      kind == VuV2MimoKind.arrange;
}

class VuV2CsCodingLecture {
  const VuV2CsCodingLecture({
    required this.spec,
    required this.steps,
    required this.solutionCode,
  });

  final VuV2CsTryItSpec spec;
  final List<VuV2CsLectureStep> steps;
  final String solutionCode;
}

/// Builds short, interactive Mimo-style coding lessons.
abstract final class VuV2CsCodingLectureBuilder {
  static VuV2CsCodingLecture build(VuV2CsTryItSpec spec) {
    final String topic = spec.topicTitle;
    final String lang = spec.languageLabel;
    final String langId = spec.languageId;
    final _Pack pack = _packFor(topic, langId, spec);

    final List<VuV2CsLectureStep> steps = <VuV2CsLectureStep>[
      VuV2CsLectureStep(
        kind: VuV2MimoKind.teach,
        emoji: '👋',
        title: 'Let\'s learn $topic',
        coach:
            'Tap through tiny challenges — like Mimo. '
            'I\'ll show a bit of $lang, then you fill the gaps.',
        code: pack.introCode,
      ),
      VuV2CsLectureStep(
        kind: VuV2MimoKind.teach,
        emoji: '👀',
        title: 'Look at this code',
        coach: pack.lookCoach,
        code: pack.lookCode,
      ),
      VuV2CsLectureStep(
        kind: VuV2MimoKind.fillBlank,
        emoji: '✍️',
        title: 'Fill in the blank',
        coach: pack.fillCoach,
        code: pack.fillTemplate,
        choices: pack.fillChoices,
        correctAnswer: pack.fillAnswer,
        successLine: pack.fillSuccess,
        failLine: 'Hmm, not that one. Pick the piece that fits the blank.',
      ),
      VuV2CsLectureStep(
        kind: VuV2MimoKind.quiz,
        emoji: '🧠',
        title: 'Quick check',
        coach: pack.quizCoach,
        code: pack.quizCode,
        choices: pack.quizChoices,
        correctAnswer: pack.quizAnswer,
        successLine: 'Yes! You get it.',
        failLine: 'Close — read the code again and pick once more.',
      ),
      VuV2CsLectureStep(
        kind: VuV2MimoKind.arrange,
        emoji: '🧩',
        title: 'Build the line',
        coach: 'Tap the chips in the right order to build this line.',
        choices: pack.arrangeChips,
        correctOrder: pack.arrangeOrder,
        successLine: 'Perfect order. That line would run!',
        failLine: 'Order matters — clear and try again.',
      ),
      VuV2CsLectureStep(
        kind: VuV2MimoKind.fillBlank,
        emoji: '🎯',
        title: 'One more blank',
        coach: pack.fill2Coach,
        code: pack.fill2Template,
        choices: pack.fill2Choices,
        correctAnswer: pack.fill2Answer,
        successLine: 'You\'re cooking 🔥',
        failLine: 'Try another chip — you\'ve got this.',
      ),
      VuV2CsLectureStep(
        kind: VuV2MimoKind.quiz,
        emoji: '🐞',
        title: 'Spot the bug',
        coach: 'Which snippet is correct for $topic?',
        code: null,
        choices: pack.bugChoices,
        correctAnswer: pack.bugAnswer,
        successLine: 'Bug crushed. Nice eye.',
        failLine: 'That one\'s cursed — pick the healthy version.',
      ),
      VuV2CsLectureStep(
        kind: VuV2MimoKind.teach,
        emoji: '🚀',
        title: 'You\'re ready!',
        coach:
            'Lesson clear. Next you\'ll Try It Yourself — write real $lang for $topic.',
        code: pack.finaleCode,
      ),
    ];

    return VuV2CsCodingLecture(
      spec: spec,
      steps: steps,
      solutionCode: pack.finaleCode,
    );
  }

  static _Pack _packFor(String topic, String langId, VuV2CsTryItSpec spec) {
    final String t = topic.toLowerCase();
    if (_has(t, const <String>['paragraph', '<p>'])) {
      return _paragraphsPack(topic);
    }
    if (_has(t, const <String>['image', 'img', 'picture', 'photo'])) {
      return _imagesPack(topic);
    }
    if (_has(t, const <String>['link', 'anchor', 'href'])) {
      return _linksPack(topic);
    }
    if (_has(t, const <String>['loop', 'for ', 'while'])) {
      return _loopsPack(topic, langId);
    }
    if (_has(t, const <String>['function', 'method'])) {
      return _functionsPack(topic, langId);
    }
    if (_has(t, const <String>['variable', 'let ', 'const'])) {
      return _variablesPack(topic, langId);
    }
    if (_has(t, const <String>['list', 'ul', 'ol']) && langId == 'html') {
      return _listsPack(topic);
    }
    if (langId == 'html' || langId == 'css') {
      return _htmlGenericPack(topic, langId, spec);
    }
    return _codeGenericPack(topic, langId, spec);
  }

  static bool _has(String t, List<String> keys) {
    for (final String k in keys) {
      if (t.contains(k)) return true;
    }
    return false;
  }

  static _Pack _paragraphsPack(String topic) {
    return const _Pack(
      introCode: '<p>Hello, GradeGlow.</p>',
      lookCoach: 'A paragraph wraps text in <p>…</p> so it gets its own block of space.',
      lookCode: '<p>Hello, GradeGlow.</p>',
      fillCoach: 'Tap the tag that starts a paragraph.',
      fillTemplate: '<____>Hello, GradeGlow.</____>',
      fillChoices: <String>['p', 'div', 'span', 'br'],
      fillAnswer: 'p',
      fillSuccess: 'Yes — p = paragraph.',
      quizCoach: 'Why do we write </p>?',
      quizCode: '<p>Learn HTML</p>',
      quizChoices: <String>[
        'It closes the paragraph so the HTML tree stays valid',
        'It changes the text color',
        'It inserts an image',
        'It creates a link',
      ],
      quizAnswer: 'It closes the paragraph so the HTML tree stays valid',
      arrangeChips: <String>['<p>', 'Hello world', '</p>'],
      arrangeOrder: <String>['<p>', 'Hello world', '</p>'],
      fill2Coach: 'Put a short sentence inside the paragraph.',
      fill2Template: '<p>____</p>',
      fill2Choices: <String>['I love coding', 'src', 'href', '</p>'],
      fill2Answer: 'I love coding',
      bugChoices: <String>[
        '<p>Hello</p>',
        '<p>Hello<p>',
        '</p>Hello<p>',
        '<paragraph>Hello</paragraph>',
      ],
      bugAnswer: '<p>Hello</p>',
      finaleCode:
          '<article>\n'
          '  <h1>Paragraphs</h1>\n'
          '  <p>First idea.</p>\n'
          '  <p>Second idea.</p>\n'
          '</article>',
    );
  }

  static _Pack _imagesPack(String topic) {
    return const _Pack(
      introCode: '<img src="cat.jpg" alt="A sleepy cat">',
      lookCoach: 'An image needs two key attributes: where it lives, and what it is.',
      lookCode: '<img src="cat.jpg" alt="A sleepy cat">',
      fillCoach: 'Tap the attribute that points to the image file.',
      fillTemplate: '<img ____="cat.jpg" alt="A sleepy cat">',
      fillChoices: <String>['src', 'href', 'link', 'file'],
      fillAnswer: 'src',
      fillSuccess: 'Yes — src = source = “get this file.”',
      quizCoach: 'What does alt do?',
      quizCode: '<img src="cat.jpg" alt="A sleepy cat">',
      quizChoices: <String>[
        'Describes the image for accessibility / broken loads',
        'Sets the file size',
        'Changes the background color',
        'Opens a new tab',
      ],
      quizAnswer: 'Describes the image for accessibility / broken loads',
      arrangeChips: <String>['<img', 'src="cat.jpg"', 'alt="Cat"', '>'],
      arrangeOrder: <String>['<img', 'src="cat.jpg"', 'alt="Cat"', '>'],
      fill2Coach: 'Finish the tag — what text helps when the picture fails?',
      fill2Template: '<img src="logo.png" alt="____">',
      fill2Choices: <String>['Brand logo', 'image', 'photo', 'asdf'],
      fill2Answer: 'Brand logo',
      bugChoices: <String>[
        '<img src="cat.jpg" alt="Orange cat">',
        '<img src="cat.jpg">',
        '<img alt="Orange cat">',
        '<img src="" alt="image">',
      ],
      bugAnswer: '<img src="cat.jpg" alt="Orange cat">',
      finaleCode:
          '<figure>\n'
          '  <img src="logo.png" alt="GradeGlow logo" width="160">\n'
          '  <figcaption>Learn by coding.</figcaption>\n'
          '</figure>',
    );
  }

  static _Pack _linksPack(String topic) {
    return const _Pack(
      introCode: '<a href="images.html">Next: Images</a>',
      lookCoach: 'Links need a destination (href) and honest click text.',
      lookCode: '<a href="images.html">Next: Images</a>',
      fillCoach: 'Which attribute sets where the link goes?',
      fillTemplate: '<a ____="images.html">Next: Images</a>',
      fillChoices: <String>['href', 'src', 'link', 'to'],
      fillAnswer: 'href',
      fillSuccess: 'href = hypertext reference. Destination locked.',
      quizCoach: 'Best link text?',
      quizCode: '<a href="images.html">…</a>',
      quizChoices: <String>[
        'Next: Images',
        'Click here',
        'Link',
        'asdf',
      ],
      quizAnswer: 'Next: Images',
      arrangeChips: <String>['<a', 'href="home.html"', '>', 'Home', '</a>'],
      arrangeOrder: <String>['<a', 'href="home.html"', '>', 'Home', '</a>'],
      fill2Coach: 'Complete the destination for the About page.',
      fill2Template: '<a href="____">About</a>',
      fill2Choices: <String>['about.html', '#', 'click', 'image.jpg'],
      fill2Answer: 'about.html',
      bugChoices: <String>[
        '<a href="about.html">About</a>',
        '<a href="#">Click here</a>',
        '<a>About</a>',
        '<a href="">About</a>',
      ],
      bugAnswer: '<a href="about.html">About</a>',
      finaleCode:
          '<nav>\n'
          '  <a href="index.html">Home</a> ·\n'
          '  <a href="images.html">Images</a>\n'
          '</nav>',
    );
  }

  static _Pack _listsPack(String topic) {
    return const _Pack(
      introCode: '<ul>\n  <li>HTML</li>\n  <li>CSS</li>\n</ul>',
      lookCoach: 'Lists need a wrapper (ul/ol) and items (li).',
      lookCode: '<ul>\n  <li>HTML</li>\n  <li>CSS</li>\n</ul>',
      fillCoach: 'What tag wraps unordered items?',
      fillTemplate: '<____>\n  <li>HTML</li>\n</____>',
      fillChoices: <String>['ul', 'ol', 'div', 'p'],
      fillAnswer: 'ul',
      fillSuccess: 'ul = unordered list. Bullets unlocked.',
      quizCoach: 'When should you use ol instead of ul?',
      quizCode: null,
      quizChoices: <String>[
        'When order matters (steps)',
        'When you want prettier bullets',
        'Never — ul is always better',
        'Only for images',
      ],
      quizAnswer: 'When order matters (steps)',
      arrangeChips: <String>['<li>', 'Images', '</li>'],
      arrangeOrder: <String>['<li>', 'Images', '</li>'],
      fill2Coach: 'Add the item tag.',
      fill2Template: '<ul>\n  <____>Learn lists</____>\n</ul>',
      fill2Choices: <String>['li', 'ul', 'p', 'span'],
      fill2Answer: 'li',
      bugChoices: <String>[
        '<ul><li>OK</li></ul>',
        '<li>Orphan</li>',
        '<ul>OK</ul>',
        '<p>- fake list</p>',
      ],
      bugAnswer: '<ul><li>OK</li></ul>',
      finaleCode: '<ol>\n  <li>Read</li>\n  <li>Code</li>\n  <li>Quiz</li>\n</ol>',
    );
  }

  static _Pack _loopsPack(String topic, String langId) {
    final bool js = langId == 'javascript' || langId == 'typescript';
    if (js) {
      return const _Pack(
        introCode: 'for (let i = 0; i < 3; i++) {\n  console.log(i);\n}',
        lookCoach: 'A loop repeats a body while the condition stays true.',
        lookCode: 'for (let i = 0; i < 3; i++) {\n  console.log(i);\n}',
        fillCoach: 'What keyword starts this loop?',
        fillTemplate: '____ (let i = 0; i < 3; i++) {\n  console.log(i);\n}',
        fillChoices: <String>['for', 'if', 'def', 'loop'],
        fillAnswer: 'for',
        fillSuccess: 'for = “repeat with a counter.”',
        quizCoach: 'What prints?',
        quizCode: 'for (let i = 0; i < 3; i++) console.log(i);',
        quizChoices: <String>['0 1 2', '1 2 3', '0 1 2 3', '3 2 1'],
        quizAnswer: '0 1 2',
        arrangeChips: <String>['for', '(let i=0; i<3; i++)', '{', 'console.log(i)', '}'],
        arrangeOrder: <String>['for', '(let i=0; i<3; i++)', '{', 'console.log(i)', '}'],
        fill2Coach: 'Complete the stop condition.',
        fill2Template: 'for (let i = 0; i ____ 3; i++) {\n  console.log(i);\n}',
        fill2Choices: <String>['<', '>', '==', '='],
        fill2Answer: '<',
        bugChoices: <String>[
          'for (let i = 0; i < 3; i++) console.log(i);',
          'for (let i = 0; i < 3;) console.log(i);',
          'for (let i = 0; i > 3; i++) console.log(i);',
          'while (true) console.log(i);',
        ],
        bugAnswer: 'for (let i = 0; i < 3; i++) console.log(i);',
        finaleCode: 'const nums = [2, 4, 6];\nlet total = 0;\nfor (const n of nums) total += n;\nconsole.log(total);',
      );
    }
    return const _Pack(
      introCode: 'for i in range(3):\n    print(i)',
      lookCoach: 'A loop repeats a body for each item / count.',
      lookCode: 'for i in range(3):\n    print(i)',
      fillCoach: 'What keyword starts this loop?',
      fillTemplate: '____ i in range(3):\n    print(i)',
      fillChoices: <String>['for', 'if', 'def', 'loop'],
      fillAnswer: 'for',
      fillSuccess: 'for = walk through a sequence.',
      quizCoach: 'What prints?',
      quizCode: 'for i in range(3):\n    print(i)',
      quizChoices: <String>['0 1 2', '1 2 3', '0 1 2 3', '3'],
      quizAnswer: '0 1 2',
      arrangeChips: <String>['for', 'n', 'in', 'nums:', 'print(n)'],
      arrangeOrder: <String>['for', 'n', 'in', 'nums:', 'print(n)'],
      fill2Coach: 'Complete the range stop (exclusive).',
      fill2Template: 'for i in range(____):\n    print(i)',
      fill2Choices: <String>['3', '0', 'i', 'print'],
      fill2Answer: '3',
      bugChoices: <String>[
        'for i in range(3):\n    print(i)',
        'i = 0\nwhile i < 3:\n    print(i)\n# forgot i += 1',
        'for i in range(3)\nprint(i)',
        'for i range(3):\n    print(i)',
      ],
      bugAnswer: 'for i in range(3):\n    print(i)',
      finaleCode: 'nums = [2, 4, 6]\ntotal = 0\nfor n in nums:\n    total += n\nprint(total)',
    );
  }

  static _Pack _functionsPack(String topic, String langId) {
    final bool js = langId == 'javascript' || langId == 'typescript';
    if (js) {
      return const _Pack(
        introCode: 'function greet(name) {\n  return `Hi, \${name}!`;\n}',
        lookCoach: 'Functions package a reusable action with inputs.',
        lookCode: 'function greet(name) {\n  return `Hi, \${name}!`;\n}',
        fillCoach: 'Which keyword defines this function?',
        fillTemplate: '____ greet(name) {\n  return `Hi, \${name}!`;\n}',
        fillChoices: <String>['function', 'for', 'class', 'const'],
        fillAnswer: 'function',
        fillSuccess: 'function names the recipe.',
        quizCoach: 'What does return do?',
        quizCode: 'function double(n) {\n  return n * 2;\n}',
        quizChoices: <String>[
          'Sends a value back to the caller',
          'Prints to the screen only',
          'Deletes the function',
          'Starts a loop',
        ],
        quizAnswer: 'Sends a value back to the caller',
        arrangeChips: <String>['function', 'add(a, b)', '{', 'return a + b', '}'],
        arrangeOrder: <String>['function', 'add(a, b)', '{', 'return a + b', '}'],
        fill2Coach: 'Call the function with 5.',
        fill2Template: 'console.log(double(____));',
        fill2Choices: <String>['5', 'double', 'n', 'return'],
        fill2Answer: '5',
        bugChoices: <String>[
          'function add(a, b) { return a + b; }',
          'function add(a, b) { a + b; }',
          'function add { return a + b; }',
          'add(a, b) => return a + b',
        ],
        bugAnswer: 'function add(a, b) { return a + b; }',
        finaleCode: 'function label(topic) {\n  return `Learning: \${topic}`;\n}\nconsole.log(label("Functions"));',
      );
    }
    return const _Pack(
      introCode: 'def greet(name):\n    return f"Hi, {name}!"',
      lookCoach: 'Functions package a reusable action with inputs.',
      lookCode: 'def greet(name):\n    return f"Hi, {name}!"',
      fillCoach: 'Which keyword defines this function?',
      fillTemplate: '____ greet(name):\n    return f"Hi, {name}!"',
      fillChoices: <String>['def', 'for', 'class', 'fun'],
      fillAnswer: 'def',
      fillSuccess: 'def = define a function in Python.',
      quizCoach: 'What does return do?',
      quizCode: 'def double(n):\n    return n * 2',
      quizChoices: <String>[
        'Sends a value back to the caller',
        'Only prints to the screen',
        'Deletes n',
        'Starts a loop',
      ],
      quizAnswer: 'Sends a value back to the caller',
      arrangeChips: <String>['def', 'add(a, b):', 'return', 'a', '+', 'b'],
      arrangeOrder: <String>['def', 'add(a, b):', 'return', 'a', '+', 'b'],
      fill2Coach: 'Call double with 5.',
      fill2Template: 'print(double(____))',
      fill2Choices: <String>['5', 'double', 'n', 'return'],
      fill2Answer: '5',
      bugChoices: <String>[
        'def add(a, b):\n    return a + b',
        'def add(a, b):\n    a + b',
        'def add(a, b)\n    return a + b',
        'add(a, b):\n    return a + b',
      ],
      bugAnswer: 'def add(a, b):\n    return a + b',
      finaleCode: 'def label(topic):\n    return f"Learning: {topic}"\n\nprint(label("Functions"))',
    );
  }

  static _Pack _variablesPack(String topic, String langId) {
    final bool js = langId == 'javascript' || langId == 'typescript';
    if (js) {
      return const _Pack(
        introCode: 'const title = "Images";\nconsole.log(title);',
        lookCoach: 'A variable sticks a name on a value.',
        lookCode: 'const title = "Images";\nconsole.log(title);',
        fillCoach: 'Pick a keyword to declare a constant.',
        fillTemplate: '____ title = "Images";',
        fillChoices: <String>['const', 'for', 'def', 'class'],
        fillAnswer: 'const',
        fillSuccess: 'const = name a value you won\'t reassign.',
        quizCoach: 'After this, what prints?',
        quizCode: 'let x = 2;\nx = 5;\nconsole.log(x);',
        quizChoices: <String>['5', '2', 'x', 'undefined'],
        quizAnswer: '5',
        arrangeChips: <String>['let', 'score', '=', '10'],
        arrangeOrder: <String>['let', 'score', '=', '10'],
        fill2Coach: 'Store the string Images.',
        fill2Template: 'const title = "____";',
        fill2Choices: <String>['Images', 'const', 'title', 'print'],
        fill2Answer: 'Images',
        bugChoices: <String>[
          'const title = "Images";\nconsole.log(title);',
          'console.log(title);\nconst title = "Images";',
          'const title;\nconsole.log(title);',
          'title == "Images";',
        ],
        bugAnswer: 'const title = "Images";\nconsole.log(title);',
        finaleCode: 'const src = "cat.jpg";\nconst alt = "Cat";\nconsole.log(`<img src="\${src}" alt="\${alt}">`);',
      );
    }
    return const _Pack(
      introCode: 'title = "Images"\nprint(title)',
      lookCoach: 'A variable sticks a name on a value.',
      lookCode: 'title = "Images"\nprint(title)',
      fillCoach: 'What operator stores a value in a name?',
      fillTemplate: 'title ____ "Images"',
      fillChoices: <String>['=', '==', ':', '->'],
      fillAnswer: '=',
      fillSuccess: '= stores. == compares.',
      quizCoach: 'What prints?',
      quizCode: 'x = 2\nx = 5\nprint(x)',
      quizChoices: <String>['5', '2', 'x', 'None'],
      quizAnswer: '5',
      arrangeChips: <String>['score', '=', '10'],
      arrangeOrder: <String>['score', '=', '10'],
      fill2Coach: 'Put Images in the variable.',
      fill2Template: 'title = "____"',
      fill2Choices: <String>['Images', 'title', 'print', '='],
      fill2Answer: 'Images',
      bugChoices: <String>[
        'title = "Images"\nprint(title)',
        'print(title)\ntitle = "Images"',
        'title == "Images"\nprint(title)',
        'title\nprint(title)',
      ],
      bugAnswer: 'title = "Images"\nprint(title)',
      finaleCode: 'src = "cat.jpg"\nalt = "Cat"\nprint(f\'<img src="{src}" alt="{alt}">\')',
    );
  }

  static _Pack _htmlGenericPack(String topic, String langId, VuV2CsTryItSpec spec) {
    final String starter = spec.starterCode.trim().isEmpty
        ? '<h1>$topic</h1>\n<p>Hello</p>'
        : spec.starterCode.trim();
    return _Pack(
      introCode: starter.split('\n').take(4).join('\n'),
      lookCoach: 'Read this $topic snippet once — then you\'ll fill gaps.',
      lookCode: starter.split('\n').take(6).join('\n'),
      fillCoach: 'Tap the missing HTML keyword/tag piece.',
      fillTemplate: langId == 'css'
          ? '.$topic {\n  color: ____;\n}'
          : '<____>$topic</____>',
      fillChoices: langId == 'css'
          ? const <String>['#fb923c', 'h1', 'div', 'src']
          : const <String>['h1', 'img', 'href', 'for'],
      fillAnswer: langId == 'css' ? '#fb923c' : 'h1',
      fillSuccess: 'Locked in.',
      quizCoach: 'What is the main job of $topic here?',
      quizCode: starter.split('\n').take(5).join('\n'),
      quizChoices: <String>[
        'Structure or style the page for $topic',
        'Compile a mobile app binary',
        'Train a neural net',
        'Format a spreadsheet',
      ],
      quizAnswer: 'Structure or style the page for $topic',
      arrangeChips: langId == 'css'
          ? <String>['h1', '{', 'color:', 'orange;', '}']
          : <String>['<h1>', topic, '</h1>'],
      arrangeOrder: langId == 'css'
          ? const <String>['h1', '{', 'color:', 'orange;', '}']
          : <String>['<h1>', topic, '</h1>'],
      fill2Coach: 'Complete this tiny $topic line.',
      fill2Template: langId == 'css' ? 'p { ____: 16px; }' : '<p>____</p>',
      fill2Choices: langId == 'css'
          ? const <String>['font-size', 'src', 'href', 'def']
          : <String>['Learn $topic', 'src', 'href', 'for'],
      fill2Answer: langId == 'css' ? 'font-size' : 'Learn $topic',
      bugChoices: <String>[
        starter.split('\n').take(2).join(' '),
        '<h1>$topic<h1>',
        '<p>$topic<p>',
        'h1 $topic /h1',
      ],
      bugAnswer: starter.split('\n').take(2).join(' '),
      finaleCode: starter,
    );
  }

  static _Pack _codeGenericPack(String topic, String langId, VuV2CsTryItSpec spec) {
    final String starter = spec.starterCode.trim().isEmpty
        ? '# $topic\ndata = [1, 2, 3]\nprint(data)'
        : spec.starterCode.trim();
    final bool js = langId == 'javascript' || langId == 'typescript';
    return _Pack(
      introCode: starter.split('\n').take(5).join('\n'),
      lookCoach: 'Here\'s a tiny $topic sample. Next screens = you play.',
      lookCode: starter.split('\n').take(8).join('\n'),
      fillCoach: 'Fill the blank to make this run for $topic.',
      fillTemplate: js
          ? 'const data = [1, 2, 3];\nconsole.____(data);'
          : 'data = [1, 2, 3]\n____(data)',
      fillChoices: js
          ? const <String>['log', 'print', 'write', 'echo']
          : const <String>['print', 'log', 'echo', 'write'],
      fillAnswer: js ? 'log' : 'print',
      fillSuccess: 'Output unlocked — now you can see results.',
      quizCoach: 'Best next move after writing $topic code?',
      quizCode: starter.split('\n').take(4).join('\n'),
      quizChoices: const <String>[
        'Trace a tiny example, then Run',
        'Optimize for nanoseconds first',
        'Delete the prints',
        'Skip testing',
      ],
      quizAnswer: 'Trace a tiny example, then Run',
      arrangeChips: js
          ? const <String>['const', 'n', '=', '3']
          : const <String>['n', '=', '3'],
      arrangeOrder: js
          ? const <String>['const', 'n', '=', '3']
          : const <String>['n', '=', '3'],
      fill2Coach: 'Complete the list of sample values.',
      fill2Template: js ? 'const data = [____];' : 'data = [____]',
      fill2Choices: const <String>['1, 2, 3', 'print', 'for', 'def'],
      fill2Answer: '1, 2, 3',
      bugChoices: <String>[
        js ? 'console.log(data);' : 'print(data)',
        js ? 'console.log(Data);' : 'Print(data)',
        js ? 'console.print(data);' : 'printf(data)',
        'echo data',
      ],
      bugAnswer: js ? 'console.log(data);' : 'print(data)',
      finaleCode: starter,
    );
  }
}

class _Pack {
  const _Pack({
    required this.introCode,
    required this.lookCoach,
    required this.lookCode,
    required this.fillCoach,
    required this.fillTemplate,
    required this.fillChoices,
    required this.fillAnswer,
    required this.fillSuccess,
    required this.quizCoach,
    required this.quizCode,
    required this.quizChoices,
    required this.quizAnswer,
    required this.arrangeChips,
    required this.arrangeOrder,
    required this.fill2Coach,
    required this.fill2Template,
    required this.fill2Choices,
    required this.fill2Answer,
    required this.bugChoices,
    required this.bugAnswer,
    required this.finaleCode,
  });

  final String introCode;
  final String lookCoach;
  final String lookCode;
  final String fillCoach;
  final String fillTemplate;
  final List<String> fillChoices;
  final String fillAnswer;
  final String fillSuccess;
  final String quizCoach;
  final String? quizCode;
  final List<String> quizChoices;
  final String quizAnswer;
  final List<String> arrangeChips;
  final List<String> arrangeOrder;
  final String fill2Coach;
  final String fill2Template;
  final List<String> fill2Choices;
  final String fill2Answer;
  final List<String> bugChoices;
  final String bugAnswer;
  final String finaleCode;
}
