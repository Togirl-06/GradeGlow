import '../../models/cs_curriculum.dart';
import '../../models/cs_w3s_topic.dart';

/// W3Schools-style multiple-choice exercises per curriculum topic.
class CsCurriculumQuizBank {
  CsCurriculumQuizBank._();

  static const int questionsPerTopic = 5;

  static List<CsW3sQuiz> forTopic({
    required CsCurriculumTopic topic,
    required String langLabel,
    required String codeLang,
  }) {
    final List<CsW3sQuiz> base;
    if (topic.languageId == 'html') {
      base = _htmlQuizzes[_htmlKey(topic.title)] ?? _htmlQuizzes['generic']!;
    } else if (topic.languageId == 'css') {
      base = _cssQuizzes[_cssKey(topic.title)] ?? _cssQuizzes['generic']!;
    } else if (topic.languageId == 'algorithms') {
      base = _algorithmQuizzes(topic.title);
    } else {
      base = _generic(topic.title, langLabel, codeLang);
    }
    return _ensureFive(base, topic, langLabel, codeLang);
  }

  static List<CsW3sQuiz> _ensureFive(
    List<CsW3sQuiz> base,
    CsCurriculumTopic topic,
    String langLabel,
    String codeLang,
  ) {
    final List<CsW3sQuiz> out = <CsW3sQuiz>[];
    final Set<String> seen = <String>{};

    void add(CsW3sQuiz q) {
      if (out.length >= questionsPerTopic) return;
      if (seen.add(q.question)) out.add(q);
    }

    for (final CsW3sQuiz q in base) {
      add(q);
    }
    for (final CsW3sQuiz q in _bonusQuestions(topic.title, langLabel, codeLang)) {
      add(q);
    }
    for (final CsW3sQuiz q in _generic(topic.title, langLabel, codeLang)) {
      add(q);
    }

    int n = 1;
    while (out.length < questionsPerTopic) {
      add(
        _q(
          code: _sampleCode(codeLang, topic.title),
          question: 'Review ($n): What did you learn about ${topic.title}?',
          options: <String>[
            'Nothing related to $langLabel',
            'Core ideas from the ${topic.title} lecture',
            'Only optional advanced theory',
            'Unrelated syntax',
          ],
          correct: 1,
          explanation: 'Review the lecture on ${topic.title} to reinforce this concept.',
        ),
      );
      n++;
    }

    return out;
  }

  static List<CsW3sQuiz> _bonusQuestions(String title, String langLabel, String codeLang) {
    final String sample = _sampleCode(codeLang, title);
    return <CsW3sQuiz>[
      _q(
        code: sample,
        question: 'Which best describes how $title fits into $langLabel?',
        options: <String>[
          'It is not part of $langLabel',
          'It is a building block covered in your lecture',
          'It replaces the entire language',
          'It only appears in comments',
        ],
        correct: 1,
        explanation: '$title is part of the $langLabel curriculum you studied.',
      ),
      _q(
        code: sample,
        question: 'After the $title lecture, you should be able to:',
        options: <String>[
          'Ignore syntax rules',
          'Apply the concept in small examples',
          'Skip to unrelated topics',
          'Only memorize definitions without code',
        ],
        correct: 1,
        explanation: 'Practice means applying $title in code like the lecture examples.',
      ),
    ];
  }

  static String _htmlKey(String title) {
    final String t = title.toLowerCase();
    if (t.contains('document structure')) return 'document_structure';
    if (t.contains('introduction')) return 'introduction';
    if (t.contains('heading')) return 'headings';
    if (t.contains('paragraph')) return 'paragraphs';
    if (t.contains('link')) return 'links';
    if (t.contains('image')) return 'images';
    if (t.contains('list')) return 'lists';
    if (t.contains('table')) return 'tables';
    if (t.contains('form')) return 'forms';
    if (t.contains('button')) return 'buttons';
    if (t.contains('semantic')) return 'semantic';
    return 'generic';
  }

  static String _cssKey(String title) {
    final String t = title.toLowerCase();
    if (t.contains('selector')) return 'selectors';
    if (t.contains('flexbox')) return 'flexbox';
    if (t.contains('box model')) return 'box_model';
    if (t.contains('color')) return 'colors';
    return 'generic';
  }

  static CsW3sQuiz _q({
    required String code,
    required String question,
    required List<String> options,
    required int correct,
    required String explanation,
  }) =>
      CsW3sQuiz(
        code: code,
        question: question,
        options: options,
        correctIndex: correct,
        explanation: explanation,
      );

  static final Map<String, List<CsW3sQuiz>> _htmlQuizzes = <String, List<CsW3sQuiz>>{
    'introduction': <CsW3sQuiz>[
      _q(
        code: '<!DOCTYPE html>\n<html>\n<body>\n  <p>Hello</p>\n</body>\n</html>',
        question: 'What is the correct declaration for an HTML5 document?',
        options: <String>['<html5>', '<!DOCTYPE html>', '<!HTML5>', '<doctype html5>'],
        correct: 1,
        explanation: 'HTML5 documents start with <!DOCTYPE html> on the first line.',
      ),
      _q(
        code: '<html>\n  <head>\n    <title>Page</title>\n  </head>\n  <body>\n  </body>\n</html>',
        question: 'Where should the page title appear in the browser tab?',
        options: <String>['Inside <body>', 'Inside <title> in <head>', 'Inside <h1>', 'Inside <meta>'],
        correct: 1,
        explanation: 'The <title> element in <head> sets the browser tab title.',
      ),
      _q(
        code: '<body>\n  <h1>Welcome</h1>\n  <p>Intro text</p>\n</body>',
        question: 'Which element is used for the largest heading?',
        options: <String>['<head>', '<header>', '<h1>', '<title>'],
        correct: 2,
        explanation: '<h1> defines the main heading; heading levels go from h1 to h6.',
      ),
    ],
    'document_structure': <CsW3sQuiz>[
      _q(
        code: '<!DOCTYPE html>\n<html>\n<head></head>\n<body></body>\n</html>',
        question: 'Which element contains ALL visible page content?',
        options: <String>['<head>', '<html>', '<body>', '<!DOCTYPE>'],
        correct: 2,
        explanation: 'Everything users see in the browser window goes inside <body>.',
      ),
      _q(
        code: '<head>\n  <meta charset="UTF-8">\n  <title>My Page</title>\n</head>',
        question: 'What is the purpose of <meta charset="UTF-8">?',
        options: <String>[
          'Sets page background color',
          'Defines character encoding',
          'Creates a navigation bar',
          'Links a stylesheet',
        ],
        correct: 1,
        explanation: 'charset tells the browser how to interpret text characters (UTF-8 supports most languages).',
      ),
      _q(
        code: '<!DOCTYPE html>\n<html lang="en">\n  ...\n</html>',
        question: 'Why add lang="en" on the <html> tag?',
        options: <String>[
          'Makes text bold',
          'Helps screen readers and search engines',
          'Loads JavaScript',
          'Required for CSS to work',
        ],
        correct: 1,
        explanation: 'The lang attribute improves accessibility and SEO by declaring the page language.',
      ),
    ],
    'headings': <CsW3sQuiz>[
      _q(
        code: '<h1>Main</h1>\n<h2>Section</h2>\n<h3>Subsection</h3>',
        question: 'Which heading level should be used only once per page for the main topic?',
        options: <String>['<h3>', '<h2>', '<h1>', 'Any heading'],
        correct: 2,
        explanation: 'Use one <h1> for the primary page topic, then h2, h3, etc. for subsections.',
      ),
      _q(
        code: '<h1>Title</h1>\n<h3>Skipped level</h3>',
        question: 'What is wrong with jumping from h1 to h3?',
        options: <String>[
          'Nothing — it is valid',
          'You should not skip heading levels',
          'h3 must be inside h1',
          'h3 is deprecated',
        ],
        correct: 1,
        explanation: 'Skipping levels (h1 → h3) breaks logical document outline for accessibility.',
      ),
      _q(
        code: '<p>Text with <h2>inside paragraph</h2></p>',
        question: 'Can a heading be nested inside a <p> tag?',
        options: <String>['Yes, always', 'No — block elements like headings cannot go inside <p>', 'Only h1', 'Only with CSS'],
        correct: 1,
        explanation: '<p> can only contain phrasing content; headings are block-level and must sit outside paragraphs.',
      ),
    ],
    'paragraphs': <CsW3sQuiz>[
      _q(
        code: '<p>First block.</p>\n<p>Second block.</p>',
        question: 'What does the <p> element create?',
        options: <String>['Inline text', 'A paragraph block', 'A bullet list', 'A table row'],
        correct: 1,
        explanation: '<p> defines a block of text — a paragraph separated from other content.',
      ),
      _q(
        code: '<p>Line one<br>Line two</p>',
        question: 'Which tag forces a line break inside a paragraph?',
        options: <String>['<lb>', '<break>', '<br>', '<newline>'],
        correct: 2,
        explanation: '<br> inserts a line break without starting a new paragraph.',
      ),
      _q(
        code: '<p></p>',
        question: 'Is an empty <p></p> useful in real pages?',
        options: <String>[
          'Yes — best practice for spacing',
          'No — use CSS margin instead of empty paragraphs',
          'Required for HTML5 validation',
          'Only in tables',
        ],
        correct: 1,
        explanation: 'Use CSS for spacing; empty paragraphs add noise for screen readers.',
      ),
    ],
    'links': <CsW3sQuiz>[
      _q(
        code: '<a href="https://example.com">Visit</a>',
        question: 'Which attribute specifies the link destination?',
        options: <String>['src', 'link', 'href', 'url'],
        correct: 2,
        explanation: 'The href attribute holds the URL the anchor points to.',
      ),
      _q(
        code: '<a href="page.html" target="_blank">Open</a>',
        question: 'What does target="_blank" do?',
        options: <String>[
          'Opens link in same tab',
          'Opens link in a new tab/window',
          'Downloads the file',
          'Disables the link',
        ],
        correct: 1,
        explanation: 'target="_blank" opens the link in a new browsing context; add rel="noopener" for security.',
      ),
      _q(
        code: '<a href="#section">Jump</a>\n...\n<h2 id="section">Section</h2>',
        question: 'What type of link uses href="#section"?',
        options: <String>['External link', 'Email link', 'Same-page anchor link', 'Broken link'],
        correct: 2,
        explanation: 'Hash links scroll to an element with a matching id on the same page.',
      ),
    ],
    'images': <CsW3sQuiz>[
      _q(
        code: '<img src="photo.jpg" alt="Sunset">',
        question: 'Why is the alt attribute important?',
        options: <String>[
          'It sets image width',
          'It describes the image for accessibility',
          'It links to another page',
          'It is optional and never needed',
        ],
        correct: 1,
        explanation: 'alt provides text when the image cannot be seen — required for accessibility.',
      ),
      _q(
        code: '<img src="logo.png">',
        question: 'What is missing for valid, accessible markup?',
        options: <String>['href', 'alt text', 'type="image"', '<img> cannot be used alone'],
        correct: 1,
        explanation: 'Always include meaningful alt text (or alt="" for decorative images).',
      ),
      _q(
        code: '<figure>\n  <img src="chart.png" alt="Sales chart">\n  <figcaption>Q1 results</figcaption>\n</figure>',
        question: 'What does <figcaption> provide?',
        options: <String>['Image source URL', 'A caption for the figure', 'Image border', 'Alt text replacement'],
        correct: 1,
        explanation: '<figure> groups media; <figcaption> adds a visible caption below it.',
      ),
    ],
    'lists': <CsW3sQuiz>[
      _q(
        code: '<ul>\n  <li>HTML</li>\n  <li>CSS</li>\n</ul>',
        question: 'What type of list does <ul> create?',
        options: <String>['Numbered list', 'Bulleted unordered list', 'Definition list', 'Table'],
        correct: 1,
        explanation: '<ul> is an unordered list; each item uses <li>.',
      ),
      _q(
        code: '<ol>\n  <li>Step 1</li>\n  <li>Step 2</li>\n</ol>',
        question: 'When should you use <ol> instead of <ul>?',
        options: <String>[
          'For bullet points',
          'When item order matters (steps, rankings)',
          'For navigation only',
          'Never — they are identical',
        ],
        correct: 1,
        explanation: '<ol> numbers items automatically — use for sequences and ranked lists.',
      ),
      _q(
        code: '<ul>\n  <li>Parent\n    <ul>\n      <li>Child</li>\n    </ul>\n  </li>\n</ul>',
        question: 'Can lists be nested inside <li> elements?',
        options: <String>['No', 'Yes — nested lists are valid', 'Only <ol> inside <ul>', 'Only with CSS'],
        correct: 1,
        explanation: 'Place a nested <ul> or <ol> inside an <li> for sub-lists.',
      ),
    ],
    'tables': <CsW3sQuiz>[
      _q(
        code: '<table>\n  <tr>\n    <td>Cell</td>\n  </tr>\n</table>',
        question: 'What does <tr> represent?',
        options: <String>['A column', 'A table row', 'Table header', 'Table border'],
        correct: 1,
        explanation: '<tr> is a table row; <td> cells go inside rows.',
      ),
      _q(
        code: '<th>Name</th>\n<td>Tom</td>',
        question: 'What is the difference between <th> and <td>?',
        options: <String>[
          'No difference',
          '<th> is a header cell; <td> is a data cell',
          '<th> is only for CSS',
          '<td> cannot be in <thead>',
        ],
        correct: 1,
        explanation: '<th> marks header cells (bold and centered by default); <td> holds data.',
      ),
      _q(
        code: '<thead>\n  <tr><th>Col</th></tr>\n</thead>\n<tbody>\n  <tr><td>1</td></tr>\n</tbody>',
        question: 'Why use <thead> and <tbody>?',
        options: <String>[
          'Required for all tables',
          'Semantic structure — separates headers from body rows',
          'Makes tables responsive automatically',
          'Replaces CSS',
        ],
        correct: 1,
        explanation: 'thead/tbody improve semantics and let browsers style header rows separately.',
      ),
    ],
    'forms': <CsW3sQuiz>[
      _q(
        code: '<form action="/save" method="post">',
        question: 'What does method="post" mean?',
        options: <String>[
          'Data is shown in the URL',
          'Data is sent in the request body',
          'Form cannot submit',
          'Only GET is valid',
        ],
        correct: 1,
        explanation: 'POST sends form data in the body — better for passwords and large data.',
      ),
      _q(
        code: '<input type="text" name="username">',
        question: 'What does the name attribute do?',
        options: <String>[
          'Shows a label',
          'Identifies the field when the form is submitted',
          'Sets placeholder text',
          'Validates email format',
        ],
        correct: 1,
        explanation: 'name becomes the key for this field in the submitted form data.',
      ),
      _q(
        code: '<button type="submit">Save</button>',
        question: 'Which button type submits the form?',
        options: <String>['type="button"', 'type="reset"', 'type="submit"', 'No type needed'],
        correct: 2,
        explanation: 'type="submit" sends the form; type="button" does nothing by default.',
      ),
    ],
    'buttons': <CsW3sQuiz>[
      _q(
        code: '<button type="button">Click</button>',
        question: 'What does type="button" do inside a form?',
        options: <String>[
          'Submits the form',
          'Does not submit — for JavaScript actions',
          'Resets all fields',
          'Is invalid HTML',
        ],
        correct: 1,
        explanation: 'Use type="button" for custom actions; type="submit" sends the form.',
      ),
      _q(
        code: '<input type="submit" value="Go">',
        question: 'How is <input type="submit"> different from <button type="submit">?',
        options: <String>[
          'input cannot submit',
          'button can contain HTML content; input only shows value text',
          'They never work in forms',
          'input is deprecated',
        ],
        correct: 1,
        explanation: '<button> is more flexible — you can put icons and HTML inside it.',
      ),
      _q(
        code: '<button aria-label="Close">×</button>',
        question: 'When is aria-label needed on a button?',
        options: <String>[
          'Never',
          'When the visible text does not describe the action (e.g. icon-only)',
          'Only on submit buttons',
          'Only in forms',
        ],
        correct: 1,
        explanation: 'aria-label gives screen readers a clear name when text alone is unclear.',
      ),
    ],
    'semantic': <CsW3sQuiz>[
      _q(
        code: '<header>...</header>\n<main>...</main>\n<footer>...</footer>',
        question: 'Why use semantic elements instead of only <div>?',
        options: <String>[
          'They are shorter to type',
          'They describe meaning — better for accessibility and SEO',
          'They replace CSS',
          'Browsers cannot render <div>',
        ],
        correct: 1,
        explanation: 'Semantic tags tell browsers and assistive tech what each region is for.',
      ),
      _q(
        code: '<nav>\n  <a href="/">Home</a>\n</nav>',
        question: 'What belongs inside <nav>?',
        options: <String>['Any paragraph', 'Major navigation links', 'Only images', 'Footer copyright'],
        correct: 1,
        explanation: '<nav> wraps blocks of navigation links — menus, toc, etc.',
      ),
      _q(
        code: '<article>\n  <h2>News</h2>\n  <p>...</p>\n</article>',
        question: 'When should you use <article>?',
        options: <String>[
          'For every div',
          'For self-contained content (blog post, card, news item)',
          'Only in footers',
          'Only with tables',
        ],
        correct: 1,
        explanation: '<article> is for content that could stand alone (syndication, sharing).',
      ),
    ],
    'generic': <CsW3sQuiz>[
      _q(
        code: '<!-- Your HTML here -->',
        question: 'What is the correct syntax for an HTML comment?',
        options: <String>['// comment', '/* comment */', '<!-- comment -->', '# comment'],
        correct: 2,
        explanation: 'HTML comments use <!-- ... --> and are ignored by the browser.',
      ),
      _q(
        code: '<!DOCTYPE html>',
        question: 'Where should <!DOCTYPE html> appear?',
        options: <String>['Inside <body>', 'As the very first line', 'Inside <head>', 'At the end of the file'],
        correct: 1,
        explanation: 'The doctype must be the first line so the browser uses standards mode.',
      ),
      _q(
        code: '<html>\n<head></head>\n<body></body>\n</html>',
        question: 'Which two sections are direct children of <html>?',
        options: <String>['<div> and <span>', '<head> and <body>', '<title> and <p>', '<meta> and <h1>'],
        correct: 1,
        explanation: 'A valid document has <head> (metadata) and <body> (visible content) inside <html>.',
      ),
    ],
  };

  static final Map<String, List<CsW3sQuiz>> _cssQuizzes = <String, List<CsW3sQuiz>>{
    'selectors': <CsW3sQuiz>[
      _q(
        code: 'p { color: blue; }',
        question: 'What does `p` select in this rule?',
        options: <String>['Elements with class "p"', 'All <p> elements', 'The paragraph id', 'Parent elements'],
        correct: 1,
        explanation: 'A type selector `p` matches every paragraph element.',
      ),
      _q(
        code: '.highlight { background: yellow; }',
        question: 'What does the dot (.) mean in `.highlight`?',
        options: <String>['ID selector', 'Class selector', 'Element selector', 'Pseudo-class'],
        correct: 1,
        explanation: '.classname targets elements with class="highlight".',
      ),
      _q(
        code: '#main { width: 100%; }',
        question: 'How do you select an element with id="main"?',
        options: <String>['.main', '#main', 'main', '*main'],
        correct: 1,
        explanation: '#id selects one unique element with that id.',
      ),
    ],
    'flexbox': <CsW3sQuiz>[
      _q(
        code: '.row { display: flex; }',
        question: 'What does display: flex do?',
        options: <String>[
          'Creates a grid',
          'Turns the container into a flex layout for its children',
          'Hides children',
          'Makes text bold',
        ],
        correct: 1,
        explanation: 'flex arranges direct children in a row (by default) with flexible sizing.',
      ),
      _q(
        code: 'justify-content: center;',
        question: 'justify-content aligns items along which axis (default row)?',
        options: <String>['Vertical', 'Horizontal (main axis)', 'Z-axis', 'Diagonal'],
        correct: 1,
        explanation: 'justify-content controls alignment along the main axis (horizontal for row).',
      ),
      _q(
        code: 'align-items: center;',
        question: 'align-items centers children on which axis (default row)?',
        options: <String>['Main axis', 'Cross axis (vertical)', 'Both axes', 'Neither'],
        correct: 1,
        explanation: 'align-items aligns on the cross axis — vertical when flex-direction is row.',
      ),
    ],
    'box_model': <CsW3sQuiz>[
      _q(
        code: 'padding: 16px;\nmargin: 8px;\nborder: 1px solid #ccc;',
        question: 'Which is INSIDE the border in the box model?',
        options: <String>['margin', 'padding', 'outline', 'gap'],
        correct: 1,
        explanation: 'From inside out: content → padding → border → margin.',
      ),
      _q(
        code: 'box-sizing: border-box;',
        question: 'What does border-box change?',
        options: <String>[
          'Width includes padding and border',
          'Removes borders',
          'Only affects margin',
          'Disables padding',
        ],
        correct: 0,
        explanation: 'border-box makes width/height include padding and border — easier layouts.',
      ),
      _q(
        code: 'margin: 0 auto;',
        question: 'How do you horizontally center a block with a set width?',
        options: <String>['text-align: center', 'margin: 0 auto', 'float: center', 'align: middle'],
        correct: 1,
        explanation: 'margin: 0 auto on a block with width centers it horizontally.',
      ),
    ],
    'colors': <CsW3sQuiz>[
      _q(
        code: 'color: #ff0000;',
        question: 'What color is #ff0000?',
        options: <String>['Blue', 'Green', 'Red', 'Black'],
        correct: 2,
        explanation: 'Hex #RRGGBB — ff0000 is full red, no green, no blue.',
      ),
      _q(
        code: 'background-color: rgb(0, 128, 0);',
        question: 'rgb(0, 128, 0) is closest to which color?',
        options: <String>['Red', 'Green', 'Blue', 'Gray'],
        correct: 1,
        explanation: 'rgb(red, green, blue) — 0,128,0 is a medium green.',
      ),
      _q(
        code: ':root { --brand: #04AA6D; }\n.btn { color: var(--brand); }',
        question: 'What are CSS custom properties (variables) declared with?',
        options: <String>['\$name', '--name', '@name', '#name'],
        correct: 1,
        explanation: 'Custom properties use --prefix and var() to read them.',
      ),
    ],
    'generic': <CsW3sQuiz>[
      _q(
        code: 'body { font-family: sans-serif; }',
        question: 'Which part of this rule is the selector?',
        options: <String>['body', 'font-family', 'sans-serif', 'the whole line'],
        correct: 0,
        explanation: 'The selector (body) comes before { }; properties go inside.',
      ),
      _q(
        code: 'color: navy;',
        question: 'What is `color` in a CSS declaration?',
        options: <String>['Selector', 'Property', 'Value', 'Comment'],
        correct: 1,
        explanation: 'Declarations are property: value pairs — color is the property.',
      ),
      _q(
        code: '/* comment */',
        question: 'How do you write a CSS comment?',
        options: <String>['// comment', '<!-- comment -->', '/* comment */', '# comment'],
        correct: 2,
        explanation: 'CSS comments use /* ... */ syntax.',
      ),
    ],
  };

  static List<CsW3sQuiz> _algorithmQuizzes(String title) {
    final String t = title.toLowerCase();
    if (t.contains('binary search')) {
      return <CsW3sQuiz>[
        _q(
          code: 'while (lo <= hi) {\n  int mid = lo + (hi - lo) / 2;\n}',
          question: 'Binary search requires the input array to be:',
          options: <String>['Unsorted', 'Sorted', 'Empty', 'All duplicates'],
          correct: 1,
          explanation: 'Binary search only works on sorted data — it eliminates half each step.',
        ),
        _q(
          code: 'mid = lo + (hi-lo)/2',
          question: 'Why use lo + (hi-lo)/2 instead of (lo+hi)/2?',
          options: <String>['It is faster', 'Avoids integer overflow', 'Required by HTML', 'No reason'],
          correct: 1,
          explanation: 'lo+hi can overflow; the safe formula avoids that in large arrays.',
        ),
        _q(
          code: 'O(log n)',
          question: 'What is the time complexity of binary search?',
          options: <String>['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
          correct: 1,
          explanation: 'Each step halves the search space → logarithmic time.',
        ),
      ];
    }
    return <CsW3sQuiz>[
      _q(
        code: '// $title\nfor (int i = 0; i < n; i++) { }',
        question: 'What is the time complexity of a single loop over n items?',
        options: <String>['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
        correct: 2,
        explanation: 'One pass through n elements is linear time O(n).',
      ),
      _q(
        code: 'if (n == 0) return;',
        question: 'Why check base cases in recursion?',
        options: <String>[
          'To speed up loops',
          'To stop the recursion and prevent infinite calls',
          'For HTML validation',
          'Not needed',
        ],
        correct: 1,
        explanation: 'Every recursive function needs a base case to terminate.',
      ),
      _q(
        code: 'int[] arr = new int[n];',
        question: 'Which structure gives O(1) access by index?',
        options: <String>['Linked list', 'Array', 'Stack only', 'Queue only'],
        correct: 1,
        explanation: 'Arrays allow constant-time random access by index.',
      ),
    ];
  }

  static List<CsW3sQuiz> _generic(String title, String langLabel, String codeLang) {
    final String sample = _sampleCode(codeLang, title);
    return <CsW3sQuiz>[
      _q(
        code: sample,
        question: 'What is the main purpose of $title in $langLabel?',
        options: <String>[
          'Unrelated to this lesson',
          'A core concept from your $title lecture',
          'Only used in CSS',
          'Deprecated syntax',
        ],
        correct: 1,
        explanation: '$title is a fundamental topic in $langLabel — review your lecture if unsure.',
      ),
      _q(
        code: sample,
        question: 'Which statement about $title is correct?',
        options: <String>[
          'It is not used in real projects',
          'It follows syntax rules taught in the $title lesson',
          'It only works in browsers',
          'It replaces all other features',
        ],
        correct: 1,
        explanation: 'Apply the syntax and rules from your lecture on $title.',
      ),
      _q(
        code: sample,
        question: 'When should you use $title?',
        options: <String>[
          'Never in production code',
          'When the situation matches what you learned in the lecture',
          'Only on mobile',
          'Only with Python',
        ],
        correct: 1,
        explanation: 'Use $title when the problem fits the use cases from your lesson.',
      ),
      _q(
        code: sample,
        question: 'Which is the best next step after studying $title?',
        options: <String>[
          'Skip practice entirely',
          'Try small examples like those in the lecture',
          'Memorize unrelated APIs',
          'Avoid writing any code',
        ],
        correct: 1,
        explanation: 'Hands-on examples solidify what you learned about $title.',
      ),
      _q(
        code: sample,
        question: 'True or false: $title syntax should match what was taught in the lecture.',
        options: <String>[
          'False — any syntax works',
          'True — follow the rules from your lesson',
          'False — only experts need rules',
          'True — but only on weekends',
        ],
        correct: 1,
        explanation: 'Correct syntax for $title is what you practiced in the lecture.',
      ),
    ];
  }

  static String _sampleCode(String codeLang, String title) {
    return switch (codeLang) {
      'html' => '<!-- $title -->\n<!DOCTYPE html>\n<html>\n<body>\n</body>\n</html>',
      'css' => '/* $title */\np { }',
      'javascript' || 'typescript' => '// $title\nconst x = 1;',
      'python3' => '# $title\ndef main():\n    pass',
      _ => '// $title',
    };
  }
}
