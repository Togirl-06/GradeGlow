import 'package:flutter/material.dart';

import '../../models/biology_degree.dart';
import '../../theme/biology_degree_theme.dart';

/// Medical / research investigation workspace with lab results + AI reasoning review.
class BiologyCaseStudiesScreen extends StatefulWidget {
  const BiologyCaseStudiesScreen({super.key, required this.path});

  final BiologyLessonPath path;

  @override
  State<BiologyCaseStudiesScreen> createState() => _BiologyCaseStudiesScreenState();
}

class _BiologyCaseStudiesScreenState extends State<BiologyCaseStudiesScreen> {
  int _caseIndex = 0;
  int? _selected;
  String? _aiReview;
  int _score = 0;
  bool _showLabs = true;
  bool _showHistory = false;
  final TextEditingController _reasoning = TextEditingController();

  @override
  void dispose() {
    _reasoning.dispose();
    super.dispose();
  }

  List<_BioCase> get _cases {
    final String topic = widget.path.lesson.title;
    return <_BioCase>[
      _BioCase(
        title: 'Medical Investigation',
        patientAge: 42,
        symptoms: <String>[
          'Fatigue',
          'Increased thirst',
          'Frequent urination',
          'High blood glucose',
        ],
        labs: <String>[
          'Fasting glucose: 168 mg/dL (elevated)',
          'HbA1c: 8.1%',
          'Urinalysis: glucose present',
          'BMI: 31',
        ],
        history: <String>[
          'Family history of type 2 diabetes',
          'Sedentary lifestyle',
          'No recent infection',
        ],
        scenario:
            'Connect the patient findings to $topic. Choose the most likely diagnosis axis.',
        options: <String>[
          'Pancreatic β-cells · insulin deficiency / resistance',
          'Thyroid · thyroxine toxicity only',
          'Liver · bile salt deficiency only',
          'Skin · melanin overproduction',
        ],
        correct: 0,
        explanation:
            'Hyperglycemia with polyuria/polydipsia points to insulin pathway failure. '
            'Your reasoning should cite labs (glucose, HbA1c) and distinguish type patterns.',
        keywords: <String>['insulin', 'glucose', 'pancrea', 'diabetes', 'β', 'beta'],
      ),
      _BioCase(
        title: 'Crop Pathology Case',
        patientAge: 0,
        symptoms: <String>[
          'Sudden wilting despite irrigation',
          'Spotting on leaves',
          'Reduced yield',
        ],
        labs: <String>[
          'Soil moisture: adequate',
          'Microscope: fungal hyphae in stem cross-section',
          'Nutrient panel: mild N deficit',
        ],
        history: <String>[
          'Recent heavy rainfall',
          'Same cultivar year over year',
          'Neighboring plot also affected',
        ],
        scenario:
            'Diagnose using $topic concepts — what is the primary driver of wilt?',
        options: <String>[
          'Vascular fungal infection / transport blockage',
          'The moon phase changed chlorophyll',
          'Plants no longer need water',
          'Ignore microscopy findings',
        ],
        correct: 0,
        explanation:
            'Adequate water + hyphae in vasculature implies pathogen-mediated vascular failure.',
        keywords: <String>['fung', 'vascular', 'pathogen', 'infect', 'hypha', 'transport'],
      ),
      _BioCase(
        title: 'Population Ecology Case',
        patientAge: 0,
        symptoms: <String>[
          'Deer census down 40%',
          'Mild winter reported',
          'No mass migration observed',
        ],
        labs: <String>[
          'Carcass surveys incomplete',
          'Tick density elevated',
          'Forage biomass moderate',
        ],
        history: <String>[
          'Previous boom year',
          'New predator sightings',
          'Farm fence expansion nearby',
        ],
        scenario:
            'Which $topic explanation is most scientific to pursue first?',
        options: <String>[
          'Disease, predation, or resource change — gather density data',
          'Animals chose to leave for no reason',
          'Graphs are unnecessary',
          'Evolution stopped',
        ],
        correct: 0,
        explanation:
            'Population crashes demand evidence for density-dependent and density-independent factors.',
        keywords: <String>['disease', 'predat', 'resource', 'density', 'data', 'population'],
      ),
    ];
  }

  void _submit() {
    final _BioCase current = _cases[_caseIndex];
    if (_selected == null) return;
    final bool ok = _selected == current.correct;
    final String reason = _reasoning.text.trim().toLowerCase();
    final int hits = current.keywords.where(reason.contains).length;
    final String reasoningNote = reason.length < 12
        ? 'Your write-up is too short — explain which symptoms and labs justify the choice.'
        : hits >= 2
            ? 'Strong reasoning: you linked mechanism language to the evidence.'
            : 'Partial reasoning: mention key mechanisms (${current.keywords.take(3).join(", ")}) and cite a lab value.';

    setState(() {
      if (ok) _score += 1;
      _aiReview = ok
          ? 'AI review: Diagnosis accepted.\n$reasoningNote\n\n${current.explanation}'
          : 'AI review: Diagnosis needs revision.\n$reasoningNote\n\n${current.explanation}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final BiologyDegreeColors c = BiologyDegreeTheme.of(context);
    final List<_BioCase> cases = _cases;
    final _BioCase current = cases[_caseIndex];
    final bool medical = current.patientAge > 0;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(
          current.title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: <Widget>[
          Text(
            'Case ${_caseIndex + 1} of ${cases.length}',
            style: TextStyle(color: c.primary, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: c.cardDecoration(borderColor: c.primary.withValues(alpha: 0.45)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  medical ? 'Patient' : 'Subject',
                  style: TextStyle(color: c.primary, fontWeight: FontWeight.w900),
                ),
                if (medical) ...<Widget>[
                  const SizedBox(height: 4),
                  Text('Age: ${current.patientAge}', style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
                const SizedBox(height: 10),
                Text('Symptoms / findings', style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                ...current.symptoms.map(
                  (String s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('• ', style: TextStyle(color: c.primary, fontWeight: FontWeight.w900)),
                        Expanded(child: Text(s)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _showLabs = true;
                    _showHistory = false;
                  }),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _showLabs ? c.primary : c.border, width: _showLabs ? 2 : 1),
                  ),
                  child: const Text('Laboratory Results'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _showHistory = true;
                    _showLabs = false;
                  }),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _showHistory ? c.primary : c.border, width: _showHistory ? 2 : 1),
                  ),
                  child: const Text('Medical History'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: c.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (_showLabs ? current.labs : current.history)
                  .map(
                    (String line) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(line, style: TextStyle(height: 1.35, color: c.textPrimary.withValues(alpha: 0.9))),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          Text(current.scenario, style: TextStyle(height: 1.4, color: c.textPrimary)),
          const SizedBox(height: 12),
          Text('Choose Diagnosis', style: TextStyle(color: c.primary, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          ...List<Widget>.generate(current.options.length, (int i) {
            final bool selected = _selected == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _aiReview == null ? () => setState(() => _selected = i) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? c.primary : c.border, width: selected ? 2 : 1),
                      color: selected ? c.primary.withValues(alpha: 0.08) : c.surface,
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          selected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: selected ? c.primary : c.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(current.options[i])),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          Text('Explain Reasoning', style: TextStyle(color: c.primary, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          TextField(
            controller: _reasoning,
            enabled: _aiReview == null,
            decoration: const InputDecoration(
              hintText: 'Cite symptoms, labs, and mechanism…',
              border: OutlineInputBorder(),
            ),
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: 12),
          if (_aiReview == null)
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Submit for AI review', style: TextStyle(fontWeight: FontWeight.w900)),
            )
          else ...<Widget>[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: c.cardDecoration(borderColor: c.accent.withValues(alpha: 0.5)),
              child: Text(
                _aiReview!,
                style: TextStyle(height: 1.45, color: c.textPrimary.withValues(alpha: 0.92)),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                if (_caseIndex >= cases.length - 1) {
                  Navigator.of(context).pop(true);
                } else {
                  setState(() {
                    _caseIndex += 1;
                    _selected = null;
                    _aiReview = null;
                    _reasoning.clear();
                    _showLabs = true;
                    _showHistory = false;
                  });
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _caseIndex >= cases.length - 1
                    ? 'Finish cases ($_score/${cases.length}) · +${BioLessonActivityKind.caseStudies.xpReward} XP'
                    : 'Next case',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BioCase {
  const _BioCase({
    required this.title,
    required this.patientAge,
    required this.symptoms,
    required this.labs,
    required this.history,
    required this.scenario,
    required this.options,
    required this.correct,
    required this.explanation,
    required this.keywords,
  });

  final String title;
  final int patientAge;
  final List<String> symptoms;
  final List<String> labs;
  final List<String> history;
  final String scenario;
  final List<String> options;
  final int correct;
  final String explanation;
  final List<String> keywords;
}
