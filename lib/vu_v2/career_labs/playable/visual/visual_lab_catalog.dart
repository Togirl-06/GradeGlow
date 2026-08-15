import 'package:flutter/material.dart';

import 'visual_lab_models.dart';

/// Catalog of interactive visual labs for all Career Lab professions.
abstract final class VisualLabCatalog {
  static VisualLabSpec? byId(String id) {
    for (final VisualLabSpec s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  static List<VisualLabSpec> forCareer(String careerId) =>
      all.where((VisualLabSpec s) => s.careerId == careerId && !s.isPracticalExam).toList();

  static List<VisualLabSpec> practicalExams({String? careerId}) => all
      .where(
        (VisualLabSpec s) =>
            s.isPracticalExam && (careerId == null || s.careerId == careerId),
      )
      .toList();

  static final List<VisualLabSpec> all = <VisualLabSpec>[
    ..._medicine,
    ..._nursing,
    ..._law,
    ..._business,
    ..._finance,
    ..._accounting,
    ..._marketing,
    ..._economics,
    ..._cs,
    ..._psychology,
    ..._biology,
    ..._chemistry,
    ..._physics,
    ..._engineering,
    ..._mathematics,
    ..._civil,
    ..._electrical,
    ..._mls,
    ..._pharmacy,
    ..._cyber,
  ];
}

// ── Palette helpers ──────────────────────────────────────────────
const Color _medA = Color(0xFF60A5FA);
const Color _medB = Color(0xFF060B14);
const Color _medS = Color(0xFF0F1A2C);
const Color _nurA = Color(0xFF2DD4A8);
const Color _nurB = Color(0xFF061412);
const Color _nurS = Color(0xFF0F2420);
const Color _lawA = Color(0xFFD4A574);
const Color _lawB = Color(0xFF120E0A);
const Color _lawS = Color(0xFF1F1812);
const Color _bizA = Color(0xFF38BDF8);
const Color _bizB = Color(0xFF071018);
const Color _bizS = Color(0xFF0F1C2A);
const Color _finA = Color(0xFF34D399);
const Color _finB = Color(0xFF06140F);
const Color _finS = Color(0xFF0E221A);
const Color _accA = Color(0xFFFBBF24);
const Color _accB = Color(0xFF12100A);
const Color _accS = Color(0xFF1F1A10);
const Color _mktA = Color(0xFFF472B6);
const Color _mktB = Color(0xFF140A12);
const Color _mktS = Color(0xFF24141F);
const Color _ecoA = Color(0xFFA78BFA);
const Color _ecoB = Color(0xFF0C0A14);
const Color _ecoS = Color(0xFF181426);
const Color _csA = Color(0xFF22D3EE);
const Color _csB = Color(0xFF061218);
const Color _csS = Color(0xFF0E1F28);
const Color _psyA = Color(0xFFC084FC);
const Color _psyB = Color(0xFF100A16);
const Color _psyS = Color(0xFF1C1426);
const Color _bioA = Color(0xFF4ADE80);
const Color _bioB = Color(0xFF06140C);
const Color _bioS = Color(0xFF0E2216);
const Color _chemA = Color(0xFFFB7185);
const Color _chemB = Color(0xFF14080C);
const Color _chemS = Color(0xFF241018);
const Color _phyA = Color(0xFF67E8F9);
const Color _phyB = Color(0xFF061318);
const Color _phyS = Color(0xFF0E2228);
const Color _engA = Color(0xFFF59E0B);
const Color _engB = Color(0xFF120E06);
const Color _engS = Color(0xFF221A0E);
const Color _mathA = Color(0xFF818CF8);
const Color _mathB = Color(0xFF0A0C18);
const Color _mathS = Color(0xFF141828);
const Color _civA = Color(0xFF94A3B8);
const Color _civB = Color(0xFF0C1014);
const Color _civS = Color(0xFF161E26);
const Color _eeA = Color(0xFFFDE047);
const Color _eeB = Color(0xFF121006);
const Color _eeS = Color(0xFF221E0C);
const Color _mlsA = Color(0xFF2DD4BF);
const Color _mlsB = Color(0xFF061412);
const Color _mlsS = Color(0xFF0E221E);
const Color _pharmA = Color(0xFF86EFAC);
const Color _pharmB = Color(0xFF08140C);
const Color _pharmS = Color(0xFF122018);
const Color _cyberA = Color(0xFFFB923C);
const Color _cyberB = Color(0xFF140C06);
const Color _cyberS = Color(0xFF24180E);

// ── Medicine ─────────────────────────────────────────────────────
final List<VisualLabSpec> _medicine = <VisualLabSpec>[
  VisualLabSpec(
    id: 'med_heart_label',
    careerId: 'medicine',
    kind: VisualLabKind.label,
    title: 'Cardiac anatomy labels',
    brief: 'Label chambers and great vessels on the heart silhouette.',
    accent: _medA,
    bg: _medB,
    surface: _medS,
    difficulty: LabelDifficulty.intermediate,
    diagramTitle: 'heart',
    wordBank: const <String>['RA', 'LA', 'RV', 'LV', 'Aorta', 'Pulmonary artery'],
    hotspots: const <Hotspot>[
      Hotspot(id: 'ra', correctLabel: 'RA', fx: 0.38, fy: 0.42),
      Hotspot(id: 'la', correctLabel: 'LA', fx: 0.62, fy: 0.40),
      Hotspot(id: 'rv', correctLabel: 'RV', fx: 0.42, fy: 0.62),
      Hotspot(id: 'lv', correctLabel: 'LV', fx: 0.58, fy: 0.60),
      Hotspot(id: 'ao', correctLabel: 'Aorta', fx: 0.52, fy: 0.22),
      Hotspot(id: 'pa', correctLabel: 'Pulmonary artery', fx: 0.48, fy: 0.28),
    ],
  ),
  VisualLabSpec(
    id: 'med_blood_path',
    careerId: 'medicine',
    kind: VisualLabKind.pathTrace,
    title: 'Systemic blood flow',
    brief: 'Trace oxygenated blood from lungs → body → return.',
    accent: _medA,
    bg: _medB,
    surface: _medS,
    diagramTitle: 'heart',
    pathOrder: const <String>['lungs', 'LA', 'LV', 'aorta', 'body', 'RA', 'RV'],
    pathNodes: const <PathNode>[
      PathNode(id: 'lungs', label: 'Lungs', fx: 0.2, fy: 0.3),
      PathNode(id: 'LA', label: 'LA', fx: 0.4, fy: 0.35),
      PathNode(id: 'LV', label: 'LV', fx: 0.55, fy: 0.5),
      PathNode(id: 'aorta', label: 'Aorta', fx: 0.7, fy: 0.28),
      PathNode(id: 'body', label: 'Body', fx: 0.82, fy: 0.55),
      PathNode(id: 'RA', label: 'RA', fx: 0.45, fy: 0.7),
      PathNode(id: 'RV', label: 'RV', fx: 0.3, fy: 0.65),
    ],
  ),
  VisualLabSpec(
    id: 'med_ecg_interpret',
    careerId: 'medicine',
    kind: VisualLabKind.interpret,
    title: 'ECG strip read',
    brief: 'Interpret the bedside ECG tracing.',
    accent: _medA,
    bg: _medB,
    surface: _medS,
    interpret: const InterpretScenario(
      visualKind: 'ecg',
      caption: 'Lead II · 25 mm/s',
      prompt: 'Most likely rhythm?',
      choices: <String>[
        'Normal sinus rhythm',
        'Atrial fibrillation',
        'Ventricular tachycardia',
        'Complete heart block',
      ],
      correctIndex: 0,
      freeTextKeywords: <String>['sinus', 'normal'],
    ),
  ),
  VisualLabSpec(
    id: 'med_body_identify',
    careerId: 'medicine',
    kind: VisualLabKind.identify,
    title: 'Identify the liver',
    brief: 'Tap the liver on the body diagram.',
    accent: _medA,
    bg: _medB,
    surface: _medS,
    diagramTitle: 'body',
    correctIdentifyId: 'liver',
    identifyOptions: const <String>['Liver'],
    hotspots: const <Hotspot>[
      Hotspot(id: 'heart', correctLabel: 'Heart', fx: 0.48, fy: 0.38),
      Hotspot(id: 'liver', correctLabel: 'Liver', fx: 0.58, fy: 0.48),
      Hotspot(id: 'stomach', correctLabel: 'Stomach', fx: 0.42, fy: 0.5),
      Hotspot(id: 'lung', correctLabel: 'Lung', fx: 0.38, fy: 0.35),
    ],
  ),
  VisualLabSpec(
    id: 'practical_exam_medicine',
    careerId: 'medicine',
    kind: VisualLabKind.label,
    title: 'Clinical visual practical',
    brief: 'Stations: label heart → path trace → ECG interpret.',
    accent: _medA,
    bg: _medB,
    surface: _medS,
    isPracticalExam: true,
    practicalStepIds: const <String>['med_heart_label', 'med_blood_path', 'med_ecg_interpret'],
  ),
];

// ── Nursing ──────────────────────────────────────────────────────
final List<VisualLabSpec> _nursing = <VisualLabSpec>[
  VisualLabSpec(
    id: 'nur_prioritize_board',
    careerId: 'nursing_ed',
    kind: VisualLabKind.prioritize,
    title: 'ED acuity board',
    brief: 'Rank four patients Immediate → Low.',
    accent: _nurA,
    bg: _nurB,
    surface: _nurS,
    prioritizeItems: const <PrioritizeItem>[
      PrioritizeItem(
        id: 'p1',
        title: 'Room 103 · SOB',
        subtitle: 'SpO₂ 88% · tripoding',
        correctRank: 1,
        acuity: 'AIRWAY',
        glyph: '🚨',
      ),
      PrioritizeItem(
        id: 'p2',
        title: 'Room 107 · Chest pain',
        subtitle: 'New pressure, diaphoretic',
        correctRank: 2,
        acuity: 'HIGH',
        glyph: '❤️',
      ),
      PrioritizeItem(
        id: 'p3',
        title: 'Room 102 · FSBS due',
        subtitle: 'Stable diabetic',
        correctRank: 3,
        acuity: 'MOD',
        glyph: '🩸',
      ),
      PrioritizeItem(
        id: 'p4',
        title: 'Room 101 · Sleeping',
        subtitle: 'Post-op day 1, stable',
        correctRank: 4,
        acuity: 'LOW',
        glyph: '😴',
      ),
    ],
  ),
  VisualLabSpec(
    id: 'nur_vitals_measure',
    careerId: 'nursing_ed',
    kind: VisualLabKind.measure,
    title: 'Capture SpO₂',
    brief: 'Dial the probe to the target saturation and record it.',
    accent: _nurA,
    bg: _nurB,
    surface: _nurS,
    instrument: const MeasureInstrument(
      kind: MeasureInstrumentKind.spo2,
      targetValue: 94,
      unit: '%',
      min: 80,
      max: 100,
      tolerance: 1,
      label: 'Pulse oximetry',
      displayPrecision: 0,
    ),
  ),
  VisualLabSpec(
    id: 'nur_med_assemble',
    careerId: 'nursing_ed',
    kind: VisualLabKind.assemble,
    title: 'Med cart matching',
    brief: 'Seat each medication into the correct drawer.',
    accent: _nurA,
    bg: _nurB,
    surface: _nurS,
    diagramTitle: 'body',
    parts: const <AssemblePart>[
      AssemblePart(id: 'ntg', label: 'Nitroglycerin', glyph: '💊'),
      AssemblePart(id: 'albuterol', label: 'Albuterol', glyph: '🫁'),
      AssemblePart(id: 'insulin', label: 'Insulin', glyph: '💉'),
      AssemblePart(id: 'morphine', label: 'Morphine', glyph: '🧪'),
    ],
    slots: const <AssembleSlot>[
      AssembleSlot(id: 'chest', name: 'Chest pain drawer', correctPartId: 'ntg', fx: 0.25, fy: 0.35),
      AssembleSlot(id: 'resp', name: 'Respiratory drawer', correctPartId: 'albuterol', fx: 0.7, fy: 0.35),
      AssembleSlot(id: 'endo', name: 'Endocrine drawer', correctPartId: 'insulin', fx: 0.25, fy: 0.7),
      AssembleSlot(id: 'pain', name: 'Pain drawer', correctPartId: 'morphine', fx: 0.7, fy: 0.7),
    ],
  ),
  VisualLabSpec(
    id: 'practical_exam_nursing_ed',
    careerId: 'nursing_ed',
    kind: VisualLabKind.prioritize,
    title: 'Shift practical exam',
    brief: 'Prioritize → measure SpO₂ → med assemble.',
    accent: _nurA,
    bg: _nurB,
    surface: _nurS,
    isPracticalExam: true,
    practicalStepIds: const <String>[
      'nur_prioritize_board',
      'nur_vitals_measure',
      'nur_med_assemble',
    ],
  ),
];

// ── Law ──────────────────────────────────────────────────────────
final List<VisualLabSpec> _law = <VisualLabSpec>[
  VisualLabSpec(
    id: 'law_evidence_assemble',
    careerId: 'law_firm',
    kind: VisualLabKind.assemble,
    title: 'Evidence board sort',
    brief: 'Place each exhibit into the correct case folder.',
    accent: _lawA,
    bg: _lawB,
    surface: _lawS,
    diagramTitle: 'network',
    parts: const <AssemblePart>[
      AssemblePart(id: 'contract', label: 'Signed contract', glyph: '📄'),
      AssemblePart(id: 'email', label: 'Email thread', glyph: '✉️'),
      AssemblePart(id: 'photo', label: 'Scene photo', glyph: '📷'),
      AssemblePart(id: 'depo', label: 'Deposition', glyph: '🎙️'),
    ],
    slots: const <AssembleSlot>[
      AssembleSlot(id: 'liability', name: 'Liability', correctPartId: 'contract', fx: 0.25, fy: 0.35),
      AssembleSlot(id: 'comms', name: 'Communications', correctPartId: 'email', fx: 0.7, fy: 0.35),
      AssembleSlot(id: 'physical', name: 'Physical', correctPartId: 'photo', fx: 0.25, fy: 0.7),
      AssembleSlot(id: 'testimony', name: 'Testimony', correctPartId: 'depo', fx: 0.7, fy: 0.7),
    ],
  ),
  VisualLabSpec(
    id: 'law_timeline_prioritize',
    careerId: 'law_firm',
    kind: VisualLabKind.prioritize,
    title: 'Case timeline priority',
    brief: 'Order filing urgency Immediate → Low.',
    accent: _lawA,
    bg: _lawB,
    surface: _lawS,
    prioritizeItems: const <PrioritizeItem>[
      PrioritizeItem(
        id: 't1',
        title: 'TRO hearing tomorrow',
        subtitle: 'Injunction clock ticking',
        correctRank: 1,
        acuity: 'NOW',
      ),
      PrioritizeItem(
        id: 't2',
        title: 'Discovery responses',
        subtitle: 'Due in 5 days',
        correctRank: 2,
        acuity: 'HIGH',
      ),
      PrioritizeItem(
        id: 't3',
        title: 'Client status memo',
        subtitle: 'Internal update',
        correctRank: 3,
        acuity: 'MOD',
      ),
      PrioritizeItem(
        id: 't4',
        title: 'CLE registration',
        subtitle: 'Next month',
        correctRank: 4,
        acuity: 'LOW',
      ),
    ],
  ),
  VisualLabSpec(
    id: 'law_argument_path',
    careerId: 'law_firm',
    kind: VisualLabKind.pathTrace,
    title: 'Argument chain',
    brief: 'Tap the next element in a sound legal argument.',
    accent: _lawA,
    bg: _lawB,
    surface: _lawS,
    diagramTitle: 'network',
    pathOrder: const <String>['facts', 'rule', 'application', 'conclusion'],
    pathNodes: const <PathNode>[
      PathNode(id: 'facts', label: 'Facts', fx: 0.2, fy: 0.5),
      PathNode(id: 'rule', label: 'Rule', fx: 0.4, fy: 0.35),
      PathNode(id: 'application', label: 'Apply', fx: 0.65, fy: 0.45),
      PathNode(id: 'conclusion', label: 'Conclude', fx: 0.85, fy: 0.55),
    ],
  ),
  VisualLabSpec(
    id: 'practical_exam_law_firm',
    careerId: 'law_firm',
    kind: VisualLabKind.assemble,
    title: 'Case board practical',
    brief: 'Evidence sort → timeline → argument path.',
    accent: _lawA,
    bg: _lawB,
    surface: _lawS,
    isPracticalExam: true,
    practicalStepIds: const <String>[
      'law_evidence_assemble',
      'law_timeline_prioritize',
      'law_argument_path',
    ],
  ),
];

// ── Business ─────────────────────────────────────────────────────
final List<VisualLabSpec> _business = <VisualLabSpec>[
  VisualLabSpec(
    id: 'biz_funnel_assemble',
    careerId: 'business',
    kind: VisualLabKind.assemble,
    title: 'Ops funnel assemble',
    brief: 'Map each KPI to the correct stage.',
    accent: _bizA,
    bg: _bizB,
    surface: _bizS,
    diagramTitle: 'network',
    parts: const <AssemblePart>[
      AssemblePart(id: 'leads', label: 'Leads', glyph: '🎯'),
      AssemblePart(id: 'conversion', label: 'Conversion', glyph: '🔁'),
      AssemblePart(id: 'retention', label: 'Retention', glyph: '📌'),
      AssemblePart(id: 'margin', label: 'Margin', glyph: '💵'),
    ],
    slots: const <AssembleSlot>[
      AssembleSlot(id: 's1', name: 'Top of funnel', correctPartId: 'leads', fx: 0.25, fy: 0.3),
      AssembleSlot(id: 's2', name: 'Mid funnel', correctPartId: 'conversion', fx: 0.7, fy: 0.35),
      AssembleSlot(id: 's3', name: 'Customer success', correctPartId: 'retention', fx: 0.25, fy: 0.7),
      AssembleSlot(id: 's4', name: 'Finance view', correctPartId: 'margin', fx: 0.7, fy: 0.7),
    ],
  ),
  VisualLabSpec(
    id: 'biz_sales_graph',
    careerId: 'business',
    kind: VisualLabKind.graph,
    title: 'Sales trend graph',
    brief: 'Plot quarterly sales and interpret the dip.',
    accent: _bizA,
    bg: _bizB,
    surface: _bizS,
    graph: const GraphScenario(
      xLabel: 'Quarter',
      yLabel: 'Sales',
      prompt: 'Plot the decline then recovery.',
      expectedPoints: <Offset>[
        Offset(0.15, 0.3),
        Offset(0.4, 0.55),
        Offset(0.65, 0.7),
        Offset(0.85, 0.4),
      ],
      interpretKeywords: <String>['decline', 'drop', 'recover', 'dip'],
    ),
  ),
  VisualLabSpec(
    id: 'biz_priority_initiatives',
    careerId: 'business',
    kind: VisualLabKind.prioritize,
    title: 'Initiative triage',
    brief: 'Rank company initiatives by urgency.',
    accent: _bizA,
    bg: _bizB,
    surface: _bizS,
    prioritizeItems: const <PrioritizeItem>[
      PrioritizeItem(id: 'b1', title: 'Churn spike', subtitle: 'Customers leaving', correctRank: 1),
      PrioritizeItem(id: 'b2', title: 'Pricing test', subtitle: 'This sprint', correctRank: 2),
      PrioritizeItem(id: 'b3', title: 'Brand refresh', subtitle: 'Q3 project', correctRank: 3),
      PrioritizeItem(id: 'b4', title: 'Office plants', subtitle: 'Nice-to-have', correctRank: 4),
    ],
  ),
  VisualLabSpec(
    id: 'practical_exam_business',
    careerId: 'business',
    kind: VisualLabKind.assemble,
    title: 'Analyst practical',
    brief: 'Funnel → graph → initiative triage.',
    accent: _bizA,
    bg: _bizB,
    surface: _bizS,
    isPracticalExam: true,
    practicalStepIds: const <String>[
      'biz_funnel_assemble',
      'biz_sales_graph',
      'biz_priority_initiatives',
    ],
  ),
];

// ── Finance ──────────────────────────────────────────────────────
final List<VisualLabSpec> _finance = <VisualLabSpec>[
  VisualLabSpec(
    id: 'fin_portfolio_assemble',
    careerId: 'finance',
    kind: VisualLabKind.assemble,
    title: 'Portfolio sleeves',
    brief: 'Assign assets to risk sleeves.',
    accent: _finA,
    bg: _finB,
    surface: _finS,
    diagramTitle: 'graph',
    parts: const <AssemblePart>[
      AssemblePart(id: 'tbills', label: 'T-Bills', glyph: '🏦'),
      AssemblePart(id: 'equity', label: 'Equity ETF', glyph: '📈'),
      AssemblePart(id: 'hy', label: 'High-yield', glyph: '⚡'),
      AssemblePart(id: 'cash', label: 'Cash', glyph: '💵'),
    ],
    slots: const <AssembleSlot>[
      AssembleSlot(id: 'safe', name: 'Conservative', correctPartId: 'tbills', fx: 0.25, fy: 0.35),
      AssembleSlot(id: 'core', name: 'Core growth', correctPartId: 'equity', fx: 0.7, fy: 0.35),
      AssembleSlot(id: 'sat', name: 'Satellite risk', correctPartId: 'hy', fx: 0.25, fy: 0.7),
      AssembleSlot(id: 'liq', name: 'Liquidity', correctPartId: 'cash', fx: 0.7, fy: 0.7),
    ],
  ),
  VisualLabSpec(
    id: 'fin_return_graph',
    careerId: 'finance',
    kind: VisualLabKind.graph,
    title: 'Risk-return scatter',
    brief: 'Plot risk vs return and interpret.',
    accent: _finA,
    bg: _finB,
    surface: _finS,
    graph: const GraphScenario(
      xLabel: 'Risk',
      yLabel: 'Return',
      expectedPoints: <Offset>[Offset(0.2, 0.7), Offset(0.5, 0.45), Offset(0.8, 0.25)],
      interpretKeywords: <String>['tradeoff', 'risk', 'return', 'higher'],
    ),
  ),
  VisualLabSpec(
    id: 'fin_shock_interpret',
    careerId: 'finance',
    kind: VisualLabKind.interpret,
    title: 'Market shock read',
    brief: 'Interpret the supply-demand shift after a rate hike.',
    accent: _finA,
    bg: _finB,
    surface: _finS,
    interpret: const InterpretScenario(
      visualKind: 'supply_demand',
      prompt: 'After a rate hike, bond prices typically…',
      choices: <String>['Fall', 'Rise sharply', 'Stay flat forever', 'Decouple from yields'],
      correctIndex: 0,
      freeTextKeywords: <String>['fall', 'drop', 'decline'],
    ),
  ),
  VisualLabSpec(
    id: 'practical_exam_finance',
    careerId: 'finance',
    kind: VisualLabKind.assemble,
    title: 'Desk practical',
    brief: 'Portfolio → graph → shock interpret.',
    accent: _finA,
    bg: _finB,
    surface: _finS,
    isPracticalExam: true,
    practicalStepIds: const <String>[
      'fin_portfolio_assemble',
      'fin_return_graph',
      'fin_shock_interpret',
    ],
  ),
];

// ── Accounting ───────────────────────────────────────────────────
final List<VisualLabSpec> _accounting = <VisualLabSpec>[
  VisualLabSpec(
    id: 'acc_entry_assemble',
    careerId: 'accounting',
    kind: VisualLabKind.assemble,
    title: 'Journal entry slots',
    brief: 'Place debit/credit pieces correctly.',
    accent: _accA,
    bg: _accB,
    surface: _accS,
    diagramTitle: 'network',
    parts: const <AssemblePart>[
      AssemblePart(id: 'cash_dr', label: 'Cash (Dr)', glyph: '📗'),
      AssemblePart(id: 'rev_cr', label: 'Revenue (Cr)', glyph: '📘'),
      AssemblePart(id: 'exp_dr', label: 'Expense (Dr)', glyph: '📕'),
      AssemblePart(id: 'ap_cr', label: 'AP (Cr)', glyph: '📙'),
    ],
    slots: const <AssembleSlot>[
      AssembleSlot(id: 'sale_dr', name: 'Sale — Debit', correctPartId: 'cash_dr', fx: 0.25, fy: 0.35),
      AssembleSlot(id: 'sale_cr', name: 'Sale — Credit', correctPartId: 'rev_cr', fx: 0.7, fy: 0.35),
      AssembleSlot(id: 'bill_dr', name: 'Bill — Debit', correctPartId: 'exp_dr', fx: 0.25, fy: 0.7),
      AssembleSlot(id: 'bill_cr', name: 'Bill — Credit', correctPartId: 'ap_cr', fx: 0.7, fy: 0.7),
    ],
  ),
  VisualLabSpec(
    id: 'acc_reconcile_measure',
    careerId: 'accounting',
    kind: VisualLabKind.measure,
    title: 'Reconcile balance',
    brief: 'Match the statement balance on the scale.',
    accent: _accA,
    bg: _accB,
    surface: _accS,
    instrument: const MeasureInstrument(
      kind: MeasureInstrumentKind.scale,
      targetValue: 12850,
      unit: 'USD',
      min: 10000,
      max: 15000,
      tolerance: 50,
      label: 'Bank statement',
      displayPrecision: 0,
    ),
  ),
  VisualLabSpec(
    id: 'acc_variance_interpret',
    careerId: 'accounting',
    kind: VisualLabKind.interpret,
    title: 'Variance chart',
    brief: 'Read the budget vs actual chart.',
    accent: _accA,
    bg: _accB,
    surface: _accS,
    interpret: const InterpretScenario(
      visualKind: 'chart',
      prompt: 'Actuals above budget for COGS means…',
      choices: <String>[
        'Unfavorable cost variance',
        'Favorable revenue surprise',
        'No action needed',
        'Assets were revalued',
      ],
      correctIndex: 0,
    ),
  ),
  VisualLabSpec(
    id: 'practical_exam_accounting',
    careerId: 'accounting',
    kind: VisualLabKind.assemble,
    title: 'Close practical',
    brief: 'Entries → reconcile → variance.',
    accent: _accA,
    bg: _accB,
    surface: _accS,
    isPracticalExam: true,
    practicalStepIds: const <String>[
      'acc_entry_assemble',
      'acc_reconcile_measure',
      'acc_variance_interpret',
    ],
  ),
];

// ── Marketing ────────────────────────────────────────────────────
final List<VisualLabSpec> _marketing = <VisualLabSpec>[
  VisualLabSpec(
    id: 'mkt_channel_assemble',
    careerId: 'marketing',
    kind: VisualLabKind.assemble,
    title: 'Channel mix board',
    brief: 'Drop tactics into the right channel.',
    accent: _mktA,
    bg: _mktB,
    surface: _mktS,
    diagramTitle: 'network',
    parts: const <AssemblePart>[
      AssemblePart(id: 'seo', label: 'SEO brief', glyph: '🔍'),
      AssemblePart(id: 'paid', label: 'Paid ads', glyph: '📣'),
      AssemblePart(id: 'email', label: 'Nurture email', glyph: '✉️'),
      AssemblePart(id: 'ugc', label: 'UGC brief', glyph: '📱'),
    ],
    slots: const <AssembleSlot>[
      AssembleSlot(id: 'organic', name: 'Organic', correctPartId: 'seo', fx: 0.25, fy: 0.35),
      AssembleSlot(id: 'paid', name: 'Paid', correctPartId: 'paid', fx: 0.7, fy: 0.35),
      AssembleSlot(id: 'crm', name: 'CRM', correctPartId: 'email', fx: 0.25, fy: 0.7),
      AssembleSlot(id: 'social', name: 'Social', correctPartId: 'ugc', fx: 0.7, fy: 0.7),
    ],
  ),
  VisualLabSpec(
    id: 'mkt_funnel_graph',
    careerId: 'marketing',
    kind: VisualLabKind.graph,
    title: 'Conversion funnel plot',
    brief: 'Plot drop-off and interpret.',
    accent: _mktA,
    bg: _mktB,
    surface: _mktS,
    graph: const GraphScenario(
      xLabel: 'Stage',
      yLabel: 'Users',
      expectedPoints: <Offset>[Offset(0.2, 0.2), Offset(0.45, 0.4), Offset(0.7, 0.65)],
      interpretKeywords: <String>['drop', 'funnel', 'convert', 'leak'],
    ),
  ),
  VisualLabSpec(
    id: 'mkt_creative_prioritize',
    careerId: 'marketing',
    kind: VisualLabKind.prioritize,
    title: 'Creative review order',
    brief: 'Prioritize assets for launch week.',
    accent: _mktA,
    bg: _mktB,
    surface: _mktS,
    prioritizeItems: const <PrioritizeItem>[
      PrioritizeItem(id: 'c1', title: 'Hero video', subtitle: 'Launch day', correctRank: 1),
      PrioritizeItem(id: 'c2', title: 'Landing copy', subtitle: 'Needs legal', correctRank: 2),
      PrioritizeItem(id: 'c3', title: 'Blog series', subtitle: 'Week 2', correctRank: 3),
      PrioritizeItem(id: 'c4', title: 'Sticker pack', subtitle: 'Swag later', correctRank: 4),
    ],
  ),
  VisualLabSpec(
    id: 'practical_exam_marketing',
    careerId: 'marketing',
    kind: VisualLabKind.assemble,
    title: 'Campaign practical',
    brief: 'Channels → funnel → creative order.',
    accent: _mktA,
    bg: _mktB,
    surface: _mktS,
    isPracticalExam: true,
    practicalStepIds: const <String>[
      'mkt_channel_assemble',
      'mkt_funnel_graph',
      'mkt_creative_prioritize',
    ],
  ),
];

// ── Economics ────────────────────────────────────────────────────
final List<VisualLabSpec> _economics = <VisualLabSpec>[
  VisualLabSpec(
    id: 'eco_supply_demand',
    careerId: 'economics',
    kind: VisualLabKind.interpret,
    title: 'Supply–demand shift',
    brief: 'Read the curve shift after a subsidy.',
    accent: _ecoA,
    bg: _ecoB,
    surface: _ecoS,
    interpret: const InterpretScenario(
      visualKind: 'supply_demand',
      prompt: 'A producer subsidy typically shifts supply…',
      choices: <String>['Right / down', 'Left / up', 'Demand only', 'No shift'],
      correctIndex: 0,
      freeTextKeywords: <String>['right', 'increase', 'supply'],
    ),
  ),
  VisualLabSpec(
    id: 'eco_inflation_observe',
    careerId: 'economics',
    kind: VisualLabKind.observe,
    title: 'Policy dashboard',
    brief: 'Adjust rates / spending and observe inflation response.',
    accent: _ecoA,
    bg: _ecoB,
    surface: _ecoS,
    diagramTitle: 'graph',
    observe: const ObserveScenario(
      params: <ObserveParam>[
        ObserveParam(id: 'rate', label: 'Policy rate', min: 0, max: 10, initial: 2, unit: '%'),
        ObserveParam(id: 'spend', label: 'Gov spend', min: 0, max: 100, initial: 50),
      ],
      prompt: 'Raise the rate sharply — what happens to inflation pressure?',
      keywords: <String>['fall', 'cool', 'decrease', 'lower'],
      choices: <String>[
        'Inflation pressure cools',
        'Inflation explodes immediately',
        'Nothing observable',
      ],
      correctChoiceIndex: 0,
      simulationHint: 'Higher rates → cooler demand bars',
    ),
  ),
  VisualLabSpec(
    id: 'eco_phillips_graph',
    careerId: 'economics',
    kind: VisualLabKind.graph,
    title: 'Phillips-style tradeoff',
    brief: 'Plot unemployment vs inflation points.',
    accent: _ecoA,
    bg: _ecoB,
    surface: _ecoS,
    graph: const GraphScenario(
      xLabel: 'Unemployment',
      yLabel: 'Inflation',
      expectedPoints: <Offset>[Offset(0.2, 0.25), Offset(0.5, 0.5), Offset(0.8, 0.75)],
      interpretKeywords: <String>['tradeoff', 'inverse', 'phillips'],
    ),
  ),
  VisualLabSpec(
    id: 'practical_exam_economics',
    careerId: 'economics',
    kind: VisualLabKind.interpret,
    title: 'Policy unit practical',
    brief: 'Curves → observe → Phillips graph.',
    accent: _ecoA,
    bg: _ecoB,
    surface: _ecoS,
    isPracticalExam: true,
    practicalStepIds: const <String>[
      'eco_supply_demand',
      'eco_inflation_observe',
      'eco_phillips_graph',
    ],
  ),
];

// ── CS Career ────────────────────────────────────────────────────
final List<VisualLabSpec> _cs = <VisualLabSpec>[
  VisualLabSpec(
    id: 'cs_arch_assemble',
    careerId: 'cs_career',
    kind: VisualLabKind.assemble,
    title: 'Service architecture',
    brief: 'Place components into the system diagram.',
    accent: _csA,
    bg: _csB,
    surface: _csS,
    diagramTitle: 'network',
    parts: const <AssemblePart>[
      AssemblePart(id: 'api', label: 'API gateway', glyph: '🚪'),
      AssemblePart(id: 'svc', label: 'Worker service', glyph: '⚙️'),
      AssemblePart(id: 'db', label: 'Database', glyph: '🗄️'),
      AssemblePart(id: 'cache', label: 'Cache', glyph: '⚡'),
    ],
    slots: const <AssembleSlot>[
      AssembleSlot(id: 'edge', name: 'Edge', correctPartId: 'api', fx: 0.25, fy: 0.3),
      AssembleSlot(id: 'core', name: 'Core', correctPartId: 'svc', fx: 0.7, fy: 0.35),
      AssembleSlot(id: 'data', name: 'Data', correctPartId: 'db', fx: 0.25, fy: 0.7),
      AssembleSlot(id: 'fast', name: 'Hot path', correctPartId: 'cache', fx: 0.7, fy: 0.7),
    ],
  ),
  VisualLabSpec(
    id: 'cs_algo_path',
    careerId: 'cs_career',
    kind: VisualLabKind.pathTrace,
    title: 'BFS visit order',
    brief: 'Tap nodes in BFS expansion order from the root.',
    accent: _csA,
    bg: _csB,
    surface: _csS,
    diagramTitle: 'network',
    pathOrder: const <String>['A', 'B', 'C', 'D', 'E'],
    pathNodes: const <PathNode>[
      PathNode(id: 'A', label: 'A', fx: 0.5, fy: 0.2),
      PathNode(id: 'B', label: 'B', fx: 0.3, fy: 0.45),
      PathNode(id: 'C', label: 'C', fx: 0.7, fy: 0.45),
      PathNode(id: 'D', label: 'D', fx: 0.2, fy: 0.75),
      PathNode(id: 'E', label: 'E', fx: 0.4, fy: 0.75),
    ],
  ),
  VisualLabSpec(
    id: 'cs_latency_graph',
    careerId: 'cs_career',
    kind: VisualLabKind.graph,
    title: 'Latency under load',
    brief: 'Plot RPS vs p99 and interpret saturation.',
    accent: _csA,
    bg: _csB,
    surface: _csS,
    graph: const GraphScenario(
      xLabel: 'RPS',
      yLabel: 'p99 ms',
      expectedPoints: <Offset>[Offset(0.2, 0.7), Offset(0.5, 0.5), Offset(0.8, 0.2)],
      interpretKeywords: <String>['latency', 'saturat', 'increase', 'load'],
    ),
  ),
  VisualLabSpec(
    id: 'practical_exam_cs_career',
    careerId: 'cs_career',
    kind: VisualLabKind.assemble,
    title: 'Eng floor practical',
    brief: 'Architecture → BFS path → latency graph.',
    accent: _csA,
    bg: _csB,
    surface: _csS,
    isPracticalExam: true,
    practicalStepIds: const <String>['cs_arch_assemble', 'cs_algo_path', 'cs_latency_graph'],
  ),
];

// ── Psychology ───────────────────────────────────────────────────
final List<VisualLabSpec> _psychology = <VisualLabSpec>[
  VisualLabSpec(
    id: 'psy_brain_label',
    careerId: 'psychology',
    kind: VisualLabKind.label,
    title: 'Brain region labels',
    brief: 'Label major regions on the brain silhouette.',
    accent: _psyA,
    bg: _psyB,
    surface: _psyS,
    difficulty: LabelDifficulty.beginner,
    diagramTitle: 'brain',
    wordBank: const <String>['Frontal', 'Parietal', 'Temporal', 'Occipital'],
    hotspots: const <Hotspot>[
      Hotspot(id: 'f', correctLabel: 'Frontal', fx: 0.35, fy: 0.4),
      Hotspot(id: 'p', correctLabel: 'Parietal', fx: 0.55, fy: 0.32),
      Hotspot(id: 't', correctLabel: 'Temporal', fx: 0.45, fy: 0.58),
      Hotspot(id: 'o', correctLabel: 'Occipital', fx: 0.72, fy: 0.45),
    ],
  ),
  VisualLabSpec(
    id: 'psy_experiment_observe',
    careerId: 'psychology',
    kind: VisualLabKind.observe,
    title: 'Stroop-style observe',
    brief: 'Change interference and observe response time.',
    accent: _psyA,
    bg: _psyB,
    surface: _psyS,
    diagramTitle: 'brain',
    observe: const ObserveScenario(
      params: <ObserveParam>[
        ObserveParam(id: 'interference', label: 'Interference', min: 0, max: 100, initial: 20),
        ObserveParam(id: 'fatigue', label: 'Fatigue', min: 0, max: 100, initial: 10),
      ],
      prompt: 'Increase interference — what happens to error / RT?',
      keywords: <String>['increase', 'slower', 'error', 'worse'],
      choices: <String>[
        'Errors / RT worsen',
        'Performance improves',
        'No change',
      ],
      correctChoiceIndex: 0,
      simulationHint: 'Bars rise with interference',
    ),
  ),
  VisualLabSpec(
    id: 'psy_condition_prioritize',
    careerId: 'psychology',
    kind: VisualLabKind.prioritize,
    title: 'Session priority',
    brief: 'Order participant needs for the lab day.',
    accent: _psyA,
    bg: _psyB,
    surface: _psyS,
    prioritizeItems: const <PrioritizeItem>[
      PrioritizeItem(id: 'x1', title: 'Consent incomplete', subtitle: 'Cannot run', correctRank: 1),
      PrioritizeItem(id: 'x2', title: 'Calibration due', subtitle: 'Equipment', correctRank: 2),
      PrioritizeItem(id: 'x3', title: 'Debrief notes', subtitle: 'After run', correctRank: 3),
      PrioritizeItem(id: 'x4', title: 'Poster print', subtitle: 'Next week', correctRank: 4),
    ],
  ),
  VisualLabSpec(
    id: 'practical_exam_psychology',
    careerId: 'psychology',
    kind: VisualLabKind.label,
    title: 'Behavioral lab practical',
    brief: 'Brain labels → observe → session priority.',
    accent: _psyA,
    bg: _psyB,
    surface: _psyS,
    isPracticalExam: true,
    practicalStepIds: const <String>[
      'psy_brain_label',
      'psy_experiment_observe',
      'psy_condition_prioritize',
    ],
  ),
];

// ── Biology ──────────────────────────────────────────────────────
final List<VisualLabSpec> _biology = <VisualLabSpec>[
  VisualLabSpec(
    id: 'bio_cell_label',
    careerId: 'biology',
    kind: VisualLabKind.label,
    title: 'Cell organelle labels',
    brief: 'Label nucleus, mitochondria, membrane, cytoplasm.',
    accent: _bioA,
    bg: _bioB,
    surface: _bioS,
    difficulty: LabelDifficulty.intermediate,
    diagramTitle: 'cell',
    wordBank: const <String>['Nucleus', 'Mitochondria', 'Membrane', 'Cytoplasm', 'Ribosome'],
    hotspots: const <Hotspot>[
      Hotspot(id: 'n', correctLabel: 'Nucleus', fx: 0.5, fy: 0.48),
      Hotspot(id: 'm', correctLabel: 'Mitochondria', fx: 0.68, fy: 0.4),
      Hotspot(id: 'mem', correctLabel: 'Membrane', fx: 0.22, fy: 0.5),
      Hotspot(id: 'cy', correctLabel: 'Cytoplasm', fx: 0.4, fy: 0.62),
    ],
  ),
  VisualLabSpec(
    id: 'bio_scope_measure',
    careerId: 'biology',
    kind: VisualLabKind.measure,
    title: 'Microscope field measure',
    brief: 'Set the ocular micrometer to the specimen size.',
    accent: _bioA,
    bg: _bioB,
    surface: _bioS,
    instrument: const MeasureInstrument(
      kind: MeasureInstrumentKind.ruler,
      targetValue: 40,
      unit: 'µm',
      min: 5,
      max: 100,
      tolerance: 3,
      label: 'Specimen diameter',
      displayPrecision: 0,
    ),
  ),
  VisualLabSpec(
    id: 'bio_dna_assemble',
    careerId: 'biology',
    kind: VisualLabKind.assemble,
    title: 'DNA base pairing',
    brief: 'Seat complementary bases into slots.',
    accent: _bioA,
    bg: _bioB,
    surface: _bioS,
    diagramTitle: 'dna',
    parts: const <AssemblePart>[
      AssemblePart(id: 'a', label: 'Adenine', glyph: 'A'),
      AssemblePart(id: 't', label: 'Thymine', glyph: 'T'),
      AssemblePart(id: 'g', label: 'Guanine', glyph: 'G'),
      AssemblePart(id: 'c', label: 'Cytosine', glyph: 'C'),
    ],
    slots: const <AssembleSlot>[
      AssembleSlot(id: 'pair_t', name: 'Pairs with A', correctPartId: 't', fx: 0.3, fy: 0.35),
      AssembleSlot(id: 'pair_a', name: 'Pairs with T', correctPartId: 'a', fx: 0.7, fy: 0.35),
      AssembleSlot(id: 'pair_c', name: 'Pairs with G', correctPartId: 'c', fx: 0.3, fy: 0.7),
      AssembleSlot(id: 'pair_g', name: 'Pairs with C', correctPartId: 'g', fx: 0.7, fy: 0.7),
    ],
  ),
  VisualLabSpec(
    id: 'practical_exam_biology',
    careerId: 'biology',
    kind: VisualLabKind.label,
    title: 'Bench practical',
    brief: 'Cell labels → measure → DNA assemble.',
    accent: _bioA,
    bg: _bioB,
    surface: _bioS,
    isPracticalExam: true,
    practicalStepIds: const <String>['bio_cell_label', 'bio_scope_measure', 'bio_dna_assemble'],
  ),
];

// ── Chemistry ────────────────────────────────────────────────────
final List<VisualLabSpec> _chemistry = <VisualLabSpec>[
  VisualLabSpec(
    id: 'chem_apparatus_assemble',
    careerId: 'chemistry',
    kind: VisualLabKind.assemble,
    title: 'Titration apparatus',
    brief: 'Assemble burette, flask, stand, indicator.',
    accent: _chemA,
    bg: _chemB,
    surface: _chemS,
    diagramTitle: 'beaker',
    parts: const <AssemblePart>[
      AssemblePart(id: 'burette', label: 'Burette', glyph: '📏'),
      AssemblePart(id: 'flask', label: 'Erlenmeyer', glyph: '🧪'),
      AssemblePart(id: 'stand', label: 'Stand/clamp', glyph: '🔩'),
      AssemblePart(id: 'ind', label: 'Indicator', glyph: '💧'),
    ],
    slots: const <AssembleSlot>[
      AssembleSlot(id: 'top', name: 'Dispenser', correctPartId: 'burette', fx: 0.5, fy: 0.25),
      AssembleSlot(id: 'vessel', name: 'Reaction vessel', correctPartId: 'flask', fx: 0.5, fy: 0.65),
      AssembleSlot(id: 'support', name: 'Support', correctPartId: 'stand', fx: 0.22, fy: 0.45),
      AssembleSlot(id: 'dye', name: 'Endpoint cue', correctPartId: 'ind', fx: 0.78, fy: 0.55),
    ],
  ),
  VisualLabSpec(
    id: 'chem_reaction_observe',
    careerId: 'chemistry',
    kind: VisualLabKind.observe,
    title: 'Reaction observe',
    brief: 'Heat the mixture and record what you see.',
    accent: _chemA,
    bg: _chemB,
    surface: _chemS,
    diagramTitle: 'beaker',
    observe: const ObserveScenario(
      params: <ObserveParam>[
        ObserveParam(id: 'temp', label: 'Temp', min: 20, max: 100, initial: 25, unit: '°C'),
        ObserveParam(id: 'conc', label: 'Conc', min: 0, max: 100, initial: 40),
      ],
      prompt: 'Raise temperature — what happens in the flask?',
      keywords: <String>['bubble', 'faster', 'reaction', 'rate', 'gas'],
      choices: <String>[
        'Reaction rate / bubbling increases',
        'Everything freezes',
        'Color vanishes instantly with no heat link',
      ],
      correctChoiceIndex: 0,
      simulationHint: 'Bubbles scale with heat',
    ),
  ),
  VisualLabSpec(
    id: 'chem_titration_measure',
    careerId: 'chemistry',
    kind: VisualLabKind.measure,
    title: 'Titration volume',
    brief: 'Read burette volume at endpoint.',
    accent: _chemA,
    bg: _chemB,
    surface: _chemS,
    instrument: const MeasureInstrument(
      kind: MeasureInstrumentKind.pipette,
      targetValue: 24.5,
      unit: 'mL',
      min: 0,
      max: 50,
      tolerance: 0.5,
      label: 'Endpoint volume',
      displayPrecision: 1,
    ),
  ),
  VisualLabSpec(
    id: 'practical_exam_chemistry',
    careerId: 'chemistry',
    kind: VisualLabKind.assemble,
    title: 'Chem lab practical',
    brief: 'Apparatus → observe → titration volume.',
    accent: _chemA,
    bg: _chemB,
    surface: _chemS,
    isPracticalExam: true,
    practicalStepIds: const <String>[
      'chem_apparatus_assemble',
      'chem_reaction_observe',
      'chem_titration_measure',
    ],
  ),
];

// ── Physics ──────────────────────────────────────────────────────
final List<VisualLabSpec> _physics = <VisualLabSpec>[
  VisualLabSpec(
    id: 'phy_force_observe',
    careerId: 'physics',
    kind: VisualLabKind.observe,
    title: 'Force & mass observe',
    brief: 'Vary force/mass and observe acceleration bars.',
    accent: _phyA,
    bg: _phyB,
    surface: _phyS,
    diagramTitle: 'body',
    observe: const ObserveScenario(
      params: <ObserveParam>[
        ObserveParam(id: 'force', label: 'Force', min: 1, max: 20, initial: 5, unit: 'N'),
        ObserveParam(id: 'mass', label: 'Mass', min: 1, max: 10, initial: 2, unit: 'kg'),
      ],
      prompt: 'Double force at fixed mass — acceleration…',
      keywords: <String>['double', 'increase', 'accel'],
      choices: <String>[
        'Acceleration roughly doubles',
        'Acceleration halves',
        'Mass changes instead',
      ],
      correctChoiceIndex: 0,
      simulationHint: 'a ∝ F/m',
    ),
  ),
  VisualLabSpec(
    id: 'phy_motion_graph',
    careerId: 'physics',
    kind: VisualLabKind.graph,
    title: 'Motion graph',
    brief: 'Plot position vs time for constant velocity.',
    accent: _phyA,
    bg: _phyB,
    surface: _phyS,
    graph: const GraphScenario(
      xLabel: 'Time',
      yLabel: 'Position',
      expectedPoints: <Offset>[Offset(0.15, 0.75), Offset(0.45, 0.5), Offset(0.8, 0.2)],
      interpretKeywords: <String>['linear', 'constant', 'velocity', 'slope'],
    ),
  ),
  VisualLabSpec(
    id: 'phy_circuit_assemble',
    careerId: 'physics',
    kind: VisualLabKind.assemble,
    title: 'Simple circuit assemble',
    brief: 'Place battery, resistor, lamp, switch.',
    accent: _phyA,
    bg: _phyB,
    surface: _phyS,
    diagramTitle: 'circuit',
    parts: const <AssemblePart>[
      AssemblePart(id: 'bat', label: 'Battery', glyph: '🔋'),
      AssemblePart(id: 'r', label: 'Resistor', glyph: '∿'),
      AssemblePart(id: 'lamp', label: 'Lamp', glyph: '💡'),
      AssemblePart(id: 'sw', label: 'Switch', glyph: '⏻'),
    ],
    slots: const <AssembleSlot>[
      AssembleSlot(id: 'src', name: 'Source', correctPartId: 'bat', fx: 0.2, fy: 0.5),
      AssembleSlot(id: 'load_r', name: 'Limiter', correctPartId: 'r', fx: 0.45, fy: 0.35),
      AssembleSlot(id: 'load_l', name: 'Output', correctPartId: 'lamp', fx: 0.7, fy: 0.55),
      AssembleSlot(id: 'ctrl', name: 'Control', correctPartId: 'sw', fx: 0.5, fy: 0.75),
    ],
  ),
  VisualLabSpec(
    id: 'practical_exam_physics',
    careerId: 'physics',
    kind: VisualLabKind.observe,
    title: 'Physics lab practical',
    brief: 'Force observe → motion graph → circuit.',
    accent: _phyA,
    bg: _phyB,
    surface: _phyS,
    isPracticalExam: true,
    practicalStepIds: const <String>[
      'phy_force_observe',
      'phy_motion_graph',
      'phy_circuit_assemble',
    ],
  ),
];

// ── Engineering ──────────────────────────────────────────────────
final List<VisualLabSpec> _engineering = <VisualLabSpec>[
  VisualLabSpec(
    id: 'eng_bridge_assemble',
    careerId: 'engineering',
    kind: VisualLabKind.assemble,
    title: 'Truss member assemble',
    brief: 'Seat deck, cables, pier, joint plates.',
    accent: _engA,
    bg: _engB,
    surface: _engS,
    diagramTitle: 'bridge',
    parts: const <AssemblePart>[
      AssemblePart(id: 'deck', label: 'Deck', glyph: '🛣️'),
      AssemblePart(id: 'cable', label: 'Cable', glyph: '🧵'),
      AssemblePart(id: 'pier', label: 'Pier', glyph: '🏛️'),
      AssemblePart(id: 'joint', label: 'Joint plate', glyph: '🔩'),
    ],
    slots: const <AssembleSlot>[
      AssembleSlot(id: 'd', name: 'Span', correctPartId: 'deck', fx: 0.5, fy: 0.55),
      AssembleSlot(id: 'c', name: 'Tension', correctPartId: 'cable', fx: 0.5, fy: 0.3),
      AssembleSlot(id: 'p', name: 'Support', correctPartId: 'pier', fx: 0.2, fy: 0.7),
      AssembleSlot(id: 'j', name: 'Node', correctPartId: 'joint', fx: 0.75, fy: 0.45),
    ],
  ),
  VisualLabSpec(
    id: 'eng_load_measure',
    careerId: 'engineering',
    kind: VisualLabKind.measure,
    title: 'Load cell reading',
    brief: 'Match the design load on the scale.',
    accent: _engA,
    bg: _engB,
    surface: _engS,
    instrument: const MeasureInstrument(
      kind: MeasureInstrumentKind.scale,
      targetValue: 12.5,
      unit: 'kN',
      min: 0,
      max: 25,
      tolerance: 0.5,
      label: 'Live load',
      displayPrecision: 1,
    ),
  ),
  VisualLabSpec(
    id: 'eng_failure_interpret',
    careerId: 'engineering',
    kind: VisualLabKind.interpret,
    title: 'Failure mode read',
    brief: 'Interpret the stress visual.',
    accent: _engA,
    bg: _engB,
    surface: _engS,
    interpret: const InterpretScenario(
      visualKind: 'chart',
      prompt: 'Hotspot at midspan under overload suggests…',
      choices: <String>[
        'Bending stress concentration',
        'Perfectly safe design',
        'Only aesthetic cracking',
        'Electrical fault',
      ],
      correctIndex: 0,
    ),
  ),
  VisualLabSpec(
    id: 'practical_exam_engineering',
    careerId: 'engineering',
    kind: VisualLabKind.assemble,
    title: 'Studio practical',
    brief: 'Truss → load → failure interpret.',
    accent: _engA,
    bg: _engB,
    surface: _engS,
    isPracticalExam: true,
    practicalStepIds: const <String>[
      'eng_bridge_assemble',
      'eng_load_measure',
      'eng_failure_interpret',
    ],
  ),
];

// ── Mathematics ──────────────────────────────────────────────────
final List<VisualLabSpec> _mathematics = <VisualLabSpec>[
  VisualLabSpec(
    id: 'math_model_graph',
    careerId: 'mathematics',
    kind: VisualLabKind.graph,
    title: 'Cost model graph',
    brief: 'Plot shipping cost vs distance.',
    accent: _mathA,
    bg: _mathB,
    surface: _mathS,
    graph: const GraphScenario(
      xLabel: 'Distance',
      yLabel: 'Cost',
      expectedPoints: <Offset>[Offset(0.2, 0.7), Offset(0.5, 0.45), Offset(0.85, 0.2)],
      interpretKeywords: <String>['linear', 'increase', 'slope', 'cost'],
    ),
  ),
  VisualLabSpec(
    id: 'math_constraint_assemble',
    careerId: 'mathematics',
    kind: VisualLabKind.assemble,
    title: 'LP constraint board',
    brief: 'Place objective and constraints into roles.',
    accent: _mathA,
    bg: _mathB,
    surface: _mathS,
    diagramTitle: 'graph',
    parts: const <AssemblePart>[
      AssemblePart(id: 'obj', label: 'Maximize Z', glyph: '🎯'),
      AssemblePart(id: 'c1', label: 'x + y ≤ 10', glyph: '①'),
      AssemblePart(id: 'c2', label: 'x ≥ 0', glyph: '②'),
      AssemblePart(id: 'c3', label: 'y ≥ 0', glyph: '③'),
    ],
    slots: const <AssembleSlot>[
      AssembleSlot(id: 'o', name: 'Objective', correctPartId: 'obj', fx: 0.5, fy: 0.25),
      AssembleSlot(id: 'a', name: 'Resource cap', correctPartId: 'c1', fx: 0.3, fy: 0.55),
      AssembleSlot(id: 'b', name: 'Nonneg x', correctPartId: 'c2', fx: 0.7, fy: 0.55),
      AssembleSlot(id: 'c', name: 'Nonneg y', correctPartId: 'c3', fx: 0.5, fy: 0.78),
    ],
  ),
  VisualLabSpec(
    id: 'math_derivative_interpret',
    careerId: 'mathematics',
    kind: VisualLabKind.interpret,
    title: 'Slope interpret',
    brief: 'Read the curve and choose the slope meaning.',
    accent: _mathA,
    bg: _mathB,
    surface: _mathS,
    interpret: const InterpretScenario(
      visualKind: 'chart',
      prompt: 'A positive constant slope means…',
      choices: <String>[
        'Constant positive rate of change',
        'Zero change forever',
        'Acceleration only',
        'Undefined function',
      ],
      correctIndex: 0,
    ),
  ),
  VisualLabSpec(
    id: 'practical_exam_mathematics',
    careerId: 'mathematics',
    kind: VisualLabKind.graph,
    title: 'Analytics practical',
    brief: 'Cost graph → LP assemble → slope interpret.',
    accent: _mathA,
    bg: _mathB,
    surface: _mathS,
    isPracticalExam: true,
    practicalStepIds: const <String>[
      'math_model_graph',
      'math_constraint_assemble',
      'math_derivative_interpret',
    ],
  ),
];

// ── Civil Engineering ────────────────────────────────────────────
final List<VisualLabSpec> _civil = <VisualLabSpec>[
  VisualLabSpec(
    id: 'civ_site_prioritize',
    careerId: 'civil_engineering',
    kind: VisualLabKind.prioritize,
    title: 'Jobsite triage',
    brief: 'Rank weather / safety / schedule items.',
    accent: _civA,
    bg: _civB,
    surface: _civS,
    prioritizeItems: const <PrioritizeItem>[
      PrioritizeItem(id: 'j1', title: 'Crane wind limit', subtitle: 'Safety stop', correctRank: 1),
      PrioritizeItem(id: 'j2', title: 'Pour window', subtitle: 'Today 2pm', correctRank: 2),
      PrioritizeItem(id: 'j3', title: 'Material RFI', subtitle: 'This week', correctRank: 3),
      PrioritizeItem(id: 'j4', title: 'Trailer coffee', subtitle: 'Anytime', correctRank: 4),
    ],
  ),
  VisualLabSpec(
    id: 'civ_bridge_label',
    careerId: 'civil_engineering',
    kind: VisualLabKind.label,
    title: 'Bridge elements',
    brief: 'Label pier, deck, abutment, cable.',
    accent: _civA,
    bg: _civB,
    surface: _civS,
    difficulty: LabelDifficulty.beginner,
    diagramTitle: 'bridge',
    wordBank: const <String>['Pier', 'Deck', 'Abutment', 'Cable'],
    hotspots: const <Hotspot>[
      Hotspot(id: 'pier', correctLabel: 'Pier', fx: 0.3, fy: 0.7),
      Hotspot(id: 'deck', correctLabel: 'Deck', fx: 0.5, fy: 0.55),
      Hotspot(id: 'abut', correctLabel: 'Abutment', fx: 0.15, fy: 0.65),
      Hotspot(id: 'cable', correctLabel: 'Cable', fx: 0.55, fy: 0.35),
    ],
  ),
  VisualLabSpec(
    id: 'civ_settle_measure',
    careerId: 'civil_engineering',
    kind: VisualLabKind.measure,
    title: 'Settlement reading',
    brief: 'Match survey rod settlement value.',
    accent: _civA,
    bg: _civB,
    surface: _civS,
    instrument: const MeasureInstrument(
      kind: MeasureInstrumentKind.ruler,
      targetValue: 12,
      unit: 'mm',
      min: 0,
      max: 40,
      tolerance: 1,
      label: 'Settlement',
      displayPrecision: 0,
    ),
  ),
  VisualLabSpec(
    id: 'practical_exam_civil_engineering',
    careerId: 'civil_engineering',
    kind: VisualLabKind.prioritize,
    title: 'Jobsite practical',
    brief: 'Triage → bridge labels → settlement.',
    accent: _civA,
    bg: _civB,
    surface: _civS,
    isPracticalExam: true,
    practicalStepIds: const <String>[
      'civ_site_prioritize',
      'civ_bridge_label',
      'civ_settle_measure',
    ],
  ),
];

// ── Electrical Engineering ───────────────────────────────────────
final List<VisualLabSpec> _electrical = <VisualLabSpec>[
  VisualLabSpec(
    id: 'ee_circuit_assemble',
    careerId: 'electrical_engineering',
    kind: VisualLabKind.assemble,
    title: 'EE lab circuit',
    brief: 'Assemble source, load, meter, ground.',
    accent: _eeA,
    bg: _eeB,
    surface: _eeS,
    diagramTitle: 'circuit',
    parts: const <AssemblePart>[
      AssemblePart(id: 'src', label: 'DC source', glyph: '🔋'),
      AssemblePart(id: 'load', label: 'Load R', glyph: '∿'),
      AssemblePart(id: 'meter', label: 'Voltmeter', glyph: '📟'),
      AssemblePart(id: 'gnd', label: 'Ground', glyph: '⏚'),
    ],
    slots: const <AssembleSlot>[
      AssembleSlot(id: 's', name: 'Source', correctPartId: 'src', fx: 0.2, fy: 0.45),
      AssembleSlot(id: 'l', name: 'Load', correctPartId: 'load', fx: 0.55, fy: 0.35),
      AssembleSlot(id: 'm', name: 'Measure', correctPartId: 'meter', fx: 0.75, fy: 0.55),
      AssembleSlot(id: 'g', name: 'Reference', correctPartId: 'gnd', fx: 0.45, fy: 0.75),
    ],
  ),
  VisualLabSpec(
    id: 'ee_volt_measure',
    careerId: 'electrical_engineering',
    kind: VisualLabKind.measure,
    title: 'Voltmeter check',
    brief: 'Dial to the node voltage and record.',
    accent: _eeA,
    bg: _eeB,
    surface: _eeS,
    instrument: const MeasureInstrument(
      kind: MeasureInstrumentKind.voltmeter,
      targetValue: 5.0,
      unit: 'V',
      min: 0,
      max: 12,
      tolerance: 0.2,
      label: 'Node voltage',
      displayPrecision: 1,
    ),
  ),
  VisualLabSpec(
    id: 'ee_fault_path',
    careerId: 'electrical_engineering',
    kind: VisualLabKind.pathTrace,
    title: 'Fault isolation path',
    brief: 'Trace diagnose → isolate → replace → verify.',
    accent: _eeA,
    bg: _eeB,
    surface: _eeS,
    diagramTitle: 'circuit',
    pathOrder: const <String>['diagnose', 'isolate', 'replace', 'verify'],
    pathNodes: const <PathNode>[
      PathNode(id: 'diagnose', label: 'Diagnose', fx: 0.2, fy: 0.5),
      PathNode(id: 'isolate', label: 'Isolate', fx: 0.4, fy: 0.35),
      PathNode(id: 'replace', label: 'Replace', fx: 0.65, fy: 0.45),
      PathNode(id: 'verify', label: 'Verify', fx: 0.85, fy: 0.55),
    ],
  ),
  VisualLabSpec(
    id: 'practical_exam_electrical_engineering',
    careerId: 'electrical_engineering',
    kind: VisualLabKind.assemble,
    title: 'EE practical',
    brief: 'Circuit → voltmeter → fault path.',
    accent: _eeA,
    bg: _eeB,
    surface: _eeS,
    isPracticalExam: true,
    practicalStepIds: const <String>[
      'ee_circuit_assemble',
      'ee_volt_measure',
      'ee_fault_path',
    ],
  ),
];

// ── Medical Lab Science ──────────────────────────────────────────
final List<VisualLabSpec> _mls = <VisualLabSpec>[
  VisualLabSpec(
    id: 'mls_pipeline_path',
    careerId: 'medical_lab_science',
    kind: VisualLabKind.pathTrace,
    title: 'Specimen pipeline',
    brief: 'Receive → prepare → test → report.',
    accent: _mlsA,
    bg: _mlsB,
    surface: _mlsS,
    diagramTitle: 'beaker',
    pathOrder: const <String>['receive', 'prepare', 'test', 'report'],
    pathNodes: const <PathNode>[
      PathNode(id: 'receive', label: 'Receive', fx: 0.2, fy: 0.5),
      PathNode(id: 'prepare', label: 'Prepare', fx: 0.4, fy: 0.35),
      PathNode(id: 'test', label: 'Test', fx: 0.65, fy: 0.45),
      PathNode(id: 'report', label: 'Report', fx: 0.85, fy: 0.55),
    ],
  ),
  VisualLabSpec(
    id: 'mls_panel_measure',
    careerId: 'medical_lab_science',
    kind: VisualLabKind.measure,
    title: 'Analyzer absorbance',
    brief: 'Match the spectrophotometer reading.',
    accent: _mlsA,
    bg: _mlsB,
    surface: _mlsS,
    instrument: const MeasureInstrument(
      kind: MeasureInstrumentKind.spectrometer,
      targetValue: 0.42,
      unit: 'AU',
      min: 0,
      max: 1,
      tolerance: 0.05,
      label: 'Absorbance',
      displayPrecision: 2,
    ),
  ),
  VisualLabSpec(
    id: 'mls_critical_prioritize',
    careerId: 'medical_lab_science',
    kind: VisualLabKind.prioritize,
    title: 'Critical value board',
    brief: 'Rank callbacks Immediate → Low.',
    accent: _mlsA,
    bg: _mlsB,
    surface: _mlsS,
    prioritizeItems: const <PrioritizeItem>[
      PrioritizeItem(id: 'k1', title: 'K+ 6.8', subtitle: 'Critical chemistry', correctRank: 1),
      PrioritizeItem(id: 'k2', title: 'Troponin rising', subtitle: 'Urgent panel', correctRank: 2),
      PrioritizeItem(id: 'k3', title: 'Routine CBC', subtitle: 'Same day', correctRank: 3),
      PrioritizeItem(id: 'k4', title: 'Research aliquot', subtitle: 'Banked', correctRank: 4),
    ],
  ),
  VisualLabSpec(
    id: 'practical_exam_medical_lab_science',
    careerId: 'medical_lab_science',
    kind: VisualLabKind.pathTrace,
    title: 'Core lab practical',
    brief: 'Pipeline → absorbance → criticals.',
    accent: _mlsA,
    bg: _mlsB,
    surface: _mlsS,
    isPracticalExam: true,
    practicalStepIds: const <String>[
      'mls_pipeline_path',
      'mls_panel_measure',
      'mls_critical_prioritize',
    ],
  ),
];

// ── Pharmacy ─────────────────────────────────────────────────────
final List<VisualLabSpec> _pharmacy = <VisualLabSpec>[
  VisualLabSpec(
    id: 'pharm_verify_assemble',
    careerId: 'pharmacy',
    kind: VisualLabKind.assemble,
    title: 'Rx verification slots',
    brief: 'Match drug, dose, route, frequency checks.',
    accent: _pharmA,
    bg: _pharmB,
    surface: _pharmS,
    diagramTitle: 'body',
    parts: const <AssemblePart>[
      AssemblePart(id: 'drug', label: 'Drug ID', glyph: '💊'),
      AssemblePart(id: 'dose', label: 'Dose check', glyph: '⚖️'),
      AssemblePart(id: 'route', label: 'Route', glyph: '➡️'),
      AssemblePart(id: 'freq', label: 'Frequency', glyph: '⏱️'),
    ],
    slots: const <AssembleSlot>[
      AssembleSlot(id: 'a', name: 'Identity', correctPartId: 'drug', fx: 0.25, fy: 0.35),
      AssembleSlot(id: 'b', name: 'Strength', correctPartId: 'dose', fx: 0.7, fy: 0.35),
      AssembleSlot(id: 'c', name: 'Administration', correctPartId: 'route', fx: 0.25, fy: 0.7),
      AssembleSlot(id: 'd', name: 'Schedule', correctPartId: 'freq', fx: 0.7, fy: 0.7),
    ],
  ),
  VisualLabSpec(
    id: 'pharm_bp_measure',
    careerId: 'pharmacy',
    kind: VisualLabKind.measure,
    title: 'Counseling BP check',
    brief: 'Dial cuff to the patient reading.',
    accent: _pharmA,
    bg: _pharmB,
    surface: _pharmS,
    instrument: const MeasureInstrument(
      kind: MeasureInstrumentKind.bpCuff,
      targetValue: 128,
      unit: 'mmHg',
      min: 80,
      max: 180,
      tolerance: 3,
      label: 'Systolic',
      displayPrecision: 0,
    ),
  ),
  VisualLabSpec(
    id: 'pharm_interact_prioritize',
    careerId: 'pharmacy',
    kind: VisualLabKind.prioritize,
    title: 'Interaction triage',
    brief: 'Rank interaction severity for callback.',
    accent: _pharmA,
    bg: _pharmB,
    surface: _pharmS,
    prioritizeItems: const <PrioritizeItem>[
      PrioritizeItem(id: 'i1', title: 'Warfarin + NSAID', subtitle: 'Bleed risk', correctRank: 1),
      PrioritizeItem(id: 'i2', title: 'Statin + grapefruit', subtitle: 'Counsel soon', correctRank: 2),
      PrioritizeItem(id: 'i3', title: 'Duplicate OTC', subtitle: 'Educate', correctRank: 3),
      PrioritizeItem(id: 'i4', title: 'Flavor preference', subtitle: 'Convenience', correctRank: 4),
    ],
  ),
  VisualLabSpec(
    id: 'practical_exam_pharmacy',
    careerId: 'pharmacy',
    kind: VisualLabKind.assemble,
    title: 'Dispensary practical',
    brief: 'Verify → BP → interaction triage.',
    accent: _pharmA,
    bg: _pharmB,
    surface: _pharmS,
    isPracticalExam: true,
    practicalStepIds: const <String>[
      'pharm_verify_assemble',
      'pharm_bp_measure',
      'pharm_interact_prioritize',
    ],
  ),
];

// ── Cybersecurity ────────────────────────────────────────────────
final List<VisualLabSpec> _cyber = <VisualLabSpec>[
  VisualLabSpec(
    id: 'cyber_network_assemble',
    careerId: 'cybersecurity',
    kind: VisualLabKind.assemble,
    title: 'SOC network map',
    brief: 'Place firewall, IDS, jump box, SIEM.',
    accent: _cyberA,
    bg: _cyberB,
    surface: _cyberS,
    diagramTitle: 'network',
    parts: const <AssemblePart>[
      AssemblePart(id: 'fw', label: 'Firewall', glyph: '🧱'),
      AssemblePart(id: 'ids', label: 'IDS', glyph: '👁️'),
      AssemblePart(id: 'jump', label: 'Jump box', glyph: '🖥️'),
      AssemblePart(id: 'siem', label: 'SIEM', glyph: '📡'),
    ],
    slots: const <AssembleSlot>[
      AssembleSlot(id: 'edge', name: 'Perimeter', correctPartId: 'fw', fx: 0.25, fy: 0.3),
      AssembleSlot(id: 'detect', name: 'Detect', correctPartId: 'ids', fx: 0.7, fy: 0.35),
      AssembleSlot(id: 'admin', name: 'Admin path', correctPartId: 'jump', fx: 0.25, fy: 0.7),
      AssembleSlot(id: 'corr', name: 'Correlate', correctPartId: 'siem', fx: 0.7, fy: 0.7),
    ],
  ),
  VisualLabSpec(
    id: 'cyber_ir_prioritize',
    careerId: 'cybersecurity',
    kind: VisualLabKind.prioritize,
    title: 'Incident response order',
    brief: 'Rank IR actions Immediate → Low.',
    accent: _cyberA,
    bg: _cyberB,
    surface: _cyberS,
    prioritizeItems: const <PrioritizeItem>[
      PrioritizeItem(id: 'r1', title: 'Contain ransomware host', subtitle: 'Isolate now', correctRank: 1),
      PrioritizeItem(id: 'r2', title: 'Preserve volatile memory', subtitle: 'Evidence', correctRank: 2),
      PrioritizeItem(id: 'r3', title: 'Stakeholder update', subtitle: 'Comms', correctRank: 3),
      PrioritizeItem(id: 'r4', title: 'Postmortem template', subtitle: 'Later', correctRank: 4),
    ],
  ),
  VisualLabSpec(
    id: 'cyber_killchain_path',
    careerId: 'cybersecurity',
    kind: VisualLabKind.pathTrace,
    title: 'Kill chain path',
    brief: 'Tap recon → weaponize → deliver → exploit.',
    accent: _cyberA,
    bg: _cyberB,
    surface: _cyberS,
    diagramTitle: 'network',
    pathOrder: const <String>['recon', 'weaponize', 'deliver', 'exploit'],
    pathNodes: const <PathNode>[
      PathNode(id: 'recon', label: 'Recon', fx: 0.2, fy: 0.5),
      PathNode(id: 'weaponize', label: 'Weaponize', fx: 0.4, fy: 0.35),
      PathNode(id: 'deliver', label: 'Deliver', fx: 0.65, fy: 0.45),
      PathNode(id: 'exploit', label: 'Exploit', fx: 0.85, fy: 0.55),
    ],
  ),
  VisualLabSpec(
    id: 'practical_exam_cybersecurity',
    careerId: 'cybersecurity',
    kind: VisualLabKind.assemble,
    title: 'SOC practical',
    brief: 'Network map → IR prioritize → kill chain.',
    accent: _cyberA,
    bg: _cyberB,
    surface: _cyberS,
    isPracticalExam: true,
    practicalStepIds: const <String>[
      'cyber_network_assemble',
      'cyber_ir_prioritize',
      'cyber_killchain_path',
    ],
  ),
];
