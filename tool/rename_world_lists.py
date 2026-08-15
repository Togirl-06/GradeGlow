from pathlib import Path
import re

p = Path("lib/data/law/law_topic_world.dart")
t = p.read_text(encoding="utf-8")

names = re.findall(r"static final List<LawLesson> (\w+) = ", t)
for n in names:
    lower = n[0].lower() + n[1:]
    t = t.replace(n, lower)
p.write_text(t, encoding="utf-8")
print("renamed", len(names), "lists")

g = Path("tool/gen_law_topic_world.py")
gt = g.read_text(encoding="utf-8")
repls = [
    ("fiduciary_board", "shareholder_freezeout"),
    ("hostile_work_env", "whistleblower_firing"),
    ("home_office_audit", "crypto_income_audit"),
    ("visa_overstay_removal", "asylum_credibility"),
    ("clean_water_pollution", "river_dumping"),
    ("trade_secret_theft", "song_sample_suit"),
    ("treaty_dispute", "treaty_extradition"),
    ("asylum_claim", "detention_due_process"),
    ("emtala_turnaway", "surgery_consent"),
    ("coverage_denial", "duty_to_defend_fire"),
    ("talent_contract", "talent_option_abuse"),
    ("athlete_contract", "stadium_injury"),
    ("cargo_damage", "harbor_collision"),
    ("opening_statement_case", "campus_discipline"),
]
for old, new in repls:
    gt = gt.replace(f'"{old}"', f'"{new}"')

gt = gt.replace(
    'add(\n    "business_law",\n    "Business Law",\n    "vendor_breach",',
    'add(\n    "business_law",\n    "Business Law",\n    "rogue_agent_deal",',
)
g.write_text(gt, encoding="utf-8")
print("generator case ids updated")
