from pathlib import Path
import re

p = Path("lib/data/law/law_topic_world.dart")
t = p.read_text(encoding="utf-8")

repl = {
    "fiduciary_board": "shareholder_freezeout",
    "hostile_work_env": "whistleblower_firing",
    "home_office_audit": "crypto_income_audit",
    "visa_overstay_removal": "asylum_credibility",
    "clean_water_pollution": "river_dumping",
    "trade_secret_theft": "song_sample_suit",
    "treaty_dispute": "treaty_extradition",
    "asylum_claim": "detention_due_process",
    "emtala_turnaway": "surgery_consent",
    "coverage_denial": "duty_to_defend_fire",
    "talent_contract": "talent_option_abuse",
    "athlete_contract": "stadium_injury",
    "cargo_damage": "harbor_collision",
    "opening_statement_case": "campus_discipline",
}

for old, new in repl.items():
    t = t.replace(f"simulationCaseId: '{old}'", f"simulationCaseId: '{new}'")

# Business law should map to rogue_agent_deal (not vendor_breach).
m = re.search(
    r"static final List<LawLesson> BusinessLawTopics = <LawLesson>\[(.*?)\];",
    t,
    re.S,
)
if not m:
    raise SystemExit("BusinessLawTopics not found")
block = m.group(0).replace(
    "simulationCaseId: 'vendor_breach'",
    "simulationCaseId: 'rogue_agent_deal'",
)
t = t[: m.start()] + block + t[m.end() :]

p.write_text(t, encoding="utf-8")

# Verify no unknown leftovers from our fake ids
unknown = [
    "fiduciary_board",
    "hostile_work_env",
    "clean_water_pollution",
    "trade_secret_theft",
    "treaty_dispute",
    "asylum_claim",
    "emtala_turnaway",
    "coverage_denial",
    "talent_contract",
    "athlete_contract",
    "opening_statement_case",
]
for u in unknown:
    if f"simulationCaseId: '{u}'" in t:
        raise SystemExit(f"still has {u}")

print("case ids fixed")
