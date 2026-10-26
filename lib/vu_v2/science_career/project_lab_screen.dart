import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'career_center_screen.dart';
import 'resume_export.dart';
import 'science_career_content.dart';
import 'science_career_progress.dart';
import 'science_career_theme.dart';

/// Classic résumé paper look (teal serif headers, white document).
abstract final class _ResumeLook {
  static const Color teal = Color(0xFF6B8F9A);
  static const Color ink = Color(0xFF1C1C1C);
  static const Color mute = Color(0xFF5C5C5C);
  static const Color paper = Color(0xFFFFFFF8);
  static const String serif = 'Georgia';
}

/// VMock-style résumé builder — write your own projects/links; no in-app grind.
class ProjectLabScreen extends StatefulWidget {
  const ProjectLabScreen({super.key, required this.progress});

  final ScienceCareerProgress progress;

  @override
  State<ProjectLabScreen> createState() => _ProjectLabScreenState();
}

class _ProjectLabScreenState extends State<ProjectLabScreen> {
  bool _editingProfile = false;

  @override
  void initState() {
    super.initState();
    widget.progress.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.progress.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _editProject({PortfolioProject? existing}) async {
    final PortfolioProject? saved = await showModalBottomSheet<PortfolioProject>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SciCosmic.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext ctx) => _ProjectEditorSheet(existing: existing),
    );
    if (saved == null) return;
    await widget.progress.upsertPortfolioProject(saved);
  }

  Future<void> _editProfile() async {
    setState(() => _editingProfile = true);
    final ResumeProfile? saved = await showModalBottomSheet<ResumeProfile>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SciCosmic.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext ctx) =>
          _ProfileEditorSheet(profile: widget.progress.resumeProfile.copy()),
    );
    setState(() => _editingProfile = false);
    if (saved == null) return;
    await widget.progress.saveResumeProfile(saved);
  }

  @override
  Widget build(BuildContext context) {
    final ScienceCareerProgress p = widget.progress;
    final double width = MediaQuery.sizeOf(context).width;
    final bool wide = width >= 980;

    return Scaffold(
      backgroundColor: SciCosmic.bg,
      appBar: SciCosmic.appBar(
        context: context,
        title: 'Project Lab',
        icon: Icons.science_rounded,
        subtitle: 'Résumé builder',
        trailing: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                'Add your own projects — no app grind required',
                style: TextStyle(
                  color: SciCosmic.mute.withValues(alpha: 0.9),
                  fontSize: 11.5,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SciStarfield(
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    width: 260,
                    child: _ProjectsRail(
                      progress: p,
                      onAdd: () => _editProject(),
                      onEdit: (PortfolioProject proj) =>
                          _editProject(existing: proj),
                      onDelete: (String id) =>
                          p.removePortfolioProject(id),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: _ResumeDocument(
                      progress: p,
                      onEditProfile: _editProfile,
                      editing: _editingProfile,
                      fillHeight: true,
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: _FeedbackRail(
                      progress: p,
                      onUseSuggestion: (ResumeBulletSuggestion s) async {
                        await p.applyBulletSuggestion(s);
                      },
                      onUseForApps: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                CareerCenterScreen(progress: p),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
                children: <Widget>[
                  _FeedbackRail(
                    progress: p,
                    onUseSuggestion: (ResumeBulletSuggestion s) async {
                      await p.applyBulletSuggestion(s);
                    },
                    onUseForApps: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => CareerCenterScreen(progress: p),
                        ),
                      );
                    },
                    compact: true,
                  ),
                  const SizedBox(height: 12),
                  _ProjectsRail(
                    progress: p,
                    onAdd: () => _editProject(),
                    onEdit: (PortfolioProject proj) =>
                        _editProject(existing: proj),
                    onDelete: (String id) => p.removePortfolioProject(id),
                    embedded: true,
                  ),
                  const SizedBox(height: 12),
                  _ResumeDocument(
                    progress: p,
                    onEditProfile: _editProfile,
                    editing: _editingProfile,
                    fillHeight: false,
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Left: your projects (manual) ───────────────────────────────────────────

class _ProjectsRail extends StatelessWidget {
  const _ProjectsRail({
    required this.progress,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    this.embedded = false,
  });

  final ScienceCareerProgress progress;
  final VoidCallback onAdd;
  final ValueChanged<PortfolioProject> onEdit;
  final ValueChanged<String> onDelete;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final List<PortfolioProject> projects = progress.portfolioProjects;
    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Your projects',
                style: TextStyle(
                  color: SciCosmic.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add anything you built — school, personal, or GitHub. '
                'Nothing here requires finishing in-app missions.',
                style: TextStyle(
                  color: SciCosmic.mute.withValues(alpha: 0.95),
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (projects.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: SciCosmic.panelBox(radius: 12),
              child: const Text(
                'No projects yet. Add a title, a few bullets, and optional links.',
                style: TextStyle(color: SciCosmic.mute, fontSize: 12, height: 1.35),
              ),
            ),
          )
        else
          ...projects.map(
            (PortfolioProject p) => Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: InkWell(
                onTap: () => onEdit(p),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: SciCosmic.panelBox(radius: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.check_circle,
                            color: SciCosmic.electric,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              p.title,
                              style: const TextStyle(
                                color: SciCosmic.ink,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => onDelete(p.id),
                            icon: const Icon(Icons.close, size: 16),
                            color: SciCosmic.mute,
                          ),
                        ],
                      ),
                      Text(
                        '${p.effectiveBullets.length} bullet'
                        '${p.effectiveBullets.length == 1 ? '' : 's'}'
                        '${p.githubUrl.isNotEmpty || p.liveUrl.isNotEmpty ? ' · linked' : ''}',
                        style: const TextStyle(
                          color: SciCosmic.mute,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: Text(
            'Tip: bullets with action verbs + numbers raise your score.',
            style: TextStyle(
              color: SciCosmic.mute.withValues(alpha: 0.85),
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add project or link'),
            style: FilledButton.styleFrom(
              backgroundColor: SciCosmic.purple,
              minimumSize: const Size.fromHeight(44),
            ),
          ),
        ),
      ],
    );

    if (embedded) {
      return Container(
        decoration: SciCosmic.panelBox(radius: 16),
        child: SizedBox(height: 320, child: body),
      );
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 6, 12),
      decoration: SciCosmic.panelBox(radius: 16),
      child: body,
    );
  }
}

// ─── Center: résumé document ────────────────────────────────────────────────

class _ResumeDocument extends StatelessWidget {
  const _ResumeDocument({
    required this.progress,
    required this.onEditProfile,
    required this.editing,
    this.fillHeight = true,
  });

  final ScienceCareerProgress progress;
  final VoidCallback onEditProfile;
  final bool editing;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final ResumeProfile r = progress.resumeProfile;
    final List<ResumeBulletSuggestion> suggestions = progress.resumeSuggestions;
    final Map<String, int> badgeByKey = <String, int>{
      for (final ResumeBulletSuggestion s in suggestions)
        '${s.projectId}:${s.bulletIndex}': s.badge,
    };

    final Widget paper = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(36, 28, 36, 32),
      decoration: BoxDecoration(
        color: _ResumeLook.paper,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD7DEE3)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: fillHeight
          ? SingleChildScrollView(child: _resumeBody(r, badgeByKey))
          : _resumeBody(r, badgeByKey),
    );

    final Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onEditProfile,
            icon: Icon(
              editing ? Icons.hourglass_empty : Icons.edit_outlined,
              size: 16,
            ),
            label: Text(editing ? 'Editing…' : 'Edit résumé details'),
          ),
        ),
        if (fillHeight) Expanded(child: paper) else paper,
      ],
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(6, 8, 6, 12),
      child: column,
    );
  }

  Widget _resumeBody(ResumeProfile r, Map<String, int> badgeByKey) {
    final ScienceMajor major = ScienceMajors.byId(progress.majorId);
    final String title = r.fullName.trim().isNotEmpty
        ? r.fullName.trim().toUpperCase()
        : '${major.title.toUpperCase()} MAJOR RÉSUMÉ';
    final String contact = <String>[
      if (r.location.trim().isNotEmpty) r.location.trim() else 'City, ST',
      if (r.email.trim().isNotEmpty) r.email.trim() else 'your.email@email.com',
      if (r.phone.trim().isNotEmpty) r.phone.trim() else '(555) 000-0000',
    ].join('  •  ');
    final String summary = r.summary.trim().isNotEmpty
        ? r.summary.trim()
        : (r.headline.trim().isNotEmpty
            ? r.headline.trim()
            : 'Motivated ${major.title.toLowerCase()} student with coursework in data structures and software development. Seeking a ${r.targetRole.trim().isEmpty ? 'junior software engineering' : r.targetRole.toLowerCase()} role to apply classroom knowledge in a collaborative team.');
    final List<String> expBullets = r.experience
        .split(RegExp(r'[\n•]+'))
        .map((String s) => s.trim().replaceFirst(RegExp(r'^[-*]\s*'), ''))
        .where((String s) => s.isNotEmpty)
        .toList();
    final Set<String> skillSet = <String>{
      ...progress.skills,
      ...r.extraSkills,
      for (final PortfolioProject p in progress.portfolioProjects) ...p.tech,
    };

    return DefaultTextStyle(
      style: const TextStyle(
        color: _ResumeLook.ink,
        height: 1.45,
        fontSize: 12.5,
        fontFamily: _ResumeLook.serif,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ResumeLook.teal,
              fontFamily: _ResumeLook.serif,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              letterSpacing: 1.1,
              height: 1.2,
            ),
          ),
          if (r.fullName.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              '${major.title} Major',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ResumeLook.mute,
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            contact,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ResumeLook.ink,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          if (r.githubUrl.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              r.githubUrl.trim(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ResumeLook.mute,
                fontSize: 11.5,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(height: 1.2, color: _ResumeLook.teal),
          const SizedBox(height: 14),
          Text(
            summary,
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 12.5, height: 1.5),
          ),
          if (expBullets.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            _sectionTitle('Relevant Experience'),
            ...expBullets.map(
              (String b) => _classicBullet(b),
            ),
          ],
          const SizedBox(height: 16),
          _sectionTitle('Projects'),
          if (progress.portfolioProjects.isEmpty)
            const Text(
              'Add projects from the left panel — title, bullets, and optional links.',
              style: TextStyle(
                color: _ResumeLook.mute,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...progress.portfolioProjects.map((PortfolioProject proj) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      proj.title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      proj.tech.isNotEmpty
                          ? proj.tech.join(', ')
                          : 'Personal / Course Project',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                    if (proj.githubUrl.isNotEmpty || proj.liveUrl.isNotEmpty)
                      Text(
                        <String>[
                          if (proj.githubUrl.isNotEmpty) proj.githubUrl,
                          if (proj.liveUrl.isNotEmpty) proj.liveUrl,
                        ].join('  •  '),
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: _ResumeLook.mute,
                          fontSize: 11.5,
                        ),
                      ),
                    const SizedBox(height: 4),
                    ...List<Widget>.generate(proj.effectiveBullets.length, (
                      int i,
                    ) {
                      return _classicBullet(
                        proj.effectiveBullets[i],
                        badge: badgeByKey['${proj.id}:$i'],
                      );
                    }),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          _sectionTitle('Education'),
          Text(
            (r.university.trim().isNotEmpty
                    ? r.university
                    : (r.education.trim().isNotEmpty
                        ? r.education.split('\n').first
                        : 'Your University'))
                .toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            r.degree.trim().isNotEmpty
                ? r.degree
                : 'Bachelor of Science in ${major.title}',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 12.5,
            ),
          ),
          Text(
            r.gradYear.trim().isNotEmpty
                ? 'Expected graduation: ${r.gradYear}'
                : 'Expected graduation: 20XX',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                const TextSpan(
                  text: 'Relevant coursework: ',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: r.coursework.trim().isNotEmpty
                      ? r.coursework.trim()
                      : 'Data Structures, Algorithms, Software Engineering, Databases',
                ),
              ],
            ),
            style: const TextStyle(fontSize: 12.5, height: 1.45),
          ),
          if (skillSet.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            _sectionTitle('Skills'),
            ...skillSet.take(10).map(_classicBullet),
          ],
        ],
      ),
    );
  }

  static Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        t,
        style: const TextStyle(
          color: _ResumeLook.teal,
          fontFamily: _ResumeLook.serif,
          fontWeight: FontWeight.w700,
          fontSize: 16,
          height: 1.2,
        ),
      ),
    );
  }

  static Widget _classicBullet(String text, {int? badge}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3, left: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            width: 14,
            child: Text('•', style: TextStyle(fontSize: 13, height: 1.35)),
          ),
          Expanded(
            child: Text(text, style: const TextStyle(height: 1.4)),
          ),
          if (badge != null) ...<Widget>[
            const SizedBox(width: 6),
            Container(
              width: 15,
              height: 15,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFE8A317),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$badge',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'sans-serif',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Right: score + suggestions ─────────────────────────────────────────────

class _FeedbackRail extends StatefulWidget {
  const _FeedbackRail({
    required this.progress,
    required this.onUseSuggestion,
    required this.onUseForApps,
    this.compact = false,
  });

  final ScienceCareerProgress progress;
  final ValueChanged<ResumeBulletSuggestion> onUseSuggestion;
  final VoidCallback onUseForApps;
  final bool compact;

  @override
  State<_FeedbackRail> createState() => _FeedbackRailState();
}

class _FeedbackRailState extends State<_FeedbackRail> {
  bool _downloading = false;

  Future<void> _download({required String format}) async {
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      final String base = ResumeExport.fileBaseName(widget.progress);
      final Uint8List bytes = format == 'txt'
          ? ResumeExport.buildTxt(widget.progress)
          : ResumeExport.buildHtml(widget.progress);
      final String ext = format == 'txt' ? 'txt' : 'html';
      await FilePicker.platform.saveFile(
        dialogTitle: 'Download résumé',
        fileName: '${base}_Resume.$ext',
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: <String>[ext],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            format == 'html'
                ? (kIsWeb
                    ? 'Download started — open the HTML file, then Print → Save as PDF'
                    : 'Résumé saved — open in a browser, then Print → Save as PDF')
                : (kIsWeb ? 'Download started (.txt)' : 'Résumé saved as .txt'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not download résumé: $e')),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScienceCareerProgress progress = widget.progress;
    final ValueChanged<ResumeBulletSuggestion> onUseSuggestion =
        widget.onUseSuggestion;
    final VoidCallback onUseForApps = widget.onUseForApps;
    final bool compact = widget.compact;
    final int score = progress.resumeBuilderScore;
    final int impact = progress.resumeImpactScore;
    final int clarity = progress.resumeClarityScore;
    final int skills = progress.resumeSkillsMatchScore;
    final ResumeProfile r = progress.resumeProfile;
    final List<ResumeBulletSuggestion> suggestions = progress.resumeSuggestions;
    final Color scoreColor = score >= 75
        ? SciCosmic.success
        : score >= 50
            ? SciCosmic.gold
            : SciCosmic.orange;

    final Widget content = ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      shrinkWrap: compact,
      physics: compact
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 7,
                    backgroundColor: SciCosmic.stroke,
                    color: scoreColor,
                  ),
                  Text(
                    '$score',
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'of 100',
                    style: TextStyle(
                      color: SciCosmic.mute,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Targeting: ${r.targetRole.trim().isEmpty ? 'Junior Software Engineer' : r.targetRole}'
                    '${r.targetCompany.trim().isEmpty ? '' : ', ${r.targetCompany}'}',
                    style: const TextStyle(
                      color: SciCosmic.ink,
                      fontSize: 12.5,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _MetricBar(label: 'Impact', value: impact, color: SciCosmic.orange),
        _MetricBar(label: 'Clarity', value: clarity, color: SciCosmic.electric),
        _MetricBar(
          label: 'Skills match',
          value: skills,
          color: SciCosmic.purple,
        ),
        const SizedBox(height: 14),
        const Text(
          'Improve these',
          style: TextStyle(
            color: SciCosmic.ink,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        if (suggestions.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SciCosmic.blue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SciCosmic.blue.withValues(alpha: 0.35)),
            ),
            child: Text(
              progress.portfolioProjects.isEmpty
                  ? 'Add a project with 2–3 bullets to get rewrite tips.'
                  : '${progress.strongBulletCount} bullets look strong — they name the work and include a count.',
              style: const TextStyle(
                color: SciCosmic.mute,
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          )
        else
          ...suggestions.map(
            (ResumeBulletSuggestion s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: SciCosmic.panelBox(radius: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: SciCosmic.orange,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${s.badge}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.reason,
                            style: const TextStyle(
                              color: SciCosmic.ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Now: ${s.nowText}',
                      style: const TextStyle(
                        color: SciCosmic.mute,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try: ${s.tryText}',
                      style: const TextStyle(
                        color: SciCosmic.ink,
                        fontSize: 11.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () => onUseSuggestion(s),
                        style: FilledButton.styleFrom(
                          backgroundColor: SciCosmic.purple,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Use this'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (progress.strongBulletCount > 0) ...<Widget>[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SciCosmic.blue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${progress.strongBulletCount} bullets are strong: they name the work and give a count.',
              style: const TextStyle(
                color: SciCosmic.mute,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _downloading ? null : () => _download(format: 'html'),
          icon: _downloading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_rounded),
          label: Text(_downloading ? 'Preparing…' : 'Download résumé'),
          style: FilledButton.styleFrom(
            backgroundColor: SciCosmic.teal,
            minimumSize: const Size.fromHeight(46),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _downloading ? null : () => _download(format: 'txt'),
          icon: const Icon(Icons.description_outlined, size: 18),
          label: const Text('Download as text'),
          style: OutlinedButton.styleFrom(
            foregroundColor: SciCosmic.ink,
            side: const BorderSide(color: SciCosmic.stroke),
            minimumSize: const Size.fromHeight(44),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: onUseForApps,
          style: FilledButton.styleFrom(
            backgroundColor: SciCosmic.purple,
            minimumSize: const Size.fromHeight(46),
          ),
          child: const Text('Use for applications'),
        ),
      ],
    );

    if (compact) {
      return Container(
        decoration: SciCosmic.panelBox(radius: 16),
        child: content,
      );
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(6, 8, 12, 12),
      decoration: SciCosmic.panelBox(radius: 16),
      child: content,
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(color: SciCosmic.mute, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '$value',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 7,
              backgroundColor: SciCosmic.stroke,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Editors ────────────────────────────────────────────────────────────────

class _ProjectEditorSheet extends StatefulWidget {
  const _ProjectEditorSheet({this.existing});

  final PortfolioProject? existing;

  @override
  State<_ProjectEditorSheet> createState() => _ProjectEditorSheetState();
}

class _ProjectEditorSheetState extends State<_ProjectEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _bullets;
  late final TextEditingController _tech;
  late final TextEditingController _github;
  late final TextEditingController _live;

  @override
  void initState() {
    super.initState();
    final PortfolioProject? e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _bullets = TextEditingController(
      text: (e?.effectiveBullets ?? const <String>[]).join('\n'),
    );
    _tech = TextEditingController(text: e?.tech.join(', ') ?? '');
    _github = TextEditingController(text: e?.githubUrl ?? '');
    _live = TextEditingController(text: e?.liveUrl ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _bullets.dispose();
    _tech.dispose();
    _github.dispose();
    _live.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: SciCosmic.mute),
        hintStyle: TextStyle(color: SciCosmic.mute.withValues(alpha: 0.5)),
        filled: true,
        fillColor: SciCosmic.panelAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  void _save() {
    final String title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a project title.')),
      );
      return;
    }
    final List<String> bullets = _bullets.text
        .split(RegExp(r'[\n•]+'))
        .map((String s) => s.trim().replaceFirst(RegExp(r'^[-*]\s*'), ''))
        .where((String s) => s.isNotEmpty)
        .toList();
    final List<String> tech = _tech.text
        .split(RegExp(r'[,;]'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
    Navigator.of(context).pop(
      PortfolioProject(
        id: widget.existing?.id ??
            'pf_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: bullets.join('\n'),
        bullets: bullets,
        tech: tech,
        githubUrl: _github.text.trim(),
        liveUrl: _live.text.trim(),
        createdAt: widget.existing?.createdAt.isNotEmpty == true
            ? widget.existing!.createdAt
            : DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Add project',
              style: TextStyle(
                color: SciCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your own work — paste bullets and links. No need to complete missions in the app.',
              style: TextStyle(color: SciCosmic.mute, fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('Project title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bullets,
              maxLines: 5,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec(
                'Bullets (one per line)',
                hint: 'Built a REST API with auth and 12 tests…',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _tech,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('Tech (comma-separated)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _github,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('GitHub URL (optional)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _live,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('Live demo URL (optional)'),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: SciCosmic.purple,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Save to résumé'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileEditorSheet extends StatefulWidget {
  const _ProfileEditorSheet({required this.profile});

  final ResumeProfile profile;

  @override
  State<_ProfileEditorSheet> createState() => _ProfileEditorSheetState();
}

class _ProfileEditorSheetState extends State<_ProfileEditorSheet> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _location;
  late final TextEditingController _github;
  late final TextEditingController _summary;
  late final TextEditingController _experience;
  late final TextEditingController _university;
  late final TextEditingController _degree;
  late final TextEditingController _grad;
  late final TextEditingController _coursework;
  late final TextEditingController _targetRole;
  late final TextEditingController _targetCompany;
  late final TextEditingController _skills;

  @override
  void initState() {
    super.initState();
    final ResumeProfile r = widget.profile;
    _name = TextEditingController(text: r.fullName);
    _email = TextEditingController(text: r.email);
    _phone = TextEditingController(text: r.phone);
    _location = TextEditingController(text: r.location);
    _github = TextEditingController(text: r.githubUrl);
    _summary = TextEditingController(text: r.summary);
    _experience = TextEditingController(text: r.experience);
    _university = TextEditingController(text: r.university);
    _degree = TextEditingController(text: r.degree);
    _grad = TextEditingController(text: r.gradYear);
    _coursework = TextEditingController(text: r.coursework);
    _targetRole = TextEditingController(
      text: r.targetRole.isEmpty ? 'Junior Software Engineer' : r.targetRole,
    );
    _targetCompany = TextEditingController(
      text: r.targetCompany.isEmpty ? 'Northwind Labs' : r.targetCompany,
    );
    _skills = TextEditingController(text: r.extraSkills.join(', '));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _location.dispose();
    _github.dispose();
    _summary.dispose();
    _experience.dispose();
    _university.dispose();
    _degree.dispose();
    _grad.dispose();
    _coursework.dispose();
    _targetRole.dispose();
    _targetCompany.dispose();
    _skills.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: SciCosmic.mute),
        filled: true,
        fillColor: SciCosmic.panelAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Résumé details',
              style: TextStyle(
                color: SciCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('Full name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _email,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phone,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('Phone'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _location,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('City, ST'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _github,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('GitHub'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _summary,
              maxLines: 4,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('Professional summary'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _experience,
              maxLines: 4,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('Relevant experience (one bullet per line)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _university,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('University'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _degree,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('Degree'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _grad,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('Expected graduation'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _coursework,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('Coursework'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _targetRole,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('Target role'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _targetCompany,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('Target company'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _skills,
              style: const TextStyle(color: SciCosmic.ink),
              decoration: _dec('Skills (comma-separated)'),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () {
                final List<String> extras = _skills.text
                    .split(RegExp(r'[,;]'))
                    .map((String s) => s.trim())
                    .where((String s) => s.isNotEmpty)
                    .toList();
                Navigator.of(context).pop(
                  ResumeProfile(
                    fullName: _name.text.trim(),
                    email: _email.text.trim(),
                    phone: _phone.text.trim(),
                    location: _location.text.trim(),
                    githubUrl: _github.text.trim(),
                    university: _university.text.trim(),
                    degree: _degree.text.trim(),
                    gradYear: _grad.text.trim(),
                    coursework: _coursework.text.trim(),
                    education: <String>[
                      _university.text.trim(),
                      _degree.text.trim(),
                      _grad.text.trim(),
                    ].where((String s) => s.isNotEmpty).join(' · '),
                    targetRole: _targetRole.text.trim(),
                    targetCompany: _targetCompany.text.trim(),
                    extraSkills: extras,
                    targetSkills: widget.profile.targetSkills,
                    headline: widget.profile.headline,
                    summary: _summary.text.trim(),
                    experience: _experience.text.trim(),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: SciCosmic.purple,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
