/// Topic-aware, code-heavy CS notes — talks through real snippets, not fluff.
abstract final class VuV2CsNotesCode {
  static String definition(String topic, String course) {
    final _CsSnippet s = _pick(topic);
    return '**Working definition.** In **$course**, **$topic** is a coding move: '
        '${s.oneLiner}\n\n'
        '**What it includes.** ${s.includes}\n\n'
        '**What it is not.** ${s.isNot}\n\n'
        '**Meet the code (warm-up):**\n'
        '```\n${s.demo}\n```\n'
        '${s.demoTalk}\n\n'
        '**Exam-ready sentence.** “**$topic** takes ${s.io}; it fails when ${s.fails}.”';
  }

  static String howItWorks(String topic, String course) {
    final _CsSnippet s = _pick(topic);
    final StringBuffer buf = StringBuffer(
      '**How $topic runs — line by line.**\n\n'
      'Think of the computer as a tiny actor. Your job is to write the script.\n\n'
      '```\n${s.howCode}\n```\n\n',
    );
    for (int i = 0; i < s.howTalk.length; i++) {
      buf.writeln('${i + 1}. ${s.howTalk[i]}');
    }
    buf.writeln(
      '\n**Memory vibe check.** If you change ${s.tweak}, what should change on screen? '
      'If you cannot answer, re-read the snippet before coding more.',
    );
    return buf.toString();
  }

  static String howToApply(String topic, String course) {
    final _CsSnippet s = _pick(topic);
    return '**How to apply $topic while coding — a fun build path.**\n\n'
        '🎯 **Mission:** ${s.mission}\n\n'
        '```\n${s.applyCode}\n```\n\n'
        '**Walkthrough (do these in order):**\n'
        '1. ${s.applySteps[0]}\n'
        '2. ${s.applySteps[1]}\n'
        '3. ${s.applySteps[2]}\n'
        '4. ${s.applySteps[3]}\n'
        '5. ${s.applySteps[4]}\n\n'
        '💬 **Coach tip:** ${s.coachTip}\n\n'
        'Do not polish until the happy path works.';
  }

  static String workedExample(String topic, String course) {
    final _CsSnippet s = _pick(topic);
    return '**Worked example — coding $topic in $course.**\n\n'
        '**Prompt.** ${s.examplePrompt}\n\n'
        '**Solution:**\n'
        '```\n${s.exampleCode}\n```\n\n'
        '**Talking through the code:**\n'
        '${s.exampleTalk}\n\n'
        '**Trace.** ${s.trace}\n\n'
        '**Your remix.** ${s.remix}';
  }

  static String mistakes(String topic, String course) {
    final _CsSnippet s = _pick(topic);
    return '**Mistakes to avoid with $topic (bug museum).**\n\n'
        '**Buggy vibe:**\n'
        '```\n${s.bugCode}\n```\n'
        '😵 ${s.bugWhy}\n\n'
        '**Fixed vibe:**\n'
        '```\n${s.fixCode}\n```\n'
        '✅ ${s.fixWhy}\n\n'
        '**Other traps:**\n'
        '${s.otherTraps}\n\n'
        'Before you ship: explain each important line out loud in one breath.';
  }

  static _CsSnippet _pick(String topic) {
    final String t = topic.toLowerCase().trim();
    if (_hit(t, const <String>['image', 'img', 'picture', 'photo'])) {
      return _images;
    }
    if (_hit(t, const <String>['link', 'anchor', 'href', 'url'])) {
      return _links;
    }
    if (_hit(t, const <String>['list', 'ul', 'ol', 'li'])) {
      return _lists;
    }
    if (_hit(t, const <String>['table', 'tr', 'td', 'th'])) {
      return _tables;
    }
    if (_hit(t, const <String>['form', 'input', 'button', 'textarea'])) {
      return _forms;
    }
    if (_hit(t, const <String>['css', 'style', 'selector', 'flex', 'grid', 'color'])) {
      return _css;
    }
    if (_hit(t, const <String>['function', 'method', 'def ', 'parameter'])) {
      return _functions;
    }
    if (_hit(t, const <String>['loop', 'for ', 'while', 'iterate'])) {
      return _loops;
    }
    if (_hit(t, const <String>['array', 'list', 'index'])) {
      return _arrays;
    }
    if (_hit(t, const <String>['if', 'else', 'condition', 'boolean'])) {
      return _conditionals;
    }
    if (_hit(t, const <String>['variable', 'let ', 'const', 'var '])) {
      return _variables;
    }
    if (_hit(t, const <String>['class', 'object', 'oop'])) {
      return _classes;
    }
    if (_hit(t, const <String>['html', 'tag', 'element', 'heading', 'paragraph'])) {
      return _htmlBasics;
    }
    return _generic(topic);
  }

  static bool _hit(String t, List<String> keys) {
    for (final String k in keys) {
      if (t.contains(k)) return true;
    }
    return false;
  }

  static final _CsSnippet _images = _CsSnippet(
    oneLiner:
        'you show a picture on a page by pointing the browser at a file (or URL) and describing it for accessibility.',
    includes:
        'the `<img>` tag, `src` (where the file lives), `alt` (what it is for screen readers / broken loads), '
        'and optional size attributes.',
    isNot:
        'dropping a random image with no `alt`, using a huge raw photo with no resize, '
        'or confusing `<img>` (content) with a CSS background (decoration).',
    io: 'a path/URL + alt text → a rendered picture',
    fails: 'the path is wrong, `alt` is empty for meaningful images, or the file is huge',
    demo:
        '<img src="cat.jpg" alt="A sleepy orange cat">\n',
    demoTalk:
        '🎬 `src` = “get this file.” `alt` = “if the picture fails / for accessibility, say this.” '
        'Two attributes. Huge power.',
    howCode:
        '<!-- 1) Pick the file -->\n'
        '<img\n'
        '  src="hero.png"\n'
        '  alt="Campus library at sunset"\n'
        '  width="400"\n'
        '>\n',
    howTalk: <String>[
      '`src="hero.png"` — browser fetches that path relative to the page.',
      '`alt="..."` — humans + screen readers get meaning when the image cannot show.',
      '`width="400"` — suggests display width (still prefer CSS for layout later).',
      'Browser paints pixels once the file arrives — no closing tag needed for `<img>`.',
    ],
    tweak: '`src` to a missing file',
    mission: 'Put a real picture on a mini profile card and make it accessible.',
    applyCode:
        '<article class="card">\n'
        '  <img src="avatar.jpg" alt="Alex smiling" width="120">\n'
        '  <h2>Alex</h2>\n'
        '  <p>CS student · loves HTML Images</p>\n'
        '</article>\n',
    applySteps: <String>[
      'Write the `<img>` with a real `src` path you control.',
      'Add honest `alt` text (what the image shows — not “image1”).',
      'Wrap it in a small card so you see layout + image together.',
      'Break `src` on purpose once — confirm `alt` / broken-image behavior.',
      'Fix path, then tweak width or CSS — only after it loads.',
    ],
    coachTip:
        'Name files like `avatar.jpg`, not `IMG_9921.JPG` — future you will thank you.',
    examplePrompt:
        'Build a product teaser: logo image + short caption under it.',
    exampleCode:
        '<figure>\n'
        '  <img src="logo.png" alt="GradeGlow logo" width="160">\n'
        '  <figcaption>Learn by coding, not by scrolling.</figcaption>\n'
        '</figure>\n',
    exampleTalk:
        '• `<figure>` groups the picture with its caption.\n'
        '• `src="logo.png"` loads the asset.\n'
        '• `alt` describes the logo for accessibility.\n'
        '• `<figcaption>` is the visible human caption under the image.',
    trace:
        'Browser requests logo.png → if found, paints it → screen readers announce the alt → '
        'caption appears below. If logo.png 404s, you still have meaning via alt + caption.',
    remix:
        'Swap `logo.png` for a photo and rewrite `alt` + caption to match. Same pattern, new story.',
    bugCode:
        '<img src="cat.jpg">\n'
        '<img src="" alt="photo">\n',
    bugWhy:
        'First tag has no `alt` (bad for accessibility). Second has empty `src` (nothing to load).',
    fixCode:
        '<img src="cat.jpg" alt="Orange cat on a keyboard">\n',
    fixWhy:
        'Real path + meaningful alt. One clear job for the browser.',
    otherTraps:
        '1. Using `alt="image"` / `alt="picture"` — useless.\n'
        '2. Giant 5MB photos on a phone page — compress first.\n'
        '3. Putting important text only inside the image — also put it in HTML.\n'
        '4. Forgetting relative paths (`../images/x.png` vs `images/x.png`).',
  );

  static final _CsSnippet _links = _CsSnippet(
    oneLiner: 'you connect pages (or sites) with an anchor that has a destination.',
    includes: '`<a href="...">label</a>`, absolute vs relative URLs, and clear link text.',
    isNot: '“click here” with mystery destinations, or `href="#"` fake links that go nowhere.',
    io: 'a URL + label → a clickable jump',
    fails: 'href is blank, broken, or the label lies about where it goes',
    demo: '<a href="https://example.com">Visit Example</a>\n',
    demoTalk: '`href` = destination. The text between tags = what humans click.',
    howCode:
        '<a href="lessons/images.html">Next: Images</a>\n'
        '<a href="https://developer.mozilla.org" target="_blank" rel="noopener">MDN</a>\n',
    howTalk: <String>[
      'Relative `href` stays on your site.',
      'Absolute `https://...` leaves your site.',
      '`target="_blank"` opens a new tab — pair with `rel="noopener"` for safety.',
      'Link text should preview the destination (“Next: Images”), not “click here”.',
    ],
    tweak: 'the href path',
    mission: 'Link a lesson page to the next topic with honest label text.',
    applyCode:
        '<nav>\n'
        '  <a href="index.html">Home</a> ·\n'
        '  <a href="images.html">Images</a>\n'
        '</nav>\n',
    applySteps: <String>[
      'Choose destination file or URL.',
      'Write clear link text.',
      'Test the click (relative paths break often).',
      'Add a second link for contrast (internal vs external).',
      'Only then style with CSS.',
    ],
    coachTip: 'If the label could be read alone and still make sense, you wrote a good link.',
    examplePrompt: 'Make a tiny footer with Home + About links.',
    exampleCode:
        '<footer>\n'
        '  <a href="/">Home</a> |\n'
        '  <a href="/about.html">About</a>\n'
        '</footer>\n',
    exampleTalk:
        '• Two anchors, two destinations.\n'
        '• Labels match pages.\n'
        '• Separator `|` is plain text, not a fake button.',
    trace: 'Click Home → browser navigates to `/`. Click About → `/about.html`.',
    remix: 'Add a third link to your Images lesson.',
    bugCode: '<a href="#">Click here</a>\n',
    bugWhy: 'Mystery label + dead-ish destination.',
    fixCode: '<a href="images.html">Open the Images lesson</a>\n',
    fixWhy: 'Honest destination + readable purpose.',
    otherTraps:
        '1. Empty href.\n2. Linking images without alt on the img.\n3. Opening every link in a new tab.',
  );

  static final _CsSnippet _lists = _CsSnippet(
    oneLiner: 'you group related items as bullets or numbers the browser understands as a list.',
    includes: '`<ul>` / `<ol>` wrappers and `<li>` items.',
    isNot: 'fake lists made of `<br>` lines or paragraphs with dashes.',
    io: 'items → a structured list',
    fails: 'li tags sit outside ul/ol, or you nest wildly without meaning',
    demo: '<ul>\n  <li>HTML</li>\n  <li>CSS</li>\n</ul>\n',
    demoTalk: 'Wrapper = list type. Each `<li>` = one idea.',
    howCode: '<ol>\n  <li>Write markup</li>\n  <li>Add styles</li>\n  <li>Test</li>\n</ol>\n',
    howTalk: <String>[
      '`<ol>` numbers items automatically.',
      'Each `<li>` is one step.',
      'Screen readers announce “list, 3 items” — structure matters.',
      'Swap to `<ul>` when order is not the point.',
    ],
    tweak: 'ol to ul',
    mission: 'Turn a messy paragraph of tips into a real list.',
    applyCode:
        '<h3>Ship checklist</h3>\n'
        '<ul>\n'
        '  <li>Valid HTML</li>\n'
        '  <li>Alt text on images</li>\n'
        '  <li>Links that go somewhere</li>\n'
        '</ul>\n',
    applySteps: <String>[
      'Pick ul (unordered) or ol (ordered).',
      'Put each tip in its own li.',
      'Nest a sub-list only if you truly need a sub-group.',
      'Read it aloud — if it sounds like a list, markup is right.',
      'Style markers with CSS after structure works.',
    ],
    coachTip: 'Structure first, bullets-as-decoration later.',
    examplePrompt: 'Number three study steps for tonight.',
    exampleCode:
        '<ol>\n'
        '  <li>Read the Images notes</li>\n'
        '  <li>Code one <img></li>\n'
        '  <li>Quiz yourself</li>\n'
        '</ol>\n',
    exampleTalk: 'Order matters → use ol. Each step is one li.',
    trace: 'Browser shows 1, 2, 3 automatically — you never hard-code the numbers.',
    remix: 'Convert the same three steps to a ul and notice the meaning change.',
    bugCode: '<li>Orphan item</li>\n<p>- not a list</p>\n',
    bugWhy: 'li without ul/ol; fake dash list.',
    fixCode: '<ul>\n  <li>Real item</li>\n</ul>\n',
    fixWhy: 'Valid list tree.',
    otherTraps: '1. Giant nested lists.\n2. Putting block chaos inside every li.\n3. Using tables for lists.',
  );

  static final _CsSnippet _tables = _CsSnippet(
    oneLiner: 'you display rows and columns of related data.',
    includes: '`<table>`, `<tr>`, `<th>` / `<td>`, and a header row when it helps.',
    isNot: 'using tables for page layout (that is CSS’s job).',
    io: 'rows of cells → a grid of data',
    fails: 'mismatched column counts or missing headers for screen readers',
    demo:
        '<table>\n'
        '  <tr><th>Name</th><th>Score</th></tr>\n'
        '  <tr><td>Alex</td><td>92</td></tr>\n'
        '</table>\n',
    demoTalk: '`th` = header cell. `td` = data cell. `tr` = one row.',
    howCode:
        '<table>\n'
        '  <thead><tr><th>Topic</th><th>Done?</th></tr></thead>\n'
        '  <tbody><tr><td>Images</td><td>Yes</td></tr></tbody>\n'
        '</table>\n',
    howTalk: <String>[
      'Header row names the columns.',
      'Body rows hold one record each.',
      'Keep the same number of cells per row.',
      'Use tables for data — not for centering a logo.',
    ],
    tweak: 'a cell value',
    mission: 'Make a 2-column scoreboard for your study streak.',
    applyCode:
        '<table>\n'
        '  <tr><th>Day</th><th>Minutes</th></tr>\n'
        '  <tr><td>Mon</td><td>25</td></tr>\n'
        '  <tr><td>Tue</td><td>40</td></tr>\n'
        '</table>\n',
    applySteps: <String>[
      'Write header row with th.',
      'Add two data rows with td.',
      'Count columns — they must match.',
      'Read across one row: does it make a sentence?',
      'Style borders after structure is correct.',
    ],
    coachTip: 'If you cannot say what each column means, add th labels.',
    examplePrompt: 'Show three languages and their file extensions.',
    exampleCode:
        '<table>\n'
        '  <tr><th>Language</th><th>Ext</th></tr>\n'
        '  <tr><td>HTML</td><td>.html</td></tr>\n'
        '  <tr><td>CSS</td><td>.css</td></tr>\n'
        '</table>\n',
    exampleTalk: 'Headers first, then one language per row.',
    trace: 'Row 1 labels columns. Row 2 is HTML/.html. Row 3 is CSS/.css.',
    remix: 'Add a JavaScript row.',
    bugCode: '<table><tr><td>Only one cell</td><td>oops</td></tr><tr><td>mismatch</td></tr></table>\n',
    bugWhy: 'Column counts differ between rows.',
    fixCode:
        '<table>\n'
        '  <tr><th>A</th><th>B</th></tr>\n'
        '  <tr><td>1</td><td>2</td></tr>\n'
        '</table>\n',
    fixWhy: 'Every row has 2 cells.',
    otherTraps: '1. Layout tables.\n2. No headers.\n3. Merging cells before you need to.',
  );

  static final _CsSnippet _forms = _CsSnippet(
    oneLiner: 'you collect user input with fields and a submit action.',
    includes: '`<form>`, `<input>`, labels, and a button.',
    isNot: 'inputs with no labels, or a form that cannot submit anything meaningful.',
    io: 'user typing → named values on submit',
    fails: 'missing name attributes or unlabeled fields',
    demo:
        '<form>\n'
        '  <label>Email <input name="email" type="email"></label>\n'
        '  <button type="submit">Join</button>\n'
        '</form>\n',
    demoTalk: 'Label wraps the control. `name` is what the server/program receives.',
    howCode:
        '<form action="/signup" method="post">\n'
        '  <label for="u">Username</label>\n'
        '  <input id="u" name="username" required>\n'
        '  <button>Save</button>\n'
        '</form>\n',
    howTalk: <String>[
      '`for`/`id` connect label ↔ input.',
      '`name` is the key in the submitted data.',
      '`required` blocks empty submit (browser help).',
      'Button inside form submits by default.',
    ],
    tweak: 'the input type',
    mission: 'Build a tiny “report a bug” form with title + details.',
    applyCode:
        '<form>\n'
        '  <label>Title <input name="title"></label>\n'
        '  <label>Details <textarea name="details"></textarea></label>\n'
        '  <button type="submit">Send</button>\n'
        '</form>\n',
    applySteps: <String>[
      'Add form wrapper.',
      'Label every field.',
      'Give each control a name.',
      'Add submit button.',
      'Try submitting empty — then add required where it helps.',
    ],
    coachTip: 'If you cannot tab to a field and hear/see its label, fix accessibility first.',
    examplePrompt: 'Login stub: username + password.',
    exampleCode:
        '<form>\n'
        '  <input name="user" placeholder="Username">\n'
        '  <input name="pass" type="password" placeholder="Password">\n'
        '  <button>Log in</button>\n'
        '</form>\n',
    exampleTalk: 'Password type hides characters. Names identify fields.',
    trace: 'User types → values sit on named inputs → submit packages them.',
    remix: 'Add an email field with type="email".',
    bugCode: '<input type="text">\n<button>Go</button>\n',
    bugWhy: 'No form, no name, no label.',
    fixCode:
        '<form>\n'
        '  <label>Search <input name="q"></label>\n'
        '  <button>Go</button>\n'
        '</form>\n',
    fixWhy: 'Labeled, named, inside a form.',
    otherTraps: '1. Placeholder as only label.\n2. Buttons outside forms.\n3. Ignoring validation.',
  );

  static final _CsSnippet _css = _CsSnippet(
    oneLiner: 'you style HTML with selectors that paint properties onto matching elements.',
    includes: 'selectors, properties, values, and the cascade idea.',
    isNot: 'sprinkling random inline styles everywhere with no plan.',
    io: 'selector + properties → visual change',
    fails: 'selector matches nothing or property is invalid',
    demo: 'h1 {\n  color: #fb923c;\n}\n',
    demoTalk: 'Left = who. Inside braces = how they look.',
    howCode:
        '.card {\n'
        '  padding: 12px;\n'
        '  border-radius: 8px;\n'
        '  background: #0f172a;\n'
        '}\n',
    howTalk: <String>[
      '`.card` selects elements with class="card".',
      '`padding` adds inner space.',
      '`border-radius` softens corners.',
      '`background` sets the fill color.',
    ],
    tweak: 'the color value',
    mission: 'Style an image card so it looks intentional.',
    applyCode:
        'img.hero {\n'
        '  max-width: 100%;\n'
        '  border-radius: 12px;\n'
        '}\n',
    applySteps: <String>[
      'Write a selector that matches your HTML.',
      'Add one property — confirm it applies.',
      'Add spacing / radius.',
      'Check mobile width (max-width: 100%).',
      'Only then pile on more flair.',
    ],
    coachTip: 'One property at a time beats a 40-line mystery stylesheet.',
    examplePrompt: 'Make all images rounded and responsive.',
    exampleCode: 'img {\n  max-width: 100%;\n  height: auto;\n  border-radius: 10px;\n}\n',
    exampleTalk: 'max-width keeps images inside the screen; height:auto keeps aspect ratio.',
    trace: 'Every img matches → browser recomputes layout → corners round.',
    remix: 'Target only `.avatar` images instead of all img.',
    bugCode: 'imgg { colour: blue; }\n',
    bugWhy: 'Typo selector + invalid property name `colour`.',
    fixCode: 'img { color: blue; }\n',
    fixWhy: 'Valid selector + property (note: color affects text, not photo pixels).',
    otherTraps: '1. Fighting specificity wars.\n2. !important spam.\n3. Styling before HTML exists.',
  );

  static final _CsSnippet _functions = _CsSnippet(
    oneLiner: 'you package a reusable action with a name, inputs (parameters), and a result.',
    includes: 'definition, parameters, return/print, and calling the function.',
    isNot: 'copy-pasting the same 10 lines with tiny edits forever.',
    io: 'arguments in → computed result out',
    fails: 'you never call it, or parameters do not match the body',
    demo: 'def greet(name):\n    return f"Hi, {name}!"\n\nprint(greet("Alex"))\n',
    demoTalk: 'Define once. Call with different names. Same recipe, new ingredient.',
    howCode:
        'def area(w, h):\n'
        '    return w * h\n'
        '\n'
        'print(area(3, 4))  # 12\n',
    howTalk: <String>[
      '`def area` names the recipe.',
      '`w, h` are placeholders filled at call time.',
      '`return` hands the answer back.',
      '`area(3, 4)` runs the body with those values.',
    ],
    tweak: 'the arguments 3 and 4',
    mission: 'Write a tiny helper that formats a label for your topic.',
    applyCode:
        'def label(topic):\n'
        '    return f"Learning: {topic}"\n'
        '\n'
        'print(label("Images"))\n',
    applySteps: <String>[
      'Name the function after the verb it does.',
      'List parameters you truly need.',
      'Return a value (or print if that is the lesson).',
      'Call it twice with different args.',
      'Trace one call on paper.',
    ],
    coachTip: 'If the name is a noun mush, rename until it sounds like a verb.',
    examplePrompt: 'Double a number with a function.',
    exampleCode: 'def double(n):\n    return n * 2\n\nprint(double(5))\n',
    exampleTalk: 'Parameter n becomes 5 → return 10 → print shows 10.',
    trace: 'Call double(5) → n=5 → return 10 → stdout: 10.',
    remix: 'Add a triple(n) function beside it.',
    bugCode: 'def add(a, b):\n    a + b\n\nprint(add(2, 3))\n',
    bugWhy: 'Computed but never returned → prints None.',
    fixCode: 'def add(a, b):\n    return a + b\n\nprint(add(2, 3))\n',
    fixWhy: 'return sends the value to the caller.',
    otherTraps: '1. Side effects everywhere.\n2. Too many parameters.\n3. Functions that do five unrelated jobs.',
  );

  static final _CsSnippet _loops = _CsSnippet(
    oneLiner: 'you repeat a block while a condition holds or while items remain.',
    includes: 'the loop header, the body, and the update that prevents infinite loops.',
    isNot: 'copy-pasting the same line 20 times.',
    io: 'a sequence / counter → repeated actions',
    fails: 'the counter never changes or the range is wrong (off-by-one)',
    demo: 'for i in range(3):\n    print(i)\n# 0 1 2\n',
    demoTalk: 'Header decides how many times. Body is the repeated action.',
    howCode:
        'nums = [2, 4, 6]\n'
        'total = 0\n'
        'for n in nums:\n'
        '    total += n\n'
        'print(total)  # 12\n',
    howTalk: <String>[
      'Start total at 0.',
      'Each loop: pull next n from the list.',
      'Add n into total.',
      'After the last item, print the sum.',
    ],
    tweak: 'the list values',
    mission: 'Loop over three image filenames and print a tag line for each.',
    applyCode:
        'files = ["a.png", "b.png", "c.png"]\n'
        'for f in files:\n'
        '    print(f"<img src=\\"{f}\\" alt=\\"{f}\\">")\n',
    applySteps: <String>[
      'Make a tiny list of inputs.',
      'Write the for-header.',
      'Do one clear action in the body.',
      'Hand-trace the first and last iteration.',
      'Only then add filters/if conditions.',
    ],
    coachTip: 'Trace iteration #1 and the last iteration — that catches most bugs.',
    examplePrompt: 'Print numbers 1 through 3.',
    exampleCode: 'for i in range(1, 4):\n    print(i)\n',
    exampleTalk: 'range(1, 4) → 1,2,3 (stop is exclusive).',
    trace: 'i=1 print → i=2 print → i=3 print → stop.',
    remix: 'Print only even numbers with an if inside the loop.',
    bugCode: 'i = 0\nwhile i < 3:\n    print(i)\n# forgot i += 1\n',
    bugWhy: 'Infinite loop — i never changes.',
    fixCode: 'i = 0\nwhile i < 3:\n    print(i)\n    i += 1\n',
    fixWhy: 'Update moves you toward the stop condition.',
    otherTraps: '1. Off-by-one.\n2. Mutating a list while looping carelessly.\n3. Nested loops without a reason.',
  );

  static final _CsSnippet _arrays = _CsSnippet(
    oneLiner: 'you store an ordered sequence of values you can index and iterate.',
    includes: 'indexes (usually from 0), length, read/update, and traversal.',
    isNot: 'a pile of separately named variables like a1, a2, a3…',
    io: 'index → value at that slot',
    fails: 'you use an index past the end',
    demo: 'colors = ["red", "green", "blue"]\nprint(colors[0])  # red\n',
    demoTalk: 'Index 0 is the first slot. That surprises humans; computers love it.',
    howCode:
        'imgs = ["a.jpg", "b.jpg"]\n'
        'imgs.append("c.jpg")\n'
        'print(len(imgs))  # 3\n',
    howTalk: <String>[
      'Start with two filenames.',
      'append adds to the end.',
      'len counts how many slots are filled.',
      'Loop later if you need every item.',
    ],
    tweak: 'index 0 to 1',
    mission: 'Keep three image paths in a list and print the middle one.',
    applyCode:
        'paths = ["hero.png", "logo.png", "icon.png"]\n'
        'print(paths[1])  # logo.png\n',
    applySteps: <String>[
      'Create the list with [ ].',
      'Read one index on purpose.',
      'Print len(list).',
      'Update one slot.',
      'Loop to print all.',
    ],
    coachTip: 'Say indexes out loud: “zeroth, first, second…” until 0-based feels normal.',
    examplePrompt: 'Sum [1, 2, 3].',
    exampleCode: 'a = [1, 2, 3]\nprint(sum(a))\n',
    exampleTalk: 'Array holds values; sum walks them.',
    trace: '1+2+3 → 6.',
    remix: 'Print the last element with a[-1].',
    bugCode: 'a = [10, 20]\nprint(a[2])\n',
    bugWhy: 'Index 2 does not exist (only 0 and 1).',
    fixCode: 'a = [10, 20]\nprint(a[1])\n',
    fixWhy: 'Last valid index is len(a)-1.',
    otherTraps: '1. Assuming 1-based indexes.\n2. Confusing value with index.\n3. Growing arrays in hot loops without need.',
  );

  static final _CsSnippet _conditionals = _CsSnippet(
    oneLiner: 'you choose which code runs based on a true/false check.',
    includes: 'if / else (and elif), comparisons, and boolean logic.',
    isNot: 'running every branch “just in case”.',
    io: 'a condition → one chosen path',
    fails: 'the condition is wrong or you forget a case',
    demo: 'score = 85\nif score >= 70:\n    print("Pass")\nelse:\n    print("Retry")\n',
    demoTalk: 'Question → yes path / no path. Only one story plays.',
    howCode:
        'src = "cat.jpg"\n'
        'if src.endswith(".jpg") or src.endswith(".png"):\n'
        '    print("Looks like an image file")\n'
        'else:\n'
        '    print("Unknown type")\n',
    howTalk: <String>[
      'Build a boolean question.',
      'If true → first block.',
      'Else → backup block.',
      'Order matters: first matching if wins when you chain elif.',
    ],
    tweak: 'the score threshold',
    mission: 'Gate an image tag: only print <img> if the filename looks valid.',
    applyCode:
        'f = "dog.png"\n'
        'if f:\n'
        '    print(f"<img src=\\"{f}\\" alt=\\"pet\\">")\n'
        'else:\n'
        '    print("<!-- missing src -->")\n',
    applySteps: <String>[
      'Write the condition in plain English first.',
      'Code the if body for the happy path.',
      'Add else for the failure path.',
      'Test both true and false inputs.',
      'Only then add elif branches.',
    ],
    coachTip: 'Always invent one input that should fail — that proves the else works.',
    examplePrompt: 'Print even/odd for a number.',
    exampleCode: 'n = 4\nif n % 2 == 0:\n    print("even")\nelse:\n    print("odd")\n',
    exampleTalk: '% 2 == 0 means divisible by 2.',
    trace: 'n=4 → true → print even.',
    remix: 'Also print “div by 5” with elif.',
    bugCode: 'if x = 5:\n    print("oops")\n',
    bugWhy: 'Assignment instead of comparison (language-dependent footgun).',
    fixCode: 'if x == 5:\n    print("ok")\n',
    fixWhy: '== asks; = stores.',
    otherTraps: '1. Overlapping conditions.\n2. Empty if bodies.\n3. Negation spaghetti.',
  );

  static final _CsSnippet _variables = _CsSnippet(
    oneLiner: 'you stick a name on a value so you can reuse and update it.',
    includes: 'name = value, reading the name later, and updating it.',
    isNot: 'magic numbers repeated everywhere with no name.',
    io: 'a name ↔ a current value',
    fails: 'you use a name before assigning it',
    demo: 'title = "Images"\nprint(title)\n',
    demoTalk: 'Box labeled title holds the string Images.',
    howCode:
        'src = "cat.jpg"\n'
        'alt = "Orange cat"\n'
        'tag = f"<img src=\\"{src}\\" alt=\\"{alt}\\">"\n'
        'print(tag)\n',
    howTalk: <String>[
      'Store the path in src.',
      'Store the description in alt.',
      'Build the HTML string from those names.',
      'Print the assembled tag.',
    ],
    tweak: 'the src string',
    mission: 'Build an img tag from two variables.',
    applyCode:
        'src = "logo.png"\n'
        'alt = "Brand logo"\n'
        'print(f"<img src=\\"{src}\\" alt=\\"{alt}\\">")\n',
    applySteps: <String>[
      'Create src.',
      'Create alt.',
      'Print/compose using both names.',
      'Change src once — confirm output changes.',
      'Rename variables if they feel vague.',
    ],
    coachTip: 'Names are UI for your future brain — make them boring and clear.',
    examplePrompt: 'Swap two variables (classic).',
    exampleCode: 'a, b = 1, 2\na, b = b, a\nprint(a, b)  # 2 1\n',
    exampleTalk: 'Tuple unpack swaps without a temp in Python.',
    trace: 'Start a=1,b=2 → after swap a=2,b=1.',
    remix: 'Do the swap with an explicit temp variable.',
    bugCode: 'print(score)\nscore = 10\n',
    bugWhy: 'Used before assigned.',
    fixCode: 'score = 10\nprint(score)\n',
    fixWhy: 'Assign first, use second.',
    otherTraps: '1. Meaningless names (x1, tmp2).\n2. Reusing one name for two jobs.\n3. Mutating when you meant to copy.',
  );

  static final _CsSnippet _classes = _CsSnippet(
    oneLiner: 'you define a blueprint for objects that bundle data + behavior.',
    includes: 'class body, __init__/constructor, methods, and instances.',
    isNot: 'a folder of unrelated functions with no shared state story.',
    io: 'class → many objects with the same shape',
    fails: 'you forget self/this or never construct an instance',
    demo:
        'class Dog:\n'
        '    def __init__(self, name):\n'
        '        self.name = name\n'
        '\n'
        'print(Dog("Nori").name)\n',
    demoTalk: 'Class = mold. Instance = one dog poured from the mold.',
    howCode:
        'class Image:\n'
        '    def __init__(self, src, alt):\n'
        '        self.src = src\n'
        '        self.alt = alt\n'
        '    def tag(self):\n'
        '        return f"<img src=\\"{self.src}\\" alt=\\"{self.alt}\\">"\n',
    howTalk: <String>[
      '__init__ stores src/alt on the object.',
      'tag() reads those fields to build HTML.',
      'Each Image instance keeps its own data.',
      'Call img.tag() to get the string.',
    ],
    tweak: 'the alt string on one instance',
    mission: 'Model an Image with src + alt and a method that returns HTML.',
    applyCode:
        'img = Image("cat.jpg", "Cat")\n'
        'print(img.tag())\n',
    applySteps: <String>[
      'Define the class.',
      'Store fields in __init__.',
      'Add one method that uses the fields.',
      'Construct an instance.',
      'Call the method and print.',
    ],
    coachTip: 'If two values always travel together, they might belong on one object.',
    examplePrompt: 'Counter object that can increment.',
    exampleCode:
        'class Counter:\n'
        '    def __init__(self):\n'
        '        self.n = 0\n'
        '    def inc(self):\n'
        '        self.n += 1\n',
    exampleTalk: 'State lives on self.n; inc mutates it.',
    trace: 'c=Counter(); c.inc(); c.n == 1.',
    remix: 'Add a reset() method.',
    bugCode: 'class A:\n    def hi():\n        print("hi")\n',
    bugWhy: 'Missing self on the method.',
    fixCode: 'class A:\n    def hi(self):\n        print("hi")\n',
    fixWhy: 'Instance methods take self.',
    otherTraps: '1. God classes.\n2. Public mutable chaos.\n3. Inheritance before composition.',
  );

  static final _CsSnippet _htmlBasics = _CsSnippet(
    oneLiner: 'you describe page structure with nested tags the browser turns into a document.',
    includes: 'elements, attributes, nesting, and the idea of a tree.',
    isNot: 'a Word doc pasted into a browser tab.',
    io: 'tags → a rendered page structure',
    fails: 'tags are unclosed / mismatched so the tree breaks',
    demo: '<h1>Hello</h1>\n<p>Welcome to coding.</p>\n',
    demoTalk: 'Opening tag, content, closing tag. Nesting builds the tree.',
    howCode:
        '<!doctype html>\n'
        '<html>\n'
        '  <body>\n'
        '    <h1>Images</h1>\n'
        '    <p>Pictures need src + alt.</p>\n'
        '  </body>\n'
        '</html>\n',
    howTalk: <String>[
      'html wraps the document.',
      'body holds visible content.',
      'h1 is the main heading.',
      'p is a paragraph under it.',
    ],
    tweak: 'the heading text',
    mission: 'Scaffold a one-section page about your topic.',
    applyCode:
        '<section>\n'
        '  <h2>Images</h2>\n'
        '  <p>Use &lt;img&gt; with src and alt.</p>\n'
        '</section>\n',
    applySteps: <String>[
      'Write the heading.',
      'Add one paragraph.',
      'Nest them in a section.',
      'Validate closing tags.',
      'Only then add CSS.',
    ],
    coachTip: 'Indent like you mean it — nesting becomes obvious.',
    examplePrompt: 'Title + one sentence intro.',
    exampleCode: '<h1>GradeGlow</h1>\n<p>Code with your AI Professor.</p>\n',
    exampleTalk: 'Two sibling elements under body.',
    trace: 'Browser builds heading node, then paragraph node, paints both.',
    remix: 'Add an img under the paragraph.',
    bugCode: '<h1>Hi<p>oops</h1></p>\n',
    bugWhy: 'Crossed tags — tree is illegal.',
    fixCode: '<h1>Hi</h1>\n<p>oops</p>\n',
    fixWhy: 'Close inner ideas in order.',
    otherTraps: '1. Div soup.\n2. Skipping headings levels wildly.\n3. Inline CSS sprawl.',
  );

  static _CsSnippet _generic(String topic) {
    final String slug = topic
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final String safe = slug.isEmpty ? 'topic' : slug;
    return _CsSnippet(
      oneLiner:
          'a coding concept with clear inputs, behavior, and outputs you can demonstrate in a tiny program.',
      includes:
          'the problem it solves, the syntax/algorithm shape, and the edge cases you must handle.',
      isNot: 'copying code you cannot explain, or ignoring empty/null/overflow cases.',
      io: 'input → $topic behavior → output',
      fails: 'edge cases are ignored or the invariant breaks',
      demo:
          '# Quick taste of $topic\n'
          'def demo_$safe(x):\n'
          '    """Show $topic on a tiny input."""\n'
          '    return x\n'
          '\n'
          'print(demo_$safe("hello"))\n',
      demoTalk:
          'We wrap the idea in a tiny function so we can call it, print it, and talk about it.',
      howCode:
          'data = ["a", "b", "c"]\n'
          'result = []\n'
          'for item in data:          # walk input\n'
          '    # apply $topic idea here\n'
          '    result.append(item)\n'
          'print(result)\n',
      howTalk: <String>[
        'Start with a tiny concrete input you can trace.',
        'Walk it step by step — $topic happens inside the loop/branch.',
        'Collect or print an output you can predict.',
        'Compare hand-trace vs Run output.',
      ],
      tweak: 'the sample data',
      mission: 'Write the smallest program that clearly shows $topic.',
      applyCode:
          '# Mission: demonstrate $topic\n'
          'def solve(items):\n'
          '    # 1) validate input\n'
          '    # 2) apply $topic\n'
          '    # 3) return something observable\n'
          '    return items\n'
          '\n'
          'print(solve([1, 2, 3]))\n',
      applySteps: <String>[
        'Restate inputs/outputs in a comment.',
        'Write the smallest outline that uses $topic.',
        'Implement one step, then Run.',
        'Hand-trace a 3-item example.',
        'Add one edge case (empty input) only after the happy path works.',
      ],
      coachTip: 'If you cannot predict the printout, you do not own $topic yet — shrink the example.',
      examplePrompt: 'Demonstrate $topic on [1, 2, 3] and print a clear result.',
      exampleCode:
          'def show_$safe(xs):\n'
          '    print("input:", xs)\n'
          '    # $topic happens here\n'
          '    out = xs\n'
          '    print("output:", out)\n'
          '    return out\n'
          '\n'
          'show_$safe([1, 2, 3])\n',
      exampleTalk:
          '• Print input so the story is visible.\n'
          '• Apply $topic in the middle.\n'
          '• Print output and return it for reuse.',
      trace: 'Call with [1,2,3] → watch each print → confirm it matches your paper trace.',
      remix: 'Change the list to [9] and re-trace before you re-run.',
      bugCode:
          'def show_$safe(xs):\n'
          '    out = xs\n'
          '    # forgot to print / return meaningfully\n'
          '\n'
          'show_$safe([1, 2, 3])\n',
      bugWhy: 'Silent function — you cannot tell if $topic worked.',
      fixCode:
          'def show_$safe(xs):\n'
          '    out = xs  # apply $topic\n'
          '    print(out)\n'
          '    return out\n'
          '\n'
          'show_$safe([1, 2, 3])\n',
      fixWhy: 'Observable output proves the idea.',
      otherTraps:
          '1. Coding before defining I/O.\n'
          '2. Ignoring empty / one-element cases.\n'
          '3. Off-by-one in loops/indexes.\n'
          '4. Assuming Run = understanding without a hand trace.',
    );
  }
}

class _CsSnippet {
  const _CsSnippet({
    required this.oneLiner,
    required this.includes,
    required this.isNot,
    required this.io,
    required this.fails,
    required this.demo,
    required this.demoTalk,
    required this.howCode,
    required this.howTalk,
    required this.tweak,
    required this.mission,
    required this.applyCode,
    required this.applySteps,
    required this.coachTip,
    required this.examplePrompt,
    required this.exampleCode,
    required this.exampleTalk,
    required this.trace,
    required this.remix,
    required this.bugCode,
    required this.bugWhy,
    required this.fixCode,
    required this.fixWhy,
    required this.otherTraps,
  });

  final String oneLiner;
  final String includes;
  final String isNot;
  final String io;
  final String fails;
  final String demo;
  final String demoTalk;
  final String howCode;
  final List<String> howTalk;
  final String tweak;
  final String mission;
  final String applyCode;
  final List<String> applySteps;
  final String coachTip;
  final String examplePrompt;
  final String exampleCode;
  final String exampleTalk;
  final String trace;
  final String remix;
  final String bugCode;
  final String bugWhy;
  final String fixCode;
  final String fixWhy;
  final String otherTraps;
}
