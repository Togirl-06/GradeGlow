import '../../models/law/law_program.dart';
import 'law_topic_factory.dart';

/// Additional topics so each specialization has a deeper practice set.
class LawTopicMore {
  LawTopicMore._();

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

  static final List<LawLesson> constitutional = <LawLesson>[
    t(
      id: 'equal_protection_levels',
      title: 'Equal Protection Scrutiny',
      field: 'Constitutional Law',
      hook: 'A city gives business grants only to firms owned by residents of certain zip codes.',
      question: 'What classification is this, and which scrutiny applies?',
      doctrine:
          'Equal protection scrutiny turns on whether a classification is suspect, quasi-suspect, or ordinary; rational basis usually applies to economic distinctions.',
      elements: <String>['Classification', 'Suspect class?', 'Fundamental right?', 'Scrutiny level', 'Fit to interest'],
      writingType: 'Equal protection brief',
      caseId: 'campus_speech_ban',
    ),
    t(
      id: 'takings_clause',
      title: 'Takings & Just Compensation',
      field: 'Constitutional Law',
      hook: 'A coastal town bans rebuilding after storms, wiping out a beach cottage\'s market value.',
      question: 'Is this a taking requiring just compensation?',
      doctrine:
          'Physical appropriations and some regulatory restrictions that go "too far" can be takings; compensation is measured by fair market value.',
      elements: <String>['Property interest', 'Physical vs regulatory', 'Penn Central factors', 'Public use', 'Just compensation'],
      writingType: 'Takings demand letter',
      caseId: 'campus_speech_ban',
    ),
    t(
      id: 'state_action',
      title: 'State Action Doctrine',
      field: 'Constitutional Law',
      hook: 'A private university that receives heavy state funding expels a student for a protest speech.',
      question: 'Is the university a state actor for First Amendment purposes?',
      doctrine:
          'Constitutional rights generally constrain government; private actors are covered only when their conduct is fairly attributable to the state.',
      elements: <String>['Private actor', 'Public function', 'Entanglement', 'Compulsion', 'Attribution'],
      writingType: 'State-action memo',
      caseId: 'campus_speech_ban',
    ),
    t(
      id: 'second_amendment',
      title: 'Second Amendment Challenges',
      field: 'Constitutional Law',
      hook: 'A state bans commonly owned handguns in the home for adults under 25.',
      question: 'How should a court analyze the ban after Bruen?',
      doctrine:
          'Modern Second Amendment analysis asks whether the regulated conduct is covered by the plain text and whether the regulation is consistent with historical tradition.',
      elements: <String>['Plain text coverage', 'Historical tradition', 'Analogous laws', 'Burden on right', 'Remedy'],
      writingType: 'Second Amendment brief',
      caseId: 'campus_speech_ban',
    ),
  ];

  static final List<LawLesson> criminal = <LawLesson>[
    t(
      id: 'mens_rea_mistakes',
      title: 'Mistake of Fact & Law',
      field: 'Criminal Law',
      hook: 'A defendant takes a bike believing it was abandoned; it was locked to a rack with a broken lock.',
      question: 'Does the mistake negate the required mental state?',
      doctrine:
          'Mistake of fact may negate mens rea for specific-intent crimes; mistake of law is rarely a defense unless the statute requires knowledge of illegality.',
      elements: <String>['Required mens rea', 'Honest mistake', 'Reasonableness', 'Specific vs general intent', 'Mistake of law limits'],
      writingType: 'Defense memo',
      caseId: 'burglary_apartment',
    ),
    t(
      id: 'insanity_defense',
      title: 'Insanity & Capacity',
      field: 'Criminal Law',
      hook: 'A defendant with schizophrenia claims voices ordered the assault; experts disagree on cognition vs control.',
      question: 'Which insanity test applies, and what must the defense prove?',
      doctrine:
          'Insanity tests vary (M\'Naghten, irresistible impulse, MPC); capacity focuses on whether the defendant could appreciate wrongfulness or conform conduct.',
      elements: <String>['Mental disease', 'Cognitive prong', 'Volitional prong', 'Burden of proof', 'Consequences of verdict'],
      writingType: 'Insanity brief',
      caseId: 'armed_robbery_store',
    ),
    t(
      id: 'conspiracy',
      title: 'Conspiracy',
      field: 'Criminal Law',
      hook: 'Two friends plan a warehouse theft; only one shows up and is caught empty-handed.',
      question: 'When is conspiracy complete, and what overt act is needed?',
      doctrine:
          'Conspiracy is an agreement to commit a crime plus (often) an overt act; liability can extend to reasonably foreseeable crimes of co-conspirators.',
      elements: <String>['Agreement', 'Intent', 'Overt act', 'Withdrawal', 'Pinkerton liability'],
      writingType: 'Conspiracy charging memo',
      caseId: 'armed_robbery_store',
    ),
    t(
      id: 'fourth_amendment_stop',
      title: 'Stops, Frisks & Arrests',
      field: 'Criminal Law',
      hook: 'Police stop a pedestrian for "looking nervous," frisk, and find a knife.',
      question: 'Was the stop and frisk lawful?',
      doctrine:
          'Terry stops require reasonable suspicion of crime; frisks require reasonable suspicion the person is armed and dangerous; arrests need probable cause.',
      elements: <String>['Seizure?', 'Reasonable suspicion', 'Frisk justification', 'Probable cause', 'Exclusionary remedy'],
      writingType: 'Suppression motion',
      caseId: 'burglary_apartment',
    ),
  ];

  static final List<LawLesson> civilProcedure = <LawLesson>[
    t(
      id: 'subject_matter_jurisdiction',
      title: 'Subject-Matter Jurisdiction',
      field: 'Civil Procedure',
      hook: 'A plaintiff sues in federal court on a state contract claim against a same-state defendant, adding a weak federal statute claim.',
      question: 'Is there federal-question or diversity jurisdiction — or supplemental?',
      doctrine:
          'Federal courts need constitutional and statutory subject-matter jurisdiction; supplemental jurisdiction has limits when diversity is the sole basis.',
      elements: <String>['Federal question', 'Diversity/AIC', 'Well-pleaded complaint', 'Supplemental jurisdiction', 'Remand/dismissal'],
      writingType: 'Motion to dismiss brief',
      caseId: 'discovery_sanctions',
    ),
    t(
      id: 'venue_transfer',
      title: 'Venue & Forum Non Conveniens',
      field: 'Civil Procedure',
      hook: 'A crash case is filed where the plaintiff lives, though witnesses and the scene are three states away.',
      question: 'Should the court transfer or dismiss for inconvenient forum?',
      doctrine:
          'Venue statutes and transfer rules balance convenience and justice; forum non conveniens may dismiss when an adequate alternative forum is clearly preferable.',
      elements: <String>['Proper venue', 'Transfer factors', 'Alternative forum', 'Private/public interests', 'Choice of law'],
      writingType: 'Transfer motion',
      caseId: 'summary_judgment_slip',
    ),
    t(
      id: 'class_actions',
      title: 'Class Action Certification',
      field: 'Civil Procedure',
      hook: 'Consumers seek a nationwide class over a defective phone battery that fails after 18 months.',
      question: 'Can the class be certified under Rule 23?',
      doctrine:
          'Certification requires numerosity, commonality, typicality, and adequacy, plus a Rule 23(b) path such as predominance for damages classes.',
      elements: <String>['Numerosity', 'Commonality', 'Typicality', 'Adequacy', 'Predominance/superiority'],
      writingType: 'Certification opposition',
      caseId: 'discovery_sanctions',
    ),
    t(
      id: 'appeals_finality',
      title: 'Appeals & Final Judgment Rule',
      field: 'Civil Procedure',
      hook: 'The trial court denies summary judgment and the loser notices an immediate appeal.',
      question: 'Is the order appealable now?',
      doctrine:
          'Appeals generally require a final judgment; interlocutory appeals are limited to certified questions, injunctions, and similar exceptions.',
      elements: <String>['Finality', 'Interlocutory exceptions', 'Collateral order', 'Certification', 'Standard of review'],
      writingType: 'Appealability memo',
      caseId: 'summary_judgment_slip',
    ),
  ];

  static final List<LawLesson> contracts = <LawLesson>[
    t(
      id: 'parol_evidence',
      title: 'Parol Evidence Rule',
      field: 'Contracts',
      hook: 'A signed software contract says "entire agreement." The buyer claims a salesperson promised free training.',
      question: 'Can the oral promise come in?',
      doctrine:
          'The parol evidence rule limits prior or contemporaneous extrinsic terms that contradict a fully integrated writing; exceptions include fraud, ambiguity, and collateral agreements.',
      elements: <String>['Integration', 'Contradiction vs explanation', 'Ambiguity', 'Fraud/mistake exception', 'Course of dealing'],
      writingType: 'Evidence exclusion memo',
      caseId: 'noncompete_battle',
    ),
    t(
      id: 'modification',
      title: 'Modification & Waiver',
      field: 'Contracts',
      hook: 'Parties orally agree to extend a delivery deadline; the written contract requires modifications in writing.',
      question: 'Is the extension enforceable?',
      doctrine:
          'Common-law modifications need new consideration; UCC modifications need only good faith. No-oral-modification clauses can be waived by conduct.',
      elements: <String>['NOM clause', 'Consideration / good faith', 'Waiver', 'Estoppel', 'Writing requirement'],
      writingType: 'Modification advice letter',
      caseId: 'vendor_breach',
    ),
    t(
      id: 'third_party_beneficiaries',
      title: 'Third-Party Beneficiaries',
      field: 'Contracts',
      hook: 'Parents buy a life insurance policy "for the benefit of our daughter." The insurer later denies the claim.',
      question: 'Can the daughter sue as a beneficiary?',
      doctrine:
          'Intended beneficiaries may enforce; incidental beneficiaries may not. Vesting rules limit when parties can modify without the beneficiary\'s consent.',
      elements: <String>['Intent to benefit', 'Creditor vs donee', 'Vesting', 'Defenses', 'Standing'],
      writingType: 'Beneficiary demand letter',
      caseId: 'vendor_breach',
    ),
    t(
      id: 'impossibility',
      title: 'Impossibility & Frustration',
      field: 'Contracts',
      hook: 'A wedding venue burns down a week before the reception; the couple wants a full refund plus vendor costs.',
      question: 'Is performance discharged, and who bears the loss?',
      doctrine:
          'Impossibility/impracticability and frustration of purpose can discharge duties when a basic assumption fails without the party\'s fault.',
      elements: <String>['Basic assumption', 'Supervening event', 'Fault', 'Allocation of risk', 'Restitution'],
      writingType: 'Discharge memo',
      caseId: 'vendor_breach',
    ),
  ];

  static final List<LawLesson> torts = <LawLesson>[
    t(
      id: 'proximate_cause',
      title: 'Proximate Cause & Foreseeability',
      field: 'Torts',
      hook: 'A speeding driver hits a pole; sparks start a fire that burns a warehouse two blocks away.',
      question: 'Where does liability end?',
      doctrine:
          'Proximate cause limits liability to harms within the risk created by the breach; intervening causes may cut off liability if unforeseeable.',
      elements: <String>['Cause-in-fact', 'Foreseeable harm', 'Intervening cause', 'Eggshell plaintiff', 'Scope of risk'],
      writingType: 'Causation brief',
      caseId: 'exploding_laptop',
    ),
    t(
      id: 'comparative_fault',
      title: 'Comparative & Contributory Fault',
      field: 'Torts',
      hook: 'A jogger crosses against the light and is hit by a driver who was texting.',
      question: 'How does the jogger\'s fault affect recovery?',
      doctrine:
          'Comparative negligence reduces damages by plaintiff fault; contributory negligence (rare) can bar recovery; assumption of risk may still apply.',
      elements: <String>['Plaintiff negligence', 'Allocation of fault', 'Bar vs reduction', 'Assumption of risk', 'Last clear chance'],
      writingType: 'Damages allocation memo',
      caseId: 'dog_bite_strict',
    ),
    t(
      id: 'emotional_distress',
      title: 'Emotional Distress Claims',
      field: 'Torts',
      hook: 'A hospital mistakenly tells a parent their child died; hours later it corrects the error.',
      question: 'NIED, IIED, or neither?',
      doctrine:
          'IIED requires extreme and outrageous conduct with severe distress; NIED often needs physical impact, zone of danger, or a special relationship.',
      elements: <String>['Outrageousness', 'Intent/recklessness', 'Severe distress', 'Physical manifestation', 'Bystander limits'],
      writingType: 'Complaint outline',
      caseId: 'exploding_laptop',
    ),
    t(
      id: 'vicarious_liability',
      title: 'Vicarious Liability',
      field: 'Torts',
      hook: 'A delivery driver causes a crash while making an unauthorized personal stop between routes.',
      question: 'Is the employer liable under respondeat superior?',
      doctrine:
          'Employers are liable for torts within the scope of employment; frolic vs detour and independent-contractor status are key limits.',
      elements: <String>['Employment relationship', 'Scope of employment', 'Frolic vs detour', 'Independent contractor', 'Negligent hiring'],
      writingType: 'Employer liability memo',
      caseId: 'dog_bite_strict',
    ),
  ];

  static final List<LawLesson> property = <LawLesson>[
    t(
      id: 'adverse_possession',
      title: 'Adverse Possession',
      field: 'Property Law',
      hook: 'A neighbor mows and fences a strip of land for 12 years, believing it was theirs.',
      question: 'Have they acquired title?',
      doctrine:
          'Adverse possession requires actual, open, notorious, exclusive, hostile possession for the statutory period; color of title and tacking may help.',
      elements: <String>['Actual possession', 'Open/notorious', 'Exclusive', 'Hostile/claim of right', 'Statutory period'],
      writingType: 'Quiet title memo',
      caseId: 'boundary_fence_war',
    ),
    t(
      id: 'landlord_tenant',
      title: 'Landlord-Tenant Duties',
      field: 'Property Law',
      hook: 'A tenant withholds rent after mold spreads and the landlord ignores repair requests.',
      question: 'What remedies exist for habitability failures?',
      doctrine:
          'The implied warranty of habitability and related statutes allow repair-and-deduct, rent withholding, or constructive eviction in many jurisdictions.',
      elements: <String>['Habitability', 'Notice', 'Reasonable time', 'Tenant remedies', 'Retaliation limits'],
      writingType: 'Tenant demand letter',
      caseId: 'boundary_fence_war',
    ),
    t(
      id: 'concurrent_ownership',
      title: 'Concurrent Ownership',
      field: 'Property Law',
      hook: 'Siblings inherit a house as joint tenants; one secretly deeds their interest to a buyer.',
      question: 'Was the joint tenancy severed, and what does each own now?',
      doctrine:
          'Joint tenancy needs the four unities and a right of survivorship; conveyance by one joint tenant typically severs into a tenancy in common.',
      elements: <String>['Four unities', 'Survivorship', 'Severance', 'Partition', 'Accounting'],
      writingType: 'Title opinion',
      caseId: 'boundary_fence_war',
    ),
    t(
      id: 'nuisance',
      title: 'Private Nuisance',
      field: 'Property Law',
      hook: 'A new brewery\'s late-night exhaust and noise make the next-door B&B unrentable.',
      question: 'Is this a substantial and unreasonable interference?',
      doctrine:
          'Private nuisance balances the gravity of harm against the utility of the defendant\'s conduct; remedies include damages and injunctions.',
      elements: <String>['Substantial interference', 'Unreasonableness', 'Intent/negligence', 'Coming to the nuisance', 'Remedy'],
      writingType: 'Nuisance complaint outline',
      caseId: 'boundary_fence_war',
    ),
  ];

  static final List<LawLesson> evidence = <LawLesson>[
    t(
      id: 'hearsay_exceptions',
      title: 'Hearsay Exceptions',
      field: 'Evidence',
      hook: 'A 911 caller describes a robbery in progress, then hangs up and cannot be found for trial.',
      question: 'Is the call admissible?',
      doctrine:
          'Hearsay is an out-of-court statement offered for its truth; exceptions include present sense impression, excited utterance, and business records.',
      elements: <String>['Statement', 'Out-of-court', 'Offered for truth', 'Exception fit', 'Confrontation issues'],
      writingType: 'Motion in limine',
      caseId: 'expert_gatekeeping',
    ),
    t(
      id: 'authentication',
      title: 'Authentication of Evidence',
      field: 'Evidence',
      hook: 'Plaintiff offers a screenshot of a deleted Instagram DM allegedly from the defendant.',
      question: 'How must the message be authenticated?',
      doctrine:
          'Evidence must be sufficient to support a finding that the item is what the proponent claims; digital evidence often needs metadata, witness, or distinctive content.',
      elements: <String>['Identity of item', 'Chain of custody', 'Distinctive characteristics', 'Self-authentication', 'Best evidence'],
      writingType: 'Authentication brief',
      caseId: 'expert_gatekeeping',
    ),
    t(
      id: 'character_propensity',
      title: 'Character & Propensity Limits',
      field: 'Evidence',
      hook: 'In a battery trial, the state wants to show the defendant "always starts fights" at bars.',
      question: 'When is character evidence allowed?',
      doctrine:
          'Propensity character evidence is generally barred; exceptions include accused\'s pertinent trait, victim\'s trait in limited cases, and MIMIC purposes.',
      elements: <String>['Propensity ban', 'Pertinent trait', 'MIMIC', 'Method of proof', 'Prejudice balancing'],
      writingType: 'Exclusion motion',
      caseId: 'expert_gatekeeping',
    ),
    t(
      id: 'confrontation_clause',
      title: 'Confrontation Clause',
      field: 'Evidence',
      hook: 'The state offers a lab report identifying the drug without calling the analyst.',
      question: 'Does Crawford require live testimony?',
      doctrine:
          'Testimonial hearsay against a criminal defendant is inadmissible unless the declarant is unavailable and there was a prior opportunity for cross-examination.',
      elements: <String>['Testimonial?', 'Unavailability', 'Prior cross', 'Business-record limits', 'Notice-and-demand'],
      writingType: 'Confrontation brief',
      caseId: 'expert_gatekeeping',
    ),
  ];

  static final List<LawLesson> family = <LawLesson>[
    t(
      id: 'custody_best_interests',
      title: 'Child Custody Standards',
      field: 'Family Law',
      hook: 'Parents separate; one wants to relocate across the country for a new job with the children.',
      question: 'How does a court decide custody and relocation?',
      doctrine:
          'Custody turns on the best interests of the child; relocation often requires showing benefit to the child and workable parenting time.',
      elements: <String>['Best interests factors', 'Primary caregiver', 'Relocation burden', 'Parenting time', 'Modification standard'],
      writingType: 'Custody brief',
      caseId: 'support_modification',
    ),
    t(
      id: 'divorce_property',
      title: 'Marital Property Division',
      field: 'Family Law',
      hook: 'One spouse built a startup during marriage using premarital savings; the other seeks half the equity.',
      question: 'What is marital vs separate property?',
      doctrine:
          'Equitable distribution divides marital property fairly; separate property generally includes premarital assets and some gifts/inheritances, subject to tracing and appreciation rules.',
      elements: <String>['Marital estate', 'Separate property', 'Tracing', 'Appreciation', 'Equitable factors'],
      writingType: 'Property division memo',
      caseId: 'support_modification',
    ),
    t(
      id: 'spousal_support',
      title: 'Spousal Support',
      field: 'Family Law',
      hook: 'After a 18-year marriage, one spouse left the workforce to raise children and now seeks alimony.',
      question: 'What factors drive amount and duration?',
      doctrine:
          'Spousal support considers need, ability to pay, marriage length, standard of living, and rehabilitative goals; modification may follow material change.',
      elements: <String>['Need', 'Ability to pay', 'Duration', 'Rehabilitative purpose', 'Modification'],
      writingType: 'Support worksheet memo',
      caseId: 'support_modification',
    ),
    t(
      id: 'domestic_violence_process',
      title: 'Domestic Violence Proceedings',
      field: 'Family Law',
      hook: 'A petitioner seeks an emergency protective order after threats and a smashed phone; the respondent denies everything.',
      question: 'What process and proof apply at the temporary and final hearings?',
      doctrine:
          'Protective-order statutes provide emergency ex parte relief and a prompt contested hearing; proof standards and firearm restrictions vary by jurisdiction.',
      elements: <String>['Ex parte showing', 'Notice', 'Hearing rights', 'Protected acts', 'Duration/renewal'],
      writingType: 'Protective order outline',
      caseId: 'support_modification',
    ),
  ];

  static final List<LawLesson> business = <LawLesson>[
    t(
      id: 'agency_authority',
      title: 'Agency & Authority',
      field: 'Business Law',
      hook: 'A store manager signs a supplier contract the owner never approved; the supplier ships and demands payment.',
      question: 'Is the business bound?',
      doctrine:
          'Principals are bound by agents with actual or apparent authority; ratification and estoppel can also create liability.',
      elements: <String>['Actual authority', 'Apparent authority', 'Inherent agency', 'Ratification', 'Undisclosed principal'],
      writingType: 'Agency liability memo',
      caseId: 'ucc_rejected_goods',
    ),
    t(
      id: 'ucc_secured',
      title: 'Attachment & Perfection',
      field: 'Business Law',
      hook: 'A lender takes a security interest in inventory but never files a financing statement before bankruptcy.',
      question: 'Is the interest enforceable against other creditors?',
      doctrine:
          'Attachment makes a security interest enforceable between parties; perfection (often by filing) is needed for priority against most third parties.',
      elements: <String>['Value', 'Rights in collateral', 'Authenticated security agreement', 'Perfection method', 'Priority'],
      writingType: 'UCC-1 advice letter',
      caseId: 'ucc_rejected_goods',
    ),
    t(
      id: 'piercing_veil_business',
      title: 'Piercing the Corporate Veil',
      field: 'Business Law',
      hook: 'A one-person LLC undercapitalizes, mixes personal and business funds, then injures a customer.',
      question: 'Can the owner be personally liable?',
      doctrine:
          'Courts may pierce when unity of interest and injustice exist — undercapitalization, alter ego, and fraud are classic factors.',
      elements: <String>['Alter ego', 'Undercapitalization', 'Commingling', 'Fraud/injustice', 'Enterprise liability'],
      writingType: 'Veil-piercing brief',
      caseId: 'noncompete_battle',
    ),
    t(
      id: 'antitrust_basics',
      title: 'Antitrust Basics',
      field: 'Business Law',
      hook: 'Two rival coffee chains agree not to open within a mile of each other.',
      question: 'Is this a per se violation or rule-of-reason case?',
      doctrine:
          'Section 1 condemns unreasonable restraints; horizontal price-fixing and market allocation are often per se illegal.',
      elements: <String>['Agreement', 'Horizontal vs vertical', 'Per se vs rule of reason', 'Market power', 'Injury'],
      writingType: 'Antitrust risk memo',
      caseId: 'noncompete_battle',
    ),
  ];

  static final List<LawLesson> corporate = <LawLesson>[
    t(
      id: 'shareholder_inspection',
      title: 'Books & Records Demands',
      field: 'Corporate Law',
      hook: 'A minority shareholder demands emails about a related-party deal after reading a suspicious press release.',
      question: 'What is a proper purpose, and how far can inspection go?',
      doctrine:
          'Shareholders may inspect books and records for a proper purpose related to their interest as shareholders; scope is limited to necessary documents.',
      elements: <String>['Standing', 'Proper purpose', 'Credible basis', 'Scope', 'Confidentiality'],
      writingType: 'Inspection demand letter',
      caseId: 'insider_trading_probe',
    ),
    t(
      id: 'conflicted_transactions',
      title: 'Conflicted Controller Deals',
      field: 'Corporate Law',
      hook: 'A controlling shareholder sells the company to their own affiliate at a price minority owners call unfair.',
      question: 'What cleansing mechanisms restore business-judgment review?',
      doctrine:
          'Conflicted controller transactions face entire fairness unless approved by an independent special committee and an informed minority vote.',
      elements: <String>['Controller conflict', 'Entire fairness', 'Special committee', 'Minority approval', 'Disclosure'],
      writingType: 'Fairness opinion memo',
      caseId: 'insider_trading_probe',
    ),
    t(
      id: 'corporate_opportunity',
      title: 'Corporate Opportunity Doctrine',
      field: 'Corporate Law',
      hook: 'A CEO personally buys a parcel the company had been negotiating for a new warehouse.',
      question: 'Did the CEO usurp a corporate opportunity?',
      doctrine:
          'Fiduciaries may not take opportunities in the company\'s line of business that the company is financially able to pursue, without disclosure and consent.',
      elements: <String>['Line of business', 'Company interest/expectancy', 'Financial ability', 'Disclosure', 'Consent'],
      writingType: 'Fiduciary demand letter',
      caseId: 'insider_trading_probe',
    ),
    t(
      id: 'dissolution',
      title: 'Judicial Dissolution',
      field: 'Corporate Law',
      hook: '50/50 owners deadlock on hiring and dividends; the business is profitable but paralyzed.',
      question: 'When will a court order dissolution or a buyout?',
      doctrine:
          'Statutes allow dissolution for deadlock, oppression, or waste; courts often prefer buyouts or other equitable remedies over liquidation.',
      elements: <String>['Deadlock', 'Oppression', 'Waste', 'Statutory grounds', 'Alternative remedies'],
      writingType: 'Dissolution petition outline',
      caseId: 'insider_trading_probe',
    ),
  ];

  static final List<LawLesson> employment = <LawLesson>[
    t(
      id: 'retaliation',
      title: 'Retaliation Claims',
      field: 'Employment Law',
      hook: 'An employee reports safety violations; two weeks later they are written up and demoted.',
      question: 'What must the employee prove for retaliation?',
      doctrine:
          'Retaliation claims require protected activity, adverse action, and a causal link; employers may show a legitimate non-retaliatory reason.',
      elements: <String>['Protected activity', 'Adverse action', 'Causation', 'Employer reason', 'Pretext'],
      writingType: 'EEOC charge outline',
      caseId: 'hostile_environment',
    ),
    t(
      id: 'flsa_overtime',
      title: 'Overtime & Exemptions',
      field: 'Employment Law',
      hook: 'A "manager" spends 90% of time ringing a register but is paid salary with no overtime.',
      question: 'Is the employee exempt under the FLSA?',
      doctrine:
          'Overtime exemptions require salary basis and primary duties that meet executive, administrative, or professional tests — titles alone are not enough.',
      elements: <String>['Salary basis', 'Primary duty', 'Exemption test', 'Hours worked', 'Damages/liquidated'],
      writingType: 'Wage claim memo',
      caseId: 'hostile_environment',
    ),
    t(
      id: 'whistleblower',
      title: 'Whistleblower Protections',
      field: 'Employment Law',
      hook: 'A nurse reports billing fraud to a hotline and is later scheduled only for overnight shifts.',
      question: 'Which statutes protect the report, and what remedies exist?',
      doctrine:
          'Whistleblower laws (and some False Claims Act provisions) protect good-faith reports of illegality from adverse employment actions.',
      elements: <String>['Protected report', 'Good faith/reasonable belief', 'Adverse action', 'Causation', 'Remedies'],
      writingType: 'Whistleblower complaint outline',
      caseId: 'hostile_environment',
    ),
    t(
      id: 'arbitration_employment',
      title: 'Workplace Arbitration',
      field: 'Employment Law',
      hook: 'A new hire clicks "I agree" to an arbitration clause buried in an onboarding portal, then later sues for discrimination.',
      question: 'Is the arbitration agreement enforceable?',
      doctrine:
          'Arbitration agreements are generally enforceable if there is assent and fairness; unconscionability and statutory limits can still defeat them.',
      elements: <String>['Assent', 'Consideration', 'Procedural unconscionability', 'Substantive fairness', 'FAA preemption'],
      writingType: 'Motion to compel opposition',
      caseId: 'hostile_environment',
    ),
  ];

  static final List<LawLesson> tax = <LawLesson>[
    t(
      id: 'gross_income',
      title: 'Gross Income Boundaries',
      field: 'Tax Law',
      hook: 'A client receives a \$15,000 employer wellness award, a debt cancellation, and a gift from a parent.',
      question: 'What is included in gross income?',
      doctrine:
          'Gross income includes all accessions to wealth clearly realized unless a specific exclusion applies; gifts and some fringe benefits are excluded.',
      elements: <String>['Accession to wealth', 'Realization', 'Exclusions', 'COD income', 'Fringe benefits'],
      writingType: 'Income inclusion memo',
      caseId: 'home_office_audit',
    ),
    t(
      id: 'like_kind_exchange',
      title: 'Like-Kind Exchanges',
      field: 'Tax Law',
      hook: 'An investor swaps one rental property for another and pockets \$40k cash boot.',
      question: 'How much gain is deferred vs recognized?',
      doctrine:
          'Section 1031 defers gain on qualifying real-property exchanges; boot triggers recognition up to realized gain.',
      elements: <String>['Qualifying property', 'Exchange structure', 'Boot', 'Basis carryover', 'Timing rules'],
      writingType: '1031 planning memo',
      caseId: 'home_office_audit',
    ),
    t(
      id: 'tax_procedure',
      title: 'Tax Court vs Refund Suit',
      field: 'Tax Law',
      hook: 'The IRS issues a notice of deficiency; the taxpayer wants to fight without paying first.',
      question: 'What forum and deadlines apply?',
      doctrine:
          'Tax Court allows prepayment challenges after a deficiency notice; refund suits generally require full payment and a claim for refund.',
      elements: <String>['Deficiency notice', 'Petition deadline', 'Tax Court jurisdiction', 'Refund claim', 'Burden of proof'],
      writingType: 'Forum selection memo',
      caseId: 'home_office_audit',
    ),
    t(
      id: 'charitable_contribution',
      title: 'Charitable Contribution Rules',
      field: 'Tax Law',
      hook: 'A donor claims a \$50,000 deduction for donated art without a qualified appraisal.',
      question: 'What substantiation is required?',
      doctrine:
          'Charitable deductions require qualified organizations, proper valuation, and substantiation that tightens as the amount rises.',
      elements: <String>['Qualified charity', 'Fair market value', 'Appraisal', 'Contemporaneous acknowledgment', 'AGI limits'],
      writingType: 'Deduction risk memo',
      caseId: 'home_office_audit',
    ),
  ];

  static final List<LawLesson> immigration = <LawLesson>[
    t(
      id: 'asylum_basics',
      title: 'Asylum Eligibility',
      field: 'Immigration Law',
      hook: 'A journalist flees after threats for reporting on corruption and seeks asylum at the border.',
      question: 'What must be shown for asylum?',
      doctrine:
          'Asylum requires a well-founded fear of persecution on account of a protected ground, plus credibility and discretionary factors.',
      elements: <String>['Persecution', 'Protected ground', 'Nexus', 'Well-founded fear', 'Bars to asylum'],
      writingType: 'Asylum declaration outline',
      caseId: 'visa_overstay_removal',
    ),
    t(
      id: 'adjustment_status',
      title: 'Adjustment of Status',
      field: 'Immigration Law',
      hook: 'A spouse of a U.S. citizen entered on a visitor visa and now wants a green card without leaving.',
      question: 'When is adjustment available?',
      doctrine:
          'Adjustment of status lets certain applicants become LPRs in the U.S. if inspected/admitted (or parole) and otherwise eligible; unlawful presence can block some paths.',
      elements: <String>['Immigrant category', 'Inspected/admitted', 'Admissibility', 'Visa availability', 'Discretion'],
      writingType: 'AOS eligibility memo',
      caseId: 'visa_overstay_removal',
    ),
    t(
      id: 'detention_bond',
      title: 'Immigration Detention & Bond',
      field: 'Immigration Law',
      hook: 'ICE detains a long-time resident after a misdemeanor; family seeks release pending removal hearings.',
      question: 'Is bond available, and what does the IJ consider?',
      doctrine:
          'Bond hearings ask whether the noncitizen is a flight risk or danger; some categories face mandatory detention limits.',
      elements: <String>['Custody authority', 'Bond eligibility', 'Flight risk', 'Danger', 'Conditions of release'],
      writingType: 'Bond brief',
      caseId: 'visa_overstay_removal',
    ),
    t(
      id: 'cancellation_removal',
      title: 'Cancellation of Removal',
      field: 'Immigration Law',
      hook: 'A non-LPR parent of U.S.-citizen children faces removal after 12 years of continuous presence.',
      question: 'Can cancellation stop removal?',
      doctrine:
          'Non-LPR cancellation requires continuous presence, good moral character, and exceptional and extremely unusual hardship to a qualifying relative.',
      elements: <String>['Continuous presence', 'Good moral character', 'Qualifying relative', 'Hardship standard', 'Discretion'],
      writingType: 'Cancellation brief',
      caseId: 'visa_overstay_removal',
    ),
  ];

  static final List<LawLesson> environmental = <LawLesson>[
    t(
      id: 'clean_water_act',
      title: 'Clean Water Act Permits',
      field: 'Environmental Law',
      hook: 'A developer fills wetlands to build a parking lot without a Section 404 permit.',
      question: 'What liability and defenses arise?',
      doctrine:
          'The CWA regulates discharges of pollutants to waters of the United States; dredge-and-fill often needs a Corps permit.',
      elements: <String>['WOTUS', 'Discharge', 'Point source', 'Permit requirement', 'Citizen suit/penalties'],
      writingType: 'CWA enforcement memo',
      caseId: 'wetlands_fill',
    ),
    t(
      id: 'citizen_suits',
      title: 'Environmental Citizen Suits',
      field: 'Environmental Law',
      hook: 'Neighbors sue a factory for ongoing permit exceedances after giving 60 days\' notice.',
      question: 'When may citizens enforce environmental statutes?',
      doctrine:
          'Many environmental statutes authorize citizen suits after notice, unless the government is diligently prosecuting.',
      elements: <String>['Statutory authorization', 'Notice', 'Ongoing violation', 'Diligent prosecution bar', 'Remedies'],
      writingType: 'Citizen suit complaint outline',
      caseId: 'wetlands_fill',
    ),
    t(
      id: 'esa_consultation',
      title: 'Endangered Species Consultation',
      field: 'Environmental Law',
      hook: 'A highway project may affect critical habitat for a listed bird; agencies disagree on mitigation.',
      question: 'What does Section 7 consultation require?',
      doctrine:
          'Federal agencies must ensure their actions are not likely to jeopardize listed species or adversely modify critical habitat.',
      elements: <String>['Federal action', 'Listed species', 'Biological opinion', 'Jeopardy', 'Reasonable alternatives'],
      writingType: 'ESA comment letter',
      caseId: 'wetlands_fill',
    ),
    t(
      id: 'environmental_justice',
      title: 'Environmental Justice Claims',
      field: 'Environmental Law',
      hook: 'A city sites a waste facility in a low-income neighborhood already hosting three plants.',
      question: 'What legal theories challenge discriminatory siting?',
      doctrine:
          'Challenges may use equal protection, Title VI administrative complaints, and NEPA/EJ analysis requirements in permitting.',
      elements: <String>['Disparate impact', 'Intent standard', 'Title VI', 'NEPA/EJ review', 'Permitting remedies'],
      writingType: 'EJ advocacy memo',
      caseId: 'wetlands_fill',
    ),
  ];

  static final List<LawLesson> ip = <LawLesson>[
    t(
      id: 'copyright_infringement',
      title: 'Copyright Infringement',
      field: 'Intellectual Property',
      hook: 'A YouTuber uses a competitor\'s song as background for a sponsored video without a license.',
      question: 'What must the owner prove, and what defenses apply?',
      doctrine:
          'Infringement requires ownership of a valid copyright and copying of original elements; fair use and licenses are key defenses.',
      elements: <String>['Ownership', 'Copying', 'Substantial similarity', 'Fair use', 'Damages/injunction'],
      writingType: 'Cease-and-desist letter',
      caseId: 'trademark_knockoff',
    ),
    t(
      id: 'trademark_likelihood',
      title: 'Likelihood of Confusion',
      field: 'Intellectual Property',
      hook: 'A startup launches "GlowGrade" tutoring next to the established "GradeGlow" brand.',
      question: 'Is there a likelihood of confusion?',
      doctrine:
          'Trademark infringement turns on likelihood of confusion factors such as similarity, strength, proximity of goods, and actual confusion.',
      elements: <String>['Protectable mark', 'Similarity', 'Related goods', 'Consumer sophistication', 'Actual confusion'],
      writingType: 'Trademark demand letter',
      caseId: 'trademark_knockoff',
    ),
    t(
      id: 'patent_infringement',
      title: 'Patent Infringement Basics',
      field: 'Intellectual Property',
      hook: 'A competitor sells a device that performs every step of a patented method, but one step is done by end users.',
      question: 'Direct, induced, or contributory infringement?',
      doctrine:
          'Direct infringement requires practicing each claim limitation; induced and contributory infringement reach those who encourage or supply components.',
      elements: <String>['Claim construction', 'All-elements rule', 'Literal vs DOE', 'Induced', 'Contributory'],
      writingType: 'Infringement chart memo',
      caseId: 'trademark_knockoff',
    ),
    t(
      id: 'dmca_safe_harbor',
      title: 'DMCA Safe Harbor',
      field: 'Intellectual Property',
      hook: 'A platform hosts user uploads; a rights holder sends a takedown; the uploader files a counter-notice.',
      question: 'What must the platform do to keep safe harbor?',
      doctrine:
          'Section 512 protects qualifying service providers that adopt notice-and-takedown procedures and lack actual or red-flag knowledge of infringement.',
      elements: <String>['Service provider', 'Notice compliance', 'Knowledge', 'Repeat infringer policy', 'Counter-notice'],
      writingType: 'DMCA compliance memo',
      caseId: 'trademark_knockoff',
    ),
  ];

  static final List<LawLesson> cyber = <LawLesson>[
    t(
      id: 'cfaa_access',
      title: 'CFAA Unauthorized Access',
      field: 'Cyber Law',
      hook: 'An ex-employee uses a still-active password to download a customer list after being fired.',
      question: 'Is this unauthorized access under the CFAA?',
      doctrine:
          'The CFAA targets accessing a computer without authorization or exceeding authorized access; circuit approaches differ on password misuse and terms-of-service violations.',
      elements: <String>['Computer', 'Access', 'Without/exceeding authorization', 'Damage/loss', 'Civil vs criminal'],
      writingType: 'CFAA complaint outline',
      caseId: 'cfaa_ex_employee',
    ),
    t(
      id: 'data_breach_notice',
      title: 'Breach Notification Duties',
      field: 'Cyber Law',
      hook: 'A clinic discovers ransomware encrypted patient files; attackers may have copied records.',
      question: 'Who must be notified, and how soon?',
      doctrine:
          'State breach laws and HIPAA require notice to individuals and regulators when personal data is compromised under defined risk thresholds.',
      elements: <String>['Personal information', 'Breach definition', 'Risk assessment', 'Notice timing', 'Regulator notice'],
      writingType: 'Breach response checklist',
      caseId: 'cfaa_ex_employee',
    ),
    t(
      id: 'electronic_surveillance',
      title: 'Wiretap & Stored Communications',
      field: 'Cyber Law',
      hook: 'A manager installs keylogging software on company laptops to monitor suspected leaks.',
      question: 'Which federal privacy statutes are implicated?',
      doctrine:
          'The Wiretap Act, Stored Communications Act, and related statutes limit interception and access to electronic communications, with workplace consent exceptions.',
      elements: <String>['Interception', 'Stored communications', 'Consent', 'Provider exception', 'Civil remedies'],
      writingType: 'Surveillance risk memo',
      caseId: 'cfaa_ex_employee',
    ),
    t(
      id: 'crypto_regulation',
      title: 'Crypto Asset Regulation',
      field: 'Cyber Law',
      hook: 'A startup sells tokenized "memberships" that buyers hope to flip for profit.',
      question: 'Are the tokens securities?',
      doctrine:
          'Howey tests investment contracts; many crypto offerings are securities if buyers expect profits from others\' efforts.',
      elements: <String>['Investment of money', 'Common enterprise', 'Expectation of profits', 'Efforts of others', 'Registration/exemption'],
      writingType: 'Howey analysis memo',
      caseId: 'cfaa_ex_employee',
    ),
  ];

  static final List<LawLesson> international = <LawLesson>[
    t(
      id: 'treaty_interpretation',
      title: 'Treaty Interpretation',
      field: 'International Law',
      hook: 'Two states dispute whether a trade treaty\'s "essential security" clause covers a new export ban.',
      question: 'How should the clause be interpreted?',
      doctrine:
          'VCLT rules emphasize ordinary meaning in context, object and purpose, and subsequent practice; some clauses receive special deference.',
      elements: <String>['Ordinary meaning', 'Context', 'Object and purpose', 'Subsequent practice', 'Travaux'],
      writingType: 'Treaty interpretation brief',
      caseId: 'embassy_immunity',
    ),
    t(
      id: 'sovereign_immunity',
      title: 'Foreign Sovereign Immunity',
      field: 'International Law',
      hook: 'A contractor sues a foreign ministry over an unpaid commercial supply contract in U.S. court.',
      question: 'Does FSIA block the suit?',
      doctrine:
          'Foreign states are generally immune in U.S. courts unless an FSIA exception applies, such as commercial activity.',
      elements: <String>['Foreign state', 'Immunity baseline', 'Commercial activity', 'Waiver', 'Execution limits'],
      writingType: 'FSIA motion brief',
      caseId: 'embassy_immunity',
    ),
    t(
      id: 'extradition',
      title: 'Extradition Basics',
      field: 'International Law',
      hook: 'A country seeks extradition of a dual national for fraud; the defense claims political offense.',
      question: 'What limits can block extradition?',
      doctrine:
          'Extradition treaties require dual criminality and often exclude political offenses; specialty and human-rights concerns may also apply.',
      elements: <String>['Treaty basis', 'Dual criminality', 'Political offense', 'Specialty', 'Human rights bars'],
      writingType: 'Extradition opposition',
      caseId: 'embassy_immunity',
    ),
    t(
      id: 'diplomatic_immunity',
      title: 'Diplomatic Privileges',
      field: 'International Law',
      hook: 'A diplomat causes a serious car crash; the host state wants to prosecute.',
      question: 'What immunities apply, and what can the host state do?',
      doctrine:
          'Diplomatic agents enjoy broad criminal immunity; the receiving state may declare persona non grata and seek waiver from the sending state.',
      elements: <String>['Diplomatic status', 'Criminal immunity', 'Civil exceptions', 'Waiver', 'Persona non grata'],
      writingType: 'Immunity advisory',
      caseId: 'embassy_immunity',
    ),
  ];

  static final List<LawLesson> humanRights = <LawLesson>[
    t(
      id: 'fair_trial_rights',
      title: 'Fair Trial Guarantees',
      field: 'Human Rights',
      hook: 'A dissident is tried in secret with no counsel of choice and a confession obtained after prolonged interrogation.',
      question: 'Which fair-trial rights were violated?',
      doctrine:
          'Fair-trial guarantees include public hearing, counsel, presumption of innocence, and freedom from compelled self-incrimination.',
      elements: <String>['Independent tribunal', 'Public hearing', 'Counsel', 'Presumption of innocence', 'Exclusion of coerced evidence'],
      writingType: 'Fair-trial petition',
      caseId: 'press_crackdown',
    ),
    t(
      id: 'privacy_surveillance',
      title: 'Privacy & Mass Surveillance',
      field: 'Human Rights',
      hook: 'A government mandates spyware on all phones sold domestically, citing counterterrorism.',
      question: 'How is the interference assessed for necessity and proportionality?',
      doctrine:
          'Interference with privacy must be lawful, pursue a legitimate aim, and be necessary and proportionate in a democratic society.',
      elements: <String>['Interference', 'Lawfulness', 'Legitimate aim', 'Necessity', 'Proportionality'],
      writingType: 'Privacy rights brief',
      caseId: 'press_crackdown',
    ),
    t(
      id: 'assembly_rights',
      title: 'Freedom of Assembly',
      field: 'Human Rights',
      hook: 'Police disperse a peaceful vigil with water cannons after organizers fail to get a same-day permit.',
      question: 'Were assembly rights unjustifiably restricted?',
      doctrine:
          'Peaceful assembly may be regulated but not banned for lack of perfect formalities when restrictions are unnecessary or disproportionate.',
      elements: <String>['Peaceful assembly', 'Prior restraint', 'Notification vs authorization', 'Necessity', 'Use of force'],
      writingType: 'Assembly rights complaint',
      caseId: 'protest_permit_denial',
    ),
    t(
      id: 'economic_social_rights',
      title: 'Economic & Social Rights',
      field: 'Human Rights',
      hook: 'A city demolishes informal housing without resettlement options during an epidemic.',
      question: 'What duties of progressive realization and non-retrogression apply?',
      doctrine:
          'Economic and social rights require progressive realization using maximum available resources and prohibit unjustified retrogressive measures.',
      elements: <String>['Minimum core', 'Progressive realization', 'Non-discrimination', 'Participation', 'Remedies'],
      writingType: 'ESCR shadow report excerpt',
      caseId: 'press_crackdown',
    ),
  ];

  static final List<LawLesson> healthcare = <LawLesson>[
    t(
      id: 'informed_consent',
      title: 'Informed Consent',
      field: 'Healthcare Law',
      hook: 'A surgeon performs an additional procedure discovered mid-operation without prior discussion of that risk.',
      question: 'Was consent valid?',
      doctrine:
          'Informed consent requires disclosure of material risks and alternatives; emergency exceptions and scope-of-consent disputes are common.',
      elements: <String>['Material risk', 'Disclosure', 'Causation', 'Emergency exception', 'Battery vs negligence'],
      writingType: 'Consent litigation memo',
      caseId: 'er_emtala_turnaway',
    ),
    t(
      id: 'emtala_deep',
      title: 'EMTALA Screening & Stabilization',
      field: 'Healthcare Law',
      hook: 'An ER triage nurse sends a patient with chest pain home after a cursory check because the patient is uninsured.',
      question: 'What EMTALA duties were breached?',
      doctrine:
          'EMTALA requires appropriate medical screening and stabilizing treatment before transfer for emergency medical conditions, regardless of ability to pay.',
      elements: <String>['Comes to ED', 'MSE', 'EMC', 'Stabilization', 'Appropriate transfer'],
      writingType: 'EMTALA complaint outline',
      caseId: 'er_emtala_turnaway',
    ),
    t(
      id: 'false_claims_health',
      title: 'Healthcare False Claims',
      field: 'Healthcare Law',
      hook: 'A clinic bills Medicare for visits that were never provided and upcodes routine checks.',
      question: 'What FCA elements and knowledge standards apply?',
      doctrine:
          'The False Claims Act reaches knowingly false claims for payment; knowledge includes deliberate ignorance and reckless disregard.',
      elements: <String>['False claim', 'Knowledge', 'Materiality', 'Presentment', 'Damages/penalties'],
      writingType: 'FCA risk memo',
      caseId: 'er_emtala_turnaway',
    ),
    t(
      id: 'telehealth_licensing',
      title: 'Telehealth & Licensing',
      field: 'Healthcare Law',
      hook: 'A doctor in State A treats a patient in State B by video without a State B license.',
      question: 'Which licensing and standard-of-care rules apply?',
      doctrine:
          'Practice of medicine is generally where the patient is located; telehealth waivers and compact licenses may authorize cross-border care.',
      elements: <String>['Locus of care', 'License requirement', 'Standard of care', 'Prescribing limits', 'Malpractice venue'],
      writingType: 'Telehealth compliance memo',
      caseId: 'er_emtala_turnaway',
    ),
  ];

  static final List<LawLesson> realEstate = <LawLesson>[
    t(
      id: 'purchase_agreements',
      title: 'Purchase Agreement Contingencies',
      field: 'Real Estate Law',
      hook: 'A buyer waives inspection, then finds major foundation cracks and wants out.',
      question: 'Which contingencies still protect the buyer?',
      doctrine:
          'Real estate contracts allocate risk through inspection, financing, and title contingencies; waiver and "as-is" clauses shift outcomes.',
      elements: <String>['Contingency language', 'Waiver', 'Material defect', 'Notice deadlines', 'Earnest money'],
      writingType: 'Termination advice letter',
      caseId: 'foreclosure_defense',
    ),
    t(
      id: 'easement_disputes',
      title: 'Access Easement Disputes',
      field: 'Real Estate Law',
      hook: 'A landlocked lot claims an easement across a neighbor\'s driveway that was used for 20 years.',
      question: 'Express, implied, or prescription?',
      doctrine:
          'Easements may arise by grant, implication, necessity, or prescription; scope and overburdening often drive disputes.',
      elements: <String>['Creation theory', 'Scope', 'Overburden', 'Abandonment', 'Relocation'],
      writingType: 'Easement quiet-title memo',
      caseId: 'foreclosure_defense',
    ),
    t(
      id: 'hoa_enforcement',
      title: 'HOA Covenant Enforcement',
      field: 'Real Estate Law',
      hook: 'An HOA fines a homeowner for a solar installation that violates aesthetic guidelines.',
      question: 'Are the covenants and fines enforceable?',
      doctrine:
          'Recorded covenants run with the land if they touch and concern; enforcement must follow governing documents and may face reasonableness and statutory limits.',
      elements: <String>['Covenant validity', 'Notice', 'Procedure', 'Reasonableness', 'Statutory overrides'],
      writingType: 'HOA dispute letter',
      caseId: 'foreclosure_defense',
    ),
    t(
      id: 'broker_disclosure',
      title: 'Broker Disclosure Duties',
      field: 'Real Estate Law',
      hook: 'A listing agent knows about a prior flood but markets the home as "never flooded."',
      question: 'What liability does the broker face?',
      doctrine:
          'Brokers owe disclosure duties regarding material latent defects known to them; misrepresentation and statutory disclosure forms often apply.',
      elements: <String>['Agency relationship', 'Material fact', 'Knowledge', 'Disclosure form', 'Damages'],
      writingType: 'Broker liability memo',
      caseId: 'foreclosure_defense',
    ),
  ];

  static final List<LawLesson> bankruptcy = <LawLesson>[
    t(
      id: 'automatic_stay_topic',
      title: 'Automatic Stay Scope',
      field: 'Bankruptcy',
      hook: 'After a Chapter 13 filing, a creditor repossesses a car and continues calling the debtor.',
      question: 'What acts violate the stay, and what remedies follow?',
      doctrine:
          'The automatic stay halts most collection acts against the debtor and estate property; willful violations can yield damages and sanctions.',
      elements: <String>['Stay trigger', 'Covered acts', 'Property of estate', 'Willfulness', 'Sanctions'],
      writingType: 'Stay violation motion',
      caseId: 'stay_violation',
    ),
    t(
      id: 'proofs_of_claim',
      title: 'Claims Allowance',
      field: 'Bankruptcy',
      hook: 'A creditor files a late proof of claim; the trustee objects that documentation is incomplete.',
      question: 'When is a claim allowed or disallowed?',
      doctrine:
          'Filed claims are deemed allowed unless objected to; courts examine validity, amount, and priority under the Code.',
      elements: <String>['Proof of claim', 'Objection', 'Prima facie validity', 'Priority', 'Late claims'],
      writingType: 'Claim objection',
      caseId: 'preference_clawback',
    ),
    t(
      id: 'chapter11_plan',
      title: 'Chapter 11 Plan Confirmation',
      field: 'Bankruptcy',
      hook: 'A debtor proposes a plan that pays unsecured creditors 10 cents while equity keeps ownership.',
      question: 'Can the plan be confirmed over creditor objections?',
      doctrine:
          'Confirmation requires best interests, feasibility, and either accepting impaired classes or cramdown compliance including absolute priority.',
      elements: <String>['Impaired classes', 'Best interests', 'Feasibility', 'Cramdown', 'Absolute priority'],
      writingType: 'Plan objection',
      caseId: 'preference_clawback',
    ),
    t(
      id: 'nondischargeable_debts',
      title: 'Nondischargeable Debts',
      field: 'Bankruptcy',
      hook: 'A creditor claims a debt was incurred by fraud and should survive discharge.',
      question: 'What must the creditor prove under §523?',
      doctrine:
          'Certain debts — fraud, willful injury, some taxes, domestic support — are excepted from discharge if statutory elements are met.',
      elements: <String>['Exception category', 'Fraud elements', 'Timing', 'Burden of proof', 'Collateral estoppel'],
      writingType: 'Dischargeability complaint outline',
      caseId: 'preference_clawback',
    ),
  ];

  static final List<LawLesson> insurance = <LawLesson>[
    t(
      id: 'duty_to_defend',
      title: 'Duty to Defend',
      field: 'Insurance Law',
      hook: 'A complaint alleges negligence and intentional assault; the insurer refuses to defend the whole suit.',
      question: 'When must the insurer defend?',
      doctrine:
          'The duty to defend is broader than the duty to indemnify and is generally triggered if any allegation potentially falls within coverage.',
      elements: <String>['Policy grant', 'Complaint allegations', 'Potential coverage', 'Reservation of rights', 'Extrinsic evidence limits'],
      writingType: 'Coverage demand letter',
      caseId: 'bad_faith_delay',
    ),
    t(
      id: 'exclusions',
      title: 'Policy Exclusions',
      field: 'Insurance Law',
      hook: 'A homeowner policy excludes "flood," but the loss was caused by a burst pipe that then flooded the basement.',
      question: 'Which cause controls coverage?',
      doctrine:
          'Exclusions are construed narrowly; efficient proximate cause and anti-concurrent causation clauses can decide multi-cause losses.',
      elements: <String>['Insuring agreement', 'Exclusion text', 'Ambiguity', 'Efficient proximate cause', 'ACC clauses'],
      writingType: 'Coverage opinion',
      caseId: 'bad_faith_delay',
    ),
    t(
      id: 'subrogation',
      title: 'Subrogation Rights',
      field: 'Insurance Law',
      hook: 'After paying a fire claim, the insurer sues a negligent contractor; the insured already signed a release with the contractor.',
      question: 'Did the release kill subrogation?',
      doctrine:
          'Subrogation lets insurers step into the insured\'s rights against third parties; releases and made-whole doctrines can limit recovery.',
      elements: <String>['Payment', 'Rights of insured', 'Release effect', 'Made whole', 'Waiver of subrogation'],
      writingType: 'Subrogation memo',
      caseId: 'bad_faith_delay',
    ),
    t(
      id: 'claims_handling',
      title: 'Claims Handling Standards',
      field: 'Insurance Law',
      hook: 'An insurer delays a clear liability claim for months while demanding repetitive documents.',
      question: 'When does delay become bad faith?',
      doctrine:
          'Insurers must investigate and settle reasonably; unreasonable delay or lowballing can support bad-faith and statutory unfair-claims claims.',
      elements: <String>['Duty of good faith', 'Reasonable investigation', 'Timely decision', 'Settlement opportunity', 'Damages'],
      writingType: 'Bad-faith demand',
      caseId: 'bad_faith_delay',
    ),
  ];

  static final List<LawLesson> entertainment = <LawLesson>[
    t(
      id: 'idea_submission',
      title: 'Idea Submission Claims',
      field: 'Entertainment Law',
      hook: 'A writer pitches a series; a year later a nearly identical show airs without credit or payment.',
      question: 'Contract, copyright, or idea-misappropriation?',
      doctrine:
          'Unsolicited ideas are often unprotected unless a contract (express or implied-in-fact) or copyrightable expression is copied.',
      elements: <String>['Novelty', 'Confidential relationship', 'Implied contract', 'Substantial similarity', 'Access'],
      writingType: 'Idea claim demand letter',
      caseId: 'clearance_failure',
    ),
    t(
      id: 'defamation_docudrama',
      title: 'Docudrama & Defamation',
      field: 'Entertainment Law',
      hook: 'A biopic portrays a living person as a criminal based on disputed sources.',
      question: 'What liability risks remain after disclaimers?',
      doctrine:
          'Docudramas can trigger defamation and false-light claims; public-figure plaintiffs must prove actual malice for reputational torts.',
      elements: <String>['Falsity', 'Of and concerning', 'Fact vs fiction', 'Actual malice', 'Disclaimers'],
      writingType: 'Clearance risk memo',
      caseId: 'clearance_failure',
    ),
    t(
      id: 'music_licensing',
      title: 'Music Licensing Paths',
      field: 'Entertainment Law',
      hook: 'A podcast uses a hit song under a claimed "fair use" for a 90-second intro every episode.',
      question: 'Sync, master, or fair use — what is needed?',
      doctrine:
          'Using music typically requires composition and master licenses; fair use is narrow and risky for recurring commercial intros.',
      elements: <String>['Composition rights', 'Master rights', 'Sync license', 'Fair use factors', 'PRO issues'],
      writingType: 'Licensing checklist',
      caseId: 'clearance_failure',
    ),
    t(
      id: 'talent_agreements',
      title: 'Talent Agreement Disputes',
      field: 'Entertainment Law',
      hook: 'An actor walks off a series after the studio adds a spin-off option never discussed in the deal memo.',
      question: 'Is the option enforceable?',
      doctrine:
          'Entertainment deals often combine deal memos and long-form contracts; ambiguity, course of dealing, and guild rules shape enforcement.',
      elements: <String>['Deal memo vs long form', 'Option scope', 'Morals/credit', 'Guild minimums', 'Remedies'],
      writingType: 'Talent dispute memo',
      caseId: 'clearance_failure',
    ),
  ];

  static final List<LawLesson> sports = <LawLesson>[
    t(
      id: 'athlete_injury',
      title: 'Athlete Injury Liability',
      field: 'Sports Law',
      hook: 'A college athlete suffers a concussion after coaches ignore return-to-play protocols.',
      question: 'What duties do schools and leagues owe?',
      doctrine:
          'Sports injury cases turn on assumed risk, heightened duties for medical protocols, and sometimes statutory immunities.',
      elements: <String>['Duty of care', 'Assumed risk', 'Protocol breach', 'Causation', 'Immunity'],
      writingType: 'Injury claim memo',
      caseId: 'nil_eligibility',
    ),
    t(
      id: 'draft_eligibility',
      title: 'Draft & Eligibility Rules',
      field: 'Sports Law',
      hook: 'A league bars a player for a social-media post under a vague "conduct detrimental" rule.',
      question: 'How far can private associations regulate athletes?',
      doctrine:
          'Courts often defer to league rules but review for bad faith, antitrust concerns, and contractual due process in CBA frameworks.',
      elements: <String>['Association rules', 'CBA process', 'Notice', 'Arbitrary enforcement', 'Remedies'],
      writingType: 'Eligibility appeal brief',
      caseId: 'nil_eligibility',
    ),
    t(
      id: 'ticket_scalping',
      title: 'Ticketing & Fan Rights',
      field: 'Sports Law',
      hook: 'A team voids season tickets after a fan resells two games above face value online.',
      question: 'Are the license terms enforceable?',
      doctrine:
          'Tickets are often licenses; teams may impose transfer restrictions subject to consumer-protection and antitrust limits.',
      elements: <String>['License vs property', 'Transfer ban', 'Notice', 'Consumer statutes', 'Remedies'],
      writingType: 'Fan rights letter',
      caseId: 'nil_eligibility',
    ),
    t(
      id: 'title_ix_sports',
      title: 'Title IX Athletics',
      field: 'Sports Law',
      hook: 'A university cuts a women\'s team while expanding men\'s facilities funded by booster donations.',
      question: 'Does Title IX require reinstatement?',
      doctrine:
          'Title IX athletics compliance looks at participation opportunities, scholarship equity, and treatment of athletes.',
      elements: <String>['Effective accommodation', 'Substantial proportionality', 'History of expansion', 'Interests/abilities', 'Equal treatment'],
      writingType: 'Title IX complaint outline',
      caseId: 'nil_eligibility',
    ),
  ];

  static final List<LawLesson> maritime = <LawLesson>[
    t(
      id: 'maritime_jurisdiction',
      title: 'Admiralty Jurisdiction',
      field: 'Maritime Law',
      hook: 'A tourist is injured on a floating casino permanently moored to a dock.',
      question: 'Is this within admiralty jurisdiction?',
      doctrine:
          'Admiralty tort jurisdiction generally requires a vessel on navigable waters plus a maritime nexus; status of the structure matters.',
      elements: <String>['Navigable waters', 'Vessel status', 'Maritime nexus', 'Location', 'Savings to suitors'],
      writingType: 'Jurisdiction memo',
      caseId: 'cargo_damage',
    ),
    t(
      id: 'maintenance_cure',
      title: 'Maintenance & Cure',
      field: 'Maritime Law',
      hook: 'A seafarer injures a back on board; the owner stops payments after disputing the medical plan.',
      question: 'What is owed, and when can payments stop?',
      doctrine:
          'Shipowners must provide maintenance and cure until maximum medical improvement for injuries while in service of the ship.',
      elements: <String>['Seaman status', 'In service of ship', 'Maintenance', 'Cure', 'Arbitrary failure damages'],
      writingType: 'Maintenance demand letter',
      caseId: 'cargo_damage',
    ),
    t(
      id: 'collision_liability',
      title: 'Collision Liability',
      field: 'Maritime Law',
      hook: 'Two vessels collide in fog; each claims the other violated COLREGS lookout rules.',
      question: 'How is fault allocated?',
      doctrine:
          'Collision liability follows comparative fault informed by navigation rules; both vessels may share blame.',
      elements: <String>['COLREGS duties', 'Lookout', 'Speed in fog', 'Comparative fault', 'Damages'],
      writingType: 'Collision liability brief',
      caseId: 'cargo_damage',
    ),
    t(
      id: 'marine_insurance',
      title: 'Marine Insurance Basics',
      field: 'Maritime Law',
      hook: 'Cargo is damaged after a delayed voyage; the policy has a sue-and-labor clause and a warranty of seaworthiness.',
      question: 'What coverage defenses are available?',
      doctrine:
          'Marine insurance is shaped by warranties, utmost good faith traditions, and specialized clauses allocating voyage risks.',
      elements: <String>['Insurable interest', 'Warranty', 'Sue and labor', 'Perils covered', 'Disclosure'],
      writingType: 'Marine coverage memo',
      caseId: 'cargo_damage',
    ),
  ];

  static final List<LawLesson> advocacy = <LawLesson>[
    t(
      id: 'voir_dire_skills',
      title: 'Jury Selection Strategy',
      field: 'Trial Advocacy',
      hook: 'You have limited challenges in a case where social media outrage already shaped local opinion.',
      question: 'How do you uncover bias without alienating the panel?',
      doctrine:
          'Voir dire seeks cause challenges and informed peremptories while educating jurors within ethical limits.',
      elements: <String>['Cause challenges', 'Peremptories', 'Batson', 'Open questions', 'Theme planting limits'],
      writingType: 'Voir dire outline',
      caseId: 'campus_discipline',
    ),
    t(
      id: 'theme_theory',
      title: 'Case Theory & Theme',
      field: 'Trial Advocacy',
      hook: 'Your facts support both a strong negligence story and a weaker intentional-tort theory.',
      question: 'How do you choose and stick to one theory?',
      doctrine:
          'A coherent theory of the case and a memorable theme guide openings, examinations, and closings; inconsistency destroys credibility.',
      elements: <String>['Theory selection', 'Theme', 'Fact selection', 'Burden framing', 'Consistency'],
      writingType: 'Case theory memo',
      caseId: 'campus_discipline',
    ),
    t(
      id: 'expert_exam',
      title: 'Expert Witness Examination',
      field: 'Trial Advocacy',
      hook: 'Your expert is brilliant on paper but freezes under jargon-heavy cross.',
      question: 'How do you structure direct and prepare for cross?',
      doctrine:
          'Expert directs teach through plain language and visuals; cross attacks qualifications, assumptions, and bias without inviting speeches.',
      elements: <String>['Qualifications', 'Teaching direct', 'Assumptions', 'Impeachment', 'Redirect'],
      writingType: 'Expert exam outline',
      caseId: 'campus_discipline',
    ),
    t(
      id: 'appellate_advocacy',
      title: 'Appellate Advocacy Basics',
      field: 'Trial Advocacy',
      hook: 'You lost at trial on a close evidence ruling and want to reverse on appeal.',
      question: 'How do you frame the issue and standard of review?',
      doctrine:
          'Appellate advocacy turns on preserved error, precise issue statements, and matching argument to the standard of review.',
      elements: <String>['Preservation', 'Issue framing', 'Standard of review', 'Record cites', 'Remedy request'],
      writingType: 'Appellate issue statement',
      caseId: 'campus_discipline',
    ),
  ];
}
