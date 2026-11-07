/// Turns resume text into profile fields. Everything returned is copied from
/// the text — nothing is inferred or invented — so a student can trust and
/// correct what they see.
library;

import 'dart:typed_data';

import '../model/career_models.dart';
import 'docx_text.dart';
import 'pdf_text.dart';

/// A scanned resume or a photo: there is no text layer, only page pictures,
/// which must be read (OCR) before the text can be parsed.
class ScannedResume implements Exception {
  const ScannedResume(this.pages, this.format);
  final List<ResumeImage> pages;

  /// 'pdf' or 'image'.
  final String format;
}

bool _isJpeg(Uint8List b) => b.length > 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF;
bool _isPng(Uint8List b) => b.length > 8 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47;

/// Reads the text of an uploaded resume file.
/// Throws [FormatException] with a message the student can act on, or
/// [ScannedResume] when the file is a scan or photo that needs reading.
String extractResumeText(String fileName, Uint8List bytes) {
  final String lower = fileName.toLowerCase();
  final bool isPdf = bytes.length > 4 && bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46;
  final bool isZip = bytes.length > 4 && bytes[0] == 0x50 && bytes[1] == 0x4b;
  final String text;
  if (isPdf) {
    text = extractPdfText(bytes);
  } else if (isZip && (lower.endsWith('.docx') || !lower.endsWith('.pdf'))) {
    text = extractDocxText(bytes);
  } else if (_isJpeg(bytes) || _isPng(bytes)) {
    final ResumeImage? page = resumeImageFromFile(bytes);
    if (page == null) throw const FormatException('This picture could not be opened. Take the photo again or upload a PDF or .docx.');
    throw ScannedResume(<ResumeImage>[page], 'image');
  } else if (lower.endsWith('.doc')) {
    throw const FormatException('Old .doc files are not supported. Save it as .docx or PDF and upload again.');
  } else {
    throw const FormatException('Upload a PDF, a Word .docx file, or a photo (JPG or PNG) of your resume.');
  }
  final String clean = normaliseText(text);
  if (clean.replaceAll(RegExp(r'\s'), '').length < 60) {
    if (isPdf) {
      final List<ResumeImage> pages;
      try {
        pages = extractPdfScanImages(bytes);
      } on ScanImageUnsupported catch (e) {
        throw FormatException(e.message);
      }
      if (pages.isNotEmpty) throw ScannedResume(pages, 'pdf');
    }
    throw const FormatException('No readable text was found. Export your resume from Word or Google Docs as a PDF or .docx, or upload a clear photo of it.');
  }
  return clean;
}

String normaliseText(String t) => t
    .replaceAll('\r\n', '\n')
    .replaceAll('\r', '\n')
    .replaceAll(' ', ' ')
    .replaceAll(RegExp(r'[ \t]+'), ' ')
    .split('\n')
    .map((String l) => l.trim())
    .join('\n')
    .replaceAll(RegExp(r'\n{3,}'), '\n\n')
    .trim();

enum ResumeSection { header, summary, education, experience, skills, projects, certifications, achievements, other }

const Map<ResumeSection, List<String>> _headings = <ResumeSection, List<String>>{
  ResumeSection.summary: <String>['summary', 'professional summary', 'profile', 'professional profile', 'objective', 'career objective', 'about me', 'personal statement', 'about'],
  ResumeSection.education: <String>['education', 'education and training', 'academic background', 'academic qualifications', 'qualifications', 'education & training'],
  ResumeSection.experience: <String>[
    'experience', 'work experience', 'professional experience', 'employment', 'employment history', 'work history', 'relevant experience',
    'clinical experience', 'clinical placements', 'placements', 'internships', 'internship experience', 'volunteer experience', 'leadership experience',
    'research experience', 'teaching experience', 'legal experience', 'professional history', 'career history',
  ],
  ResumeSection.skills: <String>['skills', 'technical skills', 'key skills', 'core skills', 'core competencies', 'competencies', 'skills and abilities', 'technologies', 'tools', 'languages', 'skills & tools', 'technical proficiencies', 'clinical skills', 'software'],
  ResumeSection.projects: <String>['projects', 'academic projects', 'personal projects', 'selected projects', 'research', 'research projects', 'portfolio', 'publications'],
  ResumeSection.certifications: <String>['certifications', 'certification', 'certificates', 'licenses', 'licences', 'licenses and certifications', 'licenses & certifications', 'certifications and licenses', 'training', 'courses'],
  ResumeSection.achievements: <String>['achievements', 'awards', 'honors', 'honours', 'awards and honors', 'awards & honors', 'accomplishments', 'awards and achievements', 'honors and awards'],
};

/// The section a line is a heading for, or null.
ResumeSection? headingOf(String line) {
  final String l = line.toLowerCase().replaceAll(RegExp(r'[:\-–—|•]+$'), '').trim();
  if (l.isEmpty || l.length > 40) return null;
  for (final MapEntry<ResumeSection, List<String>> e in _headings.entries) {
    if (e.value.contains(l)) return e.key;
  }
  return null;
}

final RegExp emailPattern = RegExp(r'[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}');
final RegExp phonePattern = RegExp(r'(\+?\(?\d[\d\s().\-]{7,}\d)');
final RegExp _link = RegExp(r'((?:https?://)?(?:www\.)?(?:linkedin\.com|github\.com|gitlab\.com|behance\.net)/[^\s|,]+)', caseSensitive: false);
final RegExp _bullet = RegExp(r'^[•·▪●◦\-*–]\s*');
final RegExp _yearish = RegExp(r'\b(19|20)\d{2}\b|\bpresent\b|\bcurrent\b', caseSensitive: false);

bool _isBullet(String l) => _bullet.hasMatch(l);

/// Verbs that open accomplishment bullets ("Built…", "Led…").
const List<String> actionVerbs = <String>[
  'achieved', 'administered', 'analysed', 'analyzed', 'assessed', 'assisted', 'automated', 'built', 'collaborated', 'completed', 'conducted',
  'coordinated', 'created', 'cut', 'delivered', 'designed', 'developed', 'documented', 'drafted', 'drove', 'edited', 'established', 'evaluated',
  'found', 'grew', 'handled', 'identified', 'implemented', 'improved', 'increased', 'launched', 'led', 'maintained', 'managed', 'mentored',
  'monitored', 'negotiated', 'organised', 'organized', 'performed', 'planned', 'prepared', 'presented', 'processed', 'produced', 'published',
  'recorded', 'reduced', 'took', 'interpreted', 'ran', 'tutored', 'examined', 'treated', 'cared', 'served', 'answered', 'operated', 'calculated', 'measured', 'cleaned', 'taught', 'translated', 'reconciled', 'researched', 'resolved', 'reviewed', 'shipped', 'streamlined', 'supported', 'taught', 'tested', 'trained', 'wrote',
];

bool startsWithActionVerb(String l) {
  final String w = _unbullet(l).split(RegExp(r'\s+')).first.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  return actionVerbs.contains(w);
}
String _unbullet(String l) => l.replaceFirst(_bullet, '').trim();

/// Groups a section's lines into entries: a non-bullet line starts an entry,
/// bullets (and short continuation lines) belong to the entry above.
List<String> groupEntries(List<String> lines) {
  final List<String> out = <String>[];
  String? head;
  final List<String> detail = <String>[];
  void flush() {
    if (head != null) out.add(detail.isEmpty ? head! : '$head — ${detail.join('; ')}');
    head = null;
    detail.clear();
  }

  for (final String raw in lines) {
    final String l = raw.trim();
    if (l.isEmpty) continue;
    if (head != null && (_isBullet(l) || (startsWithActionVerb(l) && !_yearish.hasMatch(l) && _yearish.hasMatch(head!)) || (detail.isNotEmpty && startsWithActionVerb(l) && !_yearish.hasMatch(l)))) {
      detail.add(_unbullet(l));
    } else if (head != null && !_yearish.hasMatch(l) && !_isBullet(l) && l.length < 160 && RegExp(r'^[a-z(]').hasMatch(l)) {
      // A wrapped line that continues the previous one.
      if (detail.isEmpty) {
        head = '$head $l';
      } else {
        detail[detail.length - 1] = '${detail.last} $l';
      }
    } else {
      flush();
      head = _unbullet(l);
    }
  }
  flush();
  return out;
}

List<String> splitSkills(List<String> lines) {
  final List<String> out = <String>[];
  for (final String l in lines) {
    String line = _unbullet(l);
    // "Languages: Python, Java" → keep the items, drop the label.
    final int colon = line.indexOf(':');
    if (colon > 0 && colon < 30) line = line.substring(colon + 1);
    for (final String part in line.split(RegExp(r'[,;|•·▪]|\s{2,}|\s/\s'))) {
      final String s = part.trim().replaceAll(RegExp(r'\.$'), '');
      if (s.isEmpty || s.length > 40 || s.split(' ').length > 5) continue;
      if (!out.any((String x) => x.toLowerCase() == s.toLowerCase())) out.add(s);
    }
  }
  return out;
}

/// Splits the text into sections and reads the profile fields.
ParsedResume parseResume(String text) {
  final List<String> lines = normaliseText(text).split('\n');
  final Map<ResumeSection, List<String>> sections = <ResumeSection, List<String>>{};
  ResumeSection current = ResumeSection.header;
  for (final String l in lines) {
    final ResumeSection? h = headingOf(l);
    if (h != null) {
      current = h;
      sections.putIfAbsent(h, () => <String>[]);
      continue;
    }
    (sections[current] ??= <String>[]).add(l);
  }
  final List<String> header = (sections[ResumeSection.header] ?? <String>[]).where((String l) => l.isNotEmpty).toList();
  final String email = emailPattern.firstMatch(text)?.group(0) ?? '';
  String phone = '';
  for (final RegExpMatch m in phonePattern.allMatches(header.join('\n').isEmpty ? text : header.join('\n'))) {
    final String digits = m[1]!.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10 && digits.length <= 15 && !RegExp(r'^(19|20)\d{2}(19|20)\d{2}$').hasMatch(digits)) {
      phone = m[1]!.trim();
      break;
    }
  }
  String name = '';
  String headline = '';
  for (final String l in header) {
    final bool contact = emailPattern.hasMatch(l) || phonePattern.hasMatch(l) || _link.hasMatch(l);
    if (name.isEmpty) {
      if (!contact && RegExp(r"^[A-Za-zÀ-ÿ'’.\- ]{3,60}$").hasMatch(l) && l.split(RegExp(r'\s+')).length >= 2 && l.split(RegExp(r'\s+')).length <= 5) {
        name = l;
      }
      continue;
    }
    if (!contact && headline.isEmpty && l.length >= 6 && l.length <= 120) headline = l;
  }
  final List<String> summaryLines = sections[ResumeSection.summary] ?? <String>[];
  return ParsedResume(
    name: name,
    email: email,
    phone: phone,
    headline: headline,
    summary: summaryLines.where((String l) => l.isNotEmpty).join(' '),
    education: groupEntries(sections[ResumeSection.education] ?? <String>[]),
    experience: groupEntries(sections[ResumeSection.experience] ?? <String>[]),
    skills: splitSkills(sections[ResumeSection.skills] ?? <String>[]),
    projects: groupEntries(sections[ResumeSection.projects] ?? <String>[]),
    certifications: groupEntries(sections[ResumeSection.certifications] ?? <String>[]),
    achievements: groupEntries(sections[ResumeSection.achievements] ?? <String>[]),
    links: <String>{for (final RegExpMatch m in _link.allMatches(text)) m[1]!}.toList(),
  );
}

ResumeEntry _entry(String s) {
  final int dash = s.indexOf(' — ');
  if (dash > 0) return ResumeEntry(heading: s.substring(0, dash), detail: s.substring(dash + 3));
  final int comma = s.indexOf(', ');
  if (comma > 0 && comma < 80) return ResumeEntry(heading: s.substring(0, comma), detail: s.substring(comma + 2));
  return ResumeEntry(heading: s, detail: '');
}

/// Copies confirmed fields from an upload into the student's resume, keeping
/// the portfolio projects they already attached.
Resume resumeFromParsed(ParsedResume p, Resume current, int day) => Resume(
      fullName: p.name.isNotEmpty ? p.name : current.fullName,
      email: p.email.isNotEmpty ? p.email : current.email,
      phone: p.phone.isNotEmpty ? p.phone : current.phone,
      headline: p.headline.isNotEmpty ? p.headline : current.headline,
      summary: p.summary.isNotEmpty ? p.summary : current.summary,
      education: p.education.map(_entry).toList(),
      experience: p.experience.map(_entry).toList(),
      skills: p.skills,
      projects: p.projects.map(_entry).toList(),
      certifications: p.certifications,
      achievements: p.achievements,
      projectIds: current.projectIds,
      updatedDay: day,
    );
