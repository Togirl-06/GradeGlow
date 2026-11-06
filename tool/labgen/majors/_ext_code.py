M = {}
# ---------------- MUST (nursing admission)
M['mu1'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    kg, m = map(float, l.split())
    print(f"BMI {kg / m ** 2:.1f}")
'''
M['mu2'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    before, now = map(float, l.split())
    print(f"Weight loss {(before - now) / before * 100:.1f}%")
'''
M['mu3'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    kg, m, before, acute = l.split()
    kg, m, before = float(kg), float(m), float(before)
    bmi = kg / m ** 2
    s1 = 0 if bmi > 20 else 1 if bmi >= 18.5 else 2
    loss = (before - kg) / before * 100
    s2 = 0 if loss < 5 else 1 if loss <= 10 else 2
    s3 = 2 if acute == "yes" else 0
    t = s1 + s2 + s3
    risk = "low" if t == 0 else "medium" if t == 1 else "high"
    print(f"MUST {t} ({s1}+{s2}+{s3}): {risk} risk")
'''
M['mu1_bug'] = M['mu1'].replace('kg / m ** 2', 'kg / m * 2')
# ---------------- obs trends (vitals)
M['tr1'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
lo, hi = map(float, l[0].split())
vals = list(map(float, l[1].split()))
out = [v for v in vals if v < lo or v > hi]
print(f"{len(out)} of {len(vals)} outside {lo:g}-{hi:g}")
'''
M['tr2'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    name, rest = l.split(":")
    v = list(map(float, rest.split()))
    run = best = 0
    for a, b in zip(v, v[1:]):
        run = run + 1 if b > a else 0
        best = max(best, run)
    print(f"{name}: " + ("RISING TREND - review" if best >= 3 else "no sustained rise"))
'''
M['tr3'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    t, hr, sbp = l.split()
    hr, sbp = int(hr), int(sbp)
    si = hr / sbp
    print(f"{t}: shock index {si:.2f}" + (" - ESCALATE" if si >= 1.0 else " - watch" if si >= 0.7 else ""))
'''
# ---------------- MAR (meds)
M['mar1'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
for row in l:
    drug, due, given = row.split()
    if given == "-":
        print(f"{drug} {due}: NOT GIVEN - check reason code")
    else:
        dh, dm = map(int, due.split(":")); gh, gm = map(int, given.split(":"))
        late = gh * 60 + gm - dh * 60 - dm
        print(f"{drug} {due}: given" + (f" {late} min late" if late > 60 else ""))
'''
M['mar2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
allergies = set(x.lower() for x in l[0].split(",")) if l[0].strip() != "none" else set()
CLASS = {"amoxicillin": "penicillin", "co-amoxiclav": "penicillin", "flucloxacillin": "penicillin", "penicillin v": "penicillin",
         "ibuprofen": "nsaid", "naproxen": "nsaid", "codeine": "opioid", "morphine": "opioid", "paracetamol": "paracetamol"}
for d in l[1:]:
    d = d.strip().lower()
    c = CLASS.get(d, d)
    print(f"{d}: " + ("STOP - allergy (" + c + ")" if d in allergies or c in allergies else "no recorded allergy"))
'''
M['mar3'] = '''import sys
PARA = {"paracetamol": 1000, "co-codamol 30/500": 500, "co-codamol 8/500": 500}
tot = 0
for l in sys.stdin.read().strip().split("\\n"):
    drug, tabs, times = l.rsplit(" ", 2)
    mg = PARA.get(drug.lower(), 0) * int(tabs) * int(times)
    if mg:
        print(f"{drug}: {mg} mg paracetamol in 24 h")
    tot += mg
print(f"Total paracetamol {tot} mg - " + ("EXCEEDS 4 g maximum: withhold and contact prescriber" if tot > 4000 else "within 4 g maximum"))
'''
M['mar2_bug'] = M['mar2'].replace('if d in allergies or c in allergies', 'if d in allergies')
# ---------------- Parkland (emergency)
M['pk1'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    kg, tbsa = map(float, l.split())
    print(f"{4 * kg * tbsa:g} mL in 24 hours")
'''
M['pk2'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    kg, tbsa = map(float, l.split())
    t = 4 * kg * tbsa
    print(f"First 8 h: {t / 2:g} mL at {t / 2 / 8:.0f} mL/h; next 16 h: {t / 2:g} mL at {t / 2 / 16:.0f} mL/h")
'''
M['pk3'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    kg, tbsa, hrs, given = map(float, l.split())
    t = 4 * kg * tbsa
    left8 = max(t / 2 - given, 0)
    remain = 8 - hrs
    if remain <= 0:
        print("Past 8 hours: give the second half over the remaining 16 hours")
    else:
        print(f"Give {left8:g} mL over {remain:g} h = {left8 / remain:.0f} mL/h")
'''
M['pk1_bug'] = M['pk1'].replace('4 * kg * tbsa', '2 * kg * tbsa')
# ---------------- day books (bookkeeping)
M['db1'] = '''import sys
n = v = 0.0
for l in sys.stdin.read().strip().split("\\n"):
    inv, cust, net, rate = l.split(",")
    n += float(net)
    v += round(float(net) * float(rate) / 100 + 1e-9, 2)
print(f"Net {n:.2f} VAT {v:.2f} Gross {n + v:.2f}")
'''
M['db2'] = '''import sys
b = {}
for l in sys.stdin.read().strip().split("\\n"):
    kind, cust, amt = l.split(",")
    a = float(amt)
    b[cust] = b.get(cust, 0) + (a if kind == "INV" else -a)
for c in sorted(b):
    print(f"{c}: {b[c]:.2f}")
print(f"Receivables control: {sum(b.values()):.2f}")
'''
M['db3'] = '''import sys
from datetime import date
l = sys.stdin.read().strip().split("\\n")
today = date.fromisoformat(l[0])
buckets = {"0-30": 0.0, "31-60": 0.0, "61-90": 0.0, "90+": 0.0}
for row in l[1:]:
    cust, d, amt = row.split(",")
    age = (today - date.fromisoformat(d)).days
    k = "0-30" if age <= 30 else "31-60" if age <= 60 else "61-90" if age <= 90 else "90+"
    buckets[k] += float(amt)
for k, v in buckets.items():
    print(f"{k}: {v:.2f}")
over = buckets["61-90"] + buckets["90+"]
print(f"Over 60 days: {over:.2f} - " + ("chase now" if over > 0 else "none"))
'''
M['db1_bug'] = M['db1'].replace('n += float(net)', 'n += float(net) * (1 + float(rate) / 100)')
# ---------------- bank rec
M['br_1'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
cb = [x.split(",") for x in l[0].split(";")]
bank = [x.split(",") for x in l[1].split(";")]
used = set()
for ref, amt in cb:
    m = next((i for i, (r, a) in enumerate(bank) if i not in used and r == ref and abs(float(a) - float(amt)) < 0.005), None)
    if m is None:
        print(f"{ref} {float(amt):.2f}: not on statement")
    else:
        used.add(m)
        print(f"{ref} {float(amt):.2f}: matched")
for i, (r, a) in enumerate(bank):
    if i not in used:
        print(f"{r} {float(a):.2f}: on statement only - update cash book")
'''
M['br_2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
stmt = float(l[0])
unpresented = sum(float(x) for x in l[1].split()) if l[1].strip() != "none" else 0
lodge = sum(float(x) for x in l[2].split()) if l[2].strip() != "none" else 0
adj = stmt + lodge - unpresented
print(f"Balance per statement {stmt:.2f}")
print(f"Add outstanding lodgements {lodge:.2f}")
print(f"Less unpresented cheques {unpresented:.2f}")
print(f"Balance per cash book should be {adj:.2f}")
'''
M['br_3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
cb = float(l[0])
adj = 0.0
for x in l[1].split(";"):
    what, amt = x.rsplit(" ", 1)
    adj += float(amt)
stmt = float(l[2])
unp = sum(float(x) for x in l[3].split()) if l[3].strip() != "none" else 0
lod = sum(float(x) for x in l[4].split()) if l[4].strip() != "none" else 0
a = cb + adj
b = stmt + lod - unp
print(f"Adjusted cash book {a:.2f}")
print(f"Adjusted bank {b:.2f}")
print("Reconciled" if abs(a - b) < 0.005 else f"Unreconciled difference {a - b:.2f}")
'''
M['br_2_bug'] = M['br_2'].replace('adj = stmt + lodge - unpresented', 'adj = stmt - lodge + unpresented')
# ---------------- statements
M['fs1'] = '''import sys
d = dict((k, float(v)) for k, v in (x.split("=") for x in sys.stdin.read().split()))
gp = d["sales"] - d["cogs"]
np = gp - d["expenses"]
print(f"Gross profit: {gp:.2f}")
print(f"Net profit: {np:.2f}")
'''
M['fs2'] = '''import sys
NC = {"premises", "equipment", "vehicles"}
CA = {"inventory", "receivables", "bank", "cash"}
CL = {"payables", "overdraft", "accruals"}
NL = {"loan"}
d = dict((k, float(v)) for k, v in (x.split("=") for x in sys.stdin.read().split()))
nca = sum(v for k, v in d.items() if k in NC)
ca = sum(v for k, v in d.items() if k in CA)
cl = sum(v for k, v in d.items() if k in CL)
nl = sum(v for k, v in d.items() if k in NL)
print(f"Non-current assets: {nca:.2f}")
print(f"Current assets: {ca:.2f}")
print(f"Current liabilities: {cl:.2f}")
print(f"Net assets: {nca + ca - cl - nl:.2f}")
'''
M['fs3'] = '''import sys
d = dict((k, float(v)) for k, v in (x.split("=") for x in sys.stdin.read().split()))
cfo = d["profit"] + d["depreciation"] - d["inc_inventory"] - d["inc_receivables"] + d["inc_payables"]
net = cfo - d["capex"] + d["new_loans"] - d["drawings"]
print(f"Cash from operations: {cfo:.2f}")
print(f"Net change in cash: {net:.2f}")
'''
M['fs1_bug'] = M['fs1'].replace('np = gp - d["expenses"]', 'np = d["sales"] - d["expenses"]')
