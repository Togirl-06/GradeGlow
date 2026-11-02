const Map<String, List<String>> nursingCourseTopics = <String, List<String>>{
  'nursing|fundamentals': <String>[
    'Vital Signs', 'Patient Hygiene', 'Infection Control', 'Bedside Communication',
    'Mobility & Safety', 'Documentation', 'Pain Assessment', 'Patient Education',
    'Fall Prevention', 'Hand Hygiene', 'Bed Making', 'Transfer Techniques',
    'Aseptic Technique', 'Cultural Competence', 'Ethics in Nursing', 'Exam Review',
  ],
  'nursing|pharmacology': <String>[
    'Insulin Administration', 'Medication Safety', 'Drug Interactions', 'Dosage Calculations',
    'IV Therapy', 'Pain Management', 'Anticoagulants', 'High-Alert Medications',
    'Rights of Medication', 'Pediatric Dosing', 'Geriatric Considerations', 'Adverse Reactions',
    'PRN Medications', 'Controlled Substances', 'Herbal Interactions', 'Exam Review',
  ],
  'nursing|health_assessment': <String>[
    'Head-to-Toe Assessment', 'Cardiovascular Exam', 'Respiratory Assessment', 'Neurological Exam',
    'Abdominal Assessment', 'Skin Assessment', 'Mental Status Exam', 'Health History',
    'Peripheral Pulses', 'Lung Sounds', 'Cranial Nerves', 'Musculoskeletal Exam',
    'Breast Exam', 'Genitourinary Assessment', 'Pain Scales', 'Exam Review',
  ],
  'nursing|pediatrics': <String>[
    'Growth & Development', 'Pediatric Medication Dosing', 'Immunizations', 'Family-Centered Care',
    'Pediatric Pain', 'Newborn Care', 'Asthma Management', 'Child Abuse Recognition',
    'Dehydration in Children', 'Fever Management', 'Pediatric Nutrition', 'Play Therapy',
    'Adolescent Health', 'Congenital Conditions', 'School Health', 'Exam Review',
  ],
  'nursing|medical_surgical_nursing': <String>[
    'Post-Op Care', 'Wound Management', 'Diabetes Management', 'Heart Failure',
    'COPD Care', 'Sepsis Recognition', 'Fluid & Electrolytes', 'Discharge Planning',
    'Ostomy Care', 'Chest Tubes', 'NG Tube Care', 'Blood Transfusions',
    'Renal Failure', 'Stroke Care', 'Pressure Ulcers', 'Exam Review',
  ],
  'nursing|obstetrics': <String>[
    'Prenatal Assessment', 'Labor Stages', 'Fetal Monitoring', 'Postpartum Care',
    'Newborn Assessment', 'Preeclampsia', 'Breastfeeding Support', 'High-Risk Pregnancy',
    'Gestational Diabetes', 'Epidural Care', 'Cesarean Recovery', 'Postpartum Hemorrhage',
    'Contraception Counseling', 'Lactation Issues', 'Neonatal Jaundice', 'Exam Review',
  ],
  'nursing|mental_health_nursing': <String>[
    'Therapeutic Communication', 'Suicide Risk Assessment', 'Depression Care', 'Anxiety Disorders',
    'Psychotropic Medications', 'Crisis Intervention', 'De-escalation', 'Recovery Planning',
    'Bipolar Disorder Care', 'Schizophrenia Support', 'Substance Use Disorders', 'Group Therapy',
    'Restraint Alternatives', 'Trauma-Informed Care', 'Community Resources', 'Exam Review',
  ],
  'nursing|critical_care': <String>[
    'Shock Management', 'Ventilator Basics', 'Rapid Response', 'ICU Handoff',
    'Hemodynamic Monitoring', 'Sedation Management', 'ARDS', 'Code Blue Response',
    'Central Line Care', 'Dialysis Nursing', 'ECMO Basics', 'Sepsis Protocols',
    'ICU Delirium', 'Nutrition in ICU', 'End-of-Life Care', 'Exam Review',
  ],
};

const Map<String, List<String>> medicineCourseTopics = <String, List<String>>{
  'medicine|anatomy': <String>[
    'Upper Limb Anatomy', 'Lower Limb Anatomy', 'Thoracic Anatomy', 'Abdominal Viscera',
    'Head & Neck', 'Neuroanatomy', 'Cardiac Anatomy', 'Pelvic Anatomy',
    'Back & Spine', 'Brachial Plexus', 'Cranial Foramina', 'Vascular Anatomy',
    'Lymphatic System', 'Embryology', 'Cross-Sectional Anatomy', 'Exam Review',
  ],
  'medicine|physiology': <String>[
    'Cardiovascular Physiology', 'Renal Physiology', 'Pulmonary Physiology', 'GI Physiology',
    'Endocrine Physiology', 'Neurophysiology', 'Acid-Base Balance', 'Exercise Physiology',
    'Cardiac Output', 'Glomerular Filtration', 'Ventilation-Perfusion', 'Insulin Regulation',
    'Action Potentials', 'Hormone Axes', 'Thermoregulation', 'Exam Review',
  ],
  'medicine|pathology': <String>[
    'Inflammation', 'Neoplasia', 'Ischemic Injury', 'Infectious Disease',
    'Autoimmune Disorders', 'Genetic Disorders', 'Hematologic Pathology', 'Histopathology',
    'Cell Injury', 'Amyloidosis', 'Granulomatous Disease', 'Liver Pathology',
    'Kidney Pathology', 'Lung Pathology', 'CNS Pathology', 'Exam Review',
  ],
  'medicine|pharmacology': <String>[
    'Prescribing Safety', 'Antibiotic Stewardship', 'Polypharmacy Review', 'Adverse Drug Events',
    'Cardiovascular Drugs', 'Analgesics', 'Psychiatric Medications', 'Drug Monitoring',
    'Antihypertensives', 'Anticoagulants', 'Diabetes Medications', 'Chemotherapy Basics',
    'Drug Allergies', 'Renal Dosing', 'Pediatric Prescribing', 'Exam Review',
  ],
  'medicine|internal_medicine': <String>[
    'Hypertension', 'Diabetes Mellitus', 'COPD Management', 'Heart Failure',
    'Thyroid Disorders', 'Anemia Workup', 'Chest Pain Evaluation', 'Infectious Workup',
    'Atrial Fibrillation', 'Chronic Kidney Disease', 'Liver Disease', 'Rheumatology Basics',
    'Electrolyte Disorders', 'Pneumonia', 'DVT & PE', 'Exam Review',
  ],
  'medicine|surgery': <String>[
    'Pre-Op Assessment', 'Surgical Consent', 'Post-Op Complications', 'Acute Abdomen',
    'Trauma Evaluation', 'Wound Care', 'Surgical Infections', 'Perioperative Management',
    'Appendicitis', 'Cholecystitis', 'Bowel Obstruction', 'Hernia Repair',
    'Surgical Nutrition', 'Antibiotic Prophylaxis', 'Bleeding Control', 'Exam Review',
  ],
  'medicine|emergency_medicine': <String>[
    'Triage', 'Chest Pain Workup', 'Trauma Assessment', 'Resuscitation',
    'Stroke Protocol', 'Sepsis Bundle', 'Airway Management', 'Toxicology Overdose',
    'Anaphylaxis', 'Status Epilepticus', 'Burns', 'Pediatric Emergencies',
    'Environmental Emergencies', 'Shock Types', 'Procedural Sedation', 'Exam Review',
  ],
};
