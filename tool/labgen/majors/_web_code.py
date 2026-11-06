M = {}
J = {}
# ---------------- CSS specificity
M['spec1'] = '''import sys, re
def spec(s):
    pe = len(re.findall(r"::[a-z-]+", s))
    s = re.sub(r"::[a-z-]+", "", s)
    a = len(re.findall(r"#[\\w-]+", s))
    b = len(re.findall(r"\\.[\\w-]+|\\[[^\\]]*\\]|:[a-z-]+", s))
    c = len(re.findall(r"(?:^|[\\s>+~])([a-zA-Z][\\w-]*)", s)) + pe
    return a, b, c
for l in sys.stdin.read().strip().split("\\n"):
    a, b, c = spec(l.strip())
    print(f"{l.strip()}: ({a},{b},{c})")
'''
M['spec2'] = M['spec1'].replace('''for l in sys.stdin.read().strip().split("\\n"):
    a, b, c = spec(l.strip())
    print(f"{l.strip()}: ({a},{b},{c})")
''', '''l = [x.strip() for x in sys.stdin.read().strip().split("\\n")]
x, y = spec(l[0]), spec(l[1])
if x > y:
    print(f"{l[0]} wins")
elif y > x:
    print(f"{l[1]} wins")
else:
    print(f"tie: {l[1]} wins (later in source)")
''')
M['spec3'] = M['spec1'].replace('''for l in sys.stdin.read().strip().split("\\n"):
    a, b, c = spec(l.strip())
    print(f"{l.strip()}: ({a},{b},{c})")
''', '''rules = []
for i, l in enumerate(sys.stdin.read().strip().split("\\n")):
    sel, val = [x.strip() for x in l.split("|")]
    imp = val.endswith("!important")
    val = val.replace("!important", "").strip()
    rules.append(((1 if imp else 0,) + spec(sel) + (i,), sel, val))
k, sel, val = max(rules)
print(f"color: {val} (from {sel}{' !important' if k[0] else ''})")
''')
M['spec1_bug'] = M['spec1'].replace('b = len(re.findall(r"\\.[\\w-]+|\\[[^\\]]*\\]|:[a-z-]+", s))', 'b = len(re.findall(r"\\.[\\w-]+", s))')
# ---------------- JS lab (python + js)
M['cart1'] = '''import sys
t = 0
for l in sys.stdin.read().strip().split("\\n"):
    name, q, p = l.split(",")
    t += int(q) * float(p)
print(f"Total: {t:.2f}")
'''
J['cart1'] = '''const lines = require("fs").readFileSync(0, "utf8").trim().split("\\n");
const total = lines.map(l => l.split(",")).reduce((s, [n, q, p]) => s + Number(q) * Number(p), 0);
console.log(`Total: ${total.toFixed(2)}`);
'''
M['cart2'] = '''import sys
t = 0
for l in sys.stdin.read().strip().split("\\n"):
    name, q, p = l.split(",")
    q, p = int(q), float(p)
    line = q * p * (0.9 if q >= 10 else 0.95 if q >= 5 else 1)
    t += line
    print(f"{name}: {line:.2f}")
print(f"Total: {t:.2f}")
'''
J['cart2'] = '''const lines = require("fs").readFileSync(0, "utf8").trim().split("\\n");
let total = 0;
for (const l of lines) {
  const [name, qs, ps] = l.split(",");
  const q = Number(qs), p = Number(ps);
  const line = q * p * (q >= 10 ? 0.9 : q >= 5 ? 0.95 : 1);
  total += line;
  console.log(`${name}: ${line.toFixed(2)}`);
}
console.log(`Total: ${total.toFixed(2)}`);
'''
M['cart3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
stock = dict((a, int(b)) for a, b in (x.split(",") for x in l[0].split(";")))
ok = True
for x in l[1:]:
    name, q = x.split(",")
    q = int(q)
    have = stock.get(name, 0)
    if q > have:
        ok = False
        print(f"{name}: only {have} in stock")
    else:
        stock[name] = have - q
        print(f"{name}: reserved {q}")
print("Checkout OK" if ok else "Checkout blocked")
'''
J['cart3'] = '''const l = require("fs").readFileSync(0, "utf8").trim().split("\\n");
const stock = Object.fromEntries(l[0].split(";").map(x => { const [a, b] = x.split(","); return [a, Number(b)]; }));
let ok = true;
for (const x of l.slice(1)) {
  const [name, qs] = x.split(",");
  const q = Number(qs), have = stock[name] ?? 0;
  if (q > have) { ok = false; console.log(`${name}: only ${have} in stock`); }
  else { stock[name] = have - q; console.log(`${name}: reserved ${q}`); }
}
console.log(ok ? "Checkout OK" : "Checkout blocked");
'''
J['cart1_bug'] = '''const lines = require("fs").readFileSync(0, "utf8").trim().split("\\n");
const total = lines.map(l => l.split(",")).reduce((s, [n, q, p]) => s + q * p, "");
console.log(`Total: ${total}`);
'''
M['val1'] = '''import sys, re
for e in sys.stdin.read().strip().split("\\n"):
    e = e.strip()
    print(f"{e}: " + ("valid" if re.fullmatch(r"[^@\\s]+@[^@\\s]+\\.[a-zA-Z]{2,}", e) else "invalid"))
'''
J['val1'] = '''const ls = require("fs").readFileSync(0, "utf8").trim().split("\\n");
for (const raw of ls) { const e = raw.trim(); console.log(`${e}: ${/^[^@\\s]+@[^@\\s]+\\.[a-zA-Z]{2,}$/.test(e) ? "valid" : "invalid"}`); }
'''
M['val2'] = '''import sys
l = sys.stdin.read().split("\\n")
pw, confirm = l[0], l[1] if len(l) > 1 else ""
errs = []
if len(pw) < 12:
    errs.append("Password must be at least 12 characters")
if pw != confirm:
    errs.append("Passwords do not match")
print("\\n".join(errs) if errs else "OK")
'''
J['val2'] = '''const l = require("fs").readFileSync(0, "utf8").split("\\n");
const pw = l[0], confirm = l.length > 1 ? l[1] : "";
const errs = [];
if (pw.length < 12) errs.push("Password must be at least 12 characters");
if (pw !== confirm) errs.push("Passwords do not match");
console.log(errs.length ? errs.join("\\n") : "OK");
'''
M['val3'] = '''import sys, re
fields = dict(x.split("=", 1) for x in sys.stdin.read().strip().split("\\n"))
errs = []
if not fields.get("name", "").strip():
    errs.append("name: required")
if not re.fullmatch(r"[^@\\s]+@[^@\\s]+\\.[a-zA-Z]{2,}", fields.get("email", "").strip()):
    errs.append("email: enter a valid email address")
pc = fields.get("postcode", "").strip().upper()
if not re.fullmatch(r"[A-Z]{1,2}\\d[A-Z\\d]? ?\\d[A-Z]{2}", pc):
    errs.append("postcode: enter a valid UK postcode")
age = fields.get("age", "").strip()
if not age.isdigit() or not 16 <= int(age) <= 120:
    errs.append("age: must be a whole number from 16 to 120")
print("\\n".join(errs) if errs else "Form valid")
'''
J['val3'] = '''const fields = Object.fromEntries(require("fs").readFileSync(0, "utf8").trim().split("\\n").map(x => { const i = x.indexOf("="); return [x.slice(0, i), x.slice(i + 1)]; }));
const errs = [];
if (!(fields.name || "").trim()) errs.push("name: required");
if (!/^[^@\\s]+@[^@\\s]+\\.[a-zA-Z]{2,}$/.test((fields.email || "").trim())) errs.push("email: enter a valid email address");
if (!/^[A-Z]{1,2}\\d[A-Z\\d]? ?\\d[A-Z]{2}$/.test((fields.postcode || "").trim().toUpperCase())) errs.push("postcode: enter a valid UK postcode");
const age = (fields.age || "").trim();
if (!/^\\d+$/.test(age) || Number(age) < 16 || Number(age) > 120) errs.push("age: must be a whole number from 16 to 120");
console.log(errs.length ? errs.join("\\n") : "Form valid");
'''
J['val2_bug'] = J['val2'].replace('pw.length < 12', 'pw.length < 8').replace('pw !== confirm', 'pw != confirm && false')
M['deb1'] = '''import sys
ev = sys.stdin.read().split()
c = {}
for e in ev:
    c[e] = c.get(e, 0) + 1
for k in sorted(c):
    print(f"{k}: {c[k]}")
'''
J['deb1'] = '''const ev = require("fs").readFileSync(0, "utf8").trim().split(/\\s+/);
const c = {};
for (const e of ev) c[e] = (c[e] || 0) + 1;
for (const k of Object.keys(c).sort()) console.log(`${k}: ${c[k]}`);
'''
M['deb2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
d = int(l[0])
ts = list(map(int, l[1].split()))
fired = [ts[i] + d for i in range(len(ts)) if i == len(ts) - 1 or ts[i + 1] - ts[i] >= d]
print("Search fired at: " + " ".join(map(str, fired)))
print(f"Requests saved: {len(ts) - len(fired)}")
'''
J['deb2'] = '''const l = require("fs").readFileSync(0, "utf8").trim().split("\\n");
const d = Number(l[0]); const ts = l[1].split(/\\s+/).map(Number);
const fired = ts.filter((t, i) => i === ts.length - 1 || ts[i + 1] - t >= d).map(t => t + d);
console.log("Search fired at: " + fired.join(" "));
console.log(`Requests saved: ${ts.length - fired.length}`);
'''
M['deb3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
w = int(l[0])
ts = list(map(int, l[1].split()))
run, last = [], None
for t in ts:
    if last is None or t - last >= w:
        run.append(t)
        last = t
print("Handler ran at: " + " ".join(map(str, run)))
print(f"Calls dropped: {len(ts) - len(run)}")
'''
J['deb3'] = '''const l = require("fs").readFileSync(0, "utf8").trim().split("\\n");
const w = Number(l[0]); const ts = l[1].split(/\\s+/).map(Number);
const run = []; let last = null;
for (const t of ts) if (last === null || t - last >= w) { run.push(t); last = t; }
console.log("Handler ran at: " + run.join(" "));
console.log(`Calls dropped: ${ts.length - run.length}`);
'''
# ---------------- frontend
M['red1'] = '''import sys
todos = []
for a in sys.stdin.read().strip().split("\\n"):
    cmd, _, arg = a.partition(" ")
    if cmd == "add":
        todos.append([arg, False])
    elif cmd == "toggle":
        todos[int(arg) - 1][1] = not todos[int(arg) - 1][1]
    elif cmd == "remove":
        todos.pop(int(arg) - 1)
for i, (t, d) in enumerate(todos):
    print(f"{i + 1}. [{'x' if d else ' '}] {t}")
print(f"{sum(not d for _, d in todos)} left")
'''
M['red2'] = '''import sys
past, state, future = [], [], []
for a in sys.stdin.read().strip().split("\\n"):
    cmd, _, arg = a.partition(" ")
    if cmd == "undo":
        if past:
            future.append(state)
            state = past.pop()
        continue
    if cmd == "redo":
        if future:
            past.append(state)
            state = future.pop()
        continue
    new = list(state)
    if cmd == "add":
        new.append(arg)
    elif cmd == "remove":
        new.pop(int(arg) - 1)
    past.append(state)
    state = new
    future = []
print(", ".join(state) if state else "(empty)")
'''
M['route'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
n = int(l[0])
routes = [r.split() for r in l[1:1 + n]]
for url in l[1 + n:]:
    path = url.split("?")[0].rstrip("/") or "/"
    parts = path.strip("/").split("/") if path != "/" else []
    out = "404 Not Found"
    for pat, name in routes:
        pp = pat.strip("/").split("/") if pat != "/" else []
        if len(pp) != len(parts):
            continue
        params = {}
        if all(a == b or (a.startswith(":") and params.setdefault(a[1:], b)) for a, b in zip(pp, parts)):
            out = name + ("" if not params else " " + " ".join(f"{k}={v}" for k, v in params.items()))
            break
    print(f"{url} -> {out}")
'''
M['page1'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
size, page = map(int, l[0].split())
items = l[1].split()
pages = max(1, -(-len(items) // size))
page = min(max(page, 1), pages)
print(" ".join(items[(page - 1) * size: page * size]))
print(f"Page {page} of {pages}")
'''
M['page2'] = '''import sys
cur, total = map(int, sys.stdin.read().split())
show = sorted(set(p for p in (1, total, cur - 1, cur, cur + 1) if 1 <= p <= total))
out, prev = [], 0
for p in show:
    if p - prev > 1:
        out.append("...")
    out.append(f"[{p}]" if p == cur else str(p))
    prev = p
print(" ".join(out))
'''
M['page3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
q = dict(x.split("=") for x in l[0].split("&"))
rows = [r.split(",") for r in l[1:]]
if "category" in q:
    rows = [r for r in rows if r[1] == q["category"]]
if "max" in q:
    rows = [r for r in rows if float(r[2]) <= float(q["max"])]
key = q.get("sort", "name")
desc = key.startswith("-")
key = key.lstrip("-")
idx = {"name": 0, "price": 2}[key]
rows.sort(key=lambda r: (float(r[idx]) if idx == 2 else r[idx], r[0]), reverse=desc)
for r in rows:
    print(f"{r[0]} ({r[1]}) £{float(r[2]):.2f}")
print(f"{len(rows)} results")
'''
M['page1_bug'] = M['page1'].replace('items[(page - 1) * size: page * size]', 'items[page * size: (page + 1) * size]')
# ---------------- backend
M['api1'] = '''import sys
users = {"1": "Ana", "2": "Ben", "3": "Cara"}
for r in sys.stdin.read().strip().split("\\n"):
    method, path = r.split()
    p = path.strip("/").split("/")
    if method == "GET" and p == ["users"]:
        print("200 " + ",".join(users[k] for k in sorted(users)))
    elif method == "GET" and len(p) == 2 and p[0] == "users":
        print(f"200 {users[p[1]]}" if p[1] in users else "404 user not found")
    elif p[0] == "users":
        print("405 method not allowed")
    else:
        print("404 not found")
'''
M['api2'] = '''import sys, re
users = {}
nxt = 1
for r in sys.stdin.read().strip().split("\\n"):
    parts = r.split(" ", 2)
    method, path = parts[0], parts[1]
    body = dict(x.split("=", 1) for x in parts[2].split("&")) if len(parts) > 2 else {}
    if method == "POST" and path == "/users":
        errs = []
        if not body.get("name"):
            errs.append("name required")
        if not re.fullmatch(r"[^@\\s]+@[^@\\s]+\\.[a-z]{2,}", body.get("email", "")):
            errs.append("valid email required")
        if errs:
            print("400 " + "; ".join(errs))
        elif any(u["email"] == body["email"] for u in users.values()):
            print("409 email already registered")
        else:
            users[nxt] = body
            print(f"201 created id={nxt}")
            nxt += 1
    elif method == "DELETE" and path.startswith("/users/"):
        i = int(path.split("/")[2])
        if i in users:
            del users[i]
            print("204 deleted")
        else:
            print("404 user not found")
    else:
        print("404 not found")
'''
M['rate'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
cap, refill = map(float, l[0].split())
b = {}
for r in l[1:]:
    t, client = r.split()
    t = float(t)
    tokens, last = b.get(client, (cap, t))
    tokens = min(cap, tokens + (t - last) * refill)
    if tokens >= 1:
        b[client] = (tokens - 1, t)
        print(f"{t:g} {client}: 200")
    else:
        b[client] = (tokens, t)
        print(f"{t:g} {client}: 429 Too Many Requests")
'''
M['acl1'] = '''import sys
PERM = {"viewer": {"read"}, "editor": {"read", "write"}, "admin": {"read", "write", "delete", "manage_users"}}
for r in sys.stdin.read().strip().split("\\n"):
    user, role, action = r.split()
    print(f"{user} {action}: " + ("ALLOW" if action in PERM.get(role, set()) else "DENY"))
'''
M['acl2'] = '''import sys
PERM = {"viewer": {"read"}, "editor": {"read", "write"}, "admin": {"read", "write", "delete", "manage_users"}}
for r in sys.stdin.read().strip().split("\\n"):
    user, role, action, owner = r.split()
    ok = action in PERM.get(role, set())
    if role == "editor" and action == "write" and owner != user:
        ok = False
    print(f"{user} {action} doc of {owner}: " + ("ALLOW" if ok else "DENY"))
'''
M['acl3'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
now = int(l[0])
for r in l[1:]:
    tok, scope_need = r.split()
    user, exp, scopes = tok.split(":")
    if now >= int(exp):
        print(f"{user}: 401 token expired")
    elif scope_need not in scopes.split(","):
        print(f"{user}: 403 missing scope {scope_need}")
    else:
        print(f"{user}: 200 OK")
'''
M['acl1_bug'] = M['acl1'].replace('("ALLOW" if action in PERM.get(role, set()) else "DENY")', '("ALLOW" if role else "DENY")')
# ---------------- accessibility
_LUM = '''def lum(h):
    h = h.lstrip("#")
    c = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    c = [v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4 for v in c]
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]
def ratio(a, b):
    x, y = sorted((lum(a), lum(b)), reverse=True)
    return (x + 0.05) / (y + 0.05)
'''
M['con1'] = 'import sys\n' + _LUM + '''for l in sys.stdin.read().strip().split("\\n"):
    a, b = l.split()
    print(f"{a} on {b}: {ratio(a, b):.2f}:1")
'''
M['con2'] = 'import sys\n' + _LUM + '''for l in sys.stdin.read().strip().split("\\n"):
    a, b, size = l.split()
    r = ratio(a, b)
    big = size == "large"
    aa = r >= (3 if big else 4.5)
    aaa = r >= (4.5 if big else 7)
    print(f"{a} on {b} ({size}): {r:.2f}:1 AA {'pass' if aa else 'fail'}, AAA {'pass' if aaa else 'fail'}")
'''
M['con3'] = 'import sys\n' + _LUM + '''def darker(h, f):
    h = h.lstrip("#")
    return "#" + "".join(f"{round(int(h[i:i + 2], 16) * f):02x}" for i in (0, 2, 4))
for l in sys.stdin.read().strip().split("\\n"):
    fg, bg = l.split()
    f, c = 1.0, fg
    steps = 0
    while ratio(c, bg) < 4.5 and steps < 20:
        steps += 1
        f = 1 - 0.05 * steps
        c = darker(fg, f)
    print(f"{fg} -> {c} ({ratio(c, bg):.2f}:1 after {steps} step(s))")
'''
M['con1_bug'] = M['con1'].replace('return (x + 0.05) / (y + 0.05)', 'return x / max(y, 0.0001)')
