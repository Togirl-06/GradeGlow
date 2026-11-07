/// Numeric laboratory panels (values, units, reference ranges and flags) for
/// the hospital cases, shown in the patient record like a real lab report.
///
/// Every value agrees with the case's written result: tests in
/// test/career_sim/lab_panels_test.dart check that each number in the text
/// appears in the panel and that a result is flagged exactly when the case
/// marks it abnormal. Values are adult reference ranges in US conventional
/// units, for teaching only; infants get no adult panel.
library;

import 'dart:math' as math;

import 'hospital_models.dart';

/// One measured item and its adult reference range.
class LabAnalyte {
  const LabAnalyte(this.id, this.name, this.unit, this.low, this.high, this.normal,
      {this.decimals = 1, this.lowF, this.highF, this.normalF, this.upperOnly = false, this.lowerOnly = false});
  final String id;
  final String name;
  final String unit;
  final double low;
  final double high;

  /// A typical healthy value, used when the case does not set one.
  final double normal;
  final int decimals;

  /// Female ranges where they differ.
  final double? lowF;
  final double? highF;
  final double? normalF;

  /// Only a raised value is abnormal (e.g. troponin "< 0.04").
  final bool upperOnly;

  /// Only a low value is abnormal (e.g. eGFR "≥ 60").
  final bool lowerOnly;

  double lowFor(String sex) => sex == 'F' ? (lowF ?? low) : low;
  double highFor(String sex) => sex == 'F' ? (highF ?? high) : high;
  double normalFor(String sex) => sex == 'F' ? (normalF ?? normal) : normal;

  String fmt(double v) => v.toStringAsFixed(decimals);
  String rangeFor(String sex) => upperOnly
      ? '< ${fmt(highFor(sex))}'
      : lowerOnly
          ? '≥ ${fmt(lowFor(sex))}'
          : '${fmt(lowFor(sex))}–${fmt(highFor(sex))}';
}

/// One row of a lab report.
class LabRow {
  const LabRow(this.analyte, this.value, this.sex);
  final LabAnalyte analyte;
  final double value;
  final String sex;

  String get id => analyte.id;
  String get name => analyte.name;
  String get unit => analyte.unit;
  String get shown => analyte.fmt(value);
  String get range => analyte.rangeFor(sex);

  /// 'H' (high), 'L' (low) or '' (within range).
  String get flag {
    if (!analyte.lowerOnly && value > analyte.highFor(sex)) return 'H';
    if (!analyte.upperOnly && value < analyte.lowFor(sex)) return 'L';
    return '';
  }

  bool get abnormal => flag.isNotEmpty;
}

const List<LabAnalyte> _cbc = <LabAnalyte>[
  LabAnalyte('wbc', 'White cells (WBC)', '×10⁹/L', 4.5, 11.0, 7.2),
  LabAnalyte('neut', 'Neutrophils', '×10⁹/L', 1.5, 8.0, 4.4),
  LabAnalyte('hgb', 'Hemoglobin', 'g/dL', 13.5, 17.5, 14.6, lowF: 12.0, highF: 15.5, normalF: 13.4),
  LabAnalyte('plt', 'Platelets', '×10⁹/L', 150, 400, 245, decimals: 0),
];

const List<LabAnalyte> _bmp = <LabAnalyte>[
  LabAnalyte('na', 'Sodium', 'mmol/L', 135, 145, 139, decimals: 0),
  LabAnalyte('k', 'Potassium', 'mmol/L', 3.5, 5.0, 4.1),
  LabAnalyte('cl', 'Chloride', 'mmol/L', 98, 107, 102, decimals: 0),
  LabAnalyte('hco3', 'Bicarbonate', 'mmol/L', 22, 29, 25, decimals: 0),
  LabAnalyte('bun', 'Urea nitrogen (BUN)', 'mg/dL', 7, 20, 14, decimals: 0),
  LabAnalyte('cr', 'Creatinine', 'mg/dL', 0.7, 1.3, 0.9, decimals: 2, lowF: 0.6, highF: 1.1, normalF: 0.8),
  LabAnalyte('egfr', 'eGFR', 'mL/min/1.73m²', 60, 0, 90, decimals: 0, lowerOnly: true),
];

const LabAnalyte _mg = LabAnalyte('mg', 'Magnesium', 'mg/dL', 1.7, 2.2, 2.0);

const List<LabAnalyte> _coag = <LabAnalyte>[
  LabAnalyte('pt', 'Prothrombin time', 's', 11.0, 13.5, 12.1),
  LabAnalyte('inr', 'INR', '', 0.8, 1.1, 1.0),
  LabAnalyte('aptt', 'aPTT', 's', 25, 35, 30, decimals: 0),
];

const List<LabAnalyte> _abg = <LabAnalyte>[
  LabAnalyte('ph', 'pH', '', 7.35, 7.45, 7.40, decimals: 2),
  LabAnalyte('paco2', 'PaCO₂', 'mmHg', 35, 45, 40, decimals: 0),
  LabAnalyte('pao2', 'PaO₂', 'mmHg', 80, 100, 95, decimals: 0),
  LabAnalyte('hco3a', 'Bicarbonate', 'mmol/L', 22, 26, 24, decimals: 0),
];

const List<LabAnalyte> _lactate = <LabAnalyte>[LabAnalyte('lac', 'Lactate', 'mmol/L', 0.5, 2.0, 1.1)];
const List<LabAnalyte> _troponin = <LabAnalyte>[LabAnalyte('tni', 'Troponin I', 'ng/mL', 0, 0.04, 0.01, decimals: 2, upperOnly: true)];

/// Which tests have a numeric panel.
const Map<String, List<LabAnalyte>> labPanelAnalytes = <String, List<LabAnalyte>>{
  'cbc': _cbc,
  'bmp': _bmp,
  'coag': _coag,
  'abg': _abg,
  'lactate': _lactate,
  'troponin': _troponin,
};

/// Case-specific values; anything not listed is a typical healthy value.
/// Each line mirrors the written result in hospital_cases.dart.
const Map<String, Map<String, Map<String, double>>> _values = <String, Map<String, Map<String, double>>>{
  'ed_chest_pain': <String, Map<String, double>>{
    'troponin': <String, double>{'tni': 2.8}, // Troponin I raised
  },
  'ed_asthma': <String, Map<String, double>>{
    'abg': <String, double>{'ph': 7.45, 'paco2': 31, 'pao2': 62, 'hco3a': 23}, // pH 7.45, low CO2, low O2
  },
  'icu_sepsis': <String, Map<String, double>>{
    'lactate': <String, double>{'lac': 4.2},
    'cbc': <String, double>{'wbc': 18.0, 'neut': 15.8}, // white cells 18
    'bmp': <String, double>{'bun': 34, 'cr': 2.1, 'hco3': 18}, // creatinine raised (AKI)
    'abg': <String, double>{'ph': 7.28, 'paco2': 33, 'pao2': 64, 'hco3a': 16}, // metabolic acidosis, low O2
  },
  'maternity_pph': <String, Map<String, double>>{
    'cbc': <String, double>{'hgb': 8.9}, // hemoglobin 8.9 (low)
  },
  'medsurg_delirium': <String, Map<String, double>>{
    'bmp': <String, double>{'na': 132, 'bun': 31}, // raised urea; sodium 132
    'cbc': <String, double>{'wbc': 13.0, 'neut': 10.4}, // white cells 13
  },
  'cardio_af': <String, Map<String, double>>{
    'bmp': <String, double>{'k': 4.2, 'mg': 2.0}, // potassium and magnesium normal
  },
  'onc_neutropenic': <String, Map<String, double>>{
    'cbc': <String, double>{'wbc': 1.2, 'neut': 0.3}, // neutrophils 0.3 — severe neutropenia
    'lactate': <String, double>{'lac': 1.8},
  },
  'lab_potassium': <String, Map<String, double>>{
    'bmp': <String, double>{'k': 6.7, 'bun': 48, 'cr': 3.4}, // repeat potassium 6.7; creatinine raised (CKD 4)
  },
  'radiology_contrast': <String, Map<String, double>>{
    'bmp': <String, double>{'cr': 2.47}, // eGFR 28 (severely reduced)
  },
};

/// The numeric report for [testId] in case [c], or null when the test has no
/// panel (imaging, cultures, urinalysis, ECG) or the patient is a child.
List<LabRow>? labPanel(PatientCase c, String testId) {
  final List<LabAnalyte>? base = labPanelAnalytes[testId];
  if (base == null || c.age < 16 || !c.tests.containsKey(testId)) return null;
  final Map<String, double> set = _values[c.id]?[testId] ?? const <String, double>{};
  final List<LabAnalyte> analytes = <LabAnalyte>[...base, if (testId == 'bmp' && set.containsKey('mg')) _mg];
  final Map<String, double> v = <String, double>{for (final LabAnalyte a in analytes) a.id: set[a.id] ?? a.normalFor(c.sex)};
  if (v.containsKey('egfr') && !set.containsKey('egfr')) v['egfr'] = ckdEpi2021(v['cr']!, c.age, c.sex).roundToDouble();
  return <LabRow>[for (final LabAnalyte a in analytes) LabRow(a, v[a.id]!, c.sex)];
}

/// eGFR from creatinine (mg/dL), age and sex by the race-free CKD-EPI 2021
/// equation, so kidney numbers in a report always agree with each other.
double ckdEpi2021(double creatinine, int age, String sex) {
  final bool f = sex == 'F';
  final double k = f ? 0.7 : 0.9;
  final double a = f ? -0.241 : -0.302;
  final double r = creatinine / k;
  return (142 * math.pow(math.min(r, 1.0), a) * math.pow(math.max(r, 1.0), -1.200) * math.pow(0.9938, age) * (f ? 1.012 : 1.0)).toDouble();
}
