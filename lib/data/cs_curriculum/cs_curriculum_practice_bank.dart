import '../../models/cs_curriculum.dart';
import '../../models/leetcode_problem.dart';

/// Lecture-aligned practice problems for curriculum language tracks (not algorithms).
class CsCurriculumPracticeBank {
  CsCurriculumPracticeBank._();

  static LeetcodeProblem forTopic({
    required CsCurriculumTopic topic,
    required String difficulty,
    required String codeLang,
    required String langLabel,
    bool isWeb = false,
  }) {
    final _PracticeTask task = _taskSetFor(topic, langLabel, codeLang, isWeb).forDifficulty(difficulty);
    final String slug = _slug('${topic.id}-$difficulty');
    return LeetcodeProblem(
      id: slug,
      title: task.title,
      slug: slug,
      difficulty: difficulty,
      description: task.description,
      functionName: task.functionName,
      examples: task.examples,
      constraints: task.constraintList,
      tags: <String>[langLabel, topic.title, 'Lecture practice'],
      starterCode: task.starterFor(codeLang),
      hiddenTests: task.hiddenFor(difficulty),
    );
  }

  static _PracticeTaskSet _taskSetFor(
    CsCurriculumTopic topic,
    String langLabel,
    String codeLang,
    bool isWeb,
  ) {
    final _PracticeTaskSet? html = _htmlTaskSet(topic.title);
    if (html != null) return html;

    final _PracticeTaskSet? css = _cssTaskSet(topic.title);
    if (css != null) return css;

    if (topic.languageId == 'javascript' || topic.languageId == 'typescript') {
      return _jsTaskSet(topic.title, langLabel);
    }

    if (isWeb) {
      return _webGeneric(topic.title, langLabel, codeLang);
    }

    return _programmingGeneric(topic.title, langLabel, codeLang);
  }

  static _PracticeTaskSet? _htmlTaskSet(String title) {
  final String key = _htmlKey(title);
  return _htmlSets[key];
  }

  static String _htmlKey(String title) {
    final String t = title.toLowerCase();
    if (t.contains('document structure')) return 'document_structure';
    if (t.contains('introduction')) return 'introduction';
    if (t.contains('heading')) return 'headings';
    if (t.contains('paragraph')) return 'paragraphs';
    if (t.contains('formatting')) return 'formatting';
    if (t.contains('link')) return 'links';
    if (t.contains('image')) return 'images';
    if (t.contains('list')) return 'lists';
    if (t.contains('table')) return 'tables';
    if (t.contains('form') && !t.contains('platform')) return 'forms';
    if (t.contains('input type')) return 'input_types';
    if (t.contains('button')) return 'buttons';
    if (t.contains('label')) return 'labels';
    if (t.contains('select')) return 'select';
    if (t.contains('textarea')) return 'textarea';
    if (t.contains('semantic')) return 'semantic';
    if (t.contains('div') || t.contains('span')) return 'div_span';
    if (t.contains('audio')) return 'audio';
    if (t.contains('video')) return 'video';
    if (t.contains('iframe')) return 'iframes';
    if (t.contains('meta')) return 'meta';
    if (t.contains('entit')) return 'entities';
    if (t.contains('aria') || t.contains('accessibility')) return 'aria';
    if (t.contains('responsive')) return 'responsive_images';
    if (t.contains('canvas')) return 'canvas';
    if (t.contains('svg')) return 'svg';
    if (t.contains('storage')) return 'storage';
    if (t.contains('geolocation')) return 'geolocation';
    if (t.contains('drag')) return 'drag_drop';
    if (t.contains('best practice')) return 'best_practices';
    return 'generic';
  }

  static final Map<String, _PracticeTaskSet> _htmlSets = <String, _PracticeTaskSet>{
    'introduction': _htmlIntro(),
    'document_structure': _htmlDocumentStructure(),
    'headings': _htmlHeadings(),
    'paragraphs': _htmlParagraphs(),
    'formatting': _htmlFormatting(),
    'links': _htmlLinks(),
    'images': _htmlImages(),
    'lists': _htmlLists(),
    'tables': _htmlTables(),
    'forms': _htmlForms(),
    'input_types': _htmlInputTypes(),
    'buttons': _htmlButtons(),
    'labels': _htmlLabels(),
    'select': _htmlSelect(),
    'textarea': _htmlTextarea(),
    'semantic': _htmlSemantic(),
    'div_span': _htmlDivSpan(),
    'audio': _htmlMedia('Audio', '<audio>', 'controls', 'audio/mpeg'),
    'video': _htmlMedia('Video', '<video>', 'controls', 'video/mp4'),
    'iframes': _htmlIframes(),
    'meta': _htmlMeta(),
    'entities': _htmlEntities(),
    'aria': _htmlAria(),
    'responsive_images': _htmlResponsiveImages(),
    'canvas': _htmlCanvas(),
    'svg': _htmlSvg(),
    'storage': _htmlStorage(),
    'geolocation': _htmlGeolocation(),
    'drag_drop': _htmlDragDrop(),
    'best_practices': _htmlBestPractices(),
    'generic': _htmlGeneric(),
  };

  static _PracticeTaskSet? _cssTaskSet(String title) {
    final String t = title.toLowerCase();
    if (t.contains('selector')) return _cssSelectors();
    if (t.contains('flexbox')) return _cssFlexbox();
    if (t.contains('grid')) return _cssGrid();
    if (t.contains('box model')) return _cssBoxModel();
    if (t.contains('color')) return _cssColors();
    if (t.contains('introduction')) return _cssIntro();
    return _cssGeneric(title);
  }

  static _PracticeTaskSet _jsTaskSet(String title, String langLabel) {
    final String t = title.toLowerCase();
    if (t.contains('variable')) return _jsVariables(langLabel);
    if (t.contains('function')) return _jsFunctions(langLabel);
    if (t.contains('array')) return _jsArrays(langLabel);
    if (t.contains('loop')) return _jsLoops(langLabel);
    if (t.contains('dom')) return _jsDom(langLabel);
    if (t.contains('event')) return _jsEvents(langLabel);
    return _programmingGeneric(title, langLabel, 'javascript');
  }

  static _PracticeTaskSet _htmlIntro() => _lectureSet(
        lectureTopic: 'Introduction to HTML',
        langLabel: 'HTML',
        easy: _task(
          title: 'Your First HTML Page',
          lectureTopic: 'Introduction to HTML',
          body:
              'Create a minimal HTML page that displays **Hello, World!** inside a `<p>` tag. '
              'Use a valid `<!DOCTYPE html>` declaration and wrap content in `<html>` and `<body>`.',
          exampleOut: 'Page contains Hello, World! in a paragraph inside valid HTML structure.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  \n</body>\n</html>\n',
          extraConstraints: <String>['Use a paragraph tag', 'Text must be exactly: Hello, World!'],
        ),
        medium: _task(
          title: 'Page Title & Content',
          lectureTopic: 'Introduction to HTML',
          body:
              'Build a page with `<head>` containing `<title>My First Page</title>` and a `<body>` with an `<h1>` '
              'saying **Welcome** plus a `<p>` introducing yourself in one sentence.',
          exampleOut: 'Document has title in head, h1 Welcome, and a short intro paragraph.',
          starter: '<!DOCTYPE html>\n<html>\n<head>\n  \n</head>\n<body>\n  \n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Structured Intro Page',
          lectureTopic: 'Introduction to HTML',
          body:
              'Create a complete HTML5 page: doctype, `lang="en"` on `<html>`, charset meta in `<head>`, '
              'title **Learning HTML**, `<h1>` + two `<p>` sections (what HTML is, why it matters).',
          exampleOut: 'Full HTML5 intro page with meta charset, title, h1, and two paragraphs.',
          starter: '<!DOCTYPE html>\n<html lang="en">\n<head>\n  <meta charset="UTF-8">\n  <title></title>\n</head>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlDocumentStructure() => _lectureSet(
        lectureTopic: 'HTML Document Structure',
        langLabel: 'HTML',
        easy: _task(
          title: 'HTML5 Skeleton',
          lectureTopic: 'HTML Document Structure',
          body:
              'From your **HTML Document Structure** lecture: add `<!DOCTYPE html>`, `<html>`, `<head>`, and `<body>` '
              'in the correct nesting order.',
          exampleOut: 'Valid skeleton with doctype, html, head, and body.',
          starter: '<!DOCTYPE html>\n<html>\n\n</html>\n',
          extraConstraints: <String>['`<head>` must be before `<body>`', 'Use HTML5 doctype'],
        ),
        medium: _task(
          title: 'Head Metadata',
          lectureTopic: 'HTML Document Structure',
          body:
              'Complete the document structure with `<title>HTML Practice</title>` and `<meta charset="UTF-8">` inside `<head>`. '
              'Add `<body>` with a comment `<!-- main content -->`.',
          exampleOut: 'Head has title and charset meta; body contains the required comment.',
          starter: '<!DOCTYPE html>\n<html>\n<head>\n\n</head>\n<body>\n\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Full Document Outline',
          lectureTopic: 'HTML Document Structure',
          body:
              'Build a complete HTML5 document: doctype, `lang="en"`, charset meta, title **Structure Lab**, '
              'and `<body>` with `<h1>Document Structure</h1>` and `<p>` explaining why `<head>` and `<body>` are separate.',
          exampleOut: 'Complete HTML5 document with lang, meta, title, h1, and explanatory paragraph.',
          starter: '<!DOCTYPE html>\n<html lang="en">\n<head>\n  <meta charset="UTF-8">\n  <title></title>\n</head>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlHeadings() => _lectureSet(
        lectureTopic: 'Headings',
        langLabel: 'HTML',
        easy: _task(
          title: 'Main Heading',
          lectureTopic: 'Headings',
          body: 'Use an `<h1>` to display **GradeGlow Study Guide** as the main page heading.',
          exampleOut: 'Single h1 with text GradeGlow Study Guide.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  \n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Heading Hierarchy',
          lectureTopic: 'Headings',
          body: 'Create `<h1>Course</h1>`, `<h2>Module 1</h2>`, and `<h2>Module 2</h2>` showing proper heading levels.',
          exampleOut: 'One h1 and two h2 headings in logical order.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  \n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Outline with h1–h3',
          lectureTopic: 'Headings',
          body:
              'Build a syllabus outline: `<h1>Computer Science</h1>`, two `<h2>` units, each with an `<h3>` lesson title underneath. '
              'Do not skip heading levels.',
          exampleOut: 'h1 → h2 → h3 hierarchy without skipped levels.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlParagraphs() => _lectureSet(
        lectureTopic: 'Paragraphs',
        langLabel: 'HTML',
        easy: _task(
          title: 'Single Paragraph',
          lectureTopic: 'Paragraphs',
          body: 'Wrap the sentence **HTML paragraphs group text into blocks.** in a `<p>` tag.',
          exampleOut: 'One paragraph with the required sentence.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  \n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Two Paragraphs',
          lectureTopic: 'Paragraphs',
          body: 'Write two separate `<p>` elements: one defining HTML, one explaining when to use paragraphs.',
          exampleOut: 'Two distinct paragraph blocks.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Article with Paragraphs',
          lectureTopic: 'Paragraphs',
          body: 'Create `<h1>Paragraphs</h1>` followed by three `<p>` tags forming a short article (intro, detail, conclusion).',
          exampleOut: 'h1 plus three meaningful paragraphs.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlFormatting() => _lectureSet(
        lectureTopic: 'Text Formatting',
        langLabel: 'HTML',
        easy: _task(
          title: 'Bold Important Text',
          lectureTopic: 'Text Formatting',
          body: 'In a paragraph, make the word **important** bold using `<strong>`.',
          exampleOut: 'Paragraph contains strong around the word important.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <p>Remember this is important for the exam.</p>\n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Emphasis & Strong',
          lectureTopic: 'Text Formatting',
          body: 'Use `<em>` for emphasis and `<strong>` for strong importance in the same sentence inside one `<p>`.',
          exampleOut: 'Paragraph uses both em and strong correctly.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <p>Practice HTML formatting today.</p>\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Mixed Formatting',
          lectureTopic: 'Text Formatting',
          body: 'Use `<strong>`, `<em>`, and `<mark>` in a short study tip paragraph. Include `<br>` for a line break.',
          exampleOut: 'Paragraph uses strong, em, mark, and br.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlLinks() => _lectureSet(
        lectureTopic: 'Links',
        langLabel: 'HTML',
        easy: _task(
          title: 'Basic Anchor',
          lectureTopic: 'Links',
          body: 'Create a link with text **Visit MDN** pointing to `https://developer.mozilla.org`.',
          exampleOut: 'Anchor with href to MDN and correct link text.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  \n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Link with target',
          lectureTopic: 'Links',
          body: 'Add an external link that opens in a new tab (`target="_blank"`) with `rel="noopener"`.',
          exampleOut: 'External link with target blank and rel noopener.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Navigation Links',
          lectureTopic: 'Links',
          body: 'Build a mini nav: three `<a>` links to `#home`, `#lessons`, `#practice` with labels Home, Lessons, Practice.',
          exampleOut: 'Three internal anchor links with hash hrefs.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <nav>\n    \n  </nav>\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlImages() => _lectureSet(
        lectureTopic: 'Images',
        langLabel: 'HTML',
        easy: _task(
          title: 'Image with Alt Text',
          lectureTopic: 'Images',
          body: 'Add an `<img>` with `src="logo.png"`, `alt="App logo"`, and `width="120"`.',
          exampleOut: 'img tag with src, alt, and width.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  \n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Figure with Caption',
          lectureTopic: 'Images',
          body: 'Wrap an image in `<figure>` with `<figcaption>` describing the diagram.',
          exampleOut: 'figure containing img and figcaption.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Responsive Image Markup',
          lectureTopic: 'Images',
          body: 'Create an `<img>` with meaningful `alt`, `loading="lazy"`, and `height`/`width` attributes.',
          exampleOut: 'Accessible img with lazy loading and dimensions.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlLists() => _lectureSet(
        lectureTopic: 'Lists',
        langLabel: 'HTML',
        easy: _task(
          title: 'Unordered List',
          lectureTopic: 'Lists',
          body: 'Create a `<ul>` with three `<li>` items: HTML, CSS, JavaScript.',
          exampleOut: 'ul with three list items.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  \n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Ordered Steps',
          lectureTopic: 'Lists',
          body: 'Use `<ol>` for three numbered study steps related to lists.',
          exampleOut: 'Ordered list with three steps.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Nested List',
          lectureTopic: 'Lists',
          body: 'Build a nested list: outer `<ul>` topic **Web Dev** with inner `<ul>` of two sub-skills.',
          exampleOut: 'Nested unordered lists.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlTables() => _lectureSet(
        lectureTopic: 'Tables',
        langLabel: 'HTML',
        easy: _task(
          title: 'Simple Table',
          lectureTopic: 'Tables',
          body: 'Create a 2×2 table with `<table>`, `<tr>`, and `<td>` (header row: Name, Score).',
          exampleOut: 'Table with header row and one data row.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <table>\n    \n  </table>\n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Table with thead',
          lectureTopic: 'Tables',
          body: 'Use `<thead>`, `<tbody>`, and `<th>` for column headers Subject and Grade.',
          exampleOut: 'Semantic table with thead, tbody, th.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <table>\n\n  </table>\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Schedule Table',
          lectureTopic: 'Tables',
          body: 'Build a 3-column schedule table (Day, Topic, Time) with at least two data rows using `<th>` in thead.',
          exampleOut: 'Three-column schedule with thead and two body rows.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlForms() => _lectureSet(
        lectureTopic: 'Forms',
        langLabel: 'HTML',
        easy: _task(
          title: 'Basic Form',
          lectureTopic: 'Forms',
          body: 'Create a `<form>` with `action="/subscribe"` and `method="post"` containing one text `<input name="email">`.',
          exampleOut: 'Form with action, method post, and email input.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <form>\n    \n  </form>\n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Login Form',
          lectureTopic: 'Forms',
          body: 'Build a login form with username and password fields plus a submit `<button type="submit">`.',
          exampleOut: 'Form with two inputs and submit button.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <form>\n\n  </form>\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Registration Form',
          lectureTopic: 'Forms',
          body: 'Create a registration form: name, email, password, confirm password, and submit. Use appropriate `name` attributes.',
          exampleOut: 'Multi-field registration form with submit.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlInputTypes() => _lectureSet(
        lectureTopic: 'Input Types',
        langLabel: 'HTML',
        easy: _task(
          title: 'Email Input',
          lectureTopic: 'Input Types',
          body: 'Add `<input type="email" name="email" required placeholder="you@school.edu">`.',
          exampleOut: 'Email input with name, required, and placeholder.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <form>\n    \n  </form>\n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Number & Date',
          lectureTopic: 'Input Types',
          body: 'Add `type="number"` (min 1, max 100) and `type="date"` inputs in one form.',
          exampleOut: 'Number input with min/max and date input.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <form>\n\n  </form>\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Mixed Input Types',
          lectureTopic: 'Input Types',
          body: 'Form with email, tel, url, checkbox (`name="agree"`), and radio group for skill level.',
          exampleOut: 'Form demonstrating multiple HTML5 input types.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlButtons() => _lectureSet(
        lectureTopic: 'Buttons',
        langLabel: 'HTML',
        easy: _task(
          title: 'Submit Button',
          lectureTopic: 'Buttons',
          body: 'Add `<button type="submit">Save</button>` inside a form.',
          exampleOut: 'Submit button with text Save.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <form>\n    \n  </form>\n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Button Types',
          lectureTopic: 'Buttons',
          body: 'Same form: `type="submit"`, `type="reset"`, and `type="button"` buttons with clear labels.',
          exampleOut: 'Three buttons with correct types.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <form>\n\n  </form>\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Accessible Buttons',
          lectureTopic: 'Buttons',
          body: 'Use `<button type="button" aria-label="Close dialog">×</button>` and a labeled submit button.',
          exampleOut: 'Buttons with aria-label and visible text.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlLabels() => _lectureSet(
        lectureTopic: 'Labels',
        langLabel: 'HTML',
        easy: _task(
          title: 'Label for Input',
          lectureTopic: 'Labels',
          body: 'Associate `<label for="username">Username</label>` with `<input id="username" name="username">`.',
          exampleOut: 'Label for attribute matches input id.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <form>\n    \n  </form>\n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Wrapped Label',
          lectureTopic: 'Labels',
          body: 'Wrap an input inside `<label>` for a checkbox **Remember me**.',
          exampleOut: 'Label wrapping checkbox with text.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <form>\n\n  </form>\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Form Labels',
          lectureTopic: 'Labels',
          body: 'Three labeled fields (name, email, message) each using `for`/`id` pairing.',
          exampleOut: 'Three inputs each with associated label.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlSelect() => _lectureSet(
        lectureTopic: 'Select & Option',
        langLabel: 'HTML',
        easy: _task(
          title: 'Dropdown',
          lectureTopic: 'Select & Option',
          body: 'Create `<select name="course">` with three `<option>` values: html, css, js.',
          exampleOut: 'Select with three options.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <form>\n    \n  </form>\n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Grouped Options',
          lectureTopic: 'Select & Option',
          body: 'Use `<optgroup label="Languages">` to group options in a select.',
          exampleOut: 'Select with optgroup.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <form>\n\n  </form>\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Labeled Select',
          lectureTopic: 'Select & Option',
          body: 'Label + select for **Difficulty** (Beginner, Intermediate, Advanced) with a default selected option.',
          exampleOut: 'Labeled select with default option.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlTextarea() => _lectureSet(
        lectureTopic: 'Textarea',
        langLabel: 'HTML',
        easy: _task(
          title: 'Message Box',
          lectureTopic: 'Textarea',
          body: 'Add `<textarea name="message" rows="4" placeholder="Your feedback">`.',
          exampleOut: 'Textarea with name, rows, placeholder.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <form>\n    \n  </form>\n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Labeled Textarea',
          lectureTopic: 'Textarea',
          body: 'Label **Comments** linked to a textarea with `maxlength="200"`.',
          exampleOut: 'Label + textarea with maxlength.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <form>\n\n  </form>\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Contact Form',
          lectureTopic: 'Textarea',
          body: 'Contact form: name input, email input, textarea for message, submit button.',
          exampleOut: 'Complete small contact form.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlSemantic() => _lectureSet(
        lectureTopic: 'Semantic HTML',
        langLabel: 'HTML',
        easy: _task(
          title: 'Header & Footer',
          lectureTopic: 'Semantic HTML',
          body: 'Use `<header>` with site title and `<footer>` with copyright text.',
          exampleOut: 'header and footer elements present.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  \n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Article & Section',
          lectureTopic: 'Semantic HTML',
          body: '`<main>` containing `<article>` with `<h1>` and `<section>` for content blocks.',
          exampleOut: 'main > article > section structure.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Page Landmarks',
          lectureTopic: 'Semantic HTML',
          body: 'Full page: header, nav, main (article + aside), footer using semantic tags only for layout regions.',
          exampleOut: 'header, nav, main, article, aside, footer.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlDivSpan() => _lectureSet(
        lectureTopic: 'Div & Span',
        langLabel: 'HTML',
        easy: _task(
          title: 'Div Container',
          lectureTopic: 'Div & Span',
          body: 'Wrap a heading and paragraph inside a `<div class="card">`.',
          exampleOut: 'div.card containing h and p.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  \n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Inline Span',
          lectureTopic: 'Div & Span',
          body: 'Use `<span class="highlight">` inside a sentence to style one word (no CSS required).',
          exampleOut: 'span.highlight inside paragraph.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <p>Highlight one word here.</p>\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Div Layout',
          lectureTopic: 'Div & Span',
          body: 'Three `<div class="column">` siblings each with a short paragraph (classic layout prep).',
          exampleOut: 'Three div.column elements with content.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlMedia(String topic, String tag, String attr, String type) => _lectureSet(
        lectureTopic: topic,
        langLabel: 'HTML',
        easy: _task(
          title: '$topic Element',
          lectureTopic: topic,
          body: 'Add `$tag` with `$attr` and a `<source src="file.$type" type="$type">` inside.',
          exampleOut: '$tag with controls and source child.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  \n</body>\n</html>\n',
        ),
        medium: _task(
          title: '$topic with Fallback',
          lectureTopic: topic,
          body: 'Include fallback text between `$tag` tags if media is unsupported.',
          exampleOut: '$tag with source and fallback text.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Accessible $topic',
          lectureTopic: topic,
          body: 'Add `$tag` with `controls`, descriptive fallback text, and `aria-label` describing the media.',
          exampleOut: 'Accessible media element.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlIframes() => _lectureSet(
        lectureTopic: 'Iframes',
        langLabel: 'HTML',
        easy: _task(
          title: 'Embed Page',
          lectureTopic: 'Iframes',
          body: 'Embed `https://example.com` in an `<iframe title="Example site">` with width 100% and height 300.',
          exampleOut: 'iframe with src, title, dimensions.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  \n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Sandboxed Iframe',
          lectureTopic: 'Iframes',
          body: 'Iframe with `sandbox` attribute and meaningful `title` for accessibility.',
          exampleOut: 'iframe with sandbox and title.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Iframe + Caption',
          lectureTopic: 'Iframes',
          body: 'Wrap iframe in figure/figcaption explaining embedded content purpose.',
          exampleOut: 'figure with iframe and figcaption.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlMeta() => _lectureSet(
        lectureTopic: 'Meta Tags',
        langLabel: 'HTML',
        easy: _task(
          title: 'Charset Meta',
          lectureTopic: 'Meta Tags',
          body: 'Add `<meta charset="UTF-8">` and `<meta name="viewport" content="width=device-width, initial-scale=1">` in head.',
          exampleOut: 'Charset and viewport meta tags in head.',
          starter: '<!DOCTYPE html>\n<html>\n<head>\n  <title>Meta Lab</title>\n</head>\n<body></body>\n</html>\n',
        ),
        medium: _task(
          title: 'Description Meta',
          lectureTopic: 'Meta Tags',
          body: 'Add meta description and author meta tags appropriate for a study app page.',
          exampleOut: 'description and author meta tags.',
          starter: '<!DOCTYPE html>\n<html>\n<head>\n  <meta charset="UTF-8">\n\n</head>\n<body></body>\n</html>\n',
        ),
        hard: _task(
          title: 'SEO Meta Set',
          lectureTopic: 'Meta Tags',
          body: 'Complete head meta: charset, viewport, description, keywords, and Open Graph `og:title`.',
          exampleOut: 'Full basic SEO meta set in head.',
          starter: '<!DOCTYPE html>\n<html>\n<head>\n\n</head>\n<body></body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlEntities() => _lectureSet(
        lectureTopic: 'HTML Entities',
        langLabel: 'HTML',
        easy: _task(
          title: 'Copyright Symbol',
          lectureTopic: 'HTML Entities',
          body: 'Display **© 2026 GradeGlow** using the `&copy;` entity in a paragraph.',
          exampleOut: 'Paragraph with &copy; entity.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <p></p>\n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Quotes & Ampersand',
          lectureTopic: 'HTML Entities',
          body: 'Use `&quot;`, `&amp;`, and `&lt;` correctly in one sentence inside `<p>`.',
          exampleOut: 'Entities for quotes, ampersand, less-than.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Entity Cheat Sheet',
          lectureTopic: 'HTML Entities',
          body: 'Small `<dl>` listing 3 entities (`&copy;`, `&reg;`, `&nbsp;`) with `<dt>`/`<dd>` explanations.',
          exampleOut: 'Definition list explaining entities.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlAria() => _lectureSet(
        lectureTopic: 'Accessibility (ARIA)',
        langLabel: 'HTML',
        easy: _task(
          title: 'aria-label Button',
          lectureTopic: 'Accessibility (ARIA)',
          body: 'Icon button with `aria-label="Search"` and no visible text.',
          exampleOut: 'Button with aria-label Search.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <button></button>\n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'aria-hidden Decor',
          lectureTopic: 'Accessibility (ARIA)',
          body: 'Decorative icon with `aria-hidden="true"` next to visible text label.',
          exampleOut: 'Decorative element hidden from AT; text visible.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Live Region',
          lectureTopic: 'Accessibility (ARIA)',
          body: 'Add `<div role="status" aria-live="polite">` for form status messages.',
          exampleOut: 'Status region with role and aria-live.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlResponsiveImages() => _lectureSet(
        lectureTopic: 'Responsive Images',
        langLabel: 'HTML',
        easy: _task(
          title: 'Width 100%',
          lectureTopic: 'Responsive Images',
          body: 'Image with `style="max-width:100%; height:auto;"` and descriptive alt.',
          exampleOut: 'Responsive img styling inline.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  \n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'srcset Basics',
          lectureTopic: 'Responsive Images',
          body: 'Use `srcset` with two widths on an `<img>` plus `sizes` attribute.',
          exampleOut: 'img with srcset and sizes.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'picture Element',
          lectureTopic: 'Responsive Images',
          body: '`<picture>` with `<source media="(min-width: 800px)">` and fallback `<img>`.',
          exampleOut: 'picture element with source and img.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlCanvas() => _lectureSet(
        lectureTopic: 'Canvas',
        langLabel: 'HTML',
        easy: _task(
          title: 'Canvas Element',
          lectureTopic: 'Canvas',
          body: 'Add `<canvas id="board" width="300" height="150">` with fallback text.',
          exampleOut: 'canvas with id, dimensions, fallback.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  \n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Canvas + Script Stub',
          lectureTopic: 'Canvas',
          body: 'Canvas element and `<script>` comment describing how you would draw a rectangle (no JS execution needed).',
          exampleOut: 'canvas plus script comment for drawing.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <canvas id="c" width="200" height="100"></canvas>\n  <script>\n    // \n  </script>\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Accessible Canvas',
          lectureTopic: 'Canvas',
          body: 'Canvas with `role="img"` and `aria-label` describing the graphic.',
          exampleOut: 'Canvas with role img and aria-label.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlSvg() => _lectureSet(
        lectureTopic: 'SVG',
        langLabel: 'HTML',
        easy: _task(
          title: 'Inline SVG Circle',
          lectureTopic: 'SVG',
          body: 'Inline `<svg>` with `<circle cx="50" cy="50" r="40" fill="green">`.',
          exampleOut: 'svg containing circle.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  \n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'SVG Rectangle',
          lectureTopic: 'SVG',
          body: 'SVG viewBox `0 0 100 100` with `<rect>` and `<title>` for accessibility.',
          exampleOut: 'svg with rect and title.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'SVG Icon',
          lectureTopic: 'SVG',
          body: 'Small icon SVG with `aria-hidden="true"` embedded next to a labeled button.',
          exampleOut: 'Decorative svg with labeled button.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlStorage() => _lectureSet(
        lectureTopic: 'Web Storage',
        langLabel: 'HTML',
        easy: _task(
          title: 'Storage Script Comment',
          lectureTopic: 'Web Storage',
          body: 'HTML page with script comments explaining `localStorage.setItem("theme","dark")`.',
          exampleOut: 'Script documents localStorage usage.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <script>\n    // \n  </script>\n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'sessionStorage Note',
          lectureTopic: 'Web Storage',
          body: 'Comment block comparing localStorage vs sessionStorage from the lecture.',
          exampleOut: 'Comments compare both storage types.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <script>\n    /* \n     */\n  </script>\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Storage Keys',
          lectureTopic: 'Web Storage',
          body: 'Script stub with functions `saveProgress()` and `loadProgress()` using localStorage (pseudocode OK in comments).',
          exampleOut: 'Two named functions documented for storage.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <script>\n\n  </script>\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlGeolocation() => _lectureSet(
        lectureTopic: 'Geolocation',
        langLabel: 'HTML',
        easy: _task(
          title: 'Geolocation API',
          lectureTopic: 'Geolocation',
          body: 'Script comment explaining `navigator.geolocation.getCurrentPosition` callback pattern.',
          exampleOut: 'Comment describes geolocation API.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <script>\n    // \n  </script>\n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Error Handling',
          lectureTopic: 'Geolocation',
          body: 'Comment block for success vs error callbacks when location is denied.',
          exampleOut: 'Documents error handling for geolocation.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <script>\n\n  </script>\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Location UI',
          lectureTopic: 'Geolocation',
          body: 'Button **Get Location** plus empty `<p id="coords">` and script comment tying them together.',
          exampleOut: 'Button, output element, and script plan.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlDragDrop() => _lectureSet(
        lectureTopic: 'Drag & Drop',
        langLabel: 'HTML',
        easy: _task(
          title: 'Draggable Item',
          lectureTopic: 'Drag & Drop',
          body: 'Element with `draggable="true"` and id `drag-item`.',
          exampleOut: 'draggable true on element.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  <div></div>\n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'Drop Zone',
          lectureTopic: 'Drag & Drop',
          body: 'Draggable div + drop zone div with id `drop-zone` (comment event listeners).',
          exampleOut: 'Draggable and drop target markup.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Drag List',
          lectureTopic: 'Drag & Drop',
          body: 'Three draggable list items inside `<ul>` with data-id attributes.',
          exampleOut: 'ul with three draggable li items.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlBestPractices() => _lectureSet(
        lectureTopic: 'HTML Best Practices',
        langLabel: 'HTML',
        easy: _task(
          title: 'Valid Document',
          lectureTopic: 'HTML Best Practices',
          body: 'Minimal valid HTML5 page following lecture best practices: doctype, lang, charset, title, one h1.',
          exampleOut: 'Valid accessible minimal page.',
          starter: '<!DOCTYPE html>\n<html>\n\n</html>\n',
        ),
        medium: _task(
          title: 'Semantic Best Practices',
          lectureTopic: 'HTML Best Practices',
          body: 'Page using semantic tags, alt on images, labels on inputs — no deprecated tags.',
          exampleOut: 'Semantic, accessible markup.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'Production-Ready Stub',
          lectureTopic: 'HTML Best Practices',
          body: 'Complete study landing page skeleton applying all major HTML best practices from the lecture.',
          exampleOut: 'Production-style HTML skeleton.',
          starter: '<!DOCTYPE html>\n<html lang="en">\n<head>\n  <meta charset="UTF-8">\n  <meta name="viewport" content="width=device-width, initial-scale=1">\n  <title></title>\n</head>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _htmlGeneric() => _lectureSet(
        lectureTopic: 'HTML',
        langLabel: 'HTML',
        easy: _task(
          title: 'HTML Exercise',
          lectureTopic: 'this HTML topic',
          body: 'Apply the main concept from your lecture in a short HTML snippet.',
          exampleOut: 'Markup demonstrates the lecture concept.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n  \n</body>\n</html>\n',
        ),
        medium: _task(
          title: 'HTML Practice',
          lectureTopic: 'this HTML topic',
          body: 'Build a small example page section using the syntax rules from the lecture.',
          exampleOut: 'Valid HTML demonstrating the topic.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
        hard: _task(
          title: 'HTML Challenge',
          lectureTopic: 'this HTML topic',
          body: 'Combine this topic with one related concept from the same lecture track.',
          exampleOut: 'Complete example using lecture concepts.',
          starter: '<!DOCTYPE html>\n<html>\n<body>\n\n</body>\n</html>\n',
        ),
      );

  static _PracticeTaskSet _cssIntro() => _lectureSet(
        lectureTopic: 'Introduction to CSS',
        langLabel: 'CSS',
        easy: _task(
          title: 'Element Selector',
          lectureTopic: 'Introduction to CSS',
          body: 'Style all `<p>` elements with `color: navy;` in a `<style>` block.',
          exampleOut: 'CSS rule for p { color: navy; }',
          starter: '<style>\n  \n</style>\n<p>Hello CSS</p>\n',
          lang: 'css',
        ),
        medium: _task(
          title: 'Class Selector',
          lectureTopic: 'Introduction to CSS',
          body: 'Create `.highlight { background: yellow; }` and apply class to a span.',
          exampleOut: 'Class rule and HTML using class.',
          starter: '<style>\n\n</style>\n<p>Learn <span>CSS</span> today.</p>\n',
          lang: 'css',
        ),
        hard: _task(
          title: 'Linked Stylesheet',
          lectureTopic: 'Introduction to CSS',
          body: 'HTML with `<link rel="stylesheet" href="styles.css">` plus inline comment listing 3 rules for styles.css.',
          exampleOut: 'link tag and documented rules.',
          starter: '<!DOCTYPE html>\n<html>\n<head>\n  \n</head>\n<body><h1>CSS</h1></body>\n</html>\n',
          lang: 'html',
        ),
      );

  static _PracticeTaskSet _cssSelectors() => _lectureSet(
        lectureTopic: 'Selectors',
        langLabel: 'CSS',
        easy: _task(
          title: 'ID Selector',
          lectureTopic: 'Selectors',
          body: 'Style `#main-title { font-size: 2rem; }`',
          exampleOut: 'ID selector rule.',
          starter: '/* Practice Selectors */\n#main-title {\n  \n}\n',
          lang: 'css',
        ),
        medium: _task(
          title: 'Descendant Selector',
          lectureTopic: 'Selectors',
          body: 'Rule `nav a { text-decoration: none; }`',
          exampleOut: 'Descendant combinator rule.',
          starter: '/* nav links */\n',
          lang: 'css',
        ),
        hard: _task(
          title: 'Pseudo-class',
          lectureTopic: 'Selectors',
          body: '`:hover` and `:focus` styles for `.btn`',
          exampleOut: 'Button pseudo-class rules.',
          starter: '.btn {\n  padding: 8px 12px;\n}\n',
          lang: 'css',
        ),
      );

  static _PracticeTaskSet _cssFlexbox() => _lectureSet(
        lectureTopic: 'Flexbox',
        langLabel: 'CSS',
        easy: _task(
          title: 'Flex Container',
          lectureTopic: 'Flexbox',
          body: '`.row { display: flex; gap: 12px; }`',
          exampleOut: 'Flex container with gap.',
          starter: '/* Flexbox practice */\n.row {\n  \n}\n',
          lang: 'css',
        ),
        medium: _task(
          title: 'Justify Content',
          lectureTopic: 'Flexbox',
          body: 'Center items with `justify-content: center;` and `align-items: center;` on a 200px tall flex container.',
          exampleOut: 'Centered flex layout.',
          starter: '.center-box {\n  display: flex;\n  min-height: 200px;\n}\n',
          lang: 'css',
        ),
        hard: _task(
          title: 'Flex Navbar',
          lectureTopic: 'Flexbox',
          body: 'Navbar CSS: logo left, links right using flex `justify-content: space-between`.',
          exampleOut: 'Navbar flex layout.',
          starter: '.navbar {\n  display: flex;\n}\n',
          lang: 'css',
        ),
      );

  static _PracticeTaskSet _cssGrid() => _lectureSet(
        lectureTopic: 'Grid',
        langLabel: 'CSS',
        easy: _task(
          title: 'Grid Container',
          lectureTopic: 'Grid',
          body: '`.grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }`',
          exampleOut: 'Two-column grid.',
          starter: '.grid {\n  \n}\n',
          lang: 'css',
        ),
        medium: _task(
          title: 'Grid Areas',
          lectureTopic: 'Grid',
          body: 'Define `grid-template-areas` for header, main, footer layout.',
          exampleOut: 'Named grid areas.',
          starter: '.layout {\n  display: grid;\n}\n',
          lang: 'css',
        ),
        hard: _task(
          title: 'Responsive Grid',
          lectureTopic: 'Grid',
          body: '`repeat(auto-fit, minmax(200px, 1fr))` card grid.',
          exampleOut: 'Auto-fit responsive grid.',
          starter: '.cards {\n  display: grid;\n}\n',
          lang: 'css',
        ),
      );

  static _PracticeTaskSet _cssBoxModel() => _lectureSet(
        lectureTopic: 'Box Model',
        langLabel: 'CSS',
        easy: _task(
          title: 'Padding & Margin',
          lectureTopic: 'Box Model',
          body: '`.card { padding: 16px; margin: 12px; border: 1px solid #ccc; }`',
          exampleOut: 'Box model properties on .card.',
          starter: '.card {\n  \n}\n',
          lang: 'css',
        ),
        medium: _task(
          title: 'box-sizing',
          lectureTopic: 'Box Model',
          body: 'Universal `box-sizing: border-box` reset snippet.',
          exampleOut: 'border-box reset.',
          starter: '/* box model */\n',
          lang: 'css',
        ),
        hard: _task(
          title: 'Box Model Diagram',
          lectureTopic: 'Box Model',
          body: 'Comment block labeling content, padding, border, margin on `.demo`.',
          exampleOut: 'Annotated box model CSS.',
          starter: '.demo {\n  width: 200px;\n}\n',
          lang: 'css',
        ),
      );

  static _PracticeTaskSet _cssColors() => _lectureSet(
        lectureTopic: 'Colors',
        langLabel: 'CSS',
        easy: _task(
          title: 'Hex Color',
          lectureTopic: 'Colors',
          body: 'Set `background-color: #1a73e8;` on `.banner`',
          exampleOut: 'Hex background color.',
          starter: '.banner {\n  \n}\n',
          lang: 'css',
        ),
        medium: _task(
          title: 'RGB & HSL',
          lectureTopic: 'Colors',
          body: 'Same element with `color: rgb()` and border using `hsl()`.',
          exampleOut: 'rgb and hsl usage.',
          starter: '.text {\n}\n',
          lang: 'css',
        ),
        hard: _task(
          title: 'CSS Variables',
          lectureTopic: 'Colors',
          body: '`:root { --primary: #1a73e8; }` and use `var(--primary)` on buttons.',
          exampleOut: 'CSS custom properties for colors.',
          starter: ':root {\n  \n}\n',
          lang: 'css',
        ),
      );

  static _PracticeTaskSet _cssGeneric(String title) => _lectureSet(
        lectureTopic: title,
        langLabel: 'CSS',
        easy: _task(
          title: '$title — Easy',
          lectureTopic: title,
          body: 'Write CSS that demonstrates the core idea from your **$title** lecture.',
          exampleOut: 'CSS applies the lecture concept.',
          starter: '/* $title */\n',
          lang: 'css',
        ),
        medium: _task(
          title: '$title — Practice',
          lectureTopic: title,
          body: 'Create a small stylesheet section using syntax from the **$title** lesson.',
          exampleOut: 'Valid CSS for the topic.',
          starter: '/* Practice: $title */\n',
          lang: 'css',
        ),
        hard: _task(
          title: '$title — Challenge',
          lectureTopic: title,
          body: 'Combine **$title** with one related CSS concept from your lecture.',
          exampleOut: 'Complete CSS example for the topic.',
          starter: '/* Challenge: $title */\n',
          lang: 'css',
        ),
      );

  static _PracticeTaskSet _jsVariables(String langLabel) => _programmingGeneric('Variables', langLabel, 'javascript');
  static _PracticeTaskSet _jsFunctions(String langLabel) => _programmingGeneric('Functions', langLabel, 'javascript');
  static _PracticeTaskSet _jsArrays(String langLabel) => _programmingGeneric('Arrays', langLabel, 'javascript');
  static _PracticeTaskSet _jsLoops(String langLabel) => _programmingGeneric('Loops', langLabel, 'javascript');
  static _PracticeTaskSet _jsDom(String langLabel) => _lectureSet(
        lectureTopic: 'The DOM',
        langLabel: langLabel,
        easy: _task(
          title: 'Select Element',
          lectureTopic: 'The DOM',
          body: 'Use `document.getElementById("title")` and set `textContent` (in JS file).',
          exampleOut: 'getElementById and textContent.',
          starter: '// DOM practice\n',
          lang: 'javascript',
        ),
        medium: _task(
          title: 'querySelector',
          lectureTopic: 'The DOM',
          body: 'Select `.card` with querySelector and change a style property.',
          exampleOut: 'querySelector usage.',
          starter: '// \n',
          lang: 'javascript',
        ),
        hard: _task(
          title: 'Create Element',
          lectureTopic: 'The DOM',
          body: 'createElement, appendChild, and classList.add workflow.',
          exampleOut: 'DOM creation APIs.',
          starter: '// \n',
          lang: 'javascript',
        ),
      );

  static _PracticeTaskSet _jsEvents(String langLabel) => _lectureSet(
        lectureTopic: 'Events',
        langLabel: langLabel,
        easy: _task(
          title: 'Click Listener',
          lectureTopic: 'Events',
          body: 'addEventListener("click", ...) on a button id `run`.',
          exampleOut: 'Click event listener.',
          starter: '// Events practice\n',
          lang: 'javascript',
        ),
        medium: _task(
          title: 'Form Submit',
          lectureTopic: 'Events',
          body: 'Prevent default on form submit and read input value.',
          exampleOut: 'submit handler with preventDefault.',
          starter: '// \n',
          lang: 'javascript',
        ),
        hard: _task(
          title: 'Keyboard Event',
          lectureTopic: 'Events',
          body: 'Listen for keydown on input and log key when Enter pressed.',
          exampleOut: 'keydown handler.',
          starter: '// \n',
          lang: 'javascript',
        ),
      );

  static _PracticeTaskSet _webGeneric(String title, String langLabel, String codeLang) => _lectureSet(
        lectureTopic: title,
        langLabel: langLabel,
        easy: _task(
          title: '$title — Warm-up',
          lectureTopic: title,
          body: 'Apply the main idea from your **$title** lecture in $langLabel.',
          exampleOut: 'Code demonstrates the lecture concept.',
          starter: _defaultStarter(codeLang, title),
          lang: codeLang,
        ),
        medium: _task(
          title: '$title — Apply',
          lectureTopic: title,
          body: 'Build a small example using syntax from the **$title** lesson.',
          exampleOut: 'Working example for the topic.',
          starter: _defaultStarter(codeLang, title),
          lang: codeLang,
        ),
        hard: _task(
          title: '$title — Challenge',
          lectureTopic: title,
          body: 'Solve a realistic mini-task using **$title** plus one related lecture concept.',
          exampleOut: 'Complete solution for the topic.',
          starter: _defaultStarter(codeLang, title),
          lang: codeLang,
        ),
      );

  static _PracticeTaskSet _programmingGeneric(String title, String langLabel, String codeLang) => _lectureSet(
        lectureTopic: title,
        langLabel: langLabel,
        easy: _task(
          title: '$title — Basics',
          lectureTopic: title,
          body:
              'From your **$title** lecture: write a short $langLabel program that demonstrates the core syntax '
              '(variables, output, or the main keyword from the lesson).',
          exampleOut: 'Program prints correct output using lecture concepts.',
          starter: _defaultStarter(codeLang, title),
          lang: codeLang,
          fn: 'main',
        ),
        medium: _task(
          title: '$title — Apply',
          lectureTopic: title,
          body: 'Solve a small exercise using **$title** rules from the lecture. Include at least one edge case in comments.',
          exampleOut: 'Correct output for sample input.',
          starter: _defaultStarter(codeLang, title),
          lang: codeLang,
          fn: 'solve',
        ),
        hard: _task(
          title: '$title — Challenge',
          lectureTopic: title,
          body: 'Combine **$title** with another concept from the same lecture track in one solution.',
          exampleOut: 'Complete solution handling multiple cases.',
          starter: _defaultStarter(codeLang, title),
          lang: codeLang,
          fn: 'solve',
        ),
      );

  static _PracticeTaskSet _lectureSet({
    required String lectureTopic,
    required String langLabel,
    required _PracticeTask easy,
    required _PracticeTask medium,
    required _PracticeTask hard,
  }) {
    return _PracticeTaskSet(
      easy: easy.copyWith(lectureTopic: lectureTopic, langLabel: langLabel),
      medium: medium.copyWith(lectureTopic: lectureTopic, langLabel: langLabel),
      hard: hard.copyWith(lectureTopic: lectureTopic, langLabel: langLabel),
    );
  }

  static _PracticeTask _task({
    required String title,
    required String lectureTopic,
    required String body,
    required String exampleOut,
    String? starter,
    List<String>? extraConstraints,
    String lang = 'html',
    String fn = 'completeExercise',
  }) {
    return _PracticeTask(
      title: title,
      lectureTopic: lectureTopic,
      body: body,
      exampleOut: exampleOut,
      starter: starter,
      extraConstraints: extraConstraints,
      lang: lang,
      functionName: fn,
    );
  }

  static String _defaultStarter(String codeLang, String title) {
    if (codeLang == 'html') {
      return '<!DOCTYPE html>\n<html>\n<body>\n  <!-- $title -->\n</body>\n</html>\n';
    }
    if (codeLang == 'css') return '/* $title */\n';
    if (codeLang == 'javascript' || codeLang == 'typescript') return '// $title\n';
    if (codeLang == 'python3') return '# $title\n\ndef main():\n    pass\n\nmain()\n';
    if (codeLang == 'java') {
      return 'public class Main {\n    public static void main(String[] args) {\n        // $title\n    }\n}\n';
    }
    return '// $title\n';
  }

  static String _slug(String text) =>
      text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
}

class _PracticeTaskSet {
  const _PracticeTaskSet({required this.easy, required this.medium, required this.hard});

  final _PracticeTask easy;
  final _PracticeTask medium;
  final _PracticeTask hard;

  _PracticeTask forDifficulty(String difficulty) => switch (difficulty) {
        'Hard' => hard,
        'Medium' => medium,
        _ => easy,
      };
}

class _PracticeTask {
  const _PracticeTask({
    required this.title,
    required this.lectureTopic,
    required this.body,
    required this.exampleOut,
    this.starter,
    this.extraConstraints,
    this.lang = 'html',
    this.functionName = 'completeExercise',
    this.langLabel = 'HTML',
  });

  final String title;
  final String lectureTopic;
  final String body;
  final String exampleOut;
  final String? starter;
  final List<String>? extraConstraints;
  final String lang;
  final String functionName;
  final String langLabel;

  _PracticeTask copyWith({required String lectureTopic, required String langLabel}) {
    return _PracticeTask(
      title: title,
      lectureTopic: lectureTopic,
      body: body.replaceAll('this HTML topic', lectureTopic),
      exampleOut: exampleOut,
      starter: starter,
      extraConstraints: extraConstraints,
      lang: lang,
      functionName: functionName,
      langLabel: langLabel,
    );
  }

  String get description =>
      '**Lecture topic: $lectureTopic**\n\n'
      'This practice question is based on what you learned in the lecture. $body\n\n'
      'Use only concepts from the **$lectureTopic** lesson — not unrelated algorithms.';

  List<LeetcodeExample> get examples => <LeetcodeExample>[
        LeetcodeExample(
          input: 'Your code / markup',
          output: exampleOut,
          explanation: 'Graded against the lecture objectives for $lectureTopic.',
        ),
      ];

  List<String> get constraintList => <String>[
        'Must reflect the $lectureTopic lecture',
        'Use $langLabel syntax covered in this lesson',
        ...?extraConstraints,
      ];

  Map<String, String> starterFor(String codeLang) {
    final String code = starter ?? CsCurriculumPracticeBank._defaultStarter(codeLang, lectureTopic);
    return <String, String>{codeLang: code};
  }

  List<LeetcodeHiddenTest> hiddenFor(String difficulty) {
    if (difficulty == 'Easy') return const <LeetcodeHiddenTest>[];
    return <LeetcodeHiddenTest>[
      LeetcodeHiddenTest(
        input: 'Lecture alignment check',
        output: 'Solution uses $lectureTopic concepts taught in the lecture',
      ),
    ];
  }
}
