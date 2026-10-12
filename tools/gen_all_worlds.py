#!/usr/bin/env python3
"""Generate all 19 Career Lab world Dart files (CareerWorldKit-based)."""
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "lib/vu_v2/career_sim/worlds"

def esc(s: str) -> str:
    return s.replace("\\", "\\\\").replace("'", "\\'")

def loc(i, n, b, icon, lvl=1, hint=None):
    extra = f",\n          lockedHint: '{esc(hint)}'," if hint else ","
    return (
        f"        CareerLocation(\n"
        f"          id: '{i}',\n"
        f"          name: '{esc(n)}',\n"
        f"          blurb: '{esc(b)}',\n"
        f"          icon: '{icon}',\n"
        f"          unlockCareerLevel: {lvl}{extra}\n"
        f"        )"
    )

def npc(i, n, r, p, g):
    return (
        f"        CareerNpc(\n"
        f"          id: '{i}',\n"
        f"          name: '{esc(n)}',\n"
        f"          role: '{esc(r)}',\n"
        f"          personality: '{esc(p)}',\n"
        f"          avatarGlyph: '{g}',\n"
        f"        )"
    )

def seed_block(s):
    lines = [
        "        MissionSeed(",
        f"          title: '{esc(s['title'])}',",
        f"          brief: '{esc(s['brief'])}',",
        f"          objective: '{esc(s['objective'])}',",
        f"          startLocationId: '{s['start']}',",
        f"          cinematicTitle: '{esc(s['ct'])}',",
        f"          cinematicBody: '{esc(s['cb'])}',",
        f"          supervisorLine: '{esc(s['line'])}',",
        f"          decisionTitle: '{esc(s['dt'])}',",
        f"          decisionBody: '{esc(s['db'])}',",
        f"          goodLabel: '{esc(s['gl'])}',",
        f"          goodNarrative: '{esc(s['gn'])}',",
        f"          okLabel: '{esc(s['ol'])}',",
        f"          okNarrative: '{esc(s['on'])}',",
        f"          badLabel: '{esc(s['bl'])}',",
        f"          badNarrative: '{esc(s['bn'])}',",
        f"          endTitle: '{esc(s['et'])}',",
        f"          endBody: '{esc(s['eb'])}',",
    ]
    if s.get("d2"):
        d = s["d2"]
        lines += [
            f"          decision2Title: '{esc(d[0])}',",
            f"          decision2Body: '{esc(d[1])}',",
            f"          good2Label: '{esc(d[2])}',",
            f"          good2Narrative: '{esc(d[3])}',",
            f"          ok2Label: '{esc(d[4])}',",
            f"          ok2Narrative: '{esc(d[5])}',",
            f"          bad2Label: '{esc(d[6])}',",
            f"          bad2Narrative: '{esc(d[7])}',",
        ]
    if s.get("free"):
        f = s["free"]
        kw = ", ".join(f"'{k}'" for k in f[1])
        lines += [
            f"          freeTextPrompt: '{esc(f[0])}',",
            f"          freeTextKeywords: const <String>[{kw}],",
            f"          freeTextHint: '{esc(f[2] if len(f)>2 else 'Be specific.')}',",
        ]
    if s.get("pressure"):
        lines += [
            f"          pressureTitle: '{esc(s['pressure'][0])}',",
            f"          pressureBody: '{esc(s['pressure'][1])}',",
        ]
    if s.get("random"):
        lines += [
            f"          randomEventTitle: '{esc(s['random'][0])}',",
            f"          randomEventBody: '{esc(s['random'][1])}',",
        ]
    if s.get("badge"):
        lines.append(f"          badgeOnClear: '{s['badge']}',")
    lines.append(f"          primarySkill: {s.get('skill', 'CareerSkillId.analysis')},")
    lines.append(f"          secondarySkill: {s.get('skill2', 'CareerSkillId.communication')},")
    lines.append("        )")
    return "\n".join(lines)

def emit(cfg):
    text = f"""import '../career_sim_models.dart';
import 'career_world_kit.dart';

/// {cfg['doc']}
abstract final class {cfg['class']} {{
  static const String worldId = '{cfg['id']}';

  static CareerWorld build() {{
    return CareerWorldKit.build(
      id: worldId,
      name: '{esc(cfg['name'])}',
      workplace: '{esc(cfg['workplace'])}',
      role: const CareerRole(
        title: '{esc(cfg['role'])}',
        shift: '{esc(cfg['shift'])}',
        supervisorName: '{esc(cfg['supervisor'])}',
        tagline: '{esc(cfg['tagline'])}',
      ),
      skillIds: {cfg['skills']},
      careerTitles: const <String>[{', '.join(repr(t).replace('"','') if False else chr(39)+t+chr(39) for t in cfg['titles'])}],
      locations: const <CareerLocation>[
{chr(10).join(cfg['locations'])},
      ],
      npcs: const <CareerNpc>[
{chr(10).join(','+chr(10) if False else '')}{(','.join([]) ) }
{chr(10).join(cfg['npcs'])},
      ],
      supervisorNpcId: '{cfg['npc']}',
      missionIdPrefix: '{cfg['prefix']}',
      seeds: <MissionSeed>[
{chr(10).join(seed_block(s)+',' for s in cfg['seeds'])}
      ],
    );
  }}
}}
"""
    # fix accidental join bug above - rewrite cleanly
    titles = ", ".join(f"'{t}'" for t in cfg["titles"])
    locs = ",\n".join(cfg["locations"])
    npcs = ",\n".join(cfg["npcs"])
    seeds = ",\n".join(seed_block(s) for s in cfg["seeds"])
    text = f"""import '../career_sim_models.dart';
import 'career_world_kit.dart';

/// {cfg['doc']}
abstract final class {cfg['class']} {{
  static const String worldId = '{cfg['id']}';

  static CareerWorld build() {{
    return CareerWorldKit.build(
      id: worldId,
      name: '{esc(cfg['name'])}',
      workplace: '{esc(cfg['workplace'])}',
      role: const CareerRole(
        title: '{esc(cfg['role'])}',
        shift: '{esc(cfg['shift'])}',
        supervisorName: '{esc(cfg['supervisor'])}',
        tagline: '{esc(cfg['tagline'])}',
      ),
      skillIds: {cfg['skills']},
      careerTitles: const <String>[{titles}],
      locations: const <CareerLocation>[
{locs},
      ],
      npcs: const <CareerNpc>[
{npcs},
      ],
      supervisorNpcId: '{cfg['npc']}',
      missionIdPrefix: '{cfg['prefix']}',
      seeds: <MissionSeed>[
{seeds},
      ],
    );
  }}
}}
"""
    path = OUT / cfg["file"]
    path.write_text(text, encoding="utf-8")
    print("wrote", path.name)

def ms(title, brief, objective, start, ct, cb, line, dt, db, gl, gn, ol, on, bl, bn, et, eb, **kw):
    d = dict(title=title, brief=brief, objective=objective, start=start, ct=ct, cb=cb,
             line=line, dt=dt, db=db, gl=gl, gn=gn, ol=ol, on=on, bl=bl, bn=bn, et=et, eb=eb)
    d.update(kw)
    return d

# Compact arc builder for professions with less bespoke text
def arc(prefix_titles, starts, skill, boss_name, domain_verbs, free_kw, supervisor_quotes):
    """Build 7 mission seeds from compact lists.
    prefix_titles: 7 (title, brief, objective, decision_body, good, bad_fail_label)
    """
    stages_extra = [
        {},
        {"free": ("Explain your best choice in 1-2 sentences.", free_kw, "Cite evidence and next step."), "badge": "first_clear"},
        {},
        {"free": ("What risk are you managing and why?", ["risk","because","evidence","plan","next"], "Name the risk.")},
        {},
        {"pressure": ("CLOCK IS RUNNING", "Escalate carefully. Seconds matter."),
         "random": ("SUDDEN COMPLICATION", "A new variable appears. Adapt without breaking integrity.")},
        {"badge": "boss_clear",
         "free": (f"Write your one-line plan for {boss_name}.", free_kw + ["plan","because"], "Be concrete."),
         "pressure": ("FINAL WINDOW", f"{boss_name} — choose under pressure."),
         "random": ("LAST TWIST", "One more complication before the finish.")},
    ]
    seeds = []
    for i, (title, brief, objective, db, good, bad) in enumerate(prefix_titles):
        start = starts[min(i, len(starts)-1)]
        ok = domain_verbs[i] if i < len(domain_verbs) else "Take a middling compromise"
        s = ms(
            title, brief, objective, start,
            title.replace("Mission 0", "Day ").split("—")[0].strip() if "—" in title else title,
            f"{brief}\\n\\nOBJECTIVE: {objective}",
            supervisor_quotes[min(i, len(supervisor_quotes)-1)],
            "Critical choice", db,
            good, "Strong call. Progress holds.",
            ok, "Partial progress. Friction remains.",
            bad, "That path collapses trust and outcomes.",
            "Mission complete", "You cleared this stage of the track.",
            skill=skill,
        )
        if i in (1, 3, 4):
            s["d2"] = (
                "Follow-up decision",
                "A secondary issue appears. How do you handle it?",
                "Address it with evidence and clear communication",
                "Secondary issue stabilized.",
                "Defer vaguely and hope it fades",
                "It returns worse later.",
                "Ignore it and fabricate a status update",
                "Integrity failure. Stage failed.",
            )
        s.update(stages_extra[i])
        seeds.append(s)
    return seeds

# ========================= DEFINE ALL WORLDS =========================
WORLDS = []

# We'll import law from inline full definition + generate others via arc()

# --- For speed/reliability: define each world with arc() ---

def add_world(**cfg):
    WORLDS.append(cfg)

# LAW - full custom
add_world(
    **{
        "class": "LawFirmWorld", "id": "law_firm", "file": "law_firm_world.dart", "prefix": "law", "npc": "vargas",
        "doc": "Hartwell & Associates — Junior Law Associate.",
        "name": "Law Firm & Courtroom", "workplace": "Hartwell & Associates",
        "role": "Junior Law Associate", "shift": "8:30 AM – 7:00 PM",
        "supervisor": "Partner Elena Vargas", "tagline": "Facts win cases. Shortcuts lose careers.",
        "skills": """const <String>[
        CareerSkillId.analysis, CareerSkillId.investigation, CareerSkillId.advocacy,
        CareerSkillId.communication, CareerSkillId.research, CareerSkillId.ethics,
      ]""",
        "titles": ["Law Clerk","Junior Associate","Associate","Senior Associate","Counsel","Partner Track","Partner"],
        "locations": [
            loc("reception","Reception","Clients and first impressions.","🏛️"),
            loc("associates","Associates Bullpen","Research desks and war rooms.","💻"),
            loc("library","Law Library","Reporters and quiet focus.","📚"),
            loc("conference","Conference Room","Meetings and depositions.","🗣️"),
            loc("partner","Partner Office","Vargas reviews strategy.","🚪",3,"Reach Career Level 3."),
            loc("war_room","Trial War Room","Exhibits and timelines.","📁",4,"Reach Career Level 4."),
            loc("courtroom","Courtroom","Motions and trial.","⚖️",5,"Reach Career Level 5."),
            loc("chambers","Judge Chambers","Sidebars and sealed orders.","🔏",6,"Reach Career Level 6."),
        ],
        "npcs": [
            npc("vargas","Partner Elena Vargas","Supervisor","Exacting, ethical, hates sloppy cites.","👩‍💼"),
            npc("client_m","Marcus Hale","Client","Anxious founder in a contract dispute.","🧑"),
            npc("opposing","Jordan Blake","Opposing Counsel","Aggressive, probes weakness.","🧔"),
            npc("paralegal","Sam Ortiz","Paralegal","Catches missing exhibits.","🧑‍💻"),
            npc("judge","Judge Rhee","Bench","Fair, impatient with the unprepared.","👩‍⚖️"),
            npc("witness","Dr. Kim","Key Witness","Careful, needs clear prep.","🧑‍🔬"),
        ],
        "seeds": [
            ms("Mission 01 — Firm Orientation","Tour the firm and open your first matter.","Complete onboarding without ethics missteps.","reception",
               "Day One · Hartwell","Glass doors. Binders with your name.","\"Ethics before ego.\"",
               "Matter intake","A contract dispute lands on your desk.",
               "Conflict check + open matter + calendar deadlines","Clean intake.",
               "Skim and email the client immediately","Conflict flag caught later.",
               "Promise a guaranteed win","Ethics violation.",
               "Orientation complete","On the matter board.",
               badge="firm_orientation", skill="CareerSkillId.ethics",
               free=("Why conflict-check before calling the client?",["conflict","ethics","client","before","check"],"Mention conflict check.")),
            ms("Mission 02 — First Client","Meet Marcus Hale; scope the dispute.","Run a professional client intake.","conference",
               "First Client","A founder who wants war.","\"Scope facts, not feelings.\"",
               "Client vents","Hale demands you sue them into the ground.",
               "Reflect concerns; ask for timeline and contracts","Usable chronology.",
               "Promise aggressive war immediately","Expectations inflate.",
               "Tell him to settle today and leave","Client walks out.",
               "Intake complete","Real emails shared.",
               badge="first_client", skill="CareerSkillId.advocacy",
               d2=("Claim theory","What do you research first?",
                   "Breach of contract + IP clauses","Focused research.",
                   "Everything including RICO","Scattershot.",
                   "File tonight with no research","Frivolous risk."),
               free=("How do you set timeline expectations?",["timeline","uncertain","process","update","realistic"],"Promise process.")),
            ms("Mission 03 — Case Investigation","Build chronology; preserve evidence.","Produce a reliable investigation memo.","associates",
               "Investigation","A missing attachment matters.","\"If it is not in the record, it did not happen.\"",
               "Evidence gap","Key attachment missing.",
               "Preservation letter + native files","File produced.",
               "Assume it never existed","Gap exploited later.",
               "Alter a PDF to match your theory","Career-ending breach.",
               "Memo filed","Chronology holds.", skill="CareerSkillId.investigation"),
            ms("Mission 04 — Legal Research","Find controlling authority.","Deliver a Shepardized memo.","library",
               "Research","Circuit split waiting.","\"Do not cite dicta as holding.\"",
               "Authority","Out-of-circuit win vs contrary local ruling.",
               "Lead with binding local authority","Correct hierarchy.",
               "Lead with flashy out-of-circuit case","Binding law hits later.",
               "Ignore adverse authority","Candor problem.",
               "Memo accepted","Pin cites used.", skill="CareerSkillId.research",
               free=("State the holding you lead with.",["holding","court","because","requires","rule"],"Name the rule.")),
            ms("Mission 05 — Deposition","Protect the record.","Survive deposition cleanly.","conference",
               "Deposition","Blake smiles.","\"Objections are tools.\"",
               "Badgering","Blake badgers your witness.",
               "Concise form objection; privilege only","Record protected.",
               "Argue five minutes on the record","Messy transcript.",
               "Refuse all answers","Sanctions risk.",
               "Deposition survived","Transcript usable.", skill="CareerSkillId.advocacy"),
            ms("Mission 06 — Trial Crisis","Witness wavers mid-trial.","Stabilize trial ethically.","courtroom",
               "Trial Crisis","Contradiction on the stand.","\"Do not invent facts.\"",
               "Rehab","Witness drifts on a date.",
               "Clarify with prior consistent statement","Jury re-centers.",
               "Attack your own witness","Jury winces.",
               "Fabricate a calendar entry","Mistrial risk.",
               "Crisis contained","Alive for closing.", skill="CareerSkillId.advocacy",
               pressure=("OBJECTION STORM","Three objections in ninety seconds."),
               random=("SIDEBAR","Judge wants a proffer on the exhibit.")),
            ms("Mission 07 — BOSS: THE CASE","Closing argument.","Win a clean close in THE CASE.","courtroom",
               "BOSS · THE CASE","Jury waiting.","\"Make the story true and simple.\"",
               "Theme","Closing theme?",
               "Promise vs performance via contract and emails","Jury leans in.",
               "Attack counsel personally","Theme muddies.",
               "Invent a fact not in evidence","Case compromised.",
               "THE CASE closed","Verdict path holds.", badge="the_case", skill="CareerSkillId.advocacy",
               free=("One-sentence closing theme.",["contract","evidence","promise","because","prove"],"Tie to evidence."),
               pressure=("VERDICT CLOCK","Fix the hole Blake punched."),
               random=("LAST EXHIBIT","Blake moves to exclude damages chart.")),
        ],
    }
)

# Generic helper for remaining
PROFESSIONS = [
  # (class, id, file, prefix, npc_id, doc, name, workplace, role, shift, supervisor, tagline, skills, titles, locations, npcs, starts, skill, boss, titles7)
]

def skills(*ids):
    body = ", ".join(ids)
    return f"const <String>[{body}]"

def make_arc_world(
    cls, wid, file, prefix, npc_id, doc, name, workplace, role, shift, supervisor, tagline,
    skill_list, titles, locations, npcs, starts, skill, boss_name, mission_rows, free_kw, quotes
):
    # mission_rows: 7 tuples (title, brief, objective, decision_body, good, bad)
    oks = [
        "Take a careful middle path",
        "Compromise without documenting well",
        "Order more data than needed",
        "Escalate late but correctly",
        "Patch symptoms only",
        "Split focus across issues",
        "Sound confident without full evidence",
    ]
    seeds = arc(mission_rows, starts, skill, boss_name, oks, free_kw, quotes)
    # ensure mission 1 and 2 badges make sense
    seeds[0]["badge"] = seeds[0].get("badge") or "training_clear"
    if "badge" not in seeds[1]:
        seeds[1]["badge"] = "first_mission_clear"
    seeds[6]["badge"] = "boss_clear"
    add_world(
        **{
            "class": cls, "id": wid, "file": file, "prefix": prefix, "npc": npc_id,
            "doc": doc, "name": name, "workplace": workplace, "role": role, "shift": shift,
            "supervisor": supervisor, "tagline": tagline, "skills": skill_list,
            "titles": titles, "locations": locations, "npcs": npcs, "seeds": seeds,
        }
    )

# MEDICINE
make_arc_world(
    "MedicineWorld", "medicine", "medicine_world.dart", "med", "shah",
    "Diagnostic Ward — Medical Student.",
    "Diagnostic Ward", "Riverside Med · Teaching Ward", "Medical Student", "6:30 AM – 6:30 PM",
    "Dr. Anika Shah", "Hypotheses are cheap. Data is not.",
    skills("CareerSkillId.diagnosis","CareerSkillId.clinicalKnowledge","CareerSkillId.criticalThinking","CareerSkillId.communication","CareerSkillId.timeManagement","CareerSkillId.ethics"),
    ["MS1 Shadow","Clinical Beginner","Junior Clerk","Sub-Intern","Acting Intern","Resident Track","Chief Candidate"],
    [
        loc("ward","Teaching Ward","Rounds and chalk talks.","🏥"),
        loc("clinic","Clinic","Outpatient puzzles.","🩺"),
        loc("lab","Lab Results","CBC, BMP, cultures.","🧪"),
        loc("imaging","Imaging","CXR and CT.","📷"),
        loc("sim","Sim Lab","Safe failure space.","🎯"),
        loc("icu_med","ICU","Higher acuity.","🔒",4,"Reach Career Level 4."),
        loc("er_med","ED Consult","Rapid differentials.","🔒",5,"Reach Career Level 5."),
        loc("or_med","OR Observation","Peri-op learning.","🔒",6,"Reach Career Level 6."),
    ],
    [
        npc("shah","Dr. Anika Shah","Attending","Socratic, intolerant of guessing.","👩‍⚕️"),
        npc("pt_sob","Ms. Ortiz","Patient","Short of breath, scared.","👩"),
        npc("nurse_m","RN Patel","Nurse","Knows the floor.","🧑‍⚕️"),
        npc("resident","Dr. Cole","Resident","Expects clean presentations.","👨‍⚕️"),
        npc("family_m","Mr. Ortiz","Family","Wants certainty now.","👨"),
        npc("radiologist","Dr. Ng","Radiology","Hates vague asks.","🧑‍⚕️"),
    ],
    ["sim","ward","clinic","lab","ward","icu_med","er_med"],
    "CareerSkillId.diagnosis", "12-HOUR CALL",
    [
        ("Mission 01 — Training Rounds","Learn presentation structure.","Complete supervised presentation.",
         "How do you present the sim case?","SOAP: data then assessment then plan","Guess the diagnosis dramatically"),
        ("Mission 02 — First Patient SOB","Ms. Ortiz is dyspneic.","Stabilize assessment for SOB.",
         "SpO2 88% on room air. First action?","Apply O2 per protocol, reassess, call for help","Tell her it is only anxiety"),
        ("Mission 03 — Diagnostic Workup","Choose high-yield tests.","Order a coherent workup.",
         "Suspected PE risk — next best step?","Validated score then indicated testing","Order every test in the catalog"),
        ("Mission 04 — Emergency Dx","Conflicting vitals in ED.","Make a safe emergency differential.",
         "Hypotension + fever. Priority?","Sepsis thinking + source hunt + escalate","Discharge because labs look almost normal"),
        ("Mission 05 — Conflicting Info","Chart vs family disagree.","Reconcile conflicting information.",
         "Family reports penicillin anaphylaxis; chart says none.","Hold drug, verify, document","Give penicillin to prove family wrong"),
        ("Mission 06 — Multi-patient Crisis","Two crashing patients.","Prioritize multi-patient crisis.",
         "Both rooms alarm. Who first?","Unresponsive hypotensive first; assign help to the other","Hide at the desk"),
        ("Mission 07 — BOSS: 12-HOUR CALL","Own the night call.","Survive 12-HOUR CALL with clean handoffs.",
         "Cross-cover: chest pain 10/10.","Bedside now; ECG; activate pathway","Order meds from home without assessment"),
    ],
    ["oxygen","assess","sepsis","pe","allergy","handoff","ecg","plan"],
    ['"SOAP is discipline."','"Airway before cleverness."','"Every test needs a why."','"Sick or not sick — say it."','"Verify before you act."','"Acuity first."','"Tired is not an excuse for careless."'],
)

# BUSINESS
make_arc_world(
    "BusinessWorld", "business", "business_world.dart", "biz", "reed",
    "Company HQ — Junior Business Analyst.",
    "Company HQ", "Northline Ventures", "Junior Business Analyst", "9:00 AM – 6:30 PM",
    "Director Maya Reed", "Protect the company. Then grow it.",
    skills("CareerSkillId.strategy","CareerSkillId.analysis","CareerSkillId.communication","CareerSkillId.risk","CareerSkillId.timeManagement","CareerSkillId.ethics"),
    ["Analyst Intern","Junior Analyst","Analyst","Senior Analyst","Strategy Lead","Principal","Director Track"],
    [
        loc("hq","HQ Lobby","Badge-in and all-hands.","🏢"),
        loc("warroom","Strategy War Room","Whiteboards and burn rates.","📊"),
        loc("ops","Ops Floor","Fulfillment and tickets.","⚙️"),
        loc("hr","People Ops","Employee crises.","👥"),
        loc("finance_b","Finance Pair","Cash and forecasts.","💹"),
        loc("board","Board Room","High-stakes decisions.","🔒",4,"Reach Career Level 4."),
        loc("launch","Launch Hub","Go-to-market desk.","🚀",5,"Reach Career Level 5."),
        loc("crisis_b","Crisis Bridge","Incident command.","🔒",6,"Reach Career Level 6."),
    ],
    [
        npc("reed","Maya Reed","Director","Calm under fire, allergic to vanity metrics.","👩‍💼"),
        npc("ceo","Chris Okonkwo","CEO","Visionary, sometimes impatient.","👨‍💼"),
        npc("eng_lead","Priya Nair","Eng Lead","Protects quality and people.","👩‍💻"),
        npc("sales","Luis Romero","Sales","Optimistic, hates friction.","🧑"),
        npc("hr_lead","Dana Cho","HR","Fair, documentation-first.","👩"),
        npc("investor","Alex Quinn","Board Observer","Numbers over narratives.","🧔"),
    ],
    ["hq","warroom","launch","hr","board","finance_b","crisis_b"],
    "CareerSkillId.strategy", "RUN THE COMPANY",
    [
        ("Mission 01 — Training","Learn the KPI board and decision rights.","Complete company orientation.",
         "CEO asks for a vanity metric slide. What do you do?","Show leading indicators tied to cash and retention","Inflate vanity metrics to please the room"),
        ("Mission 02 — Save the Company","Churn spike threatens runway.","Propose a save-the-company plan.",
         "Churn up 18%. First move?","Segment root causes; protect core customers; cut burn surgically","Freeze all spending blindly including revenue ops"),
        ("Mission 03 — Launch Product","Ship a risky feature.","Launch without breaking trust.",
         "Feature is 80% ready. Launch?","Soft launch + kill criteria + support staffing","Force full launch with known data-loss bug"),
        ("Mission 04 — Employee Crisis","Star performer accused of harassment.","Handle employee crisis lawfully.",
         "What do you do first?","Separate parties, open confidential process with HR","Ignore it to protect this quarter's launch"),
        ("Mission 05 — Advanced Strategy","Enter a new market.","Choose a defensible strategy.",
         "Board wants expansion. Best path?","Test beachhead with unit economics model","Copy competitor pricing with no cost model"),
        ("Mission 06 — Cash Crisis","Payroll in 10 days; cash thin.","Navigate cash crisis.",
         "Priority?","13-week cash forecast + negotiate payables + protect payroll","Hide the shortfall from the board"),
        ("Mission 07 — BOSS: RUN THE COMPANY","You are acting GM for a week.","RUN THE COMPANY through competing crises.",
         "Product outage + PR storm + investor call collide.","Stabilize customers first; factual PR; prepare investor truth pack","Blame an intern publicly and deny the outage"),
    ],
    ["churn","cash","launch","risk","customer","forecast","payroll","plan"],
    ['"Protect the company first."','"Root cause beats panic."','"Ship quality, not theater."','"People issues are company issues."','"Economics or it is cosplay."','"Cash is oxygen."','"Own the truth under pressure."'],
)

# FINANCE
make_arc_world(
    "FinanceWorld", "finance", "finance_world.dart", "fin", "hale",
    "Markets Desk — Junior Financial Analyst.",
    "Markets Desk", "Apex Capital", "Junior Financial Analyst", "7:00 AM – 5:00 PM",
    "VP Nora Hale", "Price risk honestly.",
    skills("CareerSkillId.analysis","CareerSkillId.risk","CareerSkillId.modeling","CareerSkillId.accuracy","CareerSkillId.communication","CareerSkillId.ethics"),
    ["Desk Intern","Junior Analyst","Analyst","Senior Analyst","Associate","VP Track","Portfolio Lead"],
    [
        loc("desk","Trading Floor","Screens and noise.","📈"),
        loc("model","Model Room","DCF and scenarios.","🧮"),
        loc("client_f","Client Suite","Portfolio reviews.","🤝"),
        loc("risk_f","Risk Office","Limits and VaR.","⚠️"),
        loc("research_f","Research","Filings and notes.","📄"),
        loc("macro","Macro Hub","Rates and shocks.","🌍",4,"Reach Career Level 4."),
        loc("war_f","War Room","Crisis trading.","🔒",5,"Reach Career Level 5."),
        loc("board_f","Investment Committee","Final calls.","🔒",6,"Reach Career Level 6."),
    ],
    [
        npc("hale","Nora Hale","VP","Precise, allergic to hopeium.","👩‍💼"),
        npc("pm","Evan Brooks","Portfolio Manager","Decisive under stress.","👨‍💼"),
        npc("client_f","Ms. Patel","Client","Wants upside without pain.","👩"),
        npc("risk_off","Omar Diaz","Risk Officer","Enforces limits.","🧔"),
        npc("trader","Jin Park","Trader","Fast, blunt.","🧑"),
        npc("cfo_ext","External CFO","Corp Finance","Needs clean comps.","👨"),
    ],
    ["desk","model","client_f","research_f","macro","war_f","board_f"],
    "CareerSkillId.risk", "MARKET CRISIS",
    [
        ("Mission 01 — Portfolio Basics","Learn mandates and risk limits.","Complete desk orientation.",
         "Client wants a concentrated bet outside mandate.","Stay inside mandate; propose sized alternative","Break the mandate for short-term alpha"),
        ("Mission 02 — Build Portfolio","Construct a first model portfolio.","Deliver a risk-aware portfolio.",
         "How do you size positions?","Risk budget + correlation-aware sizing","Max leverage on your favorite ticker"),
        ("Mission 03 — Corporate Finance","Advise on a capital raise.","Recommend financing structure.",
         "Growth co needs capital. Best framing?","Compare dilution, covenants, and runway scenarios","Recommend whatever maximizes your banking fee fantasy"),
        ("Mission 04 — Personal Finance Advisory","Client panic-sells.","Coach through volatility ethically.",
         "Markets down 12%. Client wants out of everything.","Revisit goals/horizon; staged plan; no product dump","Push high-fee product while they are scared"),
        ("Mission 05 — Market Pressure","Earnings miss hits a top holding.","Respond under market pressure.",
         "Thesis broken or noise?","Re-underwrite thesis with fresh numbers","Average down with no thesis update"),
        ("Mission 06 — Liquidity Stress","Redemptions spike.","Manage liquidity stress.",
         "Priority?","Liquidity ladder + communicate constraints truthfully","Hide gates and hope flows reverse"),
        ("Mission 07 — BOSS: MARKET CRISIS","Crash day. Own the desk response.","Survive MARKET CRISIS with intact process.",
         "Flash crash + client margin call + limit breach.","Protect clients within limits; escalate breaches; document","Disable risk system alerts to keep trading"),
    ],
    ["risk","mandate","liquidity","thesis","horizon","limit","scenario","plan"],
    ['"Mandates are law."','"Size is a decision."','"Structure follows need."','"Fear is not a strategy."','"Re-underwrite or exit."','"Liquidity is oxygen."','"Process under fire."'],
)

# ACCOUNTING
make_arc_world(
    "AccountingWorld", "accounting", "accounting_world.dart", "acct", "moss",
    "Controller Suite — Junior Accountant.",
    "Controller Suite", "Fairfield Manufacturing", "Junior Accountant", "8:00 AM – 5:30 PM",
    "Controller Helen Moss", "If it is not supported, it is not real.",
    skills("CareerSkillId.accuracy","CareerSkillId.analysis","CareerSkillId.investigation","CareerSkillId.ethics","CareerSkillId.communication","CareerSkillId.timeManagement"),
    ["Bookkeeping Intern","Junior Accountant","Staff Accountant","Senior Accountant","Supervisor","Assistant Controller","Controller Track"],
    [
        loc("ap","AP Desk","Invoices and vendors.","🧾"),
        loc("ar","AR Desk","Collections and credit.","💵"),
        loc("gl","General Ledger","Close checklists.","📚"),
        loc("close","Close Room","Month-end crunch.","🗓️"),
        loc("audit","Audit Room","PBC lists.","🔍"),
        loc("fp_a","FP&A Pair","Forecast bridge.","📊",4,"Reach Career Level 4."),
        loc("vault","Records Vault","Source docs.","🔒",5,"Reach Career Level 5."),
        loc("exec_a","Exec Review","Numbers under fire.","🔒",6,"Reach Career Level 6."),
    ],
    [
        npc("moss","Helen Moss","Controller","Exacting, fair.","👩‍💼"),
        npc("auditor","Greg Lang","External Auditor","Polite, relentless.","🧔"),
        npc("ap_clerk","Tina Wu","AP Clerk","Fast, sometimes messy.","👩"),
        npc("ops_mgr","Ray Cole","Ops Manager","Hates paperwork.","👨"),
        npc("cfo_a","CFO Rivera","CFO","Wants clean closes.","👩‍💼"),
        npc("vendor","Vendor Rep","Vendor","Pushy on payment.","🧑"),
    ],
    ["ap","gl","close","vault","audit","fp_a","exec_a"],
    "CareerSkillId.accuracy", "THE AUDIT",
    [
        ("Mission 01 — Bookkeeping","Learn coding and controls.","Post clean training entries.",
         "Expense lacks receipt. Post anyway?","Hold and request support","Post to clear the queue"),
        ("Mission 02 — Statements","Draft first statements.","Produce balanced statements.",
         "Trial balance off by $2,400.","Investigate tie-outs before publishing","Force a plug to make it balance"),
        ("Mission 03 — Discrepancy","Inventory variance appears.","Resolve discrepancy with evidence.",
         "Books vs count disagree.","Cycle count + cut-off testing + document","Quietly adjust to match ops preference"),
        ("Mission 04 — Audit Investigation","Auditor finds odd journal.","Investigate without obstruction.",
         "Unusual manual JE. Next?","Pull support, interview preparer, escalate if needed","Delete the entry before auditors see it"),
        ("Mission 05 — Revenue Timing","Pressure to pull revenue early.","Defend proper revenue recognition.",
         "Sales wants to recognize unsigned deals.","Recognize only when criteria met","Book it to hit bonus targets"),
        ("Mission 06 — Close Crisis","Systems down on close day.","Survive close crisis.",
         "Priority?","Control-preserving workaround + disclose delays","Skip reconciliations to finish on time"),
        ("Mission 07 — BOSS: THE AUDIT","External audit crunch week.","Clear THE AUDIT with integrity.",
         "Material weakness rumor + missing PBCs.","Prioritize high-risk samples; transparent status; fix controls","Coach staff to give misleading answers"),
    ],
    ["support","reconcile","control","evidence","disclose","cutoff","balance","audit"],
    ['"Support or it did not happen."','"Never plug."','"Evidence beats opinion."','"Do not obstruct."','"Criteria before targets."','"Controls over speed."','"Transparency survives audits."'],
)

# MARKETING
make_arc_world(
    "MarketingWorld", "marketing", "marketing_world.dart", "mkt", "vega",
    "Brand Studio — Junior Marketing Strategist.",
    "Brand Studio", "Lumen Creative", "Junior Marketing Strategist", "10:00 AM – 7:00 PM",
    "Creative Director Sol Vega", "Clarity converts. Gimmicks fade.",
    skills("CareerSkillId.creativity","CareerSkillId.strategy","CareerSkillId.analysis","CareerSkillId.communication","CareerSkillId.research","CareerSkillId.ethics"),
    ["Coordinator","Junior Strategist","Strategist","Senior Strategist","Brand Lead","Group Lead","Director Track"],
    [
        loc("studio","Studio","Concepts on the wall.","🎨"),
        loc("briefing","Briefing Room","Client truths.","📋"),
        loc("analytics","Analytics","Funnels and CAC.","📉"),
        loc("social","Social Desk","Live posts.","📱"),
        loc("prod","Production","Assets and deadlines.","🎬"),
        loc("test","Experiment Lab","A/B tests.","🧪",4,"Reach Career Level 4."),
        loc("war_m","Launch War Room","Go-live chaos.","🚀",5,"Reach Career Level 5."),
        loc("client_m","Client Boardroom","Rescue meetings.","🔒",6,"Reach Career Level 6."),
    ],
    [
        npc("vega","Sol Vega","Creative Director","Tasteful, blunt.","🧑‍🎨"),
        npc("client_brand","Jordan Lee","Client","Anxious about share.","👩‍💼"),
        npc("analyst_m","Casey Ng","Analyst","Loves clean tests.","🧑‍💻"),
        npc("copy","Riley Adams","Copy Lead","Word-obsessed.","✍️"),
        npc("media","Samir Khan","Media Buyer","Budget hawk.","🧔"),
        npc("legal_m","Pat Ortiz","Brand Legal","Claims police.","👩"),
    ],
    ["briefing","studio","test","war_m","analytics","social","client_m"],
    "CareerSkillId.creativity", "CAMPAIGN RESCUE",
    [
        ("Mission 01 — Client Brief","Decode a messy brief.","Write a clear strategy problem.",
         "Client brief is vague and contradictory.","Interview for jobs-to-be-done and success metrics","Invent a flashy campaign with no problem statement"),
        ("Mission 02 — Campaign Build","Build channel plan and creative platform.","Ship a coherent campaign build.",
         "Budget tight. Where to focus?","Highest-intent channels + one bold creative idea","Spray spend across every network"),
        ("Mission 03 — Launch Monitor","Campaign live; metrics uneven.","Monitor and iterate.",
         "CTR high, conversion low.","Diagnose landing friction; pause waste","Scale spend blindly on CTR"),
        ("Mission 04 — Claim Risk","Legal flags a claim.","Protect brand truth.",
         "Hero claim is unsubstantiated.","Rewrite to supported claim; refresh assets","Run the claim anyway for conversion"),
        ("Mission 05 — Competitive Shock","Competitor drops a viral hit.","Respond strategically.",
         "Best response?","Differentiate on proof, not panic copycats","Clone their campaign overnight"),
        ("Mission 06 — Launch Crisis","Tracking breaks on launch day.","Stabilize launch crisis.",
         "Priority?","Fix measurement; hold budget; communicate","Keep spending dark and guess"),
        ("Mission 07 — BOSS: CAMPAIGN RESCUE","Client threatens to pull the account.","Execute CAMPAIGN RESCUE.",
         "Performance down, trust down.","Truthful postmortem + 2-week test plan + creative reset","Blame the algorithm and promise magic"),
    ],
    ["brief","metric","claim","test","convert","audience","budget","plan"],
    ['"Name the problem."','"Focus beats spray."','"Diagnose before you scale."','"Claims need proof."','"Differentiate, do not clone."','"Measure or stop."','"Rescue with truth."'],
)

# ECONOMICS
make_arc_world(
    "EconomicsWorld", "economics", "economics_world.dart", "econ", "okada",
    "Policy Unit — Economic Policy Analyst.",
    "Policy Unit", "National Policy Institute", "Economic Policy Analyst", "9:00 AM – 6:00 PM",
    "Dr. Leila Okada", "Tradeoffs are the work.",
    skills("CareerSkillId.analysis","CareerSkillId.modeling","CareerSkillId.research","CareerSkillId.communication","CareerSkillId.ethics","CareerSkillId.strategy"),
    ["Research Aide","Junior Analyst","Policy Analyst","Senior Analyst","Advisor","Principal","Director Track"],
    [
        loc("office","Policy Office","Memos and models.","🏛️"),
        loc("data","Data Lab","Series and shocks.","📊"),
        loc("brief_e","Briefing Room","Principals waiting.","🗣️"),
        loc("field","Field Survey","Ground truth.","🗺️"),
        loc("sim_e","Macro Sim","Counterfactuals.","🧮"),
        loc("press","Press Desk","Public narrative.","📰",4,"Reach Career Level 4."),
        loc("cabinet","Cabinet Prep","High-stakes brief.","🔒",5,"Reach Career Level 5."),
        loc("crisis_e","Crisis Cell","National emergency desk.","🔒",6,"Reach Career Level 6."),
    ],
    [
        npc("okada","Dr. Leila Okada","Supervisor","Rigorous, calm.","👩‍🏫"),
        npc("minister","Minister Shaw","Principal","Political clock ticking.","👨‍💼"),
        npc("stat","Stat Chief","Data","Obsessed with revisions.","🧑‍🔬"),
        npc("union","Union Rep","Stakeholder","Jobs first.","🧔"),
        npc("biz_e","Chamber Lead","Business","Costs first.","👩‍💼"),
        npc("journalist","Rina Cole","Press","Wants a simple story.","📰"),
    ],
    ["office","data","sim_e","brief_e","press","cabinet","crisis_e"],
    "CareerSkillId.analysis", "NATIONAL ECONOMIC CRISIS",
    [
        ("Mission 01 — Training","Learn memo standards.","Complete policy desk training.",
         "Principal wants a one-sided memo.","Present options with tradeoffs and evidence","Write only the politically convenient recommendation"),
        ("Mission 02 — Inflation Response","Inflation sticky.","Advise on inflation response.",
         "First analytical move?","Decompose drivers; avoid one-tool dogma","Blame one group with no data"),
        ("Mission 03 — Tradeoffs","Stimulus vs inflation risk.","Make tradeoffs explicit.",
         "How do you frame it?","Show distributional impacts and time paths","Promise no tradeoffs exist"),
        ("Mission 04 — Trade Shock","Tariff proposal lands.","Analyze trade shock.",
         "Best approach?","Partial equilibrium + affected sectors + retaliation risk","Ignore second-order effects"),
        ("Mission 05 — Conflicting Forecasts","Models disagree.","Reconcile conflicting forecasts.",
         "What do you do?","Explain assumptions; present range; recommend hedges","Pick the rosy model quietly"),
        ("Mission 06 — Confidence Crisis","Markets lose confidence.","Advise under confidence crisis.",
         "Priority communication?","Clear, consistent, data-backed plan","Surprise markets with opaque moves"),
        ("Mission 07 — BOSS: NATIONAL ECONOMIC CRISIS","Currency stress + inflation + jobs scare.","Steer NATIONAL ECONOMIC CRISIS briefing.",
         "Cabinet wants a silver bullet.","Sequence tools; protect credibility; show tradeoffs","Promise painless miracles on TV"),
    ],
    ["tradeoff","inflation","evidence","model","sector","credibility","range","plan"],
    ['"Tradeoffs on the page."','"Decompose before you prescribe."','"Name the losers too."','"Second-order matters."','"Assumptions out loud."','"Credibility is policy."','"No silver bullets."'],
)

# CS
make_arc_world(
    "CsCareerWorld", "cs_career", "cs_career_world.dart", "cs", "nova",
    "Engineering Floor — Junior Software Engineer.",
    "Engineering Floor", "Stackwright", "Junior Software Engineer", "10:00 AM – 7:00 PM",
    "Eng Manager Avery Nova", "Ship safely. Then ship fast.",
    skills("CareerSkillId.analysis","CareerSkillId.investigation","CareerSkillId.design","CareerSkillId.communication","CareerSkillId.timeManagement","CareerSkillId.security"),
    ["Intern Dev","Junior Engineer","Engineer","Senior Engineer","Staff Track","Tech Lead","Principal Track"],
    [
        loc("desk_c","Dev Desk","IDE and coffee.","💻"),
        loc("pr","PR Review","Diffs and nits.","🔀"),
        loc("staging","Staging","Almost prod.","🧪"),
        loc("prod","Prod Bridge","On-call board.","🚨"),
        loc("arch","Architecture Room","Design docs.","📐"),
        loc("sec","Sec Review","Threat models.","🔒",4,"Reach Career Level 4."),
        loc("war_c","Incident War Room","Sev-1 chaos.","🧯",5,"Reach Career Level 5."),
        loc("launch_c","Launch Bridge","Launch Day.","🚀",6,"Reach Career Level 6."),
    ],
    [
        npc("nova","Avery Nova","Eng Manager","Blameless, high bar.","🧑‍💻"),
        npc("sre","Morgan Lee","SRE","Uptime zealot.","👩‍💻"),
        npc("pm_c","Chris Vale","PM","Scope creep artist.","🧔"),
        npc("sec_c","Dana Ruiz","Security","Threat-minded.","👩"),
        npc("qa","Sam Patel","QA","Finds the weird bugs.","🧑"),
        npc("customer_c","Support Lead","Support","Customer voice.","📞"),
    ],
    ["desk_c","pr","staging","prod","arch","war_c","launch_c"],
    "CareerSkillId.investigation", "LAUNCH DAY",
    [
        ("Mission 01 — Fix Bug","Reproduce and fix a customer bug.","Ship a correct bugfix.",
         "Bug not reproducible locally.","Gather logs, reproduce in staging, write regression test","Push a speculative fix to prod"),
        ("Mission 02 — Build Feature","Deliver a scoped feature.","Build feature with clean design.",
         "PM doubles scope mid-sprint.","Negotiate MVP; document cut line","Accept infinite scope silently"),
        ("Mission 03 — Code Review","Review a risky PR.","Catch a real defect in review.",
         "PR looks clever but skips authz check.","Block for security fix + tests","Approve to be nice"),
        ("Mission 04 — Production Incident","Latency spike in prod.","Mitigate production incident.",
         "First move?","Stabilize (rollback/feature flag), then diagnose","Keep experimenting on prod traffic"),
        ("Mission 05 — Design Review","Propose a scalable design.","Pass design review.",
         "How do you handle failure modes?","Explicit SLOs, retries, idempotency, backpressure","Assume happy path only"),
        ("Mission 06 — Sev-1 Crisis","Data corruption reports.","Lead sev-1 response.",
         "Priority?","Stop the bleed; preserve forensics; communicate","Overwrite logs to hide the mistake"),
        ("Mission 07 — BOSS: LAUNCH DAY","Flagship launch under load.","Survive LAUNCH DAY.",
         "Error budget burning + press demo live.","Throttle noncritical; keep core path; honest status","Disable alerts and hope"),
    ],
    ["reproduce","rollback","test","security","slo","incident","flag","plan"],
    ['"Reproduce first."','"Scope is a product."','"Security is not optional."','"Stabilize then dig."','"Design for failure."','"Preserve evidence."','"Launch with a brake pedal."'],
)

# PSYCHOLOGY
make_arc_world(
    "PsychologyWorld", "psychology", "psychology_world.dart", "psy", "brook",
    "Behavioral Lab — Research Assistant.",
    "Behavioral Lab", "Harbor University Psych Lab", "Research Assistant", "9:00 AM – 5:00 PM",
    "Dr. Naomi Brook", "Methods before stories.",
    skills("CareerSkillId.research","CareerSkillId.experimentation","CareerSkillId.analysis","CareerSkillId.ethics","CareerSkillId.communication","CareerSkillId.accuracy"),
    ["RA Trainee","Research Assistant","Senior RA","Lab Coordinator","Junior Analyst","Analyst","PhD Track"],
    [
        loc("lab_p","Behavioral Lab","Booths and cameras.","🧠"),
        loc("interview","Interview Room","Structured protocols.","🎙️"),
        loc("ethics_p","IRB Office","Consent and risk.","📜"),
        loc("stats","Stats Desk","Power and prereg.","📐"),
        loc("coding","Coding Bay","Reliability checks.","💻"),
        loc("colloq","Colloquium","Present findings.","🎤",4,"Reach Career Level 4."),
        loc("field_p","Field Site","External samples.","🔒",5,"Reach Career Level 5."),
        loc("grant","Grant War Room","Big project pitch.","🔒",6,"Reach Career Level 6."),
    ],
    [
        npc("brook","Dr. Naomi Brook","PI","Methodological hawk.","👩‍🏫"),
        npc("participant","Alex M.","Participant","Curious, cautious.","🧑"),
        npc("irb","IRB Chair","Ethics","Protects participants.","🧔"),
        npc("grad","Jamie Ortiz","Grad Student","Stressed, helpful.","👩"),
        npc("coder","Riley Chen","Coder","Obsessed with kappa.","🧑‍💻"),
        npc("reviewer","External Reviewer","Reviewer","Skeptical.","👨‍🏫"),
    ],
    ["lab_p","interview","ethics_p","stats","coding","colloq","grant"],
    "CareerSkillId.research", "RESEARCH PROJECT",
    [
        ("Mission 01 — Protocol Training","Learn consent and debrief.","Complete lab protocol training.",
         "Participant looks confused mid-consent.","Pause, re-explain, confirm understanding","Rush them through to hit quota"),
        ("Mission 02 — Behavioral Interview","Run a structured interview.","Complete behavioral interview cleanly.",
         "Participant digresses emotionally.","Acknowledge, return to protocol, offer break/stop","Probe trauma off-protocol for interesting quotes"),
        ("Mission 03 — Experiment Design","Design a clean study.","Produce an experiment design.",
         "How do you reduce confounds?","Randomize, control, preregister, power analysis","HARKing after peeking at data"),
        ("Mission 04 — Data Quality","Coders disagree.","Restore coding reliability.",
         "Best next step?","Retrain with codebook; measure kappa; adjudicate","Force agreement to fake reliability"),
        ("Mission 05 — Unexpected Result","Null result threatens narrative.","Handle unexpected results ethically.",
         "What do you do?","Report transparently; explore robustness; avoid spinning","Quietly drop conditions that hurt the story"),
        ("Mission 06 — Ethics Crisis","Consent form outdated.","Handle ethics crisis.",
         "Priority?","Halt affected runs; notify IRB; remediate","Continue collecting to save the timeline"),
        ("Mission 07 — BOSS: RESEARCH PROJECT","Capstone project under review.","Deliver RESEARCH PROJECT with integrity.",
         "Reviewer alleges p-hacking.","Open materials, show prereg, correct course","Attack the reviewer personally"),
    ],
    ["consent","protocol","preregister","kappa","transparent","irb","power","ethics"],
    ['"Consent is ongoing."','"Protocol is protection."','"Design before data."','"Reliability is earned."','"Nulls are data."','"Stop when ethics require it."','"Openness survives review."'],
)

# BIOLOGY
make_arc_world(
    "BiologyWorld", "biology", "biology_world.dart", "bio", "kent",
    "Biology Lab — Lab Student.",
    "Biology Lab", "Harbor University Bio Labs", "Biology Lab Student", "1:00 PM – 5:00 PM",
    "Prof. Maren Kent", "Observe before you conclude.",
    skills("CareerSkillId.experimentation","CareerSkillId.research","CareerSkillId.accuracy","CareerSkillId.analysis","CareerSkillId.communication","CareerSkillId.ethics"),
    ["Lab Novice","Lab Student","Skilled Technician","Research Aide","Senior Aide","Lab Lead","Investigator Track"],
    [
        loc("bench","Wet Bench","Pipettes and protocols.","🧫"),
        loc("micro","Microscopy","Light and focus.","🔬"),
        loc("geno","Genetics Bay","Gels and markers.","🧬"),
        loc("eco","Ecology Corner","Samples from field.","🌿"),
        loc("cell","Cell Culture","Sterile technique.","🦠"),
        loc("cold","Cold Storage","Reagents and stocks.","🧊",4,"Reach Career Level 4."),
        loc("field_b","Field Site","Mud and notebooks.","🔒",5,"Reach Career Level 5."),
        loc("mystery","Mystery Bench","Unknown specimen.","🔒",6,"Reach Career Level 6."),
    ],
    [
        npc("kent","Prof. Maren Kent","PI","Patient, exacting.","👩‍🏫"),
        npc("ta_b","TA Jordan","TA","Helpful, watches sterile technique.","🧑"),
        npc("partner_b","Lab Partner Lee","Partner","Fast, sometimes careless.","👩"),
        npc("tech_b","Core Tech Sam","Core Facility","Protects instruments.","🧔"),
        npc("ecologist","Dr. Imani","Ecologist","Systems thinker.","👩‍🔬"),
        npc("safety_b","Safety Officer","Safety","No shortcuts.","🦺"),
    ],
    ["bench","micro","geno","eco","cell","field_b","mystery"],
    "CareerSkillId.experimentation", "MYSTERY SPECIMEN",
    [
        ("Mission 01 — Microscopy","Learn focus and documentation.","Complete microscopy training.",
         "Image is blurry and partner wants to guess ID.","Refocus, calibrate scale, document carefully","Guess species from a blurry image"),
        ("Mission 02 — Genetics","Run a simple gel.","Complete genetics lab cleanly.",
         "Ladder looks wrong.","Stop, check reagents/loading, repeat controls","Keep going and invent band sizes"),
        ("Mission 03 — Ecology","Analyze field samples.","Produce ecology observations.",
         "Sample labels mixed in transit.","Quarantine ambiguous samples; resample if needed","Force labels to match your hypothesis"),
        ("Mission 04 — Cell Biology","Culture contamination risk.","Protect cell culture integrity.",
         "Smell suggests contamination.","Isolate, discard properly, review sterile steps","Ignore it to save cells"),
        ("Mission 05 — Conflicting Assays","Two assays disagree.","Reconcile conflicting assays.",
         "Best path?","Check controls, replicates, and method limits","Cherry-pick the assay you like"),
        ("Mission 06 — Field Crisis","Storm ruins plots.","Handle ecology crisis.",
         "Priority?","Safety first; salvage protocol; document loss","Fake missing data points"),
        ("Mission 07 — BOSS: MYSTERY SPECIMEN","Unknown organism on deadline.","Solve MYSTERY SPECIMEN rigorously.",
         "Pressure to name it now.","Systematic tests + differential + uncertainty statement","Announce a species for the press"),
    ],
    ["control","document","sterile","replicate","label","safety","uncertain","observe"],
    ['"Focus then claim."','"Controls tell truth."','"Labels are data."','"Sterile or stop."','"Disagree? Verify."','"Safety over plots."','"Uncertainty is scientific."'],
)

# CHEMISTRY
make_arc_world(
    "ChemistryWorld", "chemistry", "chemistry_world.dart", "chem", "ross",
    "Chemistry Lab — Lab Student.",
    "Chemistry Lab", "Harbor University Chem Labs", "Chemistry Lab Student", "1:00 PM – 5:00 PM",
    "Prof. Elise Ross", "Measure twice. React once.",
    skills("CareerSkillId.experimentation","CareerSkillId.accuracy","CareerSkillId.analysis","CareerSkillId.risk","CareerSkillId.communication","CareerSkillId.research"),
    ["Lab Novice","Lab Student","Analyst","Senior Analyst","Method Lead","Lab Specialist","Research Chemist Track"],
    [
        loc("hood","Fume Hood","Reactions under control.","🧪"),
        loc("titration","Titration Bench","Endpoints and burets.","💧"),
        loc("balance","Balance Room","Mass matters.","⚖️"),
        loc("spec","Spectroscopy","Peaks and purity.","📡"),
        loc("org","Organic Bay","Setup and workup.","🔥"),
        loc("waste","Waste Station","Dispose right.","🗑️",3,"Reach Career Level 3."),
        loc("instrument","Instrument Lab","GC/MS access.","🔒",5,"Reach Career Level 5."),
        loc("unknown_c","Unknown Bench","Unknown compound.","🔒",6,"Reach Career Level 6."),
    ],
    [
        npc("ross","Prof. Elise Ross","PI","Safety-first perfectionist.","👩‍🏫"),
        npc("ta_c","TA Priya","TA","Watches PPE.","👩"),
        npc("partner_c","Lab Partner Max","Partner","Impatient.","👨"),
        npc("stock","Stockroom Alex","Stockroom","Inventory hawk.","🧑"),
        npc("instrument_c","Dr. Cho","Instruments","Protects columns.","🧔"),
        npc("safety_c","Safety Officer","Safety","Evacuation ready.","🦺"),
    ],
    ["hood","titration","balance","spec","org","instrument","unknown_c"],
    "CareerSkillId.accuracy", "UNKNOWN COMPOUND",
    [
        ("Mission 01 — Reaction Setup","PPE and stoichiometry.","Complete reaction training.",
         "Partner skips goggles for a quick pour.","Stop work; enforce PPE; reset","Look away and keep timing"),
        ("Mission 02 — Titration","Hit a clean endpoint.","Complete titration accurately.",
         "Endpoint overshot.","Record, repeat properly with fresh aliquot","Fudge volume to match expected"),
        ("Mission 03 — Unknown Substance","Screen an unknown safely.","Identify class of unknown safely.",
         "First tests?","Physical props + spot tests with controls; no tasting myths","Heat unknown violently to see what happens"),
        ("Mission 04 — Organic Workup","Messy extraction.","Recover product cleanly.",
         "Emulsion forms.","Patient separation + drying + TLC check","Dump organic layer to save time"),
        ("Mission 05 — Spectra Conflict","NMR and IR disagree with hope.","Interpret spectra honestly.",
         "Peaks do not match desired product.","Propose actual structure/impurity path","Ignore peaks that ruin the story"),
        ("Mission 06 — Spill Crisis","Acid spill near aisle.","Handle lab spill crisis.",
         "Priority?","Alert, PPE, neutralize per SDS, report","Wipe with paper towels bare-handed"),
        ("Mission 07 — BOSS: UNKNOWN COMPOUND","Contest unknown under time.","Solve UNKNOWN COMPOUND safely.",
         "Final ID pressure.","Converging evidence + purity + uncertainty","Declare structure from one ambiguous peak"),
    ],
    ["ppe","endpoint","control","tlc","spectra","sds","purity","evidence"],
    ['"PPE is non-negotiable."','"Record the truth."','"Characterize safely."','"Patience in workup."','"Spectra do not care."','"SDS first."','"Converging evidence."'],
)

# PHYSICS
make_arc_world(
    "PhysicsWorld", "physics", "physics_world.dart", "phys", "hale_p",
    "Physics Lab — Lab Student.",
    "Physics Lab", "Harbor University Physics", "Physics Lab Student", "2:00 PM – 6:00 PM",
    "Prof. Theo Hale", "Model. Measure. Mismatch teaches.",
    skills("CareerSkillId.modeling","CareerSkillId.experimentation","CareerSkillId.analysis","CareerSkillId.accuracy","CareerSkillId.communication","CareerSkillId.criticalThinking"),
    ["Lab Novice","Lab Student","Analyst","Instrument Specialist","Modeling Aide","Research Aide","Engineer Physicist Track"],
    [
        loc("mech","Mechanics Bay","Tracks and timers.","⚙️"),
        loc("optics","Optics Bench","Lenses and interference.","🔦"),
        loc("waves","Waves Lab","Frequency and media.","🌊"),
        loc("compute","Compute Desk","Fits and residuals.","💻"),
        loc("shop","Student Shop","Fixtures and safety.","🛠️"),
        loc("adv","Advanced Lab","Vacuum and sensors.","🔒",4,"Reach Career Level 4."),
        loc("field_ph","Field Test","Real structures.","🔒",5,"Reach Career Level 5."),
        loc("fail","Failure Analysis","Broken systems.","🔒",6,"Reach Career Level 6."),
    ],
    [
        npc("hale_p","Prof. Theo Hale","PI","Loves residuals.","👨‍🏫"),
        npc("ta_p","TA Nora","TA","Error-bar enforcer.","👩"),
        npc("partner_p","Partner Kai","Partner","Rushes setups.","🧑"),
        npc("engineer_p","Eng Liaison","Engineer","Wants practical answers.","🧔"),
        npc("safety_p","Shop Safety","Safety","Locks out tools.","🦺"),
        npc("visitor","Industry Visitor","Sponsor","Deadline-driven.","👩‍💼"),
    ],
    ["mech","optics","waves","compute","shop","field_ph","fail"],
    "CareerSkillId.modeling", "ENGINEERING FAILURE",
    [
        ("Mission 01 — Mechanics","Measure g carefully.","Complete mechanics experiment.",
         "Data scatter looks ugly.","Propagate uncertainty; improve method; show residuals","Delete outliers until it looks perfect"),
        ("Mission 02 — Waves/Optics","Align an optics path.","Complete waves/optics lab.",
         "Fringes unstable.","Stabilize alignment; record conditions; estimate error","Invent fringe counts"),
        ("Mission 03 — Model Fit","Theory vs data disagree.","Reconcile model and measurement.",
         "Best move?","Check systematics; refine model assumptions","Force fit by changing constants randomly"),
        ("Mission 04 — Instrumentation","Sensor drift appears.","Diagnose instrument fault.",
         "Readings wander.","Calibrate against standard; log drift","Ignore calibration stickers"),
        ("Mission 05 — Design Constraint","Build a launch track under limits.","Optimize under constraints.",
         "How do you choose materials?","Model energy losses; test prototypes; safety factor","Overbuild blindly with no model"),
        ("Mission 06 — Field Failure","Bridge sensor network fails.","Respond to field failure.",
         "Priority?","Safe shutdown; preserve data; root-cause","Hotfix without isolation"),
        ("Mission 07 — BOSS: ENGINEERING FAILURE","Catastrophic prototype failure.","Lead ENGINEERING FAILURE analysis.",
         "Sponsor wants blame now.","Fault tree + evidence + redesign path","Name a junior without evidence"),
    ],
    ["uncertainty","residual","calibrate","model","safety","systematic","prototype","evidence"],
    ['"Uncertainty is part of the answer."','"Align, then claim."','"Mismatch teaches."','"Calibrate always."','"Model then build."','"Isolate first."','"Evidence before blame."'],
)

# ENGINEERING
make_arc_world(
    "EngineeringWorld", "engineering", "engineering_world.dart", "eng", "park_e",
    "Design Studio — Junior Engineer.",
    "Design Studio", "Forgeworks Engineering", "Junior Engineer", "9:00 AM – 6:00 PM",
    "Lead Engineer Mina Park", "Requirements first. Ego never.",
    skills("CareerSkillId.design","CareerSkillId.modeling","CareerSkillId.analysis","CareerSkillId.risk","CareerSkillId.communication","CareerSkillId.ethics"),
    ["CAD Intern","Junior Engineer","Engineer","Senior Engineer","Design Lead","Principal","Director Track"],
    [
        loc("studio_e","Design Studio","CAD and crits.","✏️"),
        loc("test_e","Test Bay","Prototypes break here.","🧪"),
        loc("mat","Materials","Specs and samples.","🧱"),
        loc("client_e","Client Room","Requirements fights.","🤝"),
        loc("fab","Fab Floor","Make it real.","🏭"),
        loc("sim_en","Simulation","FEA and CFD.","💻",4,"Reach Career Level 4."),
        loc("site_e","Site Visit","Constraints appear.","🔒",5,"Reach Career Level 5."),
        loc("review_e","Design Review Board","Boss challenge.","🔒",6,"Reach Career Level 6."),
    ],
    [
        npc("park_e","Mina Park","Lead Engineer","Blunt, protective of safety margins.","👩‍🔧"),
        npc("client_en","City Client","Client","Budget anxiety.","🧔"),
        npc("fab_lead","Omar","Fab Lead","Hates unbuildable CAD.","👨‍🏭"),
        npc("analyst_e","Sasha","Analyst","Loves FEA.","👩‍💻"),
        npc("intern_e","Devon","Intern","Eager.","🧑"),
        npc("inspector","Inspector Ruiz","Inspector","Code stickler.","👷"),
    ],
    ["studio_e","test_e","mat","sim_en","site_e","fab","review_e"],
    "CareerSkillId.design", "REAL-WORLD DESIGN CHALLENGE",
    [
        ("Mission 01 — Bridge Design Cycle","Learn requirements capture.","Complete design cycle training.",
         "Client changes load case mid-design.","Update requirements baseline; re-evaluate margins","Ignore change to keep schedule pretty"),
        ("Mission 02 — First Prototype","Build and test a beam model.","Learn from first prototype.",
         "Prototype fails early.","Instrument failure; iterate design","Hide failure photos from lead"),
        ("Mission 03 — Fail/Improve","Root-cause a fatigue crack.","Improve after failure.",
         "Best approach?","Failure analysis + redesign + retest plan","Add random material thickness and ship"),
        ("Mission 04 — Materials Tradeoff","Cost vs strength conflict.","Choose materials responsibly.",
         "Cheaper alloy available.","Check standards, corrosion, lifecycle cost","Switch secretly to save budget"),
        ("Mission 05 — Site Constraints","Unexpected utility line.","Adapt design to site.",
         "What do you do?","Stop dig; redesign around constraint; notify stakeholders","Keep digging and hope"),
        ("Mission 06 — Test Crisis","Critical load test tomorrow; fixture wrong.","Handle test crisis.",
         "Priority?","Delay safely; fix fixture; protect people","Run unsafe test to hit PR date"),
        ("Mission 07 — BOSS: REAL-WORLD DESIGN CHALLENGE","Live structure under review.","Win REAL-WORLD DESIGN CHALLENGE.",
         "Inspector flags margin concern.","Reanalyze; reinforce or derate; transparent report","Forge a passing certificate"),
    ],
    ["requirement","margin","iterate","standard","site","safety","retest","evidence"],
    ['"Requirements are the product."','"Failure is data."','"Root cause then redesign."','"Standards exist for reasons."','"Site reality wins."','"People over PR."','"Margins are ethics."'],
)

# MATHEMATICS
make_arc_world(
    "MathematicsWorld", "mathematics", "mathematics_world.dart", "math", "singh",
    "Analytics Desk — Math Analyst.",
    "Analytics Desk", "ParcelLogix", "Math Analyst", "9:30 AM – 5:30 PM",
    "Dr. Arjun Singh", "A wrong model is worse than no model.",
    skills("CareerSkillId.modeling","CareerSkillId.analysis","CareerSkillId.accuracy","CareerSkillId.communication","CareerSkillId.research","CareerSkillId.criticalThinking"),
    ["Math Intern","Junior Analyst","Analyst","Senior Analyst","Modeling Lead","Principal","Chief Analyst Track"],
    [
        loc("board_m","Whiteboard Bay","Graphs and proofs.","🧮"),
        loc("data_m","Data Desk","Clean and join.","📊"),
        loc("opt","Optimization","Constraints live here.","🎯"),
        loc("stats_m","Stats Corner","Inference carefully.","📈"),
        loc("sim_m","Simulation","Monte Carlo.","💻"),
        loc("client_math","Ops Client","Shipping floors.","🚚",4,"Reach Career Level 4."),
        loc("review_m","Model Review","Challenge session.","🔒",5,"Reach Career Level 5."),
        loc("war_mth","Cost War Room","Boss model.","🔒",6,"Reach Career Level 6."),
    ],
    [
        npc("singh","Dr. Arjun Singh","Lead","Allergic to silent assumptions.","👨‍🏫"),
        npc("ops_m","Ops Manager Kim","Ops","Needs actionable numbers.","👩‍💼"),
        npc("ds","Data Eng Rio","Data","Schema guardian.","🧑‍💻"),
        npc("finance_m","Finance Partner","Finance","Wants cents.","🧔"),
        npc("driver","Route Lead","Field","Reality check.","🚚"),
        npc("exec_m","COO","Exec","Decision urgency.","👩‍💼"),
    ],
    ["board_m","data_m","opt","stats_m","sim_m","review_m","war_mth"],
    "CareerSkillId.modeling", "SHIPPING COST MODEL",
    [
        ("Mission 01 — Algebra/Graph","Build intuition with graphs.","Complete algebra/graph training.",
         "Plot looks linear but residuals curve.","Try a better functional form; report fit quality","Force a line because it is simple"),
        ("Mission 02 — Optimization","Minimize delivery cost.","Solve a constrained optimization.",
         "Hard constraint violated by proposed route.","Enforce constraints; search feasible set","Ignore constraint and claim optimum"),
        ("Mission 03 — Statistics","A/B on packaging.","Draw a valid statistical conclusion.",
         "p=0.049 on tiny n.","Check power, corrections, practical significance","Ship as definitive proof"),
        ("Mission 04 — Uncertainty","Forecast volumes.","Communicate uncertainty clearly.",
         "Exec wants a single number.","Give range + assumptions + decision thresholds","Invent false precision"),
        ("Mission 05 — Model Drift","Costs shift after fuel spike.","Detect and fix model drift.",
         "Best action?","Monitor features; retrain/recalibrate; backtest","Keep old model silently"),
        ("Mission 06 — Bad Data Crisis","Feed corrupted overnight.","Handle bad data crisis.",
         "Priority?","Quarantine pipeline; fallback; alert stakeholders","Let dashboard lie until Monday"),
        ("Mission 07 — BOSS: SHIPPING COST MODEL","Company bets on your model.","Deliver SHIPPING COST MODEL under fire.",
         "Model disagrees with Ops gut.","Walk evidence; shadow deploy; kill criteria","Override Ops with arrogance and no validation"),
    ],
    ["residual","constraint","power","range","drift","quarantine","assumption","validate"],
    ['"Residuals speak."','"Feasible first."','"Significance is not importance."','"Ranges beat false precision."','"Watch for drift."','"Bad data is an incident."','"Validate under fire."'],
)

# CIVIL
make_arc_world(
    "CivilEngineeringWorld", "civil_engineering", "civil_engineering_world.dart", "civ", "brooks",
    "Jobsite — Junior Civil Engineer.",
    "Jobsite", "River City Public Works", "Junior Civil Engineer", "6:30 AM – 3:30 PM",
    "Resident Engineer Carla Brooks", "The site does not care about your slides.",
    skills("CareerSkillId.design","CareerSkillId.risk","CareerSkillId.analysis","CareerSkillId.communication","CareerSkillId.timeManagement","CareerSkillId.ethics"),
    ["Field Intern","Junior Engineer","Engineer","Senior Engineer","Resident Engineer","Project Lead","City Engineer Track"],
    [
        loc("trailer","Site Trailer","Plans and radio.","🚛"),
        loc("grade","Grading","Cuts and fills.","⛏️"),
        loc("concrete","Concrete","Pours and cures.","🧱"),
        loc("utility","Utilities","Lines and conflicts.","🔌"),
        loc("traffic","Traffic Control","Public safety.","🚧"),
        loc("lab_c","Materials Lab","Break tests.","🧪",4,"Reach Career Level 4."),
        loc("storm","Storm Desk","Rain delays.","🌧️",5,"Reach Career Level 5."),
        loc("complex","Complex Project HQ","Boss project.","🔒",6,"Reach Career Level 6."),
    ],
    [
        npc("brooks","Carla Brooks","Resident Engineer","Safety absolute.","👩‍🔧"),
        npc("foreman","Foreman Diaz","Foreman","Practical, impatient.","👷"),
        npc("inspector_c","City Inspector","Inspector","By the book.","🧔"),
        npc("neighbor","Neighbor Assoc","Public","Noise complaints.","👩"),
        npc("surveyor","Surveyor Quinn","Survey","Coordinates matter.","🧑"),
        npc("pm_civ","PM Patel","PM","Schedule pressure.","👨‍💼"),
    ],
    ["trailer","grade","concrete","utility","traffic","storm","complex"],
    "CareerSkillId.risk", "COMPLEX PROJECT",
    [
        ("Mission 01 — Site Project","Walk plans vs reality.","Complete site orientation.",
         "Plan shows a utility not marked in field.","Stop; verify as-builts; protect dig","Dig anyway to keep schedule"),
        ("Mission 02 — First Pour","Concrete pour day.","Execute first pour controls.",
         "Slump out of spec.","Reject load; document; protect placement","Accept bad load to avoid delay costs"),
        ("Mission 03 — Rain Delay","Storm incoming.","Manage rain delay safely.",
         "Crew wants to finish grading in lightning.","Suspend outdoor work; secure site","Push through the storm"),
        ("Mission 04 — Traffic Conflict","Detour failing.","Fix traffic control.",
         "Near miss reported.","Audit TCP; correct devices; brief crew","Tell public to be more careful"),
        ("Mission 05 — Change Order","Scope creep vs safety.","Handle change order ethically.",
         "Owner asks to skip inspection.","Refuse unsafe shortcut; document path","Skip inspection quietly"),
        ("Mission 06 — Utility Strike Risk","Signal of buried line.","Prevent utility crisis.",
         "Priority?","Stop excavation; notify; pothole/verify","Keep excavating to look productive"),
        ("Mission 07 — BOSS: COMPLEX PROJECT","Multi-crew downtown rebuild.","Deliver COMPLEX PROJECT safely.",
         "Flood risk + traffic + pour window collide.","Sequence by safety and critical path; communicate","Hide delays and pour in unsafe conditions"),
    ],
    ["stop","spec","safety","tcp","inspect","utility","sequence","document"],
    ['"Verify before you dig."','"Spec is law."','"Weather wins."','"Public safety first."','"No silent skips."','"Stop on signal."','"Sequence under pressure."'],
)

# ELECTRICAL
make_arc_world(
    "ElectricalEngineeringWorld", "electrical_engineering", "electrical_engineering_world.dart", "ee", "cho_e",
    "EE Lab — Electrical Engineering Student.",
    "EE Lab", "Harbor University EE", "EE Student", "2:00 PM – 6:00 PM",
    "Prof. Hannah Cho", "Power is patient until it is not.",
    skills("CareerSkillId.diagnosis","CareerSkillId.design","CareerSkillId.analysis","CareerSkillId.accuracy","CareerSkillId.risk","CareerSkillId.communication"),
    ["Lab Novice","EE Student","Technician","Junior Designer","Designer","Systems Engineer","Lead EE Track"],
    [
        loc("bench_e","Electronics Bench","Breadboards and scopes.","🔌"),
        loc("power","Power Lab","Supplies and loads.","⚡"),
        loc("pcb","PCB Bay","Layouts and reflow.","🪛"),
        loc("embed","Embedded Desk","Firmware meets hardware.","💻"),
        loc("test_ee","Test Rack","Automated checks.","📡"),
        loc("hv","High Voltage","Restricted.","🔒",4,"Reach Career Level 4."),
        loc("field_ee","Field Cabinet","Real cabinets.","🔒",5,"Reach Career Level 5."),
        loc("crit","Critical System","Boss failure.","🔒",6,"Reach Career Level 6."),
    ],
    [
        npc("cho_e","Prof. Hannah Cho","PI","Safety margins sacred.","👩‍🏫"),
        npc("ta_e","TA Miguel","TA","Scope probe police.","👨"),
        npc("partner_e","Partner Ava","Partner","Solders fast.","👩"),
        npc("tech_e","Lab Tech","Tech","Inventory and tools.","🧑‍🔧"),
        npc("ops_ee","Facilities Ops","Ops","Uptime pressure.","🧔"),
        npc("safety_e","EHS","Safety","LOTO enforcer.","🦺"),
    ],
    ["bench_e","power","pcb","embed","test_ee","field_ee","crit"],
    "CareerSkillId.diagnosis", "CRITICAL SYSTEM FAILURE",
    [
        ("Mission 01 — Circuit Build","Build and verify a circuit.","Complete circuit build training.",
         "LED does not light.","Measure systematically from supply to load","Keep swapping random parts"),
        ("Mission 02 — Troubleshoot Fault","Board partially dead.","Isolate the fault.",
         "Best method?","Divide and conquer with measurements + schematic","Apply higher voltage to force it"),
        ("Mission 03 — Timing Bug","Firmware and hardware disagree.","Resolve embedded timing issue.",
         "Race condition suspected.","Instrument signals; fix synchronization","Ship with intermittent fail as rare"),
        ("Mission 04 — Thermal Risk","Hotspot on regulator.","Mitigate thermal risk.",
         "What do you do?","Measure, derate, improve thermal path","Cover with tape and ignore"),
        ("Mission 05 — EMC Surprise","Fails emissions pretest.","Address EMC issue.",
         "First steps?","Identify coupling path; filter/layout fixes; retest","Ship anyway; hope regulators miss it"),
        ("Mission 06 — Field Outage","Cabinet trip downtown.","Handle field outage safely.",
         "Priority?","LOTO, diagnose, restore safely, document","Bypass protections to restore faster"),
        ("Mission 07 — BOSS: CRITICAL SYSTEM FAILURE","Hospital backup transfer fails.","Resolve CRITICAL SYSTEM FAILURE.",
         "Lives depend on power quality.","Safe isolate; redundant path; root cause; transparent status","Guess wiring live without LOTO"),
    ],
    ["measure","schematic","sync","thermal","emc","loto","redundant","document"],
    ['"Measure, do not guess."','"Divide and conquer."','"Intermittent is still broken."','"Heat is a requirement."','"EMC is real."','"LOTO always."','"Critical means careful."'],
)

# MLS
make_arc_world(
    "MedicalLabScienceWorld", "medical_lab_science", "medical_lab_science_world.dart", "mls", "adebayo",
    "Clinical Lab — MLS Student.",
    "Clinical Lab", "Riverside Med · Core Lab", "MLS Student", "7:00 AM – 3:30 PM",
    "Lab Manager Tessa Adebayo", "The result is a patient — treat it that way.",
    skills("CareerSkillId.accuracy","CareerSkillId.diagnosis","CareerSkillId.investigation","CareerSkillId.ethics","CareerSkillId.communication","CareerSkillId.timeManagement"),
    ["MLS Student","Bench Trainee","Technologist","Senior Tech","Lead Tech","Specialist","Manager Track"],
    [
        loc("receive","Receiving","Specimen intake.","🧪"),
        loc("heme","Hematology","CBC line.","🩸"),
        loc("chem_m","Chemistry","Analyzers.","⚗️"),
        loc("micro_m","Microbiology","Cultures.","🦠"),
        loc("blood","Blood Bank","Compatibility.","💉"),
        loc("qc","QC Desk","Controls first.","✅",3,"Reach Career Level 3."),
        loc("path","Path Consult","Weird cases.","🔒",5,"Reach Career Level 5."),
        loc("outbreak","Outbreak Cell","Boss hunt.","🔒",6,"Reach Career Level 6."),
    ],
    [
        npc("adebayo","Tessa Adebayo","Lab Manager","Quality zealot.","👩‍🔬"),
        npc("path_m","Dr. Singh","Pathologist","Clinical correlation.","👨‍⚕️"),
        npc("nurse_mls","RN Casey","Nurse","Needs STAT results.","🧑‍⚕️"),
        npc("tech_m","Bench Tech Omar","Tech","Fast and careful.","🧔"),
        npc("qa_m","QA Lead","QA","Audits everything.","👩"),
        npc("epi","Epidemiologist","Public Health","Outbreak mode.","🧑‍💼"),
    ],
    ["receive","heme","chem_m","micro_m","qc","path","outbreak"],
    "CareerSkillId.accuracy", "OUTBREAK INVESTIGATION",
    [
        ("Mission 01 — Sample Processing","Accession correctly.","Complete sample processing training.",
         "Label mismatch on STAT.","Do not proceed; resolve identity per protocol","Run it anyway because STAT"),
        ("Mission 02 — Analysis","QC fails before patient run.","Handle analysis correctly.",
         "QC out. Next?","Troubleshoot QC; do not release patients","Release patients then fix QC later"),
        ("Mission 03 — Delta Check","Impossible jump in results.","Investigate delta check.",
         "Best action?","Verify specimen/patient; repeat; call clinical","Auto-verify to clear backlog"),
        ("Mission 04 — Culture Alert","Critical organism flags.","Escalate critical micro result.",
         "What do you do?","Confirm, document, notify per critical call list","Leave it in the queue overnight"),
        ("Mission 05 — Interference","Weird chemistry pattern.","Identify analytic interference.",
         "Approach?","Check hemolysis/lipemia/drugs; correlate clinically","Report without flags"),
        ("Mission 06 — Analyzer Down","Main analyzer fails.","Manage analyzer crisis.",
         "Priority?","Backup methods; prioritize critical tests; communicate","Invent results from trends"),
        ("Mission 07 — BOSS: OUTBREAK INVESTIGATION","Cluster of rare positives.","Lead lab side of OUTBREAK INVESTIGATION.",
         "Public health on the line.","Validate assays; rule out contamination; share clean data","Suppress inconvenient positives"),
    ],
    ["label","qc","verify","critical","interfere","backup","contaminat","protocol"],
    ['"Identity is sacred."','"QC before patients."','"Delta means stop."','"Critical means call."','"Flag interferences."','"No invented results."','"Truth for public health."'],
)

# PHARMACY
make_arc_world(
    "PharmacyWorld", "pharmacy", "pharmacy_world.dart", "pharm", "okonkwo",
    "Pharmacy — Pharmacy Student.",
    "Pharmacy", "Riverside Med · Pharmacy", "Pharmacy Student", "8:00 AM – 4:30 PM",
    "Pharmacist Ada Okonkwo", "Right drug, right patient, right now.",
    skills("CareerSkillId.clinicalKnowledge","CareerSkillId.accuracy","CareerSkillId.communication","CareerSkillId.ethics","CareerSkillId.criticalThinking","CareerSkillId.timeManagement"),
    ["Pharm Student","Intern","Clinical Intern","Staff Pharmacist Track","Clinical Pharmacist","Senior Clinical","Lead Pharmacist"],
    [
        loc("verify","Verification","Rx check.","💊"),
        loc("counsel","Counseling","Patient teach-back.","🗣️"),
        loc("iv","IV Room","Sterile prep.","🧴"),
        loc("ward_p","Ward Rounds","Med reconciliation.","🏥"),
        loc("drug_info","Drug Info","Interactions.","📚"),
        loc("er_p","ED Pharmacy","Fast decisions.","🔒",4,"Reach Career Level 4."),
        loc("icu_p","ICU Satellites","High alert meds.","🔒",5,"Reach Career Level 5."),
        loc("crisis_p","Med Safety Cell","Boss crisis.","🔒",6,"Reach Career Level 6."),
    ],
    [
        npc("okonkwo","Ada Okonkwo","Pharmacist","Precise, kind under pressure.","👩‍⚕️"),
        npc("patient_p","Mr. Ellis","Patient","Confused about meds.","🧓"),
        npc("md_p","Dr. Park","Prescriber","Busy, sometimes unclear.","👨‍⚕️"),
        npc("tech_p","Tech Maya","Tech","Fills carefully.","👩"),
        npc("nurse_p","RN Diaz","Nurse","Needs clarification.","🧑‍⚕️"),
        npc("safety_ph","Med Safety","Safety","Incident reviews.","🛡️"),
    ],
    ["verify","counsel","drug_info","ward_p","iv","er_p","crisis_p"],
    "CareerSkillId.clinicalKnowledge", "MED SAFETY CRISIS",
    [
        ("Mission 01 — Rx Review","Catch a dosing error.","Complete Rx review training.",
         "Pediatric dose looks adult-sized.","Hold; recalculate; contact prescriber","Verify to clear the queue"),
        ("Mission 02 — Counseling","Patient confused on warfarin.","Counsel with teach-back.",
         "How do you counsel?","Plain language + teach-back + red flags","Hand the bottle and walk away"),
        ("Mission 03 — Interactions","New order with interaction.","Manage drug interaction.",
         "Best step?","Assess severity; recommend alternative/monitor; document","Ignore alert fatigue"),
        ("Mission 04 — Allergy Conflict","Allergy listed vs ordered drug.","Resolve allergy conflict.",
         "What do you do?","Clarify allergy details; block if needed; propose alternative","Override because the MD is senior"),
        ("Mission 05 — High-alert Med","Insulin infusion order ambiguous.","Handle high-alert safely.",
         "Ambiguous rate.","Do not prepare until clarified in writing","Guess the common rate"),
        ("Mission 06 — Shortage Crisis","Critical med on shortage.","Manage shortage ethically.",
         "Priority?","Therapeutic alternative protocol; allocate fairly; communicate","Hoard for VIP patients only"),
        ("Mission 07 — BOSS: MED SAFETY CRISIS","Cluster of near-misses.","Lead MED SAFETY CRISIS response.",
         "Wrong-patient risk spreading.","Stop affected process; investigate; system fix","Blame a single tech and move on"),
    ],
    ["hold","teach","interaction","allergy","clarify","alternative","patient","safety"],
    ['"Recalculate the vulnerable."','"Teach-back or it did not happen."','"Alerts are signals."','"Allergy details matter."','"Ambiguity stops preparation."','"Fair allocation."','"Fix systems, not scapegoats."'],
)

# CYBERSECURITY
make_arc_world(
    "CybersecurityWorld", "cybersecurity", "cybersecurity_world.dart", "cyber", "reyes",
    "SOC — Security Analyst.",
    "SOC", "ShieldOps Security", "Security Analyst", "12:00 PM – 9:00 PM",
    "SOC Lead Camila Reyes", "Assume breach. Prove otherwise.",
    skills("CareerSkillId.security","CareerSkillId.investigation","CareerSkillId.analysis","CareerSkillId.risk","CareerSkillId.communication","CareerSkillId.ethics"),
    ["SOC Intern","Junior Analyst","Analyst","Senior Analyst","Incident Responder","Lead","CISO Track"],
    [
        loc("soc","SOC Floor","Alerts and coffee.","🖥️"),
        loc("intel","Threat Intel","TTPs and IOCs.","🕵️"),
        loc("forensics","Forensics","Disk and memory.","💾"),
        loc("ir","IR Bridge","Incident command.","🚨"),
        loc("iam","IAM Desk","Access reviews.","🔑"),
        loc("red","Purple Team","Attack paths.","🔒",4,"Reach Career Level 4."),
        loc("exec_c","Exec Brief","Board fear.","🔒",5,"Reach Career Level 5."),
        loc("war_cy","Cyber War Room","Boss incident.","🔒",6,"Reach Career Level 6."),
    ],
    [
        npc("reyes","Camila Reyes","SOC Lead","Calm, blameless IR.","👩‍💻"),
        npc("user","Employee Dana","User","Clicked something.","🧑"),
        npc("it","IT Ops","IT","Wants systems up.","🧔"),
        npc("legal_c","Counsel Morgan","Legal","Evidence and notice.","👩‍💼"),
        npc("threat","Intel Analyst","Intel","Pattern hunter.","🕵️"),
        npc("ciso","CISO Blake","CISO","Risk translator.","👨‍💼"),
    ],
    ["soc","iam","intel","forensics","ir","exec_c","war_cy"],
    "CareerSkillId.security", "CYBER INCIDENT",
    [
        ("Mission 01 — Suspicious Login","Impossible travel alert.","Triage suspicious login.",
         "Alert looks noisy.","Validate context; contain account if risk; document","Close as false positive without checks"),
        ("Mission 02 — Investigation","Phish reported.","Investigate phishing chain.",
         "Best first moves?","Preserve evidence; scope recipients; block IOCs","Delete evidence to clean mailboxes fast"),
        ("Mission 03 — Access Review","Privilege creep found.","Fix access risk.",
         "Contractor has admin forever.","Least privilege + time-bound access + approvals","Leave it; they are helpful"),
        ("Mission 04 — Malware Detect","EDR detonation.","Contain malware safely.",
         "Priority?","Isolate host; collect; eradicate; recover","Reimage immediately destroying forensics always"),
        ("Mission 05 — Insider Risk","Sensitive exfil alert.","Handle insider risk ethically.",
         "Approach?","Follow policy; involve HR/legal; avoid vigilantism","Publicly accuse without evidence"),
        ("Mission 06 — Ransomware Pressure","Encryption spreading.","Lead ransomware crisis containment.",
         "First hour?","Isolate segments; preserve backups; activate IR plan","Pay immediately without scoping"),
        ("Mission 07 — BOSS: CYBER INCIDENT","Full-blown breach day.","Command CYBER INCIDENT response.",
         "Press + regulators + attackers.","Facts, containment, counsel, measured comms","Lie to customers to buy time"),
    ],
    ["contain","evidence","least","isolate","policy","backup","scope","facts"],
    ['"Validate then contain."','"Preserve evidence."','"Least privilege."','"Isolate first."','"Policy over vigilante."','"Backups are oxygen."','"Truth under breach."'],
)

print("total worlds", len(WORLDS))
for w in WORLDS:
    emit(w)
print("done")
