/// Landmark published court decisions for the Real Case Study Center.
///
/// Court decisions are public; the summaries below are original teaching
/// summaries. They are educational, not legal advice. Fictional practice cases
/// live elsewhere (law program / career worlds) and are labelled as fictional.
library;

class CaseQuestion {
  const CaseQuestion(this.prompt, this.options, this.answer, this.why);
  final String prompt;
  final List<String> options;

  /// Index into [options].
  final int answer;
  final String why;
}

class RealCase {
  const RealCase({
    required this.id,
    required this.name,
    required this.citation,
    required this.court,
    required this.year,
    required this.jurisdiction,
    required this.area,
    required this.parties,
    required this.facts,
    required this.issue,
    required this.law,
    required this.forSide,
    required this.againstSide,
    required this.decision,
    required this.reasoning,
    required this.significance,
    required this.predictOptions,
    required this.predictAnswer,
    required this.questions,
  });

  final String id;
  final String name;
  final String citation;
  final String court;
  final int year;

  /// 'United States' or 'England & Scotland (UK)'.
  final String jurisdiction;
  final String area;
  final String parties;
  final List<String> facts;
  final String issue;
  final String law;
  final String forSide;
  final String againstSide;
  final String decision;
  final String reasoning;
  final String significance;

  /// "What do you think the court decided?" before the holding is revealed.
  final List<String> predictOptions;
  final int predictAnswer;
  final List<CaseQuestion> questions;
}

abstract final class RealCases {
  static const List<RealCase> all = <RealCase>[
    RealCase(
      id: 'marbury',
      name: 'Marbury v. Madison',
      citation: '5 U.S. 137',
      court: 'Supreme Court of the United States',
      year: 1803,
      jurisdiction: 'United States',
      area: 'Constitutional law · judicial review',
      parties: 'William Marbury (appointed justice of the peace) v. James Madison (Secretary of State).',
      facts: <String>[
        'In his last days in office, President John Adams appointed William Marbury as a justice of the peace.',
        'The signed commission was not delivered before Thomas Jefferson took office, and the new Secretary of State, James Madison, withheld it.',
        'Marbury asked the Supreme Court directly for a writ of mandamus ordering Madison to deliver it, relying on Section 13 of the Judiciary Act of 1789.',
      ],
      issue: 'Can the Supreme Court issue the writ, and can a court refuse to apply an Act of Congress that conflicts with the Constitution?',
      law: 'Article III of the Constitution (the Court\'s original jurisdiction) and Section 13 of the Judiciary Act of 1789.',
      forSide: 'Marbury: the appointment was complete when the commission was signed and sealed, so he had a legal right to it and the law must give a remedy.',
      againstSide: 'Madison (the administration): the Court cannot order the executive branch, and Congress cannot expand the Court\'s original jurisdiction by statute.',
      decision: 'Marbury had a right to his commission, but the Court could not issue the writ: Section 13 tried to enlarge the Court\'s original jurisdiction beyond Article III, so that part of the Act was void.',
      reasoning: 'Chief Justice John Marshall reasoned that the Constitution is the supreme law; a statute that conflicts with it cannot be applied, and "it is emphatically the province and duty of the judicial department to say what the law is."',
      significance: 'Established judicial review: courts can strike down laws that violate the Constitution.',
      predictOptions: <String>[
        'Marbury wins and gets his commission delivered',
        'Marbury had a right, but the Court cannot order delivery because the law giving it that power is unconstitutional',
        'Marbury never had any right to the commission',
      ],
      predictAnswer: 1,
      questions: <CaseQuestion>[
        CaseQuestion('What principle does this case establish?', <String>['Judicial review', 'Separate but equal', 'Right to counsel', 'The neighbour principle'], 0,
            'Courts may refuse to apply laws that conflict with the Constitution.'),
        CaseQuestion('Why could the Court not issue the writ?', <String>['Marbury applied too late', 'Section 13 unconstitutionally expanded the Court\'s original jurisdiction', 'Madison was immune', 'There was no commission'], 1,
            'Congress cannot add to the original jurisdiction set by Article III.'),
      ],
    ),
    RealCase(
      id: 'brown',
      name: 'Brown v. Board of Education of Topeka',
      citation: '347 U.S. 483',
      court: 'Supreme Court of the United States',
      year: 1954,
      jurisdiction: 'United States',
      area: 'Constitutional law · equal protection',
      parties: 'Black schoolchildren and their parents (including Oliver Brown) v. local school boards.',
      facts: <String>[
        'State and local laws required or allowed separate public schools for Black and white children.',
        'Black children, including Linda Brown in Topeka, Kansas, were refused admission to schools attended by white children.',
        'Cases from several states were heard together. Lower courts had relied on the "separate but equal" doctrine of Plessy v. Ferguson (1896).',
      ],
      issue: 'Does racial segregation in public schools violate the Equal Protection Clause of the Fourteenth Amendment, even if facilities are said to be equal?',
      law: 'Fourteenth Amendment, Equal Protection Clause; Plessy v. Ferguson (1896).',
      forSide: 'The children: segregation itself marks Black children as inferior and denies them equal educational opportunity.',
      againstSide: 'The school boards: Plessy allows separate facilities if they are equal, and education is a matter for the states.',
      decision: 'Unanimous (9–0): segregation of children in public schools solely on the basis of race violates equal protection.',
      reasoning: 'Chief Justice Earl Warren wrote that education is central to citizenship and opportunity, and that separating children by race generates a feeling of inferiority; "separate educational facilities are inherently unequal."',
      significance: 'Rejected "separate but equal" in public education and became a foundation of the civil rights movement.',
      predictOptions: <String>[
        'Segregation is allowed if facilities are equal',
        'Segregated public schools are inherently unequal and unconstitutional',
        'Each state may decide for itself',
      ],
      predictAnswer: 1,
      questions: <CaseQuestion>[
        CaseQuestion('Which earlier doctrine did Brown reject for public education?', <String>['Judicial review', 'Separate but equal', 'Clear and present danger', 'Freedom of contract'], 1,
            'Plessy v. Ferguson\'s "separate but equal" was rejected for schools.'),
        CaseQuestion('Which constitutional provision was decisive?', <String>['First Amendment', 'Fifth Amendment', 'Fourteenth Amendment Equal Protection Clause', 'Article III'], 2,
            'The Equal Protection Clause applies to state action such as public schools.'),
      ],
    ),
    RealCase(
      id: 'gideon',
      name: 'Gideon v. Wainwright',
      citation: '372 U.S. 335',
      court: 'Supreme Court of the United States',
      year: 1963,
      jurisdiction: 'United States',
      area: 'Criminal procedure · right to counsel',
      parties: 'Clarence Earl Gideon v. Louie Wainwright (Florida corrections director).',
      facts: <String>[
        'Gideon was charged in Florida with breaking and entering with intent to commit a crime, a felony.',
        'He could not afford a lawyer and asked the court to appoint one; Florida law only provided appointed counsel in capital cases, so he was refused.',
        'He defended himself, was convicted, and sent a handwritten petition to the Supreme Court from prison.',
      ],
      issue: 'Must states provide a lawyer to defendants in felony cases who cannot afford one?',
      law: 'Sixth Amendment right to counsel, applied to the states through the Fourteenth Amendment; Betts v. Brady (1942).',
      forSide: 'Gideon: a fair trial is impossible for an ordinary person without a lawyer against a trained prosecutor.',
      againstSide: 'Florida: under Betts v. Brady states need only appoint counsel in special circumstances, and Gideon had none.',
      decision: 'Unanimous: the right to counsel is fundamental and states must appoint lawyers for felony defendants who cannot afford one. Betts v. Brady was overruled.',
      reasoning: 'Justice Hugo Black wrote that lawyers in criminal courts are "necessities, not luxuries," shown by the fact that governments hire prosecutors and wealthy defendants hire lawyers.',
      significance: 'Created the modern public-defender system. Gideon was retried with a lawyer and acquitted.',
      predictOptions: <String>[
        'States must provide lawyers to poor felony defendants',
        'Only death-penalty defendants get appointed lawyers',
        'Defendants may never represent themselves',
      ],
      predictAnswer: 0,
      questions: <CaseQuestion>[
        CaseQuestion('Which earlier case did Gideon overrule?', <String>['Plessy v. Ferguson', 'Betts v. Brady', 'Marbury v. Madison', 'Mapp v. Ohio'], 1, 'Betts v. Brady had allowed states to deny counsel in most cases.'),
        CaseQuestion('What happened at Gideon\'s retrial?', <String>['He was convicted again', 'He was acquitted', 'The case was dropped before trial', 'He pleaded guilty'], 1, 'With a lawyer, Gideon was found not guilty.'),
      ],
    ),
    RealCase(
      id: 'miranda',
      name: 'Miranda v. Arizona',
      citation: '384 U.S. 436',
      court: 'Supreme Court of the United States',
      year: 1966,
      jurisdiction: 'United States',
      area: 'Criminal procedure · self-incrimination',
      parties: 'Ernesto Miranda v. State of Arizona (decided with three similar cases).',
      facts: <String>[
        'Miranda was arrested and questioned by police for about two hours.',
        'He was not told of his right to remain silent or to have a lawyer present, and he signed a written confession.',
        'The confession was used at trial and he was convicted.',
      ],
      issue: 'Can statements from custodial police interrogation be used at trial if the suspect was not told about their rights?',
      law: 'Fifth Amendment privilege against self-incrimination; Sixth Amendment right to counsel.',
      forSide: 'Miranda: custodial interrogation is inherently pressuring; without warnings, a confession is not truly voluntary.',
      againstSide: 'Arizona: the confession was voluntary and signed, and requiring warnings would hamper police work.',
      decision: '5–4: the prosecution may not use statements from custodial interrogation unless the suspect was warned of their rights and waived them.',
      reasoning: 'Chief Justice Earl Warren set out the required warnings: the right to remain silent, that anything said can be used in court, the right to a lawyer, and to an appointed lawyer if they cannot afford one.',
      significance: 'Created the "Miranda warnings" police in the US give before custodial questioning.',
      predictOptions: <String>[
        'Any signed confession is admissible',
        'Confessions are admissible only if the suspect was warned of their rights and waived them',
        'Police may never question suspects',
      ],
      predictAnswer: 1,
      questions: <CaseQuestion>[
        CaseQuestion('When are Miranda warnings required?', <String>['Before any conversation with police', 'Before custodial interrogation', 'Only at trial', 'Only for juveniles'], 1, 'They apply when a person is in custody and being interrogated.'),
        CaseQuestion('What was the vote?', <String>['9–0', '7–2', '5–4', '6–3'], 2, 'A closely divided 5–4 Court.'),
      ],
    ),
    RealCase(
      id: 'tinker',
      name: 'Tinker v. Des Moines Independent Community School District',
      citation: '393 U.S. 503',
      court: 'Supreme Court of the United States',
      year: 1969,
      jurisdiction: 'United States',
      area: 'Constitutional law · free speech in schools',
      parties: 'Students John Tinker, Mary Beth Tinker and Christopher Eckhardt (through their parents) v. the school district.',
      facts: <String>[
        'Students planned to wear black armbands to school to protest the Vietnam War.',
        'The school adopted a policy banning armbands and suspended students who wore them.',
        'The protest was silent and did not disrupt classes.',
      ],
      issue: 'Does banning a silent, non-disruptive armband protest in a public school violate the First Amendment?',
      law: 'First Amendment freedom of speech, applied to states through the Fourteenth Amendment.',
      forSide: 'The students: armbands are symbolic speech, and the school banned them only to avoid controversy.',
      againstSide: 'The school: it must keep order and avoid disruption, and schools may set rules for students.',
      decision: '7–2 for the students: the ban violated their free speech rights.',
      reasoning: 'Justice Abe Fortas wrote that students do not "shed their constitutional rights to freedom of speech or expression at the schoolhouse gate"; schools may restrict speech only if it would substantially disrupt school activities.',
      significance: 'Set the "substantial disruption" test for student speech in public schools.',
      predictOptions: <String>[
        'Schools may ban any political symbol',
        'The ban was unconstitutional because the protest did not substantially disrupt school',
        'Students have no free-speech rights at school',
      ],
      predictAnswer: 1,
      questions: <CaseQuestion>[
        CaseQuestion('What test did the Court use?', <String>['Clear and present danger', 'Substantial disruption', 'Strict scrutiny of all school rules', 'Rational basis'], 1, 'Schools must show the speech would substantially disrupt school activities.'),
      ],
    ),
    RealCase(
      id: 'donoghue',
      name: 'Donoghue v Stevenson',
      citation: '[1932] AC 562; [1932] UKHL 100',
      court: 'House of Lords (UK)',
      year: 1932,
      jurisdiction: 'England & Scotland (UK)',
      area: 'Tort law · negligence',
      parties: 'May Donoghue (consumer) v. David Stevenson (manufacturer of ginger beer).',
      facts: <String>[
        'A friend bought Mrs Donoghue a ginger beer at a café in Paisley, Scotland. The bottle was opaque.',
        'She said that when the rest was poured out, the remains of a decomposed snail appeared, and that she became ill.',
        'She had no contract with the café or the manufacturer, so she sued the manufacturer in negligence.',
      ],
      issue: 'Does a manufacturer owe a duty of care to the final consumer of its product when there is no contract between them?',
      law: 'The common law of negligence (Scots and English law).',
      forSide: 'Donoghue: the manufacturer sealed the bottle so nobody could inspect it, so it must take care toward whoever drinks it.',
      againstSide: 'Stevenson: without a contract there is no duty, and recognising one would open floodgates of claims.',
      decision: '3–2: a manufacturer owes a duty of care to the ultimate consumer where the product reaches them without a reasonable chance of intermediate inspection.',
      reasoning: 'Lord Atkin set out the "neighbour principle": you must take reasonable care to avoid acts or omissions you can reasonably foresee would be likely to injure your neighbour, meaning people so closely and directly affected that you ought to have them in mind.',
      significance: 'The foundation of the modern law of negligence. The case decided a point of law; the facts were never tested at trial.',
      predictOptions: <String>[
        'No contract means no claim',
        'The manufacturer owes the consumer a duty of care',
        'Only the café owner can be liable',
      ],
      predictAnswer: 1,
      questions: <CaseQuestion>[
        CaseQuestion('What principle came from Lord Atkin\'s speech?', <String>['Judicial review', 'The neighbour principle', 'Remoteness of damage', 'Unilateral contract'], 1, 'The neighbour principle defines when a duty of care arises.'),
        CaseQuestion('Why did Donoghue sue in negligence rather than contract?', <String>['She had no contract with the manufacturer', 'Contract claims were banned in Scotland', 'Negligence pays more', 'The café had closed'], 0, 'Her friend bought the drink, so she had no contract.'),
      ],
    ),
    RealCase(
      id: 'carlill',
      name: 'Carlill v Carbolic Smoke Ball Co',
      citation: '[1893] 1 QB 256',
      court: 'Court of Appeal (England)',
      year: 1893,
      jurisdiction: 'England & Scotland (UK)',
      area: 'Contract law · offer and acceptance',
      parties: 'Louisa Carlill v. Carbolic Smoke Ball Company.',
      facts: <String>[
        'The company advertised that it would pay £100 to anyone who caught influenza after using its smoke ball three times a day for two weeks as directed.',
        'The advert said £1,000 had been deposited with a bank to show the company was sincere.',
        'Mrs Carlill used the smoke ball as directed, caught influenza, and claimed the £100. The company refused.',
      ],
      issue: 'Was the advertisement a binding offer that she accepted by using the product, or a mere sales puff?',
      law: 'Common law of contract: offer, acceptance, intention to create legal relations, consideration.',
      forSide: 'Carlill: the advert was a clear promise to anyone who met the conditions, backed by the bank deposit.',
      againstSide: 'The company: it was advertising puff, you cannot make an offer to the whole world, and she never told them she accepted.',
      decision: 'The company was bound to pay: the advert was a unilateral offer to the world, accepted by performing the conditions.',
      reasoning: 'The deposit showed a real intention to be bound. In a unilateral contract, performing the conditions is acceptance, and the offeror can waive notice of acceptance. Using the smoke ball as directed was good consideration.',
      significance: 'The classic case on unilateral contracts and when advertisements can be binding offers.',
      predictOptions: <String>[
        'Adverts are never offers, so she loses',
        'The advert was a binding unilateral offer and she accepted by performing the conditions',
        'She had to sign a contract first',
      ],
      predictAnswer: 1,
      questions: <CaseQuestion>[
        CaseQuestion('What showed the company intended to be bound?', <String>['The £1,000 bank deposit', 'The price of the ball', 'A signed contract', 'Her letter'], 0, 'The deposit showed the promise was serious, not puff.'),
        CaseQuestion('How was the offer accepted?', <String>['By writing to the company', 'By performing the conditions', 'By paying £100', 'By going to court'], 1, 'Performance of the conditions is acceptance of a unilateral offer.'),
      ],
    ),
    RealCase(
      id: 'hadley',
      name: 'Hadley v Baxendale',
      citation: '(1854) 9 Exch 341',
      court: 'Court of Exchequer (England)',
      year: 1854,
      jurisdiction: 'England & Scotland (UK)',
      area: 'Contract law · damages and remoteness',
      parties: 'Hadley (mill owners) v. Baxendale (of Pickford & Co, carriers).',
      facts: <String>[
        'The crankshaft of the Hadleys\' mill in Gloucester broke and had to be sent to engineers in Greenwich as a pattern for a new one.',
        'The carriers delivered it several days late through their neglect, so the mill stayed idle longer.',
        'The Hadleys sued for the profits lost while the mill was stopped.',
      ],
      issue: 'Can a party recover lost profits that the other side did not know would result from a breach?',
      law: 'Common law of contract damages.',
      forSide: 'The Hadleys: the delay caused the mill to stand idle and the carriers should pay for all resulting losses.',
      againstSide: 'The carriers: they did not know the mill would stop without the shaft; mills often keep spare shafts.',
      decision: 'Lost profits were not recoverable here; a new trial was ordered.',
      reasoning: 'Alderson B. held that damages cover losses arising naturally from the breach, or those both parties reasonably contemplated when they made the contract. The carriers were not told the mill would be idle without the shaft.',
      significance: 'Set the rule on remoteness of damage in contract that is still applied today.',
      predictOptions: <String>[
        'The carriers must pay every loss caused by the delay',
        'Only losses that arise naturally or were in both parties\' contemplation are recoverable',
        'Carriers can never be liable for delay',
      ],
      predictAnswer: 1,
      questions: <CaseQuestion>[
        CaseQuestion('Why were lost profits not recoverable?', <String>['The carriers were not negligent', 'The loss was not reasonably contemplated by both parties', 'The contract was void', 'The mill was insured'], 1, 'The carriers were not told the mill depended on the shaft.'),
      ],
    ),
  ];
}
