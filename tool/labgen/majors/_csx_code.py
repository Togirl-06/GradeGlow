M = {}
# ---------------- fundamentals
M['rc1'] = '''import sys
t = sum(float(x) for x in sys.stdin.read().split())
print(f"Total: {t:.2f}")
'''
M['rc2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
rate = float(l[0])
sub = sum(float(x) for x in l[1].split())
tax = round(sub * rate / 100 + 1e-9, 2)
print(f"Subtotal: {sub:.2f}")
print(f"Tax: {tax:.2f}")
print(f"Total: {sub + tax:.2f}")
'''
M['rc3'] = '''import sys
total, n = sys.stdin.read().split()
pence = round(float(total) * 100)
n = int(n)
base, extra = divmod(pence, n)
shares = [base + (1 if i < extra else 0) for i in range(n)]
print(" ".join(f"{s / 100:.2f}" for s in shares))
'''
M['wd1'] = '''import sys
print(len(sys.stdin.read().split()))
'''
M['wd2'] = '''import sys, re
w = re.findall(r"[A-Za-z']+", sys.stdin.read())
best = max(w, key=len)
print(f"{best} ({len(best)})")
'''
M['wd3'] = '''import sys, re
for l in sys.stdin.read().strip().split("\\n"):
    s = re.sub(r"[^a-z0-9]", "", l.lower())
    print("palindrome" if s and s == s[::-1] else "not a palindrome")
'''
M['wd2_bug'] = M['wd2'].replace('best = max(w, key=len)', 'best = w[-1]')
M['ck1'] = '''import sys
for t in sys.stdin.read().split():
    h, m = map(int, t.split(":"))
    suf = "am" if h < 12 else "pm"
    h12 = h % 12 or 12
    print(f"{h12}:{m:02d} {suf}")
'''
M['ck2'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    t, add = l.split()
    h, m = map(int, t.split(":"))
    tot = (h * 60 + m + int(add)) % 1440
    print(f"{tot // 60:02d}:{tot % 60:02d}")
'''
M['ck3'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    a, b = l.split()
    ha, ma = map(int, a.split(":"))
    hb, mb = map(int, b.split(":"))
    d = (hb * 60 + mb - ha * 60 - ma) % 1440
    print(f"{d // 60}h {d % 60:02d}m")
'''
M['ck1_bug'] = M['ck1'].replace('h12 = h % 12 or 12', 'h12 = h % 12')
M['cd1'] = '''import sys
for s in sys.stdin.read().split():
    digits = [10 if c in "Xx" else int(c) for c in s]
    ok = len(digits) == 10 and sum((10 - i) * d for i, d in enumerate(digits)) % 11 == 0
    print(f"{s}: {'valid' if ok else 'invalid'}")
'''
M['cd2'] = '''import sys
for s in sys.stdin.read().strip().split("\\n"):
    d = [int(c) for c in s if c.isdigit()]
    tot = 0
    for i, x in enumerate(reversed(d)):
        if i % 2 == 1:
            x *= 2
            if x > 9:
                x -= 9
        tot += x
    print(f"{s}: {'passes' if tot % 10 == 0 else 'fails'} Luhn check")
'''
M['cd3'] = '''import sys
for s in sys.stdin.read().strip().split("\\n"):
    d = [int(c) for c in s if c.isdigit()]
    if len(d) != 10:
        print(f"{s}: invalid length")
        continue
    r = 11 - sum((10 - i) * d[i] for i in range(9)) % 11
    check = 0 if r == 11 else r
    if r == 10 or check != d[9]:
        print(f"{s}: invalid")
    else:
        print(f"{s}: valid")
'''
M['pr1'] = '''import sys
n = int(sys.stdin.read())
for i in range(1, 11):
    print(f"{i} x {n} = {i * n}")
'''
M['pr2'] = '''import sys
n = int(sys.stdin.read())
p = [i for i in range(2, n + 1) if all(i % d for d in range(2, int(i ** 0.5) + 1))]
print(" ".join(map(str, p)) if p else "none")
'''
M['pr3'] = '''import sys
for t in sys.stdin.read().split():
    n = int(t)
    f, d, m = [], 2, n
    while d * d <= m:
        while m % d == 0:
            f.append(d)
            m //= d
        d += 1
    if m > 1:
        f.append(m)
    print(f"{n} = " + " x ".join(map(str, f)))
'''
M['pr2_bug'] = M['pr2'].replace('range(2, int(i ** 0.5) + 1)', 'range(2, int(i ** 0.5))')
# ---------------- DSA
M['br1'] = '''import sys
for s in sys.stdin.read().split():
    d = 0
    ok = True
    for c in s:
        d += 1 if c == "(" else -1
        if d < 0:
            ok = False
    print(f"{s}: {'balanced' if ok and d == 0 else 'unbalanced'}")
'''
M['br2'] = '''import sys
P = {")": "(", "]": "[", "}": "{"}
for s in sys.stdin.read().split():
    st = []
    ok = True
    for c in s:
        if c in "([{":
            st.append(c)
        elif c in P:
            if not st or st.pop() != P[c]:
                ok = False
                break
    print(f"{s}: {'balanced' if ok and not st else 'unbalanced'}")
'''
M['br3'] = '''import sys
P = {")": "(", "]": "[", "}": "{"}
for s in sys.stdin.read().strip().split("\\n"):
    st = []
    err = None
    for i, c in enumerate(s):
        if c in "([{":
            st.append((c, i))
        elif c in P:
            if not st or st[-1][0] != P[c]:
                err = f"unexpected {c} at {i + 1}"
                break
            st.pop()
    if err is None and st:
        err = f"unclosed {st[-1][0]} at {st[-1][1] + 1}"
    print(f"{s}: {err or 'balanced'}")
'''
M['br2_bug'] = M['br1']
M['bs1'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
a = list(map(int, l[0].split()))
for t in map(int, l[1].split()):
    lo, hi, res = 0, len(a) - 1, -1
    while lo <= hi:
        mid = (lo + hi) // 2
        if a[mid] == t:
            res = mid
            break
        if a[mid] < t:
            lo = mid + 1
        else:
            hi = mid - 1
    print(f"{t}: {res}")
'''
M['bs2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
a = list(map(int, l[0].split()))
for t in map(int, l[1].split()):
    lo, hi = 0, len(a)
    while lo < hi:
        mid = (lo + hi) // 2
        if a[mid] < t:
            lo = mid + 1
        else:
            hi = mid
    first = lo if lo < len(a) and a[lo] == t else -1
    lo2, hi2 = 0, len(a)
    while lo2 < hi2:
        mid = (lo2 + hi2) // 2
        if a[mid] <= t:
            lo2 = mid + 1
        else:
            hi2 = mid
    print(f"{t}: first {first}, count {lo2 - lo if first != -1 else 0}")
'''
M['bs3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
a = list(map(int, l[0].split()))
for t in map(int, l[1].split()):
    lo, hi, c, res = 0, len(a) - 1, 0, -1
    while lo <= hi:
        mid = (lo + hi) // 2
        c += 1
        if a[mid] == t:
            res = mid
            break
        if a[mid] < t:
            lo = mid + 1
        else:
            hi = mid - 1
    lin = (a.index(t) + 1) if t in a else len(a)
    print(f"{t}: index {res}, binary {c} comparisons, linear {lin} comparisons")
'''
M['bs1_bug'] = M['bs1'].replace('lo = mid + 1', 'lo = mid')
M['so1'] = '''import sys
print(" ".join(map(str, sorted(map(int, sys.stdin.read().split())))))
'''
M['so2'] = '''import sys
rows = [l.split(",") for l in sys.stdin.read().strip().split("\\n")]
rows.sort(key=lambda r: (-int(r[1]), r[0]))
for n, s in rows:
    print(f"{n} {s}")
'''
M['so3'] = '''import sys, heapq
lists = [list(map(int, l.split())) for l in sys.stdin.read().strip().split("\\n")]
h = [(x[0], i, 0) for i, x in enumerate(lists) if x]
heapq.heapify(h)
out = []
while h:
    v, i, j = heapq.heappop(h)
    out.append(v)
    if j + 1 < len(lists[i]):
        heapq.heappush(h, (lists[i][j + 1], i, j + 1))
print(" ".join(map(str, out)))
'''
M['so1_bug'] = '''import sys
print(" ".join(sorted(sys.stdin.read().split())))
'''
M['gr1'] = '''import sys
adj = {}
for l in sys.stdin.read().strip().split("\\n"):
    a, b = l.split()
    adj.setdefault(a, set()).add(b)
    adj.setdefault(b, set()).add(a)
for k in sorted(adj):
    print(f"{k}: {' '.join(sorted(adj[k]))}")
'''
M['gr2'] = '''import sys
from collections import deque
l = sys.stdin.read().strip().split("\\n")
src, dst = l[0].split()
adj = {}
for e in l[1:]:
    a, b = e.split()
    adj.setdefault(a, set()).add(b)
    adj.setdefault(b, set()).add(a)
dist = {src: 0}
q = deque([src])
while q:
    u = q.popleft()
    for v in adj.get(u, ()):
        if v not in dist:
            dist[v] = dist[u] + 1
            q.append(v)
print(f"{src} to {dst}: {dist[dst]} hops" if dst in dist else f"{src} to {dst}: unreachable")
'''
M['gr3'] = '''import sys
from collections import deque
l = sys.stdin.read().strip().split("\\n")
src, dst = l[0].split()
adj = {}
for e in l[1:]:
    a, b = e.split()
    adj.setdefault(a, set()).add(b)
    adj.setdefault(b, set()).add(a)
prev = {src: None}
q = deque([src])
while q:
    u = q.popleft()
    for v in sorted(adj.get(u, ())):
        if v not in prev:
            prev[v] = u
            q.append(v)
if dst not in prev:
    print("No route")
else:
    path = []
    x = dst
    while x is not None:
        path.append(x)
        x = prev[x]
    print(" -> ".join(reversed(path)))
'''
M['ha1'] = '''import sys
c = {}
for w in sys.stdin.read().lower().split():
    c[w] = c.get(w, 0) + 1
for w in sorted(c):
    print(f"{w} {c[w]}")
'''
M['ha2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
a = list(map(int, l[0].split()))
t = int(l[1])
seen = {}
ans = None
for i, x in enumerate(a):
    if t - x in seen:
        ans = (seen[t - x], i)
        break
    seen.setdefault(x, i)
print(f"{ans[0]} {ans[1]}" if ans else "none")
'''
M['ha3'] = '''import sys
g = {}
for w in sys.stdin.read().split():
    g.setdefault("".join(sorted(w.lower())), []).append(w)
groups = sorted((sorted(v) for v in g.values()), key=lambda v: (-len(v), v[0]))
for v in groups:
    print(" ".join(v))
'''
M['ha2_bug'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
a = list(map(int, l[0].split()))
t = int(l[1])
for i in range(len(a)):
    for j in range(len(a)):
        if a[i] + a[j] == t:
            print(f"{i} {j}")
            sys.exit()
print("none")
'''
# ---------------- OS
M['rr1'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
q = int(l[0])
jobs = [[p.split()[0], int(p.split()[1])] for p in l[1:]]
from collections import deque
d = deque(jobs)
t = 0
seq = []
while d:
    name, rem = d.popleft()
    run = min(q, rem)
    seq.append(f"{name}({t}-{t + run})")
    t += run
    if rem - run > 0:
        d.append([name, rem - run])
print(" ".join(seq))
'''
M['rr2'] = '''import sys
from collections import deque
l = sys.stdin.read().strip().split("\\n")
q = int(l[0])
jobs = [(p.split()[0], int(p.split()[1])) for p in l[1:]]
burst = dict(jobs)
d = deque([list(j) for j in jobs])
t = 0
done = {}
while d:
    name, rem = d.popleft()
    run = min(q, rem)
    t += run
    if rem - run > 0:
        d.append([name, rem - run])
    else:
        done[name] = t
for name, b in jobs:
    print(f"{name}: finish {done[name]}, waiting {done[name] - b}")
print(f"Average waiting: {sum(done[n] - b for n, b in jobs) / len(jobs):.2f}")
'''
M['rr3'] = '''import sys
from collections import deque
l = sys.stdin.read().strip().split("\\n")
q = int(l[0])
jobs = [(p.split()[0], int(p.split()[1]), int(p.split()[2])) for p in l[1:]]
jobs.sort(key=lambda j: (j[1], j[0]))
rem = {n: b for n, a, b in jobs}
arr = {n: a for n, a, b in jobs}
t, i, d, done = 0, 0, deque(), {}
while len(done) < len(jobs):
    while i < len(jobs) and jobs[i][1] <= t:
        d.append(jobs[i][0]); i += 1
    if not d:
        t = jobs[i][1]
        continue
    n = d.popleft()
    run = min(q, rem[n])
    t += run
    rem[n] -= run
    while i < len(jobs) and jobs[i][1] <= t:
        d.append(jobs[i][0]); i += 1
    if rem[n] > 0:
        d.append(n)
    else:
        done[n] = t
tat = {n: done[n] - arr[n] for n in done}
for n, a, b in jobs:
    print(f"{n}: turnaround {tat[n]}, waiting {tat[n] - b}")
print(f"Average turnaround: {sum(tat.values()) / len(jobs):.2f}")
'''
M['pg1'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
f = int(l[0])
mem, faults = [], 0
for p in l[1].split():
    if p not in mem:
        faults += 1
        if len(mem) == f:
            mem.pop(0)
        mem.append(p)
print(f"FIFO page faults: {faults}")
'''
M['pg2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
f = int(l[0])
mem, faults = [], 0
for p in l[1].split():
    if p in mem:
        mem.remove(p)
    else:
        faults += 1
        if len(mem) == f:
            mem.pop(0)
    mem.append(p)
print(f"LRU page faults: {faults}")
'''
M['pg3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
f = int(l[0])
refs = l[1].split()
def fifo():
    mem, n = [], 0
    for p in refs:
        if p not in mem:
            n += 1
            if len(mem) == f: mem.pop(0)
            mem.append(p)
    return n
def lru():
    mem, n = [], 0
    for p in refs:
        if p in mem: mem.remove(p)
        else:
            n += 1
            if len(mem) == f: mem.pop(0)
        mem.append(p)
    return n
def opt():
    mem, n = [], 0
    for i, p in enumerate(refs):
        if p in mem: continue
        n += 1
        if len(mem) < f:
            mem.append(p); continue
        fut = refs[i + 1:]
        victim = max(mem, key=lambda x: (fut.index(x) if x in fut else 10 ** 9, -mem.index(x)))
        mem[mem.index(victim)] = p
    return n
r = {"FIFO": fifo(), "LRU": lru(), "OPT": opt()}
print(" ".join(f"{k} {v}" for k, v in r.items()))
print("Best practical: " + ("LRU" if r["LRU"] <= r["FIFO"] else "FIFO"))
'''
M['pg2_bug'] = M['pg1'].replace('FIFO page faults', 'LRU page faults')
M['mm1'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
size = int(l[0])
for a in map(int, l[1].split()):
    print(f"{a}: page {a // size}, offset {a % size}")
'''
M['mm2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
size = int(l[0])
table = dict((int(p), (None if f == "-" else int(f))) for p, f in (x.split(":") for x in l[1].split()))
for a in map(int, l[2].split()):
    p, o = divmod(a, size)
    fr = table.get(p)
    print(f"{a}: page fault (page {p})" if fr is None else f"{a}: physical {fr * size + o}")
'''
M['mm3'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    hit, tlb, mem = map(float, l.split())
    h = hit / 100
    eat = h * (tlb + mem) + (1 - h) * (tlb + 2 * mem)
    print(f"Hit ratio {hit:g}%: EAT {eat:.1f} ns")
'''
M['bk1'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
n = int(l[0])
mx = [list(map(int, x.split())) for x in l[1:1 + n]]
al = [list(map(int, x.split())) for x in l[1 + n:1 + 2 * n]]
for i in range(n):
    print(f"P{i}: need " + " ".join(str(m - a) for m, a in zip(mx[i], al[i])))
'''
M['bk2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
n = int(l[0])
mx = [list(map(int, x.split())) for x in l[1:1 + n]]
al = [list(map(int, x.split())) for x in l[1 + n:1 + 2 * n]]
work = list(map(int, l[1 + 2 * n].split()))
need = [[m - a for m, a in zip(mx[i], al[i])] for i in range(n)]
done, seq = [False] * n, []
progress = True
while progress:
    progress = False
    for i in range(n):
        if not done[i] and all(x <= w for x, w in zip(need[i], work)):
            work = [w + a for w, a in zip(work, al[i])]
            done[i] = True
            seq.append(f"P{i}")
            progress = True
print("SAFE: " + " ".join(seq) if all(done) else "UNSAFE")
'''
M['bk3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
n = int(l[0])
mx = [list(map(int, x.split())) for x in l[1:1 + n]]
al = [list(map(int, x.split())) for x in l[1 + n:1 + 2 * n]]
av = list(map(int, l[1 + 2 * n].split()))
p, *req = l[2 + 2 * n].split()
i = int(p[1:])
req = list(map(int, req))
need = [[m - a for m, a in zip(mx[k], al[k])] for k in range(n)]
if any(r > x for r, x in zip(req, need[i])):
    print("DENIED: request exceeds declared maximum")
elif any(r > a for r, a in zip(req, av)):
    print("WAIT: resources not available")
else:
    av2 = [a - r for a, r in zip(av, req)]
    al[i] = [a + r for a, r in zip(al[i], req)]
    need[i] = [x - r for x, r in zip(need[i], req)]
    work, done = av2[:], [False] * n
    progress = True
    while progress:
        progress = False
        for k in range(n):
            if not done[k] and all(x <= w for x, w in zip(need[k], work)):
                work = [w + a for w, a in zip(work, al[k])]
                done[k] = True
                progress = True
    print("GRANTED: state remains safe" if all(done) else "DENIED: would leave the system unsafe")
'''
