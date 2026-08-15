import '../../models/law/law_program.dart';
import 'law_topic_factory.dart';

/// Extra topics so every Law School specialization has a full practice set.
class LawTopicExtras {
  LawTopicExtras._();

  static LawLesson t({
    required String id,
    required String title,
    required String field,
    required String hook,
    required String question,
    required String doctrine,
    required List<String> elements,
    String writingType = 'Client memo',
    String? caseId,
  }) =>
      LawTopicFactory.intro(
        id: id,
        title: title,
        field: field,
        hook: hook,
        question: question,
        doctrine: doctrine,
        elements: elements,
        writingType: writingType,
        simulationCaseId: caseId,
      );

  static List<LawLesson> forSpec(String specId) => switch (specId) {
        'constitutional_law' => constitutional,
        'criminal_law' => criminal,
        'civil_procedure' => civilProcedure,
        'contracts' => contracts,
        'torts' => torts,
        'property' => property,
        'evidence' => evidence,
        'family_law' => family,
        'business_law' => business,
        'corporate_law' => corporate,
        'employment_law' => employment,
        'tax_law' => tax,
        'immigration_law' => immigration,
        'environmental_law' => environmental,
        'ip_law' => ip,
        'cyber_law' => cyber,
        'international_law' => international,
        'human_rights' => humanRights,
        'healthcare_law' => healthcare,
        'real_estate_law' => realEstate,
        'bankruptcy' => bankruptcy,
        'insurance_law' => insurance,
        'entertainment_law' => entertainment,
        'sports_law' => sports,
        'maritime_law' => maritime,
        'advocacy' => advocacy,
        _ => const <LawLesson>[],
      };

  // —— Constitutional (add 3 → 6) ——
  static final List<LawLesson> constitutional = <LawLesson>[
    t(
      id: 'due_process',
      title: 'Procedural Due Process',
      field: 'Constitutional Law',
      hook: 'A state suspends a professional license without a hearing after an anonymous tip.',
      question: 'What process is due before the government takes a protected interest?',
      doctrine:
          'Procedural due process requires notice and a meaningful opportunity to be heard when the government deprives a person of life, liberty, or property.',
      elements: <String>['Protected interest', 'Deprivation', 'Notice', 'Hearing', 'Timing/formality'],
      writingType: 'Due process brief',
      caseId: 'campus_speech_ban',
    ),
    t(
      id: 'commerce_clause',
      title: 'Commerce Clause Limits',
      field: 'Constitutional Law',
      hook: 'Congress bans a purely local activity, claiming it affects interstate markets in the aggregate.',
      question: 'How far may Congress regulate under the Commerce Clause?',
      doctrine:
          'Congress may regulate channels, instrumentalities, and activities with a substantial effect on interstate commerce, subject to federalism limits.',
      elements: <String>['Channels', 'Instrumentalities', 'Substantial effects', 'Aggregation', 'Federalism limits'],
      writingType: 'Constitutional challenge memo',
      caseId: 'campus_speech_ban',
    ),
    t(
      id: 'separation_powers',
      title: 'Separation of Powers',
      field: 'Constitutional Law',
      hook: 'The executive refuses to spend funds Congress appropriated for a program it opposes.',
      question: 'Who controls the purse — and what remedies exist?',
      doctrine:
          'The Constitution separates legislative, executive, and judicial powers; spending and appointments disputes often turn on textual grants and historical practice.',
      elements: <String>['Textual grant', 'Encroachment', 'Historical practice', 'Standing', 'Remedy'],
      writingType: 'Separation-of-powers memo',
      caseId: 'campus_speech_ban',
    ),
  ];

  // —— Criminal (add 4 → 6) ——
  static final List<LawLesson> criminal = <LawLesson>[
    t(
      id: 'homicide',
      title: 'Homicide Degrees',
      field: 'Criminal Law',
      hook: 'A bar fight ends with a fatal blow. The state charges murder; defense argues manslaughter.',
      question: 'What mental states separate murder from manslaughter?',
      doctrine:
          'Homicide liability turns on actus reus plus mens rea — purpose, knowledge, recklessness, or negligence — and jurisdiction-specific degrees.',
      elements: <String>['Unlawful killing', 'Mens rea', 'Causation', 'Degree/mitigation', 'Defenses'],
      writingType: 'Charging memo',
      caseId: 'burglary_apartment',
    ),
    t(
      id: 'attempt',
      title: 'Attempt & Incomplete Crimes',
      field: 'Criminal Law',
      hook: 'Police stop a defendant outside a bank with a mask and a note — before entry.',
      question: 'Has the defendant crossed from preparation into attempt?',
      doctrine:
          'Attempt generally requires intent to commit the target crime plus a substantial step toward commission.',
      elements: <String>['Specific intent', 'Substantial step', 'Abandonment?', 'Impossibility', 'Merger'],
      writingType: 'Defense memo',
      caseId: 'burglary_apartment',
    ),
    t(
      id: 'accomplice',
      title: 'Accomplice Liability',
      field: 'Criminal Law',
      hook: 'A friend drives the getaway car but claims they thought it was a prank.',
      question: 'When is a helper guilty of the principal\'s crime?',
      doctrine:
          'Accomplice liability typically requires intentional assistance or encouragement with the required mental state for the offense.',
      elements: <String>['Assistance/encouragement', 'Mens rea', 'Timing', 'Withdrawal', 'Derivative liability'],
      writingType: 'Prosecution theory memo',
      caseId: 'burglary_apartment',
    ),
    t(
      id: 'theft',
      title: 'Theft & Larceny',
      field: 'Criminal Law',
      hook: 'A roommate takes a laptop "to teach a lesson" and keeps it for a week.',
      question: 'Is this theft, unauthorized use, or no crime?',
      doctrine:
          'Theft offenses generally require taking property of another with intent to permanently deprive (definitions vary by statute).',
      elements: <String>['Property of another', 'Taking/control', 'Intent to deprive', 'Value', 'Defenses'],
      writingType: 'Charging advice',
      caseId: 'burglary_apartment',
    ),
  ];

  // —— Civ Pro (add 4 → 6) ——
  static final List<LawLesson> civilProcedure = <LawLesson>[
    t(
      id: 'pleadings',
      title: 'Pleadings & Plausibility',
      field: 'Civil Procedure',
      hook: 'A complaint alleges fraud in conclusory terms. Defendant moves to dismiss.',
      question: 'What must a complaint plead to survive a motion to dismiss?',
      doctrine:
          'Modern pleading requires a short and plain statement showing entitlement to relief; fraud and some claims need particularity; plausibility standards apply in federal court.',
      elements: <String>['Claim elements', 'Factual sufficiency', 'Particularity', 'Plausibility', 'Amendment'],
      writingType: '12(b)(6) brief',
      caseId: 'summary_judgment_slip',
    ),
    t(
      id: 'discovery',
      title: 'Discovery Scope',
      field: 'Civil Procedure',
      hook: 'Plaintiff demands every email the company ever sent about "safety." Defendant calls it a fishing expedition.',
      question: 'What is discoverable, and how do courts limit burden?',
      doctrine:
          'Discovery reaches nonprivileged matter relevant to a claim or defense and proportional to the needs of the case.',
      elements: <String>['Relevance', 'Proportionality', 'Privilege', 'Work product', 'Sanctions'],
      writingType: 'Motion to compel',
      caseId: 'summary_judgment_slip',
    ),
    t(
      id: 'joinder',
      title: 'Joinder of Parties',
      field: 'Civil Procedure',
      hook: 'A crash involves three cars and an insurer. Counsel debates who must be joined.',
      question: 'When is joinder required or permissive?',
      doctrine:
          'Joinder rules balance efficiency and fairness — required parties, permissive parties, and intervention each have tests.',
      elements: <String>['Required party', 'Feasibility', 'Permissive joinder', 'Intervention', 'Prejudice'],
      writingType: 'Joinder memo',
      caseId: 'summary_judgment_slip',
    ),
    t(
      id: 'res_judicata',
      title: 'Claim & Issue Preclusion',
      field: 'Civil Procedure',
      hook: 'Plaintiff lost a state case, then files a related federal suit on overlapping facts.',
      question: 'What is barred — the claim, an issue, or neither?',
      doctrine:
          'Claim preclusion bars relitigation of claims that were or should have been brought; issue preclusion bars relitigation of decided issues under stricter conditions.',
      elements: <String>['Final judgment', 'Same claim/issue', 'Same parties/privity', 'Actually litigated', 'Essential to judgment'],
      writingType: 'Preclusion brief',
      caseId: 'summary_judgment_slip',
    ),
  ];

  // —— Contracts (add 4 → 6) ——
  static final List<LawLesson> contracts = <LawLesson>[
    t(
      id: 'consideration',
      title: 'Consideration & Promissory Estoppel',
      field: 'Contracts',
      hook: 'An uncle promises \$10,000 for college "if you quit your job." The student quits; the uncle reneges.',
      question: 'Is there a bargain — or only reliance?',
      doctrine:
          'Consideration is a bargained-for exchange; promissory estoppel may enforce a promise that induces reasonable detrimental reliance.',
      elements: <String>['Bargain', 'Legal detriment', 'Reliance', 'Injustice', 'Remedy measure'],
      writingType: 'Demand letter',
      caseId: 'vendor_breach',
    ),
    t(
      id: 'statute_frauds',
      title: 'Statute of Frauds',
      field: 'Contracts',
      hook: 'A land sale is agreed by text messages with price and parcel ID, but no formal deed yet.',
      question: 'Is the writing enough?',
      doctrine:
          'Certain contracts must be evidenced by a signed writing; UCC and land-sale rules differ on what satisfies the statute.',
      elements: <String>['Covered contract?', 'Writing', 'Signature', 'Essential terms', 'Exceptions'],
      writingType: 'Enforceability memo',
      caseId: 'vendor_breach',
    ),
    t(
      id: 'conditions',
      title: 'Conditions & Excuses',
      field: 'Contracts',
      hook: 'A construction contract requires architect approval before payment. Approval is delayed for months.',
      question: 'Is payment due, excused, or still conditional?',
      doctrine:
          'Express conditions must generally occur unless excused by waiver, prevention, or related doctrines; courts dislike forfeitures.',
      elements: <String>['Express condition', 'Substantial performance', 'Waiver', 'Prevention', 'Excuse'],
      writingType: 'Payment demand',
      caseId: 'vendor_breach',
    ),
    t(
      id: 'ucc_goods',
      title: 'UCC Sale of Goods',
      field: 'Contracts',
      hook: 'A buyer rejects a shipment of widgets as nonconforming after using some for testing.',
      question: 'Acceptance, rejection, or revocation — and what damages?',
      doctrine:
          'Article 2 governs goods contracts with special rules on offer/acceptance, warranties, rejection, and remedies.',
      elements: <String>['Goods?', 'Perfect tender / cure', 'Acceptance', 'Warranty', 'Buyer remedies'],
      writingType: 'UCC advice letter',
      caseId: 'vendor_breach',
    ),
  ];

  // —— Torts (add 4 → 6) ——
  static final List<LawLesson> torts = <LawLesson>[
    t(
      id: 'intentional_torts',
      title: 'Battery & Assault',
      field: 'Torts',
      hook: 'A coach throws a clipboard that grazes a player\'s arm during an angry tirade.',
      question: 'Battery, assault, both, or neither?',
      doctrine:
          'Battery is intentional harmful or offensive contact; assault is intentional creation of apprehension of imminent contact.',
      elements: <String>['Intent', 'Contact / apprehension', 'Harmful or offensive', 'Causation', 'Privileges'],
      writingType: 'Complaint outline',
      caseId: 'exploding_laptop',
    ),
    t(
      id: 'defamation',
      title: 'Defamation',
      field: 'Torts',
      hook: 'A blogger posts that a local chef "poisons customers." Reviews crater overnight.',
      question: 'What must the chef prove — and what First Amendment limits apply?',
      doctrine:
          'Defamation requires a false statement of fact published to a third party causing reputational harm; public-figure plaintiffs face higher fault standards.',
      elements: <String>['False statement of fact', 'Publication', 'Of and concerning', 'Fault', 'Damages'],
      writingType: 'Cease-and-desist',
      caseId: 'exploding_laptop',
    ),
    t(
      id: 'strict_liability',
      title: 'Abnormally Dangerous Activities',
      field: 'Torts',
      hook: 'A blasting company\'s controlled explosion cracks neighboring foundations.',
      question: 'Is negligence required, or is liability strict?',
      doctrine:
          'Abnormally dangerous activities may trigger strict liability for resulting harm regardless of reasonable care.',
      elements: <String>['Activity type', 'High risk', 'Uncommonality', 'Causation', 'Scope of liability'],
      writingType: 'Liability memo',
      caseId: 'exploding_laptop',
    ),
    t(
      id: 'damages_torts',
      title: 'Tort Damages',
      field: 'Torts',
      hook: 'A negligence plaintiff seeks medicals, lost wages, pain, and punitive damages after a drunk-driving crash.',
      question: 'Which damages are available, and what limits apply?',
      doctrine:
          'Compensatory damages restore the plaintiff; punitive damages punish egregious conduct under heightened standards and constitutional limits.',
      elements: <String>['Economic loss', 'Non-economic loss', 'Causation of damages', 'Mitigation', 'Punitive threshold'],
      writingType: 'Damages demand',
      caseId: 'exploding_laptop',
    ),
  ];

  // —— Property (add 4 → 6) ——
  static final List<LawLesson> property = <LawLesson>[
    t(
      id: 'estates',
      title: 'Estates & Future Interests',
      field: 'Property',
      hook: 'A deed grants "to A for life, then to B if B graduates college." B drops out.',
      question: 'Who owns what, and when?',
      doctrine:
          'Present estates and future interests allocate ownership over time; conditions and remainders must be carefully classified.',
      elements: <String>['Present estate', 'Future interest', 'Condition', 'Vesting', 'Transferability'],
      writingType: 'Title opinion',
      caseId: 'heatless_apartment',
    ),
    t(
      id: 'easements',
      title: 'Easements',
      field: 'Property',
      hook: 'A landlocked neighbor claims a right of way across a driveway used for 20 years.',
      question: 'Express easement, prescription, or implication?',
      doctrine:
          'Easements may arise by express grant, implication, necessity, or prescription, each with distinct elements.',
      elements: <String>['Servient/dominant', 'Creation theory', 'Scope', 'Termination', 'Remedies'],
      writingType: 'Quiet-title memo',
      caseId: 'heatless_apartment',
    ),
    t(
      id: 'recording',
      title: 'Recording Acts',
      field: 'Property',
      hook: 'O conveys Blackacre to A (unrecorded), then to B (records first) who paid value without notice.',
      question: 'Who prevails under race, notice, or race-notice?',
      doctrine:
          'Recording statutes protect subsequent purchasers according to race, notice, or race-notice rules.',
      elements: <String>['Bona fide purchaser', 'Value', 'Notice', 'Race to record', 'Shelter rule'],
      writingType: 'Priority memo',
      caseId: 'heatless_apartment',
    ),
    t(
      id: 'zoning',
      title: 'Zoning & Land Use',
      field: 'Property',
      hook: 'A city rezones a lot from commercial to residential after a developer buys it for a café.',
      question: 'Is this a taking, a valid police-power regulation, or both issues?',
      doctrine:
          'Zoning is generally valid if reasonably related to public welfare; takings analysis asks whether regulation goes too far.',
      elements: <String>['Police power', 'Variance/special use', 'Spot zoning', 'Takings test', 'Remedies'],
      writingType: 'Land-use appeal memo',
      caseId: 'heatless_apartment',
    ),
  ];

  // —— Evidence (add 4 → 6) ——
  static final List<LawLesson> evidence = <LawLesson>[
    t(
      id: 'relevance',
      title: 'Relevance & Prejudice',
      field: 'Evidence',
      hook: 'The state offers graphic crime-scene photos in a case where identity is the only issue.',
      question: 'Relevant — but unfairly prejudicial?',
      doctrine:
          'Relevant evidence is admissible unless a rule excludes it; courts may exclude if unfair prejudice substantially outweighs probative value.',
      elements: <String>['Probative value', 'Materiality', 'Unfair prejudice', 'Limiting instruction', 'Alternatives'],
      writingType: 'Motion in limine',
      caseId: 'hearsay_911_call',
    ),
    t(
      id: 'privileges',
      title: 'Privileges',
      field: 'Evidence',
      hook: 'Prosecutors subpoena a therapist\'s notes about the defendant\'s sessions.',
      question: 'Which communications are protected?',
      doctrine:
          'Privileges protect confidential communications in recognized relationships; waiver and crime-fraud exceptions matter.',
      elements: <String>['Relationship', 'Confidentiality', 'Holder', 'Waiver', 'Exceptions'],
      writingType: 'Privilege log memo',
      caseId: 'hearsay_911_call',
    ),
    t(
      id: 'experts',
      title: 'Expert Testimony',
      field: 'Evidence',
      hook: 'A party offers a novel forensic method never peer-reviewed.',
      question: 'Is the expert reliable enough to testify?',
      doctrine:
          'Expert opinion must be based on sufficient facts/data, reliable principles/methods, and reliable application (Daubert/Frye frameworks vary).',
      elements: <String>['Qualification', 'Helpfulness', 'Reliability', 'Fit', 'Gatekeeping'],
      writingType: 'Daubert motion',
      caseId: 'hearsay_911_call',
    ),
    t(
      id: 'impeachment',
      title: 'Impeachment',
      field: 'Evidence',
      hook: 'A star witness has a prior inconsistent statement and a recent conviction.',
      question: 'How can you attack credibility without opening doors?',
      doctrine:
          'Impeachment tools include bias, prior inconsistent statements, character for truthfulness, and certain convictions — each with limits.',
      elements: <String>['Bias', 'Prior inconsistency', 'Conviction rules', 'Extrinsic evidence', 'Rehabilitation'],
      writingType: 'Cross outline',
      caseId: 'hearsay_911_call',
    ),
  ];

  // —— Family (add 4 → 6) ——
  static final List<LawLesson> family = <LawLesson>[
    t(
      id: 'child_support',
      title: 'Child Support',
      field: 'Family Law',
      hook: 'A parent with irregular gig income seeks a downward modification after losing a contract.',
      question: 'What income counts, and when may support change?',
      doctrine:
          'Child support follows guidelines based on income and parenting time, with modification upon material change in circumstances.',
      elements: <String>['Guideline income', 'Deviations', 'Material change', 'Imputed income', 'Enforcement'],
      writingType: 'Modification motion',
      caseId: 'custody_relocation',
    ),
    t(
      id: 'domestic_violence',
      title: 'Protective Orders',
      field: 'Family Law',
      hook: 'A client seeks an emergency protective order after threats and a broken phone.',
      question: 'What must be shown for temporary vs final relief?',
      doctrine:
          'Protective-order statutes authorize emergency and longer-term relief upon proof of abuse or credible threat under local standards.',
      elements: <String>['Covered relationship', 'Abuse/threat', 'Evidence', 'Scope of order', 'Duration'],
      writingType: 'Petition draft',
      caseId: 'custody_relocation',
    ),
    t(
      id: 'adoption',
      title: 'Adoption Consent',
      field: 'Family Law',
      hook: 'A birth parent wants to revoke consent three days after signing adoption papers.',
      question: 'When is consent irrevocable?',
      doctrine:
          'Adoption consent and revocation windows are strictly statutory; notice to putative fathers and Indian Child Welfare Act issues may apply.',
      elements: <String>['Consent validity', 'Revocation period', 'Notice', 'Best interests', 'ICWA if applicable'],
      writingType: 'Adoption counseling memo',
      caseId: 'custody_relocation',
    ),
    t(
      id: 'prenup',
      title: 'Premarital Agreements',
      field: 'Family Law',
      hook: 'A prenup waives all support. One spouse signed the night before the wedding without counsel.',
      question: 'Is the agreement enforceable?',
      doctrine:
          'Premarital agreements require voluntary execution, fair disclosure, and often conscionability review at enforcement.',
      elements: <String>['Voluntariness', 'Disclosure', 'Counsel opportunity', 'Conscionability', 'Public policy'],
      writingType: 'Enforceability opinion',
      caseId: 'custody_relocation',
    ),
  ];

  // —— Business (add 5 → 6) ——
  static final List<LawLesson> business = <LawLesson>[
    t(
      id: 'partnership',
      title: 'Partnership Formation',
      field: 'Business Law',
      hook: 'Two friends run a food truck together and split profits — with no written agreement.',
      question: 'Are they partners, and what duties apply?',
      doctrine:
          'A partnership may form by agreement to share profits of a business as co-owners, triggering fiduciary duties and joint liability.',
      elements: <String>['Intent/co-ownership', 'Profit sharing', 'Authority', 'Fiduciary duties', 'Liability'],
      writingType: 'Partnership memo',
      caseId: 'rogue_agent_deal',
    ),
    t(
      id: 'secured_transactions',
      title: 'Secured Transactions',
      field: 'Business Law',
      hook: 'A lender claims a security interest in inventory, but never filed a financing statement.',
      question: 'Is the interest attached, perfected, or vulnerable?',
      doctrine:
          'Article 9 security interests require attachment and, for priority against many third parties, perfection.',
      elements: <String>['Attachment', 'Value', 'Rights in collateral', 'Perfection', 'Priority'],
      writingType: 'UCC-1 advice',
      caseId: 'rogue_agent_deal',
    ),
    t(
      id: 'negotiable',
      title: 'Negotiable Instruments',
      field: 'Business Law',
      hook: 'A check is stolen, forged, and cashed. The account holder wants the bank to recredit.',
      question: 'Who bears the loss?',
      doctrine:
          'UCC Articles 3 and 4 allocate loss among drawers, banks, and forgers based on negligence and presentment warranties.',
      elements: <String>['Negotiation', 'Holder in due course', 'Forgery', 'Bank duties', 'Comparative fault'],
      writingType: 'Bank dispute letter',
      caseId: 'rogue_agent_deal',
    ),
    t(
      id: 'consumer_protection',
      title: 'Consumer Protection',
      field: 'Business Law',
      hook: 'An online seller advertises "free trial" then bills \$79/month with buried cancellation terms.',
      question: 'Unfair/deceptive practice — and what remedies?',
      doctrine:
          'Consumer-protection statutes prohibit unfair or deceptive acts; remedies may include damages, fees, and injunctions.',
      elements: <String>['Consumer transaction', 'Deceptive act', 'Reliance/causation', 'Damages', 'Attorney fees'],
      writingType: 'UDAP complaint outline',
      caseId: 'rogue_agent_deal',
    ),
    t(
      id: 'franchise',
      title: 'Franchise Disputes',
      field: 'Business Law',
      hook: 'A franchisor terminates a franchisee for "brand standards" after the franchisee complains about supply prices.',
      question: 'Contract rights vs statutory franchise protections?',
      doctrine:
          'Franchise relationships combine contract terms with disclosure and relationship statutes that limit unfair termination.',
      elements: <String>['Franchise definition', 'Disclosure', 'Good cause', 'Cure rights', 'Damages'],
      writingType: 'Termination response',
      caseId: 'rogue_agent_deal',
    ),
  ];

  // —— Corporate (add 5 → 6) ——
  static final List<LawLesson> corporate = <LawLesson>[
    t(
      id: 'entity_choice',
      title: 'Entity Choice',
      field: 'Corporate Law',
      hook: 'Founders debate LLC vs C-corp for a venture-backed startup.',
      question: 'What tradeoffs matter for liability, tax, and investment?',
      doctrine:
          'Entity choice affects limited liability, governance, tax treatment, and investor expectations.',
      elements: <String>['Liability shield', 'Governance', 'Tax', 'Capital raising', 'Formalities'],
      writingType: 'Entity counseling memo',
      caseId: 'shareholder_freezeout',
    ),
    t(
      id: 'duty_of_care',
      title: 'Duty of Care & BJR',
      field: 'Corporate Law',
      hook: 'Directors approve a risky acquisition after a one-hour meeting with no expert report.',
      question: 'Business judgment rule protection — or gross negligence?',
      doctrine:
          'The duty of care requires informed decision-making; the business judgment rule protects good-faith, informed decisions.',
      elements: <String>['Informed process', 'Good faith', 'Independence', 'Gross negligence', 'Exculpation'],
      writingType: 'Derivative demand',
      caseId: 'shareholder_freezeout',
    ),
    t(
      id: 'shareholder_suits',
      title: 'Derivative Suits',
      field: 'Corporate Law',
      hook: 'A minority shareholder wants to sue directors for self-dealing without asking the board first.',
      question: 'Demand required or futile?',
      doctrine:
          'Derivative plaintiffs generally must demand that the board sue, unless demand is excused as futile under governing law.',
      elements: <String>['Demand', 'Futility', 'Continuous ownership', 'Special litigation committee', 'Settlement'],
      writingType: 'Demand futility brief',
      caseId: 'shareholder_freezeout',
    ),
    t(
      id: 'mergers',
      title: 'Mergers & Appraisal',
      field: 'Corporate Law',
      hook: 'A cash-out merger closes at a price dissenters call unfair.',
      question: 'What process and price review apply?',
      doctrine:
          'Merger review may involve enhanced scrutiny or entire fairness; appraisal rights can provide a statutory fair-value remedy.',
      elements: <String>['Deal process', 'Standard of review', 'Disclosure', 'Appraisal', 'Remedies'],
      writingType: 'Appraisal memo',
      caseId: 'shareholder_freezeout',
    ),
    t(
      id: 'securities',
      title: 'Securities Fraud Basics',
      field: 'Corporate Law',
      hook: 'A CEO tweets inflated user metrics the day before selling personal shares.',
      question: 'Material misstatement and scienter?',
      doctrine:
          'Securities fraud claims typically require a material misstatement or omission, scienter, reliance, and loss causation.',
      elements: <String>['Materiality', 'Scienter', 'Reliance', 'Loss causation', 'Damages'],
      writingType: 'Securities complaint outline',
      caseId: 'shareholder_freezeout',
    ),
  ];

  // —— Employment (add 5 → 6) ——
  static final List<LawLesson> employment = <LawLesson>[
    t(
      id: 'discrimination',
      title: 'Employment Discrimination',
      field: 'Employment Law',
      hook: 'A qualified applicant over 50 is rejected; the hiring manager said they want "young energy."',
      question: 'Disparate treatment framework and proof?',
      doctrine:
          'Anti-discrimination laws prohibit adverse actions because of protected characteristics; McDonnell Douglas and mixed-motive frameworks often apply.',
      elements: <String>['Protected class', 'Adverse action', 'Causation', 'Pretext', 'Remedies'],
      writingType: 'EEOC charge outline',
      caseId: 'whistleblower_firing',
    ),
    t(
      id: 'harassment',
      title: 'Hostile Work Environment',
      field: 'Employment Law',
      hook: 'Repeated comments and messages create a toxic workplace; HR does little after complaints.',
      question: 'When is the employer liable?',
      doctrine:
          'Hostile environment harassment must be severe or pervasive; employer liability depends on the harasser\'s role and response.',
      elements: <String>['Severe/pervasive', 'Because of protected trait', 'Employer liability', 'Complaint process', 'Remedies'],
      writingType: 'Internal investigation memo',
      caseId: 'whistleblower_firing',
    ),
    t(
      id: 'wage_hour',
      title: 'Wage & Hour',
      field: 'Employment Law',
      hook: 'An "assistant manager" works 55 hours/week without overtime, mostly ringing a register.',
      question: 'Exempt or non-exempt?',
      doctrine:
          'FLSA overtime turns on salary basis and duties tests; misclassification is common.',
      elements: <String>['Employee status', 'Salary basis', 'Duties test', 'Hours worked', 'Damages'],
      writingType: 'Wage claim letter',
      caseId: 'whistleblower_firing',
    ),
    t(
      id: 'ada_accommodation',
      title: 'Disability Accommodation',
      field: 'Employment Law',
      hook: 'An employee with a medical condition asks for a schedule change; the employer says "not possible."',
      question: 'What is a reasonable accommodation?',
      doctrine:
          'Covered employers must provide reasonable accommodations for known disabilities unless undue hardship exists.',
      elements: <String>['Disability', 'Qualified individual', 'Interactive process', 'Reasonableness', 'Undue hardship'],
      writingType: 'Accommodation demand',
      caseId: 'whistleblower_firing',
    ),
    t(
      id: 'noncompete',
      title: 'Noncompete Agreements',
      field: 'Employment Law',
      hook: 'A departing salesperson is blocked from working anywhere in the state for two years.',
      question: 'Is the restraint enforceable?',
      doctrine:
          'Noncompetes are scrutinized for reasonableness in time, geography, and scope — and some jurisdictions heavily restrict them.',
      elements: <String>['Legitimate interest', 'Time', 'Geography', 'Scope', 'Blue-pencil/public policy'],
      writingType: 'Enforceability opinion',
      caseId: 'whistleblower_firing',
    ),
  ];

  // —— Tax (add 5 → 6) ——
  static final List<LawLesson> tax = <LawLesson>[
    t(
      id: 'deductions',
      title: 'Business Deductions',
      field: 'Tax Law',
      hook: 'A client deducts a home office, meals, and a "business" vacation.',
      question: 'What is ordinary and necessary — and adequately substantiated?',
      doctrine:
          'Business expenses must be ordinary and necessary; personal expenses and poorly documented items are disallowed.',
      elements: <String>['Trade or business', 'Ordinary/necessary', 'Capital vs expense', 'Substantiation', 'Disallowance'],
      writingType: 'Tax advice letter',
      caseId: 'crypto_income_audit',
    ),
    t(
      id: 'capital_gains',
      title: 'Capital Gains',
      field: 'Tax Law',
      hook: 'An investor sells stock held 11 months and crypto held 2 years in the same week.',
      question: 'Short-term vs long-term — and basis issues?',
      doctrine:
          'Capital asset characterization and holding period determine rates; basis tracking is critical.',
      elements: <String>['Capital asset', 'Holding period', 'Basis', 'Realization', 'Reporting'],
      writingType: 'Gain/loss worksheet memo',
      caseId: 'crypto_income_audit',
    ),
    t(
      id: 'tax_procedure',
      title: 'Audit & Appeals',
      field: 'Tax Law',
      hook: 'The IRS proposes a deficiency. The taxpayer has 30 days to respond.',
      question: 'What are the procedural options and deadlines?',
      doctrine:
          'Tax procedure includes examination, 30-day letters, Tax Court petitions, and collection due process rights.',
      elements: <String>['Notice', 'Deadline', 'Forum choice', 'Burden of proof', 'Collection rights'],
      writingType: 'Protest letter',
      caseId: 'crypto_income_audit',
    ),
    t(
      id: 'payroll_tax',
      title: 'Worker Classification',
      field: 'Tax Law',
      hook: 'A company treats drivers as independent contractors to avoid payroll taxes.',
      question: 'Employee or contractor for tax purposes?',
      doctrine:
          'Worker classification uses control and relationship factors; misclassification creates employment-tax exposure.',
      elements: <String>['Behavioral control', 'Financial control', 'Relationship', 'Safe harbors', 'Penalties'],
      writingType: 'Classification memo',
      caseId: 'crypto_income_audit',
    ),
    t(
      id: 'tax_penalties',
      title: 'Accuracy Penalties',
      field: 'Tax Law',
      hook: 'A return understates tax by a large percentage after aggressive positions.',
      question: 'Negligence, substantial understatement, or reasonable cause?',
      doctrine:
          'Accuracy-related penalties may apply unless the taxpayer shows substantial authority or reasonable cause and good faith.',
      elements: <String>['Understatement', 'Penalty type', 'Substantial authority', 'Disclosure', 'Reasonable cause'],
      writingType: 'Penalty abatement request',
      caseId: 'crypto_income_audit',
    ),
  ];

  // —— Immigration (add 5 → 6) ——
  static final List<LawLesson> immigration = <LawLesson>[
    t(
      id: 'nonimmigrant_visas',
      title: 'Nonimmigrant Visas',
      field: 'Immigration Law',
      hook: 'A startup wants to hire a foreign engineer quickly for a specialty role.',
      question: 'Which visa categories fit — and what proofs?',
      doctrine:
          'Nonimmigrant visas are purpose-specific (e.g., specialty occupation, students, visitors) with strict eligibility criteria.',
      elements: <String>['Category fit', 'Petition proofs', 'Status maintenance', 'Dual intent', 'Timing'],
      writingType: 'Visa strategy memo',
      caseId: 'asylum_credibility',
    ),
    t(
      id: 'removal_defense',
      title: 'Removal Defense',
      field: 'Immigration Law',
      hook: 'A long-time resident is placed in removal after a conviction.',
      question: 'What forms of relief might be available?',
      doctrine:
          'Removal defense explores cancellation, asylum/withholding, adjustment, and waivers depending on equities and grounds of removability.',
      elements: <String>['Ground of removal', 'Eligibility for relief', 'Discretionary equities', 'Evidence', 'Hearing strategy'],
      writingType: 'Relief options memo',
      caseId: 'asylum_credibility',
    ),
    t(
      id: 'inadmissibility',
      title: 'Inadmissibility Grounds',
      field: 'Immigration Law',
      hook: 'A visa applicant has a prior overstay and a misrepresentation finding.',
      question: 'Which bars apply, and are waivers possible?',
      doctrine:
          'Inadmissibility grounds (health, crime, fraud, unlawful presence) can block admission; some are waivable.',
      elements: <String>['Ground identified', 'Permanent vs temporary bar', 'Waiver availability', 'Hardship', 'Evidence'],
      writingType: 'Waiver strategy memo',
      caseId: 'asylum_credibility',
    ),
    t(
      id: 'citizenship',
      title: 'Naturalization',
      field: 'Immigration Law',
      hook: 'A green-card holder wants citizenship but has travel gaps and a recent citation.',
      question: 'Continuous residence, good moral character, and civics?',
      doctrine:
          'Naturalization requires residence, physical presence, good moral character, English/civics, and attachment to the Constitution.',
      elements: <String>['Residence', 'Physical presence', 'GMC', 'English/civics', 'Disqualifiers'],
      writingType: 'N-400 readiness checklist',
      caseId: 'asylum_credibility',
    ),
    t(
      id: 'family_petition',
      title: 'Family-Based Petitions',
      field: 'Immigration Law',
      hook: 'A U.S. citizen petitions for a sibling abroad facing long visa backlogs.',
      question: 'Preference categories and waiting times?',
      doctrine:
          'Family-based immigration uses immediate-relative and preference categories with numerical limits and priority dates.',
      elements: <String>['Relationship proof', 'Category', 'Priority date', 'Affidavit of support', 'Consular vs adjustment'],
      writingType: 'Family petition plan',
      caseId: 'asylum_credibility',
    ),
  ];

  // —— Environmental (add 5 → 6) ——
  static final List<LawLesson> environmental = <LawLesson>[
    t(
      id: 'clean_air',
      title: 'Clean Air Act Basics',
      field: 'Environmental Law',
      hook: 'A plant expands production without updating its air permit.',
      question: 'New Source Review / permit violation?',
      doctrine:
          'The Clean Air Act uses ambient standards, state plans, and permitting to control emissions from stationary and mobile sources.',
      elements: <String>['Regulated pollutant', 'Source category', 'Permit duty', 'Enforcement', 'Citizen suit'],
      writingType: 'NOI letter',
      caseId: 'river_dumping',
    ),
    t(
      id: 'nepa',
      title: 'Environmental Review (NEPA)',
      field: 'Environmental Law',
      hook: 'A federal highway project skips a full EIS despite wetlands impacts.',
      question: 'When is an EIS required?',
      doctrine:
          'NEPA requires federal agencies to consider environmental impacts of major actions through EA/EIS processes.',
      elements: <String>['Major federal action', 'Significant impact', 'EA vs EIS', 'Alternatives', 'Judicial review'],
      writingType: 'NEPA comment letter',
      caseId: 'river_dumping',
    ),
    t(
      id: 'cercla',
      title: 'Superfund Liability',
      field: 'Environmental Law',
      hook: 'EPA names a former owner as a PRP for groundwater contamination discovered decades later.',
      question: 'Who is liable, and for what costs?',
      doctrine:
          'CERCLA imposes broad liability on certain parties for release of hazardous substances, with limited defenses.',
      elements: <String>['Facility', 'Release', 'Hazardous substance', 'Covered person', 'Response costs'],
      writingType: 'PRP defense memo',
      caseId: 'river_dumping',
    ),
    t(
      id: 'esa',
      title: 'Endangered Species',
      field: 'Environmental Law',
      hook: 'A developer\'s project may affect habitat of a listed species.',
      question: 'Take prohibition and consultation duties?',
      doctrine:
          'The ESA prohibits take of listed species and requires consultation for federal actions affecting them.',
      elements: <String>['Listed species', 'Take', 'Critical habitat', 'Consultation', 'Incidental take'],
      writingType: 'ESA compliance memo',
      caseId: 'river_dumping',
    ),
    t(
      id: 'climate_litigation',
      title: 'Climate & Nuisance Claims',
      field: 'Environmental Law',
      hook: 'Cities sue energy companies for climate-related infrastructure costs.',
      question: 'Public nuisance, displacement, or justiciability barriers?',
      doctrine:
          'Climate suits raise novel causation, political-question, and federal displacement issues alongside traditional tort theories.',
      elements: <String>['Duty/nuisance theory', 'Causation', 'Displacement', 'Justiciability', 'Remedies'],
      writingType: 'Motion to dismiss outline',
      caseId: 'river_dumping',
    ),
  ];

  // —— IP (add 4 → 6) ——
  static final List<LawLesson> ip = <LawLesson>[
    t(
      id: 'patent_basics',
      title: 'Patentability',
      field: 'Intellectual Property',
      hook: 'An inventor claims a software method that automates an old manual process.',
      question: 'Eligible, novel, nonobvious — or abstract?',
      doctrine:
          'Patents require eligible subject matter, novelty, nonobviousness, and adequate disclosure.',
      elements: <String>['Eligibility', 'Novelty', 'Nonobviousness', 'Enablement', 'Claims'],
      writingType: 'Patentability memo',
      caseId: 'song_sample_suit',
    ),
    t(
      id: 'trade_secret',
      title: 'Trade Secrets',
      field: 'Intellectual Property',
      hook: 'A departing engineer downloads customer lists and pricing formulas.',
      question: 'Misappropriation elements and remedies?',
      doctrine:
          'Trade secret law protects information with independent economic value that is subject to reasonable secrecy efforts.',
      elements: <String>['Secret information', 'Value', 'Secrecy efforts', 'Misappropriation', 'Remedies'],
      writingType: 'TRO application outline',
      caseId: 'song_sample_suit',
    ),
    t(
      id: 'fair_use',
      title: 'Fair Use Deep Dive',
      field: 'Intellectual Property',
      hook: 'A critic uses long clips of a film in a YouTube review that also monetizes ads.',
      question: 'Transformative fair use or infringement?',
      doctrine:
          'Fair use weighs purpose, nature, amount, and market effect — transformative use is influential but not automatic.',
      elements: <String>['Purpose', 'Nature', 'Amount', 'Market effect', 'Transformativeness'],
      writingType: 'Fair use opinion',
      caseId: 'song_sample_suit',
    ),
    t(
      id: 'right_of_publicity',
      title: 'Right of Publicity',
      field: 'Intellectual Property',
      hook: 'An ad uses a lookalike of a celebrity without permission.',
      question: 'State publicity rights vs First Amendment?',
      doctrine:
          'Publicity rights control commercial use of identity; expressive works may receive stronger First Amendment protection.',
      elements: <String>['Identity use', 'Commercial purpose', 'Consent', 'First Amendment balance', 'Remedies'],
      writingType: 'Demand letter',
      caseId: 'song_sample_suit',
    ),
  ];

  // —— Cyber (add 5 → 6) ——
  static final List<LawLesson> cyber = <LawLesson>[
    t(
      id: 'cfaa',
      title: 'Unauthorized Access',
      field: 'Cyber Law',
      hook: 'An ex-employee uses old credentials to download files after termination.',
      question: 'CFAA "without authorization" — how far does it go?',
      doctrine:
          'Computer fraud statutes target unauthorized access and exceeding authorized access, with evolving case-law limits.',
      elements: <String>['Computer', 'Access', 'Authorization', 'Damage/loss', 'Intent'],
      writingType: 'Criminal referral memo',
      caseId: 'hospital_data_breach',
    ),
    t(
      id: 'privacy_statutes',
      title: 'Privacy Statutes',
      field: 'Cyber Law',
      hook: 'An app sells precise location data without clear consent.',
      question: 'Which privacy regimes might apply?',
      doctrine:
          'Sectoral and state privacy laws (and emerging comprehensive statutes) regulate collection, use, and sale of personal data.',
      elements: <String>['Personal data', 'Consent/notice', 'Purpose limitation', 'Consumer rights', 'Enforcement'],
      writingType: 'Privacy compliance memo',
      caseId: 'hospital_data_breach',
    ),
    t(
      id: 'cyber_speech',
      title: 'Online Speech & Section 230',
      field: 'Cyber Law',
      hook: 'A platform refuses to remove defamatory user posts; the victim sues the platform.',
      question: 'When is an intermediary immune?',
      doctrine:
          'Section 230 generally immunizes platforms for third-party content, with important exceptions and ongoing reform debates.',
      elements: <String>['Interactive service', 'Third-party content', 'Publisher treatment', 'Exceptions', 'State claims'],
      writingType: '230 motion outline',
      caseId: 'hospital_data_breach',
    ),
    t(
      id: 'digital_evidence',
      title: 'Digital Evidence',
      field: 'Cyber Law',
      hook: 'Investigators want chat logs from a phone without a clear warrant strategy.',
      question: 'Fourth Amendment and authenticity issues?',
      doctrine:
          'Digital evidence raises warrant particularity, encryption, and authentication challenges at every stage.',
      elements: <String>['Search authority', 'Particularity', 'Chain of custody', 'Authentication', 'Hearsay issues'],
      writingType: 'Warrant affidavit outline',
      caseId: 'hospital_data_breach',
    ),
    t(
      id: 'ransomware_response',
      title: 'Ransomware Response',
      field: 'Cyber Law',
      hook: 'A hospital\'s systems are encrypted; attackers demand crypto payment.',
      question: 'Legal duties for notice, payment, and regulators?',
      doctrine:
          'Incident response implicates breach-notice laws, regulatory reporting, sanctions risks, and negligence exposure.',
      elements: <String>['Incident assessment', 'Notice triggers', 'Regulatory reporting', 'Sanctions risk', 'Litigation hold'],
      writingType: 'Incident playbook memo',
      caseId: 'hospital_data_breach',
    ),
  ];

  // —— International (add 5 → 6) ——
  static final List<LawLesson> international = <LawLesson>[
    t(
      id: 'jurisdiction_intl',
      title: 'International Jurisdiction',
      field: 'International Law',
      hook: 'A state prosecutes conduct abroad that harmed its nationals.',
      question: 'Which jurisdictional principles support the case?',
      doctrine:
          'Jurisdiction to prescribe may rest on territory, nationality, protective, passive personality, or universality principles.',
      elements: <String>['Principle invoked', 'Nexus', 'Reasonableness', 'Conflicts', 'Enforcement'],
      writingType: 'Jurisdiction memo',
      caseId: 'treaty_extradition',
    ),
    t(
      id: 'state_responsibility',
      title: 'State Responsibility',
      field: 'International Law',
      hook: 'A state\'s security forces attack a foreign embassy.',
      question: 'Attribution and reparation?',
      doctrine:
          'Wrongful acts attributable to a state engage international responsibility and duties of cessation and reparation.',
      elements: <String>['International obligation', 'Breach', 'Attribution', 'Circumstances precluding wrongfulness', 'Reparation'],
      writingType: 'Diplomatic claim',
      caseId: 'treaty_extradition',
    ),
    t(
      id: 'use_of_force',
      title: 'Use of Force',
      field: 'International Law',
      hook: 'A state strikes across a border after a cross-border armed attack.',
      question: 'Self-defense under the UN Charter?',
      doctrine:
          'Article 2(4) prohibits threat or use of force; self-defense and Security Council authorization are key exceptions.',
      elements: <String>['Armed attack', 'Necessity', 'Proportionality', 'Reporting', 'Collective self-defense'],
      writingType: 'Legal justification memo',
      caseId: 'treaty_extradition',
    ),
    t(
      id: 'ihl',
      title: 'Law of Armed Conflict',
      field: 'International Law',
      hook: 'During conflict, a strike hits a dual-use facility near civilians.',
      question: 'Distinction, proportionality, and precautions?',
      doctrine:
          'IHL requires distinction between civilians and combatants, proportionality, and feasible precautions in attack.',
      elements: <String>['Distinction', 'Proportionality', 'Precautions', 'Military objective', 'Accountability'],
      writingType: 'IHL compliance memo',
      caseId: 'treaty_extradition',
    ),
    t(
      id: 'investment_arbitration',
      title: 'Investment Disputes',
      field: 'International Law',
      hook: 'A foreign investor claims expropriation after a sudden license revocation.',
      question: 'Treaty standards of treatment and forum?',
      doctrine:
          'Investment treaties often guarantee fair and equitable treatment and protect against unlawful expropriation, with arbitration forums.',
      elements: <String>['Investor/investment', 'Treaty standard', 'Expropriation', 'FET', 'Arbitration'],
      writingType: 'Notice of dispute',
      caseId: 'treaty_extradition',
    ),
  ];

  // —— Human rights (add 5 → 6) ——
  static final List<LawLesson> humanRights = <LawLesson>[
    t(
      id: 'free_expression_hr',
      title: 'Freedom of Expression',
      field: 'Human Rights',
      hook: 'Journalists are fined for criticizing officials under a vague "fake news" law.',
      question: 'Legitimate restriction or rights violation?',
      doctrine:
          'Expression rights may be limited only by law for legitimate aims with necessity and proportionality.',
      elements: <String>['Protected expression', 'Restriction by law', 'Legitimate aim', 'Necessity', 'Proportionality'],
      writingType: 'Rights petition',
      caseId: 'detention_due_process',
    ),
    t(
      id: 'torture_ban',
      title: 'Torture & Ill-Treatment',
      field: 'Human Rights',
      hook: 'Detainees report beatings during interrogation to extract confessions.',
      question: 'Absolute prohibition and evidence rules?',
      doctrine:
          'Torture is absolutely prohibited; statements obtained by torture are generally inadmissible.',
      elements: <String>['Severe pain/suffering', 'Purpose', 'Official involvement', 'Absolute ban', 'Remedies'],
      writingType: 'Complaint to monitoring body',
      caseId: 'detention_due_process',
    ),
    t(
      id: 'discrimination_hr',
      title: 'Equality & Non-Discrimination',
      field: 'Human Rights',
      hook: 'A law denies benefits to a minority group without a reasoned justification.',
      question: 'Direct vs indirect discrimination analysis?',
      doctrine:
          'Equality norms prohibit unjustified differential treatment; indirect discrimination examines disparate impacts.',
      elements: <String>['Comparator', 'Differential treatment', 'Ground', 'Justification', 'Remedy'],
      writingType: 'Equality challenge memo',
      caseId: 'detention_due_process',
    ),
    t(
      id: 'refugee_rights',
      title: 'Non-Refoulement',
      field: 'Human Rights',
      hook: 'Authorities plan to return an asylum seeker to a country where they face torture risk.',
      question: 'Does non-refoulement block removal?',
      doctrine:
          'Non-refoulement prohibits return to places where there is a real risk of torture or serious harm.',
      elements: <String>['Risk assessment', 'Protected harm', 'Individualized inquiry', 'Diplomatic assurances', 'Remedies'],
      writingType: 'Stay of removal brief',
      caseId: 'detention_due_process',
    ),
    t(
      id: 'hr_remedies',
      title: 'Remedies & Accountability',
      field: 'Human Rights',
      hook: 'Victims seek investigation, prosecution, and reparations after security-force abuses.',
      question: 'What remedies does human rights law require?',
      doctrine:
          'Effective remedies include investigation, prosecution where warranted, and reparation — not only monetary damages.',
      elements: <String>['Duty to investigate', 'Prosecution', 'Reparation', 'Guarantees of non-repetition', 'Forum'],
      writingType: 'Reparations petition',
      caseId: 'detention_due_process',
    ),
  ];

  // —— Healthcare (add 5 → 6) ——
  static final List<LawLesson> healthcare = <LawLesson>[
    t(
      id: 'malpractice',
      title: 'Medical Malpractice',
      field: 'Healthcare Law',
      hook: 'A delayed diagnosis leads to advanced disease that earlier testing might have caught.',
      question: 'Standard of care and causation?',
      doctrine:
          'Malpractice generally requires duty, breach of the professional standard of care, causation, and damages.',
      elements: <String>['Duty', 'Standard of care', 'Breach', 'Causation', 'Damages'],
      writingType: 'Malpractice demand',
      caseId: 'surgery_consent',
    ),
    t(
      id: 'hipaa',
      title: 'Health Privacy (HIPAA)',
      field: 'Healthcare Law',
      hook: 'A clinic employee posts a patient\'s surgery details on social media.',
      question: 'Covered entity duties and breach response?',
      doctrine:
          'HIPAA Privacy and Security Rules limit uses/disclosures of PHI and require safeguards and breach notification.',
      elements: <String>['PHI', 'Covered entity/BA', 'Permitted use', 'Safeguards', 'Breach notice'],
      writingType: 'Privacy incident memo',
      caseId: 'surgery_consent',
    ),
    t(
      id: 'emtala',
      title: 'Emergency Care Duties',
      field: 'Healthcare Law',
      hook: 'An ER turns away an uninsured patient in active labor.',
      question: 'EMTALA screening and stabilization duties?',
      doctrine:
          'EMTALA requires Medicare hospitals to provide medical screening and stabilizing treatment for emergency conditions.',
      elements: <String>['Comes to ER', 'MSE', 'Emergency condition', 'Stabilization/transfer', 'Enforcement'],
      writingType: 'EMTALA complaint outline',
      caseId: 'surgery_consent',
    ),
    t(
      id: 'capacity',
      title: 'Capacity & Surrogates',
      field: 'Healthcare Law',
      hook: 'A confused patient refuses life-saving treatment; family disagrees with the refusal.',
      question: 'Who decides, and how is capacity assessed?',
      doctrine:
          'Informed consent requires decision-making capacity; when lacking, surrogates and advance directives guide care.',
      elements: <String>['Capacity assessment', 'Advance directive', 'Surrogate priority', 'Best interests', 'Ethics consult'],
      writingType: 'Ethics/legal memo',
      caseId: 'surgery_consent',
    ),
    t(
      id: 'fda_devices',
      title: 'FDA & Devices',
      field: 'Healthcare Law',
      hook: 'A hospital uses a cleared device in a novel way not on the label; a patient is injured.',
      question: 'Off-label use liability and FDA preemption issues?',
      doctrine:
          'FDA regulation of drugs/devices interacts with tort liability; off-label use and preemption are recurring issues.',
      elements: <String>['Regulatory status', 'Labeling', 'Off-label use', 'Preemption', 'Tort theories'],
      writingType: 'Product liability memo',
      caseId: 'surgery_consent',
    ),
  ];

  // —— Real estate (add 5 → 6) ——
  static final List<LawLesson> realEstate = <LawLesson>[
    t(
      id: 'mortgages',
      title: 'Mortgages & Foreclosure',
      field: 'Real Estate Law',
      hook: 'A homeowner misses payments; the lender accelerates and starts foreclosure.',
      question: 'What defenses and loss-mitigation rights exist?',
      doctrine:
          'Mortgage law governs security interests in land; foreclosure procedures and borrower protections are highly statutory.',
      elements: <String>['Default', 'Acceleration', 'Notice', 'Foreclosure process', 'Defenses/mitigation'],
      writingType: 'Borrower options memo',
      caseId: 'earnest_money_fight',
    ),
    t(
      id: 'title_insurance',
      title: 'Title Insurance',
      field: 'Real Estate Law',
      hook: 'After closing, a previously undisclosed easement blocks the buyer\'s planned garage.',
      question: 'Covered risk or exclusion?',
      doctrine:
          'Title insurance covers certain title defects existing at policy date, subject to exclusions and exceptions.',
      elements: <String>['Covered risk', 'Exception', 'Exclusion', 'Duty to defend', 'Indemnity'],
      writingType: 'Title claim letter',
      caseId: 'earnest_money_fight',
    ),
    t(
      id: 'commercial_lease',
      title: 'Commercial Leases',
      field: 'Real Estate Law',
      hook: 'A retail tenant wants out after foot traffic collapses; the lease has continuous-operation and guaranty clauses.',
      question: 'Assignment, sublease, or breach?',
      doctrine:
          'Commercial leases allocate rent, CAM, use, assignment, and default remedies largely by contract.',
      elements: <String>['Lease covenants', 'Default', 'Mitigation', 'Assignment/sublease', 'Guaranties'],
      writingType: 'Lease exit strategy',
      caseId: 'earnest_money_fight',
    ),
    t(
      id: 'construction',
      title: 'Construction Disputes',
      field: 'Real Estate Law',
      hook: 'A contractor walks off a job after nonpayment; the owner claims defective work.',
      question: 'Mechanics\' liens, breach, and setoff?',
      doctrine:
          'Construction projects layer contracts, change orders, lien rights, and warranty claims.',
      elements: <String>['Contract scope', 'Change orders', 'Payment', 'Lien rights', 'Defects'],
      writingType: 'Demand / lien notice',
      caseId: 'earnest_money_fight',
    ),
    t(
      id: 'broker_duties',
      title: 'Broker Duties',
      field: 'Real Estate Law',
      hook: 'A buyer learns their broker also represented the seller and pushed a quick close.',
      question: 'Disclosure and loyalty duties?',
      doctrine:
          'Real estate brokers owe fiduciary or statutory duties of loyalty, disclosure, and care depending on agency status.',
      elements: <String>['Agency relationship', 'Disclosure', 'Loyalty', 'Dual agency rules', 'Remedies'],
      writingType: 'Broker complaint letter',
      caseId: 'earnest_money_fight',
    ),
  ];

  // —— Bankruptcy (add 5 → 6) ——
  static final List<LawLesson> bankruptcy = <LawLesson>[
    t(
      id: 'chapter_choice',
      title: 'Chapter 7 vs 13',
      field: 'Bankruptcy',
      hook: 'A wage earner with a house in arrears asks whether to liquidate or reorganize.',
      question: 'Which chapter fits goals and eligibility?',
      doctrine:
          'Chapter 7 liquidates nonexempt assets; Chapter 13 uses a payment plan — eligibility and goals drive the choice.',
      elements: <String>['Goals', 'Means test/eligibility', 'Exemptions', 'Plan feasibility', 'Discharge scope'],
      writingType: 'Chapter choice memo',
      caseId: 'stay_violation',
    ),
    t(
      id: 'exemptions',
      title: 'Exemptions',
      field: 'Bankruptcy',
      hook: 'A debtor wants to keep a car and modest home equity in Chapter 7.',
      question: 'What can be exempted?',
      doctrine:
          'Exemption statutes protect certain property from creditors; state or federal schemes may apply.',
      elements: <String>['Applicable scheme', 'Homestead', 'Personal property', 'Wildcard', 'Objection timing'],
      writingType: 'Exemption schedule advice',
      caseId: 'stay_violation',
    ),
    t(
      id: 'preferences',
      title: 'Preferential Transfers',
      field: 'Bankruptcy',
      hook: 'A struggling company paid one supplier in full 60 days before filing.',
      question: 'Can the trustee claw it back?',
      doctrine:
          'Preference law allows avoidance of certain transfers that favor one creditor shortly before bankruptcy.',
      elements: <String>['Transfer', 'Antecedent debt', 'Insolvency', 'Preference period', 'Defenses'],
      writingType: 'Preference demand response',
      caseId: 'stay_violation',
    ),
    t(
      id: 'discharge',
      title: 'Discharge & Exceptions',
      field: 'Bankruptcy',
      hook: 'A creditor claims a debt for fraud should survive discharge.',
      question: 'Which debts are nondischargeable?',
      doctrine:
          'Discharge eliminates personal liability for many debts, with statutory exceptions such as certain fraud and tax debts.',
      elements: <String>['Discharge scope', 'Exception ground', 'Timing', 'Burden of proof', 'Effect'],
      writingType: 'Nondischargeability answer',
      caseId: 'stay_violation',
    ),
    t(
      id: 'priority_claims',
      title: 'Claim Priority',
      field: 'Bankruptcy',
      hook: 'Employees, tax authorities, and unsecured vendors all want to be paid first.',
      question: 'How does the Code rank claims?',
      doctrine:
          'The Bankruptcy Code establishes priority among administrative, priority, secured, and general unsecured claims.',
      elements: <String>['Secured status', 'Priority categories', 'Administrative expense', 'Subordination', 'Distribution'],
      writingType: 'Claims strategy memo',
      caseId: 'stay_violation',
    ),
  ];

  // —— Insurance (add 5 → 6) ——
  static final List<LawLesson> insurance = <LawLesson>[
    t(
      id: 'interpretation',
      title: 'Policy Interpretation',
      field: 'Insurance Law',
      hook: 'An exclusion is ambiguous; the insurer reads it broadly against the insured.',
      question: 'How do courts construe ambiguity?',
      doctrine:
          'Insurance policies are construed as contracts; ambiguities are often interpreted in favor of coverage.',
      elements: <String>['Grant of coverage', 'Exclusion', 'Ambiguity', 'Reasonable expectations', 'Extrinsic evidence'],
      writingType: 'Coverage opinion',
      caseId: 'duty_to_defend_fire',
    ),
    t(
      id: 'bad_faith',
      title: 'Bad Faith',
      field: 'Insurance Law',
      hook: 'An insurer delays payment for months despite clear coverage and mounting damages.',
      question: 'First-party bad faith elements?',
      doctrine:
          'Bad faith claims target unreasonable denial or delay of benefits without proper cause (standards vary by jurisdiction).',
      elements: <String>['Coverage owed', 'Unreasonable conduct', 'Knowledge/recklessness', 'Damages', 'Fees/punitive'],
      writingType: 'Bad faith demand',
      caseId: 'duty_to_defend_fire',
    ),
    t(
      id: 'duty_indemnify',
      title: 'Duty to Indemnify',
      field: 'Insurance Law',
      hook: 'After trial, a judgment includes punitive damages; the insurer refuses to pay that portion.',
      question: 'What does indemnity cover?',
      doctrine:
          'The duty to indemnify is narrower than the duty to defend and turns on actual facts and policy terms, including public-policy limits.',
      elements: <String>['Covered damages', 'Exclusions', 'Allocation', 'Punitive limits', 'Consent judgments'],
      writingType: 'Indemnity demand',
      caseId: 'duty_to_defend_fire',
    ),
    t(
      id: 'notice_cooperation',
      title: 'Notice & Cooperation',
      field: 'Insurance Law',
      hook: 'The insured waits six months to tender a lawsuit; the insurer claims prejudice.',
      question: 'Late notice — forfeiture or prejudice required?',
      doctrine:
          'Policies require prompt notice and cooperation; many jurisdictions require insurer prejudice for late-notice forfeiture.',
      elements: <String>['Notice condition', 'Timing', 'Prejudice', 'Cooperation', 'Estoppel/waiver'],
      writingType: 'Tender letter',
      caseId: 'duty_to_defend_fire',
    ),
    t(
      id: 'life_disability',
      title: 'Life & Disability Claims',
      field: 'Insurance Law',
      hook: 'A disability insurer denies benefits, calling the claimant\'s condition "pre-existing."',
      question: 'ERISA or state law — and what standard of review?',
      doctrine:
          'Life and disability claims often arise under ERISA plans with deferential review, or under state insurance law for individual policies.',
      elements: <String>['Plan/policy terms', 'ERISA vs state', 'Standard of review', 'Medical evidence', 'Remedies'],
      writingType: 'Administrative appeal',
      caseId: 'duty_to_defend_fire',
    ),
  ];

  // —— Entertainment (add 5 → 6) ——
  static final List<LawLesson> entertainment = <LawLesson>[
    t(
      id: 'clearance',
      title: 'Rights Clearance',
      field: 'Entertainment Law',
      hook: 'A documentary uses music, logos, and interview clips without a full clearance chart.',
      question: 'What must be cleared before release?',
      doctrine:
          'Clearance identifies copyright, trademark, publicity, and contract rights needed for distribution.',
      elements: <String>['Copyrighted works', 'Trademarks', 'Publicity/privacy', 'Releases', 'E&O insurance'],
      writingType: 'Clearance checklist memo',
      caseId: 'talent_option_abuse',
    ),
    t(
      id: 'option_purchase',
      title: 'Option/Purchase Agreements',
      field: 'Entertainment Law',
      hook: 'A producer options a novel then sits on it while shopping a competing project.',
      question: 'Option term, reversion, and shopping rights?',
      doctrine:
          'Option agreements grant time-limited rights to purchase underlying IP, with reversion and credit/payment terms.',
      elements: <String>['Option period', 'Purchase price', 'Reversion', 'Reserved rights', 'Credits'],
      writingType: 'Contract markup',
      caseId: 'talent_option_abuse',
    ),
    t(
      id: 'guild_issues',
      title: 'Guild & Credit Issues',
      field: 'Entertainment Law',
      hook: 'Writers dispute who gets "created by" credit on a series.',
      question: 'How do guild rules interact with contracts?',
      doctrine:
          'Guild MBAs and credit determination procedures often control credits and residuals beyond the individual deal.',
      elements: <String>['Applicable MBA', 'Credit determination', 'Residuals', 'Arbitration', 'Contract carveouts'],
      writingType: 'Credit dispute memo',
      caseId: 'talent_option_abuse',
    ),
    t(
      id: 'influencer_deals',
      title: 'Influencer & Endorsement Deals',
      field: 'Entertainment Law',
      hook: 'A brand wants posts that look organic but are paid — without clear #ad labeling.',
      question: 'FTC endorsement and contract risks?',
      doctrine:
          'Endorsement deals raise FTC disclosure duties, exclusivity, morality clauses, and IP ownership of content.',
      elements: <String>['Disclosure', 'Exclusivity', 'IP ownership', 'Morality clause', 'Termination'],
      writingType: 'Influencer deal memo',
      caseId: 'talent_option_abuse',
    ),
    t(
      id: 'defamation_ent',
      title: 'Docudrama Risk',
      field: 'Entertainment Law',
      hook: 'A true-crime series portrays a living person as the killer using dramatized scenes.',
      question: 'Defamation, false light, or protected expression?',
      doctrine:
          'Docudramas balance First Amendment protection for expressive works against reputational and privacy torts.',
      elements: <String>['Fact vs fiction cues', 'Of and concerning', 'Falsity', 'Fault', 'Public interest'],
      writingType: 'Risk assessment memo',
      caseId: 'talent_option_abuse',
    ),
  ];

  // —— Sports (add 5 → 6) ——
  static final List<LawLesson> sports = <LawLesson>[
    t(
      id: 'athlete_contracts',
      title: 'Athlete Contracts',
      field: 'Sports Law',
      hook: 'A team voids a signing bonus after an athlete fails a physical disputed by the player\'s doctor.',
      question: 'Contract conditions and grievance rights?',
      doctrine:
          'Athlete contracts layer standard player agreements, bonuses, and grievance/arbitration systems.',
      elements: <String>['SPA terms', 'Conditions', 'Guaranteed money', 'Grievance', 'Remedies'],
      writingType: 'Grievance outline',
      caseId: 'stadium_injury',
    ),
    t(
      id: 'eligibility',
      title: 'Amateur Eligibility',
      field: 'Sports Law',
      hook: 'A college athlete takes NIL money and is threatened with ineligibility under conference rules.',
      question: 'What rules and antitrust issues arise?',
      doctrine:
          'Eligibility rules from schools, conferences, and governing bodies interact with NIL rights and antitrust scrutiny.',
      elements: <String>['Governing body rules', 'NIL', 'Due process in discipline', 'Antitrust', 'Remedies'],
      writingType: 'Eligibility advice letter',
      caseId: 'stadium_injury',
    ),
    t(
      id: 'league_discipline',
      title: 'League Discipline',
      field: 'Sports Law',
      hook: 'A league suspends a player for off-field conduct under a commissioner\'s "best interests" power.',
      question: 'How far can private league discipline go?',
      doctrine:
          'League constitutions and CBAs authorize discipline subject to arbitration and sometimes public-policy limits.',
      elements: <String>['Authority source', 'Notice/hearing', 'Just cause', 'Arbitration', 'Public policy'],
      writingType: 'Appeal brief outline',
      caseId: 'stadium_injury',
    ),
    t(
      id: 'antitrust_sports',
      title: 'Sports Antitrust',
      field: 'Sports Law',
      hook: 'Players challenge a league rule capping compensation for a class of athletes.',
      question: 'Rule of reason analysis in sports?',
      doctrine:
          'Sports leagues face antitrust scrutiny; some restraints are assessed under rule of reason with unique industry justifications.',
      elements: <String>['Agreement', 'Restraint', 'Market definition', 'Procompetitive justifications', 'Less restrictive alternatives'],
      writingType: 'Antitrust complaint outline',
      caseId: 'stadium_injury',
    ),
    t(
      id: 'stadium_liability',
      title: 'Venue Liability',
      field: 'Sports Law',
      hook: 'A fan is injured by inadequate netting after a foul ball.',
      question: 'Inherent risk vs negligence in stadium design?',
      doctrine:
          'Assumption of risk limits some fan claims, but inadequate safety measures can still support negligence.',
      elements: <String>['Duty of venue', 'Inherent risk', 'Industry standards', 'Warnings', 'Damages'],
      writingType: 'Premises liability memo',
      caseId: 'stadium_injury',
    ),
  ];

  // —— Maritime (add 5 → 6) ——
  static final List<LawLesson> maritime = <LawLesson>[
    t(
      id: 'jones_act',
      title: 'Jones Act Negligence',
      field: 'Maritime Law',
      hook: 'A crew member is injured by defective equipment on a vessel in navigable waters.',
      question: 'Seaman status and negligence standard?',
      doctrine:
          'The Jones Act allows seamen to sue employers for negligence with a relaxed causation standard.',
      elements: <String>['Seaman status', 'Employer', 'Negligence', 'Causation', 'Damages'],
      writingType: 'Jones Act complaint outline',
      caseId: 'harbor_collision',
    ),
    t(
      id: 'unseaworthiness',
      title: 'Unseaworthiness',
      field: 'Maritime Law',
      hook: 'A vessel sails with inadequate crew and broken safety gear; a sailor is hurt.',
      question: 'Warranty of seaworthiness vs negligence?',
      doctrine:
          'Vessel owners warrant seaworthiness — a vessel reasonably fit for its intended use — independent of negligence in some respects.',
      elements: <String>['Vessel', 'Appurtenance/crew', 'Fit for intended use', 'Causation', 'Damages'],
      writingType: 'Unseaworthiness memo',
      caseId: 'harbor_collision',
    ),
    t(
      id: 'salvage',
      title: 'Salvage Claims',
      field: 'Maritime Law',
      hook: 'A private boat tows a disabled yacht off rocks and seeks a salvage award.',
      question: 'Voluntary successful salvage — how is the award set?',
      doctrine:
          'Salvage awards compensate voluntary successful efforts to save maritime property in peril.',
      elements: <String>['Marine peril', 'Voluntary service', 'Success', 'Award factors', 'Forum'],
      writingType: 'Salvage claim letter',
      caseId: 'harbor_collision',
    ),
    t(
      id: 'carriage_goods',
      title: 'Carriage of Goods',
      field: 'Maritime Law',
      hook: 'Cargo arrives water-damaged; the bill of lading limits liability.',
      question: 'COGSA/Hague-Visby duties and package limitations?',
      doctrine:
          'Carriage regimes allocate risk for cargo loss/damage with carrier duties and liability limits.',
      elements: <String>['Bill of lading', 'Carrier duties', 'Excepted perils', 'Package limitation', 'Notice/suit time'],
      writingType: 'Cargo claim memo',
      caseId: 'harbor_collision',
    ),
    t(
      id: 'limitation_liability',
      title: 'Limitation of Liability',
      field: 'Maritime Law',
      hook: 'After a collision, the vessel owner seeks to limit liability to the post-casualty value of the ship.',
      question: 'When is limitation available?',
      doctrine:
          'The Limitation of Liability Act may cap an owner\'s liability if the loss occurred without privity or knowledge.',
      elements: <String>['Owner status', 'Privity/knowledge', 'Limitation fund', 'Concursus', 'Personal contracts'],
      writingType: 'Limitation petition outline',
      caseId: 'harbor_collision',
    ),
  ];

  // —— Advocacy (add 4 → 6) ——
  static final List<LawLesson> advocacy = <LawLesson>[
    t(
      id: 'opening',
      title: 'Opening Statement',
      field: 'Trial Advocacy',
      hook: 'You have three minutes to preview a messy negligence case without arguing.',
      question: 'How do you theme without improper argument?',
      doctrine:
          'Openings preview the evidence through a coherent theme and roadmap — persuasion without forbidden argument.',
      elements: <String>['Theme', 'Story', 'Roadmap', 'Credibility', 'No improper argument'],
      writingType: 'Opening script',
      caseId: 'campus_discipline',
    ),
    t(
      id: 'direct_exam',
      title: 'Direct Examination',
      field: 'Trial Advocacy',
      hook: 'Your key witness is nervous and tends to ramble.',
      question: 'How do you control the narrative with open questions?',
      doctrine:
          'Direct uses open-ended questions to let the witness tell the story while counsel controls pace and clarity.',
      elements: <String>['Open questions', 'Looping', 'Exhibits', 'Refresh recollection', 'Protect the witness'],
      writingType: 'Direct outline',
      caseId: 'campus_discipline',
    ),
    t(
      id: 'objections_live',
      title: 'Live Objections',
      field: 'Trial Advocacy',
      hook: 'Opposing counsel piles hearsay and leading questions into one compound ask.',
      question: 'What do you object to first — and why?',
      doctrine:
          'Effective objections are timely, specific, and strategic — preserving error without alienating the jury.',
      elements: <String>['Timeliness', 'Specific ground', 'Sidebar strategy', 'Continuing objection', 'Offer of proof'],
      writingType: 'Objection drill sheet',
      caseId: 'campus_discipline',
    ),
    t(
      id: 'negotiation_adv',
      title: 'Settlement Advocacy',
      field: 'Trial Advocacy',
      hook: 'Trial starts Monday. The other side offers 60% of your demand with a confidentiality clause.',
      question: 'How do you counsel the client on BATNA and terms?',
      doctrine:
          'Settlement advocacy combines case valuation, client counseling, and term-sheet precision under ethical constraints.',
      elements: <String>['BATNA', 'Valuation', 'Non-monetary terms', 'Client authority', 'Ethics'],
      writingType: 'Settlement counseling memo',
      caseId: 'campus_discipline',
    ),
  ];
}
