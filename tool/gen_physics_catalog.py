#!/usr/bin/env python3
"""Generate lib/data/physics/physics_catalog.dart from the master physics curriculum."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "lib" / "data" / "physics" / "physics_catalog.dart"

# (level, track_id, track_name, track_tagline, emoji)
TRACKS = [
    (
        "foundations",
        "foundations",
        "Foundations of Physics",
        "Scientific method, measurement, and the mathematical language of nature.",
        "🔭",
    ),
    (
        "undergraduate",
        "undergraduate_core",
        "Undergraduate Core",
        "From kinematics through particle physics — the complete classical and modern core.",
        "⚛️",
    ),
    (
        "graduate",
        "graduate_theory",
        "Graduate Physics",
        "Advanced theory, methods, and research-depth problem solving.",
        "🎓",
    ),
    (
        "research",
        "research_specializations",
        "Research Specializations",
        "Frontier tracks: astrophysics, quantum information, medical physics, and more.",
        "🚀",
    ),
]

# (track_id, course_id, title, blurb, lab, sim, quiz, topics[])
COURSES: list[tuple] = []

def course(track, cid, title, blurb, topics, lab=None, sim=None, quiz=None):
    COURSES.append((
        track,
        cid,
        title,
        blurb,
        lab or f"{title} Virtual Lab",
        sim or f"{title} 3D Simulator",
        quiz or f"{title} Quiz",
        topics,
    ))

# --- FOUNDATIONS ---
course(
    "foundations",
    "intro_physics",
    "Introduction to Physics",
    "What physics is, how we measure reality, and how experiments become laws.",
    [
        "What is physics?",
        "History of physics",
        "Branches of physics",
        "Physics in engineering, medicine, technology",
        "Scientific method",
        "Experimental design",
        "Physical laws",
        "Mathematical modeling",
        "Units and measurements",
        "SI units",
        "Dimensional analysis",
        "Significant figures",
        "Measurement uncertainty",
        "Error analysis",
        "Data collection",
        "Graphing data",
        "Scientific notation",
        "Vectors and scalars",
    ],
)

course(
    "foundations",
    "math_foundations",
    "Mathematical Physics Foundations",
    "The calculus, linear algebra, and computation every physicist needs.",
    [
        "Algebra review",
        "Trigonometry",
        "Geometry",
        "Coordinate systems",
        "Functions",
        "Graphs",
        "Calculus introduction",
        "Limits",
        "Derivatives",
        "Integrals",
        "Differential equations",
        "Linear algebra",
        "Complex numbers",
        "Probability and statistics",
        "Numerical methods",
        "Computational physics",
    ],
)

# --- UNDERGRADUATE: CLASSICAL MECHANICS ---
course(
    "undergraduate_core",
    "kinematics",
    "Kinematics",
    "Describe motion before forces — position, velocity, acceleration, and graphs.",
    [
        "Position",
        "Distance",
        "Displacement",
        "Speed",
        "Velocity",
        "Acceleration",
        "Motion graphs",
        "One-dimensional motion",
        "Two-dimensional motion",
        "Projectile motion",
        "Circular motion",
        "Relative motion",
        "Reference frames",
    ],
)

course(
    "undergraduate_core",
    "newtonian_mechanics",
    "Newtonian Mechanics",
    "Forces, free-body diagrams, and Newton's laws in the real world.",
    [
        "Newton's laws of motion",
        "Inertia",
        "Force",
        "Mass",
        "Acceleration",
        "Weight",
        "Normal force",
        "Friction",
        "Drag force",
        "Tension",
        "Springs",
        "Equilibrium",
        "Free body diagrams",
        "Applications of forces",
    ],
)

course(
    "undergraduate_core",
    "work_energy_power",
    "Work, Energy, and Power",
    "Conservation of energy as physics' accounting system.",
    [
        "Work",
        "Energy",
        "Kinetic energy",
        "Potential energy",
        "Gravitational energy",
        "Elastic energy",
        "Conservation of energy",
        "Power",
        "Efficiency",
        "Energy transfer",
    ],
)

course(
    "undergraduate_core",
    "momentum_collisions",
    "Momentum and Collisions",
    "Impulse, conservation, and what happens when objects collide.",
    [
        "Linear momentum",
        "Impulse",
        "Conservation of momentum",
        "Elastic collisions",
        "Inelastic collisions",
        "Explosions",
        "Rocket propulsion",
        "Center of mass",
    ],
)

course(
    "undergraduate_core",
    "rotational_mechanics",
    "Rotational Mechanics",
    "Torque, angular momentum, and spinning systems.",
    [
        "Angular displacement",
        "Angular velocity",
        "Angular acceleration",
        "Torque",
        "Rotational inertia",
        "Rotational energy",
        "Angular momentum",
        "Conservation of angular momentum",
        "Rolling motion",
        "Gyroscopes",
    ],
)

course(
    "undergraduate_core",
    "gravitation",
    "Gravitation",
    "Newtonian gravity, orbits, and the doorway to relativity.",
    [
        "Newton's law of gravity",
        "Gravitational fields",
        "Gravitational potential",
        "Escape velocity",
        "Orbital mechanics",
        "Satellites",
        "Planetary motion",
        "Kepler's laws",
        "Black hole basics",
    ],
)

course(
    "undergraduate_core",
    "oscillations",
    "Oscillations and Vibrations",
    "Simple harmonic motion, damping, resonance, and mechanical waves.",
    [
        "Simple harmonic motion",
        "Springs",
        "Pendulums",
        "Damping",
        "Resonance",
        "Forced oscillations",
        "Mechanical vibrations",
        "Structural vibration",
    ],
)

# --- UNDERGRADUATE: FLUIDS / THERMO / WAVES ---
course(
    "undergraduate_core",
    "fluid_mechanics",
    "Fluid Mechanics",
    "Pressure, buoyancy, flow, and aerodynamic forces.",
    [
        "Density",
        "Pressure",
        "Buoyancy",
        "Pascal's law",
        "Archimedes principle",
        "Fluid flow",
        "Continuity equation",
        "Bernoulli equation",
        "Viscosity",
        "Turbulence",
        "Laminar flow",
        "Aerodynamics",
        "Hydrodynamics",
    ],
)

course(
    "undergraduate_core",
    "thermodynamics",
    "Thermodynamics",
    "Heat, entropy, engines, and the laws that bound energy conversion.",
    [
        "Temperature",
        "Heat",
        "Thermal equilibrium",
        "Zeroth law",
        "First law",
        "Second law",
        "Third law",
        "Entropy",
        "Heat engines",
        "Refrigerators",
        "Carnot cycle",
        "Phase transitions",
        "Thermal expansion",
    ],
)

course(
    "undergraduate_core",
    "statistical_mechanics",
    "Statistical Mechanics",
    "From microstates to temperature — the particle view of thermodynamics.",
    [
        "Probability distributions",
        "Microstates",
        "Macrostates",
        "Maxwell-Boltzmann statistics",
        "Entropy",
        "Temperature from particle motion",
        "Gas laws",
        "Quantum statistics",
    ],
)

course(
    "undergraduate_core",
    "waves",
    "Waves",
    "Superposition, interference, diffraction, and standing waves.",
    [
        "Wave properties",
        "Frequency",
        "Wavelength",
        "Amplitude",
        "Wave speed",
        "Superposition",
        "Interference",
        "Diffraction",
        "Standing waves",
        "Resonance",
        "Sound waves",
    ],
)

course(
    "undergraduate_core",
    "acoustics",
    "Acoustics",
    "How sound is made, travels, and is used in medicine and technology.",
    [
        "Sound production",
        "Sound propagation",
        "Hearing physics",
        "Ultrasound",
        "Noise control",
        "Musical instruments",
        "Audio technology",
    ],
)

# --- UNDERGRADUATE: E&M ---
course(
    "undergraduate_core",
    "electrostatics",
    "Electrostatics",
    "Charge, fields, potential, and Gauss's law.",
    [
        "Electric charge",
        "Conductors",
        "Insulators",
        "Electric fields",
        "Electric potential",
        "Voltage",
        "Coulomb's law",
        "Electric flux",
        "Gauss's law",
    ],
)

course(
    "undergraduate_core",
    "electric_circuits",
    "Electric Circuits",
    "Current, resistance, Kirchhoff rules, and RC circuits.",
    [
        "Current",
        "Resistance",
        "Voltage",
        "Ohm's law",
        "Kirchhoff laws",
        "Series circuits",
        "Parallel circuits",
        "Capacitors",
        "Batteries",
        "RC circuits",
        "Electronics",
    ],
)

course(
    "undergraduate_core",
    "magnetism",
    "Magnetism",
    "Magnetic fields, forces, materials, and the Hall effect.",
    [
        "Magnetic fields",
        "Magnetic force",
        "Electromagnets",
        "Magnetic materials",
        "Earth's magnetic field",
        "Hall effect",
        "Magnetic storage",
    ],
)

course(
    "undergraduate_core",
    "em_induction",
    "Electromagnetic Induction",
    "Faraday, Lenz, generators, motors, and transformers.",
    [
        "Faraday's law",
        "Lenz's law",
        "Generators",
        "Motors",
        "Transformers",
        "Power transmission",
    ],
)

course(
    "undergraduate_core",
    "maxwell_equations",
    "Maxwell's Equations",
    "Unifying electricity and magnetism — and predicting light.",
    [
        "Electric fields",
        "Magnetic fields",
        "Electromagnetic waves",
        "Light as electromagnetic radiation",
        "Wave equations",
    ],
)

# --- UNDERGRADUATE: MODERN ---
course(
    "undergraduate_core",
    "optics",
    "Optics",
    "Reflection, refraction, lenses, lasers, and optical instruments.",
    [
        "Reflection",
        "Refraction",
        "Mirrors",
        "Lenses",
        "Image formation",
        "Optical instruments",
        "Fiber optics",
        "Lasers",
        "Holography",
    ],
)

course(
    "undergraduate_core",
    "special_relativity",
    "Special Relativity",
    "Einstein's postulates and spacetime for fast-moving observers.",
    [
        "Einstein's postulates",
        "Time dilation",
        "Length contraction",
        "Relativity of simultaneity",
        "Relativistic momentum",
        "Mass-energy equivalence",
    ],
)

course(
    "undergraduate_core",
    "general_relativity",
    "General Relativity",
    "Gravity as curved spacetime — black holes and cosmology.",
    [
        "Gravity as spacetime curvature",
        "Einstein field equations",
        "Black holes",
        "Gravitational waves",
        "Cosmology",
    ],
)

course(
    "undergraduate_core",
    "quantum_mechanics",
    "Quantum Mechanics",
    "Wave functions, operators, measurement, and tunneling.",
    [
        "Quantum theory",
        "Wave-particle duality",
        "Quantum states",
        "Probability waves",
        "Schrödinger equation",
        "Operators",
        "Quantum numbers",
        "Spin",
        "Quantum tunneling",
        "Quantum measurement",
    ],
)

course(
    "undergraduate_core",
    "atomic_physics",
    "Atomic Physics",
    "Orbitals, spectroscopy, transitions, and laser physics.",
    [
        "Atomic structure",
        "Electron orbitals",
        "Energy levels",
        "Spectroscopy",
        "Atomic transitions",
        "Lasers",
    ],
)

course(
    "undergraduate_core",
    "nuclear_physics",
    "Nuclear Physics",
    "Radioactivity, reactions, fission, fusion, and reactors.",
    [
        "Nuclear structure",
        "Radioactivity",
        "Alpha decay",
        "Beta decay",
        "Gamma radiation",
        "Nuclear reactions",
        "Nuclear fission",
        "Nuclear fusion",
        "Nuclear reactors",
    ],
)

course(
    "undergraduate_core",
    "particle_physics",
    "Particle Physics",
    "The Standard Model, accelerators, and the Higgs.",
    [
        "Fundamental particles",
        "Quarks",
        "Leptons",
        "Bosons",
        "Standard Model",
        "Higgs boson",
        "Particle accelerators",
        "CERN physics",
    ],
)

# --- GRADUATE ---
course(
    "graduate_theory",
    "advanced_classical",
    "Advanced Classical Mechanics",
    "Lagrangians, Hamiltonians, chaos, and rigid-body theory.",
    [
        "Lagrangian mechanics",
        "Hamiltonian mechanics",
        "Canonical transformations",
        "Poisson brackets",
        "Small oscillations",
        "Central force problems",
        "Rigid body dynamics",
        "Nonlinear dynamics and chaos",
    ],
)

course(
    "graduate_theory",
    "advanced_electrodynamics",
    "Advanced Electrodynamics",
    "Covariant formulation, radiation, and plasmas.",
    [
        "Maxwell equations in covariant form",
        "Electromagnetic potentials",
        "Gauge invariance",
        "Radiation from accelerating charges",
        "Multipole expansion",
        "Waveguides and cavities",
        "Plasma electrodynamics",
    ],
)

course(
    "graduate_theory",
    "advanced_quantum",
    "Advanced Quantum Mechanics",
    "Perturbation theory, scattering, and identical particles.",
    [
        "Perturbation theory",
        "Variational methods",
        "WKB approximation",
        "Scattering theory",
        "Partial waves",
        "Identical particles",
        "Density matrices",
        "Open quantum systems",
    ],
)

course(
    "graduate_theory",
    "quantum_field_theory",
    "Quantum Field Theory",
    "Fields, creation operators, Feynman diagrams, and renormalization.",
    [
        "Second quantization",
        "Klein-Gordon and Dirac fields",
        "Quantum electrodynamics basics",
        "Feynman diagrams",
        "Renormalization",
        "Spontaneous symmetry breaking",
        "Standard Model field content",
    ],
)

course(
    "graduate_theory",
    "statistical_field_theory",
    "Statistical Field Theory",
    "Phase transitions, critical phenomena, and renormalization group.",
    [
        "Partition functions",
        "Ising model",
        "Mean field theory",
        "Critical exponents",
        "Renormalization group",
        "Landau theory",
        "Fluctuation-dissipation",
    ],
)

course(
    "graduate_theory",
    "general_relativity_grad",
    "General Relativity (Graduate)",
    "Tensor calculus, geodesics, and gravitational lensing.",
    [
        "Differential geometry",
        "Einstein tensor",
        "Geodesic equation",
        "Schwarzschild solution",
        "Kerr black holes",
        "Gravitational lensing",
        "Cosmological models",
    ],
)

course(
    "graduate_theory",
    "condensed_matter_grad",
    "Condensed Matter (Graduate)",
    "Band theory, phonons, and many-body methods.",
    [
        "Crystal symmetry",
        "Band structure",
        "Fermi liquid theory",
        "Phonons",
        "Superconductivity (BCS)",
        "Topological insulators",
        "Many-body perturbation",
    ],
)

course(
    "graduate_theory",
    "plasma_physics_grad",
    "Plasma Physics (Graduate)",
    "MHD, instabilities, and fusion confinement.",
    [
        "Debye shielding",
        "Plasma oscillations",
        "Magnetohydrodynamics",
        "Tokamak equilibrium",
        "Instabilities",
        "Fusion power balance",
    ],
)

course(
    "graduate_theory",
    "computational_methods",
    "Computational Physics Methods",
    "Numerical PDEs, Monte Carlo, and high-performance simulation.",
    [
        "Finite difference methods",
        "Finite element basics",
        "Molecular dynamics",
        "Monte Carlo integration",
        "Lattice simulations",
        "Parallel computing for physics",
        "Machine learning in physics",
    ],
)

# --- RESEARCH SPECIALIZATIONS ---
course(
    "research_specializations",
    "astrophysics",
    "Astrophysics",
    "Stars, galaxies, dark matter, and the expanding universe.",
    [
        "Stars",
        "Star formation",
        "Stellar evolution",
        "Supernovae",
        "Galaxies",
        "Dark matter",
        "Dark energy",
        "Neutron stars",
        "Black holes",
        "Cosmology",
    ],
)

course(
    "research_specializations",
    "space_physics",
    "Space Physics",
    "Solar wind, magnetospheres, and space weather.",
    [
        "Solar physics",
        "Solar wind",
        "Magnetospheres",
        "Space weather",
        "Radiation belts",
        "Planetary physics",
    ],
)

course(
    "research_specializations",
    "medical_physics",
    "Medical Physics",
    "Imaging, therapy, and radiation safety in healthcare.",
    [
        "Radiation therapy",
        "MRI physics",
        "CT scans",
        "Ultrasound imaging",
        "Nuclear medicine",
        "Medical radiation safety",
    ],
)

course(
    "research_specializations",
    "condensed_matter",
    "Condensed Matter Physics",
    "Solids, semiconductors, superconductors, and nanotech.",
    [
        "Solid-state physics",
        "Crystal structures",
        "Semiconductors",
        "Superconductivity",
        "Nanotechnology",
        "Materials physics",
    ],
)

course(
    "research_specializations",
    "plasma_physics",
    "Plasma Physics",
    "Ionized gases, fusion reactors, and space plasma.",
    [
        "Ionized gases",
        "Plasma waves",
        "Fusion reactors",
        "Tokamaks",
        "Space plasma",
    ],
)

course(
    "research_specializations",
    "biophysics",
    "Biophysics",
    "Physics of life — from proteins to neural systems.",
    [
        "Physics of cells",
        "Protein folding",
        "DNA mechanics",
        "Biomechanics",
        "Neural physics",
        "Biological systems",
    ],
)

course(
    "research_specializations",
    "computational_physics",
    "Computational Physics",
    "Simulation, ML discovery, and numerical modeling at scale.",
    [
        "Python for physics",
        "Simulation methods",
        "Monte Carlo methods",
        "Machine learning physics",
        "Numerical modeling",
        "AI physics discovery",
    ],
)

course(
    "research_specializations",
    "engineering_physics",
    "Engineering Physics Applications",
    "Aerospace, quantum computing, renewables, and semiconductors.",
    [
        "Aerospace physics",
        "Robotics physics",
        "Nuclear engineering physics",
        "Renewable energy physics",
        "Quantum computing",
        "Semiconductor physics",
        "Nanotechnology",
    ],
)

course(
    "research_specializations",
    "advanced_research",
    "Advanced Research Frontiers",
    "String theory, quantum gravity, and open problems at the edge of physics.",
    [
        "String theory",
        "Quantum field theory frontiers",
        "Quantum gravity",
        "Loop quantum gravity",
        "Supersymmetry",
        "Multiverse theories",
        "Dark matter research",
        "Dark energy research",
        "Quantum information theory",
        "Topological physics",
        "High-energy physics",
    ],
)


def slug(s: str) -> str:
    s = s.lower().strip()
    s = re.sub(r"[^a-z0-9]+", "_", s)
    return s.strip("_")[:48]


def dart_escape(s: str) -> str:
    return s.replace("\\", "\\\\").replace("'", "\\'")


def topic_block(course_id: str, title: str, idx: int) -> str:
    tid = f"{course_id}_{slug(title)}"
    hook = f"A real scenario where {title.lower()} determines whether a design, experiment, or prediction succeeds."
    summary = (
        f"Master {title} through lecture, simulation, lab work, and problem solving — "
        f"from intuition to quantitative prediction."
    )
    concepts = f"'{dart_escape(title)}', 'Quantitative prediction', 'Experimental verification', 'Model limits'"
    formulas = "'Define governing relations', 'Check units and limits', 'Apply conservation laws'"
    real_world = f"Engineering, space missions, medical devices, and energy systems all depend on {title.lower()}."
    career = "Research labs, NASA, CERN, semiconductor fabs, hospitals, and national energy programs."
    return f"""    PhysicsTopic(
      id: '{tid}',
      title: '{dart_escape(title)}',
      hook: '{dart_escape(hook)}',
      summary: '{dart_escape(summary)}',
      keyConcepts: <String>[{concepts}],
      formulas: <String>[{formulas}],
      realWorld: '{dart_escape(real_world)}',
      career: '{dart_escape(career)}',
    ),"""


def generate() -> str:
    lines: list[str] = [
        "import 'package:flutter/material.dart';",
        "",
        "import '../../models/physics/physics_program.dart';",
        "",
        "/// Complete Virtual University Physics curriculum — foundations through research.",
        "/// Organized by academic level, not calendar year.",
        "class PhysicsCatalog {",
        "  PhysicsCatalog._();",
        "",
        "  static const String philosophy =",
        "      'Learn → Simulate → Experiment → Build → Compete → Research → Apply';",
        "",
        "  static const String mission =",
        "      'MIT rigor + NASA wonder + simulator depth + olympiad practice — one physics university.';",
        "",
        "  static List<PhysicsTrack> get tracks => _tracks;",
        "",
        "  static List<PhysicsLevel> get levels => PhysicsLevel.values;",
        "",
        "  static PhysicsTrack? trackById(String id) {",
        "    for (final PhysicsTrack t in _tracks) {",
        "      if (t.id == id) return t;",
        "    }",
        "    return null;",
        "  }",
        "",
        "  static List<PhysicsTrack> tracksForLevel(PhysicsLevel level) =>",
        "      _tracks.where((PhysicsTrack t) => t.level == level).toList();",
        "",
        "  static PhysicsCourse? courseById({required String trackId, required String courseId}) {",
        "    final PhysicsTrack? track = trackById(trackId);",
        "    if (track == null) return null;",
        "    for (final PhysicsCourse c in track.courses) {",
        "      if (c.id == courseId) return c;",
        "    }",
        "    return null;",
        "  }",
        "",
        "  static PhysicsTopic? topicById({",
        "    required String trackId,",
        "    required String courseId,",
        "    required String topicId,",
        "  }) {",
        "    final PhysicsCourse? course = courseById(trackId: trackId, courseId: courseId);",
        "    if (course == null) return null;",
        "    for (final PhysicsTopic t in course.topics) {",
        "      if (t.id == topicId) return t;",
        "    }",
        "    return null;",
        "  }",
        "",
        "  static int get trackCount => _tracks.length;",
        "",
        "  static int get courseCount =>",
        "      _tracks.fold<int>(0, (int sum, PhysicsTrack t) => sum + t.courses.length);",
        "",
        "  static int get topicCount => _tracks.fold<int>(",
        "        0,",
        "        (int sum, PhysicsTrack t) =>",
        "            sum + t.courses.fold<int>(0, (int cs, PhysicsCourse c) => cs + c.topics.length),",
        "      );",
        "",
        "  static const List<PhysicsTrack> _tracks = <PhysicsTrack>[",
    ]

    track_icons = {
        "foundations": "Icons.explore_outlined",
        "undergraduate_core": "Icons.hub_outlined",
        "graduate_theory": "Icons.psychology_outlined",
        "research_specializations": "Icons.rocket_launch_outlined",
    }

    by_track: dict[str, list] = {}
    for row in COURSES:
        by_track.setdefault(row[0], []).append(row)

    level_map = {t[1]: t[0] for t in TRACKS}

    for level, tid, tname, ttag, emoji in TRACKS:
        rows = by_track.get(tid, [])
        lines.append("    PhysicsTrack(")
        lines.append(f"      level: PhysicsLevel.{level},")
        lines.append(f"      id: '{tid}',")
        lines.append(f"      name: '{dart_escape(tname)}',")
        lines.append(f"      tagline: '{dart_escape(ttag)}',")
        lines.append(f"      icon: {track_icons.get(tid, 'Icons.science_outlined')},")
        lines.append(f"      emoji: '{emoji}',")
        lines.append("      courses: <PhysicsCourse>[")
        for _, cid, title, blurb, lab, sim, quiz, topics in rows:
            lines.append("        PhysicsCourse(")
            lines.append(f"          id: '{cid}',")
            lines.append(f"          title: '{dart_escape(title)}',")
            lines.append(f"          blurb: '{dart_escape(blurb)}',")
            lines.append(f"          labTitle: '{dart_escape(lab)}',")
            lines.append(f"          simulatorTitle: '{dart_escape(sim)}',")
            lines.append(f"          quizTitle: '{dart_escape(quiz)}',")
            lines.append("          topics: <PhysicsTopic>[")
            for i, topic_title in enumerate(topics):
                lines.append(topic_block(cid, topic_title, i))
            lines.append("          ],")
            lines.append("        ),")
        lines.append("      ],")
        lines.append("    ),")

    lines.append("  ];")
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def main() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(generate(), encoding="utf-8")
    topic_total = sum(len(c[7]) for c in COURSES)
    print(f"Wrote {OUT}")
    print(f"  courses: {len(COURSES)}")
    print(f"  topics:  {topic_total}")


if __name__ == "__main__":
    main()
