#!/usr/bin/env python3
"""GradeGlow lab development tracker.

Source of truth for every major and every laboratory in the Virtual University
blueprint and the honest implementation status of each. Run:

    python3 tool/lab_tracker.py

It writes docs/career_sim/LAB_TRACKER.md and lib/career_sim/labs/lab_blueprint.g.dart
(the app shows planned labs and their status from it). test/career_sim/lab_blueprint_test.dart
checks that the built lab ids and scenario counts recorded here match the app.

Statuses (from the blueprint):
  not_started, interface, in_progress, functional, tested, verified
A lab is "tested" only when its tools, grading and saving work and are covered
by automated tests AND it has 15 scenarios (5 per level) or a set of project briefs.
"verified" additionally needs a manual run of the student journey.
"""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

STATUS = {
    "not_started": "Not started",
    "interface": "Interface completed",
    "in_progress": "Functionality in progress",
    "functional": "Functionality completed",
    "tested": "Tested",
    "verified": "Verified complete",
}

# Built labs: blueprint lab -> (app lab id, status, note). Scenario counts are
# checked against the app by a test.
BUILT = {}


def built(lab_id, status, note=""):
    return {"labId": lab_id, "status": status, "note": note}


SCHOOLS = [
    ("School of Computer Science and Technology", [
        ("computer_science", "Computer Science", [
            ("Programming Laboratory", built("cs_lab_fundamentals", "in_progress", "Real Python/JavaScript execution and tests; 1 scenario of 15")),
            ("Data Structures and Algorithms", built("cs_lab_dsa", "in_progress", "Trace and challenge modes; 1 scenario of 15")),
            ("Database Engineering", built("cs_lab_database", "in_progress", "Real SQLite workbench; 1 scenario of 15")),
            ("Computer Architecture and Operating Systems", built("cs_lab_os", "in_progress", "FCFS/SJF and paging simulators; no Priority/Round Robin or CPU model yet")),
            ("Software Project Laboratory", built("cs_lab_project", "in_progress", "1 project brief")),
        ]),
        ("software_engineering", "Software Engineering", [
            ("Requirements Engineering", None), ("System Design and Architecture", None), ("Software Development", None),
            ("Git and Collaboration", None), ("Software Testing and Quality Assurance", None), ("Software Maintenance", None),
        ]),
        ("artificial_intelligence", "Artificial Intelligence", [
            ("Machine Learning", None), ("Neural Networks", None), ("Natural Language Processing", None),
            ("Generative AI Development", None), ("AI Ethics and Model Evaluation", None),
        ]),
        ("data_science", "Data Science", [
            ("Data Cleaning", None), ("Data Analysis", None), ("Data Visualization", None),
            ("Statistical Modelling", None), ("Predictive Modelling", None), ("Data Science Capstone", None),
        ]),
        ("cybersecurity", "Cybersecurity", [
            ("Networking Fundamentals", None), ("Security Monitoring", None), ("Vulnerability Assessment", None),
            ("Digital Forensics", None), ("Incident Response", None), ("Security Awareness", None),
        ]),
        ("information_technology", "Information Technology", [
            ("IT Help Desk", None), ("Hardware Support", None), ("Network Administration", None),
            ("Systems Administration", None), ("IT Service Management", None),
        ]),
        ("web_development", "Web Development", [
            ("HTML and CSS Studio", None), ("JavaScript Development", None), ("Frontend Application Development", None),
            ("Backend Development", None), ("Accessibility and Responsive Testing", None), ("Client Project", None),
        ]),
        ("mobile_app_development", "Mobile Application Development", [
            ("Mobile UI Design", None), ("Flutter Development", None), ("Backend Integration", None),
            ("Mobile App Testing", None), ("App Deployment", None), ("Full App Project", None),
        ]),
    ]),
    ("School of Medicine and Health Sciences", [
        ("medicine", "Medicine", [
            ("Human Anatomy and Physiology", built("md_lab_anatomy", "in_progress", "2D diagrams, not the required 3D body")),
            ("Medical History and Patient Interview", built("md_lab_assessment", "in_progress", "1 patient case")),
            ("Physical Examination", None), ("Diagnostic Investigation", None), ("Clinical Reasoning and Diagnosis", None),
            ("Emergency Medicine", built("md_lab_emergency", "in_progress", "1 case (anaphylaxis)")),
            ("Medical Research and Evidence", None),
        ]),
        ("nursing", "Nursing", [
            ("Patient Admission", built("nu_lab_admission", "in_progress", "1 patient")),
            ("Vital Signs and Patient Monitoring", built("nu_lab_vitals", "in_progress", "NEWS2 scoring; 1 scenario")),
            ("Patient Assessment", None),
            ("Medication Safety", built("nu_lab_meds", "in_progress", "MAR checks; 1 scenario")),
            ("Nursing Procedures", built("nu_lab_procedures", "in_progress", "1 scenario")),
            ("Patient Documentation", None),
            ("Emergency Nursing", built("nu_lab_emergency", "in_progress", "1 scenario")),
            ("Medical-Surgical Nursing", None), ("Paediatric Nursing", None), ("Maternity Nursing", None),
            ("Intensive Care Nursing", None),
            ("Full Hospital Shift", built("nu_lab_shift", "in_progress", "1 shift")),
        ]),
    ]),
    ("School of Law", [
        ("introduction_to_law", "Law", [
            ("Legal Research", None), ("Case Analysis", None), ("Legal Drafting", None), ("Client Consultation", None),
            ("Negotiation and Mediation", None), ("Courtroom Practice", None), ("Full Case Assignment", None),
        ]),
    ]),
    ("School of Engineering", [
        ("mechanical_engineering", "Mechanical Engineering", [
            ("Engineering Mechanics", None), ("Thermodynamics", None), ("Fluid Mechanics", None),
            ("Machine Design", None), ("CAD and Technical Drawing", None), ("Failure Analysis", None),
        ]),
        ("civil_engineering", "Civil Engineering", [
            ("Structural Analysis", None), ("Concrete and Materials Testing", None), ("Geotechnical Engineering", None),
            ("Surveying", None), ("Transportation and Infrastructure", None), ("Construction Project Management", None),
        ]),
        ("electrical_engineering", "Electrical Engineering", [
            ("Circuit Construction", None), ("Circuit Analysis", None), ("Electronic Systems", None),
            ("Digital Logic", None), ("Power Systems", None), ("Fault Diagnosis", None),
        ]),
        ("chemical_engineering", "Chemical Engineering", [
            ("Chemical Process Fundamentals", None), ("Reaction Engineering", None), ("Separation Processes", None),
            ("Process Flow Design", None), ("Process Control", None), ("Process Safety", None),
        ]),
        ("aerospace_engineering", "Aerospace Engineering", [
            ("Aerodynamics", None), ("Aircraft Design", None), ("Flight Mechanics", None),
            ("Propulsion Systems", None), ("Aircraft Systems", None), ("Aerospace Design Project", None),
        ]),
        ("industrial_engineering", "Industrial Engineering", [
            ("Manufacturing Systems", None), ("Quality Engineering", None), ("Operations Research", None),
            ("Supply Chain", None), ("Process Improvement", None), ("Industrial Simulation Project", None),
        ]),
    ]),
    ("School of Business and Economics", [
        ("business_administration", "Business Administration", [
            ("Business Operations", None), ("Strategic Management", None), ("Human and Team Management", None),
            ("Project Management", None), ("Business Analytics", None), ("Management Capstone", None),
        ]),
        ("accounting", "Accounting", [
            ("Bookkeeping", built("acc_lab_bookkeeping", "in_progress", "Journals posted to a ledger; 1 company")),
            ("Double-Entry Accounting", None), ("General Ledger and Trial Balance", None),
            ("Bank Reconciliation", built("acc_lab_reconciliation", "in_progress", "1 reconciliation")),
            ("Financial Statements", built("acc_lab_statements", "in_progress", "Income statement and balance sheet; no cash flow yet")),
            ("Cost and Management Accounting", None), ("Auditing", None), ("Accounting Capstone", None),
        ]),
        ("finance", "Finance", [
            ("Financial Mathematics", None), ("Financial Statement Analysis", None), ("Investment Analysis", None),
            ("Portfolio Management", None), ("Corporate Finance", None), ("Risk Management", None), ("Finance Capstone", None),
        ]),
        ("economics", "Economics", [
            ("Microeconomics", None), ("Macroeconomics", None), ("Market Structures", None),
            ("Economic Data Analysis", None), ("Public Policy", None), ("International Economics", None),
        ]),
        ("entrepreneurship", "Entrepreneurship", [
            ("Opportunity Identification", None), ("Customer Discovery", None), ("Market Validation", None),
            ("Business Model Design", None), ("Financial Planning", None), ("Pitch Preparation", None),
            ("Investor Pitch", None), ("Startup Management", None),
        ]),
        ("marketing", "Marketing", [
            ("Market Research", None), ("Brand Strategy", None), ("Content Marketing", None), ("Digital Advertising", None),
            ("Social Media Marketing", None), ("Analytics and Optimization", None), ("Client Campaign Project", None),
        ]),
        ("human_resource_management", "Human Resources Management", [
            ("Recruitment", None), ("Interview Management", None), ("Employee Onboarding", None),
            ("Performance Management", None), ("Employee Relations", None), ("Workforce Planning", None), ("HR Capstone", None),
        ]),
        ("international_business", "International Business", [
            ("Global Market Research", None), ("International Trade", None), ("International Business Strategy", None),
            ("Global Supply Chain", None), ("International Negotiations", None), ("Cross-Cultural Management", None),
            ("International Business Capstone", None),
        ]),
    ]),
    ("School of Mathematics and Sciences", [
        ("mathematics", "Mathematics", [
            ("Algebra", None), ("Calculus", None), ("Linear Algebra", None), ("Statistics", None),
            ("Differential Equations", None), ("Applied Mathematics", None),
        ]),
        ("biology", "Biology", [
            ("Cell Biology", None), ("Human Biology", None), ("Genetics", None), ("Microbiology", None),
            ("Ecology", None), ("Microscopy", None), ("Biology Research Project", None),
        ]),
        ("chemistry", "Chemistry", [
            ("Atomic Structure", None), ("Molecular Modelling", None), ("Chemical Equations", None), ("Stoichiometry", None),
            ("Acids and Bases", None), ("Titration", None), ("Analytical Chemistry", None), ("Chemistry Capstone", None),
        ]),
        ("physics", "Physics", [
            ("Mechanics", None), ("Electricity", None), ("Magnetism", None), ("Waves and Optics", None),
            ("Thermodynamics", None), ("Modern Physics", None), ("Experimental Physics", None),
        ]),
    ]),
    ("School of English and Communication", [
        ("english", "English and Communication", [
            ("Grammar and Language", None), ("Reading Comprehension", None), ("Academic Writing", None),
            ("Professional Writing", None), ("Public Speaking", None), ("Editing and Proofreading", None),
            ("Professional Communication", None),
        ]),
    ]),
]

# Scenario counts of built labs (checked by test/career_sim/lab_blueprint_test.dart).
SCENARIOS = {
    "cs_lab_fundamentals": 1, "cs_lab_dsa": 1, "cs_lab_database": 1, "cs_lab_os": 1, "cs_lab_project": 1,
    "md_lab_anatomy": 1, "md_lab_assessment": 1, "md_lab_emergency": 1,
    "nu_lab_admission": 1, "nu_lab_vitals": 1, "nu_lab_meds": 1, "nu_lab_procedures": 1, "nu_lab_emergency": 1, "nu_lab_shift": 1,
    "acc_lab_bookkeeping": 1, "acc_lab_reconciliation": 1, "acc_lab_statements": 1,
}


def rows():
    for school, majors in SCHOOLS:
        for major_id, major, labs in majors:
            for i, (title, b) in enumerate(labs):
                b = b or {}
                yield {
                    "school": school, "majorId": major_id, "major": major, "letter": chr(65 + i), "title": title,
                    "labId": b.get("labId", ""), "status": b.get("status", "not_started"), "note": b.get("note", ""),
                    "scenarios": SCENARIOS.get(b.get("labId", ""), 0),
                }


def major_status(labs):
    if all(l["status"] == "verified" for l in labs):
        return "Verified complete"
    if all(l["status"] in ("tested", "verified") for l in labs):
        return "Tested"
    if any(l["status"] != "not_started" for l in labs):
        return "In progress"
    return "Not started"


def write_md(all_rows):
    total = len(all_rows)
    counts = {k: sum(1 for r in all_rows if r["status"] == k) for k in STATUS}
    out = ["# GradeGlow lab development tracker", "",
           "Generated by `python3 tool/lab_tracker.py`. Do not edit by hand.", "",
           "A lab is **Tested** only when its tools, grading and saving work, automated tests cover it, and it has",
           "15 scenarios (5 beginner, 5 intermediate, 5 advanced) or a set of project briefs. **Verified complete**",
           "also needs a manual run of the student journey. Fewer scenarios means **Functionality in progress**.", "",
           f"**{total} labs.** " + ", ".join(f"{STATUS[k]}: {counts[k]}" for k in STATUS) + ".", "",
           "## Majors", "", "| School | Major | Labs | Status |", "|---|---|---|---|"]
    majors = {}
    for r in all_rows:
        majors.setdefault((r["school"], r["major"]), []).append(r)
    for (school, major), labs in majors.items():
        out.append(f"| {school} | {major} | {len(labs)} | {major_status(labs)} |")
    out += ["", "## Labs", ""]
    for (school, major), labs in majors.items():
        out += [f"### {major}", "", "| Lab | Status | Scenarios | App id | Notes |", "|---|---|---|---|---|"]
        for r in labs:
            out.append(f"| {r['letter']}. {r['title']} | {STATUS[r['status']]} | {r['scenarios']} / 15 | {('`' + r['labId'] + '`') if r['labId'] else ''} | {r['note']} |")
        out.append("")
    with open(os.path.join(ROOT, "docs/career_sim/LAB_TRACKER.md"), "w") as f:
        f.write("\n".join(out))


def dart_str(s):
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$") + "'"


def write_dart(all_rows):
    lines = ["// GENERATED by tool/lab_tracker.py. Do not edit by hand.", "",
             "/// One laboratory from the Virtual University blueprint and how far it is built.",
             "class BlueprintLab {",
             "  const BlueprintLab(this.school, this.majorId, this.major, this.letter, this.title, this.labId, this.status, this.scenarios, this.note);",
             "  final String school;", "  final String majorId;", "  final String major;", "  final String letter;",
             "  final String title;", "", "  /// App lab id when built, otherwise empty.", "  final String labId;",
             "  final String status;", "  final int scenarios;", "  final String note;", "",
             "  bool get built => labId.isNotEmpty;", "}", "",
             "const Map<String, String> blueprintStatusLabels = <String, String>{"]
    lines += [f"  {dart_str(k)}: {dart_str(v)}," for k, v in STATUS.items()]
    lines += ["};", "", "const List<BlueprintLab> blueprintLabs = <BlueprintLab>["]
    for r in all_rows:
        lines.append("  BlueprintLab(" + ", ".join([dart_str(r["school"]), dart_str(r["majorId"]), dart_str(r["major"]), dart_str(r["letter"]),
                                                    dart_str(r["title"]), dart_str(r["labId"]), dart_str(r["status"]), str(r["scenarios"]), dart_str(r["note"])]) + "),")
    lines += ["];", ""]
    with open(os.path.join(ROOT, "lib/career_sim/labs/lab_blueprint.g.dart"), "w") as f:
        f.write("\n".join(lines))


if __name__ == "__main__":
    all_rows = list(rows())
    write_md(all_rows)
    write_dart(all_rows)
    print(json.dumps({"labs": len(all_rows), "built": sum(1 for r in all_rows if r["labId"])}))
