import '../../models/practice_lab.dart';
import '../../models/practice_lab_topic.dart';
import 'topic_area_helpers.dart';

const String _cs = 'computer_science';
const String _se = 'software_engineering';
const String _it = 'information_technology';
const String _cyber = 'cybersecurity';
const String _ds = 'data_science';
const String _ai = 'artificial_intelligence';
const String _ml = 'machine_learning';
const String _is = 'information_systems';
const String _ce = 'computer_engineering';
const String _game = 'game_development';
const String _web = 'web_development';
const String _cloud = 'cloud_computing';

final List<PracticeLabTopicArea> computerScienceMajorTopics = majorTopicAreas(
  majorId: _cs,
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'programming_fundamentals',
      name: 'Programming Fundamentals',
      emoji: '⌨️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'variables', name: 'Variables & Types', description: 'Trace scope bugs and explain memory representation in a live coding interview.', style: SimulationStyle.codingInterview, aiRole: 'Technical Interviewer', codeLab: true),
        labTopic(id: 'loops', name: 'Loops & Iteration', description: 'Optimize nested loops and analyze time complexity trade-offs.', style: SimulationStyle.codingInterview, aiRole: 'Technical Interviewer', codeLab: true),
        labTopic(id: 'recursion', name: 'Recursion', description: 'Convert recursive solutions to iterative forms and prove correctness.', style: SimulationStyle.codingInterview, aiRole: 'Staff Engineer', codeLab: true, advanced: true),
      ],
    ),
    (
      id: 'data_structures',
      name: 'Data Structures',
      emoji: '🧱',
      topics: <PracticeLabTopic>[
        labTopic(id: 'arrays', name: 'Arrays', description: 'Solve a two-pointer array problem under interview pressure.', style: SimulationStyle.codingInterview, aiRole: 'Interviewer', codeLab: true),
        labTopic(id: 'linked_lists', name: 'Linked Lists', description: 'Reverse and merge linked lists while explaining pointer invariants.', style: SimulationStyle.codingInterview, aiRole: 'Interviewer', codeLab: true),
        labTopic(id: 'trees', name: 'Trees & BSTs', description: 'Traverse and rebalance a binary search tree in a timed challenge.', style: SimulationStyle.codingInterview, aiRole: 'Interviewer', codeLab: true, advanced: true),
        labTopic(id: 'graphs', name: 'Graphs', description: 'Implement BFS/DFS and find shortest paths on weighted graphs.', style: SimulationStyle.codingInterview, aiRole: 'Interviewer', codeLab: true, advanced: true),
      ],
    ),
    (
      id: 'algorithms',
      name: 'Algorithms',
      emoji: '⚡',
      topics: <PracticeLabTopic>[
        labTopic(id: 'sorting', name: 'Sorting Algorithms', description: 'Compare sorts and pick the optimal algorithm for a constrained dataset.', style: SimulationStyle.codingInterview, aiRole: 'Interviewer', codeLab: true),
        labTopic(id: 'dynamic_programming', name: 'Dynamic Programming', description: 'Decompose overlapping subproblems with memoization or tabulation.', style: SimulationStyle.codingInterview, aiRole: 'Interviewer', codeLab: true, advanced: true),
        labTopic(id: 'competitive_coding', name: 'Competitive Coding', description: 'Race the clock on a contest-style problem with strict I/O limits.', style: SimulationStyle.codingInterview, aiRole: 'Contest Judge', codeLab: true, advanced: true),
      ],
    ),
    (
      id: 'theory',
      name: 'Computer Science Theory',
      emoji: '📐',
      topics: <PracticeLabTopic>[
        labTopic(id: 'complexity', name: 'Complexity Analysis', description: 'Prove Big-O bounds and defend asymptotic choices to a theory professor.', style: SimulationStyle.classroom, aiRole: 'Professor'),
        labTopic(id: 'automata', name: 'Automata & Languages', description: 'Design a finite automaton that accepts a given regular language.', style: SimulationStyle.classroom, aiRole: 'Theory Instructor', advanced: true),
        labTopic(id: 'computability', name: 'Computability', description: 'Explain why a problem is undecidable and propose practical workarounds.', style: SimulationStyle.classroom, aiRole: 'Research Advisor', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> softwareEngineeringMajorTopics = majorTopicAreas(
  majorId: _se,
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'sdlc',
      name: 'Software Development Lifecycle',
      emoji: '🔄',
      topics: <PracticeLabTopic>[
        labTopic(id: 'requirements', name: 'Requirements Gathering', description: 'Interview a vague stakeholder and write actionable user stories.', style: SimulationStyle.customerScenario, aiRole: 'Product Owner'),
        labTopic(id: 'estimation', name: 'Sprint Estimation', description: 'Estimate story points and defend your sizing to a skeptical tech lead.', style: SimulationStyle.customerScenario, aiRole: 'Tech Lead'),
        labTopic(id: 'release_planning', name: 'Release Planning', description: 'Plan a phased rollout with feature flags and rollback strategy.', style: SimulationStyle.systemDesign, aiRole: 'Engineering Manager', advanced: true),
      ],
    ),
    (
      id: 'code_quality',
      name: 'Code Quality & Review',
      emoji: '🔍',
      topics: <PracticeLabTopic>[
        labTopic(id: 'code_review', name: 'Code Review', description: 'Review a pull request and give constructive feedback on design and tests.', style: SimulationStyle.codingInterview, aiRole: 'Senior Engineer', codeLab: true),
        labTopic(id: 'refactoring', name: 'Refactoring', description: 'Refactor legacy code without breaking behavior — explain each step.', style: SimulationStyle.debugging, aiRole: 'Staff Engineer', codeLab: true),
        labTopic(id: 'testing_strategy', name: 'Testing Strategy', description: 'Design unit, integration, and E2E coverage for a critical service.', style: SimulationStyle.systemDesign, aiRole: 'QA Architect', advanced: true),
      ],
    ),
    (
      id: 'architecture',
      name: 'Software Architecture',
      emoji: '🏗️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'design_patterns', name: 'Design Patterns', description: 'Choose patterns for a scaling codebase and justify trade-offs.', style: SimulationStyle.codingInterview, aiRole: 'Architect', codeLab: true, advanced: true),
        labTopic(id: 'api_design', name: 'API Design', description: 'Design RESTful APIs with versioning, auth, and error contracts.', style: SimulationStyle.systemDesign, aiRole: 'Platform Lead'),
        labTopic(id: 'microservices', name: 'Microservices Migration', description: 'Plan decomposition of a monolith into bounded contexts.', style: SimulationStyle.systemDesign, aiRole: 'CTO', advanced: true),
      ],
    ),
    (
      id: 'devops',
      name: 'DevOps & Delivery',
      emoji: '🚀',
      topics: <PracticeLabTopic>[
        labTopic(id: 'cicd', name: 'CI/CD Pipelines', description: 'Design a pipeline with gates, artifacts, and deployment stages.', style: SimulationStyle.systemDesign, aiRole: 'DevOps Engineer'),
        labTopic(id: 'incident_response', name: 'Incident Response', description: 'Lead a production outage war room and write the postmortem.', style: SimulationStyle.customerScenario, aiRole: 'On-Call Lead', advanced: true),
        labTopic(id: 'agile_ceremonies', name: 'Agile Ceremonies', description: 'Facilitate sprint planning when priorities conflict across teams.', style: SimulationStyle.customerScenario, aiRole: 'Scrum Master'),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> artificialIntelligenceMajorTopics = majorTopicAreas(
  majorId: _ai,
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'ai_foundations',
      name: 'AI Foundations',
      emoji: '🧠',
      topics: <PracticeLabTopic>[
        labTopic(id: 'search', name: 'Search & Planning', description: 'Compare BFS, A*, and heuristic search for a robotics navigation task.', style: SimulationStyle.classroom, aiRole: 'AI Professor'),
        labTopic(id: 'knowledge_rep', name: 'Knowledge Representation', description: 'Model domain knowledge with ontologies and inference rules.', style: SimulationStyle.classroom, aiRole: 'Research Lead'),
        labTopic(id: 'expert_systems', name: 'Expert Systems', description: 'Build rule-based reasoning for a diagnostic assistant.', style: SimulationStyle.diagnosis, aiRole: 'Domain Expert', advanced: true),
      ],
    ),
    (
      id: 'nlp',
      name: 'Natural Language Processing',
      emoji: '💬',
      topics: <PracticeLabTopic>[
        labTopic(id: 'text_classification', name: 'Text Classification', description: 'Design an NLP pipeline for sentiment analysis in production.', style: SimulationStyle.codingInterview, aiRole: 'NLP Engineer', codeLab: true),
        labTopic(id: 'llm_applications', name: 'LLM Applications', description: 'Architect a RAG system with retrieval, grounding, and guardrails.', style: SimulationStyle.systemDesign, aiRole: 'AI Architect', advanced: true),
        labTopic(id: 'prompt_design', name: 'Prompt Design', description: 'Engineer prompts for reliable structured outputs in a business workflow.', style: SimulationStyle.customerScenario, aiRole: 'AI Product Manager'),
      ],
    ),
    (
      id: 'computer_vision',
      name: 'Computer Vision',
      emoji: '👁️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'image_classification', name: 'Image Classification', description: 'Select model architecture and augmentation for a vision benchmark.', style: SimulationStyle.codingInterview, aiRole: 'Vision Engineer'),
        labTopic(id: 'object_detection', name: 'Object Detection', description: 'Evaluate detection metrics and handle class imbalance in deployment.', style: SimulationStyle.diagnosis, aiRole: 'ML Lead', advanced: true),
        labTopic(id: 'video_analytics', name: 'Video Analytics', description: 'Design a real-time video inference pipeline at the edge.', style: SimulationStyle.systemDesign, aiRole: 'Edge AI Engineer', advanced: true),
      ],
    ),
    (
      id: 'ai_ethics',
      name: 'AI Ethics & Safety',
      emoji: '⚖️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'bias_fairness', name: 'Bias & Fairness', description: 'Audit a model for disparate impact and propose mitigation steps.', style: SimulationStyle.diagnosis, aiRole: 'Ethics Reviewer'),
        labTopic(id: 'ai_governance', name: 'AI Governance', description: 'Draft an AI use policy for a regulated enterprise environment.', style: SimulationStyle.customerScenario, aiRole: 'Chief AI Officer', advanced: true),
        labTopic(id: 'human_ai_collab', name: 'Human-AI Collaboration', description: 'Design human-in-the-loop workflows for high-stakes decisions.', style: SimulationStyle.customerScenario, aiRole: 'Operations Director'),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> machineLearningMajorTopics = majorTopicAreas(
  majorId: _ml,
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'supervised',
      name: 'Supervised Learning',
      emoji: '📈',
      topics: <PracticeLabTopic>[
        labTopic(id: 'regression', name: 'Regression Models', description: 'Select features and regularization for a regression forecasting task.', style: SimulationStyle.codingInterview, aiRole: 'ML Engineer', codeLab: true),
        labTopic(id: 'classification', name: 'Classification', description: 'Handle imbalanced classes and tune decision thresholds.', style: SimulationStyle.codingInterview, aiRole: 'Data Scientist', codeLab: true),
        labTopic(id: 'ensemble_methods', name: 'Ensemble Methods', description: 'Compare bagging, boosting, and stacking for a Kaggle-style problem.', style: SimulationStyle.codingInterview, aiRole: 'ML Lead', codeLab: true, advanced: true),
      ],
    ),
    (
      id: 'unsupervised',
      name: 'Unsupervised Learning',
      emoji: '🔮',
      topics: <PracticeLabTopic>[
        labTopic(id: 'clustering', name: 'Clustering', description: 'Choose clustering algorithms and validate segments for a marketing use case.', style: SimulationStyle.diagnosis, aiRole: 'Analytics Lead'),
        labTopic(id: 'dimensionality', name: 'Dimensionality Reduction', description: 'Apply PCA or t-SNE and interpret latent structure for stakeholders.', style: SimulationStyle.classroom, aiRole: 'Professor'),
        labTopic(id: 'anomaly_detection', name: 'Anomaly Detection', description: 'Detect fraud patterns in streaming transaction data.', style: SimulationStyle.diagnosis, aiRole: 'Fraud Analyst', advanced: true),
      ],
    ),
    (
      id: 'deep_learning',
      name: 'Deep Learning',
      emoji: '🧬',
      topics: <PracticeLabTopic>[
        labTopic(id: 'neural_nets', name: 'Neural Network Design', description: 'Design layer architecture and activation choices for a tabular DL task.', style: SimulationStyle.codingInterview, aiRole: 'Deep Learning Engineer', codeLab: true),
        labTopic(id: 'training_tuning', name: 'Training & Hyperparameter Tuning', description: 'Debug vanishing gradients and optimize learning rate schedules.', style: SimulationStyle.debugging, aiRole: 'Research Engineer', advanced: true),
        labTopic(id: 'transfer_learning', name: 'Transfer Learning', description: 'Fine-tune a pretrained model for a low-data domain problem.', style: SimulationStyle.codingInterview, aiRole: 'ML Engineer', advanced: true),
      ],
    ),
    (
      id: 'mlops',
      name: 'MLOps',
      emoji: '⚙️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'model_evaluation', name: 'Model Evaluation', description: 'Select metrics and design cross-validation for a production model.', style: SimulationStyle.diagnosis, aiRole: 'ML Platform Lead'),
        labTopic(id: 'feature_stores', name: 'Feature Stores', description: 'Architect offline/online feature pipelines for real-time inference.', style: SimulationStyle.systemDesign, aiRole: 'Platform Engineer', advanced: true),
        labTopic(id: 'drift_monitoring', name: 'Drift Monitoring', description: 'Detect data drift and trigger retraining with minimal downtime.', style: SimulationStyle.diagnosis, aiRole: 'SRE', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> dataScienceMajorTopics = majorTopicAreas(
  majorId: _ds,
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'statistics',
      name: 'Statistics & Probability',
      emoji: '📊',
      topics: <PracticeLabTopic>[
        labTopic(id: 'hypothesis_testing', name: 'Hypothesis Testing', description: 'Design an A/B test and interpret statistical significance for executives.', style: SimulationStyle.customerScenario, aiRole: 'VP of Product'),
        labTopic(id: 'bayesian', name: 'Bayesian Inference', description: 'Build a Bayesian model and explain priors to non-technical stakeholders.', style: SimulationStyle.classroom, aiRole: 'Statistician', advanced: true),
        labTopic(id: 'sampling', name: 'Sampling & Bias', description: 'Identify selection bias in a survey dataset and correct methodology.', style: SimulationStyle.diagnosis, aiRole: 'Research Director'),
      ],
    ),
    (
      id: 'data_wrangling',
      name: 'Data Wrangling',
      emoji: '🧹',
      topics: <PracticeLabTopic>[
        labTopic(id: 'eda', name: 'Exploratory Data Analysis', description: 'Profile messy data and surface insights for a business question.', style: SimulationStyle.diagnosis, aiRole: 'Analytics Manager'),
        labTopic(id: 'data_cleaning', name: 'Data Cleaning', description: 'Build a reproducible cleaning pipeline for inconsistent production data.', style: SimulationStyle.codingInterview, aiRole: 'Data Engineer', codeLab: true),
        labTopic(id: 'sql_analytics', name: 'SQL Analytics', description: 'Write complex SQL to answer multi-table business questions.', style: SimulationStyle.codingInterview, aiRole: 'Analytics Engineer', codeLab: true),
      ],
    ),
    (
      id: 'visualization',
      name: 'Data Visualization',
      emoji: '📉',
      topics: <PracticeLabTopic>[
        labTopic(id: 'dashboards', name: 'Executive Dashboards', description: 'Design KPI dashboards that drive decisions without chart junk.', style: SimulationStyle.customerScenario, aiRole: 'CEO'),
        labTopic(id: 'storytelling', name: 'Data Storytelling', description: 'Present findings from a contentious dataset to skeptical leadership.', style: SimulationStyle.customerScenario, aiRole: 'Board Member', advanced: true),
      ],
    ),
    (
      id: 'modeling',
      name: 'Predictive Modeling',
      emoji: '🎯',
      topics: <PracticeLabTopic>[
        labTopic(id: 'forecasting', name: 'Time Series Forecasting', description: 'Forecast demand with seasonality and communicate uncertainty bands.', style: SimulationStyle.codingInterview, aiRole: 'Forecasting Lead', codeLab: true),
        labTopic(id: 'causal_inference', name: 'Causal Inference', description: 'Distinguish correlation from causation in an observational study.', style: SimulationStyle.classroom, aiRole: 'Econometrician', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> cybersecurityMajorTopics = majorTopicAreas(
  majorId: _cyber,
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'security_fundamentals',
      name: 'Security Fundamentals',
      emoji: '🔐',
      topics: <PracticeLabTopic>[
        labTopic(id: 'auth', name: 'Authentication & Access', description: 'Audit IAM policies and recommend MFA and least-privilege fixes.', style: SimulationStyle.diagnosis, aiRole: 'Security Analyst'),
        labTopic(id: 'cryptography', name: 'Cryptography Basics', description: 'Explain TLS handshakes and choose encryption for data at rest.', style: SimulationStyle.classroom, aiRole: 'Security Architect'),
        labTopic(id: 'vuln_assessment', name: 'Vulnerability Assessment', description: 'Prioritize CVEs from a scan report and plan remediation sprints.', style: SimulationStyle.diagnosis, aiRole: 'Penetration Tester', advanced: true),
      ],
    ),
    (
      id: 'network_security',
      name: 'Network Security',
      emoji: '🌐',
      topics: <PracticeLabTopic>[
        labTopic(id: 'firewalls', name: 'Firewalls & Segmentation', description: 'Design network zones and firewall rules for a hybrid cloud environment.', style: SimulationStyle.systemDesign, aiRole: 'Network Security Engineer'),
        labTopic(id: 'intrusion', name: 'Intrusion Detection', description: 'Investigate suspicious traffic patterns in SIEM alerts.', style: SimulationStyle.diagnosis, aiRole: 'SOC Analyst', advanced: true),
        labTopic(id: 'ddos', name: 'DDoS Mitigation', description: 'Respond to a volumetric attack and coordinate with the ISP.', style: SimulationStyle.erEmergency, aiRole: 'Incident Commander', advanced: true),
      ],
    ),
    (
      id: 'incident_response',
      name: 'Incident Response',
      emoji: '🚨',
      topics: <PracticeLabTopic>[
        labTopic(id: 'ransomware', name: 'Ransomware Response', description: 'Lead containment and recovery during an active ransomware attack.', style: SimulationStyle.customerScenario, aiRole: 'CISO'),
        labTopic(id: 'forensics', name: 'Digital Forensics', description: 'Preserve evidence and reconstruct an attack timeline.', style: SimulationStyle.diagnosis, aiRole: 'Forensic Investigator', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> informationTechnologyMajorTopics = majorTopicAreas(
  majorId: _it,
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'it_support',
      name: 'IT Support',
      emoji: '🎧',
      topics: <PracticeLabTopic>[
        labTopic(id: 'helpdesk', name: 'Help Desk Triage', description: 'Diagnose user issues and prioritize tickets during a outage spike.', style: SimulationStyle.customerScenario, aiRole: 'Frustrated User'),
        labTopic(id: 'troubleshooting', name: 'Hardware Troubleshooting', description: 'Walk a remote user through diagnosing a failing workstation.', style: SimulationStyle.diagnosis, aiRole: 'Employee'),
        labTopic(id: 'ticket_escalation', name: 'Ticket Escalation', description: 'Decide when to escalate and document for tier-2 engineers.', style: SimulationStyle.customerScenario, aiRole: 'IT Manager'),
      ],
    ),
    (
      id: 'infrastructure',
      name: 'IT Infrastructure',
      emoji: '🖥️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'active_directory', name: 'Active Directory', description: 'Resolve group policy and permission issues in a corporate domain.', style: SimulationStyle.diagnosis, aiRole: 'Systems Admin'),
        labTopic(id: 'virtualization', name: 'Virtualization', description: 'Provision VMs and troubleshoot hypervisor resource contention.', style: SimulationStyle.diagnosis, aiRole: 'Infrastructure Lead'),
        labTopic(id: 'backup_recovery', name: 'Backup & Recovery', description: 'Restore critical services from backup after accidental deletion.', style: SimulationStyle.erEmergency, aiRole: 'IT Director', advanced: true),
      ],
    ),
    (
      id: 'networking',
      name: 'Networking',
      emoji: '🔗',
      topics: <PracticeLabTopic>[
        labTopic(id: 'tcp_ip', name: 'TCP/IP Troubleshooting', description: 'Use ping, traceroute, and DNS tools to isolate connectivity failures.', style: SimulationStyle.diagnosis, aiRole: 'Network Admin'),
        labTopic(id: 'wifi', name: 'Wireless Networks', description: 'Fix enterprise Wi-Fi coverage and authentication issues.', style: SimulationStyle.diagnosis, aiRole: 'Wireless Engineer'),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> informationSystemsMajorTopics = majorTopicAreas(
  majorId: _is,
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'business_systems',
      name: 'Business Systems',
      emoji: '🏢',
      topics: <PracticeLabTopic>[
        labTopic(id: 'erp', name: 'ERP Implementation', description: 'Map business processes to ERP modules during a go-live crisis.', style: SimulationStyle.customerScenario, aiRole: 'ERP Consultant'),
        labTopic(id: 'crm', name: 'CRM Configuration', description: 'Design sales pipeline stages and reporting for a growing SaaS company.', style: SimulationStyle.customerScenario, aiRole: 'Sales Director'),
        labTopic(id: 'requirements_ba', name: 'Business Analysis', description: 'Elicit requirements from conflicting stakeholders for a system upgrade.', style: SimulationStyle.customerScenario, aiRole: 'Business Analyst'),
      ],
    ),
    (
      id: 'data_systems',
      name: 'Data & Integration',
      emoji: '🗄️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'database_design', name: 'Database Design for Business', description: 'Normalize a schema for reporting while preserving OLTP performance.', style: SimulationStyle.systemDesign, aiRole: 'Data Architect'),
        labTopic(id: 'integration', name: 'System Integration', description: 'Plan API integrations between legacy and cloud systems.', style: SimulationStyle.systemDesign, aiRole: 'Integration Architect', advanced: true),
      ],
    ),
    (
      id: 'is_strategy',
      name: 'IS Strategy',
      emoji: '📋',
      topics: <PracticeLabTopic>[
        labTopic(id: 'it_governance', name: 'IT Governance', description: 'Align IT portfolio priorities with business strategy on a tight budget.', style: SimulationStyle.customerScenario, aiRole: 'CIO'),
        labTopic(id: 'change_management', name: 'Change Management', description: 'Drive user adoption for a disruptive system rollout.', style: SimulationStyle.customerScenario, aiRole: 'Change Manager', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> computerEngineeringMajorTopics = majorTopicAreas(
  majorId: _ce,
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'digital_logic',
      name: 'Digital Logic',
      emoji: '🔢',
      topics: <PracticeLabTopic>[
        labTopic(id: 'logic_gates', name: 'Logic Gates & Circuits', description: 'Design combinational circuits to meet timing constraints.', style: SimulationStyle.classroom, aiRole: 'Lab Instructor', codeLab: true),
        labTopic(id: 'fsm', name: 'Finite State Machines', description: 'Implement FSM controllers for a sequential logic problem.', style: SimulationStyle.codingInterview, aiRole: 'Hardware Engineer', codeLab: true),
      ],
    ),
    (
      id: 'embedded',
      name: 'Embedded Systems',
      emoji: '📟',
      topics: <PracticeLabTopic>[
        labTopic(id: 'microcontrollers', name: 'Microcontrollers', description: 'Debug firmware timing issues on a resource-constrained MCU.', style: SimulationStyle.debugging, aiRole: 'Embedded Lead', codeLab: true),
        labTopic(id: 'rtos', name: 'Real-Time OS', description: 'Schedule tasks and avoid priority inversion in a safety-critical system.', style: SimulationStyle.diagnosis, aiRole: 'RTOS Engineer', advanced: true),
        labTopic(id: 'iot', name: 'IoT Devices', description: 'Design power-efficient sensing and OTA update architecture.', style: SimulationStyle.systemDesign, aiRole: 'IoT Architect', advanced: true),
      ],
    ),
    (
      id: 'architecture',
      name: 'Computer Architecture',
      emoji: '🧮',
      topics: <PracticeLabTopic>[
        labTopic(id: 'cpu_design', name: 'CPU Pipelines', description: 'Explain pipeline hazards and cache effects on performance.', style: SimulationStyle.classroom, aiRole: 'Architecture Professor'),
        labTopic(id: 'memory', name: 'Memory Hierarchy', description: 'Optimize memory access patterns for throughput-critical code.', style: SimulationStyle.codingInterview, aiRole: 'Performance Engineer', codeLab: true, advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> gameDevelopmentMajorTopics = majorTopicAreas(
  majorId: _game,
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'game_design',
      name: 'Game Design',
      emoji: '🎮',
      topics: <PracticeLabTopic>[
        labTopic(id: 'core_loop', name: 'Core Game Loop', description: 'Pitch a compelling core loop and progression system to a publisher.', style: SimulationStyle.customerScenario, aiRole: 'Creative Director'),
        labTopic(id: 'level_design', name: 'Level Design', description: 'Balance difficulty curves and teach mechanics without tutorials.', style: SimulationStyle.classroom, aiRole: 'Lead Designer'),
        labTopic(id: 'narrative', name: 'Narrative Design', description: 'Integrate branching story choices with gameplay consequences.', style: SimulationStyle.customerScenario, aiRole: 'Narrative Director', advanced: true),
      ],
    ),
    (
      id: 'game_programming',
      name: 'Game Programming',
      emoji: '👾',
      topics: <PracticeLabTopic>[
        labTopic(id: 'game_physics', name: 'Game Physics', description: 'Fix collision detection bugs in a physics-heavy platformer.', style: SimulationStyle.debugging, aiRole: 'Gameplay Programmer', codeLab: true),
        labTopic(id: 'rendering', name: 'Rendering & Graphics', description: 'Optimize draw calls and shader performance for mobile targets.', style: SimulationStyle.codingInterview, aiRole: 'Graphics Engineer', codeLab: true, advanced: true),
        labTopic(id: 'networking', name: 'Multiplayer Networking', description: 'Design lag compensation and state sync for a competitive multiplayer game.', style: SimulationStyle.systemDesign, aiRole: 'Network Engineer', advanced: true),
      ],
    ),
    (
      id: 'production',
      name: 'Game Production',
      emoji: '🎬',
      topics: <PracticeLabTopic>[
        labTopic(id: 'playtesting', name: 'Playtesting Feedback', description: 'Synthesize playtest data and prioritize fixes before milestone.', style: SimulationStyle.customerScenario, aiRole: 'Producer'),
        labTopic(id: 'monetization', name: 'Monetization Ethics', description: 'Design fair monetization that respects players and meets revenue goals.', style: SimulationStyle.customerScenario, aiRole: 'Studio Head', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> webDevelopmentMajorTopics = majorTopicAreas(
  majorId: _web,
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'frontend',
      name: 'Frontend Development',
      emoji: '🎨',
      topics: <PracticeLabTopic>[
        labTopic(id: 'html_css', name: 'HTML & CSS Layout', description: 'Build a responsive layout and explain accessibility choices.', style: SimulationStyle.codingInterview, aiRole: 'Frontend Lead', codeLab: true),
        labTopic(id: 'react', name: 'Component Architecture', description: 'Refactor a React codebase for state management and reusability.', style: SimulationStyle.debugging, aiRole: 'Senior Frontend Dev', codeLab: true),
        labTopic(id: 'performance', name: 'Web Performance', description: 'Diagnose Core Web Vitals regressions and propose fixes.', style: SimulationStyle.diagnosis, aiRole: 'Performance Engineer', advanced: true),
      ],
    ),
    (
      id: 'backend',
      name: 'Backend Development',
      emoji: '⚙️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'rest_apis', name: 'REST APIs', description: 'Design REST endpoints with auth, pagination, and error handling.', style: SimulationStyle.codingInterview, aiRole: 'Backend Engineer', codeLab: true),
        labTopic(id: 'databases_web', name: 'Database Integration', description: 'Optimize ORM queries causing N+1 problems in production.', style: SimulationStyle.debugging, aiRole: 'Full-Stack Dev', codeLab: true),
        labTopic(id: 'auth_web', name: 'Web Authentication', description: 'Implement OAuth flows and secure session management.', style: SimulationStyle.systemDesign, aiRole: 'Security Engineer', advanced: true),
      ],
    ),
    (
      id: 'fullstack',
      name: 'Full-Stack Delivery',
      emoji: '🌐',
      topics: <PracticeLabTopic>[
        labTopic(id: 'deployment', name: 'Deployment Pipelines', description: 'Ship a full-stack feature with preview environments and rollbacks.', style: SimulationStyle.systemDesign, aiRole: 'DevOps Lead'),
        labTopic(id: 'seo', name: 'SEO & SSR', description: 'Improve search visibility with SSR and metadata strategy.', style: SimulationStyle.customerScenario, aiRole: 'Growth Lead', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> cloudComputingMajorTopics = majorTopicAreas(
  majorId: _cloud,
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'cloud_fundamentals',
      name: 'Cloud Fundamentals',
      emoji: '☁️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'iaas_paas', name: 'IaaS vs PaaS', description: 'Choose cloud service models for a startup migrating from on-prem.', style: SimulationStyle.systemDesign, aiRole: 'Cloud Architect'),
        labTopic(id: 'regions', name: 'Regions & Availability', description: 'Design multi-region failover for a mission-critical application.', style: SimulationStyle.systemDesign, aiRole: 'SRE'),
        labTopic(id: 'cost_optimization', name: 'Cost Optimization', description: 'Right-size resources and cut cloud spend without hurting SLAs.', style: SimulationStyle.customerScenario, aiRole: 'FinOps Lead'),
      ],
    ),
    (
      id: 'containers',
      name: 'Containers & Orchestration',
      emoji: '🐳',
      topics: <PracticeLabTopic>[
        labTopic(id: 'docker', name: 'Docker & Images', description: 'Containerize a legacy app and fix image size and security issues.', style: SimulationStyle.debugging, aiRole: 'Platform Engineer', codeLab: true),
        labTopic(id: 'kubernetes', name: 'Kubernetes', description: 'Debug pod crashes and design deployments with HPA and probes.', style: SimulationStyle.diagnosis, aiRole: 'K8s Admin', advanced: true),
        labTopic(id: 'service_mesh', name: 'Service Mesh', description: 'Add observability and mTLS between microservices at scale.', style: SimulationStyle.systemDesign, aiRole: 'Cloud Native Architect', advanced: true),
      ],
    ),
    (
      id: 'serverless',
      name: 'Serverless & Managed Services',
      emoji: '⚡',
      topics: <PracticeLabTopic>[
        labTopic(id: 'lambda', name: 'Serverless Functions', description: 'Design event-driven workflows with queues and dead-letter handling.', style: SimulationStyle.systemDesign, aiRole: 'Serverless Engineer'),
        labTopic(id: 'cloud_security', name: 'Cloud Security', description: 'Remediate misconfigured S3 buckets and IAM overly permissive roles.', style: SimulationStyle.diagnosis, aiRole: 'Cloud Security Analyst', advanced: true),
      ],
    ),
  ],
);

/// All computer & technology majors mapped to distinct topic catalogs.
final Map<String, List<PracticeLabTopicArea>> computerTechnologyTopicsByMajor =
    <String, List<PracticeLabTopicArea>>{
  _cs: computerScienceMajorTopics,
  _se: softwareEngineeringMajorTopics,
  _it: informationTechnologyMajorTopics,
  _cyber: cybersecurityMajorTopics,
  _ds: dataScienceMajorTopics,
  _ai: artificialIntelligenceMajorTopics,
  _ml: machineLearningMajorTopics,
  _is: informationSystemsMajorTopics,
  _ce: computerEngineeringMajorTopics,
  _game: gameDevelopmentMajorTopics,
  _web: webDevelopmentMajorTopics,
  _cloud: cloudComputingMajorTopics,
};
