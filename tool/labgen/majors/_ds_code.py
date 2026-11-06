M = {}
# ---------------- cleaning
M['clean1'] = '''import sys
rows = sys.stdin.read().strip().split("\\n")[1:]
missing = 0
for r in rows:
    name, city = [x.strip() for x in r.split(",")]
    if not name or not city:
        missing += 1
        continue
    print(f"{name.title()},{city.title()}")
print(f"Missing: {missing}")
'''
M['clean2'] = '''import sys
rows = sys.stdin.read().strip().split("\\n")[1:]
seen, dup = set(), 0
for r in rows:
    name, email = [x.strip() for x in r.split(",")]
    key = email.lower()
    if key in seen:
        dup += 1
        continue
    seen.add(key)
    print(f"{name.title()},{key}")
print(f"Duplicates removed: {dup}")
'''
M['clean3'] = '''import sys, re
bad = 0
for d in sys.stdin.read().strip().split("\\n"):
    d = d.strip()
    m1 = re.fullmatch(r"(\\d{4})-(\\d{2})-(\\d{2})", d)
    m2 = re.fullmatch(r"(\\d{1,2})/(\\d{1,2})/(\\d{4})", d)
    if m1:
        y, mo, da = map(int, m1.groups())
    elif m2:
        da, mo, y = map(int, m2.groups())
    else:
        y = None
    ok = False
    if y is not None and 1 <= mo <= 12:
        leap = (y % 4 == 0 and y % 100 != 0) or y % 400 == 0
        dim = [31, 29 if leap else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][mo - 1]
        ok = 1 <= da <= dim
    if ok:
        print(f"{y:04d}-{mo:02d}-{da:02d}")
    else:
        bad += 1
        print("INVALID")
print(f"Invalid: {bad}")
'''
M['clean2_bug'] = M['clean2'].replace('key = email.lower()', 'key = email')
M['imp1'] = '''import sys
vals = sys.stdin.read().split()
nums = [float(v) for v in vals if v != "NA"]
mean = sum(nums) / len(nums)
print(" ".join(f"{mean:.1f}" if v == "NA" else f"{float(v):.1f}" for v in vals))
'''
M['imp2'] = '''import sys
vals = sys.stdin.read().split()
nums = sorted(float(v) for v in vals if v != "NA")
n = len(nums)
med = nums[n // 2] if n % 2 else (nums[n // 2 - 1] + nums[n // 2]) / 2
print(f"Median: {med:.1f}")
print(" ".join(f"{med:.1f}" if v == "NA" else f"{float(v):.1f}" for v in vals))
'''
M['imp3'] = '''import sys
x = sorted(map(float, sys.stdin.read().split()))
def q(p):
    i = (len(x) - 1) * p
    lo = int(i)
    hi = min(lo + 1, len(x) - 1)
    return x[lo] + (x[hi] - x[lo]) * (i - lo)
q1, q3 = q(0.25), q(0.75)
iqr = q3 - q1
lo, hi = q1 - 1.5 * iqr, q3 + 1.5 * iqr
out = [v for v in x if v < lo or v > hi]
print(f"Q1={q1:.2f} Q3={q3:.2f} IQR={iqr:.2f}")
print("Outliers: " + (" ".join(f"{v:g}" for v in out) if out else "none"))
'''
M['imp1_bug'] = M['imp1'].replace('nums = [float(v) for v in vals if v != "NA"]', 'nums = [float(v) if v != "NA" else 0.0 for v in vals]')
# ---------------- analysis
M['grp1'] = '''import sys
t = {}
for l in sys.stdin.read().strip().split("\\n")[1:]:
    region, amount = l.split(",")
    t[region] = t.get(region, 0) + float(amount)
for r in sorted(t):
    print(f"{r}: {t[r]:.2f}")
'''
M['grp2'] = '''import sys
t = {}
for l in sys.stdin.read().strip().split("\\n")[1:]:
    region, amount = l.split(",")
    a = t.setdefault(region, [0, 0.0])
    a[0] += 1
    a[1] += float(amount)
for r, (n, s) in sorted(t.items(), key=lambda kv: (-kv[1][1] / kv[1][0], kv[0])):
    print(f"{r}: n={n} mean={s / n:.2f}")
'''
M['grp3'] = '''import sys
t = {}
for l in sys.stdin.read().strip().split("\\n")[1:]:
    month, amount = l.split(",")
    t[month] = t.get(month, 0) + float(amount)
ms = sorted(t)
print(f"{ms[0]}: {t[ms[0]]:.2f}")
for a, b in zip(ms, ms[1:]):
    g = (t[b] - t[a]) / t[a] * 100
    print(f"{b}: {t[b]:.2f} ({g:+.1f}%)")
'''
M['st1'] = '''import sys
x = list(map(float, sys.stdin.read().split()))
s = sorted(x)
n = len(s)
med = s[n // 2] if n % 2 else (s[n // 2 - 1] + s[n // 2]) / 2
c = {}
for v in x:
    c[v] = c.get(v, 0) + 1
mode = min(v for v in c if c[v] == max(c.values()))
print(f"Mean: {sum(x) / n:.2f}")
print(f"Median: {med:.2f}")
print(f"Mode: {mode:g}")
'''
M['st2'] = '''import sys, math
x = list(map(float, sys.stdin.read().split()))
n = len(x)
m = sum(x) / n
sd = math.sqrt(sum((v - m) ** 2 for v in x) / (n - 1))
print(f"Mean: {m:.2f} SD: {sd:.2f}")
print("z: " + " ".join(f"{(v - m) / sd:.2f}" for v in x))
'''
M['st3'] = '''import sys, math
l = sys.stdin.read().strip().split("\\n")
x = list(map(float, l[0].split()))
y = list(map(float, l[1].split()))
n = len(x)
mx, my = sum(x) / n, sum(y) / n
sxy = sum((a - mx) * (b - my) for a, b in zip(x, y))
sxx = sum((a - mx) ** 2 for a in x)
syy = sum((b - my) ** 2 for b in y)
r = sxy / math.sqrt(sxx * syy)
s = "strong" if abs(r) >= 0.7 else "moderate" if abs(r) >= 0.4 else "weak"
print(f"r = {r:.3f} ({s} {'positive' if r > 0 else 'negative'})")
'''
M['st2_bug'] = M['st2'].replace('/ (n - 1))', '/ n)')
# ---------------- visualisation
M['hist1'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
w = float(l[0])
x = list(map(float, l[1].split()))
lo = 0
top = max(x)
b = 0
while b * w <= top:
    c = sum(b * w <= v < (b + 1) * w for v in x)
    print(f"{b * w:g}-{(b + 1) * w:g}: {c}")
    b += 1
'''
M['hist2'] = M['hist1'].replace('print(f"{b * w:g}-{(b + 1) * w:g}: {c}")', 'print(f"{b * w:g}-{(b + 1) * w:g} | " + "#" * c)')
M['hist3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
w = float(l[0])
x = list(map(float, l[1].split()))
top = max(x)
bins = []
b = 0
while b * w <= top:
    bins.append((f"{b * w:g}-{(b + 1) * w:g}", sum(b * w <= v < (b + 1) * w for v in x)))
    b += 1
peak = max(c for _, c in bins)
pad = max(len(k) for k, _ in bins)
for k, c in bins:
    print(f"{k.ljust(pad)} | {'#' * round(c / peak * 20)} {c}")
'''
# ---------------- statistics
M['tt1'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
a = list(map(float, l[0].split()))
b = list(map(float, l[1].split()))
ma, mb = sum(a) / len(a), sum(b) / len(b)
print(f"Mean A: {ma:.2f}")
print(f"Mean B: {mb:.2f}")
print(f"Difference (B-A): {mb - ma:.2f}")
'''
M['tt2'] = '''import sys, math
l = sys.stdin.read().strip().split("\\n")
a = list(map(float, l[0].split()))
b = list(map(float, l[1].split()))
def mv(x):
    m = sum(x) / len(x)
    return m, sum((v - m) ** 2 for v in x) / (len(x) - 1)
ma, va = mv(a)
mb, vb = mv(b)
t = (mb - ma) / math.sqrt(va / len(a) + vb / len(b))
print(f"t = {t:.3f}")
'''
M['tt3'] = '''import sys, math
l = sys.stdin.read().strip().split("\\n")
a = list(map(float, l[0].split()))
b = list(map(float, l[1].split()))
crit = float(l[2])
def mv(x):
    m = sum(x) / len(x)
    return m, sum((v - m) ** 2 for v in x) / (len(x) - 1)
ma, va = mv(a)
mb, vb = mv(b)
t = (mb - ma) / math.sqrt(va / len(a) + vb / len(b))
print(f"t = {t:.3f}")
print("Reject H0: significant difference" if abs(t) > crit else "Fail to reject H0: no significant difference")
'''
M['ci1'] = '''import sys, math
x = list(map(float, sys.stdin.read().split()))
n = len(x)
m = sum(x) / n
sd = math.sqrt(sum((v - m) ** 2 for v in x) / (n - 1))
h = 1.96 * sd / math.sqrt(n)
print(f"95% CI: {m - h:.2f} to {m + h:.2f}")
'''
M['ci2'] = '''import sys, math
k, n = map(int, sys.stdin.read().split())
p = k / n
h = 1.96 * math.sqrt(p * (1 - p) / n)
print(f"p = {p:.3f}")
print(f"95% CI: {p - h:.3f} to {p + h:.3f}")
'''
M['ci3'] = '''import sys, math
sd, e = map(float, sys.stdin.read().split())
print(f"n = {math.ceil((1.96 * sd / e) ** 2)}")
'''
# ---------------- predictive
M['lg1'] = '''import sys, math
l = sys.stdin.read().strip().split("\\n")
w = list(map(float, l[0].split()))
for row in l[1:]:
    x = list(map(float, row.split()))
    z = w[0] + sum(a * b for a, b in zip(w[1:], x))
    print(f"{1 / (1 + math.exp(-z)):.3f}")
'''
M['lg2'] = '''import sys, math
l = sys.stdin.read().strip().split("\\n")
w = list(map(float, l[0].split()))
t = float(l[1])
right = 0
rows = l[2:]
for row in rows:
    v = list(map(float, row.split()))
    x, y = v[:-1], int(v[-1])
    p = 1 / (1 + math.exp(-(w[0] + sum(a * b for a, b in zip(w[1:], x)))))
    pred = 1 if p >= t else 0
    right += pred == y
    print(pred)
print(f"Accuracy: {right / len(rows):.2f}")
'''
M['lg3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
cfp, cfn = map(float, l[0].split())
ts = list(map(float, l[1].split()))
data = [(float(a), int(b)) for a, b in (r.split() for r in l[2:])]
best = None
for t in ts:
    fp = sum(s >= t and y == 0 for s, y in data)
    fn = sum(s < t and y == 1 for s, y in data)
    c = fp * cfp + fn * cfn
    print(f"t={t:.2f} FP={fp} FN={fn} cost={c:.0f}")
    if best is None or c < best[0]:
        best = (c, t)
print(f"Best threshold: {best[1]:.2f}")
'''
M['fc1'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
k = int(l[0])
x = list(map(float, l[1].split()))
print(" ".join(f"{sum(x[i - k + 1:i + 1]) / k:.1f}" for i in range(k - 1, len(x))))
print(f"Forecast: {sum(x[-k:]) / k:.1f}")
'''
M['fc2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
a = float(l[0])
x = list(map(float, l[1].split()))
s = x[0]
out = [s]
for v in x[1:]:
    s = a * v + (1 - a) * s
    out.append(s)
print(" ".join(f"{v:.2f}" for v in out))
print(f"Forecast: {s:.2f}")
'''
M['fc3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
k = int(l[0].split()[0])
a = float(l[0].split()[1])
x = list(map(float, l[1].split()))
ma_err, es_err, n = 0, 0, 0
s = x[0]
for i in range(1, len(x)):
    if i >= k:
        ma_err += abs(x[i] - sum(x[i - k:i]) / k)
        es_err += abs(x[i] - s)
        n += 1
    s = a * x[i] + (1 - a) * s
print(f"MAE moving average: {ma_err / n:.2f}")
print(f"MAE smoothing: {es_err / n:.2f}")
print("Use: " + ("moving average" if ma_err <= es_err else "smoothing"))
'''
# ---------------- capstone
M['kpi1'] = '''import sys
rows = [r.split(",") for r in sys.stdin.read().strip().split("\\n")[1:]]
orders = len(rows)
rev = sum(int(q) * float(p) for _, _, q, p in rows)
cust = len(set(r[1] for r in rows))
print(f"Orders: {orders}")
print(f"Revenue: {rev:.2f}")
print(f"Customers: {cust}")
print(f"Average order value: {rev / orders:.2f}")
'''
M['kpi2'] = '''import sys
rows = [r.split(",") for r in sys.stdin.read().strip().split("\\n")[1:]]
seg = {}
for _, c, q, p, ch in rows:
    s = seg.setdefault(ch, [0, 0.0, set()])
    s[0] += 1
    s[1] += int(q) * float(p)
    s[2].add(c)
tot = sum(s[1] for s in seg.values())
for ch in sorted(seg, key=lambda k: (-seg[k][1], k)):
    n, r, cs = seg[ch]
    print(f"{ch}: orders={n} revenue={r:.2f} share={r / tot * 100:.1f}% customers={len(cs)}")
'''
M['kpi3'] = '''import sys
rows = [r.split(",") for r in sys.stdin.read().strip().split("\\n")[1:]]
first, count = {}, {}
for d, c, q, p in rows:
    m = d[:7]
    first[c] = min(first.get(c, m), m)
    count[c] = count.get(c, 0) + 1
months = sorted(set(first.values()))
for m in months:
    cs = [c for c in first if first[c] == m]
    rep = sum(count[c] > 1 for c in cs)
    print(f"{m}: new={len(cs)} repeat={rep} repeat_rate={rep / len(cs) * 100:.0f}%")
'''
M['kpi1_bug'] = M['kpi1'].replace('cust = len(set(r[1] for r in rows))', 'cust = len(rows)')
