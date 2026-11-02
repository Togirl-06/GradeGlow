import 'vu_v2_cs_try_it.dart';
import 'vu_v2_interactive_notes.dart';

/// W3Schools-style CS lecture beats: Example → Explained → Syntax → Exercises.
abstract final class VuV2CsW3sNotes {
  static List<VuV2InteractiveBeat> build({
    required String topicTitle,
    required String courseTitle,
    required String trackTitle,
    String? topicId,
  }) {
    final VuV2CsTryItSpec spec = VuV2CsTryItResolver.resolve(
      topicTitle: topicTitle,
      topicId: topicId,
      trackTitle: trackTitle,
      courseTitle: courseTitle,
    );
    final _Page page = _pageFor(topicTitle, spec);

    final List<VuV2InteractiveBeat> beats = <VuV2InteractiveBeat>[
      VuV2InteractiveBeat(
        kind: VuV2BeatKind.teach,
        emoji: '📗',
        eyebrow: 'INTRODUCTION',
        title: topicTitle,
        body:
            '**What is $topicTitle?**\n\n'
            '${page.whatIs}\n\n'
            '**When to use it**\n'
            '${page.whenToUse}',
      ),
      VuV2InteractiveBeat(
        kind: VuV2BeatKind.teach,
        emoji: '💻',
        eyebrow: 'EXAMPLE',
        title: 'Example',
        body:
            'A simple $topicTitle example (${spec.languageLabel}):\n\n'
            '```\n${page.exampleCode}\n```\n\n'
            '**Result**\n'
            '```\n${page.result}\n```',
      ),
      VuV2InteractiveBeat(
        kind: VuV2BeatKind.teach,
        emoji: '🔎',
        eyebrow: 'EXAMPLE EXPLAINED',
        title: 'Example Explained',
        body: page.exampleExplained,
      ),
      VuV2InteractiveBeat(
        kind: VuV2BeatKind.teach,
        emoji: '📐',
        eyebrow: 'SYNTAX',
        title: 'Syntax',
        body: page.syntaxBody,
      ),
      VuV2InteractiveBeat(
        kind: VuV2BeatKind.teach,
        emoji: '🧪',
        eyebrow: 'MORE EXAMPLES',
        title: 'More Examples',
        body:
            '```\n${page.moreExample}\n```\n\n'
            '${page.moreTalk}',
      ),
      ...List<VuV2InteractiveBeat>.generate(page.exercises.length, (int i) {
        final _Ex e = page.exercises[i];
        return VuV2InteractiveBeat(
          kind: VuV2BeatKind.pulse,
          emoji: '✏️',
          eyebrow: 'EXERCISE ${i + 1}',
          title: 'Exercise',
          body: e.body,
          pulsePrompt: e.prompt,
          pulseChoices: e.choices,
        );
      }),
      VuV2InteractiveBeat(
        kind: VuV2BeatKind.teach,
        emoji: '🚀',
        eyebrow: 'TRY IT YOURSELF',
        title: 'You\'re ready',
        body:
            'That\'s the W3Schools flow for **$topicTitle**:\n'
            'read the example → understand the syntax → practice → code it yourself.\n\n'
            'Next screen: **Try It Yourself** editor.',
      ),
    ];

    final int n = beats.length;
    return List<VuV2InteractiveBeat>.generate(n, (int i) {
      final VuV2InteractiveBeat b = beats[i];
      return VuV2InteractiveBeat(
        kind: b.kind,
        emoji: b.emoji,
        eyebrow: '${b.eyebrow} · ${i + 1}/$n',
        title: b.title,
        body: b.body,
        pulsePrompt: b.pulsePrompt,
        pulseChoices: b.pulseChoices,
      );
    });
  }

  static _Page _pageFor(String topic, VuV2CsTryItSpec spec) {
    final String t = topic.toLowerCase();
    if (_has(t, const <String>['paragraph', '<p>'])) return _paragraphs(spec);
    if (_has(t, const <String>['image', 'img', 'picture', 'photo'])) {
      return _images(spec);
    }
    if (_has(t, const <String>['link', 'anchor', 'href'])) return _links(spec);
    if (_has(t, const <String>['heading', 'h1', 'h2'])) return _headings(spec);
    if (_has(t, const <String>['list', 'ul', 'ol', 'li'])) return _lists(spec);
    return _fromSpec(spec);
  }

  static bool _has(String t, List<String> keys) {
    for (final String k in keys) {
      if (t.contains(k)) return true;
    }
    return false;
  }

  static String _bullets(List<String> lines) =>
      lines.map((String b) => '• $b').join('\n');

  static _Page _fromSpec(VuV2CsTryItSpec spec) {
    final String code = spec.starterCode.trim().isEmpty
        ? '// ${spec.topicTitle}\nprint("Hello")'
        : spec.starterCode.trim();
    final List<String> syntax = spec.syntaxBullets.isEmpty
        ? <String>[
            'Write a tiny example',
            'Run it',
            'Compare output to the expected result',
          ]
        : spec.syntaxBullets;
    return _Page(
      whatIs:
          '${spec.topicTitle} is a coding topic in ${spec.languageLabel}. '
          '${spec.task}',
      whenToUse: spec.runContext,
      exampleCode: code.split('\n').take(12).join('\n'),
      result: 'Input: ${spec.exampleInput}\nOutput: ${spec.exampleOutput}',
      exampleExplained:
          '**Step by step**\n${spec.exampleSteps}\n\n'
          'Read the example from top to bottom. Each line should earn its place.',
      syntaxBody:
          '**${spec.languageLabel} syntax tips**\n\n${_bullets(syntax)}',
      moreExample: code.split('\n').take(8).join('\n'),
      moreTalk: 'Edit this in Try It Yourself and change one value, then Run.',
      exercises: <_Ex>[
        _Ex(
          body: 'What should you do first with ${spec.topicTitle}?',
          prompt: 'Choose the best habit',
          choices: <VuV2PulseChoice>[
            const VuV2PulseChoice(
              label: 'Study a tiny example, then try it yourself',
              correct: true,
              reaction: 'Classic W3Schools method. Yes.',
            ),
            const VuV2PulseChoice(
              label: 'Memorize only the title',
              correct: false,
              reaction: 'You need the example + practice.',
            ),
            const VuV2PulseChoice(
              label: 'Skip the code boxes',
              correct: false,
              reaction: 'Code boxes are the lesson.',
            ),
          ],
        ),
        _Ex(
          body:
              'Expected output for this topic:\n```\n${spec.exampleOutput}\n```',
          prompt: 'If your Run output differs, you should…',
          choices: const <VuV2PulseChoice>[
            VuV2PulseChoice(
              label: 'Re-read the example and fix your code',
              correct: true,
              reaction: 'Debug against the example.',
            ),
            VuV2PulseChoice(
              label: 'Ignore the example',
              correct: false,
              reaction: 'The example is your reference.',
            ),
            VuV2PulseChoice(
              label: 'Delete the language',
              correct: false,
              reaction: 'Keep going — compare carefully.',
            ),
          ],
        ),
      ],
    );
  }

  static _Page _paragraphs(VuV2CsTryItSpec spec) {
    return _Page(
      whatIs:
          'HTML paragraphs are defined with the `<p>` tag.\n\n'
          'A paragraph always starts on a new line, and browsers automatically add '
          'some white space before and after a paragraph.',
      whenToUse:
          'Use `<p>` whenever you write a block of text that is one idea — '
          'like a sentence or short paragraph on a webpage.',
      exampleCode: '<p>This is a paragraph.</p>\n<p>This is another paragraph.</p>',
      result: 'This is a paragraph.\n\nThis is another paragraph.',
      exampleExplained:
          '**Example Explained**\n\n'
          '• The `<p>` element defines a paragraph.\n'
          '• A paragraph always starts on a new line.\n'
          '• Browsers automatically add margin before/after `<p>`.\n'
          '• You cannot nest a `<p>` inside another `<p>`.',
      syntaxBody:
          '**HTML Paragraph Syntax**\n\n'
          '```\n<p>Write your text here</p>\n```\n\n'
          '${_bullets(<String>[
            'Start with <p>',
            'Write the text content',
            'End with </p>',
            'Use a new <p> for each paragraph',
          ])}',
      moreExample:
          '<p>The quick brown fox.</p>\n'
          '<p>Jumps over the lazy dog.</p>',
      moreTalk:
          'Two ideas → two paragraphs. That keeps the page easy to read.',
      exercises: const <_Ex>[
        _Ex(
          body: 'Which tag defines an HTML paragraph?',
          prompt: 'Pick the correct tag',
          choices: <VuV2PulseChoice>[
            VuV2PulseChoice(label: '<p>', correct: true, reaction: 'Correct!'),
            VuV2PulseChoice(label: '<para>', correct: false, reaction: 'Not a real HTML tag.'),
            VuV2PulseChoice(label: '<paragraph>', correct: false, reaction: 'Use <p>.'),
            VuV2PulseChoice(label: '<br>', correct: false, reaction: '<br> is a line break.'),
          ],
        ),
        _Ex(
          body: '```\n<p>Hello\n```\nWhat is missing?',
          prompt: 'Choose',
          choices: <VuV2PulseChoice>[
            VuV2PulseChoice(
              label: 'The closing </p> tag',
              correct: true,
              reaction: 'Yes — always close the paragraph.',
            ),
            VuV2PulseChoice(label: 'An <img> tag', correct: false, reaction: 'Not required here.'),
            VuV2PulseChoice(label: 'A href attribute', correct: false, reaction: 'That\'s for links.'),
            VuV2PulseChoice(label: 'Nothing', correct: false, reaction: 'It should be closed.'),
          ],
        ),
        _Ex(
          body: 'Best way to write two separate ideas?',
          prompt: 'Choose',
          choices: <VuV2PulseChoice>[
            VuV2PulseChoice(
              label: 'Two <p> elements',
              correct: true,
              reaction: 'Perfect — one idea per paragraph.',
            ),
            VuV2PulseChoice(
              label: 'Only <br> with no <p>',
              correct: false,
              reaction: 'br breaks a line; p structures paragraphs.',
            ),
            VuV2PulseChoice(
              label: '<paragraph> tags',
              correct: false,
              reaction: 'Not valid HTML.',
            ),
          ],
        ),
        _Ex(
          body: 'What does the browser add around <p>?',
          prompt: 'Choose',
          choices: <VuV2PulseChoice>[
            VuV2PulseChoice(
              label: 'Space (margin) before and after',
              correct: true,
              reaction: 'That\'s why paragraphs look separated.',
            ),
            VuV2PulseChoice(
              label: 'A random image',
              correct: false,
              reaction: 'No — that\'s not automatic.',
            ),
            VuV2PulseChoice(
              label: 'A hyperlink',
              correct: false,
              reaction: 'Links need <a>.',
            ),
          ],
        ),
      ],
    );
  }

  static _Page _images(VuV2CsTryItSpec spec) {
    return _Page(
      whatIs:
          'HTML images are defined with the `<img>` tag.\n\n'
          'The `<img>` tag is empty (no closing tag). It has two important attributes: '
          '`src` (image source) and `alt` (alternative text).',
      whenToUse: 'Use images to show photos, logos, icons, and diagrams on a page.',
      exampleCode: '<img src="cat.jpg" alt="A sleepy cat">',
      result: '[ image of a sleepy cat ]',
      exampleExplained:
          '**Example Explained**\n\n'
          '• `src` points to the image file path or URL.\n'
          '• `alt` describes the image for accessibility and broken-image fallback.\n'
          '• `<img>` does not need a closing tag.',
      syntaxBody:
          '**HTML Image Syntax**\n\n'
          '```\n<img src="url" alt="text">\n```\n\n'
          '${_bullets(<String>[
            'src — required path/URL of the image',
            'alt — text description of the image',
            'width / height — optional size attributes (CSS preferred for layout)',
          ])}',
      moreExample:
          '<img src="logo.png" alt="GradeGlow logo" width="120">',
      moreTalk: 'Always write meaningful alt text — not just “image”.',
      exercises: const <_Ex>[
        _Ex(
          body: 'Which attribute sets the image file?',
          prompt: 'Choose',
          choices: <VuV2PulseChoice>[
            VuV2PulseChoice(label: 'src', correct: true, reaction: 'src = source.'),
            VuV2PulseChoice(label: 'href', correct: false, reaction: 'href is for links.'),
            VuV2PulseChoice(label: 'alt', correct: false, reaction: 'alt describes the image.'),
            VuV2PulseChoice(label: 'link', correct: false, reaction: 'Not an img attribute.'),
          ],
        ),
        _Ex(
          body: 'Why use alt?',
          prompt: 'Choose',
          choices: <VuV2PulseChoice>[
            VuV2PulseChoice(
              label: 'Accessibility + fallback if the image fails',
              correct: true,
              reaction: 'Correct.',
            ),
            VuV2PulseChoice(
              label: 'It compresses the image',
              correct: false,
              reaction: 'Compression is separate.',
            ),
            VuV2PulseChoice(
              label: 'It opens a new tab',
              correct: false,
              reaction: 'That\'s target on links.',
            ),
          ],
        ),
        _Ex(
          body: '```\n<img src="cat.jpg">\n```\nWhat\'s wrong?',
          prompt: 'Choose',
          choices: <VuV2PulseChoice>[
            VuV2PulseChoice(
              label: 'Missing alt text',
              correct: true,
              reaction: 'Add alt for accessibility.',
            ),
            VuV2PulseChoice(
              label: 'Needs </img>',
              correct: false,
              reaction: 'img is a void element.',
            ),
            VuV2PulseChoice(
              label: 'src is illegal',
              correct: false,
              reaction: 'src is required and correct here.',
            ),
          ],
        ),
      ],
    );
  }

  static _Page _links(VuV2CsTryItSpec spec) {
    return _Page(
      whatIs:
          'HTML links are defined with the `<a>` tag (anchor).\n\n'
          'The most important attribute is `href`, which indicates the link destination.',
      whenToUse: 'Use links to navigate between pages or to external websites.',
      exampleCode: '<a href="https://www.w3schools.com">Visit W3Schools</a>',
      result: 'Visit W3Schools  (clickable)',
      exampleExplained:
          '**Example Explained**\n\n'
          '• `<a>` creates a hyperlink.\n'
          '• `href` is the destination URL or page.\n'
          '• The text between tags is what the user clicks.',
      syntaxBody:
          '**HTML Link Syntax**\n\n'
          '```\n<a href="url">link text</a>\n```\n\n'
          '${_bullets(<String>[
            'href — destination',
            'link text — visible clickable label',
            'Use clear labels (not just “click here”)',
          ])}',
      moreExample: '<a href="images.html">HTML Images</a>',
      moreTalk: 'Relative links point to pages on your own site.',
      exercises: const <_Ex>[
        _Ex(
          body: 'Which attribute sets the link destination?',
          prompt: 'Choose',
          choices: <VuV2PulseChoice>[
            VuV2PulseChoice(label: 'href', correct: true, reaction: 'Correct.'),
            VuV2PulseChoice(label: 'src', correct: false, reaction: 'src is for images/scripts.'),
            VuV2PulseChoice(label: 'alt', correct: false, reaction: 'alt is for images.'),
          ],
        ),
        _Ex(
          body: 'Best link text?',
          prompt: 'Choose',
          choices: <VuV2PulseChoice>[
            VuV2PulseChoice(label: 'HTML Images tutorial', correct: true, reaction: 'Clear destination.'),
            VuV2PulseChoice(label: 'Click here', correct: false, reaction: 'Too vague.'),
            VuV2PulseChoice(label: 'Link', correct: false, reaction: 'Not descriptive.'),
          ],
        ),
      ],
    );
  }

  static _Page _headings(VuV2CsTryItSpec spec) {
    return _Page(
      whatIs:
          'HTML headings are defined with `<h1>` to `<h6>`.\n\n'
          '`<h1>` is the most important heading. `<h6>` is the least important.',
      whenToUse: 'Use headings to structure your page like an outline.',
      exampleCode: '<h1>Heading 1</h1>\n<h2>Heading 2</h2>\n<h3>Heading 3</h3>',
      result: 'Heading 1\nHeading 2\nHeading 3',
      exampleExplained:
          '**Example Explained**\n\n'
          '• Search engines use headings to index content.\n'
          '• Users skim headings to find information.\n'
          '• Prefer one `<h1>` per page for the main title.',
      syntaxBody:
          '**HTML Heading Syntax**\n\n'
          '```\n<h1>Main title</h1>\n<h2>Section</h2>\n```\n\n'
          '${_bullets(<String>[
            'h1 — main page title',
            'h2 — section title',
            'h3–h6 — deeper subsections',
          ])}',
      moreExample: '<h1>HTML Headings</h1>\n<h2>Why headings matter</h2>',
      moreTalk: 'Don\'t choose a heading only because of its default size — use the right level.',
      exercises: const <_Ex>[
        _Ex(
          body: 'Which tag is the top-level heading?',
          prompt: 'Choose',
          choices: <VuV2PulseChoice>[
            VuV2PulseChoice(label: '<h1>', correct: true, reaction: 'Yes.'),
            VuV2PulseChoice(label: '<h6>', correct: false, reaction: 'h6 is the lowest level.'),
            VuV2PulseChoice(label: '<p>', correct: false, reaction: 'p is a paragraph.'),
          ],
        ),
        _Ex(
          body: 'Headings should mainly provide…',
          prompt: 'Choose',
          choices: <VuV2PulseChoice>[
            VuV2PulseChoice(label: 'Document structure', correct: true, reaction: 'Exactly.'),
            VuV2PulseChoice(label: 'Only decoration', correct: false, reaction: 'Use CSS for decoration.'),
            VuV2PulseChoice(label: 'Image compression', correct: false, reaction: 'Unrelated.'),
          ],
        ),
      ],
    );
  }

  static _Page _lists(VuV2CsTryItSpec spec) {
    return _Page(
      whatIs:
          'HTML lists can be unordered (`<ul>`) or ordered (`<ol>`).\n\n'
          'List items are defined with `<li>`.',
      whenToUse:
          'Use lists for steps, menus, features — anything that is a collection of items.',
      exampleCode: '<ul>\n  <li>Coffee</li>\n  <li>Tea</li>\n  <li>Milk</li>\n</ul>',
      result: '• Coffee\n• Tea\n• Milk',
      exampleExplained:
          '**Example Explained**\n\n'
          '• `<ul>` = unordered list (bullets).\n'
          '• `<ol>` = ordered list (numbers).\n'
          '• Each `<li>` is one list item.',
      syntaxBody:
          '**HTML List Syntax**\n\n'
          '```\n<ul>\n  <li>Item</li>\n</ul>\n```\n\n'
          '${_bullets(<String>[
            'Wrap items in ul or ol',
            'Put each item in li',
            'Use ol when order matters',
          ])}',
      moreExample: '<ol>\n  <li>HTML</li>\n  <li>CSS</li>\n  <li>JavaScript</li>\n</ol>',
      moreTalk: 'Ordered lists are perfect for step-by-step tutorials.',
      exercises: const <_Ex>[
        _Ex(
          body: 'Which tag creates a list item?',
          prompt: 'Choose',
          choices: <VuV2PulseChoice>[
            VuV2PulseChoice(label: '<li>', correct: true, reaction: 'Correct.'),
            VuV2PulseChoice(label: '<ul>', correct: false, reaction: 'ul is the wrapper.'),
            VuV2PulseChoice(label: '<p>', correct: false, reaction: 'p is a paragraph.'),
          ],
        ),
        _Ex(
          body: 'Use <ol> when…',
          prompt: 'Choose',
          choices: <VuV2PulseChoice>[
            VuV2PulseChoice(label: 'Order matters', correct: true, reaction: 'Yes.'),
            VuV2PulseChoice(label: 'Never', correct: false, reaction: 'ol is useful for steps.'),
            VuV2PulseChoice(label: 'Only for images', correct: false, reaction: 'Lists hold any items.'),
          ],
        ),
      ],
    );
  }
}

class _Page {
  const _Page({
    required this.whatIs,
    required this.whenToUse,
    required this.exampleCode,
    required this.result,
    required this.exampleExplained,
    required this.syntaxBody,
    required this.moreExample,
    required this.moreTalk,
    required this.exercises,
  });

  final String whatIs;
  final String whenToUse;
  final String exampleCode;
  final String result;
  final String exampleExplained;
  final String syntaxBody;
  final String moreExample;
  final String moreTalk;
  final List<_Ex> exercises;
}

class _Ex {
  const _Ex({
    required this.body,
    required this.prompt,
    required this.choices,
  });

  final String body;
  final String prompt;
  final List<VuV2PulseChoice> choices;
}
