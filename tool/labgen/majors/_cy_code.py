M = {}
_IP = '''def ip2i(s):
    a = list(map(int, s.split(".")))
    return (a[0] << 24) | (a[1] << 16) | (a[2] << 8) | a[3]
def i2ip(n):
    return ".".join(str((n >> s) & 255) for s in (24, 16, 8, 0))
def mask(p):
    return (0xFFFFFFFF << (32 - p)) & 0xFFFFFFFF if p else 0
'''
M['sub1'] = '''import sys
''' + _IP + '''ip, p = sys.stdin.read().strip().split("/")
p = int(p)
net = ip2i(ip) & mask(p)
print(f"Network: {i2ip(net)}/{p}")
print(f"Broadcast: {i2ip(net | (~mask(p) & 0xFFFFFFFF))}")
'''
M['sub2'] = '''import sys
''' + _IP + '''ip, p = sys.stdin.read().strip().split("/")
p = int(p)
net = ip2i(ip) & mask(p)
bc = net | (~mask(p) & 0xFFFFFFFF)
if p >= 31:
    print("Usable hosts: 0")
else:
    print(f"Usable hosts: {bc - net - 1}")
    print(f"Range: {i2ip(net + 1)} - {i2ip(bc - 1)}")
'''
M['sub3'] = '''import sys, math
''' + _IP + '''l = sys.stdin.read().strip().split("\\n")
base, bp = l[0].split("/")
cur = ip2i(base)
end = cur + 2 ** (32 - int(bp))
needs = []
for x in l[1:]:
    name, h = x.split()
    needs.append((int(h), name))
for h, name in sorted(needs, key=lambda t: (-t[0], t[1])):
    size = 2 ** math.ceil(math.log2(h + 2))
    p = 32 - int(math.log2(size))
    if cur + size > end:
        print(f"{name}: DOES NOT FIT")
        continue
    print(f"{name}: {i2ip(cur)}/{p}")
    cur += size
'''
M['sub2_bug'] = M['sub2'].replace('bc - net - 1', 'bc - net + 1')
M['fw1'] = '''import sys
SVC = {"22": "SSH", "25": "SMTP", "53": "DNS", "80": "HTTP", "443": "HTTPS", "3389": "RDP", "3306": "MySQL"}
for p in sys.stdin.read().split():
    print(f"{p}: {SVC.get(p, 'UNKNOWN')}")
'''
M['fw2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
n = int(l[0])
rules = [r.split() for r in l[1:1 + n]]
for pkt in l[1 + n:]:
    proto, port = pkt.split()
    act = "DENY"
    for a, rp, rport in rules:
        if (rp == "any" or rp == proto) and (rport == "any" or rport == port):
            act = a.upper()
            break
    print(f"{proto} {port}: {act}")
'''
M['fw3'] = '''import sys
''' + _IP + '''def inside(ip, cidr):
    if cidr == "any":
        return True
    net, p = cidr.split("/")
    return ip2i(ip) & mask(int(p)) == ip2i(net) & mask(int(p))
l = sys.stdin.read().strip().split("\\n")
n = int(l[0])
rules = [r.split() for r in l[1:1 + n]]
for pkt in l[1 + n:]:
    src, port = pkt.split()
    act, why = "DENY", "default"
    for i, (a, cidr, rport) in enumerate(rules):
        if inside(src, cidr) and (rport == "any" or rport == port):
            act, why = a.upper(), f"rule {i + 1}"
            break
    print(f"{src} -> {port}: {act} ({why})")
'''
M['fw2_bug'] = M['fw2'].replace('act = "DENY"', 'act = "ALLOW"')
# ---------------- monitoring
M['log1'] = '''import sys
c = {}
for l in sys.stdin.read().strip().split("\\n"):
    t, user, ip, res = l.split()
    if res == "FAIL":
        c[user] = c.get(user, 0) + 1
for u in sorted(c, key=lambda k: (-c[k], k)):
    print(f"{u}: {c[u]}")
if not c:
    print("No failures")
'''
M['log2'] = '''import sys
def mins(t):
    h, m = t.split(":")
    return int(h) * 60 + int(m)
fails = {}
for l in sys.stdin.read().strip().split("\\n"):
    t, user, ip, res = l.split()
    if res == "FAIL":
        fails.setdefault(ip, []).append(mins(t))
alerts = []
for ip, ts in fails.items():
    ts.sort()
    for i in range(len(ts) - 4):
        if ts[i + 4] - ts[i] <= 10:
            alerts.append(ip)
            break
for ip in sorted(alerts):
    print(f"ALERT brute force from {ip}")
if not alerts:
    print("No alerts")
'''
M['log3'] = '''import sys
fails = {}
out = []
for l in sys.stdin.read().strip().split("\\n"):
    t, user, ip, res = l.split()
    if res == "FAIL":
        fails[user] = fails.get(user, 0) + 1
    else:
        if fails.get(user, 0) >= 3:
            out.append(f"CRITICAL {user} logged in from {ip} at {t} after {fails[user]} failures")
        fails[user] = 0
print("\\n".join(out) if out else "No suspicious logins")
'''
M['log1_bug'] = M['log1'].replace('if res == "FAIL":', 'if res != "OK" or True:')
# ---------------- vulnerability
M['ver1'] = '''import sys
def v(s):
    return tuple(int(x) for x in s.split("."))
for l in sys.stdin.read().strip().split("\\n"):
    name, inst, fixed = l.split()
    print(f"{name} {inst}: {'VULNERABLE' if v(inst) < v(fixed) else 'OK'}")
'''
M['ver1_bug'] = '''import sys
for l in sys.stdin.read().strip().split("\\n"):
    name, inst, fixed = l.split()
    print(f"{name} {inst}: {'VULNERABLE' if inst < fixed else 'OK'}")
'''
M['ver2'] = '''import sys
def v(s):
    return tuple(int(x) for x in s.split("."))
l = sys.stdin.read().strip().split("\\n")
n = int(l[0])
adv = {}
for a in l[1:1 + n]:
    name, fixed, cve = a.split()
    adv.setdefault(name, []).append((fixed, cve))
for h in l[1 + n:]:
    host, name, inst = h.split()
    hits = [cve for fixed, cve in adv.get(name, []) if v(inst) < v(fixed)]
    print(f"{host} {name} {inst}: " + (", ".join(sorted(hits)) if hits else "OK"))
'''
M['ver3'] = '''import sys
W = {"critical": 10, "high": 7, "medium": 4, "low": 1}
E = {"internet": 3, "internal": 1}
rows = []
for l in sys.stdin.read().strip().split("\\n"):
    host, cve, sev, exp, kev = l.split()
    s = W[sev] * E[exp] * (2 if kev == "yes" else 1)
    rows.append((-s, host, cve, s))
for i, (_, host, cve, s) in enumerate(sorted(rows)):
    print(f"{i + 1}. {host} {cve} score={s}")
'''
M['pw1'] = '''import sys
for p in sys.stdin.read().split("\\n"):
    p = p.rstrip("\\r")
    if not p:
        continue
    probs = []
    if len(p) < 12:
        probs.append("too short")
    if not any(c.isdigit() for c in p):
        probs.append("no digit")
    if not any(c.isupper() for c in p):
        probs.append("no uppercase")
    print("OK" if not probs else "WEAK: " + ", ".join(probs))
'''
M['pw2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
common = set(x.lower() for x in l[0].split())
for p in l[1:]:
    probs = []
    base = "".join(c for c in p.lower() if c.isalpha())
    if p.lower() in common or base in common:
        probs.append("common password")
    if len(p) < 12:
        probs.append("too short")
    print("OK" if not probs else "WEAK: " + ", ".join(probs))
'''
M['pw3'] = '''import sys, math
for p in sys.stdin.read().strip().split("\\n"):
    pool = 0
    if any(c.islower() for c in p): pool += 26
    if any(c.isupper() for c in p): pool += 26
    if any(c.isdigit() for c in p): pool += 10
    if any(not c.isalnum() for c in p): pool += 33
    bits = len(p) * math.log2(pool) if pool else 0
    rating = "strong" if bits >= 80 else "moderate" if bits >= 60 else "weak"
    print(f"{bits:.1f} bits ({rating})")
'''
# ---------------- forensics
M['hash1'] = '''import sys, hashlib
l = sys.stdin.read().split("\\n", 1)
rec = l[0].strip().lower()
data = l[1].strip() if len(l) > 1 else ""
h = hashlib.sha256(data.encode()).hexdigest()
print(f"SHA-256: {h}")
print("MATCH" if h == rec else "MISMATCH - evidence may have been altered")
'''
M['hash2'] = '''import sys, hashlib
l = sys.stdin.read().strip().split("\\n")
n = int(l[0])
man = dict(x.split() for x in l[1:1 + n])
bad = 0
for f in l[1 + n:]:
    name, content = f.split(" ", 1)
    h = hashlib.sha256(content.encode()).hexdigest()
    if name not in man:
        print(f"{name}: NOT IN MANIFEST")
        bad += 1
    elif man[name] != h:
        print(f"{name}: MODIFIED")
        bad += 1
    else:
        print(f"{name}: OK")
print(f"Integrity failures: {bad}")
'''
M['coc'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
holder = l[0].split()[1]
last = ""
ok = True
for i, e in enumerate(l[1:]):
    t, frm, to = e.split()
    if frm != holder:
        print(f"Entry {i + 1}: BREAK - {frm} did not hold the evidence ({holder} did)")
        ok = False
    if t <= last:
        print(f"Entry {i + 1}: BREAK - time {t} is not after {last}")
        ok = False
    holder, last = to, t
print("Chain of custody intact" if ok else "Chain of custody broken")
'''
M['tl1'] = '''import sys
ev = [l.split(" ", 1) for l in sys.stdin.read().strip().split("\\n")]
for t, d in sorted(ev, key=lambda x: x[0]):
    print(f"{t} {d}")
'''
M['tl2'] = '''import sys
l = sys.stdin.read().strip().split("\\n")
a, b = l[0].split()
ev = [x.split(" ", 1) for x in l[1:]]
hits = [(t, d) for t, d in ev if a <= t <= b]
for t, d in sorted(hits):
    print(f"{t} {d}")
print(f"{len(hits)} events in window")
'''
M['tl3'] = '''import sys
from datetime import datetime, timedelta
out = []
for l in sys.stdin.read().strip().split("\\n"):
    src, t, off, d = l.split(" ", 3)
    sign = 1 if off[0] == "+" else -1
    h, m = int(off[1:3]), int(off[4:6])
    utc = datetime.strptime(t, "%Y-%m-%dT%H:%M") - sign * timedelta(hours=h, minutes=m)
    out.append((utc, src, d))
for utc, src, d in sorted(out):
    print(f"{utc.strftime('%Y-%m-%dT%H:%MZ')} [{src}] {d}")
'''
M['tl1_bug'] = M['tl1'].replace('sorted(ev, key=lambda x: x[0])', 'ev')
# ---------------- awareness
M['ph1'] = '''import sys, re
URG = ["urgent", "immediately", "suspended", "verify your", "final notice", "act now"]
for l in sys.stdin.read().strip().split("\\n"):
    t = l.lower()
    hits = [w for w in URG if w in t]
    print(f"{len(hits)} pressure phrase(s)" + (": " + ", ".join(hits) if hits else ""))
'''
M['ph2'] = '''import sys, re
l = sys.stdin.read().strip().split("\\n")
trusted = l[0].split()
for url in l[1:]:
    host = re.sub(r"^https?://", "", url).split("/")[0].lower()
    if any(host == d or host.endswith("." + d) for d in trusted):
        print(f"{host}: TRUSTED")
    elif any(d.split(".")[0] in host for d in trusted):
        print(f"{host}: LOOKALIKE")
    else:
        print(f"{host}: UNKNOWN")
'''
M['ph3'] = '''import sys, re
URG = ["urgent", "immediately", "suspended", "verify your", "final notice", "act now"]
l = sys.stdin.read().strip().split("\\n")
org = l[0].strip().lower()
for e in l[1:]:
    sender, link, body = e.split("|")
    sender, link, body = sender.strip().lower(), link.strip().lower(), body.strip().lower()
    score = 0
    reasons = []
    sd = sender.split("@")[-1]
    host = re.sub(r"^https?://", "", link).split("/")[0] if link != "none" else ""
    if org.split(".")[0] in sd and sd != org:
        score += 3; reasons.append("lookalike sender")
    if host and not (host == org or host.endswith("." + org)):
        score += 2; reasons.append("external link")
    if link.startswith("http://"):
        score += 1; reasons.append("no https")
    u = sum(w in body for w in URG)
    if u:
        score += u; reasons.append("pressure")
    verdict = "REPORT AS PHISHING" if score >= 4 else "SUSPICIOUS" if score >= 2 else "LIKELY SAFE"
    print(f"{verdict} (score {score}" + (": " + ", ".join(reasons) if reasons else "") + ")")
'''
