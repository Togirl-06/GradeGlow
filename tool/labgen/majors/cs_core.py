"""Extra scenarios for the hand-built Computer Science labs (lib/career_sim/labs/content/cs_labs.dart)."""
import re
import os

from labgen import D, I, O, Lab, Major, Choice, ge, le, case, Code, V3, Sql, SqlV, ROOT
from majors._csx_code import M

_src = open(os.path.join(ROOT, 'lib/career_sim/labs/content/cs_labs.dart')).read()
UNIVERSITY_DB = re.search(r"const String universityDb = '''(.*?)''';", _src, re.S).group(1)

LEAD = 'Dr Lena Osei, lecturer in computer science'

fund = Lab('cs_lab_fundamentals', 1, 'Programming Fundamentals', 'computingLab', '', [], ['cs_prog', 'cs_debug'], 'xf', extends=True,
    code=[
        Code('receipt', 'Café till', 'The campus café’s till software needs rewriting.', [
            V3('Input: item prices separated by spaces. Print "Total: x" (2 dp).',
               [('2.50 3.20 1.05', 'Total: 6.75'), ('10', 'Total: 10.00'), ('0.99 0.01', 'Total: 1.00')], M['rc1']),
            V3('Line 1 the tax rate %, line 2 the prices. Print "Subtotal", "Tax" (rounded to the penny) and "Total", each 2 dp.',
               [('20\n2.50 3.20 1.05', 'Subtotal: 6.75\nTax: 1.35\nTotal: 8.10'), ('0\n5', 'Subtotal: 5.00\nTax: 0.00\nTotal: 5.00'), ('5\n1.10', 'Subtotal: 1.10\nTax: 0.06\nTotal: 1.16')], M['rc2']),
            V3('Split a bill fairly. Input "total people". Work in pence; give any leftover pennies to the first people. Print the shares (2 dp), space-separated.',
               [('10.00 3', '3.34 3.33 3.33'), ('100 4', '25.00 25.00 25.00 25.00'), ('0.05 2', '0.03 0.02')], M['rc3']),
        ], skills=['cs_prog']),
        Code('words', 'Text tools', 'The library wants simple text tools for its catalogue.', [
            V3('Input: text. Print the number of words (separated by whitespace).',
               [('the quick  brown fox', '4'), ('one', '1'), ('a\nb c', '3')], M['wd1']),
            V3('The starting program prints the last word. Print the longest word (letters and apostrophes; first if tied) and its length as "word (n)".',
               [('I love programming in Python', 'programming (11)'), ('cat dog', 'cat (3)'), ("don't stop", "don't (5)")], M['wd2'], None, M['wd2_bug']),
            V3('For each line print "palindrome" or "not a palindrome", ignoring case, spaces and punctuation.',
               [('Racecar\nA man, a plan, a canal: Panama\nhello', 'palindrome\npalindrome\nnot a palindrome'), ('No lemon, no melon', 'palindrome'), ('ab', 'not a palindrome')], M['wd3']),
        ], skills=['cs_prog']),
        Code('clock', 'Timetable clock', 'The timetable app shows times in several formats.', [
            V3('The starting program shows 0:15 for a quarter past midnight. Convert 24-hour times to 12-hour "h:mm am|pm".',
               [('00:15 09:05 12:00 13:45 23:59', '12:15 am\n9:05 am\n12:00 pm\n1:45 pm\n11:59 pm'), ('12:30', '12:30 pm'), ('01:00', '1:00 am')], M['ck1'], None, M['ck1_bug']),
            V3('Input lines "HH:MM minutes". Print the time after adding the minutes (24-hour, wrapping past midnight).',
               [('23:30 45\n09:00 90\n00:10 1440', '00:15\n10:30\n00:10'), ('12:00 0', '12:00'), ('22:59 61', '00:00')], M['ck2']),
            V3('Input lines "start end". Print the duration as "Hh MMm" (the end may be after midnight).',
               [('22:30 01:15\n09:00 17:30\n12:00 12:00', '2h 45m\n8h 30m\n0h 00m'), ('23:59 00:00', '0h 01m'), ('00:00 23:59', '23h 59m')], M['ck3']),
        ], skills=['cs_prog']),
        Code('checks', 'Check digits', 'The bookshop and the clinic both need input validation.', [
            V3('ISBN-10: digits weighted 10 down to 1 (X = 10) must sum to a multiple of 11. Print "isbn: valid|invalid" for each.',
               [('0306406152 0306406153 080442957X', '0306406152: valid\n0306406153: invalid\n080442957X: valid'), ('123', '123: invalid'), ('0000000000', '0000000000: valid')], M['cd1']),
            V3('Luhn check (card numbers): from the right, double every second digit (subtract 9 if over 9); the sum must end in 0. Print "number: passes|fails Luhn check" (spaces allowed).',
               [('4539 1488 0343 6467\n1234 5678 9012 3456\n79927398713', '4539 1488 0343 6467: passes Luhn check\n1234 5678 9012 3456: fails Luhn check\n79927398713: passes Luhn check'), ('0', '0: passes Luhn check'), ('18', '18: passes Luhn check')], M['cd2']),
            V3('NHS number: 10 digits; weights 10 to 2 on the first 9; check = 11 − (sum mod 11), 11 → 0, 10 → invalid; must equal the 10th digit. Print "n: valid", "n: invalid" or "n: invalid length".',
               [('943 476 5919\n943 476 5918\n123', '943 476 5919: valid\n943 476 5918: invalid\n123: invalid length'), ('401 023 2137', '401 023 2137: valid'), ('0000000000', '0000000000: valid')], M['cd3']),
        ], skills=['cs_prog', 'cs_debug']),
        Code('primes', 'Number patterns', 'The maths department wants teaching tools.', [
            V3('Input n. Print its times table from 1 to 10 as "i x n = p".',
               [('7', '\n'.join(f'{i} x 7 = {7 * i}' for i in range(1, 11))), ('1', '\n'.join(f'{i} x 1 = {i}' for i in range(1, 11))), ('12', '\n'.join(f'{i} x 12 = {12 * i}' for i in range(1, 11)))], M['pr1']),
            V3('The starting program misses some composites. Print all primes up to n, or "none".',
               [('30', '2 3 5 7 11 13 17 19 23 29'), ('1', 'none'), ('10', '2 3 5 7'), ('25', '2 3 5 7 11 13 17 19 23')], M['pr2'], None, M['pr2_bug']),
            V3('Print the prime factorisation of each number as "n = p x q x …".',
               [('84 97 360 1001', '84 = 2 x 2 x 3 x 7\n97 = 97\n360 = 2 x 2 x 2 x 3 x 3 x 5\n1001 = 7 x 11 x 13'), ('2', '2 = 2'), ('49', '49 = 7 x 7')], M['pr3']),
        ], skills=['cs_prog']),
    ])

dsa = Lab('cs_lab_dsa', 2, 'Data Structures and Algorithms', 'computingLab', '', [], ['cs_ds', 'cs_algo'], 'xd', extends=True,
    code=[
        Code('brackets', 'Bracket checker (stack)', 'The code editor needs bracket matching.', [
            V3('Input: strings of ( and ). Print "s: balanced|unbalanced".',
               [('(()) (() )( ()()', '(()): balanced\n((): unbalanced\n)(: unbalanced\n()(): balanced'), ('()', '(): balanced'), (')', '): unbalanced')], M['br1']),
            V3('The starting program only counts parentheses. Handle (), [] and {} with a stack.',
               [('([]{}) ([)] {[()]} ((', '([]{}): balanced\n([)]: unbalanced\n{[()]}: balanced\n((: unbalanced'), ('[]', '[]: balanced'), ('(]', '(]: unbalanced')], M['br2'], None, M['br2_bug']),
            V3('Report the first error for each line: "unexpected c at p" or "unclosed c at p" (1-based), otherwise "balanced". Other characters are ignored.',
               [('f(a[1)\nif (x { y }\n{[()]}\n)(', 'f(a[1): unexpected ) at 6\nif (x { y }: unclosed ( at 4\n{[()]}: balanced\n)(: unexpected ) at 1'), ('x[0]', 'x[0]: balanced'), ('{', '{: unclosed { at 1')], M['br3']),
        ], skills=['cs_ds']),
        Code('search', 'Binary search', 'The student records system searches sorted IDs.', [
            V3('The starting program can loop forever. Line 1 a sorted list, line 2 targets. Print "t: index" or -1 using binary search.',
               [('1 3 5 7 9 11\n7 1 11 4', '7: 3\n1: 0\n11: 5\n4: -1'), ('5\n5 6', '5: 0\n6: -1'), ('2 4\n4', '4: 1')], M['bs1'], None, M['bs1_bug']),
            V3('With duplicates, print "t: first i, count c" using two binary searches (first −1 and count 0 if absent).',
               [('1 2 2 2 5 7\n2 5 3 1', '2: first 1, count 3\n5: first 4, count 1\n3: first -1, count 0\n1: first 0, count 1'), ('4 4 4\n4', '4: first 0, count 3'), ('1\n0', '0: first -1, count 0')], M['bs2']),
            V3('Compare costs. Print "t: index i, binary b comparisons, linear l comparisons" (binary counts each midpoint check; linear counts until found, or n if absent).',
               [('1 3 5 7 9 11 13 15\n13 1 4', '13: index 6, binary 3 comparisons, linear 7 comparisons\n1: index 0, binary 3 comparisons, linear 1 comparisons\n4: index -1, binary 3 comparisons, linear 8 comparisons'),
                ('1 2 3\n2', '2: index 1, binary 1 comparisons, linear 2 comparisons'), ('10\n10', '10: index 0, binary 1 comparisons, linear 1 comparisons')], M['bs3']),
        ], skills=['cs_algo']),
        Code('sorting', 'Sorting', 'The grade reports must be sorted correctly.', [
            V3('The starting program sorts numbers as text. Print the numbers in ascending numeric order.',
               [('10 2 33 4', '2 4 10 33'), ('5 -1 0', '-1 0 5'), ('100 20 3', '3 20 100')], M['so1'], None, M['so1_bug']),
            V3('Input lines "name,score". Print "name score" by score descending, then name ascending.',
               [('Ana,90\nBen,85\nCy,90\nDee,70', 'Ana 90\nCy 90\nBen 85\nDee 70'), ('Z,1\nA,1', 'A 1\nZ 1'), ('Solo,50', 'Solo 50')], M['so2']),
            V3('Merge k sorted lists (one per line) into one sorted list efficiently.',
               [('1 4 9\n2 3 10\n5', '1 2 3 4 5 9 10'), ('1 1\n1', '1 1 1'), ('3\n1\n2', '1 2 3')], M['so3']),
        ], skills=['cs_algo']),
        Code('graphs', 'Campus routes (graphs)', 'The campus map app finds routes between buildings. Edges are undirected.', [
            V3('Input edges "A B". Print each node’s neighbours alphabetically as "node: n1 n2 …".',
               [('A B\nB C\nA C\nC D', 'A: B C\nB: A C\nC: A B D\nD: C'), ('X Y', 'X: Y\nY: X'), ('A B\nA B', 'A: B\nB: A')], M['gr1']),
            V3('Line 1 "start end", then edges. Print "start to end: n hops" using breadth-first search, or "unreachable".',
               [('A E\nA B\nB C\nC E\nA D\nD E', 'A to E: 2 hops'), ('A Z\nA B', 'A to Z: unreachable'), ('A A\nA B', 'A to A: 0 hops')], M['gr2']),
            V3('Print the shortest route "A -> … -> E"; when several are equally short, explore neighbours alphabetically (BFS) so the result is deterministic. Print "No route" if none.',
               [('A E\nA B\nB C\nC E\nA D\nD E', 'A -> D -> E'), ('X Y\nX Z', 'No route'), ('A C\nA B\nB C\nA C', 'A -> C')], M['gr3']),
        ], skills=['cs_algo', 'cs_ds']),
        Code('hashing', 'Hash maps', 'Use dictionaries to make slow code fast.', [
            V3('Count words case-insensitively; print "word n" alphabetically.',
               [('The cat the Dog THE', 'cat 1\ndog 1\nthe 3'), ('a', 'a 1'), ('b a b', 'a 1\nb 2')], M['ha1']),
            V3('The starting program is O(n²) and can reuse the same element. Line 1 numbers, line 2 target. Print the first pair of indices "i j" (i < j) summing to the target using a hash map, or "none".',
               [('2 7 11 15\n9', '0 1'), ('3 2 4\n6', '1 2'), ('1 2\n7', 'none'), ('3 3\n6', '0 1')], M['ha2'], None, M['ha2_bug']),
            V3('Group anagrams. Print each group’s words sorted, one group per line, largest groups first (then by first word).',
               [('listen silent enlist google inlets banana', 'enlist inlets listen silent\nbanana\ngoogle'), ('ab ba c', 'ab ba\nc'), ('x', 'x')], M['ha3']),
        ], skills=['cs_ds']),
    ])

db = Lab('cs_lab_database', 3, 'Database Engineering', 'computingLab', '', [], ['cs_db'], 'xb', extends=True, database=UNIVERSITY_DB,
    sql=[
        Sql('filters', 'Filtering students', 'The registry office needs student lists.', [
            SqlV('List the names of first-year students (year 1).', "SELECT name FROM students WHERE year = 1"),
            SqlV('List the name and major of Law and Accounting students, ordered by name.', "SELECT name, major FROM students WHERE major IN ('Law', 'Accounting') ORDER BY name", ordered=True),
            SqlV('List, alphabetically, the names of students whose name contains “an” in any letter case.', "SELECT name FROM students WHERE LOWER(name) LIKE '%an%' ORDER BY name", ordered=True),
        ], skills=['cs_db']),
        Sql('joins', 'Joining tables', 'The timetabling team needs enrolment views.', [
            SqlV('Show each student’s name with the title of every CS course they are enrolled on (codes starting CS).', "SELECT s.name, c.title FROM enrollments e JOIN students s ON s.id = e.student_id JOIN courses c ON c.code = e.course_code WHERE c.code LIKE 'CS%'"),
            SqlV('Find the names of students who are not enrolled on any course.', "SELECT s.name FROM students s LEFT JOIN enrollments e ON e.student_id = s.id WHERE e.student_id IS NULL"),
            SqlV('Show the name and total credits of students enrolled on at least 30 credits.', "SELECT s.name, SUM(c.credits) FROM students s JOIN enrollments e ON e.student_id = s.id JOIN courses c ON c.code = e.course_code GROUP BY s.id HAVING SUM(c.credits) >= 30"),
        ], skills=['cs_db']),
        Sql('aggregates', 'Reporting with aggregates', 'The dean wants summary statistics.', [
            SqlV('Show each major and how many students it has.', "SELECT major, COUNT(*) FROM students GROUP BY major"),
            SqlV('Show each course code and its average grade rounded to 1 dp (graded enrolments only), highest average first.', "SELECT course_code, ROUND(AVG(grade), 1) FROM enrollments WHERE grade IS NOT NULL GROUP BY course_code ORDER BY AVG(grade) DESC", ordered=True),
            SqlV('For courses whose average grade is above 75, show the title, the number of graded students and the top grade.', "SELECT c.title, COUNT(e.grade), MAX(e.grade) FROM courses c JOIN enrollments e ON e.course_code = c.code GROUP BY c.code HAVING AVG(e.grade) > 75"),
        ], skills=['cs_db']),
        Sql('changes', 'Changing data safely', 'Registry updates arrive from admissions.', [
            SqlV('Add a new student: id 8, Hana Sato, Computer Science, year 1.', "INSERT INTO students VALUES (8, 'Hana Sato', 'Computer Science', 1)", check="SELECT id, name, major, year FROM students WHERE id = 8"),
            SqlV('Every Law student moves up one year. Update their records without changing anyone else.', "UPDATE students SET year = year + 1 WHERE major = 'Law'", check="SELECT name, year FROM students ORDER BY id", ordered=True),
            SqlV('CS101 is now worth 20 credits, and Ben Hart (id 2) has withdrawn from LAW100. Make both changes.', "UPDATE courses SET credits = 20 WHERE code = 'CS101'; DELETE FROM enrollments WHERE student_id = 2 AND course_code = 'LAW100'",
                 check="SELECT 'CS101', credits FROM courses WHERE code = 'CS101' UNION ALL SELECT 'enrolments', COUNT(*) FROM enrollments", ordered=True),
        ], skills=['cs_db']),
        Sql('repairs', 'Repairing broken queries', 'Colleagues’ queries give wrong answers. Fix them.', [
            SqlV('This should show each major with its average year, but returns one row. Fix it.', "SELECT major, AVG(year) FROM students GROUP BY major", starter="SELECT major, AVG(year) FROM students"),
            SqlV('This should list CS101 students and their grades, highest first, but the join is wrong. Fix it.', "SELECT s.name, e.grade FROM students s JOIN enrollments e ON e.student_id = s.id WHERE e.course_code = 'CS101' ORDER BY e.grade DESC",
                 ordered=True, starter="SELECT s.name, e.grade FROM students s JOIN enrollments e ON e.student_id = s.year WHERE e.course_code = 'CS101' ORDER BY e.grade DESC"),
            SqlV('This should list ungraded enrolments (student name and course code) but returns nothing. Fix it.', "SELECT s.name, e.course_code FROM enrollments e JOIN students s ON s.id = e.student_id WHERE e.grade IS NULL",
                 starter="SELECT s.name, e.course_code FROM enrollments e JOIN students s ON s.id = e.student_id WHERE e.grade = NULL"),
        ], skills=['cs_db']),
    ])

os_lab = Lab('cs_lab_os', 4, 'Computer Architecture and Operating Systems', 'computingLab', '', [], ['cs_os', 'cs_algo'], 'xo', extends=True,
    code=[
        Code('roundrobin', 'Round Robin scheduler', 'Implement the CPU scheduler for the teaching OS.', [
            V3('Line 1 the time quantum, then jobs "name burst" (all arrive at 0, queued in order). Print the timeline "name(start-end)" space-separated.',
               [('2\nP1 5\nP2 3\nP3 1', 'P1(0-2) P2(2-4) P3(4-5) P1(5-7) P2(7-8) P1(8-9)'), ('4\nA 3', 'A(0-3)'), ('1\nA 2\nB 1', 'A(0-1) B(1-2) A(2-3)')], M['rr1']),
            V3('Print each job’s finish time and waiting time (finish − burst), then "Average waiting: x" (2 dp).',
               [('2\nP1 5\nP2 3\nP3 1', 'P1: finish 9, waiting 4\nP2: finish 8, waiting 5\nP3: finish 5, waiting 4\nAverage waiting: 4.33'), ('4\nA 3', 'A: finish 3, waiting 0\nAverage waiting: 0.00'), ('1\nA 2\nB 1', 'A: finish 3, waiting 1\nB: finish 2, waiting 1\nAverage waiting: 1.00')], M['rr2']),
            V3('Jobs now arrive over time: "name arrival burst". New arrivals join the queue before a pre-empted job; the CPU idles if the queue is empty. Print each job’s turnaround (finish − arrival) and waiting time, then "Average turnaround: x" (2 dp).',
               [('2\nP1 0 5\nP2 1 3\nP3 2 1', 'P1: turnaround 9, waiting 4\nP2: turnaround 7, waiting 4\nP3: turnaround 3, waiting 2\nAverage turnaround: 6.33'), ('3\nA 0 2\nB 10 3', 'A: turnaround 2, waiting 0\nB: turnaround 3, waiting 0\nAverage turnaround: 2.50'), ('1\nX 0 1', 'X: turnaround 1, waiting 0\nAverage turnaround: 1.00')], M['rr3']),
        ], skills=['cs_os']),
        Code('paging', 'Page replacement', 'Compare page-replacement policies for the memory manager.', [
            V3('Line 1 the number of frames, line 2 page references. Print "FIFO page faults: n".',
               [('3\n7 0 1 2 0 3 0 4 2 3 0 3 2', 'FIFO page faults: 10'), ('3\n1 2 3 4 1 2 5 1 2 3 4 5', 'FIFO page faults: 9'), ('1\n1 1 2', 'FIFO page faults: 2')], M['pg1']),
            V3('The starting program uses FIFO. Implement LRU and print "LRU page faults: n".',
               [('3\n7 0 1 2 0 3 0 4 2 3 0 3 2', 'LRU page faults: 9'), ('3\n1 2 3 4 1 2 5 1 2 3 4 5', 'LRU page faults: 10'), ('2\n1 2 1 3 1', 'LRU page faults: 3')], M['pg2'], None, M['pg2_bug']),
            V3('Compare FIFO, LRU and OPT (replace the page used furthest in the future; ties go to the page loaded earliest in the frames). Print "FIFO a LRU b OPT c" and "Best practical: LRU|FIFO" (LRU if tied).',
               [('3\n7 0 1 2 0 3 0 4 2 3 0 3 2', 'FIFO 10 LRU 9 OPT 7\nBest practical: LRU'), ('3\n1 2 3 4 1 2 5 1 2 3 4 5', 'FIFO 9 LRU 10 OPT 7\nBest practical: FIFO'), ('2\n1 2 3', 'FIFO 3 LRU 3 OPT 3\nBest practical: LRU')], M['pg3']),
        ], skills=['cs_os']),
        Code('memory', 'Address translation', 'Model the MMU for the architecture course.', [
            V3('Line 1 the page size in bytes, line 2 logical addresses. Print "a: page p, offset o".',
               [('1024\n0 1023 1024 5000', '0: page 0, offset 0\n1023: page 0, offset 1023\n1024: page 1, offset 0\n5000: page 4, offset 904'), ('4096\n8192', '8192: page 2, offset 0'), ('100\n250', '250: page 2, offset 50')], M['mm1']),
            V3('Line 2 the page table "page:frame" (- means not in memory), line 3 addresses. Print "a: physical x" or "a: page fault (page p)".',
               [('1024\n0:5 1:2 2:- 3:7\n100 1500 2100 3100', '100: physical 5220\n1500: physical 2524\n2100: page fault (page 2)\n3100: physical 7196'), ('100\n0:3\n42', '42: physical 342'), ('100\n0:-\n5', '5: page fault (page 0)')], M['mm2']),
            V3('Effective access time with a TLB. Input lines "hit% tlb_ns memory_ns". EAT = h(t + m) + (1 − h)(t + 2m). Print "Hit ratio h%: EAT x ns" (1 dp).',
               [('80 20 100\n98 20 100', 'Hit ratio 80%: EAT 140.0 ns\nHit ratio 98%: EAT 122.0 ns'), ('100 10 50', 'Hit ratio 100%: EAT 60.0 ns'), ('0 10 50', 'Hit ratio 0%: EAT 110.0 ns')], M['mm3']),
        ], skills=['cs_os']),
        Code('bankers', 'Deadlock avoidance (Banker’s algorithm)', 'Implement deadlock avoidance for the resource manager.', [
            V3('Line 1 n processes; next n lines Max; next n lines Allocation. Print "Pi: need …" (Need = Max − Allocation).',
               [('2\n7 5 3\n3 2 2\n0 1 0\n2 0 0', 'P0: need 7 4 3\nP1: need 1 2 2'), ('1\n2 2\n1 0', 'P0: need 1 2'), ('1\n1\n1', 'P0: need 0')], M['bk1']),
            V3('Add a line with Available. Run the safety algorithm, scanning P0…Pn−1 repeatedly and running any process whose Need fits. Print "SAFE: P… P…" in that order, or "UNSAFE".',
               [('5\n7 5 3\n3 2 2\n9 0 2\n2 2 2\n4 3 3\n0 1 0\n2 0 0\n3 0 2\n2 1 1\n0 0 2\n3 3 2', 'SAFE: P1 P3 P4 P0 P2'), ('2\n3 3\n3 3\n1 1\n1 1\n1 1', 'UNSAFE'), ('1\n2\n1\n1', 'SAFE: P0')], M['bk2']),
            V3('A final line "Pi r1 r2 …" requests resources. Print "DENIED: request exceeds declared maximum", "WAIT: resources not available", "GRANTED: state remains safe" or "DENIED: would leave the system unsafe".',
               [('5\n7 5 3\n3 2 2\n9 0 2\n2 2 2\n4 3 3\n0 1 0\n2 0 0\n3 0 2\n2 1 1\n0 0 2\n3 3 2\nP1 1 0 2', 'GRANTED: state remains safe'), ('5\n7 5 3\n3 2 2\n9 0 2\n2 2 2\n4 3 3\n0 1 0\n2 0 0\n3 0 2\n2 1 1\n0 0 2\n3 3 2\nP4 3 3 0', 'DENIED: would leave the system unsafe'),
                ('5\n7 5 3\n3 2 2\n9 0 2\n2 2 2\n4 3 3\n0 1 0\n2 0 0\n3 0 2\n2 1 1\n0 0 2\n3 3 2\nP1 2 0 0', 'DENIED: request exceeds declared maximum'), ('5\n7 5 3\n3 2 2\n9 0 2\n2 2 2\n4 3 3\n0 1 0\n2 0 0\n3 0 2\n2 1 1\n0 0 2\n3 3 2\nP0 4 0 0', 'WAIT: resources not available')], M['bk3']),
        ], skills=['cs_os', 'cs_algo']),
    ],
    problems=[
        D('cpu', 'CPU performance', 'A program runs n million instructions. CPU time = instructions × CPI ÷ clock rate. Choose the design.',
          [I('n', 'Instructions (millions)', 100, 2000, 100, 2000), I('c', 'Average CPI', 0.5, 4, 0.5, 4), I('f', 'Clock rate', 1, 5, 0.5, 1, 'GHz')],
          [O('T', 'CPU time', 'n*c/f', 'ms', 1), O('W', 'Power estimate (∝ f²)', '10*f^2', 'W', 1)],
          {'n': 2000, 'c': 4, 'f': 1}, ['T', 'W'],
          ([le('T', 1000, 'Run in under 1 second')], [ge('n', 1200, 'The workload is 1,200 million instructions'), ge('c', 1.5, 'CPI at least 1.5 (realistic for this ISA)')], [le('W', 100, 'Power within 100 W (cooling)'), le('T', 650, 'Under 650 ms (interactive)')]),
          {'n': 1200, 'c': 1.5, 'f': 3}),
    ])

project = Lab('cs_lab_project', 5, 'Software Project Laboratory', 'techOffice', '', [], ['cs_se', 'cs_review'], 'xp', extends=True,
    problems=[
        D('velocity', 'Planning the release', 'The team has a backlog of story points and a measured velocity per two-week sprint.',
          [I('p', 'Points in the release', 20, 160, 10, 160), I('v', 'Planned velocity', 10, 40, 2, 10)],
          [O('S', 'Sprints', 'p/v', 'sprints', 1)],
          {'p': 160, 'v': 10}, ['S'],
          ([le('S', 6, 'Release within 6 sprints')], [ge('p', 90, 'Must-have stories total 90 points'), le('v', 22, 'No faster than the measured 22 points per sprint')], [le('S', 4.5, 'Leave the final sprint for hardening (≤ 4.5 sprints)')]),
          {'p': 90, 'v': 20}),
    ],
    cases=[
        case('scope', 'Client requirements workshop', 'The student union wants a society-booking system.', 'Requests',
             [('moscow', 'Priority', ['Must', 'Should', 'Could', 'Won’t (this release)'])],
             [('Book', 'Societies book rooms online.', {'moscow': 'Must'}), ('Clash', 'Prevent double bookings.', {'moscow': 'Must'}), ('Email', 'Email confirmations.', {'moscow': 'Should'}),
              ('Chat', 'Built-in chat between societies.', {'moscow': 'Won’t (this release)|Could'}), ('Themes', 'Custom colour themes per society.', {'moscow': 'Could|Won’t (this release)'})],
             'Amara Diallo, student union president', 'We want everything by the end of term!',
             [('E', 'What must work on day one for the union to switch from paper?', 'Booking and no double bookings.'),
              ('E', 'Can we agree a MoSCoW list and fix the Musts?', 'Yes, fair.'),
              ('U', 'How many societies?', 'About 120.'),
              ('N', 'What’s the union’s colour?', 'Purple.'),
              ('P', 'Promise every feature by end of term?', 'That would be great!', 'Over-promising guarantees failure.')],
             conclusions=[Choice('mvp', 'Release 1 must include', 'online booking with clash prevention', ['chat', 'themes'])]),
        case('standup', 'Daily stand-up', 'Run the team stand-up on day 6 of the sprint.', 'Updates',
             [('act', 'Action', ['Fine', 'Blocker: act today', 'Take offline'])],
             [('Ana', 'Finished the booking form; starting validation.', {'act': 'Fine'}), ('Ben', 'Blocked for two days waiting for database access.', {'act': 'Blocker: act today'}, 'Unresolved blockers sink sprints.'),
              ('Cy', 'Wants to debate the ideal framework for 20 minutes.', {'act': 'Take offline'}), ('Dee', 'Clash detection 80% done, needs a review.', {'act': 'Fine'})],
             'Ben Ortiz, developer', 'I still can’t get into the database…',
             [('E', 'I’ll chase the admin straight after stand-up and pair you with Dee meanwhile.', 'Thanks.'),
              ('E', 'Cy, can we take the framework discussion offline after?', 'Sure.'),
              ('U', 'Is the sprint goal still realistic?', 'If Ben’s unblocked today.'),
              ('N', 'Lunch plans?', 'Later.'),
              ('P', 'Let’s spend the stand-up solving the database issue?', 'It’ll take ages.', 'Stand-ups surface blockers; solving happens after.')],
             conclusions=[Choice('purpose', 'A stand-up is for', 'syncing progress and surfacing blockers quickly', ['long design debates', 'status reports to managers only'])]),
        case('demo', 'Sprint review with the client', 'Demo the booking system at the end of sprint 2.', 'Feedback',
             [('act', 'Action', ['Fix now', 'Add to backlog', 'Decline'])],
             [('Bug', 'Bookings across midnight show the wrong date.', {'act': 'Fix now'}, 'A correctness bug in a core flow.', True), ('Export', '“Can we export to a spreadsheet?”', {'act': 'Add to backlog'}),
              ('Override', '“Let the president delete anyone’s booking without a log.”', {'act': 'Decline'}, 'Unaudited deletion is a governance risk.'), ('Colour', '“Make the buttons purple.”', {'act': 'Add to backlog'})],
             'Amara Diallo, student union president', 'This looks great — a few thoughts…',
             [('E', 'We’ll fix the midnight date bug first and add a test for it.', 'Great.'),
              ('E', 'Deletions can be allowed with an audit log — would that work?', 'Yes, that’s better.'),
              ('U', 'Who will train society secretaries?', 'Me.'),
              ('N', 'How was exam season?', 'Busy.'),
              ('P', 'Add every request to this sprint?', 'Could you?', 'Changing scope mid-sprint breaks commitments.')],
             conclusions=[Choice('first', 'First priority from the review', 'Fix the midnight date bug with a regression test', ['Purple buttons', 'Unlogged deletions'])]),
        case('retro', 'Sprint retrospective', 'Facilitate the team retrospective after sprint 2.', 'Retro notes',
             [('type', 'Category', ['Went well', 'To improve', 'Action'])],
             [('Pairing', 'Pairing on the clash detector caught bugs early.', {'type': 'Went well'}), ('Reviews', 'PRs waited 3 days for review.', {'type': 'To improve'}),
              ('Rule', 'Agree: every PR reviewed within one working day.', {'type': 'Action'}), ('Tests', 'Flaky tests failed CI twice.', {'type': 'To improve'})],
             'Dee Kumar, developer', 'Retros usually turn into moaning. How do we make this useful?',
             [('E', 'Let’s pick at most two actions, each with an owner and a date.', 'Good idea.'),
              ('E', 'Can we start by checking last retro’s actions?', 'Yes.'),
              ('U', 'Should we vote on topics?', 'Dot-voting works.'),
              ('N', 'Who brought biscuits?', 'Ana.'),
              ('P', 'Name the person who broke the build?', 'That’s not the point.', 'Blame destroys psychological safety.')],
             conclusions=[Choice('good', 'A good retro produces', 'a few owned, time-bound improvement actions', ['a list of who to blame', 'nothing'])],
             procedure=['Review last sprint’s actions', 'Gather what went well and what to improve', 'Group and vote on themes', 'Agree owned actions', 'Record and share the outcome'], must=[(0, 1), (1, 2), (2, 3), (3, 4)],
             doc=('Retrospective record', [
                 ('Themes', [('Notes a strength', [r'pair|went well|worked']), ('Notes a problem', [r'review|flaky|wait'])],
                  'Pairing on the clash detector worked well and caught bugs early. Pull requests waited up to three days for review, and flaky tests broke CI twice.'),
                 ('Actions', [('Has an owner', [r'(Ana|Ben|Cy|Dee)|owner']), ('Has a date or timeframe', [r'by|within|next sprint|\d'])],
                  'Action 1: every pull request reviewed within one working day — owner Dee. Action 2: Ben will fix or quarantine the flaky tests by the end of next sprint.')])),
    ])

MAJOR = Major('Computer Science at GradeGlow University', 'cs', 'computer_science',
              ('Dr Lena Osei', 'Lecturer, Computer Science', 'Run your code often. The tests tell you what is wrong — not the answer.'),
              [fund, dsa, db, os_lab, project],
              {'cs_lab_fundamentals': 'Programming Laboratory', 'cs_lab_dsa': 'Data Structures and Algorithms', 'cs_lab_database': 'Database Engineering',
               'cs_lab_os': 'Computer Architecture and Operating Systems', 'cs_lab_project': 'Software Project Laboratory'})
