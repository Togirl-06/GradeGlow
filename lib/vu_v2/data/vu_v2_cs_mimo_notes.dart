import 'vu_v2_interactive_notes.dart';

/// Short Mimo-style notes: tip → explain → code → lots of tap questions.
abstract final class VuV2CsMimoNotes {
  static List<VuV2InteractiveBeat> build({
    required String topicTitle,
    required String courseTitle,
  }) {
    final _Pack p = _pack(topicTitle);
    final List<VuV2InteractiveBeat> beats = <VuV2InteractiveBeat>[
      VuV2InteractiveBeat(
        kind: VuV2BeatKind.teach,
        emoji: '💛',
        eyebrow: 'TIP',
        title: 'Quick note',
        body: p.lilNote,
        moreBody: p.lilNoteMore,
      ),
      VuV2InteractiveBeat(
        kind: VuV2BeatKind.teach,
        emoji: '👋',
        eyebrow: 'LEARN',
        title: 'What is $topicTitle?',
        body: p.intro,
        moreBody: p.explainMore,
      ),
      VuV2InteractiveBeat(
        kind: VuV2BeatKind.teach,
        emoji: '👀',
        eyebrow: 'CODE',
        title: 'Look at this',
        body: '${p.lookTalk}\n\n```\n${p.lookCode}\n```',
        moreBody: p.codeNote,
      ),
      VuV2InteractiveBeat(
        kind: VuV2BeatKind.pulse,
        emoji: '✍️',
        eyebrow: 'Q1',
        title: 'Fill the blank',
        body: '${p.fillTalk}\n\n```\n${p.fillCode}\n```',
        pulsePrompt: 'Tap the missing piece',
        pulseChoices: p.fillChoices,
      ),
      VuV2InteractiveBeat(
        kind: VuV2BeatKind.pulse,
        emoji: '🧠',
        eyebrow: 'Q2',
        title: 'Quick check',
        body: p.quizTalk +
            (p.quizCode == null ? '' : '\n\n```\n${p.quizCode}\n```'),
        pulsePrompt: p.quizPrompt,
        pulseChoices: p.quizChoices,
      ),
      VuV2InteractiveBeat(
        kind: VuV2BeatKind.pulse,
        emoji: '🧩',
        eyebrow: 'Q3',
        title: p.extra1Title,
        body: p.extra1Body,
        pulsePrompt: p.extra1Prompt,
        pulseChoices: p.extra1Choices,
      ),
      VuV2InteractiveBeat(
        kind: VuV2BeatKind.pulse,
        emoji: '🎯',
        eyebrow: 'Q4',
        title: p.extra2Title,
        body: p.extra2Body,
        pulsePrompt: p.extra2Prompt,
        pulseChoices: p.extra2Choices,
      ),
      VuV2InteractiveBeat(
        kind: VuV2BeatKind.pulse,
        emoji: '🐞',
        eyebrow: 'Q5',
        title: 'Spot the bug',
        body: 'Which one is correct for $topicTitle?',
        pulsePrompt: 'Pick the healthy snippet',
        pulseChoices: p.bugChoices,
      ),
      VuV2InteractiveBeat(
        kind: VuV2BeatKind.pulse,
        emoji: '⚡',
        eyebrow: 'Q6',
        title: p.extra3Title,
        body: p.extra3Body,
        pulsePrompt: p.extra3Prompt,
        pulseChoices: p.extra3Choices,
      ),
      VuV2InteractiveBeat(
        kind: VuV2BeatKind.teach,
        emoji: '🚀',
        eyebrow: 'DONE',
        title: 'Notes clear!',
        body:
            'Heart check complete ❤️ — you learned $topicTitle with tips + practice.\n\n'
            'Next: take the topic quiz to lock it in.',
        moreBody: p.outroTip,
      ),
    ];

    // Refresh eyebrow counts like 1/N.
    final int n = beats.length;
    return List<VuV2InteractiveBeat>.generate(n, (int i) {
      final VuV2InteractiveBeat b = beats[i];
      return VuV2InteractiveBeat(
        kind: b.kind,
        emoji: b.emoji,
        eyebrow: '${b.eyebrow} · ${i + 1}/$n',
        title: b.title,
        body: b.body,
        moreBody: b.moreBody,
        pulsePrompt: b.pulsePrompt,
        pulseChoices: b.pulseChoices,
      );
    });
  }

  static _Pack _pack(String topic) {
    final String t = topic.toLowerCase();
    if (_has(t, const <String>['paragraph', '<p>', 'p tag'])) {
      return _paragraphs;
    }
    if (_has(t, const <String>['image', 'img', 'picture', 'photo'])) {
      return _images;
    }
    if (_has(t, const <String>['link', 'anchor', 'href'])) {
      return _links;
    }
    if (_has(t, const <String>['heading', 'h1', 'h2', 'title tag'])) {
      return _headings;
    }
    if (_has(t, const <String>['list', 'ul', 'ol', 'li'])) {
      return _lists;
    }
    return _generic(topic);
  }

  static bool _has(String t, List<String> keys) {
    for (final String k in keys) {
      if (t.contains(k)) return true;
    }
    return false;
  }

  static const _Pack _paragraphs = _Pack(
    lilNote:
        '📝 Lil note: use a new `<p>` for each idea — not one giant paragraph for the whole page.',
    lilNoteMore:
        'Think of paragraphs like speech bubbles. One bubble = one thought. '
        'Screen readers and browsers both love that structure.',
    intro:
        'A paragraph is a block of text wrapped in `<p>…</p>`.\n\n'
        'The browser adds a little space above and below so sentences can breathe — '
        'that\'s why paragraphs feel like separate chunks on the page.',
    explainMore:
        '**Open** with `<p>`, write your text, **close** with `</p>`.\n'
        'Don\'t nest a `<p>` inside another `<p>`.\n'
        'Want a line break inside the same idea? That\'s `<br>` — different job.',
    lookTalk:
        'Opening tag → your words → closing tag. Say it out loud once.',
    lookCode: '<p>Hello, GradeGlow.</p>',
    codeNote:
        '`<p>` starts the paragraph. `Hello, GradeGlow.` is the content. '
        '`</p>` ends it. Miss the slash and the page tree gets messy.',
    fillTalk: 'What tag starts a paragraph?',
    fillCode: '<____>Hello, GradeGlow.</____>',
    fillChoices: <VuV2PulseChoice>[
      VuV2PulseChoice(label: 'p', correct: true, reaction: 'Yes — <p> means paragraph. ❤️'),
      VuV2PulseChoice(label: 'div', correct: false, reaction: 'div is a generic box. Paragraphs use p.'),
      VuV2PulseChoice(label: 'span', correct: false, reaction: 'span is inline — not a paragraph block.'),
      VuV2PulseChoice(label: 'br', correct: false, reaction: 'br is a line break, not a wrapper.'),
    ],
    quizTalk: 'Why close with </p>?',
    quizCode: '<p>Learn HTML</p>',
    quizPrompt: 'Best answer',
    quizChoices: <VuV2PulseChoice>[
      VuV2PulseChoice(
        label: 'It ends the paragraph so the HTML tree stays valid',
        correct: true,
        reaction: 'Exact. Open + close = clean tree.',
      ),
      VuV2PulseChoice(
        label: 'It changes the text color',
        correct: false,
        reaction: 'Color is CSS — not the closing tag.',
      ),
      VuV2PulseChoice(
        label: 'It adds an image',
        correct: false,
        reaction: 'Images use <img>, not </p>.',
      ),
      VuV2PulseChoice(
        label: 'It creates a hyperlink',
        correct: false,
        reaction: 'Links use <a href="...">.',
      ),
    ],
    extra1Title: 'One idea or many?',
    extra1Body:
        'You want two thoughts: “I love HTML.” and “I love CSS.”',
    extra1Prompt: 'Best markup?',
    extra1Choices: <VuV2PulseChoice>[
      VuV2PulseChoice(
        label: '<p>I love HTML.</p><p>I love CSS.</p>',
        correct: true,
        reaction: 'Two ideas → two paragraphs. Clean.',
      ),
      VuV2PulseChoice(
        label: '<p>I love HTML. I love CSS.</p>',
        correct: false,
        reaction: 'Works, but two ideas usually deserve two <p> tags.',
      ),
      VuV2PulseChoice(
        label: '<p>I love HTML.<p>I love CSS.</p>',
        correct: false,
        reaction: 'First <p> never closed properly.',
      ),
      VuV2PulseChoice(
        label: 'I love HTML.\nI love CSS.',
        correct: false,
        reaction: 'Plain text — no paragraph structure.',
      ),
    ],
    extra2Title: 'p vs br',
    extra2Body:
        '```\n<p>Line one<br>Line two</p>\n```\n'
        'What did `<br>` do here?',
    extra2Prompt: 'Choose',
    extra2Choices: <VuV2PulseChoice>[
      VuV2PulseChoice(
        label: 'Forced a line break inside the same paragraph',
        correct: true,
        reaction: 'Yep — still one <p>, just a visual break.',
      ),
      VuV2PulseChoice(
        label: 'Started a brand new paragraph',
        correct: false,
        reaction: 'New paragraphs need another <p>.',
      ),
      VuV2PulseChoice(
        label: 'Deleted line one',
        correct: false,
        reaction: 'br never deletes text.',
      ),
      VuV2PulseChoice(
        label: 'Made the text bold',
        correct: false,
        reaction: 'Bold is <strong> or CSS.',
      ),
    ],
    bugChoices: <VuV2PulseChoice>[
      VuV2PulseChoice(label: '<p>Hello</p>', correct: true, reaction: 'Valid paragraph. Ship it.'),
      VuV2PulseChoice(label: '<p>Hello<p>', correct: false, reaction: 'Opens twice — no proper close.'),
      VuV2PulseChoice(label: '</p>Hello<p>', correct: false, reaction: 'Closing before opening — broken.'),
      VuV2PulseChoice(
        label: '<paragraph>Hello</paragraph>',
        correct: false,
        reaction: 'Not a real HTML tag — use p.',
      ),
    ],
    extra3Title: 'Where do paragraphs live?',
    extra3Body: 'In a normal page, paragraphs belong in the visible document body.',
    extra3Prompt: 'True or false-ish — pick the best',
    extra3Choices: <VuV2PulseChoice>[
      VuV2PulseChoice(
        label: 'Inside <body> (the visible page content)',
        correct: true,
        reaction: 'Correct — body holds what people read.',
      ),
      VuV2PulseChoice(
        label: 'Only inside <head>',
        correct: false,
        reaction: 'head is metadata — not paragraph text.',
      ),
      VuV2PulseChoice(
        label: 'Only inside <img>',
        correct: false,
        reaction: 'img can\'t wrap paragraphs.',
      ),
      VuV2PulseChoice(
        label: 'Nowhere — browsers invent them',
        correct: false,
        reaction: 'You write the <p> tags (or a framework does).',
      ),
    ],
    outroTip:
        'Coach tip: if a block of text answers “what is this chunk about?”, wrap it in <p>.',
  );

  static const _Pack _images = _Pack(
    lilNote: '📝 Lil note: every meaningful image needs `alt` text — not just a file path.',
    lilNoteMore:
        'alt helps screen readers and shows up if the image fails to load. '
        'Decorative images can use alt="" on purpose.',
    intro:
        'Images use `<img>` with `src` (where the file lives) and `alt` (what it means).\n\n'
        'No closing tag — `<img ...>` is a void element.',
    explainMore:
        '`src` = fetch this file.\n'
        '`alt` = describe it for humans + accessibility.\n'
        'Optional: `width` / CSS for size. Prefer compressing big photos first.',
    lookTalk: 'Two attributes. Huge power.',
    lookCode: '<img src="cat.jpg" alt="A sleepy cat">',
    codeNote: 'If src is wrong, the picture breaks — but good alt still explains it.',
    fillTalk: 'Which attribute points to the file?',
    fillCode: '<img ____="cat.jpg" alt="A sleepy cat">',
    fillChoices: <VuV2PulseChoice>[
      VuV2PulseChoice(label: 'src', correct: true, reaction: 'src = source. Yes! ❤️'),
      VuV2PulseChoice(label: 'href', correct: false, reaction: 'href is for links.'),
      VuV2PulseChoice(label: 'alt', correct: false, reaction: 'alt describes — src loads.'),
      VuV2PulseChoice(label: 'link', correct: false, reaction: 'Not an img attribute.'),
    ],
    quizTalk: 'What is alt for?',
    quizCode: '<img src="cat.jpg" alt="A sleepy cat">',
    quizPrompt: 'Pick one',
    quizChoices: <VuV2PulseChoice>[
      VuV2PulseChoice(
        label: 'Accessibility + fallback when the image fails',
        correct: true,
        reaction: 'Perfect.',
      ),
      VuV2PulseChoice(label: 'Sets image width only', correct: false, reaction: 'That\'s width / CSS.'),
      VuV2PulseChoice(label: 'Opens a new tab', correct: false, reaction: 'That\'s target on links.'),
      VuV2PulseChoice(label: 'Compresses the file', correct: false, reaction: 'Compression is tooling, not alt.'),
    ],
    extra1Title: 'Best alt text?',
    extra1Body: 'Photo of an orange cat sleeping on a keyboard.',
    extra1Prompt: 'Pick the best alt',
    extra1Choices: <VuV2PulseChoice>[
      VuV2PulseChoice(
        label: 'Orange cat sleeping on a keyboard',
        correct: true,
        reaction: 'Specific and honest.',
      ),
      VuV2PulseChoice(label: 'image', correct: false, reaction: 'Useless — say what it shows.'),
      VuV2PulseChoice(label: 'photo', correct: false, reaction: 'Still too vague.'),
      VuV2PulseChoice(label: 'click here', correct: false, reaction: 'That\'s link text energy, not alt.'),
    ],
    extra2Title: 'Missing piece?',
    extra2Body: '```\n<img alt="Logo">\n```',
    extra2Prompt: 'What\'s wrong?',
    extra2Choices: <VuV2PulseChoice>[
      VuV2PulseChoice(label: 'No src — nothing to load', correct: true, reaction: 'Need a path/URL.'),
      VuV2PulseChoice(label: 'alt is too long', correct: false, reaction: 'alt is fine; src is missing.'),
      VuV2PulseChoice(label: 'Needs </img>', correct: false, reaction: 'img is void — no closer.'),
      VuV2PulseChoice(label: 'Must be inside <p>', correct: false, reaction: 'Not required.'),
    ],
    bugChoices: <VuV2PulseChoice>[
      VuV2PulseChoice(
        label: '<img src="cat.jpg" alt="Orange cat">',
        correct: true,
        reaction: 'Healthy tag.',
      ),
      VuV2PulseChoice(label: '<img src="cat.jpg">', correct: false, reaction: 'Missing alt.'),
      VuV2PulseChoice(label: '<img alt="Orange cat">', correct: false, reaction: 'Missing src.'),
      VuV2PulseChoice(label: '<img src="" alt="image">', correct: false, reaction: 'Empty src + weak alt.'),
    ],
    extra3Title: 'Content vs decoration',
    extra3Body: 'A logo that also acts as the site name in the header…',
    extra3Prompt: 'Should it have meaningful alt?',
    extra3Choices: <VuV2PulseChoice>[
      VuV2PulseChoice(
        label: 'Yes — it carries meaning',
        correct: true,
        reaction: 'Meaningful images need meaningful alt.',
      ),
      VuV2PulseChoice(
        label: 'Never — images never need alt',
        correct: false,
        reaction: 'Accessibility says otherwise.',
      ),
      VuV2PulseChoice(
        label: 'Only if the file is PNG',
        correct: false,
        reaction: 'Format doesn\'t decide alt.',
      ),
      VuV2PulseChoice(
        label: 'Only on mobile',
        correct: false,
        reaction: 'Alt matters everywhere.',
      ),
    ],
    outroTip: 'Coach tip: write alt like you\'re describing the pic to a friend on the phone.',
  );

  static const _Pack _links = _Pack(
    lilNote: '📝 Lil note: link text should preview the destination — never mystery “click here”.',
    lilNoteMore: 'If you read only the link text out loud, you should still know where it goes.',
    intro:
        'Links use `<a href="...">label</a>`.\n\n'
        '`href` is the destination. The words between the tags are what people tap.',
    explainMore:
        'Relative href (`about.html`) stays on your site.\n'
        'Absolute href (`https://…`) can leave your site.\n'
        '`target="_blank"` opens a new tab — pair with `rel="noopener"`.',
    lookTalk: 'Destination + honest label.',
    lookCode: '<a href="next.html">Next lesson</a>',
    codeNote: 'href="next.html" = go there. “Next lesson” = human-readable purpose.',
    fillTalk: 'Which attribute sets the destination?',
    fillCode: '<a ____="next.html">Next lesson</a>',
    fillChoices: <VuV2PulseChoice>[
      VuV2PulseChoice(label: 'href', correct: true, reaction: 'href locked in. ❤️'),
      VuV2PulseChoice(label: 'src', correct: false, reaction: 'src is for images/scripts.'),
      VuV2PulseChoice(label: 'link', correct: false, reaction: 'Not the attribute name.'),
      VuV2PulseChoice(label: 'url', correct: false, reaction: 'Close — real name is href.'),
    ],
    quizTalk: 'Best link text?',
    quizPrompt: 'Choose',
    quizChoices: <VuV2PulseChoice>[
      VuV2PulseChoice(label: 'Next lesson', correct: true, reaction: 'Honest and clear.'),
      VuV2PulseChoice(label: 'Click here', correct: false, reaction: 'Mystery meat.'),
      VuV2PulseChoice(label: 'Link', correct: false, reaction: 'Too vague.'),
      VuV2PulseChoice(label: 'asdf', correct: false, reaction: 'Nope.'),
    ],
    extra1Title: 'Relative path',
    extra1Body: 'You\'re on `index.html` in the same folder as `images.html`.',
    extra1Prompt: 'Best href to Images?',
    extra1Choices: <VuV2PulseChoice>[
      VuV2PulseChoice(label: 'images.html', correct: true, reaction: 'Same folder — simple relative path.'),
      VuV2PulseChoice(label: 'href', correct: false, reaction: 'That\'s the attribute name, not the path.'),
      VuV2PulseChoice(label: '#', correct: false, reaction: 'Goes nowhere useful.'),
      VuV2PulseChoice(label: 'img', correct: false, reaction: 'Wrong idea.'),
    ],
    extra2Title: 'Missing href?',
    extra2Body: '```\n<a>About</a>\n```',
    extra2Prompt: 'Problem?',
    extra2Choices: <VuV2PulseChoice>[
      VuV2PulseChoice(label: 'No destination — add href', correct: true, reaction: 'Exactly.'),
      VuV2PulseChoice(label: 'Needs </link>', correct: false, reaction: 'Closer is </a>.'),
      VuV2PulseChoice(label: 'Must use src', correct: false, reaction: 'src ≠ links.'),
      VuV2PulseChoice(label: 'Invalid word About', correct: false, reaction: 'Label is fine.'),
    ],
    bugChoices: <VuV2PulseChoice>[
      VuV2PulseChoice(label: '<a href="about.html">About</a>', correct: true, reaction: 'Good link.'),
      VuV2PulseChoice(label: '<a href="#">Click here</a>', correct: false, reaction: 'Weak label + dead-ish href.'),
      VuV2PulseChoice(label: '<a>About</a>', correct: false, reaction: 'No href.'),
      VuV2PulseChoice(label: '<a href="">About</a>', correct: false, reaction: 'Empty href.'),
    ],
    extra3Title: 'New tab safety',
    extra3Body: 'Opening an external site in a new tab…',
    extra3Prompt: 'Good combo?',
    extra3Choices: <VuV2PulseChoice>[
      VuV2PulseChoice(
        label: 'target="_blank" rel="noopener"',
        correct: true,
        reaction: 'Safer new-tab pattern.',
      ),
      VuV2PulseChoice(
        label: 'target="_blank" only, always',
        correct: false,
        reaction: 'Add rel="noopener" too.',
      ),
      VuV2PulseChoice(
        label: 'Never use href',
        correct: false,
        reaction: 'You still need href.',
      ),
      VuV2PulseChoice(
        label: 'Use <img> instead',
        correct: false,
        reaction: 'Wrong tool.',
      ),
    ],
    outroTip: 'Coach tip: write link text so it still makes sense with the rest of the sentence hidden.',
  );

  static const _Pack _headings = _Pack(
    lilNote: '📝 Lil note: one main `<h1>` per page — then nest h2/h3 like an outline.',
    lilNoteMore: 'Headings are structure, not just big text. CSS can style them; meaning stays in the tag.',
    intro:
        'Headings `<h1>`…`<h6>` title sections.\n\n'
        '`h1` is the top title. `h2` is a subsection under it. Don\'t skip levels wildly.',
    explainMore:
        'Think outline:\n'
        'h1 Document title\n'
        '  h2 Section\n'
        '    h3 Subsection\n'
        'Screen readers use this map to jump around.',
    lookTalk: 'Bigger number ≠ automatically bigger text — level = importance.',
    lookCode: '<h1>Paragraphs</h1>\n<h2>Why they matter</h2>',
    codeNote: 'h1 introduces the page topic. h2 introduces a section inside it.',
    fillTalk: 'Main page title tag?',
    fillCode: '<____>Paragraphs</____>',
    fillChoices: <VuV2PulseChoice>[
      VuV2PulseChoice(label: 'h1', correct: true, reaction: 'h1 = top title. ❤️'),
      VuV2PulseChoice(label: 'p', correct: false, reaction: 'p is body text.'),
      VuV2PulseChoice(label: 'h7', correct: false, reaction: 'HTML stops at h6.'),
      VuV2PulseChoice(label: 'title', correct: false, reaction: 'title lives in <head>.'),
    ],
    quizTalk: 'h2 is for…',
    quizPrompt: 'Pick',
    quizChoices: <VuV2PulseChoice>[
      VuV2PulseChoice(
        label: 'A subsection under the main title',
        correct: true,
        reaction: 'Yes — hierarchy.',
      ),
      VuV2PulseChoice(label: 'Always bigger than h1', correct: false, reaction: 'No — h1 is top level.'),
      VuV2PulseChoice(label: 'Images only', correct: false, reaction: 'Headings title text sections.'),
      VuV2PulseChoice(label: 'Replacing <p>', correct: false, reaction: 'Different jobs.'),
    ],
    extra1Title: 'Outline check',
    extra1Body: 'Page about “Images”, section “Alt text”.',
    extra1Prompt: 'Sensible pair?',
    extra1Choices: <VuV2PulseChoice>[
      VuV2PulseChoice(
        label: '<h1>Images</h1> then <h2>Alt text</h2>',
        correct: true,
        reaction: 'Solid outline.',
      ),
      VuV2PulseChoice(
        label: '<h2>Images</h2> then <h1>Alt text</h1>',
        correct: false,
        reaction: 'Upside-down hierarchy.',
      ),
      VuV2PulseChoice(
        label: 'Only <p>Images</p>',
        correct: false,
        reaction: 'That\'s not a heading.',
      ),
      VuV2PulseChoice(
        label: '<h6> everywhere',
        correct: false,
        reaction: 'Levels should mean something.',
      ),
    ],
    extra2Title: 'Styling vs meaning',
    extra2Body: 'You want big text that is NOT a section title.',
    extra2Prompt: 'Better approach?',
    extra2Choices: <VuV2PulseChoice>[
      VuV2PulseChoice(
        label: 'Use CSS on a <p> or <span> — don\'t fake an h1',
        correct: true,
        reaction: 'Meaning stays honest.',
      ),
      VuV2PulseChoice(
        label: 'Always use h1 for big text',
        correct: false,
        reaction: 'Breaks the outline.',
      ),
      VuV2PulseChoice(
        label: 'Use <img> for text',
        correct: false,
        reaction: 'Bad for accessibility.',
      ),
      VuV2PulseChoice(
        label: 'Skip headings forever',
        correct: false,
        reaction: 'Pages need structure.',
      ),
    ],
    bugChoices: <VuV2PulseChoice>[
      VuV2PulseChoice(label: '<h1>Title</h1>', correct: true, reaction: 'Valid.'),
      VuV2PulseChoice(label: '<h1>Title<h1>', correct: false, reaction: 'Not closed properly.'),
      VuV2PulseChoice(label: '<heading>Title</heading>', correct: false, reaction: 'Not a real tag.'),
      VuV2PulseChoice(label: '<h1>Title</h2>', correct: false, reaction: 'Mismatched tags.'),
    ],
    extra3Title: 'How many h1?',
    extra3Body: 'For a simple lesson page…',
    extra3Prompt: 'Best practice?',
    extra3Choices: <VuV2PulseChoice>[
      VuV2PulseChoice(label: 'Usually one main h1', correct: true, reaction: 'Classic, clear structure.'),
      VuV2PulseChoice(label: 'Zero headings ever', correct: false, reaction: 'Harder to scan.'),
      VuV2PulseChoice(label: 'Twenty h1s', correct: false, reaction: 'Everything can\'t be top-level.'),
      VuV2PulseChoice(label: 'Only h6', correct: false, reaction: 'Wrong default.'),
    ],
    outroTip: 'Coach tip: write headings first like an essay outline, then fill paragraphs under them.',
  );

  static const _Pack _lists = _Pack(
    lilNote: '📝 Lil note: real lists need `<ul>`/`<ol>` + `<li>` — not dashes inside a `<p>`.',
    lilNoteMore: 'Lists tell browsers and screen readers “these items belong together.”',
    intro:
        'Unordered lists (`ul`) show bullets. Ordered lists (`ol`) show numbers.\n\n'
        'Each item is an `<li>`.',
    explainMore:
        'Use `ol` when order matters (steps).\n'
        'Use `ul` when it\'s just a group.\n'
        'Don\'t leave orphan `<li>` tags outside a list.',
    lookTalk: 'Wrapper + items.',
    lookCode: '<ul>\n  <li>HTML</li>\n  <li>CSS</li>\n</ul>',
    codeNote: 'ul wraps. Each li is one bullet.',
    fillTalk: 'Unordered list wrapper?',
    fillCode: '<____>\n  <li>HTML</li>\n</____>',
    fillChoices: <VuV2PulseChoice>[
      VuV2PulseChoice(label: 'ul', correct: true, reaction: 'ul = unordered list. ❤️'),
      VuV2PulseChoice(label: 'ol', correct: false, reaction: 'ol is numbered.'),
      VuV2PulseChoice(label: 'li', correct: false, reaction: 'li is the item.'),
      VuV2PulseChoice(label: 'list', correct: false, reaction: 'Not an HTML tag.'),
    ],
    quizTalk: 'Use ol when…',
    quizPrompt: 'Choose',
    quizChoices: <VuV2PulseChoice>[
      VuV2PulseChoice(label: 'Order matters (steps)', correct: true, reaction: 'Correct.'),
      VuV2PulseChoice(label: 'You want prettier bullets', correct: false, reaction: 'That\'s CSS.'),
      VuV2PulseChoice(label: 'Never', correct: false, reaction: 'ol is great for steps.'),
      VuV2PulseChoice(label: 'Only for images', correct: false, reaction: 'Lists hold any items.'),
    ],
    extra1Title: 'Item tag',
    extra1Body: '```\n<ul>\n  <____>Learn lists</____>\n</ul>\n```',
    extra1Prompt: 'Fill it',
    extra1Choices: <VuV2PulseChoice>[
      VuV2PulseChoice(label: 'li', correct: true, reaction: 'li = list item.'),
      VuV2PulseChoice(label: 'ul', correct: false, reaction: 'Already have the wrapper.'),
      VuV2PulseChoice(label: 'p', correct: false, reaction: 'Use li inside lists.'),
      VuV2PulseChoice(label: 'span', correct: false, reaction: 'Not the list item tag.'),
    ],
    extra2Title: 'Fake list?',
    extra2Body: '```\n<p>- milk\\n- eggs</p>\n```',
    extra2Prompt: 'Why is this weak?',
    extra2Choices: <VuV2PulseChoice>[
      VuV2PulseChoice(
        label: 'It looks like a list but isn\'t structured as one',
        correct: true,
        reaction: 'Use ul/ol + li instead.',
      ),
      VuV2PulseChoice(label: 'p cannot hold text', correct: false, reaction: 'p can hold text.'),
      VuV2PulseChoice(label: 'Dashes are illegal', correct: false, reaction: 'Dashes are fine — structure is the issue.'),
      VuV2PulseChoice(label: 'Needs an img', correct: false, reaction: 'Unrelated.'),
    ],
    bugChoices: <VuV2PulseChoice>[
      VuV2PulseChoice(label: '<ul><li>OK</li></ul>', correct: true, reaction: 'Valid list.'),
      VuV2PulseChoice(label: '<li>Orphan</li>', correct: false, reaction: 'li needs ul/ol parent.'),
      VuV2PulseChoice(label: '<p>- fake</p>', correct: false, reaction: 'Not a real list.'),
      VuV2PulseChoice(label: '<ul>OK</ul>', correct: false, reaction: 'Missing li items.'),
    ],
    extra3Title: 'Recipe steps',
    extra3Body: 'Boil water → add pasta → drain.',
    extra3Prompt: 'Best list type?',
    extra3Choices: <VuV2PulseChoice>[
      VuV2PulseChoice(label: 'ol — order matters', correct: true, reaction: 'Steps love numbers.'),
      VuV2PulseChoice(label: 'ul — order never matters', correct: false, reaction: 'Here order matters.'),
      VuV2PulseChoice(label: 'No list — only h1', correct: false, reaction: 'Headings aren\'t steps.'),
      VuV2PulseChoice(label: 'Only <br> lines', correct: false, reaction: 'Weak structure.'),
    ],
    outroTip: 'Coach tip: if you can number it or bullet it on paper, it probably wants a real HTML list.',
  );

  static _Pack _generic(String topic) {
    return _Pack(
      lilNote: '📝 Lil note: learn $topic in tiny loops — tip, code, question, repeat.',
      lilNoteMore: 'If you can explain one line out loud, you\'re ready for the next challenge.',
      intro:
          '$topic is a coding idea with inputs, behavior, and outputs.\n\n'
          'We\'ll peek at a snippet, then answer a bunch of quick taps.',
      explainMore:
          'Definition → tiny example → predict output → tap questions.\n'
          'Wrong answers cost a heart ❤️ — that\'s how you remember.',
      lookTalk: 'Here\'s the shape of $topic.',
      lookCode: '// $topic\n// input → process → output',
      codeNote: 'Read top → bottom. Ask: what exists before? what exists after?',
      fillTalk: 'What comes first when learning $topic?',
      fillCode: '____ → code → run',
      fillChoices: const <VuV2PulseChoice>[
        VuV2PulseChoice(label: 'tiny example', correct: true, reaction: 'Start small. Always. ❤️'),
        VuV2PulseChoice(label: 'optimize', correct: false, reaction: 'Optimize after it works.'),
        VuV2PulseChoice(label: 'delete tests', correct: false, reaction: 'Keep the feedback loop.'),
        VuV2PulseChoice(label: 'skip reading', correct: false, reaction: 'Read a little, then tap.'),
      ],
      quizTalk: 'Best proof you understand $topic?',
      quizPrompt: 'Pick',
      quizChoices: <VuV2PulseChoice>[
        VuV2PulseChoice(
          label: 'I can write a tiny example and explain each line',
          correct: true,
          reaction: 'That\'s the standard.',
        ),
        const VuV2PulseChoice(label: 'I recognize the title', correct: false, reaction: 'Recognition ≠ skill.'),
        const VuV2PulseChoice(label: 'I skipped the exercises', correct: false, reaction: 'Doing is the lesson.'),
        const VuV2PulseChoice(label: 'I memorized only the emoji', correct: false, reaction: 'Cute, but no.'),
      ],
      extra1Title: 'Before you Run',
      extra1Body: 'You just wrote a $topic snippet.',
      extra1Prompt: 'Smart next move?',
      extra1Choices: const <VuV2PulseChoice>[
        VuV2PulseChoice(
          label: 'Hand-trace a tiny example',
          correct: true,
          reaction: 'Predict, then Run.',
        ),
        VuV2PulseChoice(label: 'Delete all prints', correct: false, reaction: 'You need a scoreboard.'),
        VuV2PulseChoice(label: 'Ship without checking', correct: false, reaction: 'Nope.'),
        VuV2PulseChoice(label: 'Only change fonts', correct: false, reaction: 'Unrelated.'),
      ],
      extra2Title: 'Edge case',
      extra2Body: 'What should you test besides the happy path?',
      extra2Prompt: 'Pick',
      extra2Choices: const <VuV2PulseChoice>[
        VuV2PulseChoice(
          label: 'Empty / tiny input',
          correct: true,
          reaction: 'Edges find bugs fast.',
        ),
        VuV2PulseChoice(label: 'Nothing else', correct: false, reaction: 'Edges matter.'),
        VuV2PulseChoice(label: 'Only the emoji', correct: false, reaction: 'Focus.'),
        VuV2PulseChoice(label: 'Random CSS only', correct: false, reaction: 'Wrong layer.'),
      ],
      bugChoices: <VuV2PulseChoice>[
        VuV2PulseChoice(
          label: 'Trace a tiny $topic example, then Run',
          correct: true,
          reaction: 'Healthy habit.',
        ),
        const VuV2PulseChoice(
          label: 'Paste code you cannot explain',
          correct: false,
          reaction: 'That\'s the bug.',
        ),
        const VuV2PulseChoice(
          label: 'Never print output',
          correct: false,
          reaction: 'You need a scoreboard.',
        ),
        const VuV2PulseChoice(
          label: 'Ignore wrong answers',
          correct: false,
          reaction: 'Wrong answers teach — and cost hearts.',
        ),
      ],
      extra3Title: 'Heart rule',
      extra3Body: 'Wrong tap on a question…',
      extra3Prompt: 'What happens?',
      extra3Choices: const <VuV2PulseChoice>[
        VuV2PulseChoice(
          label: 'You lose a heart — then try again',
          correct: true,
          reaction: 'Mimo energy. Learn the miss.',
        ),
        VuV2PulseChoice(label: 'The app deletes your code', correct: false, reaction: 'Dramatic, but no.'),
        VuV2PulseChoice(label: 'Nothing ever happens', correct: false, reaction: 'Hearts keep you honest.'),
        VuV2PulseChoice(label: 'You skip the whole course', correct: false, reaction: 'Stay in the lesson.'),
      ],
      outroTip: 'Coach tip: teach $topic to a rubber duck in one minute — then you\'re quiz-ready.',
    );
  }
}

class _Pack {
  const _Pack({
    required this.lilNote,
    required this.lilNoteMore,
    required this.intro,
    required this.explainMore,
    required this.lookTalk,
    required this.lookCode,
    required this.codeNote,
    required this.fillTalk,
    required this.fillCode,
    required this.fillChoices,
    required this.quizTalk,
    this.quizCode,
    required this.quizPrompt,
    required this.quizChoices,
    required this.extra1Title,
    required this.extra1Body,
    required this.extra1Prompt,
    required this.extra1Choices,
    required this.extra2Title,
    required this.extra2Body,
    required this.extra2Prompt,
    required this.extra2Choices,
    required this.bugChoices,
    required this.extra3Title,
    required this.extra3Body,
    required this.extra3Prompt,
    required this.extra3Choices,
    required this.outroTip,
  });

  final String lilNote;
  final String lilNoteMore;
  final String intro;
  final String explainMore;
  final String lookTalk;
  final String lookCode;
  final String codeNote;
  final String fillTalk;
  final String fillCode;
  final List<VuV2PulseChoice> fillChoices;
  final String quizTalk;
  final String? quizCode;
  final String quizPrompt;
  final List<VuV2PulseChoice> quizChoices;
  final String extra1Title;
  final String extra1Body;
  final String extra1Prompt;
  final List<VuV2PulseChoice> extra1Choices;
  final String extra2Title;
  final String extra2Body;
  final String extra2Prompt;
  final List<VuV2PulseChoice> extra2Choices;
  final List<VuV2PulseChoice> bugChoices;
  final String extra3Title;
  final String extra3Body;
  final String extra3Prompt;
  final List<VuV2PulseChoice> extra3Choices;
  final String outroTip;
}
