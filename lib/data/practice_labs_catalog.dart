import 'package:flutter/material.dart';

import '../models/practice_lab.dart';
import 'practice_lab_scenarios.dart';

/// A simulation matched during catalog search.
typedef PracticeLabSearchHit = ({
  PracticeLabSubjectGroup group,
  PracticeLabCategory category,
  PracticeLabType lab,
});

/// Practice Labs catalog — subjects grouped by field of study.
class PracticeLabsCatalog {
  PracticeLabsCatalog._();

  static const List<PracticeLabSubjectGroup> _baseGroups =
      <PracticeLabSubjectGroup>[
        PracticeLabSubjectGroup(
          id: 'health_medical',
          name: 'Health & Medical',
          emoji: '🏥',
          icon: Icons.local_hospital_outlined,
          subjects: <PracticeLabCategory>[
            PracticeLabCategory(
              id: 'nursing',
              name: 'Nursing',
              emoji: '🩺',
              icon: Icons.medical_services_outlined,
              labs: <PracticeLabType>[],
              groupId: 'health_medical',
            ),
            PracticeLabCategory(
              id: 'pre_med',
              name: 'Pre-Med',
              emoji: '',
              icon: Icons.healing_outlined,
              labs: <PracticeLabType>[],
              groupId: 'health_medical',
            ),
            PracticeLabCategory(
              id: 'medical_school',
              name: 'Medical School',
              emoji: '',
              icon: Icons.local_hospital_rounded,
              labs: <PracticeLabType>[],
              groupId: 'health_medical',
            ),
            PracticeLabCategory(
              id: 'physician_assistant',
              name: 'Physician Assistant (PA)',
              emoji: '',
              icon: Icons.health_and_safety_outlined,
              labs: <PracticeLabType>[],
              groupId: 'health_medical',
            ),
            PracticeLabCategory(
              id: 'pharmacy',
              name: 'Pharmacy',
              emoji: '',
              icon: Icons.medication_outlined,
              labs: <PracticeLabType>[],
              groupId: 'health_medical',
            ),
            PracticeLabCategory(
              id: 'physical_therapy',
              name: 'Physical Therapy',
              emoji: '',
              icon: Icons.accessibility_new_rounded,
              labs: <PracticeLabType>[],
              groupId: 'health_medical',
            ),
            PracticeLabCategory(
              id: 'occupational_therapy',
              name: 'Occupational Therapy',
              emoji: '',
              icon: Icons.back_hand_outlined,
              labs: <PracticeLabType>[],
              groupId: 'health_medical',
            ),
            PracticeLabCategory(
              id: 'radiology',
              name: 'Radiology',
              emoji: '',
              icon: Icons.radar_outlined,
              labs: <PracticeLabType>[],
              groupId: 'health_medical',
            ),
            PracticeLabCategory(
              id: 'respiratory_therapy',
              name: 'Respiratory Therapy',
              emoji: '',
              icon: Icons.air_outlined,
              labs: <PracticeLabType>[],
              groupId: 'health_medical',
            ),
            PracticeLabCategory(
              id: 'dental_hygiene',
              name: 'Dental Hygiene',
              emoji: '',
              icon: Icons.cleaning_services_outlined,
              labs: <PracticeLabType>[],
              groupId: 'health_medical',
            ),
            PracticeLabCategory(
              id: 'dentistry',
              name: 'Dentistry',
              emoji: '',
              icon: Icons.mood_outlined,
              labs: <PracticeLabType>[],
              groupId: 'health_medical',
            ),
            PracticeLabCategory(
              id: 'veterinary_medicine',
              name: 'Veterinary Medicine',
              emoji: '',
              icon: Icons.pets_outlined,
              labs: <PracticeLabType>[],
              groupId: 'health_medical',
            ),
            PracticeLabCategory(
              id: 'public_health',
              name: 'Public Health',
              emoji: '',
              icon: Icons.public_outlined,
              labs: <PracticeLabType>[],
              groupId: 'health_medical',
            ),
            PracticeLabCategory(
              id: 'health_sciences',
              name: 'Health Sciences',
              emoji: '',
              icon: Icons.biotech_outlined,
              labs: <PracticeLabType>[],
              groupId: 'health_medical',
            ),
            PracticeLabCategory(
              id: 'kinesiology',
              name: 'Kinesiology',
              emoji: '',
              icon: Icons.directions_run_outlined,
              labs: <PracticeLabType>[],
              groupId: 'health_medical',
            ),
            PracticeLabCategory(
              id: 'exercise_science',
              name: 'Exercise Science',
              emoji: '',
              icon: Icons.fitness_center_outlined,
              labs: <PracticeLabType>[],
              groupId: 'health_medical',
            ),
            PracticeLabCategory(
              id: 'medical_laboratory_science',
              name: 'Medical Laboratory Science',
              emoji: '',
              icon: Icons.science_outlined,
              labs: <PracticeLabType>[],
              groupId: 'health_medical',
            ),
          ],
        ),
        PracticeLabSubjectGroup(
          id: 'computer_technology',
          name: 'Computer & Technology',
          emoji: '💻',
          icon: Icons.terminal_outlined,
          subjects: <PracticeLabCategory>[
            PracticeLabCategory(
              id: 'computer_science',
              name: 'Computer Science',
              emoji: '',
              icon: Icons.computer_rounded,
              labs: <PracticeLabType>[],
              groupId: 'computer_technology',
            ),
            PracticeLabCategory(
              id: 'software_engineering',
              name: 'Software Engineering',
              emoji: '',
              icon: Icons.code_rounded,
              labs: <PracticeLabType>[],
              groupId: 'computer_technology',
            ),
            PracticeLabCategory(
              id: 'information_technology',
              name: 'Information Technology',
              emoji: '',
              icon: Icons.computer_outlined,
              labs: <PracticeLabType>[],
              groupId: 'computer_technology',
            ),
            PracticeLabCategory(
              id: 'cybersecurity',
              name: 'Cybersecurity',
              emoji: '',
              icon: Icons.security_outlined,
              labs: <PracticeLabType>[],
              groupId: 'computer_technology',
            ),
            PracticeLabCategory(
              id: 'data_science',
              name: 'Data Science',
              emoji: '',
              icon: Icons.analytics_outlined,
              labs: <PracticeLabType>[],
              groupId: 'computer_technology',
            ),
            PracticeLabCategory(
              id: 'artificial_intelligence',
              name: 'Artificial Intelligence',
              emoji: '',
              icon: Icons.psychology_alt_outlined,
              labs: <PracticeLabType>[],
              groupId: 'computer_technology',
            ),
            PracticeLabCategory(
              id: 'machine_learning',
              name: 'Machine Learning',
              emoji: '',
              icon: Icons.model_training_outlined,
              labs: <PracticeLabType>[],
              groupId: 'computer_technology',
            ),
            PracticeLabCategory(
              id: 'information_systems',
              name: 'Information Systems',
              emoji: '',
              icon: Icons.dns_outlined,
              labs: <PracticeLabType>[],
              groupId: 'computer_technology',
            ),
            PracticeLabCategory(
              id: 'computer_engineering',
              name: 'Computer Engineering',
              emoji: '',
              icon: Icons.memory_outlined,
              labs: <PracticeLabType>[],
              groupId: 'computer_technology',
            ),
            PracticeLabCategory(
              id: 'game_development',
              name: 'Game Development',
              emoji: '',
              icon: Icons.sports_esports_outlined,
              labs: <PracticeLabType>[],
              groupId: 'computer_technology',
            ),
            PracticeLabCategory(
              id: 'web_development',
              name: 'Web Development',
              emoji: '',
              icon: Icons.language_outlined,
              labs: <PracticeLabType>[],
              groupId: 'computer_technology',
            ),
            PracticeLabCategory(
              id: 'cloud_computing',
              name: 'Cloud Computing',
              emoji: '',
              icon: Icons.cloud_outlined,
              labs: <PracticeLabType>[],
              groupId: 'computer_technology',
            ),
          ],
        ),
        PracticeLabSubjectGroup(
          id: 'business',
          name: 'Business',
          emoji: '📊',
          icon: Icons.trending_up_rounded,
          subjects: <PracticeLabCategory>[
            PracticeLabCategory(
              id: 'business_administration',
              name: 'Business Administration',
              emoji: '',
              icon: Icons.business_center_outlined,
              labs: <PracticeLabType>[],
              groupId: 'business',
            ),
            PracticeLabCategory(
              id: 'human_resources',
              name: 'Human Resources',
              emoji: '',
              icon: Icons.groups_outlined,
              labs: <PracticeLabType>[],
              groupId: 'business',
            ),
            PracticeLabCategory(
              id: 'operations_management',
              name: 'Operations Management',
              emoji: '',
              icon: Icons.settings_suggest_outlined,
              labs: <PracticeLabType>[],
              groupId: 'business',
            ),
            PracticeLabCategory(
              id: 'entrepreneurship',
              name: 'Entrepreneurship',
              emoji: '',
              icon: Icons.rocket_launch_outlined,
              labs: <PracticeLabType>[],
              groupId: 'business',
            ),
            PracticeLabCategory(
              id: 'supply_chain_management',
              name: 'Supply Chain Management',
              emoji: '',
              icon: Icons.local_shipping_outlined,
              labs: <PracticeLabType>[],
              groupId: 'business',
            ),
            PracticeLabCategory(
              id: 'international_business',
              name: 'International Business',
              emoji: '',
              icon: Icons.public_rounded,
              labs: <PracticeLabType>[],
              groupId: 'business',
            ),
            PracticeLabCategory(
              id: 'management',
              name: 'Management',
              emoji: '',
              icon: Icons.leaderboard_outlined,
              labs: <PracticeLabType>[],
              groupId: 'business',
            ),
            PracticeLabCategory(
              id: 'business_analytics',
              name: 'Business Analytics',
              emoji: '',
              icon: Icons.insights_outlined,
              labs: <PracticeLabType>[],
              groupId: 'business',
            ),
            PracticeLabCategory(
              id: 'digital_business',
              name: 'Digital Business',
              emoji: '',
              icon: Icons.storefront_outlined,
              labs: <PracticeLabType>[],
              groupId: 'business',
            ),
            PracticeLabCategory(
              id: 'leadership',
              name: 'Leadership',
              emoji: '',
              icon: Icons.emoji_events_outlined,
              labs: <PracticeLabType>[],
              groupId: 'business',
            ),
            PracticeLabCategory(
              id: 'real_estate',
              name: 'Real Estate',
              emoji: '',
              icon: Icons.home_work_outlined,
              labs: <PracticeLabType>[],
              groupId: 'business',
            ),
          ],
        ),
        PracticeLabSubjectGroup(
          id: 'law_criminal_justice',
          name: 'Law & Criminal Justice',
          emoji: '⚖️',
          icon: Icons.gavel_outlined,
          subjects: <PracticeLabCategory>[
            PracticeLabCategory(
              id: 'law',
              name: 'Law',
              emoji: '',
              icon: Icons.balance_outlined,
              labs: <PracticeLabType>[],
              groupId: 'law_criminal_justice',
            ),
            PracticeLabCategory(
              id: 'pre_law',
              name: 'Pre-Law',
              emoji: '',
              icon: Icons.menu_book_outlined,
              labs: <PracticeLabType>[],
              groupId: 'law_criminal_justice',
            ),
            PracticeLabCategory(
              id: 'criminal_justice',
              name: 'Criminal Justice',
              emoji: '',
              icon: Icons.local_police_outlined,
              labs: <PracticeLabType>[],
              groupId: 'law_criminal_justice',
            ),
            PracticeLabCategory(
              id: 'criminology',
              name: 'Criminology',
              emoji: '',
              icon: Icons.search_outlined,
              labs: <PracticeLabType>[],
              groupId: 'law_criminal_justice',
            ),
            PracticeLabCategory(
              id: 'paralegal_studies',
              name: 'Paralegal Studies',
              emoji: '',
              icon: Icons.description_outlined,
              labs: <PracticeLabType>[],
              groupId: 'law_criminal_justice',
            ),
            PracticeLabCategory(
              id: 'homeland_security',
              name: 'Homeland Security',
              emoji: '',
              icon: Icons.shield_outlined,
              labs: <PracticeLabType>[],
              groupId: 'law_criminal_justice',
            ),
            PracticeLabCategory(
              id: 'forensic_science',
              name: 'Forensic Science',
              emoji: '',
              icon: Icons.fingerprint_outlined,
              labs: <PracticeLabType>[],
              groupId: 'law_criminal_justice',
            ),
          ],
        ),
        PracticeLabSubjectGroup(
          id: 'psychology_social_sciences',
          name: 'Psychology & Social Sciences',
          emoji: '🧠',
          icon: Icons.psychology_outlined,
          subjects: <PracticeLabCategory>[
            PracticeLabCategory(
              id: 'psychology',
              name: 'Psychology',
              emoji: '',
              icon: Icons.psychology_outlined,
              labs: <PracticeLabType>[],
              groupId: 'psychology_social_sciences',
            ),
            PracticeLabCategory(
              id: 'sociology',
              name: 'Sociology',
              emoji: '',
              icon: Icons.groups_2_outlined,
              labs: <PracticeLabType>[],
              groupId: 'psychology_social_sciences',
            ),
            PracticeLabCategory(
              id: 'social_work',
              name: 'Social Work',
              emoji: '',
              icon: Icons.volunteer_activism_outlined,
              labs: <PracticeLabType>[],
              groupId: 'psychology_social_sciences',
            ),
            PracticeLabCategory(
              id: 'counseling',
              name: 'Counseling',
              emoji: '',
              icon: Icons.support_agent_outlined,
              labs: <PracticeLabType>[],
              groupId: 'psychology_social_sciences',
            ),
            PracticeLabCategory(
              id: 'anthropology',
              name: 'Anthropology',
              emoji: '',
              icon: Icons.public_off_outlined,
              labs: <PracticeLabType>[],
              groupId: 'psychology_social_sciences',
            ),
            PracticeLabCategory(
              id: 'human_services',
              name: 'Human Services',
              emoji: '',
              icon: Icons.handshake_outlined,
              labs: <PracticeLabType>[],
              groupId: 'psychology_social_sciences',
            ),
            PracticeLabCategory(
              id: 'behavioral_science',
              name: 'Behavioral Science',
              emoji: '',
              icon: Icons.self_improvement_outlined,
              labs: <PracticeLabType>[],
              groupId: 'psychology_social_sciences',
            ),
            PracticeLabCategory(
              id: 'political_science',
              name: 'Political Science',
              emoji: '',
              icon: Icons.how_to_vote_outlined,
              labs: <PracticeLabType>[],
              groupId: 'psychology_social_sciences',
            ),
            PracticeLabCategory(
              id: 'international_relations',
              name: 'International Relations',
              emoji: '',
              icon: Icons.language_outlined,
              labs: <PracticeLabType>[],
              groupId: 'psychology_social_sciences',
            ),
          ],
        ),
        PracticeLabSubjectGroup(
          id: 'science',
          name: 'Science',
          emoji: '🔬',
          icon: Icons.science_outlined,
          subjects: <PracticeLabCategory>[
            PracticeLabCategory(
              id: 'biology',
              name: 'Biology',
              emoji: '',
              icon: Icons.biotech_outlined,
              labs: <PracticeLabType>[],
              groupId: 'science',
            ),
            PracticeLabCategory(
              id: 'chemistry',
              name: 'Chemistry',
              emoji: '',
              icon: Icons.science_outlined,
              labs: <PracticeLabType>[],
              groupId: 'science',
            ),
            PracticeLabCategory(
              id: 'physics',
              name: 'Physics',
              emoji: '',
              icon: Icons.bolt_outlined,
              labs: <PracticeLabType>[],
              groupId: 'science',
            ),
            PracticeLabCategory(
              id: 'environmental_science',
              name: 'Environmental Science',
              emoji: '',
              icon: Icons.eco_outlined,
              labs: <PracticeLabType>[],
              groupId: 'science',
            ),
            PracticeLabCategory(
              id: 'biochemistry',
              name: 'Biochemistry',
              emoji: '',
              icon: Icons.water_drop_outlined,
              labs: <PracticeLabType>[],
              groupId: 'science',
            ),
            PracticeLabCategory(
              id: 'microbiology',
              name: 'Microbiology',
              emoji: '',
              icon: Icons.coronavirus_outlined,
              labs: <PracticeLabType>[],
              groupId: 'science',
            ),
            PracticeLabCategory(
              id: 'biotechnology',
              name: 'Biotechnology',
              emoji: '',
              icon: Icons.hub_outlined,
              labs: <PracticeLabType>[],
              groupId: 'science',
            ),
            PracticeLabCategory(
              id: 'marine_biology',
              name: 'Marine Biology',
              emoji: '',
              icon: Icons.waves_outlined,
              labs: <PracticeLabType>[],
              groupId: 'science',
            ),
            PracticeLabCategory(
              id: 'geology',
              name: 'Geology',
              emoji: '',
              icon: Icons.landscape_outlined,
              labs: <PracticeLabType>[],
              groupId: 'science',
            ),
            PracticeLabCategory(
              id: 'astronomy',
              name: 'Astronomy',
              emoji: '',
              icon: Icons.dark_mode_outlined,
              labs: <PracticeLabType>[],
              groupId: 'science',
            ),
            PracticeLabCategory(
              id: 'neuroscience',
              name: 'Neuroscience',
              emoji: '',
              icon: Icons.blur_on_outlined,
              labs: <PracticeLabType>[],
              groupId: 'science',
            ),
          ],
        ),
        PracticeLabSubjectGroup(
          id: 'engineering',
          name: 'Engineering',
          emoji: '🏗️',
          icon: Icons.architecture_outlined,
          subjects: <PracticeLabCategory>[
            PracticeLabCategory(
              id: 'mechanical_engineering',
              name: 'Mechanical Engineering',
              emoji: '',
              icon: Icons.precision_manufacturing_outlined,
              labs: <PracticeLabType>[],
              groupId: 'engineering',
            ),
            PracticeLabCategory(
              id: 'civil_engineering',
              name: 'Civil Engineering',
              emoji: '',
              icon: Icons.apartment_outlined,
              labs: <PracticeLabType>[],
              groupId: 'engineering',
            ),
            PracticeLabCategory(
              id: 'electrical_engineering',
              name: 'Electrical Engineering',
              emoji: '',
              icon: Icons.electrical_services_outlined,
              labs: <PracticeLabType>[],
              groupId: 'engineering',
            ),
            PracticeLabCategory(
              id: 'aerospace_engineering',
              name: 'Aerospace Engineering',
              emoji: '',
              icon: Icons.flight_outlined,
              labs: <PracticeLabType>[],
              groupId: 'engineering',
            ),
            PracticeLabCategory(
              id: 'chemical_engineering',
              name: 'Chemical Engineering',
              emoji: '',
              icon: Icons.opacity_outlined,
              labs: <PracticeLabType>[],
              groupId: 'engineering',
            ),
            PracticeLabCategory(
              id: 'industrial_engineering',
              name: 'Industrial Engineering',
              emoji: '',
              icon: Icons.factory_outlined,
              labs: <PracticeLabType>[],
              groupId: 'engineering',
            ),
            PracticeLabCategory(
              id: 'biomedical_engineering',
              name: 'Biomedical Engineering',
              emoji: '',
              icon: Icons.monitor_heart_outlined,
              labs: <PracticeLabType>[],
              groupId: 'engineering',
            ),
            PracticeLabCategory(
              id: 'environmental_engineering',
              name: 'Environmental Engineering',
              emoji: '',
              icon: Icons.eco_outlined,
              labs: <PracticeLabType>[],
              groupId: 'engineering',
            ),
            PracticeLabCategory(
              id: 'materials_engineering',
              name: 'Materials Engineering',
              emoji: '',
              icon: Icons.layers_outlined,
              labs: <PracticeLabType>[],
              groupId: 'engineering',
            ),
            PracticeLabCategory(
              id: 'nuclear_engineering',
              name: 'Nuclear Engineering',
              emoji: '',
              icon: Icons.warning_amber_outlined,
              labs: <PracticeLabType>[],
              groupId: 'engineering',
            ),
          ],
        ),
        PracticeLabSubjectGroup(
          id: 'architecture_design',
          name: 'Architecture & Design',
          emoji: '🏛️',
          icon: Icons.domain_outlined,
          subjects: <PracticeLabCategory>[
            PracticeLabCategory(
              id: 'architecture',
              name: 'Architecture',
              emoji: '',
              icon: Icons.architecture_outlined,
              labs: <PracticeLabType>[],
              groupId: 'architecture_design',
            ),
            PracticeLabCategory(
              id: 'interior_design',
              name: 'Interior Design',
              emoji: '',
              icon: Icons.weekend_outlined,
              labs: <PracticeLabType>[],
              groupId: 'architecture_design',
            ),
            PracticeLabCategory(
              id: 'urban_planning',
              name: 'Urban Planning',
              emoji: '',
              icon: Icons.location_city_outlined,
              labs: <PracticeLabType>[],
              groupId: 'architecture_design',
            ),
            PracticeLabCategory(
              id: 'landscape_architecture',
              name: 'Landscape Architecture',
              emoji: '',
              icon: Icons.park_outlined,
              labs: <PracticeLabType>[],
              groupId: 'architecture_design',
            ),
            PracticeLabCategory(
              id: 'industrial_design',
              name: 'Industrial Design',
              emoji: '',
              icon: Icons.design_services_outlined,
              labs: <PracticeLabType>[],
              groupId: 'architecture_design',
            ),
          ],
        ),
        PracticeLabSubjectGroup(
          id: 'arts_creative',
          name: 'Arts & Creative Fields',
          emoji: '🎨',
          icon: Icons.palette_outlined,
          subjects: <PracticeLabCategory>[
            PracticeLabCategory(
              id: 'graphic_design',
              name: 'Graphic Design',
              emoji: '',
              icon: Icons.brush_outlined,
              labs: <PracticeLabType>[],
              groupId: 'arts_creative',
            ),
            PracticeLabCategory(
              id: 'animation',
              name: 'Animation',
              emoji: '',
              icon: Icons.animation_outlined,
              labs: <PracticeLabType>[],
              groupId: 'arts_creative',
            ),
            PracticeLabCategory(
              id: 'film_studies',
              name: 'Film Studies',
              emoji: '',
              icon: Icons.movie_outlined,
              labs: <PracticeLabType>[],
              groupId: 'arts_creative',
            ),
            PracticeLabCategory(
              id: 'music',
              name: 'Music',
              emoji: '',
              icon: Icons.music_note_outlined,
              labs: <PracticeLabType>[],
              groupId: 'arts_creative',
            ),
            PracticeLabCategory(
              id: 'music_production',
              name: 'Music Production',
              emoji: '',
              icon: Icons.library_music_outlined,
              labs: <PracticeLabType>[],
              groupId: 'arts_creative',
            ),
            PracticeLabCategory(
              id: 'fashion_design',
              name: 'Fashion Design',
              emoji: '',
              icon: Icons.checkroom_outlined,
              labs: <PracticeLabType>[],
              groupId: 'arts_creative',
            ),
            PracticeLabCategory(
              id: 'fine_arts',
              name: 'Fine Arts',
              emoji: '',
              icon: Icons.color_lens_outlined,
              labs: <PracticeLabType>[],
              groupId: 'arts_creative',
            ),
            PracticeLabCategory(
              id: 'photography',
              name: 'Photography',
              emoji: '',
              icon: Icons.camera_alt_outlined,
              labs: <PracticeLabType>[],
              groupId: 'arts_creative',
            ),
            PracticeLabCategory(
              id: 'theatre',
              name: 'Theatre',
              emoji: '',
              icon: Icons.theater_comedy_outlined,
              labs: <PracticeLabType>[],
              groupId: 'arts_creative',
            ),
            PracticeLabCategory(
              id: 'creative_writing',
              name: 'Creative Writing',
              emoji: '',
              icon: Icons.edit_note_outlined,
              labs: <PracticeLabType>[],
              groupId: 'arts_creative',
            ),
          ],
        ),
        PracticeLabSubjectGroup(
          id: 'communications_media',
          name: 'Communications & Media',
          emoji: '📢',
          icon: Icons.campaign_outlined,
          subjects: <PracticeLabCategory>[
            PracticeLabCategory(
              id: 'communications',
              name: 'Communications',
              emoji: '',
              icon: Icons.forum_outlined,
              labs: <PracticeLabType>[],
              groupId: 'communications_media',
            ),
            PracticeLabCategory(
              id: 'journalism',
              name: 'Journalism',
              emoji: '',
              icon: Icons.newspaper_outlined,
              labs: <PracticeLabType>[],
              groupId: 'communications_media',
            ),
            PracticeLabCategory(
              id: 'public_relations',
              name: 'Public Relations',
              emoji: '',
              icon: Icons.record_voice_over_outlined,
              labs: <PracticeLabType>[],
              groupId: 'communications_media',
            ),
            PracticeLabCategory(
              id: 'broadcasting',
              name: 'Broadcasting',
              emoji: '',
              icon: Icons.live_tv_outlined,
              labs: <PracticeLabType>[],
              groupId: 'communications_media',
            ),
            PracticeLabCategory(
              id: 'digital_media',
              name: 'Digital Media',
              emoji: '',
              icon: Icons.devices_outlined,
              labs: <PracticeLabType>[],
              groupId: 'communications_media',
            ),
            PracticeLabCategory(
              id: 'advertising',
              name: 'Advertising',
              emoji: '',
              icon: Icons.ads_click_outlined,
              labs: <PracticeLabType>[],
              groupId: 'communications_media',
            ),
            PracticeLabCategory(
              id: 'media_studies',
              name: 'Media Studies',
              emoji: '',
              icon: Icons.perm_media_outlined,
              labs: <PracticeLabType>[],
              groupId: 'communications_media',
            ),
          ],
        ),
        PracticeLabSubjectGroup(
          id: 'humanities',
          name: 'Humanities',
          emoji: '🌎',
          icon: Icons.menu_book_outlined,
          subjects: <PracticeLabCategory>[
            PracticeLabCategory(
              id: 'english',
              name: 'English',
              emoji: '',
              icon: Icons.auto_stories_outlined,
              labs: <PracticeLabType>[],
              groupId: 'humanities',
            ),
            PracticeLabCategory(
              id: 'philosophy',
              name: 'Philosophy',
              emoji: '',
              icon: Icons.lightbulb_outline_rounded,
              labs: <PracticeLabType>[],
              groupId: 'humanities',
            ),
            PracticeLabCategory(
              id: 'religious_studies',
              name: 'Religious Studies',
              emoji: '',
              icon: Icons.church_outlined,
              labs: <PracticeLabType>[],
              groupId: 'humanities',
            ),
            PracticeLabCategory(
              id: 'linguistics',
              name: 'Linguistics',
              emoji: '',
              icon: Icons.translate_outlined,
              labs: <PracticeLabType>[],
              groupId: 'humanities',
            ),
            PracticeLabCategory(
              id: 'foreign_languages',
              name: 'Foreign Languages',
              emoji: '',
              icon: Icons.language_rounded,
              labs: <PracticeLabType>[],
              groupId: 'humanities',
            ),
            PracticeLabCategory(
              id: 'cultural_studies',
              name: 'Cultural Studies',
              emoji: '',
              icon: Icons.diversity_3_outlined,
              labs: <PracticeLabType>[],
              groupId: 'humanities',
            ),
          ],
        ),
        PracticeLabSubjectGroup(
          id: 'hospitality_tourism',
          name: 'Hospitality & Tourism',
          emoji: '🍽️',
          icon: Icons.restaurant_outlined,
          subjects: <PracticeLabCategory>[
            PracticeLabCategory(
              id: 'hospitality_management',
              name: 'Hospitality Management',
              emoji: '',
              icon: Icons.hotel_outlined,
              labs: <PracticeLabType>[],
              groupId: 'hospitality_tourism',
            ),
            PracticeLabCategory(
              id: 'tourism_management',
              name: 'Tourism Management',
              emoji: '',
              icon: Icons.tour_outlined,
              labs: <PracticeLabType>[],
              groupId: 'hospitality_tourism',
            ),
            PracticeLabCategory(
              id: 'event_management',
              name: 'Event Management',
              emoji: '',
              icon: Icons.event_outlined,
              labs: <PracticeLabType>[],
              groupId: 'hospitality_tourism',
            ),
            PracticeLabCategory(
              id: 'culinary_arts',
              name: 'Culinary Arts',
              emoji: '',
              icon: Icons.restaurant_menu_outlined,
              labs: <PracticeLabType>[],
              groupId: 'hospitality_tourism',
            ),
            PracticeLabCategory(
              id: 'hotel_management',
              name: 'Hotel Management',
              emoji: '',
              icon: Icons.night_shelter_outlined,
              labs: <PracticeLabType>[],
              groupId: 'hospitality_tourism',
            ),
          ],
        ),
        PracticeLabSubjectGroup(
          id: 'agriculture_environment',
          name: 'Agriculture & Environment',
          emoji: '🌱',
          icon: Icons.agriculture_outlined,
          subjects: <PracticeLabCategory>[
            PracticeLabCategory(
              id: 'agriculture',
              name: 'Agriculture',
              emoji: '',
              icon: Icons.agriculture_outlined,
              labs: <PracticeLabType>[],
              groupId: 'agriculture_environment',
            ),
            PracticeLabCategory(
              id: 'agribusiness',
              name: 'Agribusiness',
              emoji: '',
              icon: Icons.storefront_outlined,
              labs: <PracticeLabType>[],
              groupId: 'agriculture_environment',
            ),
            PracticeLabCategory(
              id: 'animal_science',
              name: 'Animal Science',
              emoji: '',
              icon: Icons.pets_outlined,
              labs: <PracticeLabType>[],
              groupId: 'agriculture_environment',
            ),
            PracticeLabCategory(
              id: 'horticulture',
              name: 'Horticulture',
              emoji: '',
              icon: Icons.local_florist_outlined,
              labs: <PracticeLabType>[],
              groupId: 'agriculture_environment',
            ),
            PracticeLabCategory(
              id: 'forestry',
              name: 'Forestry',
              emoji: '',
              icon: Icons.forest_outlined,
              labs: <PracticeLabType>[],
              groupId: 'agriculture_environment',
            ),
            PracticeLabCategory(
              id: 'environmental_studies',
              name: 'Environmental Studies',
              emoji: '',
              icon: Icons.nature_people_outlined,
              labs: <PracticeLabType>[],
              groupId: 'agriculture_environment',
            ),
          ],
        ),
        PracticeLabSubjectGroup(
          id: 'mathematics_finance',
          name: 'Mathematics & Finance',
          emoji: '💰',
          icon: Icons.functions_outlined,
          subjects: <PracticeLabCategory>[
            PracticeLabCategory(
              id: 'mathematics',
              name: 'Mathematics',
              emoji: '',
              icon: Icons.functions_outlined,
              labs: <PracticeLabType>[],
              groupId: 'mathematics_finance',
            ),
            PracticeLabCategory(
              id: 'statistics',
              name: 'Statistics',
              emoji: '',
              icon: Icons.bar_chart_outlined,
              labs: <PracticeLabType>[],
              groupId: 'mathematics_finance',
            ),
            PracticeLabCategory(
              id: 'actuarial_science',
              name: 'Actuarial Science',
              emoji: '',
              icon: Icons.calculate_outlined,
              labs: <PracticeLabType>[],
              groupId: 'mathematics_finance',
            ),
            PracticeLabCategory(
              id: 'quantitative_finance',
              name: 'Quantitative Finance',
              emoji: '',
              icon: Icons.candlestick_chart_outlined,
              labs: <PracticeLabType>[],
              groupId: 'mathematics_finance',
            ),
          ],
        ),
        PracticeLabSubjectGroup(
          id: 'public_safety_government',
          name: 'Public Safety & Government',
          emoji: '🚔',
          icon: Icons.local_police_outlined,
          subjects: <PracticeLabCategory>[
            PracticeLabCategory(
              id: 'emergency_management',
              name: 'Emergency Management',
              emoji: '',
              icon: Icons.emergency_outlined,
              labs: <PracticeLabType>[],
              groupId: 'public_safety_government',
            ),
            PracticeLabCategory(
              id: 'fire_science',
              name: 'Fire Science',
              emoji: '',
              icon: Icons.local_fire_department_outlined,
              labs: <PracticeLabType>[],
              groupId: 'public_safety_government',
            ),
            PracticeLabCategory(
              id: 'public_administration',
              name: 'Public Administration',
              emoji: '',
              icon: Icons.account_balance_outlined,
              labs: <PracticeLabType>[],
              groupId: 'public_safety_government',
            ),
            PracticeLabCategory(
              id: 'public_policy',
              name: 'Public Policy',
              emoji: '',
              icon: Icons.policy_outlined,
              labs: <PracticeLabType>[],
              groupId: 'public_safety_government',
            ),
            PracticeLabCategory(
              id: 'intelligence_studies',
              name: 'Intelligence Studies',
              emoji: '',
              icon: Icons.visibility_outlined,
              labs: <PracticeLabType>[],
              groupId: 'public_safety_government',
            ),
            PracticeLabCategory(
              id: 'military_science',
              name: 'Military Science',
              emoji: '',
              icon: Icons.military_tech_outlined,
              labs: <PracticeLabType>[],
              groupId: 'public_safety_government',
            ),
          ],
        ),
      ];

  /// Subject groups with scenario labs injected from [PracticeLabScenarios].
  static List<PracticeLabSubjectGroup> get groups => _enrichedGroups;

  static List<PracticeLabSubjectGroup>? _enrichedGroupsCache;

  static List<PracticeLabSubjectGroup> get _enrichedGroups {
    return _enrichedGroupsCache ??= _baseGroups
        .map(
          (PracticeLabSubjectGroup group) => PracticeLabSubjectGroup(
            id: group.id,
            name: group.name,
            emoji: group.emoji,
            icon: group.icon,
            subjects: group.subjects
                .map(
                  (PracticeLabCategory category) => PracticeLabCategory(
                    id: category.id,
                    name: category.name,
                    emoji: category.emoji,
                    icon: category.icon,
                    groupId: category.groupId,
                    labs: PracticeLabScenarios.forMajor(
                      category.id,
                      groupId: category.groupId,
                      majorName: category.name,
                    ),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  static int get totalSimulationCount => categories.fold<int>(
    0,
    (int sum, PracticeLabCategory category) => sum + category.labs.length,
  );

  static List<PracticeLabCategory> get categories =>
      groups.expand((PracticeLabSubjectGroup group) => group.subjects).toList();

  static bool _matchesQuery(String query, String text) =>
      text.toLowerCase().contains(query);

  /// Filter subject groups to majors whose name matches [query].
  static List<PracticeLabSubjectGroup> filterGroups(String query) {
    final String trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return groups;

    return groups
        .map((PracticeLabSubjectGroup group) {
          final bool groupMatches = _matchesQuery(trimmed, group.name);
          final List<PracticeLabCategory> subjects = group.subjects
              .where(
                (PracticeLabCategory category) =>
                    groupMatches || _matchesQuery(trimmed, category.name),
              )
              .toList();
          if (subjects.isEmpty) return null;
          return PracticeLabSubjectGroup(
            id: group.id,
            name: group.name,
            emoji: group.emoji,
            icon: group.icon,
            subjects: subjects,
          );
        })
        .whereType<PracticeLabSubjectGroup>()
        .toList();
  }

  /// Find simulations whose title, subtitle, role, or difficulty match [query].
  static List<PracticeLabSearchHit> searchSimulations(String query) {
    final String trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return const <PracticeLabSearchHit>[];

    final List<PracticeLabSearchHit> hits = <PracticeLabSearchHit>[];
    for (final PracticeLabSubjectGroup group in groups) {
      for (final PracticeLabCategory category in group.subjects) {
        for (final PracticeLabType lab in category.labs) {
          final bool matches =
              _matchesQuery(trimmed, lab.title) ||
              _matchesQuery(trimmed, lab.subtitle) ||
              _matchesQuery(trimmed, lab.difficulty) ||
              (lab.aiRole != null && _matchesQuery(trimmed, lab.aiRole!)) ||
              _matchesQuery(trimmed, category.name) ||
              _matchesQuery(trimmed, group.name);
          if (matches) {
            hits.add((group: group, category: category, lab: lab));
          }
        }
      }
    }
    return hits;
  }

  static List<PracticeLabType> filterLabs(
    List<PracticeLabType> labs,
    String query,
  ) {
    final String trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return labs;

    return labs.where((PracticeLabType lab) {
      return _matchesQuery(trimmed, lab.title) ||
          _matchesQuery(trimmed, lab.subtitle) ||
          _matchesQuery(trimmed, lab.difficulty) ||
          (lab.aiRole != null && _matchesQuery(trimmed, lab.aiRole!));
    }).toList();
  }

  static PracticeLabSubjectGroup? groupById(String id) {
    for (final PracticeLabSubjectGroup group in groups) {
      if (group.id == id) return group;
    }
    return null;
  }

  static String roleplayGuide(SimulationStyle style) {
    return switch (style) {
      SimulationStyle.aiPatient =>
        'You are a realistic patient in a clinical simulation. Stay in character. '
            'Answer the student nurse naturally based on your symptoms and history. '
            'Do not diagnose yourself or tell them the correct treatment.',
      SimulationStyle.erEmergency =>
        'You are an emergency department simulation. Present as charge nurse, patient, or team member as needed. '
            'Create urgency. Respond to the student\'s triage, assessment, and treatment decisions realistically.',
      SimulationStyle.codingInterview =>
        'You are a senior software engineer conducting a technical interview. '
            'Give problems, ask follow-ups about time/space complexity, edge cases, and trade-offs. '
            'Stay professional and realistic.',
      SimulationStyle.debugging =>
        'You are a debugging lab assistant. Present broken code in markdown fences. '
            'Respond to the student\'s fixes and questions. Do not give away the full solution immediately.',
      SimulationStyle.systemDesign =>
        'You are a system design interviewer at a top tech company. '
            'Present a design prompt, ask scaling, reliability, and trade-off follow-ups.',
      SimulationStyle.customerScenario =>
        'You are an unhappy or demanding customer in a business simulation. '
            'React realistically to the student\'s communication and decisions.',
      SimulationStyle.courtroom =>
        'You are a legal simulation partner — judge, opposing counsel, or witness as appropriate. '
            'Stay in role and respond to the student\'s legal arguments and questions.',
      SimulationStyle.counseling =>
        'You are a client in a therapy simulation with realistic emotional responses. '
            'Do not break character. Respond to empathy, boundaries, and technique.',
      SimulationStyle.classroom =>
        'You are a student, parent, or administrator in a teacher training simulation. '
            'React to the student teacher\'s classroom management choices.',
      SimulationStyle.diagnosis =>
        'You are a patient in a medical school OSCE. Provide history and symptoms when asked. '
            'Do not reveal the diagnosis directly.',
      SimulationStyle.anatomyGame =>
        'Anatomy diagram game — not used for chat simulations.',
      SimulationStyle.diagramLab =>
        'Science diagram labeling — not used for chat simulations.',
    };
  }

  static PracticeLabCategory? categoryById(String id) {
    for (final PracticeLabCategory category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  static PracticeLabType? labById({
    required String categoryId,
    required String labId,
  }) {
    final PracticeLabCategory? category = categoryById(categoryId);
    if (category == null) return null;
    for (final PracticeLabType lab in category.labs) {
      if (lab.id == labId) return lab;
    }
    return null;
  }
}
