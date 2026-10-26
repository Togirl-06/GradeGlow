class InterviewScenario {
  const InterviewScenario({
    required this.id,
    required this.title,
    required this.company,
    required this.role,
    required this.recruiter,
    required this.level,
    required this.majorTag,
    required this.opener,
    required this.followUps,
    required this.hint,
    required this.keywords,
  });

  final String id;
  final String title;
  final String company;
  final String role;
  final String recruiter;
  final String level;
  final String majorTag;
  final String opener;
  final List<String> followUps;
  final String hint;
  final List<String> keywords;
}

abstract final class InterviewCatalog {
  static final List<InterviewScenario> all = _build();

  static List<InterviewScenario> forMajor(String majorTitle) {
    final List<InterviewScenario> filtered = all
        .where((InterviewScenario s) => s.majorTag == majorTitle)
        .toList();
    if (filtered.length >= 8) return filtered;
    return all;
  }

  static List<InterviewScenario> _build() {
    final List<InterviewScenario> out = <InterviewScenario>[];
    final List<_Seed> seeds = <_Seed>[
      _Seed(
        'Northwind Labs',
        'Maya Okafor',
        'Software Engineering',
        <String>[
          'Junior Software Engineer',
          'Backend Intern',
          'Full-Stack Engineer',
          'Platform Engineer',
        ],
        <String>[
          'debug a login 500 when email is missing',
          'design a retry policy for flaky APIs',
          'explain how you would write a regression test',
          'walk through a pull request review',
        ],
        <String>['400', 'test', 'reproduce', 'null', 'edge'],
      ),
      _Seed(
        'Pixelforge Studio',
        'Leo Park',
        'Web Development',
        <String>[
          'Web Developer Intern',
          'Frontend Engineer',
          'UI Engineer',
          'Design Systems Intern',
        ],
        <String>[
          'make a landing page responsive without breaking desktop',
          'debug a CSS layout shift',
          'explain accessibility for a button component',
          'optimize image loading on a marketing site',
        ],
        <String>['responsive', 'css', 'a11y', 'aria', 'flex'],
      ),
      _Seed(
        'Brightloop',
        'Sam Rivera',
        'Mobile App Development',
        <String>[
          'Mobile App Intern',
          'Flutter Developer',
          'iOS Engineer Intern',
          'Android Engineer Intern',
        ],
        <String>[
          'fix a Flutter rebuild loop',
          'handle null in a Text widget safely',
          'explain state management for a simple form',
          'write a widget test for a button',
        ],
        <String>['flutter', 'null', 'widget', 'state', 'test'],
      ),
      _Seed(
        'Ironclad Systems',
        'Nora Blake',
        'Cybersecurity',
        <String>[
          'Security Analyst Intern',
          'SOC Analyst',
          'AppSec Junior',
          'Threat Intel Intern',
        ],
        <String>[
          'triage suspicious failed-login spikes',
          'explain least privilege for a service account',
          'remediate a reflected XSS finding',
          'prioritize vulnerabilities by exploitability',
        ],
        <String>['log', 'privilege', 'xss', 'severity', 'auth'],
      ),
      _Seed(
        'DataNest Analytics',
        'Priya Shah',
        'Data Science',
        <String>[
          'Data Analyst Intern',
          'Junior Data Scientist',
          'Analytics Engineer',
          'BI Intern',
        ],
        <String>[
          'clean a dataset with missing revenue fields',
          'explain a sudden drop in conversion rate',
          'choose a metric for A/B test success',
          'detect leakage in a training set',
        ],
        <String>['missing', 'metric', 'bias', 'join', 'outlier'],
      ),
      _Seed(
        'Neuron Forge',
        'Chris Adeyemi',
        'AI & Machine Learning',
        <String>[
          'ML Intern',
          'Junior ML Engineer',
          'Applied AI Analyst',
          'NLP Intern',
        ],
        <String>[
          'investigate a model that overfits validation',
          'choose a metric for class imbalance',
          'debug incorrect predictions on minority class',
          'explain train/serve skew',
        ],
        <String>['overfit', 'precision', 'recall', 'skew', 'split'],
      ),
      _Seed(
        'Helix Compute',
        'Jordan Reyes',
        'Computer Science',
        <String>[
          'Algorithms Intern',
          'Systems Intern',
          'Research Engineer Intern',
          'Junior Software Engineer',
        ],
        <String>[
          'optimize an O(n^2) search under a time limit',
          'explain hash collisions',
          'choose between BFS and DFS',
          'reason about memory vs time tradeoffs',
        ],
        <String>['complexity', 'hash', 'bfs', 'dfs', 'tradeoff'],
      ),
      _Seed(
        'Uptime Collective',
        'Alex Kim',
        'Information Technology',
        <String>[
          'IT Support Intern',
          'Systems Admin Junior',
          'Cloud Support Associate',
          'NOC Intern',
        ],
        <String>[
          'restore a downed internal wiki service',
          'prioritize tickets during an outage',
          'explain DNS troubleshooting steps',
          'document a rollback plan',
        ],
        <String>['dns', 'rollback', 'outage', 'ticket', 'monitor'],
      ),
      _Seed(
        'Cloudspan Apps',
        'Riley Chen',
        'Software Engineering',
        <String>[
          'SRE Intern',
          'DevOps Junior',
          'API Engineer',
          'QA Automation Intern',
        ],
        <String>[
          'design health checks for a payment API',
          'explain blue/green deploys',
          'write an idempotent webhook handler',
          'reduce flaky CI tests',
        ],
        <String>['idempotent', 'deploy', 'ci', 'health', 'retry'],
      ),
      _Seed(
        'Harbor Soft',
        'Mina Okonkwo',
        'Software Engineering',
        <String>[
          'Intern Software Engineer',
          'Junior Backend Engineer',
          'Associate Product Engineer',
          'Support Engineer',
        ],
        <String>[
          'explain REST vs RPC briefly',
          'handle pagination correctly',
          'prevent N+1 queries',
          'secure an API key in a mobile client',
        ],
        <String>['pagination', 'n+1', 'rest', 'secret', 'cache'],
      ),
    ];

    int i = 0;
    for (final _Seed seed in seeds) {
      for (int r = 0; r < seed.roles.length; r++) {
        for (int q = 0; q < seed.prompts.length; q++) {
          i++;
          final String role = seed.roles[r];
          final String openerPrompt = seed.prompts[q];
          final String level = role.toLowerCase().contains('intern')
              ? 'Intern'
              : role.toLowerCase().contains('junior') ||
                      role.toLowerCase().contains('associate')
                  ? 'Junior'
                  : 'Advanced';
          out.add(
            InterviewScenario(
              id: 'iv_${i.toString().padLeft(3, '0')}',
              title: '$role interview',
              company: seed.company,
              role: role,
              recruiter: seed.recruiter,
              level: level,
              majorTag: seed.major,
              opener:
                  'Hi — I am ${seed.recruiter} from ${seed.company}. '
                  'Thanks for practicing with me. Please $openerPrompt.',
              followUps: <String>[
                'Good start. What would you verify first, and why?',
                'How would you communicate risk to a non-technical stakeholder?',
                'What test or check would convince you the fix is durable?',
                'If this failed in production at 2am, what is your first move?',
              ],
              hint: 'Mention concrete steps and at least one of: '
                  '${seed.keywords.take(3).join(", ")}.',
              keywords: seed.keywords,
            ),
          );
        }
      }
    }
    return out;
  }
}

class _Seed {
  const _Seed(
    this.company,
    this.recruiter,
    this.major,
    this.roles,
    this.prompts,
    this.keywords,
  );

  final String company;
  final String recruiter;
  final String major;
  final List<String> roles;
  final List<String> prompts;
  final List<String> keywords;
}
