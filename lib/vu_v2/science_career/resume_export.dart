import 'dart:convert';
import 'dart:typed_data';

import 'science_career_content.dart';
import 'science_career_progress.dart';

/// Build downloadable résumé files from Project Lab data.
abstract final class ResumeExport {
  static String fileBaseName(ScienceCareerProgress progress) {
    final String name = progress.resumeProfile.fullName.trim();
    if (name.isEmpty) return 'GradeGlow_Resume';
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  /// Classic teal/serif résumé as HTML (open in browser → Print → Save as PDF).
  static Uint8List buildHtml(ScienceCareerProgress progress) {
    final ResumeProfile r = progress.resumeProfile;
    final ScienceMajor major = ScienceMajors.byId(progress.majorId);
    final String title = r.fullName.trim().isNotEmpty
        ? _esc(r.fullName.trim().toUpperCase())
        : _esc('${major.title.toUpperCase()} MAJOR RÉSUMÉ');
    final String contact = <String>[
      if (r.location.trim().isNotEmpty) _esc(r.location.trim()) else 'City, ST',
      if (r.email.trim().isNotEmpty)
        _esc(r.email.trim())
      else
        'your.email@email.com',
      if (r.phone.trim().isNotEmpty) _esc(r.phone.trim()) else '(555) 000-0000',
      if (r.githubUrl.trim().isNotEmpty) _esc(r.githubUrl.trim()),
    ].join(' &nbsp;|&nbsp; ');
    final String summary = r.summary.trim().isNotEmpty
        ? _esc(r.summary.trim())
        : _esc(
            'Motivated ${major.title.toLowerCase()} student seeking a '
            '${r.targetRole.trim().isEmpty ? 'junior software engineering' : r.targetRole.toLowerCase()} role.',
          );
    final StringBuffer projects = StringBuffer();
    if (progress.portfolioProjects.isEmpty) {
      projects.writeln(
        '<p class="mute"><em>Add projects in Project Lab to include them here.</em></p>',
      );
    } else {
      for (final PortfolioProject p in progress.portfolioProjects) {
        projects.writeln('<div class="entry">');
        projects.writeln('<div>${_esc(p.title)}</div>');
        projects.writeln(
          '<div class="bold">${_esc(p.tech.isNotEmpty ? p.tech.join(', ') : 'Personal / Course Project')}</div>',
        );
        if (p.githubUrl.isNotEmpty || p.liveUrl.isNotEmpty) {
          projects.writeln(
            '<div class="mute"><em>${_esc(<String>[
                  if (p.githubUrl.isNotEmpty) p.githubUrl,
                  if (p.liveUrl.isNotEmpty) p.liveUrl,
                ].join('  •  '))}</em></div>',
          );
        }
        projects.writeln('<ul>');
        for (final String b in p.effectiveBullets) {
          projects.writeln('<li>${_esc(b)}</li>');
        }
        projects.writeln('</ul></div>');
      }
    }
    final List<String> exp = _lines(r.experience);
    final String expHtml = exp.isEmpty
        ? ''
        : '<h2>Relevant Experience</h2><ul>${exp.map((String e) => '<li>${_esc(e)}</li>').join()}</ul>';
    final Set<String> skills = <String>{
      ...progress.skills,
      ...r.extraSkills,
      for (final PortfolioProject p in progress.portfolioProjects) ...p.tech,
    };
    final String skillsHtml = skills.isEmpty
        ? ''
        : '<h2>Skills</h2><ul>${skills.take(12).map((String s) => '<li>${_esc(s)}</li>').join()}</ul>';

    final String html = '''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<title>$title</title>
<style>
  body { font-family: Georgia, "Times New Roman", serif; color: #1c1c1c; max-width: 760px; margin: 32px auto; padding: 0 24px; line-height: 1.45; background: #fffef8; }
  h1 { color: #6B8F9A; font-size: 22px; letter-spacing: 1.1px; text-align: center; margin: 0; }
  .sub { text-align: center; color: #5c5c5c; font-style: italic; font-size: 12px; margin-top: 4px; }
  .contact { text-align: center; font-size: 12px; margin-top: 8px; }
  hr { border: none; border-top: 1.5px solid #6B8F9A; margin: 14px 0; }
  h2 { color: #6B8F9A; font-size: 16px; margin: 18px 0 8px; border-bottom: 1px solid #c5d4d9; padding-bottom: 2px; }
  .bold { font-weight: 700; }
  .mute { color: #5c5c5c; font-size: 12px; }
  ul { margin: 4px 0 0 18px; padding: 0; }
  li { margin-bottom: 3px; font-size: 13px; }
  .entry { margin-bottom: 12px; }
  .hint { text-align: center; color: #94a3b8; font-size: 11px; margin-top: 28px; }
  @media print {
    body { margin: 0; background: white; }
    .hint { display: none; }
  }
</style>
</head>
<body>
  <h1>$title</h1>
  ${r.fullName.trim().isNotEmpty ? '<div class="sub">${_esc(major.title)} Major</div>' : ''}
  <div class="contact">$contact</div>
  <hr/>
  <p style="text-align:justify;font-size:13px;">$summary</p>
  $expHtml
  <h2>Projects</h2>
  $projects
  <h2>Education</h2>
  <div class="bold">${_esc((r.university.trim().isNotEmpty ? r.university : (r.education.trim().isNotEmpty ? r.education.split('\n').first : 'Your University')).toUpperCase())}</div>
  <div style="font-style:italic;">${_esc(r.degree.trim().isNotEmpty ? r.degree : 'Bachelor of Science in ${major.title}')}</div>
  <div style="font-style:italic;">${_esc(r.gradYear.trim().isNotEmpty ? 'Expected graduation: ${r.gradYear}' : 'Expected graduation: 20XX')}</div>
  <p><strong>Relevant coursework:</strong> ${_esc(r.coursework.trim().isNotEmpty ? r.coursework.trim() : 'Data Structures, Algorithms, Software Engineering, Databases')}</p>
  $skillsHtml
  <p class="hint">Tip: open this file in your browser → Print → Save as PDF</p>
</body>
</html>''';
    return Uint8List.fromList(utf8.encode(html));
  }

  static Uint8List buildTxt(ScienceCareerProgress progress) {
    final ResumeProfile r = progress.resumeProfile;
    final ScienceMajor major = ScienceMajors.byId(progress.majorId);
    final StringBuffer b = StringBuffer();
    b.writeln(
      r.fullName.trim().isNotEmpty
          ? r.fullName.trim().toUpperCase()
          : '${major.title.toUpperCase()} MAJOR RÉSUMÉ',
    );
    b.writeln(
      <String>[
        if (r.location.trim().isNotEmpty) r.location.trim() else 'City, ST',
        if (r.email.trim().isNotEmpty) r.email.trim() else 'your.email@email.com',
        if (r.phone.trim().isNotEmpty) r.phone.trim() else '(555) 000-0000',
        if (r.githubUrl.trim().isNotEmpty) r.githubUrl.trim(),
      ].join(' | '),
    );
    b.writeln('');
    b.writeln(
      r.summary.trim().isNotEmpty
          ? r.summary.trim()
          : 'Motivated ${major.title.toLowerCase()} student seeking a '
              '${r.targetRole.trim().isEmpty ? 'junior software engineering' : r.targetRole.toLowerCase()} role.',
    );
    final List<String> exp = _lines(r.experience);
    if (exp.isNotEmpty) {
      b.writeln('');
      b.writeln('RELEVANT EXPERIENCE');
      for (final String e in exp) {
        b.writeln('• $e');
      }
    }
    b.writeln('');
    b.writeln('PROJECTS');
    if (progress.portfolioProjects.isEmpty) {
      b.writeln('(Add projects in Project Lab)');
    } else {
      for (final PortfolioProject p in progress.portfolioProjects) {
        b.writeln(p.title);
        if (p.tech.isNotEmpty) b.writeln(p.tech.join(', '));
        for (final String bullet in p.effectiveBullets) {
          b.writeln('• $bullet');
        }
        b.writeln('');
      }
    }
    b.writeln('EDUCATION');
    b.writeln(
      (r.university.trim().isNotEmpty
              ? r.university
              : (r.education.trim().isNotEmpty
                  ? r.education.split('\n').first
                  : 'Your University'))
          .toUpperCase(),
    );
    b.writeln(
      r.degree.trim().isNotEmpty
          ? r.degree
          : 'Bachelor of Science in ${major.title}',
    );
    b.writeln(
      r.gradYear.trim().isNotEmpty
          ? 'Expected graduation: ${r.gradYear}'
          : 'Expected graduation: 20XX',
    );
    b.writeln(
      'Relevant coursework: ${r.coursework.trim().isNotEmpty ? r.coursework.trim() : 'Data Structures, Algorithms, Software Engineering, Databases'}',
    );
    final Set<String> skills = <String>{
      ...progress.skills,
      ...r.extraSkills,
      for (final PortfolioProject p in progress.portfolioProjects) ...p.tech,
    };
    if (skills.isNotEmpty) {
      b.writeln('');
      b.writeln('SKILLS');
      for (final String s in skills.take(12)) {
        b.writeln('• $s');
      }
    }
    return Uint8List.fromList(utf8.encode(b.toString()));
  }

  static List<String> _lines(String raw) => raw
      .split(RegExp(r'[\n•]+'))
      .map((String s) => s.trim().replaceFirst(RegExp(r'^[-*]\s*'), ''))
      .where((String s) => s.isNotEmpty)
      .toList();

  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
