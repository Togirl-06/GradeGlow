"""GradeGlow lab generator.

Content for formula-driven and casework labs is written as Python data in
tool/labgen/majors/*.py. This module validates every scenario before any Dart
is written:

  * design problems: formulas evaluate, the model design meets every
    requirement at every level and sits on the slider grid, the starting
    settings do not already meet the specification, hand-calculation answers
    are finite and small enough that a wrong answer cannot pass by tolerance;
  * investigations: evidence both supports and contradicts, options distinct;
  * case files: every queue decision is one of its options and has a wrong
    alternative; conversations have essential and poor/neutral moves; the
    model document meets its own rubric; procedures have 4+ steps.

Then it emits lib/career_sim/labs/content/gen_<name>.dart and
tool/labgen/built.json (read by tool/lab_tracker.py).

Run: python3 tool/labgen/build.py
"""
import json
import math
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


class ContentError(Exception):
    pass


# ------------------------------------------------------------ data types

class I:  # simulation input
    def __init__(self, name, label, lo, hi, step=1, init=None, unit=''):
        self.name, self.label, self.lo, self.hi, self.step, self.init, self.unit = name, label, lo, hi, step, init, unit


class O:  # simulation output
    def __init__(self, name, label, formula, unit='', dec=2):
        self.name, self.label, self.formula, self.unit, self.dec = name, label, formula, unit, dec


class C:  # constraint
    def __init__(self, out, op, value, label):
        self.out, self.op, self.value, self.label = out, op, value, label


def ge(o, v, label): return C(o, '>=', v, label)
def le(o, v, label): return C(o, '<=', v, label)


class Choice:
    def __init__(self, id, prompt, correct, wrong, explain=''):
        self.id, self.prompt, self.correct, self.wrong, self.explain = id, prompt, correct, list(wrong), explain


class Num:
    def __init__(self, id, prompt, answer, tol=0.01, relative=True, unit='', explain=''):
        self.id, self.prompt, self.answer, self.tol, self.relative, self.unit, self.explain = id, prompt, answer, tol, relative, unit, explain


class D:  # design problem
    def __init__(self, key, title, brief, inputs, outputs, given, ask, levels, model, formulas=(), interpret=None):
        self.key, self.title, self.brief = key, title, brief
        self.inputs, self.outputs, self.given, self.ask = inputs, outputs, given, ask
        self.levels, self.model, self.formulas, self.interpret = levels, model, list(formulas), interpret


class V:  # investigation
    def __init__(self, key, title, brief, evidence, cause, wrong_causes, fix, wrong_fixes, calc=None, steps=(), must=()):
        self.key, self.title, self.brief, self.evidence = key, title, brief, evidence
        self.cause, self.wrong_causes, self.fix, self.wrong_fixes = cause, wrong_causes, fix, wrong_fixes
        self.calc, self.steps, self.must = calc, list(steps), list(must)


class F:  # triage field
    def __init__(self, id, label, options):
        self.id, self.label, self.options = id, label, options


class Item:
    def __init__(self, id, title, body, answers, meta=None, why='', critical=False):
        self.id, self.title, self.body, self.answers, self.meta, self.why, self.critical = id, title, body, answers, meta or {}, why, critical


class Opt:
    VALUES = ('essential', 'useful', 'neutral', 'poor', 'unsafe')

    def __init__(self, id, say, reply, value='neutral', note=''):
        assert value in Opt.VALUES, value
        self.id, self.say, self.reply, self.value, self.note = id, say, reply, value, note


def E(id, say, reply, note=''): return Opt(id, say, reply, 'essential', note)
def U(id, say, reply, note=''): return Opt(id, say, reply, 'useful', note)
def N(id, say, reply, note=''): return Opt(id, say, reply, 'neutral', note)
def P(id, say, reply, note=''): return Opt(id, say, reply, 'poor', note)
def X(id, say, reply, note=''): return Opt(id, say, reply, 'unsafe', note)


class R:  # rubric item
    def __init__(self, label, patterns, advice='', weight=1):
        self.label, self.patterns, self.advice, self.weight = label, patterns, advice, weight


class Sec:
    def __init__(self, id, heading, rubric, model, guidance='', min_words=20):
        self.id, self.heading, self.rubric, self.model, self.guidance, self.min_words = id, heading, rubric, model, guidance, min_words


class Case:
    def __init__(self, key, title, brief, queue, fields, items, person, opening, options, conclusions=(),
                 procedure=(), must=(), doc_type='', sections=(), forbidden=(), sources=()):
        self.key, self.title, self.brief, self.queue, self.fields, self.items = key, title, brief, queue, fields, items
        self.person, self.opening, self.options, self.conclusions = person, opening, options, list(conclusions)
        self.procedure, self.must, self.doc_type, self.sections = list(procedure), list(must), doc_type, list(sections)
        self.forbidden, self.sources = list(forbidden), list(sources)


class Code:
    """A programming problem at three levels: variants = [(instructions, [(stdin, expected)], model_py, model_js, starter_py, starter_js)]."""
    def __init__(self, key, title, brief, variants, skills=()):
        self.key, self.title, self.brief, self.variants, self.skills = key, title, brief, variants, list(skills)


def V3(instructions, cases, py, js=None, starter_py=None, starter_js=None):
    return (instructions, cases, py, js, starter_py, starter_js)


class Sql:
    """A SQL problem at three levels: variants = [SqlV(...)]; run against `database` (SQLite)."""
    def __init__(self, key, title, brief, variants, skills=()):
        self.key, self.title, self.brief, self.variants, self.skills = key, title, brief, variants, list(skills)


def SqlV(instructions, ref, check=None, ordered=False, starter=''):
    return {'instructions': instructions, 'ref': ref, 'check': check, 'ordered': ordered, 'starter': starter}


class Lab:
    def __init__(self, id, number, title, env, summary, objectives, skills, prefix, problems=(), investigations=(), cases=(),
                 reference=(), minutes=30, difficulty='intermediate', portfolio=False, tools=(), code=(), sql=(), database='', extends=False):
        self.code, self.sql, self.database, self.extends = list(code), list(sql), database, extends
        self.id, self.number, self.title, self.env, self.summary = id, number, title, env, summary
        self.objectives, self.skills, self.prefix = objectives, skills, prefix
        self.problems, self.investigations, self.cases = list(problems), list(investigations), list(cases)
        self.reference, self.minutes, self.difficulty, self.portfolio, self.tools = list(reference), minutes, difficulty, portfolio, list(tools)


class Major:
    def __init__(self, name, dept, major, person, labs, blueprint_titles):
        """blueprint_titles: lab id -> the lab title used in tool/lab_tracker.py."""
        self.name, self.dept, self.major, self.person, self.labs, self.blueprint_titles = name, dept, major, person, labs, blueprint_titles


# ------------------------------------------------------------ formula evaluation (mirrors expr.dart)

FUNCS = {'sqrt': math.sqrt, 'exp': math.exp, 'ln': math.log, 'log': math.log10, 'sin': math.sin, 'cos': math.cos,
         'tan': math.tan, 'abs': abs, 'atan': math.atan, 'asin': math.asin, 'acos': math.acos}
NAME_RE = re.compile(r'^([a-zA-Z]|[A-Z][0-9]+)$')


def check_name(n, where):
    if not NAME_RE.match(n) or n == 'e':
        raise ContentError(f'{where}: variable name "{n}" must be one letter (not e) or a capital with digits')


def evaluate(formula, env, where):
    if re.search(r'[0-9)]\s*[a-zA-Z(]|[a-zA-Z]\s+[a-zA-Z(]', formula.replace('sqrt', 'S').replace('exp', 'S').replace('ln', 'S').replace('log', 'S').replace('sin', 'S').replace('cos', 'S').replace('tan', 'S').replace('abs', 'S').replace('pi', 'S')):
        # Implicit multiplication is legal in the app but keep generated formulas explicit.
        pass
    tokens = re.findall(r'[A-Za-z][A-Za-z0-9]*|[0-9.]+|\*\*|[-+*/^(),]', formula)
    out = []
    for t in tokens:
        if t[0].isalpha():
            if t in FUNCS:
                out.append(f'F["{t}"]')
            elif t == 'pi':
                out.append('math.pi')
            elif t == 'e':
                out.append('math.e')
            elif t in env:
                out.append(f'V["{t}"]')
            else:
                raise ContentError(f'{where}: unknown name "{t}" in formula {formula!r} (multi-letter names are not allowed)')
        elif t == '^':
            out.append('**')
        else:
            out.append(t)
    try:
        v = eval(''.join(out), {'F': FUNCS, 'V': env, 'math': math})
    except (ZeroDivisionError, ValueError, OverflowError):
        return float('nan')
    return float(v)


def run_outputs(p, values):
    env = dict(values)
    for o in p.outputs:
        env[o.name] = evaluate(o.formula, env, f'{p.key}.{o.name}')
    return env


def met(c, v):
    if v != v:
        return False
    tol = 1e-9 * max(1, abs(c.value))
    return {'<=': v <= c.value + tol, '>=': v >= c.value - tol, '<': v < c.value, '>': v > c.value}.get(c.op, abs(v - c.value) <= 0.01 * max(1, abs(c.value)))


def validate_design(p, where):
    names = [i.name for i in p.inputs]
    for n in names + [o.name for o in p.outputs]:
        check_name(n, where)
    if len(set(names + [o.name for o in p.outputs])) != len(names) + len(p.outputs):
        raise ContentError(f'{where}: duplicate variable names')
    if len(p.levels) != 3:
        raise ContentError(f'{where}: three specification levels needed')
    for i in p.inputs:
        if i.name not in p.given:
            raise ContentError(f'{where}: given value missing for {i.name}')
        if i.init is None:
            i.init = i.lo
        for v, what in ((p.model[i.name], 'model'), (i.init, 'initial')):
            if not (i.lo - 1e-9 <= v <= i.hi + 1e-9):
                raise ContentError(f'{where}: {what} {i.name}={v} outside [{i.lo}, {i.hi}]')
            k = (v - i.lo) / i.step
            if abs(k - round(k)) > 1e-6:
                raise ContentError(f'{where}: {what} {i.name}={v} is not on the slider grid (step {i.step})')
    env = run_outputs(p, p.given)
    for a in p.ask:
        v = env[a]
        if not math.isfinite(v):
            raise ContentError(f'{where}: hand calculation {a} is not finite')
        if abs(v) * 0.01 >= 1000:
            raise ContentError(f'{where}: hand-calculation answer {a}={v} is too large for the 1% tolerance test; rescale units')
    cum = []
    for lvl, cs in enumerate(p.levels):
        cum = cum + cs
        menv = run_outputs(p, p.model)
        for c in cum:
            if c.out not in menv:
                raise ContentError(f'{where}: constraint on unknown output {c.out}')
            if not met(c, menv[c.out]):
                raise ContentError(f'{where}: model fails level {lvl + 1} requirement "{c.label}" ({c.out}={menv[c.out]:.6g})')
        if lvl == 0:
            ienv = run_outputs(p, {i.name: i.init for i in p.inputs})
            if all(met(c, ienv[c.out]) for c in cs):
                raise ContentError(f'{where}: the starting settings already meet specification A')
    return env


def validate_investigation(v, where):
    if not any(e[1] for e in v.evidence) or all(e[1] for e in v.evidence):
        raise ContentError(f'{where}: evidence must include supporting and non-supporting observations')
    if v.cause in v.wrong_causes or v.fix in v.wrong_fixes or len(v.wrong_causes) < 2 or len(v.wrong_fixes) < 2:
        raise ContentError(f'{where}: need distinct wrong causes/fixes')
    if v.calc and abs(v.calc[1]) * 0.02 >= 1000:
        raise ContentError(f'{where}: calc answer too large')
    if v.steps and len(v.steps) < 4:
        raise ContentError(f'{where}: procedure needs 4+ steps')
    for a, b in v.must:
        if not (0 <= a < len(v.steps) and 0 <= b < len(v.steps) and a < b):
            raise ContentError(f'{where}: bad mustPrecede {(a, b)}')


def _run(cmd, src, stdin):
    import subprocess, tempfile
    with tempfile.NamedTemporaryFile('w', suffix='.py' if cmd == 'python3' else '.js', delete=False) as f:
        f.write(src)
        path = f.name
    try:
        r = subprocess.run([cmd, path], input=stdin, capture_output=True, text=True, timeout=5)
    except subprocess.TimeoutExpired:
        return '', 'time limit exceeded', 124
    finally:
        os.unlink(path)
    return r.stdout, r.stderr, r.returncode


def _norm(s):
    return '\n'.join(l.rstrip() for l in s.replace('\r\n', '\n').split('\n')).strip()


def validate_code(c, where):
    if len(c.variants) != 3:
        raise ContentError(f'{where}: three variants needed')
    for n, (instr, cases, py, js, spy, sjs) in enumerate(c.variants):
        if len(cases) < 3:
            raise ContentError(f'{where} v{n + 1}: at least 3 test cases')
        for lang, src in (('python3', py), ('node', js)):
            if src is None:
                continue
            for stdin, expected in cases:
                out, err, code = _run(lang, src, stdin)
                if code != 0 or _norm(out) != _norm(expected):
                    raise ContentError(f'{where} v{n + 1} {lang}: model fails on input {stdin!r}: got {out!r} expected {expected!r} {err[-200:]}')
        for lang, src in (('python3', spy), ('node', sjs)):
            if src is None:
                continue
            if all(_run(lang, src, stdin)[0].strip() == _norm(expected) for stdin, expected in cases):
                raise ContentError(f'{where} v{n + 1} {lang}: the starter already passes every test')


def _sql_rows(db, statements, check):
    import sqlite3
    con = sqlite3.connect(':memory:')
    try:
        con.executescript(db)
        cur = con.cursor()
        last = None
        for st in [x for x in _split_sql(statements) if x.strip()]:
            cur.execute(st)
            if cur.description:
                last = [list(r) for r in cur.fetchall()]
        con.commit()
        if check:
            cur.execute(check)
            last = [list(r) for r in cur.fetchall()]
        return last
    finally:
        con.close()


def _split_sql(s):
    return [x for x in s.split(';')]


def _cell(v):
    if isinstance(v, (int, float)) and not isinstance(v, bool):
        return str(int(v)) if float(v) == round(float(v)) else f'{float(v):.4f}'
    return 'NULL' if v is None else str(v)


def validate_sql(c, where, db):
    if len(c.variants) != 3:
        raise ContentError(f'{where}: three variants needed')
    if not db:
        raise ContentError(f'{where}: lab has no database')
    for n, v in enumerate(c.variants):
        rows = _sql_rows(db, v['ref'], v['check'])
        if rows is None:
            raise ContentError(f'{where} v{n + 1}: reference returns no rows')
        if not rows:
            raise ContentError(f'{where} v{n + 1}: reference returns an empty result (too weak a test)')
        v['expected'] = rows
        if v['starter']:
            try:
                srows = _sql_rows(db, v['starter'], v['check'])
            except Exception:
                srows = None
            key = (lambda r: sorted('|'.join(_cell(x) for x in row) for row in r))
            if srows is not None and key(srows) == key(rows):
                raise ContentError(f'{where} v{n + 1}: the starter already gives the right answer')


def words(t):
    return len(re.findall(r"[A-Za-z0-9'’]+", t))


def validate_case(c, where):
    fids = {f.id for f in c.fields}
    for f in c.fields:
        if len(f.options) < 2:
            raise ContentError(f'{where}: field {f.id} needs 2+ options')
    if len(c.items) < 3:
        raise ContentError(f'{where}: queue needs 3+ items')
    for it in c.items:
        for k, ans in it.answers.items():
            if k not in fids:
                raise ContentError(f'{where}/{it.id}: unknown field {k}')
            f = next(f for f in c.fields if f.id == k)
            parts = ans.split('|')
            for a in parts:
                if a not in f.options:
                    raise ContentError(f'{where}/{it.id}: answer "{a}" not an option of {k}')
            if all(o in parts for o in f.options):
                raise ContentError(f'{where}/{it.id}: every option is correct for {k}')
        if not it.answers:
            raise ContentError(f'{where}/{it.id}: no decisions')
    vals = [o.value for o in c.options]
    if 'essential' not in vals or not any(v in ('neutral', 'poor', 'unsafe') for v in vals):
        raise ContentError(f'{where}: conversation needs essential and neutral/poor/unsafe options')
    if len({o.id for o in c.options}) != len(c.options):
        raise ContentError(f'{where}: duplicate option ids')
    if c.procedure and len(c.procedure) < 4:
        raise ContentError(f'{where}: procedure needs 4+ steps')
    for a, b in c.must:
        if not (0 <= a < b < len(c.procedure)):
            raise ContentError(f'{where}: bad mustPrecede {(a, b)}')
    alltext = '\n'.join(s.model for s in c.sections)
    for s in c.sections:
        if words(s.model) < s.min_words:
            raise ContentError(f'{where}/{s.id}: model has {words(s.model)} words < {s.min_words}')
        for r in s.rubric:
            if not any(re.search(p, s.model, re.I) for p in r.patterns):
                raise ContentError(f'{where}/{s.id}: model misses rubric "{r.label}"')
            if any(re.search(p, 'Not sure.', re.I) for p in r.patterns):
                raise ContentError(f'{where}/{s.id}: rubric "{r.label}" matches an empty answer')
    for r in c.forbidden:
        if any(re.search(p, alltext, re.I) for p in r.patterns):
            raise ContentError(f'{where}: model document contains forbidden "{r.label}"')
    if c.sections and not c.doc_type:
        raise ContentError(f'{where}: doc_type needed')


# ------------------------------------------------------------ Dart emission

def ds(s):
    return "'" + str(s).replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$').replace('\n', '\\n') + "'"


def dn(v):
    v = float(v)
    if v == int(v) and abs(v) < 1e15:
        return f'{int(v)}'
    return repr(v)


def dlist(items, typ, const=True):
    return f"{'const ' if const else ''}<{typ}>[{', '.join(items)}]"


def e_choice(q, prefix=''):
    return f"pick({ds(prefix + q.id)}, {ds(q.prompt)}, {ds(q.correct)}, {dlist([ds(w) for w in q.wrong], 'String')}, explain: {ds(q.explain)})"


def e_question(q, prefix=''):
    if isinstance(q, Choice):
        return e_choice(q, prefix)
    return (f"NumberQuestion({ds(prefix + q.id)}, {ds(q.prompt)}, {dn(q.answer)}, tolerance: {dn(q.tol)}, relative: {'true' if q.relative else 'false'}, "
            f"unit: {ds(q.unit)}, explain: {ds(q.explain)})")


def e_design(p):
    ins = [f"SimInput({ds(i.name)}, {ds(i.label)}, {dn(i.lo)}, {dn(i.hi)}, step: {dn(i.step)}, initial: {dn(i.init)}, unit: {ds(i.unit)})" for i in p.inputs]
    outs = [f"SimOutput({ds(o.name)}, {ds(o.label)}, {ds(o.formula)}, unit: {ds(o.unit)}, decimals: {o.dec})" for o in p.outputs]
    lv = []
    for cs in p.levels:
        lv.append('<SimConstraint>[' + ', '.join(f"SimConstraint({ds(c.out)}, {ds(c.op)}, {dn(c.value)}, {ds(c.label)})" for c in cs) + ']')
    model = '{' + ', '.join(f"{ds(k)}: {dn(v)}" for k, v in p.model.items()) + '}'
    given = '{' + ', '.join(f"{ds(k)}: {dn(v)}" for k, v in p.given.items()) + '}'
    return f"""    DesignProblem(
      key: {ds(p.key)},
      title: {ds(p.title)},
      brief: {ds(p.brief)},
      inputs: {dlist(ins, 'SimInput')},
      outputs: {dlist(outs, 'SimOutput')},
      given: const <String, double>{given},
      ask: {dlist([ds(a) for a in p.ask], 'String')},
      formulas: {dlist([ds(f) for f in p.formulas], 'String')},
      levels: cum({lv[0]}, {lv[1]}, {lv[2]}),
      models: same(const <String, double>{model}),{f'''
      interpret: {e_choice(p.interpret)},''' if p.interpret else ''}
    )"""


def e_invest(v):
    ev = ', '.join(f"({ds(t)}, {'true' if b else 'false'})" for t, b in v.evidence)
    calc = f"\n      calc: ({ds(v.calc[0])}, {dn(v.calc[1])}, {ds(v.calc[2])}, {ds(v.calc[3])})," if v.calc else ''
    steps = f"\n      steps: {dlist([ds(s) for s in v.steps], 'String')}," if v.steps else ''
    must = f"\n      mustPrecede: const <(int, int)>[{', '.join(f'({a}, {b})' for a, b in v.must)}]," if v.must else ''
    return f"""    Investigation(
      key: {ds(v.key)},
      title: {ds(v.title)},
      brief: {ds(v.brief)},
      evidence: const <(String, bool)>[{ev}],
      cause: {ds(v.cause)},
      wrongCauses: {dlist([ds(w) for w in v.wrong_causes], 'String')},
      fix: {ds(v.fix)},
      wrongFixes: {dlist([ds(w) for w in v.wrong_fixes], 'String')},{calc}{steps}{must}
    )"""


def e_case(c):
    fields = [f"TriageField({ds(f.id)}, {ds(f.label)}, {dlist([ds(o) for o in f.options], 'String')})" for f in c.fields]
    items = []
    for it in c.items:
        meta = '{' + ', '.join(f"{ds(k)}: {ds(v)}" for k, v in it.meta.items()) + '}'
        ans = '{' + ', '.join(f"{ds(k)}: {ds(v)}" for k, v in it.answers.items()) + '}'
        items.append(f"TriageItem(id: {ds(it.id)}, title: {ds(it.title)}, body: {ds(it.body)}, meta: const <String, String>{meta}, "
                     f"answers: const <String, String>{ans}, why: {ds(it.why)}, critical: {'true' if it.critical else 'false'})")
    opts = [f"DialogueOption({ds(o.id)}, {ds(o.say)}, {ds(o.reply)}, value: DialogueValue.{o.value}, note: {ds(o.note)})" for o in c.options]
    concl = [e_question(q, c.key + '_') for q in c.conclusions]
    secs = []
    for s in c.sections:
        rub = [f"RubricItem({ds(r.label)}, {dlist([ds(p) for p in r.patterns], 'String')}, weight: {r.weight}, advice: {ds(r.advice)})" for r in s.rubric]
        secs.append(f"DocSection({ds(s.id)}, {ds(s.heading)}, guidance: {ds(s.guidance)}, minWords: {s.min_words}, rubric: {dlist(rub, 'RubricItem')})")
    model = '{' + ', '.join(f"{ds(s.id)}: {ds(s.model)}" for s in c.sections) + '}'
    forb = [f"RubricItem({ds(r.label)}, {dlist([ds(p) for p in r.patterns], 'String')}, advice: {ds(r.advice)})" for r in c.forbidden]
    return f"""    CaseFile(
      key: {ds(c.key)},
      title: {ds(c.title)},
      brief: {ds(c.brief)},
      queueName: {ds(c.queue)},
      fields: {dlist(fields, 'TriageField')},
      items: {dlist(items, 'TriageItem')},
      person: {ds(c.person)},
      opening: {ds(c.opening)},
      options: {dlist(opts, 'DialogueOption')},
      conclusions: {dlist(concl, 'MathQuestion', const=False)},
      procedure: {dlist([ds(p) for p in c.procedure], 'String')},
      mustPrecede: const <(int, int)>[{', '.join(f'({a}, {b})' for a, b in c.must)}],
      docType: {ds(c.doc_type)},
      sections: {dlist(secs, 'DocSection')},
      model: const <String, String>{model},
      forbidden: {dlist(forb, 'RubricItem')},
      sources: {dlist([ds(s) for s in c.sources], 'String')},
    )"""


def camel(s):
    parts = re.split(r'[_\W]+', s)
    return parts[0] + ''.join(p.title() for p in parts[1:])


def emit_major(m, fname):
    lines = [f'// GENERATED by tool/labgen/build.py from tool/labgen/majors/{fname}.py. Do not edit by hand.',
             f'// {m.name}.', '', '// ignore_for_file: prefer_const_constructors, lines_longer_than_80_chars', '',
             "import '../lab_models.dart';", "import '../math/math_steps.dart';", "import '../work/work_steps.dart';",
             "import 'case_kit.dart';", "import 'design_kit.dart';", '',
             f"const LabPerson _lead = LabPerson({ds(m.person[0])}, {ds(m.person[1])}, {ds(m.person[2])});", '']
    names = []
    for lab in m.labs:
        var = camel(lab.id) + 'Spec'
        parts = []
        if lab.problems:
            parts.append(f"...fromProblems({ds(lab.prefix + 'p')}, <DesignProblem>[\n" + ',\n'.join(e_design(p) for p in lab.problems) + ",\n  ], person: _lead)")
        if lab.investigations:
            parts.append(f"...fromInvestigations({ds(lab.prefix + 'v')}, <Investigation>[\n" + ',\n'.join(e_invest(v) for v in lab.investigations) + ",\n  ], person: _lead)")
        if lab.code:
            items = []
            for c in lab.code:
                vs = []
                for instr, cases, py, js, spy, sjs in c.variants:
                    pcs = ', '.join(f"ProgramCase({ds(i)}, {ds(o)})" for i, o in cases)
                    extra = (f", starterPy: {ds(spy)}" if spy else '') + (f", starterJs: {ds(sjs)}" if sjs else '')
                    vs.append(f"CodeVariant({ds(instr)}, <ProgramCase>[{pcs}]{extra})")
                items.append(f"    CodeProblem(key: {ds(c.key)}, title: {ds(c.title)}, brief: {ds(c.brief)}, skills: {dlist([ds(k) for k in c.skills], 'String')}, variants: <CodeVariant>[\n      " + ',\n      '.join(vs) + ",\n    ])")
            parts.append(f"...fromCode({ds(lab.prefix + 'k')}, <CodeProblem>[\n" + ',\n'.join(items) + ",\n  ], person: _lead)")
        if lab.sql:
            items = []
            for c in lab.sql:
                vs = []
                for v in c.variants:
                    rows = ', '.join('<Object?>[' + ', '.join(dn(x) if isinstance(x, (int, float)) else ('null' if x is None else ds(str(x))) for x in r) + ']' for r in v['expected'])
                    extra = (f", check: {ds(v['check'])}" if v['check'] else '') + (', ordered: true' if v['ordered'] else '') + (f", starter: {ds(v['starter'])}" if v['starter'] else '')
                    vs.append(f"SqlVariant({ds(v['instructions'])}, <List<Object?>>[{rows}]{extra})")
                items.append(f"    SqlProblem(key: {ds(c.key)}, title: {ds(c.title)}, brief: {ds(c.brief)}, skills: {dlist([ds(k) for k in c.skills], 'String')}, variants: <SqlVariant>[\n      " + ',\n      '.join(vs) + ",\n    ])")
            parts.append(f"...fromSql({ds(lab.prefix + 'q')}, <SqlProblem>[\n" + ',\n'.join(items) + ",\n  ], person: _lead)")
        if lab.cases:
            tools = f", tools: {dlist([ds(t) for t in lab.tools], 'String')}" if lab.tools else ''
            parts.append(f"...fromCases({ds(lab.prefix + 'c')}, <CaseFile>[\n" + ',\n'.join(e_case(c) for c in lab.cases) + f",\n  ], person: _lead{tools})")
        if lab.extends:
            lines.append(f"/// Extra scenarios for the hand-built lab {lab.id}.")
            lines.append(f"final List<LabScenario> {camel(lab.id)}Extra = byLevel(<LabScenario>[\n  " + ',\n  '.join(parts) + ",\n]);\n")
            continue
        names.append(var)
        lines.append(f"""final LabSpec {var} = designLab(
  id: {ds(lab.id)},
  deptId: {ds(m.dept)},
  majorId: {ds(m.major)},
  number: {lab.number},
  title: {ds(lab.title)},
  environment: LabEnvironment.{lab.env},
  summary: {ds(lab.summary)},
  objectives: {dlist([ds(o) for o in lab.objectives], 'String')},
  skills: {dlist([ds(s) for s in lab.skills], 'String')},
  reference: {dlist([ds(r) for r in lab.reference], 'String')},
  minutes: {lab.minutes},
  difficulty: LabDifficulty.{ {'beginner': 'foundation', 'intermediate': 'intermediate', 'advanced': 'advanced'}[lab.difficulty] },
  portfolio: {'true' if lab.portfolio else 'false'},
  scenarios: byLevel(<LabScenario>[
  {(',\n  ').join(parts)},
  ]),
);
""")
    list_name = camel(fname) + 'GenLabs'
    lines.append(f"final List<LabSpec> {list_name} = <LabSpec>[{', '.join(names)}];")
    lines.append('')
    return '\n'.join(lines), list_name


DEPT_SKILLS = {}


def _load_dept_skills():
    """Skill ids each department defines (labs may only train their own department's skills)."""
    if DEPT_SKILLS:
        return DEPT_SKILLS
    folder = os.path.join(ROOT, 'lib/career_sim/content')
    for f in os.listdir(folder):
        src = open(os.path.join(folder, f)).read()
        for m in re.finditer(r"Department\(\s*id: '([a-z_]+)'(.*?)\n\);", src, re.S):
            body = m.group(2)
            ids = set(re.findall(r"SkillDef\('([a-z_]+)'", body))
            ref = re.search(r"skills: (_[a-zA-Z]+)", body)
            if ref:
                lst = re.search(ref.group(1) + r" = <SkillDef>\[(.*?)\];", src, re.S)
                if lst:
                    ids |= set(re.findall(r"SkillDef\('([a-z_]+)'", lst.group(1)))
            DEPT_SKILLS[m.group(1)] = ids
    return DEPT_SKILLS


ERRORS = []


def build(majors):
    """majors: list of (module name, Major). Returns built index."""
    built = {}
    registry = []
    for fname, m in majors:
        allowed = _load_dept_skills().get(m.dept)
        if not allowed:
            raise ContentError(f'{m.major}: department {m.dept} not found or has no skills')
        for lab in m.labs:
            where = f'{m.major}/{lab.id}'
            bad = [k for k in lab.skills if k not in allowed]
            if bad:
                raise ContentError(f'{where}: skills {bad} are not defined by department {m.dept} ({sorted(allowed)})')
            n = 0
            for fn, items in ((validate_design, lab.problems), (validate_investigation, lab.investigations), (validate_case, lab.cases), (validate_code, lab.code),
                              (lambda x, w: validate_sql(x, w, lab.database), lab.sql)):
                for x in items:
                    try:
                        fn(x, f'{where}/{x.key}')
                    except ContentError as e:
                        ERRORS.append(str(e))
                    n += 3
            if n != 15:
                raise ContentError(f'{where}: {n} scenarios (need 15 = five problems, investigations or cases)')
            keys = [x.key for x in lab.problems + lab.investigations + lab.cases + lab.code + lab.sql]
            if len(set(keys)) != len(keys):
                raise ContentError(f'{where}: duplicate keys')
            if lab.id not in m.blueprint_titles:
                raise ContentError(f'{where}: missing blueprint title')
            built[lab.id] = {'major': m.major, 'title': m.blueprint_titles[lab.id], 'scenarios': n, 'note': lab.summary[:90], 'extends': lab.extends}
        if ERRORS:
            continue
        dart, list_name = emit_major(m, fname)
        out = os.path.join(ROOT, f'lib/career_sim/labs/content/gen_{fname}.dart')
        with open(out, 'w') as f:
            f.write(dart)
        registry.append((fname, list_name, m.major, m.name))
    if ERRORS:
        raise ContentError('\n'.join(ERRORS))
    reg = ['// GENERATED by tool/labgen/build.py. Do not edit by hand.', '']
    reg += [f"import 'gen_{f}.dart';" for f, _, _, _ in registry]
    reg += ["import '../lab_models.dart';", '', '/// Labs generated from tool/labgen/majors.', 'final List<LabSpec> generatedLabs = <LabSpec>[']
    reg += [f'  ...{ln},' for _, ln, _, _ in registry]
    reg += ['];', '', 'const Map<String, String> generatedMajorLabels = <String, String>{']
    seen_majors = set()
    for _, _, mj, nm in registry:
        if mj not in seen_majors:
            seen_majors.add(mj)
            reg.append(f"  {ds(mj)}: {ds(nm.split(' at ')[0])},")
    reg += ['};', '']
    with open(os.path.join(ROOT, 'lib/career_sim/labs/content/gen_registry.dart'), 'w') as f:
        f.write('\n'.join(reg))
    with open(os.path.join(ROOT, 'tool/labgen/built.json'), 'w') as f:
        json.dump(built, f, indent=1, sort_keys=True)
    # Reference programs for functions/test/lab_keys.test.js, which re-runs every
    # program step's cases in the app's own Pyodide runtime.
    fx = os.path.join(ROOT, 'functions/test/fixtures/career_lab_refs.json')
    with open(fx) as f:
        refs = json.load(f)
    gen_ids = set(refs.pop('_generated', []))
    progs = {k: v for k, v in refs['programs'].items() if k not in gen_ids}
    sqls = {k: v for k, v in refs['sql'].items() if k not in gen_ids}
    new_ids = []
    for _, m in majors:
        for lab in m.labs:
            for c in lab.sql:
                for n, v in enumerate(c.variants):
                    sid = f'{lab.prefix}q_{c.key}_{n + 1}_sql'
                    if sid in sqls:
                        raise ContentError(f'{lab.id}: SQL step id {sid} is used twice (change the lab prefix)')
                    sqls[sid] = v['ref']
                    new_ids.append(sid)
    refs['sql'] = sqls
    for _, m in majors:
        for lab in m.labs:
            for c in lab.code:
                for n, v in enumerate(c.variants):
                    pid = f'{lab.prefix}k_{c.key}_{n + 1}_code'
                    if pid in progs:
                        raise ContentError(f'{lab.id}: program step id {pid} is used twice (change the lab prefix)')
                    progs[pid] = v[2]
                    new_ids.append(pid)
    refs['programs'] = progs
    refs['_generated'] = sorted(new_ids)
    with open(fx, 'w') as f:
        json.dump(refs, f, indent=1, sort_keys=True)
        f.write('\n')
    return built


# ------------------------------------------------------------ compact case helper

_KIND = {'E': 'essential', 'U': 'useful', 'N': 'neutral', 'P': 'poor', 'X': 'unsafe'}


def case(key, title, brief, queue, fields, items, person, opening, talk, conclusions=(), procedure=(), must=(), doc=None, sources=()):
    """fields: [(id, label, [options])]; items: [(title, body, {field: answer}, why[, critical])];
    talk: [(kind E/U/N/P/X, say, reply[, note])]; doc: (doc_type, [(heading, [(label, [regex…])…], model)], forbidden [(label, [regex…])])."""
    fs = [F(f[0], f[1], f[2]) for f in fields]
    its = []
    for n, it in enumerate(items):
        its.append(Item(f'i{n + 1}', it[0], it[1], it[2], why=it[3] if len(it) > 3 else '', critical=it[4] if len(it) > 4 else False))
    opts = [Opt(f'o{n + 1}', t[1], t[2], _KIND[t[0]], t[3] if len(t) > 3 else '') for n, t in enumerate(talk)]
    secs, forb, dtype = [], [], ''
    if doc:
        dtype = doc[0]
        for n, (heading, rubric, model) in enumerate(doc[1]):
            secs.append(Sec(f's{n + 1}', heading, [R(lbl, pats) for lbl, pats in rubric], model))
        forb = [R(lbl, pats) for lbl, pats in (doc[2] if len(doc) > 2 else [])]
    return Case(key, title, brief, queue, fs, its, person, opening, opts, conclusions, procedure, must, dtype, secs, forb, sources)
