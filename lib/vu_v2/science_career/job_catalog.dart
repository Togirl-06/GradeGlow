import 'science_career_content.dart';

/// Large generated job board across companies and roles.
abstract final class CareerJobs {
  static final List<JobListing> all = _build();

  static JobListing? byId(String id) {
    for (final JobListing j in all) {
      if (j.id == id) return j;
    }
    return null;
  }

  static bool isNorthwindJob(String jobId) {
    if (jobId == 'northwind_junior' || jobId.startsWith('northwind')) {
      return true;
    }
    return byId(jobId)?.company == 'Northwind Labs';
  }

  static List<JobListing> _build() {
    final List<JobListing> out = <JobListing>[
      const JobListing(
        id: 'northwind_junior',
        title: 'Junior Software Engineer',
        company: 'Northwind Labs',
        companyLetter: 'N',
        mode: 'Hybrid',
        level: 'Junior',
        payLabel: '\$26.00 – \$32.00 / hour',
        blurb:
            'Northwind Labs builds developer tools for growing teams. '
            'You will fix bugs, ship small changes, and learn the codebase '
            'with a supportive engineering manager.',
        skills: <String>['Python', 'Debugging', 'Git basics', 'Unit testing'],
        majorTag: 'Software Engineering',
      ),
    ];

    final List<_Co> companies = <_Co>[
      _Co('Northwind Labs', 'N', 'Software Engineering', <String>[
        'Junior Software Engineer',
        'Backend Intern',
        'Full-Stack Engineer',
        'QA Automation Intern',
        'Platform Engineer',
        'API Engineer',
      ], <String>[
        'Python',
        'Debugging',
        'Git',
        'Testing',
      ]),
      _Co('Pixelforge Studio', 'P', 'Web Development', <String>[
        'Web Developer Intern',
        'Frontend Engineer',
        'UI Engineer',
        'Design Systems Intern',
        'Accessibility Intern',
        'Junior Web Developer',
      ], <String>[
        'HTML',
        'CSS',
        'JavaScript',
        'Responsive',
      ]),
      _Co('Brightloop', 'B', 'Mobile App Development', <String>[
        'Mobile App Intern',
        'Flutter Developer',
        'iOS Intern',
        'Android Intern',
        'Mobile QA Intern',
        'Junior Mobile Engineer',
      ], <String>[
        'Flutter',
        'Dart',
        'UI',
        'Widget tests',
      ]),
      _Co('Ironclad Systems', 'I', 'Cybersecurity', <String>[
        'Security Analyst Intern',
        'SOC Analyst',
        'AppSec Junior',
        'Threat Intel Intern',
        'Security Engineer Intern',
        'GRC Intern',
      ], <String>[
        'Logs',
        'Networking',
        'Threat basics',
        'OWASP',
      ]),
      _Co('DataNest Analytics', 'D', 'Data Science', <String>[
        'Data Analyst Intern',
        'Junior Data Scientist',
        'Analytics Engineer',
        'BI Intern',
        'Data Engineer Intern',
        'Research Analyst',
      ], <String>[
        'SQL',
        'Python',
        'Pandas',
        'Visualization',
      ]),
      _Co('Neuron Forge', 'A', 'AI & Machine Learning', <String>[
        'ML Intern',
        'Junior ML Engineer',
        'Applied AI Analyst',
        'NLP Intern',
        'MLOps Intern',
        'Computer Vision Intern',
      ], <String>[
        'Python',
        'Metrics',
        'PyTorch basics',
        'Evaluation',
      ]),
      _Co('Helix Compute', 'H', 'Computer Science', <String>[
        'Algorithms Intern',
        'Systems Intern',
        'Research Engineer Intern',
        'Compiler Intern',
        'Junior Software Engineer',
        'Performance Intern',
      ], <String>[
        'Algorithms',
        'C++/Python',
        'Complexity',
        'Data structures',
      ]),
      _Co('Uptime Collective', 'U', 'Information Technology', <String>[
        'IT Support Intern',
        'Systems Admin Junior',
        'Cloud Support Associate',
        'NOC Intern',
        'Helpdesk Specialist',
        'Identity Intern',
      ], <String>[
        'Networking',
        'Tickets',
        'Linux basics',
        'Monitoring',
      ]),
      _Co('Cloudspan Apps', 'C', 'Software Engineering', <String>[
        'SRE Intern',
        'DevOps Junior',
        'Cloud Engineer Intern',
        'Observability Intern',
        'Release Engineer',
        'Junior Backend Engineer',
      ], <String>[
        'CI/CD',
        'Docker basics',
        'Monitoring',
        'Python',
      ]),
      _Co('Harbor Soft', 'S', 'Software Engineering', <String>[
        'Intern Software Engineer',
        'Junior Backend Engineer',
        'Associate Product Engineer',
        'Support Engineer',
        'Integrations Intern',
        'Junior Full-Stack',
      ], <String>[
        'APIs',
        'SQL',
        'Debugging',
        'Customer empathy',
      ]),
      _Co('Lumen Retail Tech', 'L', 'Web Development', <String>[
        'Ecommerce Frontend Intern',
        'Checkout Engineer',
        'CMS Intern',
        'Junior Web Engineer',
        'Performance Web Intern',
        'SEO Engineer Intern',
      ], <String>[
        'JavaScript',
        'React basics',
        'Web vitals',
        'A/B tests',
      ]),
      _Co('Orbit Health', 'O', 'Data Science', <String>[
        'Health Data Intern',
        'Clinical Analytics Intern',
        'Junior Data Analyst',
        'Privacy Analytics Intern',
        'Operations Analyst',
        'Reporting Engineer',
      ], <String>[
        'SQL',
        'Statistics',
        'Ethics',
        'Dashboards',
      ]),
      _Co('Shield Mail', 'M', 'Cybersecurity', <String>[
        'Email Security Intern',
        'Phishing Analyst',
        'DFIR Intern',
        'Junior Security Analyst',
        'Identity Security Intern',
        'Cloud Sec Intern',
      ], <String>[
        'Phishing',
        'SIEM basics',
        'IAM',
        'Incident response',
      ]),
      _Co('Pulse Mobile', 'V', 'Mobile App Development', <String>[
        'React Native Intern',
        'Mobile Growth Intern',
        'Junior Flutter Engineer',
        'Mobile Platform Intern',
        'App Store Ops Intern',
        'Mobile Security Intern',
      ], <String>[
        'Mobile UI',
        'Release',
        'Crashlytics',
        'Dart/JS',
      ]),
      _Co('Atlas Cloud IT', 'T', 'Information Technology', <String>[
        'Endpoint Intern',
        'Identity Desk Junior',
        'Backup Admin Intern',
        'Junior Sysadmin',
        'SaaS Admin Intern',
        'Network Desk Intern',
      ], <String>[
        'Active Directory',
        'Tickets',
        'Backups',
        'SaaS admin',
      ]),
    ];

    const List<String> modes = <String>['Remote', 'Hybrid', 'Office'];
    const List<String> levels = <String>['Intern', 'Junior', 'Mid-level'];

    int n = 0;
    for (final _Co co in companies) {
      for (int r = 0; r < co.roles.length; r++) {
        for (int shift = 0; shift < 2; shift++) {
          n++;
          final String id = n == 1 && co.name == 'Northwind Labs'
              ? 'northwind_junior_alt_$shift'
              : 'job_${n.toString().padLeft(3, '0')}';
          // Keep original northwind_junior unique; skip duplicate title clone on first.
          if (co.name == 'Northwind Labs' &&
              co.roles[r] == 'Junior Software Engineer' &&
              shift == 0) {
            continue;
          }
          final String mode = modes[(n + shift) % modes.length];
          final String level = levels[(r + shift) % levels.length];
          // Hourly USD ranges by level (stored as cents for formatting).
          final int lowCents = switch (level) {
            'Intern' => 1600 + (n * 11) % 600,
            'Junior' => 2200 + (n * 13) % 800,
            _ => 3000 + (n * 17) % 1000,
          };
          final int highCents = lowCents + 300 + (n % 5) * 100;
          final String payLow =
              '\$${(lowCents / 100).toStringAsFixed(2)}';
          final String payHigh =
              '\$${(highCents / 100).toStringAsFixed(2)}';
          out.add(
            JobListing(
              id: id,
              title: co.roles[r],
              company: co.name,
              companyLetter: co.letter,
              mode: mode,
              level: level,
              payLabel: '$payLow – $payHigh / hour',
              blurb:
                  '${co.name} is hiring for ${co.roles[r]}. '
                  'You will ship real work in a simulated sprint, collaborate with NPCs, '
                  'and grow skills in ${co.major}.',
              skills: co.skills,
              majorTag: co.major,
            ),
          );
        }
      }
    }
    return out;
  }
}

class _Co {
  const _Co(this.name, this.letter, this.major, this.roles, this.skills);
  final String name;
  final String letter;
  final String major;
  final List<String> roles;
  final List<String> skills;
}
