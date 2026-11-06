M = {}
_NEWS = '''def rr(v):
    return 3 if v <= 8 else 1 if v <= 11 else 0 if v <= 20 else 2 if v <= 24 else 3
def spo2(v):
    return 3 if v <= 91 else 2 if v <= 93 else 1 if v <= 95 else 0
def sbp(v):
    return 3 if v <= 90 else 2 if v <= 100 else 1 if v <= 110 else 0 if v <= 219 else 3
def hr(v):
    return 3 if v <= 40 else 1 if v <= 50 else 0 if v <= 90 else 1 if v <= 110 else 2 if v <= 130 else 3
def temp(v):
    return 3 if v <= 35.0 else 1 if v <= 36.0 else 0 if v <= 38.0 else 1 if v <= 39.0 else 2
'''
M['news1'] = 'import sys\n' + _NEWS + '''for l in sys.stdin.read().strip().split("\\n"):
    r, s = l.split()
    a, b = rr(int(r)), spo2(int(s))
    print(f"RR {r}: {a}, SpO2 {s}: {b}")
'''
M['news2'] = 'import sys\n' + _NEWS + '''for l in sys.stdin.read().strip().split("\\n"):
    r, s, o2, bp, p, c, t = l.split()
    parts = [rr(int(r)), spo2(int(s)), 2 if o2 == "oxygen" else 0, sbp(int(bp)), hr(int(p)), 0 if c == "A" else 3, temp(float(t))]
    print(f"NEWS2 {sum(parts)} (" + " ".join(map(str, parts)) + ")")
'''
M['news3'] = 'import sys\n' + _NEWS + '''for l in sys.stdin.read().strip().split("\\n"):
    r, s, o2, bp, p, c, t = l.split()
    parts = [rr(int(r)), spo2(int(s)), 2 if o2 == "oxygen" else 0, sbp(int(bp)), hr(int(p)), 0 if c == "A" else 3, temp(float(t))]
    n = sum(parts)
    if n >= 7:
        resp = "HIGH: emergency response, continuous monitoring"
    elif n >= 5:
        resp = "MEDIUM: urgent response, at least hourly observations"
    elif 3 in parts:
        resp = "LOW-MEDIUM: urgent ward-based response (score of 3 in one parameter)"
    elif n >= 1:
        resp = "LOW: inform registered nurse, 4-6 hourly observations"
    else:
        resp = "ROUTINE: at least 12-hourly observations"
    print(f"NEWS2 {n} - {resp}")
'''
M['news1_bug'] = M['news1'].replace('0 if v <= 20 else 2 if v <= 24', '0 if v <= 24 else 2 if v <= 24')
M['fb1'] = '''import sys
ins, outs = 0, 0
for l in sys.stdin.read().strip().split("\\n"):
    kind, ml, what = l.split(" ", 2)
    if kind == "IN":
        ins += int(ml)
    else:
        outs += int(ml)
print(f"Input: {ins} mL")
print(f"Output: {outs} mL")
print(f"Balance: {ins - outs:+d} mL")
'''
M['fb2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
kg = float(l[0])
urine = 0
for x in l[1:]:
    t, ml = x.split()
    urine += int(ml)
h = len(l) - 1
rate = urine / kg / h
print(f"Urine output: {rate:.2f} mL/kg/h over {h} h")
print("ESCALATE: below 0.5 mL/kg/h" if rate < 0.5 else "Adequate")
'''
M['drip1'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    ml, hrs = l.split()
    print(f"{float(ml) / float(hrs):.1f} mL/h")
'''
M['drip2'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    ml, mins, df = map(float, l.split())
    print(f"{round(ml * df / mins)} drops/min")
'''
M['drip3'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    want, stock, vol = map(float, l.split())
    dose = want / stock * vol
    print(f"Give {dose:g} mL")
'''
M['drip1_bug'] = M['drip1'].replace('float(ml) / float(hrs)', 'float(ml) * float(hrs)')
M['ped1'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    kg, mgkg = map(float, l.split())
    print(f"{kg * mgkg:g} mg")
'''
M['ped2'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    kg, mgkg, maxd, conc = map(float, l.split())
    dose = min(kg * mgkg, maxd)
    capped = kg * mgkg > maxd
    print(f"Dose {dose:g} mg" + (" (capped at maximum)" if capped else "") + f" = {dose / conc:g} mL")
'''
M['ped3'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    kg = float(l)
    day = 100 * min(kg, 10) + 50 * min(max(kg - 10, 0), 10) + 20 * max(kg - 20, 0)
    print(f"{kg:g} kg: {day:g} mL/day = {day / 24:.1f} mL/h")
'''
M['apgar'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    hr, resp, tone, refl, col = l.split()
    hr = int(hr)
    s = (0 if hr == 0 else 1 if hr < 100 else 2)
    s += {"absent": 0, "weak": 1, "strong": 2}[resp]
    s += {"limp": 0, "some": 1, "active": 2}[tone]
    s += {"none": 0, "grimace": 1, "cry": 2}[refl]
    s += {"blue": 0, "extremities": 1, "pink": 2}[col]
    band = "reassuring" if s >= 7 else "moderately abnormal" if s >= 4 else "low - needs immediate resuscitation"
    print(f"Apgar {s}: {band}")
'''
M['icu1'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    s, d = map(float, l.split("/"))
    m = (s + 2 * d) / 3
    print(f"MAP {m:.0f} mmHg" + (" - below 65 target" if m < 65 else ""))
'''
M['icu2'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    e, v, m = map(int, l.split())
    t = e + v + m
    sev = "severe" if t <= 8 else "moderate" if t <= 12 else "mild"
    print(f"GCS {t} (E{e} V{v} M{m}) - {sev}" + (" - airway at risk" if t <= 8 else ""))
'''
M['icu3'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    pao2, fio2 = map(float, l.split())
    r = pao2 / (fio2 / 100)
    cat = "normal" if r > 40 else "mild ARDS range" if r > 26.6 else "moderate ARDS range" if r > 13.3 else "severe ARDS range"
    print(f"P/F ratio {r:.1f} kPa - {cat}")
'''
# ---------------- medicine
M['abg1'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    ph = float(l)
    print(f"pH {ph:.2f}: " + ("acidaemia" if ph < 7.35 else "alkalaemia" if ph > 7.45 else "normal"))
'''
M['abg2'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    ph, co2, hco3 = map(float, l.split())
    if ph < 7.35:
        p = "respiratory acidosis" if co2 > 6.0 else "metabolic acidosis" if hco3 < 22 else "unclear"
    elif ph > 7.45:
        p = "respiratory alkalosis" if co2 < 4.7 else "metabolic alkalosis" if hco3 > 26 else "unclear"
    else:
        p = "no acidaemia or alkalaemia"
    print(f"pH {ph:.2f} PaCO2 {co2:g} HCO3 {hco3:g}: {p}")
'''
M['abg3'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    ph, co2, hco3, na, cl = map(float, l.split())
    if ph < 7.35 and hco3 < 22:
        ag = na - (cl + hco3)
        kind = "raised anion gap" if ag > 12 else "normal anion gap"
        comp = "with respiratory compensation" if co2 < 4.7 else "without respiratory compensation"
        print(f"Metabolic acidosis, anion gap {ag:g} ({kind}), {comp}")
    else:
        print("Not a metabolic acidosis")
'''
M['abg2_bug'] = M['abg2'].replace('"respiratory acidosis" if co2 > 6.0 else "metabolic acidosis" if hco3 < 22', '"metabolic acidosis" if hco3 < 30 else "respiratory acidosis" if co2 > 6.0')
M['dx1'] = '''import sys
tp, fp, fn, tn = map(int, sys.stdin.read().split())
print(f"Sensitivity: {tp / (tp + fn) * 100:.1f}%")
print(f"Specificity: {tn / (tn + fp) * 100:.1f}%")
'''
M['dx2'] = '''import sys
tp, fp, fn, tn = map(int, sys.stdin.read().split())
print(f"PPV: {tp / (tp + fp) * 100:.1f}%")
print(f"NPV: {tn / (tn + fn) * 100:.1f}%")
'''
M['dx3'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    sens, spec, prev = map(float, l.split())
    sens, spec, prev = sens / 100, spec / 100, prev / 100
    ppv = sens * prev / (sens * prev + (1 - spec) * (1 - prev))
    print(f"Prevalence {prev * 100:g}%: PPV {ppv * 100:.1f}%")
'''
M['sc1'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    conf, urea, rr, sbp, dbp, age = l.split()
    s = (conf == "yes") + (float(urea) > 7) + (int(rr) >= 30) + (int(sbp) < 90 or int(dbp) <= 60) + (int(age) >= 65)
    risk = "low - consider home treatment" if s <= 1 else "moderate - consider hospital treatment" if s == 2 else "high - severe pneumonia, consider critical care"
    print(f"CURB-65 {s}: {risk}")
'''
M['sc2'] = '''import sys
W = {"dvt_signs": 3, "pe_most_likely": 3, "hr_over_100": 1.5, "immobile_or_surgery": 1.5, "previous_vte": 1.5, "haemoptysis": 1, "malignancy": 1}
for l in sys.stdin.read().strip().split("\\n"):
    f = l.split() if l.strip() != "none" else []
    s = sum(W[x] for x in f)
    print(f"Wells {s:g}: " + ("PE likely" if s > 4 else "PE unlikely"))
'''
M['sc3'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    age, sex, rest = l.split(" ", 2)
    age = int(age)
    f = rest.split() if rest.strip() != "none" else []
    s = (2 if age >= 75 else 1 if age >= 65 else 0) + (sex == "F")
    s += sum({"chf": 1, "hypertension": 1, "diabetes": 1, "stroke_tia": 2, "vascular": 1}[x] for x in f)
    print(f"CHA2DS2-VASc {s}")
'''
M['ev1'] = '''import sys
ec, nc, et, nt = map(int, sys.stdin.read().split())
cer, eer = ec / nc, et / nt
arr = cer - eer
print(f"Control event rate: {cer * 100:.1f}%")
print(f"Treatment event rate: {eer * 100:.1f}%")
print(f"ARR: {arr * 100:.1f}%")
'''
M['ev2'] = '''import sys, math
ec, nc, et, nt = map(int, sys.stdin.read().split())
cer, eer = ec / nc, et / nt
arr = cer - eer
print(f"RRR: {arr / cer * 100:.1f}%")
print(f"NNT: {math.ceil(round(1 / arr, 9))}" if arr > 0 else "No benefit: NNT not applicable")
'''
M['ev3'] = '''import sys, math
a, b, c, d = map(int, sys.stdin.read().split())
o = (a * d) / (b * c)
se = math.sqrt(1 / a + 1 / b + 1 / c + 1 / d)
lo, hi = math.exp(math.log(o) - 1.96 * se), math.exp(math.log(o) + 1.96 * se)
sig = "significant" if lo > 1 or hi < 1 else "not significant"
print(f"OR {o:.2f} (95% CI {lo:.2f} to {hi:.2f}) - {sig}")
'''
M['ev2_bug'] = M['ev2'].replace('math.ceil(round(1 / arr, 9))', 'round(1 / arr)')
M['fb3'] = '''import sys
bal = 0
for l in sys.stdin.read().strip().split("\\n"):
    t, kind, ml = l.split()[:3]
    bal += int(ml) if kind == "IN" else -int(ml)
    print(f"{t} {kind} {ml} -> running balance {bal:+d} mL")
print(f"24-hour balance: {bal:+d} mL" + (" - review fluid overload" if bal > 1500 else " - review dehydration" if bal < -500 else ""))
'''
M['ap1'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    hr, resp, tone, refl, col = l.split()
    hr = int(hr)
    s = (0 if hr == 0 else 1 if hr < 100 else 2)
    s += {"absent": 0, "weak": 1, "strong": 2}[resp]
    s += {"limp": 0, "some": 1, "active": 2}[tone]
    s += {"none": 0, "grimace": 1, "cry": 2}[refl]
    s += {"blue": 0, "extremities": 1, "pink": 2}[col]
    print(f"Apgar {s}")
'''
M['ap3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
for row in l:
    a1, a5 = map(int, row.split())
    if a5 >= 7:
        act = "routine care, skin-to-skin"
    else:
        act = "continue support and repeat Apgar at 10 minutes; neonatal team involved"
    print(f"1 min {a1}, 5 min {a5}: {act}")
'''
M['ap1_bug'] = M['ap1'].replace('1 if hr < 100 else 2', '2 if hr < 100 else 1')
