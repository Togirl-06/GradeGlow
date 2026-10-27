# Usage: python3 tool/gen_life_world_demo.py .   (from the repo root)
# Generates web/life_world/demo_data.js from the Dart world definitions so the
# standalone preview shows exactly the same city and rooms as the game.
import re, json, sys
root = sys.argv[1]
inter = open(root + '/lib/life_sim/world/interiors.dart').read()
emp = open(root + '/lib/life_sim/employment/employers.dart').read()

def dstr(s):
    s = s.strip()
    if s.startswith("'") or s.startswith('"'):
        q = s[0]
        return s[1:-1].replace("\\'", "'")
    return s

def split_args(a):
    out, depth, cur, q = [], 0, '', None
    i = 0
    while i < len(a):
        c = a[i]
        if q:
            cur += c
            if c == '\\': cur += a[i+1]; i += 1
            elif c == q: q = None
        elif c in '\'"': q = c; cur += c
        elif c in '([<{': depth += 1; cur += c
        elif c in ')]>}': depth -= 1; cur += c
        elif c == ',' and depth == 0: out.append(cur.strip()); cur = ''
        else: cur += c
        i += 1
    if cur.strip(): out.append(cur.strip())
    return out

def calls(src, name):
    res = []
    for m in re.finditer(r'\b' + name + r'\(', src):
        i = m.end(); depth = 1; q = None
        while depth:
            c = src[i]
            if q:
                if c == '\\': i += 1
                elif c == q: q = None
            elif c in '\'"': q = c
            elif c == '(': depth += 1
            elif c == ')': depth -= 1
            i += 1
        res.append(split_args(src[m.end():i-1]))
    return res

def named(args):
    pos, kw = [], {}
    for a in args:
        m = re.match(r'^(\w+):\s*(.*)$', a, re.S)
        if m and not a.startswith("'"): kw[m.group(1)] = m.group(2)
        else: pos.append(a)
    return pos, kw

rooms = {}
body = inter[inter.index('switch (id) {'):inter.index('  static final List<(int, int)> _apartmentWalls')]
for case in re.split(r"\n\s*case '", body)[1:]:
    rid = case[:case.index("'")]
    items = []
    for a in calls(case, '_i'):
        pos, kw = named(a)
        items.append(dict(id=dstr(pos[0]), name=dstr(pos[1]), emoji=dstr(pos[2]), x=int(pos[3]), y=int(pos[4]),
                          type=pos[5].split('.')[-1], arg=dstr(kw['arg']) if 'arg' in kw else None,
                          hint=dstr(kw.get('hint', "''"))))
    npcs = []
    for a in calls(case, '_n'):
        pos, kw = named(a)
        npcs.append(dict(id=dstr(pos[0]), name=dstr(pos[1]), role=dstr(pos[2]), x=int(pos[3]), y=int(pos[4]),
                         outfit=int(kw.get('outfit', '0xFF6366F1'), 16), skin=int(kw.get('skin', '2')), hair=int(kw.get('hair', '1'))))
    fl = re.search(r'floor:\s*(0x[0-9A-Fa-f]+)', case); wl = re.search(r'wall:\s*(0x[0-9A-Fa-f]+)', case)
    rooms[rid] = dict(items=items, npcs=npcs, floor=int(fl.group(1), 16) if fl else 0xFFE5E7EB, wall=int(wl.group(1), 16) if wl else 0xFF94A3B8)

stations = {}
for m in re.finditer(r"'(\w+)': <StationDef>\[(.*?)\]", inter, re.S):
    stations[m.group(1)] = [dict(id=dstr(a[0]), name=dstr(a[1]), emoji=dstr(a[2])) for a in calls(m.group(2), 'StationDef')]

employers = []
for a in calls(emp, 'Employer'):
    pos, kw = named(a)
    if 'buildingId' not in kw: continue
    ip, ikw = named(calls(kw['interviewer'], 'InterviewerPersona')[0])
    employers.append(dict(id=dstr(kw['id']), name=dstr(kw['name']), buildingId=dstr(kw['buildingId']),
        hires=re.findall(r"'(\w+)'", kw['hires']), accent=int(kw.get('accent', '0xFF3B82F6'), 16),
        startHour=int(kw.get('startHour', '9')), endHour=int(kw.get('endHour', '17')),
        interviewer=dict(name=dstr(ikw['name']), title=dstr(ikw['title']), skin=int(ikw['skinTone'], 16),
                         hair=int(ikw['hairColor'], 16), outfit=int(ikw['outfitColor'], 16), hairStyle=dstr(ikw.get('hairStyle', "'short'")))))

# ---- campus: labs, schools, city layout (mirrors lib/life_sim/campus + world/city_map.dart)
labsrc = open(root + '/lib/life_sim/campus/lab_info.dart').read()
labs = [dict(id=a[0], school=a[1], name=a[2], emoji=a[3], hint=a[4], skill=a[5]) for a in
        [[dstr(x) for x in args] for args in calls(labsrc[labsrc.index('kCampusLabs = '):], 'LabInfo')]]
schsrc = open(root + '/lib/life_sim/campus/campus_schools.dart').read()
schools = []
for a in calls(schsrc[schsrc.index('kSchools = '):], 'SchoolDef'):
    pos, kw = named(a)
    def person(txt):
        pp, pk = named(calls(txt, 'SchoolPerson')[0])
        return dict(id=dstr(pp[0]), name=dstr(pp[1]), role=dstr(pp[2]), skin=int(pk.get('skin', '2')), hair=int(pk.get('hair', '1')), outfit=int(pk.get('outfit', '0xFF6366F1'), 16))
    schools.append(dict(id=dstr(kw['id']), floor=dstr(kw.get('floor', "'tile'")), majors=re.findall(r"'([^']+)'", kw['majors']), professor=person(kw['professor']), student=person(kw['student'])))
slots = [(1, 1), (4, 1), (7, 1), (10, 1), (1, 4), (10, 4), (1, 7), (10, 7), (3, 6), (8, 6)]
for sc in schools:
    items, zones = [], []
    mine = [l for l in labs if l['school'] == sc['id']][:8]
    for k, l in enumerate(mine):
        x, y = slots[k]
        items.append(dict(id='lab_' + l['id'], name=l['name'], emoji=l['emoji'], x=x, y=y, type='openLab', arg=l['id'], hint=l['hint']))
        zones.append(dict(name=l['name'], emoji=l['emoji'], x0=max(0, x - 1), y0=max(0, y - 1), x1=min(11, x + 1), y1=min(8, y + 1), floor=sc['floor']))
    x, y = slots[8]
    items.append(dict(id='lecture', name='Lecture Room', emoji='🧑‍🏫', x=x, y=y, type='lectureHall', arg=None, hint='Lectures for ' + ', '.join(sc['majors']) + '.'))
    p, st = sc['professor'], sc['student']
    rooms[sc['id']] = dict(items=items, zones=zones, walls=[], floor=0xFFF1F5F9, wall=p['outfit'],
        npcs=[dict(p, x=6, y=4), dict(st, x=8, y=4)])
# apartment walls/zones are built in code; mirror them here
rooms['apartment_block']['walls'] = [[x, 4] for x in range(12) if x not in (2, 6, 10)] + [[4, y] for y in range(4)] + [[8, y] for y in range(4)]
for rid in ('apartment_block', 'student_union'):
    case = inter[inter.index("case '%s':" % rid):]
    case = case[:case.index('case \'', 10)]
    rooms[rid]['zones'] = [dict(name=dstr(a[0]), emoji=dstr(a[1]), x0=int(a[2]), y0=int(a[3]), x1=int(a[4]), y1=int(a[5]), floor=dstr(named(a)[1].get('floor', "'tile'"))) for a in calls(case, 'InteriorZone')]

city = open(root + '/lib/life_sim/world/city_map.dart').read()
districts = []
for a in calls(city, 'District'):
    pos, kw = named(a)
    if 'id' not in kw: continue
    districts.append(dict(id=dstr(kw['id']), name=dstr(kw['name']), emoji=dstr(kw['emoji']), col=int(kw['col']), row=int(kw['row']), color=int(kw['color'], 16)))
cols_ = int(re.search(r'static const int cols = (\d+)', city).group(1)); rows_ = int(re.search(r'static const int rows = (\d+)', city).group(1))
build = city[city.index('    // ---- Row 0'):city.index('buildings = List<Building>.unmodifiable')]
blds = []
dmap = {d['id']: d for d in districts}
def place(kind, a):
    pos, kw = named(a)
    if kind == 'mk':
        bid, name, dist, emoji, slot, total = dstr(pos[0]), dstr(pos[1]), dstr(pos[2]), dstr(pos[3]), int(pos[4]), int(pos[5])
        color = int(kw.get('color', '0xFF94A3B8'), 16); emp_id = None
        op, cl = int(kw.get('open', '8')), int(kw.get('close', '20'))
    else:
        e = next(e for e in employers if e['id'] == dstr(pos[0]))
        bid, name, dist, emoji, slot, total = e['buildingId'], e['name'], dstr(pos[1]), dstr(pos[4]), int(pos[2]), int(pos[3])
        color = e['accent']; emp_id = e['id']
        hosp = 'hospital: true' in ','.join(a)
        op, cl = (0, 24) if hosp else (max(0, e['startHour'] - 1), e['endHour'] + 1)
    d = dmap[dist]; cx, cy = d['col'] * 12, d['row'] * 10
    w = 3 if total == 3 else 5
    x = cx + 1 + slot * 4 if total == 3 else cx + (1 if slot == 0 else 7)
    blds.append(dict(id=bid, name=name, district=dist, emoji=emoji, x=x, y=cy + 2, w=w, h=5, color=color, employer=emp_id, open=op, close=cl))
for m in re.finditer(r'\b(mk|emp)\(', build):
    i = m.end(); depth = 1; q = None
    while depth:
        c = build[i]
        if q:
            if c == '\\': i += 1
            elif c == q: q = None
        elif c in '\'"': q = c
        elif c == '(': depth += 1
        elif c == ')': depth -= 1
        i += 1
    place(m.group(1), split_args(build[m.end():i - 1]))

out = '// GENERATED by tool/gen_life_world_demo.py from lib/life_sim (world/interiors.dart, employment/employers.dart).\n'
out += '// Used only by the standalone preview (?demo=1); the game sends live data from Dart.\n'
out += 'export const ROOMS = ' + json.dumps(rooms, ensure_ascii=False) + ';\n'
out += 'export const STATIONS = ' + json.dumps(stations, ensure_ascii=False) + ';\n'
out += 'export const EMPLOYERS = ' + json.dumps(employers, ensure_ascii=False) + ';\n'
out += 'export const DISTRICTS = ' + json.dumps(districts, ensure_ascii=False) + ';\n'
out += 'export const BUILDINGS = ' + json.dumps(blds, ensure_ascii=False) + ';\n'
out += 'export const GRID = ' + json.dumps(dict(cols=cols_, rows=rows_, cellW=12, cellH=10)) + ';\n'
open(root + '/web/life_world/demo_data.js', 'w').write(out)
print(len(blds), 'buildings', len(districts), 'districts', len(labs), 'labs')
print(len(rooms), 'rooms', len(employers), 'employers', sum(len(v) for v in stations.values()), 'stations')
print(list(rooms))
