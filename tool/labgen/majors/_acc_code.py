M = {}
_T = '''NORMAL = {"asset": "Dr", "expense": "Dr", "drawings": "Dr", "liability": "Cr", "equity": "Cr", "revenue": "Cr"}
'''
M['de1'] = 'import sys\n' + _T + '''for l in sys.stdin.read().strip().split("\\n"):
    acc, kind, change = l.rsplit(" ", 2)
    side = NORMAL[kind]
    if change == "decrease":
        side = "Cr" if side == "Dr" else "Dr"
    print(f"{acc}: {'Debit' if side == 'Dr' else 'Credit'}")
'''
M['de1_bug'] = 'import sys\n' + '''for l in sys.stdin.read().strip().split("\\n"):
    acc, kind, change = l.rsplit(" ", 2)
    print(f"{acc}: {'Debit' if change == 'increase' else 'Credit'}")
'''
M['de2'] = '''import sys
e = {}
order = []
for l in sys.stdin.read().strip().split("\\n"):
    n, acc, side, amt = l.rsplit(" ", 3)
    if n not in e:
        e[n] = [0.0, 0.0]
        order.append(n)
    e[n][0 if side == "Dr" else 1] += float(amt)
for n in order:
    d, c = e[n]
    if abs(d - c) < 0.005:
        print(f"Entry {n}: balanced ({d:.2f})")
    else:
        print(f"Entry {n}: UNBALANCED - debits {d:.2f}, credits {c:.2f}, difference {abs(d - c):.2f}")
'''
M['de3'] = '''import sys
a = l_ = e = 0.0
for l in sys.stdin.read().strip().split("\\n"):
    desc, parts = l.split(":")
    for p in parts.split(","):
        kind, amt = p.split()
        v = float(amt)
        if kind == "A":
            a += v
        elif kind == "L":
            l_ += v
        else:
            e += v
    status = "balances" if abs(a - (l_ + e)) < 0.005 else "DOES NOT BALANCE"
    print(f"{desc.strip()}: A {a:.2f} = L {l_:.2f} + E {e:.2f} - {status}")
'''
M['gl1'] = '''import sys
b = {}
for l in sys.stdin.read().strip().split("\\n"):
    dr, cr, amt = l.split(",")
    b[dr] = b.get(dr, 0) + float(amt)
    b[cr] = b.get(cr, 0) - float(amt)
for k in sorted(b):
    v = b[k]
    print(f"{k}: {abs(v):.2f} {'Dr' if v > 0 else 'Cr' if v < 0 else ''}".rstrip())
'''
M['gl2'] = '''import sys
td = tc = 0.0
for l in sys.stdin.read().strip().split("\\n"):
    acc, amt, side = l.rsplit(" ", 2)
    if side == "Dr":
        td += float(amt)
    else:
        tc += float(amt)
print(f"Total debits: {td:.2f}")
print(f"Total credits: {tc:.2f}")
if abs(td - tc) < 0.005:
    print("Trial balance agrees")
else:
    d = round(abs(td - tc), 2)
    print(f"Difference {d:.2f} to suspense ({'credit' if td > tc else 'debit'} side)")
    if round(d * 100) % 9 == 0:
        print("Hint: divisible by 9 - check for a transposition error")
    if round(d * 100) % 2 == 0:
        print(f"Hint: half the difference is {d / 2:.2f} - check for an amount posted to the wrong side")
'''
M['gl3'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    cost, resid, life, method = l.split()
    cost, resid, life = float(cost), float(resid), int(life)
    nbv = cost
    out = []
    for y in range(1, life + 1):
        if method == "SL":
            d = (cost - resid) / life
        else:
            d = nbv * 0.25
        nbv -= d
        out.append(f"Y{y} {d:.2f}")
    print(f"{method}: " + ", ".join(out) + f" | NBV {nbv:.2f}")
'''
M['gl2_bug'] = M['gl2'].replace('if side == "Dr":', 'if side == "Cr":')
M['cv1'] = '''import sys, math
for l in sys.stdin.read().strip().split("\\n"):
    f, p, v = map(float, l.split())
    c = p - v
    print(f"Contribution {c:.2f} per unit; break-even {math.ceil(round(f / c, 9))} units")
'''
M['cv2'] = '''import sys, math
for l in sys.stdin.read().strip().split("\\n"):
    f, p, v, budget, target = map(float, l.split())
    c = p - v
    be = math.ceil(round(f / c, 9))
    mos = (budget - be) / budget * 100
    need = math.ceil(round((f + target) / c, 9))
    print(f"Break-even {be}; margin of safety {mos:.1f}%; units for target profit {need}")
'''
M['cv3'] = '''import sys
sq, sp, aq, ap = map(float, sys.stdin.read().split())
price = (sp - ap) * aq
usage = (sq - aq) * sp
def fmt(x):
    return f"{abs(x):.2f} {'F' if x > 0 else 'A' if x < 0 else ''}".rstrip()
print(f"Material price variance: {fmt(price)}")
print(f"Material usage variance: {fmt(usage)}")
print(f"Total material variance: {fmt(price + usage)}")
'''
M['cv1_bug'] = M['cv1'].replace('c = p - v', 'c = p')
M['au1'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
n, size, start = map(int, l[0].split())
step = n // size
picks = [start + i * step for i in range(size)]
print(f"Interval {step}: items " + " ".join(map(str, picks)))
'''
M['au2'] = '''import sys, math
vals = [x for x in sys.stdin.read().split() if float(x) >= 1]
c = [0] * 10
for v in vals:
    d = int(v.lstrip("0.")[0])
    c[d] += 1
n = len(vals)
for d in range(1, 10):
    exp = math.log10(1 + 1 / d) * 100
    act = c[d] / n * 100
    flag = " CHECK" if abs(act - exp) > 10 else ""
    print(f"{d}: {act:.1f}% (expected {exp:.1f}%){flag}")
'''
M['au3'] = '''import sys
from datetime import date
rows = []
for l in sys.stdin.read().strip().split("\\n"):
    ref, d, sup, amt = l.split(",")
    rows.append((ref, date.fromisoformat(d), sup, float(amt)))
found = 0
for i in range(len(rows)):
    for j in range(i + 1, len(rows)):
        a, b = rows[i], rows[j]
        if a[2] == b[2] and abs(a[3] - b[3]) < 0.005 and abs((b[1] - a[1]).days) <= 7:
            print(f"Possible duplicate: {a[0]} and {b[0]} ({a[2]}, {a[3]:.2f})")
            found += 1
print(f"{found} possible duplicate(s)")
'''
M['ra1'] = '''import sys
d = dict((k, float(v)) for k, v in (x.split("=") for x in sys.stdin.read().split()))
print(f"Gross margin: {(d['revenue'] - d['cogs']) / d['revenue'] * 100:.1f}%")
print(f"Net margin: {d['profit'] / d['revenue'] * 100:.1f}%")
print(f"Current ratio: {d['ca'] / d['cl']:.2f}")
'''
M['ra2'] = '''import sys
d = dict((k, float(v)) for k, v in (x.split("=") for x in sys.stdin.read().split()))
qr = (d['ca'] - d['inventory']) / d['cl']
rd = d['receivables'] / d['revenue'] * 365
pd = d['payables'] / d['cogs'] * 365
print(f"Quick ratio: {qr:.2f}")
print(f"Receivable days: {rd:.0f}")
print(f"Payable days: {pd:.0f}")
'''
M['ra3'] = '''import sys
lines = sys.stdin.read().strip().split("\\n")
def parse(s):
    return dict((k, float(v)) for k, v in (x.split("=") for x in s.split()))
a, b = parse(lines[0]), parse(lines[1])
for k in ("revenue", "profit", "cash"):
    ch = (b[k] - a[k]) / a[k] * 100
    print(f"{k}: {a[k]:.0f} -> {b[k]:.0f} ({ch:+.1f}%)")
if b["profit"] > a["profit"] and b["cash"] < a["cash"]:
    print("Warning: profit up but cash down - check receivables, inventory and capital spending")
'''
