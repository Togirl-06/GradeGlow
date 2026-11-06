import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/career_models.dart';
import '../model/content_models.dart';
import '../resume/resume_analysis.dart';
import '../store/career_sim_store.dart';
import 'career_centre.dart';
import 'common.dart';
import 'gg_kit.dart';

/// Picks a resume file from the device: (file name, bytes), or null if cancelled.
typedef ResumePicker = Future<(String, Uint8List)?> Function();

Future<(String, Uint8List)?> pickResumeFile() async {
  final FilePickerResult? r = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const <String>['pdf', 'docx'],
    withData: true,
  );
  final PlatformFile? f = r == null || r.files.isEmpty ? null : r.files.first;
  if (f == null || f.bytes == null) return null;
  return (f.name, f.bytes!);
}

/// My Resume: upload real PDF/DOCX resumes, check what was read, see the
/// quality score, and replace or delete files.
class ResumeHubScreen extends StatelessWidget {
  const ResumeHubScreen({super.key});

  /// Replaced in tests.
  static ResumePicker picker = pickResumeFile;

  static Future<void> upload(BuildContext context, {String? replaceId}) async {
    final CareerSimStore store = context.read<CareerSimStore>();
    final (String, Uint8List)? file = await picker();
    if (file == null || !context.mounted) return;
    final ResumeUpload? u = await runCareerAction<ResumeUpload>(context, () => store.uploadResume(file.$1, file.$2, replaceId: replaceId));
    if (u != null && context.mounted) {
      await Navigator.of(context).push(ggRoute<void>((_) => ResumeReviewScreen(uploadId: u.id)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final CareerProfile p = store.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('My Resume')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          SectionCard(
            title: 'Upload your resume',
            subtitle: 'PDF or Word (.docx), up to 5 MB. The text is read on your device; the file is stored privately in your account and only you can open it.',
            child: Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
              BusyButton(
                key: const ValueKey<String>('upload_resume'),
                label: p.resumeUploads.isEmpty ? 'Upload resume' : 'Upload another',
                icon: Icons.upload_file_rounded,
                onPressed: p.resumeUploads.length >= CareerSimStore.maxResumeUploads ? null : () => upload(context),
              ),
              OutlinedButton.icon(
                key: const ValueKey<String>('hub_edit_profile_resume'),
                onPressed: () => Navigator.of(context).push(ggRoute<void>((_) => const ResumeScreen())),
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Edit my profile resume'),
              ),
            ]),
          ),
          if (p.resumeUploads.isEmpty)
            Text('No resume uploaded yet. You can also build one in GradeGlow with "Edit my profile resume".', style: TextStyle(color: GG.mute)),
          for (final ResumeUpload u in p.resumeUploads)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Row(children: <Widget>[
                    Icon(u.format == 'pdf' ? Icons.picture_as_pdf_rounded : Icons.description_rounded, color: GG.accent),
                    const SizedBox(width: 8),
                    Expanded(child: Text(u.fileName, style: TextStyle(color: GG.ink, fontWeight: FontWeight.w800))),
                    if (p.defaultResumeId == u.id) const StatusChip('Default'),
                  ]),
                  const SizedBox(height: 4),
                  Text('Uploaded day ${u.uploadedDay} · ${(u.sizeBytes / 1024).round()} KB · quality ${resumeQuality(u.parsed).score}/100 · ${u.reviewed ? 'checked by you' : 'not yet checked'}',
                      style: TextStyle(color: GG.mute, fontSize: 12.5)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 6, children: <Widget>[
                    FilledButton.tonal(
                      key: ValueKey<String>('review_${u.id}'),
                      onPressed: () => Navigator.of(context).push(ggRoute<void>((_) => ResumeReviewScreen(uploadId: u.id))),
                      child: Text(u.reviewed ? 'View / edit' : 'Check extracted details'),
                    ),
                    OutlinedButton(key: ValueKey<String>('replace_${u.id}'), onPressed: () => upload(context, replaceId: u.id), child: const Text('Replace file')),
                    TextButton(
                      key: ValueKey<String>('delete_${u.id}'),
                      onPressed: () async {
                        final bool? yes = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext ctx) => AlertDialog(
                            title: const Text('Delete this resume?'),
                            content: Text('${u.fileName} and its stored file will be removed.'),
                            actions: <Widget>[
                              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                              FilledButton(key: const ValueKey<String>('confirm_delete_resume'), onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                            ],
                          ),
                        );
                        if (yes == true && context.mounted) await runCareerAction<void>(context, () => store.deleteResume(u.id), success: 'Resume deleted.');
                      },
                      child: const Text('Delete'),
                    ),
                  ]),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shows what was read from an uploaded resume as editable fields, with the
/// quality analysis. Nothing is added that is not in the file.
class ResumeReviewScreen extends StatefulWidget {
  const ResumeReviewScreen({super.key, required this.uploadId});
  final String uploadId;

  @override
  State<ResumeReviewScreen> createState() => _ResumeReviewScreenState();
}

class _ResumeReviewScreenState extends State<ResumeReviewScreen> {
  final Map<String, TextEditingController> _c = <String, TextEditingController>{};
  bool _init = false;

  TextEditingController _f(String k) => _c.putIfAbsent(k, TextEditingController.new);

  @override
  void dispose() {
    for (final TextEditingController c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _lines(String k) => _f(k).text.split('\n').map((String l) => l.trim()).where((String l) => l.isNotEmpty).toList();

  ParsedResume _current(ParsedResume base) => base.copyWith(
        name: _f('name').text.trim(),
        email: _f('email').text.trim(),
        phone: _f('phone').text.trim(),
        headline: _f('headline').text.trim(),
        summary: _f('summary').text.trim(),
        education: _lines('education'),
        experience: _lines('experience'),
        skills: _f('skills').text.split(RegExp(r'[,\n]')).map((String s) => s.trim()).where((String s) => s.isNotEmpty).toList(),
        projects: _lines('projects'),
        certifications: _lines('certifications'),
        achievements: _lines('achievements'),
      );

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final ResumeUpload? u = store.profile.resumeUpload(widget.uploadId);
    if (u == null) return const Scaffold(body: Center(child: Text('Resume not found')));
    if (!_init) {
      _init = true;
      final ParsedResume r = u.parsed;
      _f('name').text = r.name;
      _f('email').text = r.email;
      _f('phone').text = r.phone;
      _f('headline').text = r.headline;
      _f('summary').text = r.summary;
      _f('education').text = r.education.join('\n');
      _f('experience').text = r.experience.join('\n');
      _f('skills').text = r.skills.join(', ');
      _f('projects').text = r.projects.join('\n');
      _f('certifications').text = r.certifications.join('\n');
      _f('achievements').text = r.achievements.join('\n');
    }
    final ParsedResume now = _current(u.parsed);
    final ResumeQuality q = resumeQuality(now);
    Widget field(String k, String label, {int lines = 1, String? hint}) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextField(
            key: ValueKey<String>('rv_$k'),
            controller: _f(k),
            minLines: lines,
            maxLines: lines == 1 ? 1 : 12,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: label, helperText: hint, border: const OutlineInputBorder()),
          ),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Professional profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Text('Read from ${u.fileName}. Check each field and correct anything that was read wrongly — only what is in your file is shown.',
              style: TextStyle(color: GG.mute)),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Resume quality: ${q.score}/100',
            trailing: const ValidatedBadge(label: 'Rule-based'),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              LabeledBar(label: 'Quality', value: q.score, detail: '${q.words} words'),
              if (q.strengths.isNotEmpty) ...<Widget>[
                Text('Strengths', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
                BulletList(q.strengths, icon: Icons.add_circle_outline_rounded, color: GG.green),
              ],
              if (q.weaknesses.isNotEmpty) ...<Widget>[
                Text('Weaknesses', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
                BulletList(q.weaknesses, icon: Icons.remove_circle_outline_rounded, color: GG.red),
              ],
              if (q.suggestions.isNotEmpty) ...<Widget>[
                Text('Suggested improvements', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
                BulletList(q.suggestions),
              ],
            ]),
          ),
          field('name', 'Full name'),
          field('email', 'Email'),
          field('phone', 'Phone'),
          field('headline', 'Headline'),
          field('summary', 'Summary', lines: 3),
          field('education', 'Education (one per line)', lines: 3),
          field('experience', 'Experience (one role per line)', lines: 4, hint: 'Role, organisation, dates — what you did'),
          field('skills', 'Skills (comma separated)', lines: 2),
          field('projects', 'Projects (one per line)', lines: 3),
          field('certifications', 'Certifications (one per line)', lines: 2),
          field('achievements', 'Achievements (one per line)', lines: 2),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Text read from the file'),
            children: <Widget>[SelectableText(u.text, style: TextStyle(color: GG.ink, fontSize: 12.5))],
          ),
          const SizedBox(height: 8),
          BusyButton(
            key: const ValueKey<String>('rv_save'),
            label: 'Save and use for my profile',
            icon: Icons.check_rounded,
            onPressed: () async {
              final bool? ok = await runCareerAction<bool>(context, () async {
                await store.confirmResume(u.id, _current(u.parsed));
                return true;
              }, success: 'Profile updated from your resume.');
              if (ok == true && context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

/// How the student's default resume matches a job, with reasons.
class ResumeMatchCard extends StatelessWidget {
  const ResumeMatchCard({super.key, required this.job});
  final JobPosting job;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final CareerProfile p = store.profile;
    final ResumeUpload? u = p.resumeUpload(p.defaultResumeId);
    final bool any = u != null || p.resume.fullName.isNotEmpty || p.resume.skills.isNotEmpty;
    if (!any) {
      return SectionCard(
        title: 'Resume compatibility',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text('Upload your resume to see how well it matches this job.', style: TextStyle(color: GG.ink)),
          const SizedBox(height: 6),
          FilledButton.tonalIcon(
            key: const ValueKey<String>('match_upload'),
            onPressed: () => Navigator.of(context).push(ggRoute<void>((_) => const ResumeHubScreen())),
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Upload resume'),
          ),
        ]),
      );
    }
    final JobMatch m = u != null ? jobMatch(u.parsed, job, fullText: u.text) : jobMatch(parsedFromResume(p.resume), job);
    return SectionCard(
      key: const ValueKey<String>('job_match'),
      title: 'Resume compatibility: ${m.score}%',
      subtitle: 'Using ${u?.fileName ?? 'your GradeGlow profile resume'}',
      trailing: const ValidatedBadge(label: 'Rule-based'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        LabeledBar(label: 'Match', value: m.score),
        BulletList(m.reasons),
        if (m.missing.isNotEmpty) ...<Widget>[
          Text('Missing keywords', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
          Wrap(spacing: 6, runSpacing: 6, children: <Widget>[for (final String k in m.missing) StatusChip(k, color: GG.mute)]),
          const SizedBox(height: 4),
          Text('Only add a skill to your resume if you really have it — pass a related lab to build the evidence.', style: TextStyle(color: GG.mute, fontSize: 12.5)),
        ],
      ]),
    );
  }
}
