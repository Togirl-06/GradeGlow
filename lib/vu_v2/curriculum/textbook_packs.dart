import 'textbook_fields.dart';

/// Long-form instructional prose. These passages teach; they do not pad titles.
abstract final class TextbookPacks {
  static String intro(TextbookKind kind, String topic, String course) {
    switch (kind) {
      case TextbookKind.skeletal:
        return 'Imagine entering an emergency department and seeing an X-ray of a patient '
            'who has fallen from a bicycle. Before the physician can determine whether the '
            'patient has fractured the radius, ulna, or humerus, they need a precise '
            'understanding of how the skeleton is organized, how a typical long bone is '
            'built, and which named structures are even in the field of view.\n\n'
            'A sentence such as “The skeletal system consists of bones. Bones provide '
            'support, protection, and movement” is true and almost useless at that moment. '
            'It is a summary. Summaries compress; they do not teach you which bone is '
            'medial, which is a girdle, or why unloading a limb changes density months later.\n\n'
            'This chapter on **$topic** in **$course** is a university reading. You will '
            'meet the axial/appendicular split as a clinical sorting tool, walk the anatomy '
            'of a long bone until the words diaphysis and periosteum change what you would '
            'palpate, follow remodeling as a lifelong process rather than a childhood event, '
            'and then apply the model to trauma. Terminology is introduced when it is needed '
            'and then used, not listed as decoration.\n\n'
            'Read slowly. After each numbered section, close the book and redraw the figure. '
            'If you cannot, you are still in the summary stage.';
      case TextbookKind.membrane:
        return 'A red blood cell placed in distilled water swells and may burst. The same '
            'cell in strong saline crenates. Nobody “decided” that should happen. Water '
            'moved. The direction of that movement is not a slogan about salt; it is a '
            'consequence of a bilayer that is a terrible door for ions and a passable door '
            'for small nonpolar molecules, plus proteins that make the barrier interesting.\n\n'
            '**$topic** in **$course** is the chapter in which you stop treating the cell '
            'as a bag and start treating it as a regulated compartment. We begin with a '
            'gradient, then a barrier, then the proteins that spend energy to keep the '
            'compartment different from the bath. Oral rehydration solution, IV fluid choice, '
            'and edema are not “applications tacked on.” They are the same physics with names.\n\n'
            'You will distinguish simple diffusion, facilitated diffusion, osmosis, and active '
            'transport by asking two questions every time: is a protein required, and is ATP '
            'hydrolyzed at this protein? If you cannot ask those questions, you cannot yet '
            'claim this chapter.';
      case TextbookKind.cell:
        return 'A junior technician is handed an unlabeled smear and asked what kind of cell '
            'it is. “It has a nucleus” is not an identification. Bacteria can surprise you; '
            'plants and fungi share walls for different biochemical reasons; mitochondria '
            'will not announce themselves at 4×.\n\n'
            '**$topic** in **$course** is cell theory made operational: what you must see, '
            'what you must not invent, and why magnification order is part of the science. '
            'We teach compartments, then evidence, then the mistakes that turn a lab into a '
            'guessing game.';
      case TextbookKind.dna:
        return 'If you treat DNA as “the molecule of heredity” and stop, you cannot explain '
            'why replication is semiconservative, why a 3′ end matters, or why a silent '
            'mutation is silent. **$topic** in **$course** is information as chemistry: '
            'base pairing as a copying rule, antiparallel strands as a geometric fact, and '
            'central-dogma steps as distinct jobs with different mistakes.';
      case TextbookKind.chemistry:
        return 'You are handed an unknown acid and a bottle of standardized sodium hydroxide. '
            '“Mix A and B” is not a method. **$topic** in **$course** is measurement under '
            'stoichiometric control: rinsing, meniscus, air bubbles in the burette tip, an '
            'indicator’s pH window, and the honesty to keep a trial you overshot.\n\n'
            'Concentration is not a vibe. It is moles of titrant at the true endpoint divided '
            'by the volume of unknown, with dilution algebra written in the open. If you '
            'cannot say what overshooting does to your calculated molarity, you cannot yet '
            'report a number.';
      case TextbookKind.physics:
        return 'Drop an object from a known height and time the fall. You will not obtain '
            '9.81 m/s². You will obtain a cloud of numbers. **$topic** in **$course** is how '
            'a physicist turns noisy trials into a claim about nature, with an error story '
            'rather than a single lucky click.\n\n'
            'The model g ≈ 2h/t² is simple enough to tempt dishonesty: one beautiful answer. '
            'This chapter forbids that. You will keep the scatter, graph it, and explain why '
            'the mean differs from the accepted value without blaming “human error” as a '
            'magical category.';
      case TextbookKind.clinical:
        return 'A fifty-four-year-old man holds his chest. Nobody in the room is asking you '
            'to define a normal heart rate. They are asking what you do first, what you must '
            'not skip, and what you will say if the supervising physician walks in.\n\n'
            '**$topic** in **$course** is clinical reasoning under incomplete information. '
            'Actions have order. Missing an ECG while reciting trivia is not studying. The '
            'patient’s state can change while you hesitate. That is the pedagogy.';
      case TextbookKind.law:
        return 'A file lands on your desk: a complaint, emails, a photograph, a statute, a '
            'precedent. Multiple-choice definitions of consideration will not open it. '
            '**$topic** in **$course** is how a junior associate turns paper into issues, '
            'rules, admissible evidence, arguments, and the other side’s best reply.';
      case TextbookKind.business:
        return 'Revenue is down eighteen percent. The CEO wants a cause by Friday, not a '
            'mood. Company-level percentages hide the story. **$topic** in **$course** is '
            'diagnosis with disaggregated data: region, then product, then a mechanism you '
            'can defend, then a decision whose consequences you are willing to forecast.';
      case TextbookKind.biology:
        return 'Biology is not a list of life facts. **$topic** in **$course** is a claim '
            'about living systems that must survive a control, a measurement, and a rival '
            'explanation. We open with a scene a working biologist would recognize, then '
            'build the model until a novice could design a test rather than recite a label.';
      case TextbookKind.generic:
        return 'Open **$topic** in **$course** as if a colleague will ask you to teach it '
            'tomorrow. A paragraph that only restates the title is not instruction. This '
            'chapter introduces terms when they earn their keep, walks a mechanism with '
            'verbs, puts a figure to work, names a professional first move, and attacks '
            'the misconception that a slogan is a model.\n\n'
            'University reading is slow on purpose. After the introduction you should be '
            'able to say what problem this chapter exists to solve — not what heading it '
            'wears.';
    }
  }

  static String organization(TextbookKind kind, String topic) {
    switch (kind) {
      case TextbookKind.skeletal:
        return 'The adult human skeleton is divided into two major components, and the '
            'split is not a trivia tax. It is how you decide what to protect, image, and '
            'clear first.\n\n'
            'The **axial skeleton** is the central axis: skull, vertebral column, and '
            'thoracic cage (ribs and sternum). These structures house the central nervous '
            'system and the organs of the thorax. A cervical-spine precaution is an axial '
            'decision. So is a chest tube’s relationship to intercostal spaces.\n\n'
            'The **appendicular skeleton** is the girdles and the limbs: pectoral girdle '
            '(clavicle and scapula), upper limbs, pelvic girdle, and lower limbs. A fall on '
            'an outstretched hand is an appendicular problem long before anyone recites '
            '“the skeletal system.”\n\n'
            'Why the distinction matters: injury patterns, imaging fields, and surgical '
            'approaches travel with these groups. Students lose marks by calling the '
            'clavicle axial because it sits near the midline. Articulation near the midline '
            'does not rewrite development or function. The clavicle is appendicular.\n\n'
            'Organization is also laterality and anatomical position. Radius is lateral and '
            'ulna is medial when the patient is in anatomical position — palms forward. If '
            'you describe a film with the palm down and swap those names, you will name the '
            'wrong bone. That is not pedantry. That is how a “broken arm” becomes the wrong '
            'operation.\n\n'
            'When a patient presents with trauma to the lower leg, you do not examine “the '
            'skeletal system.” You examine tibia and fibula first (the leg, not the thigh), '
            'then ask whether force transmitted to the ankle mortise or the knee. Named '
            'bones, in a named region, in a named division — that is organization applied.';
      case TextbookKind.membrane:
        return 'Classify every crossing event with two questions: protein or not; ATP at '
            'this protein or not.\n\n'
            'Passive, no protein: small nonpolar solutes such as O₂ and CO₂ through the '
            'hydrophobic core. Passive, protein: channels and carriers (facilitated '
            'diffusion) down an electrochemical gradient. Osmosis: net water toward higher '
            'effective osmotic concentration, often accelerated by aquaporins. Primary '
            'active: ATP is hydrolyzed at the pump (the Na⁺/K⁺ ATPase is the emblem). '
            'Secondary active: a gradient built by a pump is spent by a cotransporter '
            '(SGLT is the teaching example).\n\n'
            'This taxonomy is the organization of **$topic**. Treatments follow it. Poison '
            'ATP synthesis and primary pumps fail; secondary transport dies next; osmotic '
            'balance follows. If your notes are a pile of protein names without this tree, '
            'you have a glossary, not a chapter.';
      case TextbookKind.cell:
        return 'Organize cells the way a microscope forces you to: boundary, interior '
            'compartments, and evidence of energy or genetics. Prokaryotes lack a '
            'membrane-bound nucleus. Plant cells add a cellulose wall and, when green, '
            'chloroplasts. Animal cells do not. Fungi have walls that are not cellulose. '
            '**$topic** is that sorting, not a coloring-book of organelles.';
      case TextbookKind.dna:
        return 'Organize nucleic-acid information as structure → copying → expression. '
            'Base pairing is the copying rule. The 5′→3′ polarity is the synthesis rule. '
            'Transcription and translation are different machines in different places in '
            'eukaryotes. Collapsing them into “DNA makes protein” is how **$topic** becomes '
            'a slogan.';
      case TextbookKind.chemistry:
        return 'A titration bench is organized as glassware that must be clean in a '
            'chemically relevant way, a standardized titrant of known concentration, an '
            'unknown of known volume, an indicator or pH readout, and a notebook that '
            'records initial and final burette volumes without editing after the fact. '
            'Skip rinse and you dilute. Skip bubble-clearing and you invent volume. That '
            'is the organization of **$topic**.';
      case TextbookKind.physics:
        return 'An experiment is organized as apparatus, repeated trials, recorded raw '
            'data, a derived quantity, a graph that shows scatter, and a written account '
            'of systematic versus random error. **$topic** lives in that sequence. A single '
            'calculated g with no table is not an experiment.';
      case TextbookKind.clinical:
        return 'Organize an encounter as airway/breathing/circulation first, then vitals, '
            'then a targeted history, then the tests that can change the next ten minutes. '
            '**$topic** is that order. A recitation of normal ranges while the patient '
            'deteriorates is disorganization wearing a white coat.';
      case TextbookKind.law:
        return 'Organize a file as facts, issues, applicable rules, admissible evidence, '
            'and the inferences each exhibit actually supports. **$topic** is issue-spotting '
            'before advocacy. Advocacy without that map is performance.';
      case TextbookKind.business:
        return 'Organize a performance problem as a tree: company → region → product → '
            'customer behavior → decision. **$topic** forbids stopping at the first '
            'percentage. Averages hide the failing branch.';
      default:
        return 'Structure **$topic** the way a professional would: the objects or agents, '
            'the relations among them, the process in time, and the failure modes. If your '
            'notes are only a list of objects, you do not yet have the subject. Write a '
            'paragraph that could not be pasted onto a neighboring chapter by swapping the '
            'title. Then write why a look-alike is different. Distinction is how fields '
            'stay honest.';
    }
  }

  static String mechanism(TextbookKind kind, String topic) {
    switch (kind) {
      case TextbookKind.skeletal:
        return 'A typical **long bone** is a machine, not a white prop. The **diaphysis** '
            '(shaft) is a tube of compact bone around a medullary cavity that in adults '
            'holds yellow marrow. The **epiphyses** are the ends, built of spongy bone '
            'beneath articular cartilage so joints can bear load without grinding. Between '
            'them, in growing people, the epiphyseal plate is hyaline cartilage that is '
            'the reason a child’s fracture is not merely a smaller adult fracture.\n\n'
            '**Periosteum** is a living, vascular, innervated sheath. It is why bone pain '
            'is real and why periosteal injury matters for healing. Osteoblasts on bone '
            'surfaces deposit matrix; osteocytes sit in lacunae and sense strain; '
            'osteoclasts resorb. Remodeling is not a childhood chapter you close. Unload a '
            'limb in a cast and density falls. Load a tennis arm and it does not.\n\n'
            'Muscles pull tendons; bones are levers; joints constrain the path. If you skip '
            'this mechanics, kinesiology is vocabulary without a machine, and **$topic** '
            'collapses into the summary you were told not to write.\n\n'
            'On an X-ray you are seeing mineralized matrix, not periosteum and not most '
            'cartilage. That is why a film can look “normal” early in some injuries and why '
            'clinical correlation is not a polite extra — it is part of the method.';
      case TextbookKind.membrane:
        return 'The phospholipid bilayer’s hydrophobic core rejects hydrated ions. That is '
            'why a sodium ion does not “diffuse in because it is small.” Channels are gated '
            'aqueous pores. Carriers bind and change conformation; they saturate; they can '
            'be inhibited. Those two protein strategies are not synonyms.\n\n'
            'The Na⁺/K⁺ ATPase moves three sodium ions out and two potassium ions in per '
            'ATP. The unequal charge movement and the concentration gradients are the '
            'battery that secondary transporters spend. SGLT in the gut couples glucose to '
            'sodium; water follows osmotically. That is why oral rehydration solution '
            'contains both glucose and sodium, and why “just give water” is a '
            'misunderstanding of **$topic**, not a kindness.';
      case TextbookKind.cell:
        return 'Evidence, not labels, identifies a cell. A nucleus is a eukaryotic clue, '
            'not a complete ID. Chloroplasts and a cellulose wall together argue plant. A '
            'wall without chloroplasts could be fungus or a non-photosynthetic plant cell. '
            'Size and shape constrain bacteria. Stains add chemistry. **$topic** is that '
            'chain of inference.';
      case TextbookKind.chemistry:
        return 'Titration is controlled stoichiometric addition. An indicator reports a pH '
            'window, not a moral verdict of “done.” Phenolphthalein’s colorless-to-pink '
            'change is a range. Overshooting the endpoint does not erase the trial; it '
            'biases the titrant volume high. You record it, you do not “fix” it, and you '
            'repeat. Molarity of a monoprotic unknown is moles of base at the true endpoint '
            'divided by liters of acid. Dilution, if any, is algebra, not a vibe. That is '
            'the mechanism of **$topic**.';
      case TextbookKind.physics:
        return 'Near Earth, neglecting drag, displacement from rest is h = ½ g t², so '
            'g = 2h/t². Timing error enters squared in the denominator, which is why a '
            'sloppy stopwatch destroys the result faster than a slightly wrong meter stick. '
            'Air resistance systematically lengthens time and therefore lowers calculated g. '
            'Repeating trials is how scatter becomes visible. **$topic** is that error '
            'budget, not a treasure hunt for 9.81.';
      case TextbookKind.clinical:
        return 'Chest discomfort is a time-critical branch. You obtain vitals because '
            'numbers change the next action. You ask about onset, radiation, associated '
            'dyspnea or diaphoresis because the story sorts ACS from anxiety in a way a '
            'single heart-rate fact cannot. You order an ECG because ST-elevation is a '
            'decision, not a souvenir. If you skip, the patient can infarct while you feel '
            'busy. **$topic** is prioritization as a mechanism.';
      case TextbookKind.law:
        return 'Legal analysis is IRAC done honestly. The issue is a question the facts '
            'actually raise. The rule is a statute or holding, not a vibe of fairness. '
            'Application maps facts onto elements, including facts that hurt. A photograph '
            'that inflames more than it proves can be excluded. **$topic** is that mapping.';
      case TextbookKind.business:
        return 'A company-level decline is a mixture. If Region A is up four percent and '
            'Region B is down thirty-one, the average is a disguise. If Product X is down '
            'forty-two percent after a price change and complaints rose, the mechanism is '
            'not “marketing in general.” **$topic** is the drill-down until a decision '
            'has a causal story.';
      default:
        return 'Mechanism for **$topic** means a causal chain: starting state, allowed '
            'operations, invariants, end state, and what a disruption does. Write the chain '
            'with verbs. Noun piles are not mechanisms. After the chain, state one check a '
            'skeptic could demand — a measurement, a control, a citation, a laterality, a '
            'sign in the opposite direction.';
    }
  }

  static String essay(TextbookKind kind, String topic, String course) {
    switch (kind) {
      case TextbookKind.skeletal:
        return _skeletalEssay(topic, course);
      case TextbookKind.membrane:
        return _membraneEssay(topic, course);
      case TextbookKind.cell:
        return _cellEssay(topic, course);
      case TextbookKind.dna:
        return _dnaEssay(topic, course);
      case TextbookKind.chemistry:
        return _chemEssay(topic, course);
      case TextbookKind.physics:
        return _physEssay(topic, course);
      case TextbookKind.clinical:
        return _clinEssay(topic, course);
      case TextbookKind.law:
        return _lawEssay(topic, course);
      case TextbookKind.business:
        return _bizEssay(topic, course);
      case TextbookKind.biology:
        return _bioEssay(topic, course);
      case TextbookKind.generic:
        return _genericEssay(topic, course);
    }
  }

  static String studio(TextbookKind kind, String topic, String course) {
    return 'Reading **$topic** in **$course** is a skill. First pass: read 1.1 through 1.3 '
        'without highlighting. If you highlight everything, you are afraid, not studying. '
        'After 1.1, write the problem the chapter exists to solve in one sentence that does '
        'not contain the chapter title. After 1.2, draw the organization. After 1.3, write '
        'the causal chain with verbs. Only then look at the figures and try to predict the '
        'worked example before you read the path.\n\n'
        'Second pass: cover the worked example’s answer and force yourself to choose the '
        'first move. Say why a nearby look-alike is the trap. If you cannot, you are still '
        'in recognition. Recognition is what a summary card trains. University reading trains '
        'production.\n\n'
        'Third pass: answer Check Your Understanding in writing. Compare to the chapter. '
        'The mismatches are your lecture questions. Bring them to the professor as arguments, '
        'not as “can you repeat the definition.” The professor will hide labels on purpose.\n\n'
        'Then enter the laboratory. A lab is not a quiz wearing goggles. You will have a '
        'mission, equipment, an environment that responds, decisions with consequences, data '
        'that can be ugly, and a report. If you skip calibration, focus order, vitals, or the '
        'failing region, the simulation will remember. That is the point.\n\n'
        'When you write the case at the end of this chapter, pretend a junior colleague will '
        'act on your sentences. Name the observation, the inference, the action, and the '
        'uncertainty. If any line could be pasted into a different chapter by swapping '
        '**$topic**, rewrite it until it would be malpractice in another subject.\n\n'
        'Spaced review is not rereading. Tomorrow, rebuild Figure 1 from memory. Before the '
        'exam, teach the worked path aloud in two minutes. If you stall, return to mechanism, '
        'not to the heading. $course will assume this chapter later; it will not warn you.\n\n'
        'A note on diagrams: they are compressed arguments, not clip art. Trace the arrows '
        'and narrate. If you cannot, the figure has not been read. The same standard applies '
        'to a titration table, a drop-time grid, an ECG, a regional dashboard, and a case file. '
        'Instruments show up because this field uses them; they are not decoration for a quiz.\n\n'
        'Keep a running glossary. Each bold term in this chapter should change a decision: '
        'which bone, which transporter, which titre, which action, which exhibit, which region. '
        'A term that only sounds educated is decoration. Decoration fails professional '
        'simulation at Level 4, where nobody hands you the procedure.\n\n'
        'If you have twenty spare minutes, write a teaching outline with no bullet that merely '
        'restates **$topic**. Include one observation you would demand before trusting a '
        'conclusion, one instrument, one control, and the most likely error. That outline is '
        'the bridge from this chapter to the investigation lab. Skipping it is how students '
        'arrive at the bench ready to click.';
  }

  static String models(TextbookKind kind, String topic) {
    return '**Figure 1.** A two-panel contrast for **$topic**: the naïve picture a '
        'summary card would print, beside the working model this chapter actually uses '
        '(axial vs appendicular; protein vs no protein; plant vs animal; flask before '
        'and after endpoint; five noisy trials vs one lucky number; Region B vs the '
        'company average).\n\n'
        '**Figure 2.** The inset a novice skips — periosteum, SGLT, the burette tip '
        'bubble, the photogate placement, the ECG lead, a footnote in a contract, the '
        'complaint spike after a price change.\n\n'
        '**Figure 3.** The failure case: 40× before a focused 4× field; overshot pink; '
        'a single trial reported as g; a patient who infarcts while vital signs wait; a '
        'photo admitted because it is dramatic; a strategy that “increases ads” without '
        'naming the failing product.\n\n'
        'Redraw all three with the book closed. If you cannot, you are still summarizing '
        '**$topic**, not reading it.';
  }

  static String _skeletalEssay(String t, String c) {
    return 'Bone is living tissue. That sentence is the first misconception repair in '
        '**$t**, and it is not poetry. Living bone is vascular. It hurts when periosteum '
        'is irritated. It remodels. It fails in characteristic ways: greenstick in the '
        'young, fragility in the osteoporotic, avascular necrosis when a blood supply is '
        'unforgiving, nonunion when stability or biology is missing.\n\n'
        'Compact bone is organized in osteons with central canals. Spongy bone is '
        'trabeculae aligned to load. Marrow is a hematopoietic and adipose organ living '
        'inside mineral. If your mental picture is a dry Halloween decoration, you will '
        'not understand why a closed fracture still threatens fat embolism, why '
        'compartment syndrome is an emergency, or why a child’s growth plate injury is '
        'counseled differently from a shaft crack.\n\n'
        'Movement is not “bones plus muscles” as a list. A joint is a constraint. A '
        'muscle can only pull. A bone transmits compression, tension, and bending. Tendons '
        'and ligaments are not interchangeable words. Ligaments stabilize joints; tendons '
        'transmit muscle force. Skip that and every later chapter on gait or throwing is '
        'cosplay.\n\n'
        'Clinical films require a language: AP, lateral, oblique; anatomical position as '
        'the naming frame even when the arm is pronated on the table. Distal radius '
        'fractures after FOOSH are common because that is where the load path goes when '
        'the hand hits first. Ulna and carpus still get inspected because force is not '
        'polite. Humerus is the arm; radius and ulna are the forearm; “arm” in casual '
        'speech is how patients talk and how students fail identification.\n\n'
        'Pelvis and femur change the story again: blood loss, hip-joint implications, '
        'inability to bear weight. Axial trauma asks about spinal cord and airway in the '
        'same breath as bone. That is why the organization section was not optional '
        'flavor. **$c** will test whether you can choose the right family of bones before '
        'you can name the chip on the film.\n\n'
        'Remodeling is Wolff’s law in usable form: bone adapts to habitual load. Astronauts '
        'and bedridden patients lose density for the same directional reason a tennis '
        'player’s racket arm does not. Calcium chapters that treat bone as a warehouse '
        'miss the cells. PTH, calcitonin, estrogen, and vitamin D matter because they '
        'talk to those cells. You do not need the full endocrine monograph here, but you '
        'do need to refuse the idea that anatomy is a bag of names and physiology is a '
        'different course that starts later.\n\n'
        'When you meet a cyclist with a tender distal forearm, you are not being asked '
        'whether the skeletal system provides support. You are being asked which bones, '
        'which division, which associated injuries you must not miss, and how articular '
        'involvement changes what you tell the patient. That is university anatomy. That '
        'is **$t**.';
  }

  static String _membraneEssay(String t, String c) {
    return 'Start with a gradient because life is a nonequilibrium state. A cell that '
        'equilibrates every solute with the bath is dead or dying. The plasma membrane is '
        'how **$c** lets you talk about that nonequilibrium without magic.\n\n'
        'Simple diffusion of O₂ works because oxygen is small and nonpolar. It does not '
        'work for glucose at useful rates; that is why GLUT proteins exist. It does not '
        'work for sodium; that is why channels and pumps exist. “Diffusion is how stuff '
        'moves” is the summary that fails an exam the moment the solute is charged.\n\n'
        'Osmosis is water, and tonicity is about the solutes that cannot freely follow. '
        'A solution can be iso-osmotic and still hypotonic if the solute penetrates and '
        'then water follows. That distinction is why sterile water is not an IV fluid and '
        'why urea behaves differently from sucrose in teaching problems. If you collapse '
        'tonicity into “saltiness,” you will lyse cells in your head and not notice.\n\n'
        'Facilitated diffusion saturates. Simple bilayer diffusion of O₂ does not in the '
        'same way. Michaelis–Menten language belongs here even if this is not an enzyme '
        'chapter, because carriers are enzymes’ cousins. Inhibitors and competing solutes '
        'are not extra credit. They are how you tell a carrier from a pore.\n\n'
        'The sodium–potassium pump is primary active transport and the quiet premise of '
        'membrane potential, secondary transport, and cell-volume control. Ouabain is the '
        'classic poison in textbooks because it makes the premise visible. Secondary '
        'active transport is not “sort of active.” It is active at one remove: ATP was '
        'spent at the pump; the cotransporter spends the ion battery.\n\n'
        'ORS is the humanitarian face of **$t**. Cholera dumps chloride into the lumen; '
        'water follows; the patient dehydrates. SGLT still works. Glucose plus sodium in '
        'the lumen pulls sodium, then water, through a living epithelium. Water alone does '
        'not recruit that cotransporter. This is not a heartwarming sidebar. It is the '
        'same figure as the gut apical membrane.\n\n'
        'Edema, hypernatremia, and IV fluid choice are the other face. You are not being '
        'trained to recite “the cell membrane is selectively permeable.” You are being '
        'trained to predict volume change when non-penetrating solute outside rises, and '
        'to know that “hydrate” is not a complete order. Hypotonic IV free water can lyse '
        'red cells; isotonic saline does not, because the effective osmoles cannot freely '
        'follow water into the erythrocyte. Carriers also explain why high-dose glucose '
        'does not infinitely increase uptake: GLUT saturates. A channel does not bind in '
        'the same saturable way. If your notebook cannot say which protein class you '
        'invoked, you cannot interpret a transport graph in **$c**. That is the chapter. '
        'That is **$t**.';
  }

  static String _cellEssay(String t, String c) {
    return 'Cell theory is three commitments: organisms are made of cells; the cell is the '
        'living unit; cells arise from cells. **$t** in **$c** is what those commitments '
        'force you to do with a specimen. You do not begin at 40×. You begin by finding '
        'the sample at low power because a scientist who cannot find the specimen is not '
        'magnifying knowledge — they are magnifying noise.\n\n'
        'Eukaryotic interiors are not a random sticker sheet. Ribosomes make protein. '
        'Rough ER feeds the secretory path. Golgi modifies and sorts. Mitochondria run '
        'oxidative phosphorylation on inner-membrane cristae — and if all you remember is '
        '“powerhouse,” you still cannot say which membrane holds the electron-transport '
        'chain. Nuclei hold chromosomes in eukaryotes; nucleoid is not a nucleus. Lysosomes '
        'and vacuoles are related stories in animal and plant cells, not identical '
        'furniture.\n\n'
        'Identification is hypothesis plus test. Chloroplasts and a wall push you toward '
        'plant. A wall and no chloroplast is incomplete. Bacteria at a few micrometers with '
        'no nucleus is a different world. Fungi add chitinous walls and their own look. '
        'You record what you saw, not what the worksheet hoped you would click. That is '
        'the difference between a lab and a quiz in a lab coat.';
  }

  static String _dnaEssay(String t, String c) {
    return 'Base pairing is not a rhyme. A pairs with T (or U in RNA) and G with C because '
        'of hydrogen-bond geometry and the width of the helix. Replication is '
        'semiconservative: each daughter helix keeps one parental strand. Helicase, '
        'primase, DNA polymerases, and ligase are jobs, not a shopping list. Leading and '
        'lagging strands exist because synthesis is 5′→3′ on antiparallel templates.\n\n'
        'Transcription copies DNA into RNA with different machinery and, in eukaryotes, '
        'different location than translation. Introns, 5′ caps, and poly-A tails are why '
        'eukaryotic mRNA is not a raw gene. Translation is a ribosome reading codons with '
        'tRNAs. A missense mutation is not a silent mutation. **$t** in **$c** is that '
        'refusal to collapse the central dogma into a single arrow.';
  }

  static String _chemEssay(String t, String c) {
    return 'Quantitative chemistry is a promise that the notebook matches the glassware. '
            'Rinse a pipette with the solution it will deliver, not with leftover water that '
            'will dilute the unknown. Fill a burette, clear the tip, and read the meniscus at '
            'eye level. Those sentences are not etiquette. They are systematic-error control '
            'for **$t** in **$c**.\n\n'
            'At the endpoint of a strong-base titration of a monoprotic strong acid, moles '
            'of acid equal moles of base if the stoichiometry is 1:1. Weak acids add '
            'buffering and a different curve; the indicator still has to match the steep '
            'region. Three concordant titres are how you show you can hit a technique, not '
            'how you hide an overshot flask. Report mean and scatter. If the third trial is '
            'an outlier you can explain (overshoot, bubble, dirty flask), you still write it '
            'down. Erasing is not analysis.';
  }

  static String _physEssay(String t, String c) {
    return 'A measurement without an error story is a rumor. In a free-fall lab the accepted '
            'g is a reference, not a grade. Your job in **$t** is to estimate g from h and t, '
            'repeat, plot, and interpret. Reaction time on a stopwatch is largely random. A '
            'meter stick that is always 1 cm short is systematic. Air resistance is '
            'systematic in the direction of longer times. Write those sentences until they '
            'are more automatic than the formula.\n\n'
            'Graphs are not decoration. Height versus t² should be linear with slope g/2 if '
            'the model holds. A cloud with no trend is a procedure problem. A trend with a '
            'wrong slope is a model or calibration problem. **$c** will credit the student '
            'who explains the discrepancy, not the student who writes 9.81 because they '
            '“know what it should be.”';
  }

  static String _clinEssay(String t, String c) {
    return 'Professional simulation is not a quiz about normal ranges. It is a patient who '
            'can worsen. For **$t** in **$c** you practice gathering the information that '
            'changes action: vitals, a pain history that includes radiation and associated '
            'symptoms, a cardiovascular exam, an ECG, and a call for help when the pattern '
            'is ACS or shock. You also practice writing why you did what you did, because '
            'a chart is how teams survive shift change.\n\n'
            'Incomplete reasoning should be met with a probing question, not a green check. '
            'Dangerous omissions — no vitals, no ECG, no airway glance — should pause the '
            'case. That is teaching. The objective is to think like the professional you '
            'are training to become, not to harvest points.';
  }

  static String _lawEssay(String t, String c) {
    return 'A junior associate does not “know the law” as a stack of slogans. They read. '
            'The complaint tells you the theory the other side is already telling a court. '
            'Witness statements conflict; that is normal. Emails have hearsay and business-'
            'record problems. Photographs have prejudicial impact. Statutes have elements. '
            'Precedents have holdings and distinguishable facts.\n\n'
            '**$t** in **$c** is the file: what happened, what is disputed, what is '
            'admissible, what your client can argue, what you must expect back. Then a '
            'hearing, where a judge or opposing counsel will not award you a point for '
            'defining consideration if you never tied it to these facts.';
  }

  static String _bizEssay(String t, String c) {
    return 'Aggregates lie. A firm can grow in one region and collapse in another while '
            'the quarterly slide looks like a gentle slide. **$t** in **$c** trains you to '
            'open the regional dashboard, then the product cut, then the customer-complaint '
            'log, then the price-change date, then a competitor move. Only then do you write '
            'a recommendation whose consequences you are willing to simulate: restore a '
            'price and lose a margin story, keep the price and lose volume, or split the '
            'difference with a communication plan that may not work.\n\n'
            'The laboratory is the company. Decisions change the next quarter in the model. '
            'That is the point. A multiple-choice definition of “marketing mix” cannot do '
            'this job.';
  }

  static String _bioEssay(String t, String c) {
    return 'A biologist’s claim is a claim that could have been otherwise. **$t** in **$c** '
            'should leave you able to name an observation, a competing explanation, and a '
            'measurement that would hurt your favorite story. Controls exist because living '
            'systems are noisy. Sample size exists because anecdote is not a result. A '
            'diagram is a model; a model hides assumptions. If you cannot say what the '
            'figure leaves out, you are decorating, not reading.\n\n'
            'Use the architecture of this course. Foundations before membranes; membranes '
            'before bioenergetics; information flow before Mendel. **$t** sits on that tree. '
            'Learn it as a chapter that future chapters will assume, not as an isolated '
            'badge.';
  }

  static String _genericEssay(String topic, String course) {
    return 'Open **$topic** in **$course** the way a supervisor would: name the problem a junior person is actually handed, '
            'the distinction that makes it solvable, the causal chain with verbs, and the first observation you would demand before trusting a conclusion.\n\n'
            'A worked path always states the unknown, the governing rule, the substitution or analogical mapping, and a sanity check: units, laterality, opposite-party facts, a limit as a variable goes to zero. '
            'Misconceptions in this field usually collapse that path into a slogan. Repair the slogan with the mechanism, not with “that’s wrong.”\n\n'
            'When you finish the chapter, you should be able to enter the laboratory and perform **$topic** — prepare, observe, decide, record, and report — without hunting a labeled answer. '
            'If a sentence in your notes could be pasted into a different chapter unchanged, rewrite it. That is the standing order for **$course**.';
  }
}
