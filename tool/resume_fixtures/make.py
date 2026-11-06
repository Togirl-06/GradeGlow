"""Builds the test resumes in test/fixtures/resumes (fictional people).

Each resume is produced by a different real tool so the extractor is tested on
the kinds of files students upload: Word-style DOCX (python-docx), a PDF
exported by LibreOffice (subset TrueType fonts + ToUnicode), a PDF printed by
Chromium (Skia, CID fonts) and a PDF from ReportLab (standard Type 1 fonts).
"""
import os, subprocess, sys, json, tempfile
from docx import Document
from docx.shared import Pt

OUT = os.path.join(os.path.dirname(__file__), '..', '..', 'test', 'fixtures', 'resumes')

RESUMES = {
  'cs': {
    'name': 'Jordan Rivera', 'email': 'jordan.rivera@example.com', 'phone': '(555) 201-7788',
    'headline': 'Computer Science student — mobile and backend development',
    'sections': [
      ('Summary', ['Computer Science student who builds Flutter apps with Firebase backends. Shipped two apps used by 1,200 students and enjoys debugging hard production issues.']),
      ('Education', ['B.S. Computer Science, Lakeview State University, 2022 – 2026', 'GPA 3.6/4.0. Coursework: Data Structures, Algorithms, Databases, Operating Systems']),
      ('Experience', ['Software Developer Intern, Brightpath Apps, June 2025 – August 2025', '• Built 4 Flutter screens connected to a REST API and reduced crash rate by 30%', '• Wrote widget and unit tests for the authentication flow', 'IT Help Desk Assistant, Lakeview State University, 2023 – 2025', '• Resolved 40+ tickets a week for students and staff']),
      ('Projects', ['Campus Eats — Flutter and Firebase food-ordering app with 1,200 users', 'Study Timer — Dart command-line tool with 95% test coverage']),
      ('Skills', ['Python, Dart, Flutter, Firebase, SQL, Git, REST APIs, JavaScript, Unit testing']),
      ('Certifications', ['Google Associate Android Developer (2025)']),
      ('Achievements', ['Dean\'s List 2023 and 2024', 'Second place, Lakeview Hackathon 2024']),
    ]},
  'nursing': {
    'name': 'Amara Okafor', 'email': 'amara.okafor@example.org', 'phone': '555-310-4421',
    'headline': 'Nursing student — acute care placements',
    'sections': [
      ('Profile', ['Final-year nursing student with 600 supervised clinical placement hours on medical and surgical wards. Calm under pressure and careful with documentation.']),
      ('Education', ['Bachelor of Science in Nursing (BSN), Riverside College of Nursing, 2022 – 2026']),
      ('Clinical Experience', ['Student Nurse, Medical-Surgical Unit, Riverside General Hospital, Jan 2025 – May 2025', '• Recorded vital signs and early warning scores for 6 patients per shift', '• Assisted with wound care, fall-risk assessments and patient education', 'Nursing Assistant, Maple Grove Care Home, 2023 – 2024']),
      ('Skills', ['Vital signs, Patient assessment, Wound care, Infection control, Medication safety, Documentation, Patient education, Teamwork']),
      ('Certifications', ['Basic Life Support (BLS), American Heart Association, 2025']),
      ('Awards', ['Clinical Excellence Award, Riverside College 2025']),
    ]},
  'business': {
    'name': 'Daniel Chen', 'email': 'daniel.chen@example.net', 'phone': '+1 555 482 9001',
    'headline': 'Accounting and finance graduate',
    'sections': [
      ('Objective', ['Accounting graduate seeking a junior accountant role. Experienced with reconciliations, Excel models and month-end close support.']),
      ('Education', ['Bachelor of Business Administration, Accounting, Northfield University, 2021 – 2025']),
      ('Work Experience', ['Accounts Payable Clerk, Harbor Logistics, 2024 – 2025', '- Processed 300 invoices a month and reconciled vendor statements', '- Found $12,000 of duplicate payments during reconciliation']),
      ('Technical Skills', ['Excel, QuickBooks, Financial statements, Reconciliation, Budgeting, Accounts payable, SQL']),
      ('Projects', ['Small-business budget model — three-statement Excel model for a local bakery']),
    ]},
  'law': {
    'name': 'Sofia Martinez', 'email': 'sofia.martinez@example.com', 'phone': '(555) 640-2210',
    'headline': 'Law student — litigation and legal research',
    'sections': [
      ('Summary', ['Second-year law student with strong legal research and legal writing skills from moot court and a summer clerkship.']),
      ('Education', ['Juris Doctor (JD) candidate, Eastbrook University School of Law, 2024 – 2027', 'B.A. Political Science, Eastbrook University, 2020 – 2024']),
      ('Legal Experience', ['Summer Law Clerk, Grant & Hale LLP, June 2025 – August 2025', '• Researched case law on Westlaw and drafted 6 research memos for associates', '• Prepared a case chronology and evidence index for a contract dispute']),
      ('Skills', ['Legal research, Legal writing, Case analysis, Citation, Westlaw, Drafting, Client communication']),
      ('Achievements', ['Moot Court semi-finalist 2025']),
    ]},
  'engineering': {
    'name': 'Ethan Brooks', 'email': 'ethan.brooks@example.org', 'phone': '555-702-3381',
    'headline': 'Mechanical engineering graduate — design and analysis',
    'sections': [
      ('Summary', ['Mechanical engineering graduate who designs machine components with CAD and checks them with hand calculations and test data.']),
      ('Education', ['B.S. Mechanical Engineering, Ridgeway Institute of Technology, 2021 – 2025']),
      ('Experience', ['Engineering Intern, Delta Motion Systems, May 2024 – August 2024', '• Designed a gearbox mounting bracket in SolidWorks and cut its mass by 18%', '• Wrote a technical report on a shaft fatigue failure and recommended a larger fillet']),
      ('Projects', ['Formula SAE suspension — machine design, stress calculations and CAD drawings']),
      ('Skills', ['CAD, SolidWorks, Mechanics, Machine design, MATLAB, Technical report, Failure analysis']),
    ]},
  'medicine': {
    'name': 'Priya Shah', 'email': 'priya.shah@example.net', 'phone': '555-118-4407',
    'headline': 'Final-year medical student',
    'sections': [
      ('Summary', ['Final-year medical student with clinical rotations in internal medicine and emergency medicine.']),
      ('Education', ['Doctor of Medicine (MD) candidate, Northgate School of Medicine, 2022 – 2026', 'B.S. Biomedical Science, Northgate University, 2018 – 2022']),
      ('Clinical Experience', ['Medical Student, Internal Medicine rotation, Northgate General Hospital, 2025', '• Took histories and examined 4 patients a day, presented cases to the attending', '• Interpreted ECG and blood results under supervision']),
      ('Research', ['Audit of sepsis screening times in the emergency department (poster, 2025)']),
      ('Skills', ['History taking, Clinical reasoning, Patient assessment, Communication, ECG interpretation, Research']),
      ('Certifications', ['Basic Life Support (BLS), 2025']),
    ]},
  'science': {
    'name': 'Grace Kim', 'email': 'grace.kim@example.com', 'phone': '555-233-9012',
    'headline': 'Biology graduate — cell and molecular biology',
    'sections': [
      ('Summary', ['Biology graduate with two years of undergraduate research using microscopy and cell culture.']),
      ('Education', ['B.S. Biology, Lakeshore University, 2021 – 2025']),
      ('Research Experience', ['Undergraduate Research Assistant, Lakeshore Cell Biology Lab, 2023 – 2025', '• Prepared samples and ran 40+ microscopy experiments', '• Analyzed data in Excel and wrote lab reports following safety procedures']),
      ('Skills', ['Laboratory, Microscopy, Cell culture, Data analysis, Safety, PCR']),
    ]},
  'maths': {
    'name': 'Noah Williams', 'email': 'noah.williams@example.org', 'phone': '555-889-1200',
    'headline': 'Mathematics graduate — modelling and statistics',
    'sections': [
      ('Summary', ['Mathematics graduate who builds models in Python and checks them statistically.']),
      ('Education', ['B.S. Mathematics, Hillcrest University, 2021 – 2025']),
      ('Experience', ['Math Tutor, Hillcrest Learning Center, 2022 – 2025', '• Tutored 15 students a week in calculus and linear algebra']),
      ('Projects', ['Epidemic modelling — differential equations solved in Python with 3 scenarios']),
      ('Skills', ['Mathematics, Statistics, Python, Modelling, Linear algebra, Differential equations, LaTeX']),
    ]},
  'communication': {
    'name': 'Olivia Turner', 'email': 'olivia.turner@example.com', 'phone': '555-402-7765',
    'headline': 'English graduate — writing and editing',
    'sections': [
      ('Summary', ['English graduate who writes and edits clear, accurate content for web and print.']),
      ('Education', ['B.A. English, Westfield College, 2021 – 2025']),
      ('Experience', ['Staff Writer, The Westfield Ledger (student newspaper), 2022 – 2025', '• Wrote 60+ articles, researched and fact-checked every story', '• Edited copy to AP style and improved SEO traffic by 25%']),
      ('Skills', ['Writing, Editing, Research, SEO, Proofreading, Social media']),
    ]},
}

def write_docx(r, path):
  d = Document()
  d.add_heading(r['name'], 0)
  d.add_paragraph(f"{r['email']} | {r['phone']}")
  d.add_paragraph(r['headline'])
  for h, lines in r['sections']:
    d.add_heading(h, level=1)
    for l in lines:
      p = d.add_paragraph(l.lstrip('•- ').strip(), style='List Bullet' if l[:1] in '•-' else None)
  d.save(path)

def html(r):
  body = ''.join(f"<h2>{h}</h2>" + ''.join(f"<p>{l}</p>" for l in lines) for h, lines in r['sections'])
  return f"""<html><body style="font-family: Arial, sans-serif; font-size: 11pt; margin: 40px">
<h1>{r['name']}</h1><p>{r['email']} | {r['phone']}</p><p>{r['headline']}</p>{body}</body></html>"""

def reportlab_pdf(r, path):
  from reportlab.lib.pagesizes import letter
  from reportlab.pdfgen import canvas
  c = canvas.Canvas(path, pagesize=letter)
  y = 740
  def line(t, font='Helvetica', size=10):
    nonlocal y
    c.setFont(font, size); c.drawString(60, y, t); y -= size + 6
  line(r['name'], 'Helvetica-Bold', 16); line(f"{r['email']} | {r['phone']}"); line(r['headline'])
  for h, lines in r['sections']:
    y -= 6; line(h.upper(), 'Helvetica-Bold', 11)
    for l in lines: line(l.replace('•', '-'))
  c.save()

def main():
  os.makedirs(OUT, exist_ok=True)
  expected = {}
  for key, r in RESUMES.items():
    expected[key] = {'name': r['name'], 'email': r['email'], 'phone': r['phone'], 'sections': [h for h, _ in r['sections']]}
  # cs: DOCX and LibreOffice PDF of the same file
  cs_docx = os.path.join(OUT, 'jordan_rivera_cs.docx')
  write_docx(RESUMES['cs'], cs_docx)
  with tempfile.TemporaryDirectory() as t:
    subprocess.run(['soffice', '--headless', '--convert-to', 'pdf', '--outdir', t, cs_docx], check=True, capture_output=True)
    os.replace(os.path.join(t, 'jordan_rivera_cs.pdf'), os.path.join(OUT, 'jordan_rivera_cs_libreoffice.pdf'))
  write_docx(RESUMES['nursing'], os.path.join(OUT, 'amara_okafor_nursing.docx'))
  # nursing: Chromium-printed PDF
  hp = os.path.join(OUT, '_nursing.html')
  open(hp, 'w').write(html(RESUMES['nursing']))
  js = f"""const {{chromium}} = require('playwright');(async()=>{{const b=await chromium.launch();const p=await b.newPage();await p.goto('file://{os.path.abspath(hp)}');await p.pdf({{path:'{os.path.abspath(os.path.join(OUT,'amara_okafor_nursing_chrome.pdf'))}',format:'Letter'}});await b.close();}})();"""
  subprocess.run(['node', '-e', js], check=True)
  os.remove(hp)
  reportlab_pdf(RESUMES['business'], os.path.join(OUT, 'daniel_chen_business_reportlab.pdf'))
  write_docx(RESUMES['business'], os.path.join(OUT, 'daniel_chen_business.docx'))
  for key, fname in [('law','sofia_martinez_law'),('engineering','ethan_brooks_engineering'),('medicine','priya_shah_medicine'),('science','grace_kim_biology'),('maths','noah_williams_maths'),('communication','olivia_turner_english')]:
    d = os.path.join(OUT, fname + '.docx'); write_docx(RESUMES[key], d)
    if key in ('law', 'engineering'):
      with tempfile.TemporaryDirectory() as t:
        subprocess.run(['soffice', '--headless', '--convert-to', 'pdf', '--outdir', t, d], check=True, capture_output=True)
        os.replace(os.path.join(t, fname + '.pdf'), os.path.join(OUT, fname + '.pdf'))
  json.dump(expected, open(os.path.join(OUT, 'expected.json'), 'w'), indent=1)
  print(sorted(os.listdir(OUT)))

main()
