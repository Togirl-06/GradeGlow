M = {}
M['flex1'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
w = float(l[0])
kids = l[1].split()
fixed = sum(float(k) for k in kids if not k.startswith("flex"))
flex = [int(k[4:]) for k in kids if k.startswith("flex")]
free = max(0.0, w - fixed)
unit = free / sum(flex) if flex else 0
out = [f"{float(k):.1f}" if not k.startswith("flex") else f"{unit * int(k[4:]):.1f}" for k in kids]
print("widths: " + " ".join(out))
'''
M['flex2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
w, pad, gap = map(float, l[0].split())
kids = l[1].split()
inner = w - 2 * pad - gap * (len(kids) - 1)
fixed = sum(float(k) for k in kids if not k.startswith("flex"))
flex = [int(k[4:]) for k in kids if k.startswith("flex")]
free = max(0.0, inner - fixed)
unit = free / sum(flex) if flex else 0
x = pad
for k in kids:
    kw = float(k) if not k.startswith("flex") else unit * int(k[4:])
    print(f"x={x:.1f} w={kw:.1f}")
    x += kw + gap
'''
M['flex3'] = '''import sys
for case in sys.stdin.read().strip().split("\\n"):
    w, kids = case.split(":")
    w = float(w)
    ks = kids.split()
    fixed = sum(float(k) for k in ks if not k.startswith("flex"))
    has_flex = any(k.startswith("flex") for k in ks)
    if fixed > w:
        print(f"A RenderFlex overflowed by {fixed - w:g} pixels on the right.")
    elif has_flex:
        print("OK (flexible children fill the remaining space)")
    else:
        print(f"OK ({w - fixed:g} px unused)")
'''
M['flex1_bug'] = M['flex1'].replace('free = max(0.0, w - fixed)', 'free = w')
M['nav1'] = '''import sys
st = []
for a in sys.stdin.read().strip().split("\\n"):
    cmd, _, arg = a.partition(" ")
    if cmd == "push":
        st.append(arg)
    elif cmd == "pop":
        if len(st) > 1:
            st.pop()
        else:
            print("cannot pop the last route")
    elif cmd == "replace":
        st[-1] = arg
print(" > ".join(st))
'''
M['nav2'] = '''import sys
st = []
for a in sys.stdin.read().strip().split("\\n"):
    cmd, _, arg = a.partition(" ")
    if cmd == "push":
        st.append(arg)
    elif cmd == "pop":
        if len(st) > 1:
            st.pop()
        else:
            print("cannot pop the last route")
    elif cmd == "replace":
        st[-1] = arg
    elif cmd == "popUntil":
        if arg in st:
            while st[-1] != arg:
                st.pop()
        else:
            print(f"{arg} not in stack")
    elif cmd == "pushAndRemoveAll":
        st = [arg]
print(" > ".join(st))
'''
M['nav3'] = '''import sys
ROUTES = {"": "home", "products": "products", "products/:id": "product", "cart": "cart", "orders/:id": "order"}
for url in sys.stdin.read().strip().split("\\n"):
    path = url.split("://", 1)[-1].split("/", 1)[-1] if "://" in url else url.lstrip("/")
    path = path.split("?")[0].strip("/")
    parts = path.split("/") if path else []
    stack = ["home"]
    ok = True
    for i in range(1, len(parts) + 1):
        seg = parts[:i]
        name = None
        for pat, n in ROUTES.items():
            pp = pat.split("/") if pat else []
            if len(pp) == len(seg) and all(a == b or a.startswith(":") for a, b in zip(pp, seg)):
                name = n + (f"({seg[-1]})" if pp and pp[-1].startswith(":") else "")
        if name is None:
            if i == len(parts):
                ok = False
            continue
        stack.append(name)
    print(" > ".join(stack) if ok else "home > not-found")
'''
M['js1'] = '''import sys, json
d = json.loads(sys.stdin.read())
print(f"{d['name']} <{d['email']}>")
print(f"Orders: {len(d['orders'])}")
'''
M['js2'] = '''import sys, json
for u in json.loads(sys.stdin.read()):
    name = (u.get("name") or "").strip() or "Unknown"
    avatar = u.get("avatar_url") or "default.png"
    vip = bool(u.get("vip", False))
    print(f"{u['id']}: {name} | {avatar} | {'VIP' if vip else 'standard'}")
'''
M['js3'] = '''import sys, json
pages = [json.loads(l) for l in sys.stdin.read().strip().split("\\n")]
seen, out = set(), []
for p in pages:
    for it in p["items"]:
        if it["id"] not in seen:
            seen.add(it["id"])
            out.append(it)
for it in out:
    print(f"{it['id']} {it['title']}")
print(f"{len(out)} unique items, has more: {'yes' if pages[-1].get('next') else 'no'}")
'''
M['js2_bug'] = '''import sys, json
for u in json.loads(sys.stdin.read()):
    print(f"{u['id']}: {u['name']} | {u['avatar_url']} | {'VIP' if u['vip'] else 'standard'}")
'''
M['bo1'] = '''import sys
base, n = sys.stdin.read().split()
base, n = float(base), int(n)
print(" ".join(f"{base * 2 ** i:g}" for i in range(n)))
'''
M['bo2'] = '''import sys
base, n, cap = sys.stdin.read().split()
base, n, cap = float(base), int(n), float(cap)
d = [min(cap, base * 2 ** i) for i in range(n)]
print("delays: " + " ".join(f"{x:g}" for x in d))
print(f"total wait: {sum(d):g}")
'''
M['bo3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
server = {}
for x in l[0].split(";"):
    k, v, t = x.split(",")
    server[k] = (v, int(t))
for x in l[1:]:
    k, v, t = x.split(",")
    t = int(t)
    if k not in server or t > server[k][1]:
        server[k] = (v, t)
        print(f"{k}: upload {v}")
    elif t < server[k][1]:
        print(f"{k}: keep server {server[k][0]} (newer)")
    else:
        print(f"{k}: in sync")
'''
M['cr1'] = '''import sys
s = sys.stdin.read().split()
ok = sum(x == "ok" for x in s)
print(f"Crash-free sessions: {ok / len(s) * 100:.2f}%")
'''
M['cr2'] = '''import sys
c = {}
for l in sys.stdin.read().strip().split("\\n"):
    v, user, res = l.split()
    u = c.setdefault(v, {})
    u[user] = u.get(user, True) and res == "ok"
for v in sorted(c, key=lambda s: tuple(map(int, s.split(".")))):
    users = c[v]
    print(f"{v}: crash-free users {sum(users.values()) / len(users) * 100:.1f}% ({len(users)} users)")
'''
M['cr3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
target = float(l[0])
prev = None
for row in l[1:]:
    v, users, crashed = row.split()
    rate = (1 - int(crashed) / int(users)) * 100
    note = ""
    if rate < target:
        note = " HALT ROLLOUT"
    elif prev is not None and rate < prev - 0.5:
        note = " REGRESSION"
    print(f"{v}: {rate:.2f}%{note}")
    prev = rate
'''
M['cr1_bug'] = M['cr1'].replace('ok / len(s)', '(len(s) - ok) / len(s)')
