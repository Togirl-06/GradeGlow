"""Builds the 3D anatomy model data.

One source of truth for the 3D atlas: this file emits
  web/anatomy_3d/structures.js              (geometry, read by the 3D viewer)
  lib/career_sim/labs/anatomy3d/anatomy3d_data.g.dart   (names, systems, facts)

Coordinates are metres in anatomical position: the body stands at the origin
facing +z (towards the viewer), y is up, and the patient's LEFT is +x.
The model is a teaching schematic built from geometric primitives — organ
positions, sides and relations are anatomically placed; shapes are simplified.

  python3 tool/anatomy3d/build.py
"""
import json
import math
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

S = []  # structures


def add(id, name, system, color, desc, parts, region='', side=''):
    S.append({'id': id, 'name': name, 'system': system, 'color': color, 'desc': desc, 'parts': parts, 'region': region, 'side': side})


def ell(pos, size, rot=(0, 0, 0)):
    return {'t': 'ellipsoid', 'pos': list(pos), 'size': list(size), 'rot': list(rot)}


def cyl(pos, r, length, rot=(0, 0, 0), r2=None):
    return {'t': 'cyl', 'pos': list(pos), 'r': r, 'r2': r if r2 is None else r2, 'len': length, 'rot': list(rot)}


def tube(points, r):
    return {'t': 'tube', 'pts': [list(p) for p in points], 'r': r}


def box(pos, size, rot=(0, 0, 0)):
    return {'t': 'box', 'pos': list(pos), 'size': list(size), 'rot': list(rot)}


def mx(p):
    """Mirror a point to the other side."""
    return [-p[0], p[1], p[2]]


def mirror(parts):
    out = []
    for q in parts:
        q = json.loads(json.dumps(q))
        if 'pos' in q:
            q['pos'] = mx(q['pos'])
            q['rot'] = [q['rot'][0], -q['rot'][1], -q['rot'][2]]
        if 'pts' in q:
            q['pts'] = [mx(p) for p in q['pts']]
        out.append(q)
    return out


def paired(id, name, system, color, desc, left_parts, region=''):
    """Left (+x) and right copies of a paired structure."""
    add(f'{id}_l', f'Left {name}', system, color, desc, left_parts, region, 'left')
    add(f'{id}_r', f'Right {name}', system, color, desc, mirror(left_parts), region, 'right')


# ---------------------------------------------------------------- skeletal
BONE = '#e9e2cf'
add('skull', 'Skull', 'skeletal', BONE, 'Cranium and facial bones; protects the brain.', [ell((0, 1.62, 0.0), (0.085, 0.1, 0.1)), ell((0, 1.525, 0.05), (0.055, 0.035, 0.05))], 'head')
add('mandible', 'Mandible', 'skeletal', BONE, 'The lower jaw — the only movable bone of the skull.', [tube([(-0.05, 1.53, 0.0), (-0.045, 1.49, 0.06), (0, 1.48, 0.085), (0.045, 1.49, 0.06), (0.05, 1.53, 0.0)], 0.011)], 'head')
add('spine', 'Vertebral column', 'skeletal', BONE, '7 cervical, 12 thoracic, 5 lumbar vertebrae, then sacrum and coccyx; protects the spinal cord.',
    [cyl((0, 1.44 - i * 0.031, -0.075 - 0.02 * math.sin(i / 23 * math.pi)), 0.019 if i < 7 else 0.024 if i < 19 else 0.03, 0.022) for i in range(24)], 'trunk')
add('sacrum', 'Sacrum', 'skeletal', BONE, 'Five fused vertebrae joining the spine to the pelvis.', [ell((0, 0.68, -0.09), (0.045, 0.06, 0.025), (-20, 0, 0))], 'pelvis')
ribs = []
for i in range(12):
    y = 1.36 - i * 0.032
    w = 0.1 + 0.035 * math.sin(min(i, 8) / 8 * math.pi / 2)
    front = 0.07 if i < 7 else 0.05 - (i - 7) * 0.02
    ribs.append(tube([(0.02, y + 0.01, -0.08), (w, y, -0.06), (w + 0.02, y - 0.02, 0.0), (w * 0.75, y - 0.04, front), (0.03 if i < 7 else w * 0.5, y - 0.05, front + 0.01)], 0.006))
paired('ribs', 'ribs', 'skeletal', BONE, 'Twelve pairs: 1–7 true ribs reach the sternum, 8–10 false, 11–12 floating.', ribs, 'thorax')
add('sternum', 'Sternum', 'skeletal', BONE, 'Breastbone: manubrium, body and xiphoid process. The sternal angle marks the 2nd rib.', [box((0, 1.27, 0.085), (0.035, 0.17, 0.012))], 'thorax')
paired('clavicle', 'clavicle', 'skeletal', BONE, 'Collarbone: the strut between the sternum and the scapula; commonly fractured.', [tube([(0.02, 1.37, 0.07), (0.08, 1.385, 0.06), (0.15, 1.39, 0.0)], 0.008)], 'shoulder')
paired('scapula', 'scapula', 'skeletal', BONE, 'Shoulder blade on the back of the thorax.', [box((0.11, 1.28, -0.1), (0.09, 0.13, 0.01), (0, 15, 0))], 'shoulder')
paired('humerus', 'humerus', 'skeletal', BONE, 'Upper-arm bone; the radial nerve winds around its shaft.', [cyl((0.2, 1.21, -0.01), 0.014, 0.3)], 'arm')
paired('radius_ulna', 'radius and ulna', 'skeletal', BONE, 'Forearm bones; the radius is on the thumb side.', [cyl((0.215, 0.93, 0.0), 0.009, 0.25), cyl((0.2, 0.93, -0.012), 0.009, 0.26)], 'forearm')
add('pelvis', 'Pelvis', 'skeletal', BONE, 'Hip bones (ilium, ischium, pubis) and sacrum; supports the pelvic organs.',
    [ell((0.095, 0.77, -0.03), (0.07, 0.06, 0.012), (0, 40, -20)), ell((-0.095, 0.77, -0.03), (0.07, 0.06, 0.012), (0, -40, 20)), tube([(-0.11, 0.75, 0.0), (-0.07, 0.68, 0.05), (0, 0.66, 0.07), (0.07, 0.68, 0.05), (0.11, 0.75, 0.0)], 0.012)], 'pelvis')
paired('femur', 'femur', 'skeletal', BONE, 'Thigh bone — the longest bone in the body.', [ell((0.09, 0.69, 0.0), (0.024, 0.024, 0.024)), cyl((0.095, 0.47, 0.0), 0.016, 0.42, (0, 0, 3))], 'thigh')
paired('patella', 'patella', 'skeletal', BONE, 'Kneecap, a sesamoid bone in the quadriceps tendon.', [ell((0.1, 0.25, 0.04), (0.022, 0.026, 0.01))], 'knee')
paired('tibia_fibula', 'tibia and fibula', 'skeletal', BONE, 'Leg bones; the common peroneal nerve wraps the neck of the fibula.', [cyl((0.1, 0.03 + 0.17, 0.005), 0.015, 0.38), cyl((0.13, 0.2, -0.01), 0.008, 0.36)], 'leg')

# ---------------------------------------------------------------- nervous
add('brain', 'Brain', 'nervous', '#f2a6b3', 'Cerebral hemispheres, cerebellum and brainstem.', [ell((0.033, 1.64, 0.0), (0.04, 0.05, 0.075)), ell((-0.033, 1.64, 0.0), (0.04, 0.05, 0.075))], 'head')
add('cerebellum', 'Cerebellum', 'nervous', '#e58a9d', 'Coordinates movement and balance; at the back of the skull.', [ell((0, 1.575, -0.06), (0.05, 0.025, 0.03))], 'head')
add('spinal_cord', 'Spinal cord', 'nervous', '#f7d36b', 'Runs in the vertebral canal from the brainstem to about L1–L2.', [tube([(0, 1.56, -0.05), (0, 1.45, -0.07), (0, 1.2, -0.085), (0, 0.98, -0.08)], 0.007)], 'trunk')
paired('sciatic', 'sciatic nerve', 'nervous', '#f7d36b', 'The largest nerve; supplies the back of the thigh and below the knee.', [tube([(0.04, 0.72, -0.07), (0.08, 0.64, -0.05), (0.095, 0.45, -0.03), (0.1, 0.3, -0.03)], 0.005)], 'thigh')

# ---------------------------------------------------------------- cardiovascular
add('heart', 'Heart', 'cardiovascular', '#c62828', 'Four-chamber pump in the middle mediastinum, apex pointing to the left (5th intercostal space).', [ell((0.03, 1.24, 0.04), (0.055, 0.07, 0.045), (0, 0, -35))], 'thorax')
add('aorta', 'Aorta', 'cardiovascular', '#d32f2f', 'Leaves the left ventricle, arches to the left and descends in front of the spine.',
    [tube([(0.02, 1.27, 0.04), (0.02, 1.33, 0.03), (0.03, 1.355, -0.01), (0.03, 1.33, -0.05), (0.02, 1.2, -0.05), (0.01, 0.98, -0.045), (0.005, 0.83, -0.03)], 0.011)], 'thorax')
add('svc', 'Superior and inferior vena cava', 'cardiovascular', '#3949ab', 'Return venous blood to the right atrium.', [tube([(-0.03, 1.36, 0.02), (-0.035, 1.27, 0.03)], 0.01), tube([(-0.03, 1.2, 0.0), (-0.025, 1.05, -0.03), (-0.02, 0.83, -0.03)], 0.011)], 'thorax')
paired('carotid', 'common carotid artery', 'cardiovascular', '#d32f2f', 'Supplies the head and neck; pulse felt beside the larynx.', [tube([(0.012, 1.35, 0.0), (0.022, 1.42, 0.02), (0.03, 1.5, 0.02)], 0.005)], 'neck')
paired('femoral_a', 'femoral artery', 'cardiovascular', '#d32f2f', 'Main artery of the leg; pulse at the mid-inguinal point.', [tube([(0.005, 0.83, -0.03), (0.05, 0.75, 0.03), (0.08, 0.66, 0.035), (0.09, 0.45, 0.01)], 0.006)], 'thigh')

# ---------------------------------------------------------------- respiratory
add('trachea', 'Trachea', 'respiratory', '#90caf9', 'Windpipe from the larynx to the carina (about T4), where it divides.', [cyl((0, 1.38, 0.02), 0.01, 0.12)], 'neck')
paired('bronchus', 'main bronchus', 'respiratory', '#90caf9', 'The right main bronchus is wider, shorter and more vertical — inhaled objects usually go right.', [tube([(0, 1.32, 0.02), (0.035, 1.29, 0.01), (0.06, 1.27, 0.0)], 0.007)], 'thorax')
add('lung_l', 'Left lung', 'respiratory', '#f48fb1', 'Two lobes (upper and lower) and a cardiac notch for the heart.', [ell((0.085, 1.27, 0.0), (0.06, 0.12, 0.075))], 'thorax', 'left')
add('lung_r', 'Right lung', 'respiratory', '#f48fb1', 'Three lobes (upper, middle and lower); slightly larger than the left.', [ell((-0.09, 1.27, 0.0), (0.065, 0.12, 0.08))], 'thorax', 'right')
add('diaphragm', 'Diaphragm', 'respiratory', '#bcaaa4', 'Dome-shaped main muscle of breathing, between thorax and abdomen.', [ell((0, 1.12, -0.01), (0.15, 0.03, 0.1))], 'thorax')

# ---------------------------------------------------------------- digestive
add('oesophagus', 'Oesophagus', 'digestive', '#ef9a9a', 'Muscular tube behind the trachea, through the diaphragm to the stomach.', [tube([(0, 1.45, -0.01), (0.0, 1.3, -0.03), (0.02, 1.14, -0.02), (0.05, 1.1, 0.0)], 0.007)], 'thorax')
add('liver', 'Liver', 'digestive', '#8d3b2b', 'Largest internal organ, under the right diaphragm; makes bile and processes nutrients.', [ell((-0.06, 1.07, 0.02), (0.12, 0.05, 0.08), (0, 0, -8))], 'abdomen', 'right')
add('gallbladder', 'Gallbladder', 'digestive', '#4caf50', 'Stores bile under the liver; inflamed in cholecystitis (Murphy’s sign).', [ell((-0.06, 1.02, 0.08), (0.015, 0.025, 0.012))], 'abdomen', 'right')
add('stomach', 'Stomach', 'digestive', '#ff8a65', 'J-shaped sac in the left upper quadrant, below the diaphragm.', [tube([(0.05, 1.1, 0.0), (0.09, 1.07, 0.04), (0.08, 1.0, 0.07), (0.03, 0.98, 0.07), (-0.01, 1.0, 0.05)], 0.03)], 'abdomen', 'left')
add('pancreas', 'Pancreas', 'digestive', '#ffcc80', 'Behind the stomach, head in the duodenal curve; makes insulin and digestive enzymes.', [ell((0.02, 0.98, -0.02), (0.07, 0.012, 0.015), (0, 0, 10))], 'abdomen')
add('spleen', 'Spleen', 'lymphatic', '#6a1b9a', 'Left upper quadrant behind the stomach, under ribs 9–11; filters blood.', [ell((0.12, 1.04, -0.04), (0.025, 0.045, 0.02), (0, 0, 20))], 'abdomen', 'left')
add('small_intestine', 'Small intestine', 'digestive', '#ffd54f', 'Duodenum, jejunum and ileum: about 6 m long; absorbs nutrients.',
    [tube([((0.07 if (k // 2) % 2 == 0 else -0.07) * (1 if k % 2 == 0 else 0.2), 0.92 - k * 0.011, 0.045 + 0.012 * math.sin(k * 1.3)) for k in range(18)], 0.012)], 'abdomen')
add('large_intestine', 'Large intestine', 'digestive', '#c49a6c', 'Caecum, ascending, transverse, descending and sigmoid colon; absorbs water.',
    [tube([(-0.1, 0.78, 0.03), (-0.11, 0.9, 0.03), (-0.08, 0.96, 0.05), (0.0, 0.95, 0.07), (0.08, 0.96, 0.05), (0.11, 0.9, 0.03), (0.1, 0.8, 0.03), (0.06, 0.74, 0.04), (0.02, 0.72, 0.02)], 0.02)], 'abdomen')
add('appendix', 'Appendix', 'digestive', '#a1887f', 'Hangs from the caecum in the right iliac fossa (McBurney’s point).', [tube([(-0.1, 0.77, 0.04), (-0.095, 0.745, 0.05), (-0.085, 0.735, 0.055)], 0.005)], 'abdomen', 'right')
add('rectum', 'Rectum', 'digestive', '#a1887f', 'Final part of the large bowel in the pelvis, in front of the sacrum.', [cyl((0.0, 0.68, -0.05), 0.016, 0.07)], 'pelvis')

# ---------------------------------------------------------------- urinary
paired('kidney', 'kidney', 'urinary', '#8e2b2b', 'Retroperitoneal at T12–L3; the right sits a little lower because of the liver. Filters blood.', [ell((0.065, 0.97, -0.06), (0.022, 0.045, 0.018), (0, 0, -10))], 'abdomen')
for side, sx in (('l', 1), ('r', -1)):
    S[-1 if side == 'r' else -2]['parts'][0]['pos'][1] = 0.97 if side == 'l' else 0.955
paired('ureter', 'ureter', 'urinary', '#e6b800', 'Carries urine from the kidney to the bladder.', [tube([(0.06, 0.93, -0.05), (0.05, 0.82, -0.04), (0.035, 0.7, 0.02), (0.015, 0.68, 0.04)], 0.004)], 'abdomen')
add('bladder', 'Urinary bladder', 'urinary', '#ffe082', 'Stores urine in the pelvis behind the pubic symphysis.', [ell((0.0, 0.68, 0.045), (0.03, 0.025, 0.025))], 'pelvis')

# ---------------------------------------------------------------- endocrine
add('thyroid', 'Thyroid gland', 'endocrine', '#ab47bc', 'Butterfly-shaped gland in front of the trachea below the larynx.', [ell((0.012, 1.42, 0.035), (0.01, 0.018, 0.008)), ell((-0.012, 1.42, 0.035), (0.01, 0.018, 0.008))], 'neck')
paired('adrenal', 'adrenal gland', 'endocrine', '#ce93d8', 'Caps each kidney; produces adrenaline and cortisol.', [ell((0.06, 1.02, -0.055), (0.012, 0.01, 0.008))], 'abdomen')

SYSTEMS = {
    'skeletal': 'Skeletal', 'nervous': 'Nervous', 'cardiovascular': 'Cardiovascular', 'respiratory': 'Respiratory',
    'digestive': 'Digestive', 'urinary': 'Urinary', 'endocrine': 'Endocrine', 'lymphatic': 'Lymphatic',
}

# Body surface (semi-transparent skin), not pickable.
SKIN = [ell((0, 1.6, 0.0), (0.095, 0.115, 0.11)), cyl((0, 1.43, -0.01), 0.05, 0.1), ell((0, 1.2, -0.01), (0.17, 0.22, 0.12)), ell((0, 0.85, 0.0), (0.15, 0.17, 0.11)),
        cyl((0.2, 1.2, -0.01), 0.04, 0.32), cyl((-0.2, 1.2, -0.01), 0.04, 0.32), cyl((0.21, 0.92, 0.0), 0.033, 0.28), cyl((-0.21, 0.92, 0.0), 0.033, 0.28),
        cyl((0.095, 0.47, 0.0), 0.065, 0.46, (0, 0, 3), 0.045), cyl((-0.095, 0.47, 0.0), 0.065, 0.46, (0, 0, -3), 0.045), cyl((0.105, 0.2, 0.0), 0.045, 0.4, (0, 0, 0), 0.03), cyl((-0.105, 0.2, 0.0), 0.045, 0.4, (0, 0, 0), 0.03)]


def validate():
    ids = [s['id'] for s in S]
    assert len(ids) == len(set(ids)), 'duplicate ids'
    for s in S:
        assert s['system'] in SYSTEMS, s['id']
        assert s['parts'], s['id']
        for p in s['parts']:
            for k in ('pos',):
                if k in p:
                    assert len(p[k]) == 3
            if p['t'] == 'tube':
                assert len(p['pts']) >= 2, s['id']
    # Sides: patient's left is +x.
    centre = {s['id']: (sum((p['pos'][0] if 'pos' in p else sum(q[0] for q in p['pts']) / len(p['pts'])) for p in s['parts']) / len(s['parts'])) for s in S}
    for s in S:
        if s['side'] == 'left':
            assert centre[s['id']] > 0, f"{s['id']} should be on the patient's left (+x)"
        if s['side'] == 'right':
            assert centre[s['id']] < 0, f"{s['id']} should be on the patient's right (-x)"


def emit():
    validate()
    data = {'systems': SYSTEMS, 'structures': S, 'skin': SKIN}
    os.makedirs(os.path.join(ROOT, 'web/anatomy_3d'), exist_ok=True)
    with open(os.path.join(ROOT, 'web/anatomy_3d/structures.js'), 'w') as f:
        f.write('// Generated by tool/anatomy3d/build.py — do not edit.\n')
        f.write('(function (g) { g.GG_ANATOMY = ' + json.dumps(data, separators=(',', ':')) + ';\n')
        f.write("  if (typeof module !== 'undefined') module.exports = g.GG_ANATOMY;\n})(typeof globalThis !== 'undefined' ? globalThis : this);\n")
    os.makedirs(os.path.join(ROOT, 'lib/career_sim/labs/anatomy3d'), exist_ok=True)

    def ds(x):
        return "'" + x.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"
    lines = ['// Generated by tool/anatomy3d/build.py — do not edit.', '// ignore_for_file: lines_longer_than_80_chars', '',
             "import 'anatomy3d.dart';", '', 'const Map<String, String> anatomySystems = <String, String>{']
    lines += [f'  {ds(k)}: {ds(v)},' for k, v in SYSTEMS.items()]
    lines += ['};', '', 'const List<AnatomyStructure> anatomyStructures = <AnatomyStructure>[']
    for s in S:
        lines.append(f"  AnatomyStructure({ds(s['id'])}, {ds(s['name'])}, {ds(s['system'])}, {ds(s['desc'])}, region: {ds(s['region'])}, side: {ds(s['side'])}),")
    lines += ['];', '']
    with open(os.path.join(ROOT, 'lib/career_sim/labs/anatomy3d/anatomy3d_data.g.dart'), 'w') as f:
        f.write('\n'.join(lines))
    print(f'{len(S)} structures in {len(SYSTEMS)} systems')


if __name__ == '__main__':
    emit()
