import '../../models/practice_lab.dart';
import '../../models/practice_lab_topic.dart';
import 'topic_area_helpers.dart';

List<PracticeLabTopicArea> _scienceMajor(
  String majorId,
  String fieldName,
  String emoji,
  List<({String areaId, String areaName, String topicId, String topicName, String desc})> items,
) {
  final Map<String, List<PracticeLabTopic>> grouped = <String, List<PracticeLabTopic>>{};
  final Map<String, String> areaNames = <String, String>{};
  for (final ({String areaId, String areaName, String topicId, String topicName, String desc}) item in items) {
    areaNames[item.areaId] = item.areaName;
    grouped.putIfAbsent(item.areaId, () => <PracticeLabTopic>[]).add(
          labTopic(
            id: item.topicId,
            name: item.topicName,
            description: item.desc,
            style: SimulationStyle.diagnosis,
            aiRole: 'Lab Instructor',
            advanced: item.topicId.contains('advanced') || item.desc.length > 80,
          ),
        );
  }
  return majorTopicAreas(
    majorId: majorId,
    areas: grouped.entries
        .map(
          (MapEntry<String, List<PracticeLabTopic>> e) => (
                id: e.key,
                name: areaNames[e.key] ?? fieldName,
                emoji: emoji,
                topics: e.value,
              ),
        )
        .toList(),
  );
}

final List<PracticeLabTopicArea> biologyMajorTopics = _scienceMajor('biology', 'Biology', '🧬', <({String areaId, String areaName, String topicId, String topicName, String desc})>[
  (areaId: 'cell_bio', areaName: 'Cell Biology', topicId: 'cell_division', topicName: 'Cell Division', desc: 'Explain mitosis errors observed in microscopy lab.'),
  (areaId: 'cell_bio', areaName: 'Cell Biology', topicId: 'membrane', topicName: 'Membrane Transport', desc: 'Predict transport mechanisms for osmotic stress experiment.'),
  (areaId: 'ecology', areaName: 'Ecology', topicId: 'ecosystems', topicName: 'Ecosystem Dynamics', desc: 'Model predator-prey population changes after habitat loss.'),
  (areaId: 'genetics', areaName: 'Genetics', topicId: 'inheritance', topicName: 'Inheritance Patterns', desc: 'Construct pedigree analysis for rare genetic disorder.'),
]);

final List<PracticeLabTopicArea> chemistryMajorTopics = _scienceMajor('chemistry', 'Chemistry', '⚗️', <({String areaId, String areaName, String topicId, String topicName, String desc})>[
  (areaId: 'organic', areaName: 'Organic Chemistry', topicId: 'synthesis', topicName: 'Synthesis Planning', desc: 'Design multi-step synthesis for target pharmaceutical intermediate.'),
  (areaId: 'organic', areaName: 'Organic Chemistry', topicId: 'stereochem', topicName: 'Stereochemistry', desc: 'Predict stereochemical outcomes of SN1/SN2 reactions.'),
  (areaId: 'analytical', areaName: 'Analytical Chemistry', topicId: 'spectroscopy', topicName: 'Spectroscopy', desc: 'Identify unknown compound from NMR and IR data.'),
  (areaId: 'physical', areaName: 'Physical Chemistry', topicId: 'thermo', topicName: 'Thermodynamics', desc: 'Calculate Gibbs free energy for spontaneous reaction prediction.'),
]);

final List<PracticeLabTopicArea> physicsMajorTopics = _scienceMajor('physics', 'Physics', '⚛️', <({String areaId, String areaName, String topicId, String topicName, String desc})>[
  (areaId: 'mechanics', areaName: 'Classical Mechanics', topicId: 'kinematics', topicName: 'Kinematics Problems', desc: 'Solve projectile motion with air resistance approximation.'),
  (areaId: 'em', areaName: 'Electromagnetism', topicId: 'maxwell', topicName: 'Maxwell Equations', desc: 'Apply Maxwell equations to electromagnetic wave propagation.'),
  (areaId: 'quantum', areaName: 'Quantum Physics', topicId: 'wave_functions', topicName: 'Wave Functions', desc: 'Interpret probability density for particle in a box.'),
]);

final List<PracticeLabTopicArea> environmentalScienceMajorTopics = _scienceMajor('environmental_science', 'Environmental Science', '🌿', <({String areaId, String areaName, String topicId, String topicName, String desc})>[
  (areaId: 'climate', areaName: 'Climate Science', topicId: 'carbon_cycle', topicName: 'Carbon Cycle', desc: 'Evaluate carbon sequestration proposal for regional policy.'),
  (areaId: 'conservation', areaName: 'Conservation', topicId: 'biodiversity', topicName: 'Biodiversity', desc: 'Design conservation plan for endangered species habitat.'),
]);

final List<PracticeLabTopicArea> biochemistryMajorTopics = _scienceMajor('biochemistry', 'Biochemistry', '🧪', <({String areaId, String areaName, String topicId, String topicName, String desc})>[
  (areaId: 'metabolism', areaName: 'Metabolism', topicId: 'pathways', topicName: 'Metabolic Pathways', desc: 'Trace glucose metabolism under fasting conditions.'),
  (areaId: 'enzymes', areaName: 'Enzymology', topicId: 'kinetics', topicName: 'Enzyme Kinetics', desc: 'Interpret Lineweaver-Burk plot for inhibitor type.'),
]);

final List<PracticeLabTopicArea> microbiologyMajorTopics = _scienceMajor('microbiology', 'Microbiology', '🦠', <({String areaId, String areaName, String topicId, String topicName, String desc})>[
  (areaId: 'clinical_micro', areaName: 'Clinical Microbiology', topicId: 'culture', topicName: 'Culture Interpretation', desc: 'Identify pathogen from culture and recommend antibiotics.'),
  (areaId: 'immunology', areaName: 'Immunology', topicId: 'immune_response', topicName: 'Immune Response', desc: 'Explain vaccine mechanism to vaccine-hesitant patient group.'),
]);

final List<PracticeLabTopicArea> biotechnologyMajorTopics = _scienceMajor('biotechnology', 'Biotechnology', '🔬', <({String areaId, String areaName, String topicId, String topicName, String desc})>[
  (areaId: 'genetic_eng', areaName: 'Genetic Engineering', topicId: 'crispr', topicName: 'CRISPR Applications', desc: 'Design CRISPR experiment with off-target risk mitigation.'),
  (areaId: 'bioprocess', areaName: 'Bioprocess Engineering', topicId: 'fermentation', topicName: 'Fermentation Scale-Up', desc: 'Troubleshoot yield drop in bioreactor production run.'),
]);

final List<PracticeLabTopicArea> marineBiologyMajorTopics = _scienceMajor('marine_biology', 'Marine Biology', '🌊', <({String areaId, String areaName, String topicId, String topicName, String desc})>[
  (areaId: 'marine_eco', areaName: 'Marine Ecology', topicId: 'coral', topicName: 'Coral Reef Health', desc: 'Assess bleaching impact and restoration interventions.'),
  (areaId: 'oceanography', areaName: 'Oceanography', topicId: 'currents', topicName: 'Ocean Currents', desc: 'Predict pollutant dispersion from spill using current models.'),
]);

final List<PracticeLabTopicArea> geologyMajorTopics = _scienceMajor('geology', 'Geology', '🪨', <({String areaId, String areaName, String topicId, String topicName, String desc})>[
  (areaId: 'mineralogy', areaName: 'Mineralogy', topicId: 'identification', topicName: 'Mineral Identification', desc: 'Identify minerals from hand sample and thin section.'),
  (areaId: 'seismology', areaName: 'Seismology', topicId: 'hazard', topicName: 'Seismic Hazard', desc: 'Evaluate earthquake risk for proposed construction site.'),
]);

final List<PracticeLabTopicArea> astronomyMajorTopics = _scienceMajor('astronomy', 'Astronomy', '🔭', <({String areaId, String areaName, String topicId, String topicName, String desc})>[
  (areaId: 'observational', areaName: 'Observational Astronomy', topicId: 'light_curves', topicName: 'Light Curves', desc: 'Classify variable star from observational light curve data.'),
  (areaId: 'cosmology', areaName: 'Cosmology', topicId: 'expansion', topicName: 'Cosmic Expansion', desc: 'Interpret redshift data for Hubble constant debate.'),
]);

final List<PracticeLabTopicArea> neuroscienceMajorTopics = _scienceMajor('neuroscience', 'Neuroscience', '🧠', <({String areaId, String areaName, String topicId, String topicName, String desc})>[
  (areaId: 'neuro_anatomy', areaName: 'Neuroanatomy', topicId: 'pathways', topicName: 'Neural Pathways', desc: 'Localize lesion from neurological exam findings.'),
  (areaId: 'cognitive_neuro', areaName: 'Cognitive Neuroscience', topicId: 'brain_imaging', topicName: 'Brain Imaging', desc: 'Interpret fMRI study design and confound controls.'),
]);

final Map<String, List<PracticeLabTopicArea>> scienceTopicsByMajor = <String, List<PracticeLabTopicArea>>{
  'biology': biologyMajorTopics,
  'chemistry': chemistryMajorTopics,
  'physics': physicsMajorTopics,
  'environmental_science': environmentalScienceMajorTopics,
  'biochemistry': biochemistryMajorTopics,
  'microbiology': microbiologyMajorTopics,
  'biotechnology': biotechnologyMajorTopics,
  'marine_biology': marineBiologyMajorTopics,
  'geology': geologyMajorTopics,
  'astronomy': astronomyMajorTopics,
  'neuroscience': neuroscienceMajorTopics,
};
