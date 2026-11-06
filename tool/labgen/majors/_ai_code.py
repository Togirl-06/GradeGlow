M = {}
M['lr1'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
pts = [tuple(map(float, x.split())) for x in l[1:1 + int(l[0])]]
n = len(pts)
mx = sum(p[0] for p in pts) / n
my = sum(p[1] for p in pts) / n
m = sum((x - mx) * (y - my) for x, y in pts) / sum((x - mx) ** 2 for x, _ in pts)
c = my - m * mx
print(f"m={m:.2f} c={c:.2f}")
'''
M['lr2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
pts = [tuple(map(float, x.split())) for x in l[1:1 + int(l[0])]]
q = float(l[1 + int(l[0])])
n = len(pts)
mx = sum(p[0] for p in pts) / n
my = sum(p[1] for p in pts) / n
m = sum((x - mx) * (y - my) for x, y in pts) / sum((x - mx) ** 2 for x, _ in pts)
c = my - m * mx
mse = sum((y - (m * x + c)) ** 2 for x, y in pts) / n
print(f"Prediction: {m * q + c:.2f}")
print(f"MSE: {mse:.2f}")
'''
M['lr3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
n = int(l[0])
tr = [tuple(map(float, x.split())) for x in l[1:1 + n]]
k = int(l[1 + n])
te = [tuple(map(float, x.split())) for x in l[2 + n:2 + n + k]]
mx = sum(p[0] for p in tr) / n
my = sum(p[1] for p in tr) / n
m = sum((x - mx) * (y - my) for x, y in tr) / sum((x - mx) ** 2 for x, _ in tr)
c = my - m * mx
ty = sum(y for _, y in te) / k
ss_res = sum((y - (m * x + c)) ** 2 for x, y in te)
ss_tot = sum((y - ty) ** 2 for _, y in te)
print(f"Test R2: {1 - ss_res / ss_tot:.3f}")
'''
M['knn1'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
n = int(l[0])
tr = [x.split() for x in l[1:1 + n]]
qx, qy = map(float, l[1 + n].split())
best = min(tr, key=lambda r: (float(r[0]) - qx) ** 2 + (float(r[1]) - qy) ** 2)
print(best[2])
'''
M['knn2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
n, k = map(int, l[0].split())
tr = [x.split() for x in l[1:1 + n]]
for q in l[1 + n:]:
    qx, qy = map(float, q.split())
    near = sorted(tr, key=lambda r: (float(r[0]) - qx) ** 2 + (float(r[1]) - qy) ** 2)[:k]
    votes = {}
    for r in near:
        votes[r[2]] = votes.get(r[2], 0) + 1
    top = max(votes.values())
    print(sorted(c for c, v in votes.items() if v == top)[0])
'''
M['knn3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
n, k = map(int, l[0].split())
tr = [x.split() for x in l[1:1 + n]]
xs = [float(r[0]) for r in tr]
ys = [float(r[1]) for r in tr]
def sc(v, a):
    return (v - min(a)) / (max(a) - min(a))
right = 0
qs = l[1 + n:]
for q in qs:
    qx, qy, truth = q.split()
    qx, qy = sc(float(qx), xs), sc(float(qy), ys)
    near = sorted(tr, key=lambda r: (sc(float(r[0]), xs) - qx) ** 2 + (sc(float(r[1]), ys) - qy) ** 2)[:k]
    votes = {}
    for r in near:
        votes[r[2]] = votes.get(r[2], 0) + 1
    top = max(votes.values())
    pred = sorted(c for c, v in votes.items() if v == top)[0]
    right += pred == truth
    print(pred)
print(f"Accuracy: {right / len(qs):.2f}")
'''
M['nn1'] = '''import sys, math
l = sys.stdin.read().strip().split("\\n")
x = list(map(float, l[0].split()))
w = list(map(float, l[1].split()))
b = float(l[2])
z = sum(a * c for a, c in zip(x, w)) + b
print(f"z={z:.3f} y={1 / (1 + math.exp(-z)):.3f}")
'''
M['nn2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
x = list(map(float, l[0].split()))
h = int(l[1])
W1 = [list(map(float, l[2 + i].split())) for i in range(h)]
b1 = list(map(float, l[2 + h].split()))
W2 = list(map(float, l[3 + h].split()))
b2 = float(l[4 + h])
hid = [max(0.0, sum(a * c for a, c in zip(x, W1[i])) + b1[i]) for i in range(h)]
out = sum(a * c for a, c in zip(hid, W2)) + b2
print("hidden: " + " ".join(f"{v:.2f}" for v in hid))
print(f"output: {out:.2f}")
'''
M['nn3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
lr, epochs = float(l[0].split()[0]), int(l[0].split()[1])
data = [list(map(float, x.split())) for x in l[1:]]
w = [0.0, 0.0]
b = 0.0
for e in range(epochs):
    err = 0
    for x1, x2, t in data:
        y = 1 if w[0] * x1 + w[1] * x2 + b > 0 else 0
        d = t - y
        if d != 0:
            err += 1
            w[0] += lr * d * x1
            w[1] += lr * d * x2
            b += lr * d
    print(f"epoch {e + 1}: errors {err}")
print(f"w1={w[0]:.2f} w2={w[1]:.2f} b={b:.2f}")
'''
M['tok1'] = '''import sys, re
t = sys.stdin.read().lower()
words = re.findall(r"[a-z']+", t)
c = {}
for w in words:
    c[w] = c.get(w, 0) + 1
for w, n in sorted(c.items(), key=lambda kv: (-kv[1], kv[0]))[:3]:
    print(f"{w} {n}")
'''
M['tok2'] = '''import sys, re
lines = sys.stdin.read().strip().split("\\n")
stop = set(lines[0].lower().split())
words = [w for w in re.findall(r"[a-z']+", " ".join(lines[1:]).lower()) if w not in stop]
c = {}
for w in words:
    c[w] = c.get(w, 0) + 1
for w, n in sorted(c.items(), key=lambda kv: (-kv[1], kv[0]))[:3]:
    print(f"{w} {n}")
'''
M['tok3'] = '''import sys, re
lines = sys.stdin.read().strip().split("\\n")
docs = [set(re.findall(r"[a-z']+", d.lower())) for d in lines[1:]]
term = lines[0].strip().lower()
import math
df = sum(term in d for d in docs)
idf = math.log(len(docs) / df) if df else 0
for i, d in enumerate(lines[1:]):
    ws = re.findall(r"[a-z']+", d.lower())
    tf = ws.count(term) / len(ws)
    print(f"doc {i + 1}: {tf * idf:.3f}")
'''
M['sent1'] = '''import sys, re
POS = {"good", "great", "love", "excellent", "happy", "fast"}
NEG = {"bad", "terrible", "hate", "slow", "broken", "awful"}
for line in sys.stdin.read().strip().split("\\n"):
    ws = re.findall(r"[a-z']+", line.lower())
    s = sum(w in POS for w in ws) - sum(w in NEG for w in ws)
    print("positive" if s > 0 else "negative" if s < 0 else "neutral")
'''
M['sent2'] = '''import sys, re
POS = {"good", "great", "love", "excellent", "happy", "fast"}
NEG = {"bad", "terrible", "hate", "slow", "broken", "awful"}
NOT = {"not", "never", "no"}
for line in sys.stdin.read().strip().split("\\n"):
    ws = re.findall(r"[a-z']+", line.lower())
    s = 0
    for i, w in enumerate(ws):
        v = 1 if w in POS else -1 if w in NEG else 0
        if v and i > 0 and ws[i - 1] in NOT:
            v = -v
        s += v
    print("positive" if s > 0 else "negative" if s < 0 else "neutral")
'''
M['sent3'] = '''import sys, re
POS = {"good", "great", "love", "excellent", "happy", "fast"}
NEG = {"bad", "terrible", "hate", "slow", "broken", "awful"}
NOT = {"not", "never", "no"}
def label(line):
    ws = re.findall(r"[a-z']+", line.lower())
    s = 0
    for i, w in enumerate(ws):
        v = 1 if w in POS else -1 if w in NEG else 0
        if v and i > 0 and ws[i - 1] in NOT:
            v = -v
        s += v
    return "positive" if s > 0 else "negative" if s < 0 else "neutral"
right = n = 0
for line in sys.stdin.read().strip().split("\\n"):
    gold, text = line.split("|", 1)
    p = label(text)
    n += 1
    right += p == gold.strip()
    if p != gold.strip():
        print(f"MISS {gold.strip()}->{p}: {text.strip()}")
print(f"Accuracy: {right / n:.2f}")
'''
M['fair1'] = '''import sys
c = {}
for l in sys.stdin.read().strip().split("\\n"):
    g, d = l.split()
    a = c.setdefault(g, [0, 0])
    a[0] += 1
    a[1] += int(d)
for g in sorted(c):
    print(f"{g}: {c[g][1] / c[g][0]:.2f}")
'''
M['fair2'] = '''import sys
c = {}
for l in sys.stdin.read().strip().split("\\n"):
    g, d = l.split()
    a = c.setdefault(g, [0, 0])
    a[0] += 1
    a[1] += int(d)
r = {g: c[g][1] / c[g][0] for g in c}
lo, hi = min(r, key=r.get), max(r, key=r.get)
ratio = r[lo] / r[hi]
for g in sorted(r):
    print(f"{g}: {r[g]:.2f}")
print(f"Impact ratio: {ratio:.2f}")
print("FLAG" if ratio < 0.8 else "OK")
'''
M['fair3'] = '''import sys
c = {}
for l in sys.stdin.read().strip().split("\\n"):
    g, y, p = l.split()
    a = c.setdefault(g, [0, 0, 0, 0])
    y, p = int(y), int(p)
    if y == 1:
        a[0] += 1
        a[1] += p
    else:
        a[2] += 1
        a[3] += p
for g in sorted(c):
    tpr = c[g][1] / c[g][0] if c[g][0] else 0
    fpr = c[g][3] / c[g][2] if c[g][2] else 0
    print(f"{g}: TPR {tpr:.2f} FPR {fpr:.2f}")
t = [c[g][1] / c[g][0] for g in c if c[g][0]]
print(f"TPR gap: {max(t) - min(t):.2f}")
'''
M['met1'] = '''import sys
a, p = [list(map(int, l.split())) for l in sys.stdin.read().strip().split("\\n")[:2]]
acc = sum(x == y for x, y in zip(a, p)) / len(a)
print(f"Accuracy: {acc:.2f}")
'''
M['met2'] = '''import sys
a, p = [list(map(int, l.split())) for l in sys.stdin.read().strip().split("\\n")[:2]]
tp = sum(x == 1 and y == 1 for x, y in zip(a, p))
fp = sum(x == 0 and y == 1 for x, y in zip(a, p))
fn = sum(x == 1 and y == 0 for x, y in zip(a, p))
pr = tp / (tp + fp) if tp + fp else 0
rc = tp / (tp + fn) if tp + fn else 0
f1 = 2 * pr * rc / (pr + rc) if pr + rc else 0
print(f"Precision: {pr:.2f}")
print(f"Recall: {rc:.2f}")
print(f"F1: {f1:.2f}")
'''
M['met3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
a = list(map(int, l[0].split()))
s = list(map(float, l[1].split()))
t = float(l[2])
p = [1 if v >= t else 0 for v in s]
tp = sum(x == 1 and y == 1 for x, y in zip(a, p))
fp = sum(x == 0 and y == 1 for x, y in zip(a, p))
fn = sum(x == 1 and y == 0 for x, y in zip(a, p))
tn = sum(x == 0 and y == 0 for x, y in zip(a, p))
pr = tp / (tp + fp) if tp + fp else 0
rc = tp / (tp + fn) if tp + fn else 0
print(f"TP {tp} FP {fp} FN {fn} TN {tn}")
print(f"Precision: {pr:.2f}")
print(f"Recall: {rc:.2f}")
'''
M['knn3_bug'] = M['knn2'].replace("for q in l[1 + n:]:\n    qx, qy = map(float, q.split())", "right = 0\nqs = l[1 + n:]\nfor q in qs:\n    qx, qy, truth = q.split()\n    qx, qy = float(qx), float(qy)").replace("    print(sorted(c for c, v in votes.items() if v == top)[0])", "    pred = sorted(c for c, v in votes.items() if v == top)[0]\n    right += pred == truth\n    print(pred)\nprint(f\"Accuracy: {right / len(qs):.2f}\")")
M['metrics_bug'] = M['met2'].replace("fn = sum(x == 1 and y == 0", "fn = sum(x == 0 and y == 0")
