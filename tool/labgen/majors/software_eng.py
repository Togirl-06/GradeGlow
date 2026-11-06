from labgen import D, I, O, Lab, Major, Choice, ge, le, case, Code, V3

PM = 'Marcus Bell, delivery manager'

# ------------------------------------------------------------ code models

TASKS_V1 = '''import sys
lines = sys.stdin.read().strip().split("\\n")
n = int(lines[0])
tasks = []
for l in lines[1:1 + n]:
    t, p = l.rsplit(",", 1)
    tasks.append((int(p), t.strip()))
for p, t in sorted(tasks):
    print(f"[{p}] {t}")
'''
TASKS_V2 = '''import sys
lines = sys.stdin.read().strip().split("\\n")
n = int(lines[0])
todo, done = [], 0
for l in lines[1:1 + n]:
    t, p, s = [x.strip() for x in l.split(",")]
    if s == "done":
        done += 1
    else:
        todo.append((int(p), t))
for p, t in sorted(todo):
    print(f"[{p}] {t}")
print(f"Done: {done}")
'''
TASKS_V3 = '''import sys
tasks = {}
for l in sys.stdin.read().strip().split("\\n"):
    l = l.strip()
    if l.startswith("add "):
        t, p = l[4:].rsplit(",", 1)
        tasks[t.strip()] = int(p)
    elif l.startswith("done "):
        t = l[5:].strip()
        if t in tasks:
            del tasks[t]
        else:
            print(f"ERROR unknown task: {t}")
    elif l == "list":
        for t, p in sorted(tasks.items(), key=lambda kv: (kv[1], kv[0])):
            print(f"[{p}] {t}")
        print("---")
'''

BOOK_V1 = '''import sys
lines = sys.stdin.read().strip().split("\\n")
n = int(lines[0])
b = [tuple(map(int, l.split())) for l in lines[1:1 + n]]
clash = any(b[i][0] < b[j][1] and b[j][0] < b[i][1] for i in range(n) for j in range(i))
print("CONFLICT" if clash else "OK")
'''
BOOK_V2 = '''import sys
lines = sys.stdin.read().strip().split("\\n")
n = int(lines[0])
b = [tuple(map(int, l.split())) for l in lines[1:1 + n]]
for i in range(n):
    if any(b[i][0] < b[j][1] and b[j][0] < b[i][1] for j in range(i)):
        print(i + 1)
        break
else:
    print("OK")
'''
BOOK_V3 = '''import sys
lines = sys.stdin.read().strip().split("\\n")
n = int(lines[0])
acc = []
for l in lines[1:1 + n]:
    r, s, e = l.split()
    s, e = int(s), int(e)
    if any(r == r2 and s < e2 and s2 < e for r2, s2, e2 in acc):
        print("REJECTED")
    else:
        acc.append((r, s, e))
        print("ACCEPTED")
'''

INV_V1 = '''import sys
total = 0
for l in sys.stdin.read().strip().split("\\n"):
    if l.strip() == "END":
        break
    item, q, p = l.split()
    total += int(q) * float(p)
print(f"{total:.2f}")
'''
INV_V2 = '''import sys
sub = 0
for l in sys.stdin.read().strip().split("\\n"):
    if l.strip() == "END":
        break
    item, q, p = l.split()
    sub += int(q) * float(p)
vat = sub * 0.2
print(f"Subtotal: {sub:.2f}")
print(f"VAT: {vat:.2f}")
print(f"Total: {sub + vat:.2f}")
'''
INV_V3 = '''import sys
sub, rate, msgs = 0, 0, []
for l in sys.stdin.read().strip().split("\\n"):
    l = l.strip()
    if l == "END":
        break
    parts = l.split()
    if parts[0] == "CODE":
        if parts[1] == "SAVE10":
            rate = 0.1
        else:
            msgs.append(f"Invalid code: {parts[1]}")
        continue
    item, q, p = parts
    sub += int(q) * float(p)
disc = sub * rate
vat = (sub - disc) * 0.2
for m in msgs:
    print(m)
print(f"Subtotal: {sub:.2f}")
print(f"Discount: {disc:.2f}")
print(f"VAT: {vat:.2f}")
print(f"Total: {sub - disc + vat:.2f}")
'''

GRADE_BUG_PY = '''import sys
m = int(sys.stdin.read().strip())
if m > 70:
    print("A")
elif m > 60:
    print("B")
elif m > 50:
    print("C")
else:
    print("F")
'''
GRADE_BUG_JS = '''const m = parseInt(require("fs").readFileSync(0, "utf8").trim());
if (m > 70) console.log("A");
else if (m > 60) console.log("B");
else if (m > 50) console.log("C");
else console.log("F");
'''
GRADE_V1 = '''import sys
m = int(sys.stdin.read().strip())
print("A" if m >= 70 else "B" if m >= 60 else "C" if m >= 50 else "F")
'''
GRADE_V2 = '''import sys
t = sys.stdin.read().strip()
try:
    m = int(t)
    ok = 0 <= m <= 100
except ValueError:
    ok = False
if not ok:
    print("INVALID")
else:
    print("A" if m >= 70 else "B" if m >= 60 else "C" if m >= 50 else "F")
'''
GRADE_V3 = '''import sys
counts = {"A": 0, "B": 0, "C": 0, "F": 0, "INVALID": 0}
for t in sys.stdin.read().strip().split("\\n"):
    t = t.strip()
    try:
        m = int(t)
        ok = 0 <= m <= 100
    except ValueError:
        ok = False
    g = "INVALID" if not ok else ("A" if m >= 70 else "B" if m >= 60 else "C" if m >= 50 else "F")
    counts[g] += 1
    print(g)
print(" ".join(f"{k}:{v}" for k, v in counts.items()))
'''
GRADE_BUG2_PY = '''import sys
t = sys.stdin.read().strip()
m = int(t)
print("A" if m >= 70 else "B" if m >= 60 else "C" if m >= 50 else "F")
'''
GRADE_BUG3_PY = '''import sys
for t in sys.stdin.read().strip().split("\\n"):
    m = int(t)
    print("A" if m >= 70 else "B" if m >= 60 else "C" if m >= 50 else "F")
'''

LEAP_BUG_PY = '''import sys
y = int(sys.stdin.read().strip())
print("YES" if y % 4 == 0 else "NO")
'''
LEAP_BUG_JS = '''const y = parseInt(require("fs").readFileSync(0, "utf8").trim());
console.log(y % 4 === 0 ? "YES" : "NO");
'''
LEAP_V1 = '''import sys
y = int(sys.stdin.read().strip())
print("YES" if (y % 4 == 0 and y % 100 != 0) or y % 400 == 0 else "NO")
'''
LEAP_V2 = '''import sys
y, m = map(int, sys.stdin.read().split())
leap = (y % 4 == 0 and y % 100 != 0) or y % 400 == 0
d = [31, 29 if leap else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
print(d[m - 1])
'''
LEAP_V3 = '''import sys
s = sys.stdin.read().strip()
try:
    y, m, d = map(int, s.split("-"))
    leap = (y % 4 == 0 and y % 100 != 0) or y % 400 == 0
    days = [31, 29 if leap else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    ok = len(s) == 10 and 1 <= m <= 12 and 1 <= d <= days[m - 1]
except (ValueError, IndexError):
    ok = False
print("VALID" if ok else "INVALID")
'''
LEAP_BUG2_PY = '''import sys
y, m = map(int, sys.stdin.read().split())
d = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
print(d[m - 1])
'''
LEAP_BUG3_PY = '''import sys
s = sys.stdin.read().strip()
y, m, d = map(int, s.split("-"))
print("VALID" if 1 <= m <= 12 and 1 <= d <= 31 else "INVALID")
'''

SHIP_BUG_PY = '''import sys
# Legacy shipping calculator. Zone A £3, zone B £5, plus £1 per kg over 2 kg.
zone, kg = sys.stdin.read().split()
kg = float(kg)
if zone == "A":
    cost = 3
    if kg > 2:
        cost = cost + (kg - 2) * 1
if zone == "B":
    cost = 5
    if kg > 2:
        cost = cost + (kg - 1) * 1
print(f"{cost:.2f}")
'''
SHIP_V1 = '''import sys
BASE = {"A": 3, "B": 5}
zone, kg = sys.stdin.read().split()
kg = float(kg)
print(f"{BASE[zone] + max(0, kg - 2):.2f}")
'''
SHIP_V2 = '''import sys
BASE = {"A": 3, "B": 5, "C": 8}
zone, kg = sys.stdin.read().split()
kg = float(kg)
if zone not in BASE:
    print("UNKNOWN ZONE")
else:
    print(f"{BASE[zone] + max(0, kg - 2):.2f}")
'''
SHIP_V3 = '''import sys
BASE = {"A": 3, "B": 5, "C": 8}
zone, kg = sys.stdin.read().split()
kg = float(kg)
if zone not in BASE:
    print("UNKNOWN ZONE")
elif kg > 30:
    print("TOO HEAVY")
else:
    extra = max(0, kg - 2) + (5 if kg > 20 else 0)
    print(f"{BASE[zone] + extra:.2f}")
'''

CSV_V1 = '''import sys
lines = sys.stdin.read().strip().split("\\n")
for l in lines[1:]:
    print(l.split(",")[1])
'''
CSV_V2 = '''import sys
def parse(line):
    out, cur, q = [], "", False
    for ch in line:
        if ch == '"':
            q = not q
        elif ch == "," and not q:
            out.append(cur); cur = ""
        else:
            cur += ch
    out.append(cur)
    return out
lines = sys.stdin.read().strip().split("\\n")
for l in lines[1:]:
    print(parse(l)[1])
'''
CSV_V3 = '''import sys
def parse(line):
    out, cur, q, i = [], "", False, 0
    while i < len(line):
        ch = line[i]
        if ch == '"':
            if q and i + 1 < len(line) and line[i + 1] == '"':
                cur += '"'; i += 1
            else:
                q = not q
        elif ch == "," and not q:
            out.append(cur); cur = ""
        else:
            cur += ch
        i += 1
    out.append(cur)
    return out
lines = sys.stdin.read().strip().split("\\n")
head = parse(lines[0])
idx = head.index("name")
for l in lines[1:]:
    print(parse(l)[idx])
'''
CSV_BUG_PY = '''import sys
lines = sys.stdin.read().strip().split("\\n")
for l in lines[1:]:
    print(l.split(",")[1])
'''

# ------------------------------------------------------------ labs

req = Lab('se_lab_requirements', 1, 'Requirements Engineering', 'techOffice',
    'Work with simulated clients to gather, classify and document requirements as user stories with acceptance criteria.',
    ['Elicit requirements by asking the right questions', 'Separate functional from non-functional requirements', 'Write testable user stories'],
    ['cs_se', 'cs_review'], 'sr',
    cases=[
        case(key, f'Requirements: {title}', brief, 'Client statements',
             [('kind', 'Type', ['Functional', 'Non-functional', 'Out of scope', 'Constraint'])], items, person, opening, talk, conclusions=concl,
             procedure=['Read the client brief', 'Interview the stakeholders', 'Classify and prioritise requirements', 'Write user stories with acceptance criteria', 'Review with the client'], must=[(0, 1), (1, 2), (2, 3), (3, 4)],
             doc=('Requirements document', [
                 ('User story', [('Uses the user-story form', [r'as an? .{2,40},? I want']), ('Gives the benefit', [r'so that'])], story),
                 ('Acceptance criteria', [('Uses Given/When/Then', [r'given .{2,}when .{2,}then']), ('Is measurable', [r'\d|within|seconds|must'])], ac)]))
        for key, title, brief, items, person, opening, talk, concl, story, ac in [
            ('attendance', 'student attendance app', 'A university wants an attendance app.',
             [('R1', 'Lecturers mark attendance with a QR code.', {'kind': 'Functional'}), ('R2', 'Works for 5,000 students at 9 am.', {'kind': 'Non-functional'}),
              ('R3', 'Also manage the canteen menu.', {'kind': 'Out of scope'}), ('R4', 'Must use the university’s login system.', {'kind': 'Constraint'}),
              ('R5', 'Students see their attendance percentage.', {'kind': 'Functional'})],
             'Dr Helen Price, registrar (client)', 'We need better attendance data. Where do you start?',
             [('E', 'Who will use the app and what does each need?', 'Lecturers mark; students view; admin reports.'),
              ('E', 'How quickly must marking work at peak?', 'Within 2 seconds for 5,000 students at 9 am.'),
              ('U', 'What happens when a student is absent three times?', 'Their tutor is emailed.'),
              ('N', 'What is your favourite app?', 'Not sure.'),
              ('P', 'Shall we also build the canteen system?', 'That is not this project.', 'Scope creep adds cost and risk.')],
             [Choice('prio', 'Highest-priority requirement', 'Lecturers can mark attendance quickly at peak times', ['Canteen menu', 'Dark mode'])],
             'As a lecturer, I want to mark attendance by showing a QR code, so that I can record who attended without taking a register.',
             'Given 5,000 students scan the QR code at 9 am, when each student scans, then their attendance must be recorded within 2 seconds.'),
            ('clinic', 'clinic booking system', 'A GP surgery wants online appointment booking.',
             [('R1', 'Patients book and cancel appointments online.', {'kind': 'Functional'}), ('R2', 'Patient data must be encrypted.', {'kind': 'Non-functional'}),
              ('R3', 'Must integrate with the existing clinical system.', {'kind': 'Constraint'}), ('R4', 'Sell vitamins online.', {'kind': 'Out of scope'}),
              ('R5', 'Reminders by text 24 hours before.', {'kind': 'Functional'})],
             'Sanjay Rao, practice manager', 'Phones are jammed every morning.',
             [('E', 'What must patients be able to do online?', 'Book, cancel and get reminders.'),
              ('E', 'What data protection rules apply?', 'Health data — encryption and access logs.'),
              ('U', 'How many appointments a day?', 'About 300.'),
              ('N', 'Do you like blue?', 'Fine.'),
              ('X', 'Shall we store patient data unencrypted to save time?', 'Absolutely not.', 'Health data must be protected.')],
             [Choice('nfr', 'Which is a non-functional requirement?', 'Patient data must be encrypted', ['Patients can book online', 'Reminders are sent'])],
             'As a patient, I want to book an appointment online, so that I do not have to wait on the phone at 8 am.',
             'Given a free slot exists, when a patient books it, then the slot must be confirmed and a text reminder sent within 1 minute.'),
            ('library', 'library loans app', 'A public library wants an app for loans and renewals.',
             [('R1', 'Members renew loans in the app.', {'kind': 'Functional'}), ('R2', 'Accessible to screen-reader users.', {'kind': 'Non-functional'}),
              ('R3', 'Budget of £40k.', {'kind': 'Constraint'}), ('R4', 'Stream films.', {'kind': 'Out of scope'}), ('R5', 'Reserve a book at another branch.', {'kind': 'Functional'})],
             'Mo Clarke, head librarian', 'Our members want to do things from their phones.',
             [('E', 'Which tasks do members most want on their phones?', 'Renewals and reservations.'),
              ('E', 'What accessibility standard must we meet?', 'WCAG 2.2 AA.'),
              ('U', 'How many members?', '18,000.'),
              ('N', 'Favourite book?', 'Many.'),
              ('P', 'Can we skip accessibility to hit the budget?', 'No — it’s required.', 'Public services must be accessible.')],
             [Choice('acc', 'WCAG 2.2 AA is a', 'non-functional requirement', ['functional requirement', 'out-of-scope item'])],
             'As a library member, I want to renew my loans in the app, so that I avoid late fees without visiting the branch.',
             'Given a loan is due within 7 days, when the member taps renew, then the new due date must show within 3 seconds.'),
            ('delivery', 'food delivery tracking', 'A restaurant wants customers to track deliveries.',
             [('R1', 'Customers see the driver on a map.', {'kind': 'Functional'}), ('R2', 'Location updates at least every 10 seconds.', {'kind': 'Non-functional'}),
              ('R3', 'Must work on iOS and Android.', {'kind': 'Constraint'}), ('R4', 'A loyalty points scheme.', {'kind': 'Out of scope'}), ('R5', 'Text when the driver is 5 minutes away.', {'kind': 'Functional'})],
             'Rosa Lima, restaurant owner', 'Customers keep phoning to ask where their food is.',
             [('E', 'What information do customers want while waiting?', 'Where the driver is and the arrival time.'),
              ('E', 'How fresh must the location be?', 'Updated every 10 seconds.'),
              ('U', 'How many drivers?', 'Twelve.'),
              ('N', 'What’s on the menu?', 'Pizza.'),
              ('X', 'Track drivers’ locations when off shift too?', 'No.', 'Tracking outside work breaches privacy.')],
             [Choice('privacy', 'Driver location should be tracked', 'only during active deliveries', ['all the time', 'never'])],
             'As a customer, I want to see my driver on a map, so that I know when my food will arrive.',
             'Given a delivery is in progress, when the driver moves, then the map must show the new position within 10 seconds and the arrival time must be updated.'),
            ('payroll', 'payroll self-service portal', 'A company wants staff to view payslips online.',
             [('R1', 'Staff download payslips.', {'kind': 'Functional'}), ('R2', 'Two-factor login.', {'kind': 'Non-functional'}),
              ('R3', 'Go live before the tax year.', {'kind': 'Constraint'}), ('R4', 'Book meeting rooms.', {'kind': 'Out of scope'}), ('R5', 'Update bank details with approval.', {'kind': 'Functional'})],
             'Kate Dunn, HR director', 'People email us for copies of payslips constantly.',
             [('E', 'What can staff do themselves?', 'View payslips and request bank changes.'),
              ('E', 'How must logins be secured?', 'Two-factor authentication.'),
              ('U', 'When is the deadline?', '6 April.'),
              ('N', 'How big is the office?', 'Three floors.'),
              ('P', 'Let staff change bank details with no check?', 'That invites fraud.', 'Unverified bank changes enable payroll fraud.')],
             [Choice('fraud', 'Bank-detail changes should', 'require verification and approval', ['apply instantly with no checks', 'be emailed in plain text'])],
             'As an employee, I want to download my payslips, so that I can provide proof of income without emailing HR.',
             'Given a staff member logs in with two-factor authentication, when they open payslips, then the last 24 months must be available to download.'),
        ]
    ])

design = Lab('se_lab_design', 2, 'System Design and Architecture', 'techOffice',
    'Estimate capacity, choose components and justify architecture decisions for real systems.',
    ['Estimate load and storage', 'Choose architecture components', 'Record design decisions'],
    ['cs_se', 'cs_db'], 'sd',
    problems=[
        D('capacity', 'Sizing the web tier', 'Peak traffic: users × requests per user per minute. Each server handles 200 requests per second at 70% target utilisation.',
          [I('u', 'Peak concurrent users', 5, 100, 5, 20, 'k'), I('r', 'Requests per user per minute', 1, 20, 1, 6), I('n', 'Servers', 1, 40, 1, 1)],
          [O('Q', 'Peak requests per second', 'u*1000*r/60', 'req/s', 0), O('U', 'Utilisation per server', 'Q/(n*200)*100', '%', 1)],
          {'u': 20, 'r': 6, 'n': 10}, ['Q', 'U'],
          ([le('U', 70, 'Utilisation no more than 70%')], [ge('u', 50, 'Plan for 50k concurrent users')], [ge('r', 6, 'At least 6 requests per user per minute (measured)'), le('n', 36, 'No more than 36 servers (budget)')]),
          {'u': 50, 'r': 6, 'n': 36}),
        D('storage', 'Storage for photo uploads', 'Users upload photos; plan five years of storage with replication.',
          [I('d', 'Photos per day', 10, 200, 10, 200, 'k'), I('s', 'Average photo size', 0.5, 5, 0.5, 5, 'MB'), I('k', 'Replicas', 1, 3, 1, 1)],
          [O('T', 'Five-year storage', 'd*1000*s*365*5*k/1000000', 'TB', 1)],
          {'d': 50, 's': 2, 'k': 3}, ['T'],
          ([le('T', 700, 'No more than 700 TB')], [ge('k', 3, 'Three replicas for durability')], [ge('d', 80, 'Plan for 80k photos a day'), ge('s', 1.5, 'Average size at least 1.5 MB (compressed)')]),
          {'d': 80, 's': 1.5, 'k': 3}),
    ],
    cases=[
        case('components', 'Choosing components for a ticketing system', 'Design a concert-ticket system that survives sale-day spikes.', 'Proposed components',
             [('dec', 'Decision', ['Use', 'Avoid'])],
             [('Queue', 'A message queue to absorb purchase spikes.', {'dec': 'Use'}), ('Single DB', 'One database server with no replica.', {'dec': 'Avoid'}, 'Single point of failure.'),
              ('Cache', 'Cache event listings in memory.', {'dec': 'Use'}), ('Card storage', 'Store full card numbers in our database.', {'dec': 'Avoid'}, 'Use a payment provider; storing card data breaches PCI rules.', True)],
             'Asha Nair, solutions architect', 'Sale day brings 100× normal traffic. What’s your design?',
             [('E', 'Can we queue purchase requests and process them in order?', 'Yes, that protects the database.'),
              ('E', 'Should a payment provider handle card data?', 'Yes, we never store card numbers.'),
              ('U', 'Which parts can be cached?', 'Event listings and seat maps.'),
              ('N', 'Which language is coolest?', 'Doesn’t matter.'),
              ('P', 'Can we test the spike in production on sale day?', 'Too risky.', 'Load test before launch.')],
             conclusions=[Choice('spof', 'Biggest risk in the first design', 'The single database server', ['The cache', 'The queue'])],
             procedure=['Gather load requirements', 'Draw the component diagram', 'Identify single points of failure', 'Load test', 'Record decisions in an ADR'], must=[(0, 1), (1, 2), (2, 3)],
             doc=('Architecture decision record', [
                 ('Decision', [('States the decision', [r'we will|decided|decision']), ('Names the component', [r'queue|cache|replica|database'])],
                  'We will place a message queue in front of the purchase service and add a database replica, so sale-day spikes are absorbed safely.'),
                 ('Consequences', [('Gives a trade-off', [r'trade-off|however|cost|latency|complex']), ('Covers payments', [r'payment provider|PCI|card'])],
                  'However, the queue adds a few seconds of latency and operational complexity. Card data is handled only by the payment provider, keeping us outside PCI scope.')])),
        case('api', 'Designing an API', 'Review endpoints for a library loans API.', 'Endpoint designs',
             [('ok', 'Design quality', ['Good', 'Fix'])],
             [('GET /books/{id}', 'Returns one book.', {'ok': 'Good'}), ('GET /deleteBook?id=5', 'Deletes a book with GET.', {'ok': 'Fix'}, 'Use DELETE; GET must be safe.'),
              ('POST /loans', 'Creates a loan; returns 201.', {'ok': 'Good'}), ('GET /members', 'Returns every member’s address to any caller.', {'ok': 'Fix'}, 'Personal data needs authorisation.', True)],
             'Asha Nair, solutions architect', 'Is this API ready for the mobile team?',
             [('E', 'Who is allowed to see member addresses?', 'Only library staff.'),
              ('E', 'What status code should a successful create return?', '201 Created.'),
              ('U', 'Do we need pagination?', 'Yes, 30,000 books.'),
              ('N', 'What logo for the API docs?', 'Library logo.'),
              ('P', 'Can we leave authentication for later?', 'No.', 'Security cannot be retrofitted cheaply.')],
             conclusions=[Choice('delete', 'Correct way to delete a book', 'DELETE /books/{id} with staff authorisation', ['GET /deleteBook?id=5', 'POST /books/delete'])]),
        case('datamodel', 'Data model review', 'Review the data model for a booking platform.', 'Entities and relationships',
             [('ok', 'Correct?', ['Correct', 'Fix'])],
             [('Customer–Booking', 'One customer has many bookings.', {'ok': 'Correct'}), ('Booking–Room', 'Room stored as free text in each booking.', {'ok': 'Fix'}, 'Use a foreign key to a Room table.'),
              ('Payment', 'Payment linked to a booking by booking_id.', {'ok': 'Correct'}), ('Age', 'Customer age stored instead of date of birth.', {'ok': 'Fix'}, 'Age changes; store date of birth.')],
             'Ben Ward, database engineer', 'We need this schema finalised this week.',
             [('E', 'Can rooms be a separate table referenced by ID?', 'Yes, with capacity and price.'),
              ('E', 'Do we need date of birth or just age band?', 'Age band is enough — store less personal data.'),
              ('U', 'What indexes do queries need?', 'By date and room.'),
              ('N', 'Which SQL dialect sounds nicest?', 'Postgres.'),
              ('P', 'Can we store everything in one big table?', 'It will be hard to maintain.', 'Unnormalised tables cause update anomalies.')],
             conclusions=[Choice('norm', 'Why move rooms into their own table?', 'To avoid inconsistent duplicates and allow foreign keys', ['To use more storage', 'Because tables are trendy'])]),
    ])

dev = Lab('se_lab_development', 3, 'Software Development', 'computingLab',
    'Implement features from development tickets in Python or JavaScript, run them and pass automated tests.',
    ['Implement features to specification', 'Handle edge cases', 'Write clean, maintainable code'],
    ['cs_prog', 'cs_se'], 'sv',
    code=[
        Code('tasks', 'Task list feature', 'Ticket TASK-101: the task manager needs a sorted task list.', [
            V3('Input: first line n, then n lines "title,priority" (priority 1–3). Print each task as "[priority] title", sorted by priority, then title.',
               [('3\nWrite report,2\nCall client,1\nBook room,2', '[1] Call client\n[2] Book room\n[2] Write report'), ('1\nDeploy,3', '[3] Deploy'), ('4\nb,1\na,1\nc,3\nd,2', '[1] a\n[1] b\n[2] d\n[3] c')], TASKS_V1),
            V3('Input: first line n, then n lines "title,priority,status" (status todo or done). Print only todo tasks as "[priority] title" sorted by priority then title, then a line "Done: k".',
               [('3\nA,2,todo\nB,1,done\nC,1,todo', '[1] C\n[2] A\nDone: 1'), ('2\nX,3,done\nY,3,done', 'Done: 2'), ('3\nm,2,todo\nk,2,todo\nz,1,todo', '[1] z\n[2] k\n[2] m\nDone: 0')], TASKS_V2),
            V3('Input: commands, one per line: "add title,priority", "done title" or "list". For "list" print todo tasks as "[priority] title" (by priority then title) then "---". For "done" of an unknown title print "ERROR unknown task: title".',
               [('add A,2\nadd B,1\nlist\ndone A\nlist', '[1] B\n[2] A\n---\n[1] B\n---'), ('done X\nlist', 'ERROR unknown task: X\n---'), ('add a,3\nadd b,3\nadd c,1\nlist', '[1] c\n[3] a\n[3] b\n---')], TASKS_V3),
        ], skills=['cs_prog']),
        Code('booking', 'Room booking conflicts', 'Ticket BOOK-42: stop double bookings.', [
            V3('Input: n, then n lines "start end" (whole hours, end exclusive). Print OK if no two bookings overlap, otherwise CONFLICT.',
               [('2\n9 10\n10 11', 'OK'), ('2\n9 11\n10 12', 'CONFLICT'), ('3\n8 9\n13 15\n9 13', 'OK'), ('2\n9 12\n10 11', 'CONFLICT')], BOOK_V1),
            V3('Input: n, then n lines "start end". Print the 1-based number of the first booking that overlaps an earlier one, or OK.',
               [('3\n9 10\n11 12\n9 11', '3'), ('2\n9 10\n10 11', 'OK'), ('4\n8 9\n10 12\n11 13\n12 14', '3')], BOOK_V2),
            V3('Input: n, then n lines "room start end". Process in order: print ACCEPTED, or REJECTED if it overlaps an accepted booking in the same room.',
               [('3\nA 9 11\nB 9 11\nA 10 12', 'ACCEPTED\nACCEPTED\nREJECTED'), ('2\nA 9 10\nA 10 11', 'ACCEPTED\nACCEPTED'), ('4\nA 9 12\nA 10 11\nA 12 13\nB 10 11', 'ACCEPTED\nREJECTED\nACCEPTED\nACCEPTED')], BOOK_V3),
        ], skills=['cs_prog', 'cs_algo']),
        Code('invoice', 'Invoice totals', 'Ticket BILL-7: the invoice service needs correct totals.', [
            V3('Input: lines "item quantity unit_price" ending with END. Print the total to 2 decimal places.',
               [('pen 3 1.50\npad 2 2.25\nEND', '9.00'), ('desk 1 120.00\nEND', '120.00'), ('a 10 0.10\nb 4 0.25\nEND', '2.00')], INV_V1),
            V3('Input: lines "item quantity unit_price" ending with END. Print "Subtotal: x", "VAT: y" (20%) and "Total: z", each to 2 decimal places.',
               [('pen 3 1.50\npad 2 2.25\nEND', 'Subtotal: 9.00\nVAT: 1.80\nTotal: 10.80'), ('desk 1 120.00\nEND', 'Subtotal: 120.00\nVAT: 24.00\nTotal: 144.00'), ('a 4 2.50\nEND', 'Subtotal: 10.00\nVAT: 2.00\nTotal: 12.00')], INV_V2),
            V3('Input: lines "item quantity unit_price" or "CODE name", ending with END. Code SAVE10 gives 10% off the subtotal before VAT; any other code prints "Invalid code: name" first. Then print Subtotal, Discount, VAT (20% after discount) and Total, each to 2 dp.',
               [('pen 10 2.00\nCODE SAVE10\nEND', 'Subtotal: 20.00\nDiscount: 2.00\nVAT: 3.60\nTotal: 21.60'), ('CODE BOGUS\nbox 1 50.00\nEND', 'Invalid code: BOGUS\nSubtotal: 50.00\nDiscount: 0.00\nVAT: 10.00\nTotal: 60.00'),
                ('a 2 25.00\nEND', 'Subtotal: 50.00\nDiscount: 0.00\nVAT: 10.00\nTotal: 60.00')], INV_V3),
        ], skills=['cs_prog']),
    ],
    cases=[
        case('tickets', 'Sprint ticket triage', 'Triage the tickets at the start of the sprint.', 'Sprint backlog',
             [('pri', 'Priority', ['P1 — now', 'P2 — this sprint', 'P3 — backlog'])],
             [('Login outage', 'Users cannot log in since the 2 am release.', {'pri': 'P1 — now'}, 'Production outage.', True), ('Typo', 'Typo on the about page.', {'pri': 'P3 — backlog'}),
              ('Slow search', 'Search takes 6 s for some users.', {'pri': 'P2 — this sprint'}), ('Feature', 'Customer asks for dark mode.', {'pri': 'P3 — backlog'})],
             PM, 'What are you picking up first?',
             [('E', 'Can we roll back the 2 am release to restore logins?', 'Yes, do it now.'),
              ('E', 'Is there a ticket with steps to reproduce the slow search?', 'Yes, with examples.'),
              ('U', 'Who reviews my pull requests?', 'Sofia.'),
              ('N', 'What’s for lunch?', 'Sandwiches.'),
              ('P', 'Should I fix the typo before the outage?', 'No.', 'Outages come first.')],
             conclusions=[Choice('roll', 'Fastest safe fix for the outage', 'Roll back the release, then investigate', ['Wait for the next release', 'Delete the user database'])]),
        case('review', 'Code review', 'Review a pull request before it merges.', 'Review comments',
             [('sev', 'Severity', ['Blocker', 'Should fix', 'Nit'])],
             [('SQL', 'Query built by string concatenation with user input.', {'sev': 'Blocker'}, 'SQL injection risk.', True), ('Naming', 'Variable named x2.', {'sev': 'Nit|Should fix'}),
              ('Tests', 'No tests for the new discount code.', {'sev': 'Should fix|Blocker'}), ('Logging', 'Logs full passwords on failed login.', {'sev': 'Blocker'}, 'Never log secrets.', True)],
             'Sofia Rossi, lead developer', 'Is it safe to merge?',
             [('E', 'Can we switch to parameterised queries?', 'Yes, that’s our standard.'),
              ('E', 'Can we remove passwords from the logs?', 'Yes — log the username only.'),
              ('U', 'Should tests cover invalid codes?', 'Yes.'),
              ('N', 'Do you like tabs or spaces?', 'Spaces.'),
              ('P', 'Approve now and fix later?', 'Not with security issues.', 'Security blockers must be fixed before merging.')],
             conclusions=[Choice('merge', 'Merge decision', 'Request changes: fix injection and logging, add tests', ['Approve', 'Merge directly to main'])]),
    ])

git = Lab('se_lab_git', 4, 'Git and Collaboration', 'techOffice',
    'Branch, commit, pull request, review and resolve conflicts in a simulated team workflow.',
    ['Use a branching workflow', 'Resolve merge conflicts', 'Review and collaborate through pull requests'],
    ['cs_review', 'cs_se'], 'sg',
    cases=[
        case(key, title, brief, queue, fields, items, PM if person is None else person, opening, talk, conclusions=concl, procedure=proc, must=must)
        for key, title, brief, queue, fields, items, person, opening, talk, concl, proc, must in [
            ('feature', 'Feature branch workflow', 'Ship a small feature through the team’s Git workflow.', 'Git commands',
             [('ok', 'Appropriate here?', ['Do it', 'Don’t'])],
             [('git switch -c feature/login-timeout', 'Create a feature branch.', {'ok': 'Do it'}), ('git push --force origin main', 'Force-push to main.', {'ok': 'Don’t'}, 'Rewrites shared history.', True),
              ('git commit -m "Add login timeout"', 'Commit with a clear message.', {'ok': 'Do it'}), ('git commit -m "stuff"', 'Vague commit message.', {'ok': 'Don’t'})],
             'Sofia Rossi, lead developer', 'How will you get this into main?',
             [('E', 'Should I open a pull request for review?', 'Yes, always.'),
              ('E', 'Should I pull the latest main before opening the PR?', 'Yes, to catch conflicts early.'),
              ('U', 'Who approves PRs?', 'One reviewer plus green CI.'),
              ('N', 'What’s your favourite emoji?', '🚀.'),
              ('P', 'Can I commit straight to main to save time?', 'No.', 'Bypassing review risks breaking production.')],
             [Choice('pr', 'Before merging, a PR needs', 'an approving review and passing CI', ['nothing', 'a manager’s email'])],
             ['git switch main && git pull', 'git switch -c feature/login-timeout', 'Make changes and commit with clear messages', 'git push -u origin feature/login-timeout', 'Open a pull request and request review', 'Merge after approval and green CI'], [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5)]),
            ('conflict', 'Resolving a merge conflict', 'Two developers edited the same function.', 'Conflict hunks',
             [('keep', 'Resolution', ['Keep ours', 'Keep theirs', 'Combine both'])],
             [('Hunk 1', 'Ours renames a variable; theirs adds input validation in the same lines.', {'keep': 'Combine both'}),
              ('Hunk 2', 'Theirs fixes a bug we did not touch; ours only reformats.', {'keep': 'Keep theirs'}),
              ('Hunk 3', 'Ours adds the new feature; theirs deletes dead code nearby.', {'keep': 'Combine both'}), ('Hunk 4', 'Both made the same change.', {'keep': 'Keep ours|Keep theirs'})],
             'Dev Patel, teammate', 'My branch conflicts with yours. Can we sort it?',
             [('E', 'What did your change to validate input do?', 'It rejects empty usernames.'),
              ('E', 'Shall we run the tests after resolving?', 'Yes, both our tests.'),
              ('U', 'Should we pair on it?', 'Sure, 15 minutes.'),
              ('N', 'Coffee?', 'Yes.'),
              ('P', 'Just take my version of everything?', 'You’d lose my fix.', 'Blindly choosing one side drops work.')],
             [Choice('after', 'After resolving conflicts you should', 'run the tests before committing the merge', ['push immediately', 'delete the other branch'])],
             ['git pull origin main', 'Open each conflicted file', 'Resolve each hunk deliberately', 'Run the tests', 'git add and commit the merge'], [(0, 1), (1, 2), (2, 3), (3, 4)]),
            ('hotfix', 'Production hotfix', 'A bug in production must be fixed today.', 'Hotfix steps',
             [('ok', 'Do it?', ['Do it', 'Don’t'])],
             [('Branch', 'Create hotfix/price-rounding from the release tag.', {'ok': 'Do it'}), ('Skip tests', 'Skip CI to deploy faster.', {'ok': 'Don’t'}),
              ('Tag', 'Tag the fixed release.', {'ok': 'Do it'}), ('Back-merge', 'Merge the fix back into main.', {'ok': 'Do it'})],
             None, 'Prices are rounding wrongly. How fast can we fix it?',
             [('E', 'Can I branch from the release tag that is live?', 'Yes, v2.3.1.'),
              ('E', 'Will the fix also go back into main?', 'Yes, or the bug returns.'),
              ('U', 'Who can approve a hotfix?', 'Any senior dev.'),
              ('N', 'Is it raining?', 'Yes.'),
              ('P', 'Edit the live server directly?', 'No.', 'Untracked changes are lost and untested.')],
             [Choice('back', 'Why merge the hotfix back into main?', 'So the next release does not reintroduce the bug', ['To make main longer', 'It is not needed'])],
             ['Branch from the live release tag', 'Write a failing test for the bug', 'Fix the bug and pass the test', 'Review, tag and deploy', 'Merge back into main'], [(0, 1), (1, 2), (2, 3), (3, 4)]),
            ('history', 'Cleaning up before review', 'Your branch has messy commits.', 'Branch commits',
             [('act', 'Action', ['Keep', 'Squash', 'Remove'])],
             [('Commit 1', '"Add rota export" — the real change.', {'act': 'Keep'}), ('Commit 2', '"fix typo" — tiny fix to commit 1.', {'act': 'Squash'}),
              ('Commit 3', '"wip" — half-finished.', {'act': 'Squash'}), ('Commit 4', 'Accidentally added a file with an API key.', {'act': 'Remove'}, 'Secrets must never be committed; rotate the key too.', True)],
             'Sofia Rossi, lead developer', 'Tidy the branch before I review it.',
             [('E', 'Should I rotate the API key I committed?', 'Yes — treat it as leaked.'),
              ('E', 'Is it OK to rebase my own unpushed branch?', 'Yes, it’s only yours.'),
              ('U', 'Squash into one commit?', 'Two logical commits is fine.'),
              ('N', 'What music do you code to?', 'Jazz.'),
              ('P', 'Rebase main that everyone shares?', 'Never.', 'Rewriting shared history breaks colleagues’ work.')],
             [Choice('key', 'After removing a committed secret you must also', 'rotate (revoke and replace) the secret', ['do nothing else', 'rename the file'])],
             ['Remove the secret from the branch history', 'Rotate the leaked key', 'Squash fix-up commits', 'Push the cleaned branch', 'Request review'], [(0, 3), (2, 3), (3, 4)]),
            ('review', 'Reviewing a teammate’s PR', 'Give constructive review on a teammate’s pull request.', 'Draft review comments',
             [('tone', 'Comment quality', ['Constructive', 'Unhelpful'])],
             [('C1', '"This loop is O(n²); a set lookup would make it O(n). Example: …"', {'tone': 'Constructive'}), ('C2', '"This is terrible."', {'tone': 'Unhelpful'}),
              ('C3', '"Could we add a test for the empty-list case?"', {'tone': 'Constructive'}), ('C4', '"Why would anyone write this?"', {'tone': 'Unhelpful'})],
             'Dev Patel, teammate', 'Any feedback on my PR?',
             [('E', 'Explain the performance issue with an example fix.', 'Thanks, that makes sense.'),
              ('E', 'Ask for a test for the empty-list case.', 'Will add it.'),
              ('U', 'Praise what works well.', 'Appreciated!'),
              ('N', 'Talk about weekend plans.', 'Hiking.'),
              ('P', 'Rewrite their whole PR yourself.', 'Oh…', 'Taking over undermines ownership.')],
             [Choice('good', 'A good review comment is', 'specific, kind and suggests a fix', ['vague', 'personal'])],
             ['Read the PR description', 'Check out and run the code', 'Leave specific, kind comments', 'Approve or request changes'], [(0, 1), (1, 2), (2, 3)]),
        ]
    ])

testing = Lab('se_lab_testing', 5, 'Software Testing and Quality Assurance', 'computingLab',
    'Investigate deliberately faulty programs, write the fix, and pass the tests; triage bugs and design test cases.',
    ['Find defects from failing tests', 'Fix code and cover edge cases', 'Report bugs clearly'],
    ['cs_debug', 'cs_se'], 'st',
    code=[
        Code('grades', 'Faulty grade calculator', 'Bug report: students with exactly 70 get a B. Repair the program.', [
            V3('The starting program is faulty. Input: a whole mark 0–100. Print A (70+), B (60–69), C (50–59) or F (below 50).',
               [('70', 'A'), ('69', 'B'), ('60', 'B'), ('50', 'C'), ('49', 'F'), ('100', 'A')], GRADE_V1, None, GRADE_BUG_PY, GRADE_BUG_JS),
            V3('The starting program crashes on bad input. Input: one line. Print the grade as before, or INVALID if it is not a whole number from 0 to 100.',
               [('70', 'A'), ('abc', 'INVALID'), ('-5', 'INVALID'), ('101', 'INVALID'), ('55', 'C')], GRADE_V2, None, GRADE_BUG2_PY),
            V3('Input: several lines, one mark each. Print the grade (or INVALID) for each line, then a summary "A:a B:b C:c F:f INVALID:i".',
               [('70\n45\nx', 'A\nF\nINVALID\nA:1 B:0 C:0 F:1 INVALID:1'), ('60\n61\n59', 'B\nB\nC\nA:0 B:2 C:1 F:0 INVALID:0'), ('100\n0\n150', 'A\nF\nINVALID\nA:1 B:0 C:0 F:1 INVALID:1')], GRADE_V3, None, GRADE_BUG3_PY),
        ], skills=['cs_debug']),
        Code('dates', 'Faulty date logic', 'Bug report: the year 1900 is shown as a leap year. Repair it.', [
            V3('The starting program is faulty. Input: a year. Print YES if it is a leap year, otherwise NO (divisible by 4, except centuries unless divisible by 400).',
               [('2024', 'YES'), ('1900', 'NO'), ('2000', 'YES'), ('2023', 'NO')], LEAP_V1, None, LEAP_BUG_PY, LEAP_BUG_JS),
            V3('The starting program ignores leap years. Input: "year month". Print the number of days in that month.',
               [('2024 2', '29'), ('2023 2', '28'), ('1900 2', '28'), ('2023 4', '30'), ('2023 12', '31')], LEAP_V2, None, LEAP_BUG2_PY),
            V3('The starting program accepts impossible dates. Input: a date "YYYY-MM-DD". Print VALID or INVALID.',
               [('2024-02-29', 'VALID'), ('2023-02-29', 'INVALID'), ('2023-04-31', 'INVALID'), ('2023-13-01', 'INVALID'), ('2023-12-31', 'VALID')], LEAP_V3, None, LEAP_BUG3_PY),
        ], skills=['cs_debug']),
    ],
    cases=[
        case('bugs', 'Bug report triage', 'Triage incoming bug reports for the booking app.', 'Bug reports',
             [('sev', 'Severity', ['Critical', 'Major', 'Minor']), ('repro', 'Reproducible?', ['Yes', 'Need more info'])],
             [('Payments', 'Card payments fail for all users since 10 am. Steps attached.', {'sev': 'Critical', 'repro': 'Yes'}, 'Revenue-blocking.', True),
              ('Calendar', '"Sometimes the calendar is weird." No steps.', {'sev': 'Minor|Major', 'repro': 'Need more info'}),
              ('Accessibility', 'Screen reader cannot read the book button. Steps attached.', {'sev': 'Major', 'repro': 'Yes'}),
              ('Colour', 'Footer colour slightly off brand. Screenshot attached.', {'sev': 'Minor', 'repro': 'Yes'})],
             'Lena Fischer, QA lead', 'Which bugs need attention today?',
             [('E', 'Can we reproduce the payment failure in staging?', 'Yes, every time.'),
              ('E', 'Can we ask the calendar reporter for steps and device?', 'I’ll email them.'),
              ('U', 'Who owns payments?', 'The checkout squad.'),
              ('N', 'Who picked the footer colour?', 'Design.'),
              ('P', 'Close the calendar bug as "can’t reproduce" now?', 'Ask for details first.', 'Closing without investigation loses real bugs.')],
             conclusions=[Choice('good', 'A good bug report includes', 'steps to reproduce, expected vs actual, and environment', ['only a complaint', 'the reporter’s mood'])],
             procedure=['Reproduce the bug', 'Write a failing test', 'Fix the code', 'Verify the fix and run all tests', 'Close the bug with notes'], must=[(0, 1), (1, 2), (2, 3), (3, 4)]),
        case('cases', 'Designing test cases', 'Design tests for a password rule: 8–64 characters, at least one digit.', 'Proposed tests',
             [('use', 'Keep this test?', ['Keep', 'Redundant'])],
             [('7 chars with digit', 'Boundary just below the minimum.', {'use': 'Keep'}), ('8 chars with digit', 'Boundary at the minimum.', {'use': 'Keep'}),
              ('9, 10, 11 chars with digit', 'Three more mid-range lengths.', {'use': 'Redundant'}), ('No digit, 12 chars', 'Missing a digit.', {'use': 'Keep'}), ('65 chars', 'Just over the maximum.', {'use': 'Keep'})],
             'Lena Fischer, QA lead', 'How many tests do we really need?',
             [('E', 'Which boundaries should we test?', '7, 8, 64 and 65 characters.'),
              ('E', 'What invalid classes exist?', 'Too short, too long, no digit.'),
              ('U', 'Should we test unicode?', 'Yes, one case.'),
              ('N', 'What’s your password?', 'Not telling!'),
              ('P', 'Test every length from 1 to 100?', 'Wasteful.', 'Equivalence classes and boundaries give coverage efficiently.')],
             conclusions=[Choice('tech', 'The technique used here is', 'boundary value analysis and equivalence partitioning', ['random testing only', 'no testing'])]),
        case('release', 'Release readiness', 'Decide whether release 3.2 can ship.', 'Release checklist',
             [('ok', 'Status', ['Pass', 'Fail'])],
             [('Unit tests', '1,240 of 1,240 passing.', {'ok': 'Pass'}), ('Critical bug', 'One open critical bug in checkout.', {'ok': 'Fail'}, 'Critical defects block release.', True),
              ('Coverage', 'Coverage 78% (target 75%).', {'ok': 'Pass'}), ('Performance', 'Response times within targets.', {'ok': 'Pass'})],
             'Marcus Bell, delivery manager', 'Marketing has announced Friday. Can we ship?',
             [('E', 'When will the checkout bug be fixed and retested?', 'Thursday afternoon.'),
              ('E', 'Can the release go Friday only if the fix passes?', 'Yes, that’s the plan.'),
              ('U', 'Is there a rollback plan?', 'Yes, one-click rollback.'),
              ('N', 'What’s the release name?', 'Puffin.'),
              ('P', 'Ship with the known critical bug?', 'No.', 'Shipping known critical defects harms users.')],
             conclusions=[Choice('dec', 'Release decision', 'Ship Friday only if the checkout fix passes retesting', ['Ship now regardless', 'Cancel the release forever'])]),
    ])

maint = Lab('se_lab_maintenance', 6, 'Software Maintenance', 'computingLab',
    'Work on an existing codebase with technical debt: fix legacy bugs, extend features safely and prioritise refactoring.',
    ['Understand and fix legacy code', 'Extend features without breaking behaviour', 'Prioritise technical debt'],
    ['cs_debug', 'cs_se', 'cs_review'], 'sm',
    code=[
        Code('shipping', 'Legacy shipping calculator', 'The old shipping code charges zone B wrongly and is hard to extend.', [
            V3('The starting program is faulty. Input: "zone kg" (zone A or B). Cost = base (A £3, B £5) + £1 per kg over 2 kg. Print the cost to 2 dp.',
               [('A 1', '3.00'), ('A 4.5', '5.50'), ('B 2', '5.00'), ('B 5', '8.00')], SHIP_V1, None, SHIP_BUG_PY),
            V3('Add zone C (base £8). Input: "zone kg". Print the cost to 2 dp, or UNKNOWN ZONE for other zones.',
               [('C 3', '9.00'), ('B 5', '8.00'), ('D 1', 'UNKNOWN ZONE'), ('A 2', '3.00')], SHIP_V2, None, SHIP_BUG_PY),
            V3('Add weight rules: over 20 kg adds a £5 surcharge; over 30 kg print TOO HEAVY. Zones A £3, B £5, C £8, £1 per kg over 2 kg; unknown zones print UNKNOWN ZONE.',
               [('A 21', '27.00'), ('C 30', '41.00'), ('B 31', 'TOO HEAVY'), ('X 3', 'UNKNOWN ZONE'), ('A 20', '21.00')], SHIP_V3, None, SHIP_BUG_PY),
        ], skills=['cs_debug']),
        Code('csv', 'CSV import that breaks on commas', 'Customer names with commas break the import.', [
            V3('Input: a CSV with header "id,name,city" and rows. Print the name from each row (no quotes in this file).',
               [('id,name,city\n1,Ana,Leeds\n2,Ben,York', 'Ana\nBen'), ('id,name,city\n7,Zoë,Bath', 'Zoë'), ('id,name,city\n1,A,B\n2,C,D\n3,E,F', 'A\nC\nE')], CSV_V1),
            V3('The starting program splits on every comma. Names may be in double quotes and contain commas. Print the name from each row.',
               [('id,name,city\n1,"Smith, Ana",Leeds\n2,Ben,York', 'Smith, Ana\nBen'), ('id,name,city\n3,"Lee, Jo",Hull', 'Lee, Jo'), ('id,name,city\n1,A,B', 'A')], CSV_V2, None, CSV_BUG_PY),
            V3('Columns may be in any order (find "name" in the header). Quoted fields may contain commas and doubled quotes ("" means "). Print the name from each row.',
               [('city,name,id\nLeeds,"Smith, Ana",1', 'Smith, Ana'), ('name,id\n"The ""Boss""",2', 'The "Boss"'), ('id,name\n1,"A, B"\n2,C', 'A, B\nC')], CSV_V3, None, CSV_BUG_PY),
        ], skills=['cs_debug', 'cs_prog']),
    ],
    cases=[
        case('debt', 'Technical debt register', 'Prioritise the team’s technical debt.', 'Debt register',
             [('pri', 'Priority', ['Fix now', 'Plan this quarter', 'Accept for now'])],
             [('Outdated library', 'Payment library has a known security vulnerability.', {'pri': 'Fix now'}, 'Security vulnerabilities come first.', True),
              ('No tests', 'Pricing module has no tests and changes monthly.', {'pri': 'Plan this quarter|Fix now'}), ('Old admin UI', 'Ugly internal admin screen, rarely used.', {'pri': 'Accept for now'}),
              ('Copy-paste', 'Shipping logic copied in 4 places.', {'pri': 'Plan this quarter'})],
             'Sofia Rossi, lead developer', 'We get one sprint for debt. What goes in?',
             [('E', 'Is there a patched version of the payment library?', 'Yes, a minor upgrade.'),
              ('E', 'How often does the pricing module break?', 'Twice last quarter.'),
              ('U', 'Who uses the admin screen?', 'Two support staff.'),
              ('N', 'Favourite editor?', 'Vim.'),
              ('P', 'Rewrite the whole system from scratch?', 'Too risky.', 'Big-bang rewrites rarely succeed; refactor incrementally.')],
             conclusions=[Choice('first', 'First item to fix', 'Upgrade the vulnerable payment library', ['Redesign the admin UI', 'Rename variables'])],
             procedure=['Add tests around current behaviour', 'Refactor in small steps', 'Run the tests after each step', 'Review and merge', 'Monitor in production'], must=[(0, 1), (1, 2), (2, 3)]),
        case('incident', 'Legacy outage post-mortem', 'An old cron job deleted live data overnight.', 'Timeline',
             [('kind', 'Classification', ['Root cause', 'Contributing factor', 'Not relevant'])],
             [('Script', 'Cleanup script deletes rows older than 30 days using the wrong date column.', {'kind': 'Root cause'}), ('No review', 'Script was never code-reviewed.', {'kind': 'Contributing factor'}),
              ('Backups', 'Backups restored the data in 2 hours.', {'kind': 'Not relevant|Contributing factor'}), ('Monitoring', 'No alert on sudden row-count drop.', {'kind': 'Contributing factor'})],
             'Marcus Bell, delivery manager', 'What happened and how do we stop it happening again?',
             [('E', 'Which date column should the script use?', 'created_at, not updated_at.'),
              ('E', 'Can we add an alert for large deletions?', 'Yes, in monitoring.'),
              ('U', 'How long was the impact?', 'Two hours.'),
              ('N', 'Who wrote it?', 'Not important — blameless review.', 'Post-mortems focus on systems, not blame.'),
              ('P', 'Fire whoever wrote it?', 'No.', 'Blame discourages honest reporting.')],
             conclusions=[Choice('action', 'Most valuable action', 'Fix the column, add review and a deletion alert', ['Delete the backups', 'Blame the author'])]),
        case('upgrade', 'Framework upgrade plan', 'The web framework version is end-of-life next month.', 'Upgrade risks',
             [('act', 'Action', ['Mitigate', 'Accept'])],
             [('Breaking API', 'Routing API changed in the new version.', {'act': 'Mitigate'}), ('Deprecated warnings', 'Hundreds of deprecation warnings.', {'act': 'Mitigate'}),
              ('No support', 'No security patches after EOL.', {'act': 'Mitigate'}, 'Running unsupported software is a security risk.', True), ('New features', 'We don’t need the new features yet.', {'act': 'Accept'})],
             'Sofia Rossi, lead developer', 'Can we just stay on the old version?',
             [('E', 'What breaks when we upgrade?', 'Routing and two plugins.'),
              ('E', 'Can we upgrade behind a feature flag?', 'Yes, route by route.'),
              ('U', 'Do we have test coverage on routing?', '60%.'),
              ('N', 'What’s the framework’s mascot?', 'A fox.'),
              ('P', 'Ignore EOL — it still works?', 'Not safely.', 'No security patches means growing risk.')],
             conclusions=[Choice('plan', 'Best plan', 'Increase routing tests, upgrade route by route behind a flag', ['Stay on EOL forever', 'Upgrade everything at once with no tests'])]),
    ])

MAJOR = Major('Software Engineering at Bridgeline Digital', 'cs', 'software_engineering',
              ('Marcus Bell', 'Delivery Manager', 'We ship working software to real clients. Requirements, reviews and tests are how we keep our promises.'),
              [req, design, dev, git, testing, maint],
              {'se_lab_requirements': 'Requirements Engineering', 'se_lab_design': 'System Design and Architecture', 'se_lab_development': 'Software Development',
               'se_lab_git': 'Git and Collaboration', 'se_lab_testing': 'Software Testing and Quality Assurance', 'se_lab_maintenance': 'Software Maintenance'})
