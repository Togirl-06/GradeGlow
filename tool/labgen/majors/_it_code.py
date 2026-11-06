M = {}
M['up1'] = '''import sys
r = sys.stdin.read().split()
ok = sum(x == "UP" for x in r)
print(f"Availability: {ok / len(r) * 100:.2f}%")
'''
M['up2'] = '''import sys
c = {}
for l in sys.stdin.read().strip().split("\\n"):
    t, host, s = l.split()
    a = c.setdefault(host, [0, 0])
    a[0] += 1
    a[1] += s == "UP"
for h in sorted(c):
    pct = c[h][1] / c[h][0] * 100
    print(f"{h}: {pct:.2f}%" + (" BELOW SLA" if pct < 99.5 else ""))
'''
M['up3'] = '''import sys
cur = {}
out = []
last = {}
for l in sys.stdin.read().strip().split("\\n"):
    t, host, s = l.split()
    if s == "DOWN" and host not in cur:
        cur[host] = t
    if s == "UP" and host in cur:
        out.append((cur.pop(host), host, t))
    last[host] = t
for h, start in cur.items():
    out.append((start, h, "ongoing"))
for start, h, end in sorted(out):
    print(f"{h} down {start} - {end}")
if not out:
    print("No outages")
'''
M['up1_bug'] = M['up1'].replace('/ len(r) * 100', '/ (len(r) + 1) * 100')
M['df1'] = '''import sys
l = sys.stdin.read().strip().split("\\n")[1:]
for row in l:
    fs, size, used, mount = row.split()
    pct = int(used) / int(size) * 100
    flag = "CRITICAL" if pct >= 90 else "WARNING" if pct >= 80 else "OK"
    print(f"{mount}: {pct:.0f}% {flag}")
'''
M['df2'] = '''import sys
t = {}
for row in sys.stdin.read().strip().split("\\n"):
    size, path = row.split()
    top = "/" + path.strip("/").split("/")[0]
    t[top] = t.get(top, 0) + int(size)
for k in sorted(t, key=lambda k: (-t[k], k))[:3]:
    print(f"{k}: {t[k] / 1024:.1f} GB")
'''
M['df3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
keep = int(l[0])
logs = {}
for f in l[1:]:
    name, date = f.split()
    logs.setdefault(name, []).append(date)
for name in sorted(logs):
    ds = sorted(logs[name], reverse=True)
    for d in ds[keep:]:
        print(f"delete {name}_{d}.log")
    print(f"{name}: kept {min(keep, len(ds))}")
'''
M['acc1'] = '''import sys
seen = {}
for l in sys.stdin.read().strip().split("\\n"):
    first, last = l.split()
    base = (first[0] + "".join(c for c in last if c.isalpha())).lower()
    n = seen.get(base, 0) + 1
    seen[base] = n
    print(base if n == 1 else f"{base}{n}")
'''
M['acc2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
hr = set(l[0].split())
ad = l[1].split()
svc = [a for a in ad if a.startswith("svc_")]
leavers = sorted(a for a in ad if a not in hr and not a.startswith("svc_"))
missing = sorted(h for h in hr if h not in ad)
for a in leavers:
    print(f"DISABLE {a}")
for h in missing:
    print(f"CREATE {h}")
print(f"Service accounts reviewed separately: {len(svc)}")
'''
M['acc3'] = '''import sys
from datetime import date
l = sys.stdin.read().strip().split("\\n")
today = date.fromisoformat(l[0])
for row in l[1:]:
    user, last, admin = row.split()
    if last == "never":
        print(f"{user}: never logged in - DISABLE")
        continue
    d = (today - date.fromisoformat(last)).days
    limit = 30 if admin == "admin" else 90
    if d > limit:
        print(f"{user}: inactive {d} days - DISABLE")
    else:
        print(f"{user}: active")
'''
M['acc1_bug'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    first, last = l.split()
    print((first[0] + last).lower())
'''
