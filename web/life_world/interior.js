// Cut-away interiors (The Sims style) with furniture for every interactable.
import * as THREE from 'three';
import { box, rbox, cyl, sphere, cone, torus, plane, mat, col, shade, hex, at, labelSprite, signMaterial, rng, mergeStatic } from './util.js';
import { tree, bush, bench } from './buildings.js';
import { makeCharacter, uniformForRole } from './characters.js';

const WALL_H = 2.1;

// ------------------------------------------------------------ textures

function floorTexture(kind, base) {
  const c = document.createElement('canvas');
  c.width = c.height = 256;
  const g = c.getContext('2d');
  const b = col(base);
  const r = rng('floor' + kind);
  if (kind === 'wood') {
    for (let y = 0; y < 256; y += 32) {
      for (let x = (y / 32) % 2 ? -64 : 0; x < 256; x += 128) {
        const v = 0.85 + r() * 0.2;
        g.fillStyle = '#' + new THREE.Color(0xc08a5a).multiplyScalar(v).lerp(b, 0.15).getHexString();
        g.fillRect(x, y, 128, 32);
        g.fillStyle = 'rgba(0,0,0,0.18)';
        g.fillRect(x, y, 128, 1.5);
        g.fillRect(x, y, 1.5, 32);
        g.fillStyle = 'rgba(80,40,10,0.08)';
        for (let i = 0; i < 4; i++) g.fillRect(x + r() * 120, y + 6 + r() * 20, 30 + r() * 40, 1);
      }
    }
  } else if (kind === 'carpet') {
    g.fillStyle = '#' + b.clone().lerp(new THREE.Color(0x64748b), 0.55).getHexString();
    g.fillRect(0, 0, 256, 256);
    for (let i = 0; i < 4000; i++) {
      g.fillStyle = r() < 0.5 ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.06)';
      g.fillRect(r() * 256, r() * 256, 1.5, 1.5);
    }
    g.strokeStyle = 'rgba(0,0,0,0.08)';
    for (let i = 0; i <= 256; i += 128) {
      g.beginPath();
      g.moveTo(i, 0);
      g.lineTo(i, 256);
      g.moveTo(0, i);
      g.lineTo(256, i);
      g.stroke();
    }
  } else if (kind === 'grass') {
    g.fillStyle = '#86c96e';
    g.fillRect(0, 0, 256, 256);
    for (let i = 0; i < 1500; i++) {
      g.fillStyle = r() < 0.5 ? 'rgba(255,255,255,0.07)' : 'rgba(0,70,0,0.09)';
      g.fillRect(r() * 256, r() * 256, 2, 4);
    }
  } else {
    // tiles (vinyl / marble)
    const marble = kind === 'marble';
    const t1 = marble ? new THREE.Color(0xf5f5f4) : new THREE.Color(0xf8fafc).lerp(b, 0.12);
    const t2 = marble ? new THREE.Color(0xd6d3d1) : new THREE.Color(0xe2e8f0).lerp(b, 0.18);
    for (let y = 0; y < 4; y++) for (let x = 0; x < 4; x++) {
      g.fillStyle = '#' + ((x + y) % 2 ? t1 : t2).getHexString();
      g.fillRect(x * 64, y * 64, 64, 64);
    }
    g.strokeStyle = 'rgba(0,0,0,0.12)';
    g.lineWidth = 2;
    for (let i = 0; i <= 256; i += 64) {
      g.beginPath();
      g.moveTo(i, 0);
      g.lineTo(i, 256);
      g.moveTo(0, i);
      g.lineTo(256, i);
      g.stroke();
    }
    if (marble) {
      g.strokeStyle = 'rgba(120,113,108,0.15)';
      for (let i = 0; i < 20; i++) {
        g.beginPath();
        g.moveTo(r() * 256, r() * 256);
        g.bezierCurveTo(r() * 256, r() * 256, r() * 256, r() * 256, r() * 256, r() * 256);
        g.stroke();
      }
    }
  }
  const t = new THREE.CanvasTexture(c);
  t.wrapS = t.wrapT = THREE.RepeatWrapping;
  t.colorSpace = THREE.SRGBColorSpace;
  t.anisotropy = 8;
  return t;
}

function floorKind(buildingId, items) {
  if (buildingId === 'park') return 'grass';
  if (buildingId === 'courthouse' || buildingId === 'bank' || buildingId === 'university') return 'marble';
  if (['apartment_block', 'corner_cafe', 'library', 'whitmore_lane', 'civic_legal', 'cinema'].includes(buildingId)) return 'wood';
  if (items.some((i) => i.type === 'workStation' && /desk|review|standup|ledger|audit|report|meeting|strategy|manager|complaints|office|client/.test(i.arg || ''))) return 'carpet';
  if (['employment_center', 'company_registry', 'meridian_group', 'harbor_retail', 'pixelforge', 'nimbus_cloud', 'ledger_co', 'ironclad_audit'].includes(buildingId)) return 'carpet';
  return 'tile';
}

// ------------------------------------------------------------ furniture helpers

const WOOD = 0xb07a4f;
const DARKWOOD = 0x6b4226;
const METAL = 0x9ca3af;
const WHITE = 0xf8fafc;

function chair(color = 0x334155, back = true) {
  const g = new THREE.Group();
  const m = mat(color, { r: 0.6 });
  g.add(at(rbox(0.36, 0.06, 0.34, 0.02, m), 0, 0.3, 0));
  if (back) g.add(at(rbox(0.36, 0.34, 0.05, 0.02, m), 0, 0.5, -0.15));
  g.add(at(cyl(0.025, 0.025, 0.28, mat(METAL, { m: 0.6 }), 6), 0, 0.15, 0));
  g.add(at(cyl(0.16, 0.16, 0.03, mat(0x1f2937), 10), 0, 0.02, 0));
  return g;
}

function desk(w = 0.95, d = 0.55, color = WOOD) {
  const g = new THREE.Group();
  const m = mat(color, { r: 0.6 });
  g.add(at(rbox(w, 0.05, d, 0.015, m), 0, 0.5, 0));
  const lm = mat(shade(color, -0.3), { r: 0.6 });
  for (const sx of [-1, 1]) g.add(at(box(0.05, 0.5, d - 0.06, lm), sx * (w / 2 - 0.05), 0.25, 0));
  return g;
}

function screenMat(kind = 'code') {
  const c = document.createElement('canvas');
  c.width = 128;
  c.height = 80;
  const g = c.getContext('2d');
  const r = rng('scr' + kind);
  if (kind === 'ecg') {
    g.fillStyle = '#04120a';
    g.fillRect(0, 0, 128, 80);
    g.strokeStyle = '#22c55e';
    g.lineWidth = 2;
    g.beginPath();
    for (let x = 0; x < 128; x += 2) {
      const p = x % 40;
      const y = p === 20 ? 10 : p === 22 ? 62 : p === 24 ? 34 : 40 + Math.sin(x * 0.3) * 2;
      x ? g.lineTo(x, y) : g.moveTo(x, y);
    }
    g.stroke();
    g.fillStyle = '#22c55e';
    g.font = 'bold 12px monospace';
    g.fillText('HR 78  SpO2 97%', 6, 74);
  } else if (kind === 'code') {
    g.fillStyle = '#0f172a';
    g.fillRect(0, 0, 128, 80);
    const cols = ['#38bdf8', '#a78bfa', '#f472b6', '#4ade80', '#facc15', '#e2e8f0'];
    for (let y = 6; y < 80; y += 7) {
      let x = 6 + Math.floor(r() * 3) * 8;
      while (x < 120 && r() < 0.85) {
        const w = 8 + r() * 26;
        g.fillStyle = cols[Math.floor(r() * cols.length)];
        g.fillRect(x, y, w, 3);
        x += w + 4;
      }
    }
  } else if (kind === 'chart') {
    g.fillStyle = '#f8fafc';
    g.fillRect(0, 0, 128, 80);
    const cols = ['#3b82f6', '#22c55e', '#f97316', '#a855f7'];
    for (let i = 0; i < 8; i++) {
      const hgt = 10 + r() * 55;
      g.fillStyle = cols[i % 4];
      g.fillRect(10 + i * 14, 72 - hgt, 10, hgt);
    }
  } else if (kind === 'kanban') {
    g.fillStyle = '#f1f5f9';
    g.fillRect(0, 0, 128, 80);
    const cols = ['#fde68a', '#bfdbfe', '#bbf7d0', '#fbcfe8'];
    for (let c2 = 0; c2 < 4; c2++) {
      g.fillStyle = '#cbd5e1';
      g.fillRect(4 + c2 * 31, 4, 28, 6);
      for (let i = 0; i < 2 + Math.floor(r() * 4); i++) {
        g.fillStyle = cols[c2];
        g.fillRect(6 + c2 * 31, 14 + i * 14, 24, 11);
      }
    }
  } else if (kind === 'jobs') {
    g.fillStyle = '#1e3a8a';
    g.fillRect(0, 0, 128, 80);
    g.fillStyle = '#fff';
    g.font = 'bold 11px sans-serif';
    g.fillText('OPEN ROLES', 8, 14);
    g.font = '9px sans-serif';
    ['Junior Developer', 'Staff Nurse', 'Paralegal', 'Accountant', 'Ops Manager'].forEach((s, i) => g.fillText('• ' + s, 8, 28 + i * 11));
  } else {
    g.fillStyle = '#1e293b';
    g.fillRect(0, 0, 128, 80);
    g.fillStyle = '#38bdf8';
    g.fillRect(8, 8, 112, 10);
    g.fillStyle = '#94a3b8';
    for (let y = 26; y < 76; y += 10) g.fillRect(8, y, 60 + r() * 50, 4);
  }
  const t = new THREE.CanvasTexture(c);
  t.colorSpace = THREE.SRGBColorSpace;
  const m = new THREE.MeshStandardMaterial({ map: t, emissive: 0xffffff, emissiveMap: t, emissiveIntensity: 0.65, roughness: 0.3 });
  return m;
}

function monitor(kind = 'code', w = 0.42) {
  const g = new THREE.Group();
  g.add(at(rbox(w, w * 0.62, 0.03, 0.01, mat(0x111827)), 0, 0.36, 0));
  g.add(at(plane(w - 0.04, w * 0.62 - 0.04, screenMat(kind)), 0, 0.36, 0.016));
  g.add(at(box(0.04, 0.16, 0.04, mat(0x374151)), 0, 0.12, -0.02));
  g.add(at(box(0.16, 0.02, 0.12, mat(0x374151)), 0, 0.01, -0.02));
  return g;
}

function computerDesk(kind = 'code', dual = false, chairColor = 0x334155) {
  const g = desk(1.0, 0.55);
  if (dual) {
    g.add(at(monitor(kind, 0.36), -0.2, 0.52, -0.1).rotateY(0.15));
    g.add(at(monitor('chart', 0.36), 0.2, 0.52, -0.1).rotateY(-0.15));
  } else g.add(at(monitor(kind), 0, 0.52, -0.1));
  g.add(at(box(0.36, 0.02, 0.12, mat(0x1f2937)), 0, 0.535, 0.12));
  g.add(at(box(0.06, 0.02, 0.09, mat(0x1f2937)), 0.28, 0.535, 0.12));
  g.add(at(cyl(0.04, 0.035, 0.09, mat(0xf97316), 10), -0.38, 0.57, 0.1));
  const c = chair(chairColor);
  c.position.set(0, 0, 0.5);
  c.rotation.y = Math.PI;
  g.add(c);
  g.userData.anchor = { x: 0, z: 0.5, ry: Math.PI, pose: 'sit' };
  return g;
}

function bookshelf(w = 0.95, hgt = 1.7, r = rng('books')) {
  const g = new THREE.Group();
  const m = mat(DARKWOOD, { r: 0.7 });
  g.add(at(box(w, hgt, 0.04, m), 0, hgt / 2, -0.17));
  for (const sx of [-1, 1]) g.add(at(box(0.04, hgt, 0.36, m), sx * (w / 2 - 0.02), hgt / 2, 0));
  const shelves = 5;
  const cols = [0xef4444, 0x3b82f6, 0x22c55e, 0xeab308, 0x8b5cf6, 0xf97316, 0x0ea5e9, 0x1f2937, 0xf8fafc];
  for (let s = 0; s < shelves; s++) {
    const y = 0.04 + (s * (hgt - 0.08)) / shelves;
    g.add(at(box(w - 0.06, 0.03, 0.34, m), 0, y, 0));
    let x = -w / 2 + 0.06;
    while (x < w / 2 - 0.08) {
      const bw = 0.035 + r() * 0.04;
      const bh = 0.18 + r() * 0.1;
      const b = at(box(bw, bh, 0.24, mat(cols[Math.floor(r() * cols.length)], { r: 0.8 })), x + bw / 2, y + bh / 2 + 0.015, 0);
      if (r() < 0.08) b.rotation.z = 0.25;
      g.add(b);
      x += bw + 0.004;
    }
  }
  g.add(at(box(w, 0.04, 0.36, m), 0, hgt, 0));
  return g;
}

function sofa(color = 0x6366f1, w = 1.2) {
  const g = new THREE.Group();
  const m = mat(color, { r: 0.95 });
  g.add(at(rbox(w, 0.24, 0.6, 0.06, m), 0, 0.2, 0));
  g.add(at(rbox(w, 0.42, 0.16, 0.06, m), 0, 0.38, -0.24));
  for (const sx of [-1, 1]) g.add(at(rbox(0.14, 0.3, 0.6, 0.05, m), sx * (w / 2 - 0.07), 0.3, 0));
  for (const sx of [-0.28, 0.28]) g.add(at(rbox(w / 2 - 0.16, 0.08, 0.44, 0.04, mat(shade(color, 0.15), { r: 0.95 })), sx * (w / 1.2), 0.35, 0.04));
  g.add(at(rbox(0.24, 0.22, 0.08, 0.04, mat(0xfacc15)), -w / 2 + 0.3, 0.5, -0.12).rotateZ(0.2));
  g.userData.anchor = { x: 0, z: 0.05, ry: 0, pose: 'sit' };
  return g;
}

function counter(w = 1.6, color = 0x7c2d12, top = 0xf5f5f4) {
  const g = new THREE.Group();
  g.add(at(rbox(w, 0.62, 0.5, 0.03, mat(color, { r: 0.7 })), 0, 0.31, 0));
  g.add(at(rbox(w + 0.06, 0.05, 0.56, 0.02, mat(top, { r: 0.3 })), 0, 0.645, 0));
  return g;
}

function plant(r, s = 1) {
  const g = new THREE.Group();
  g.add(at(cyl(0.13 * s, 0.1 * s, 0.24 * s, mat(0xd6d3d1), 12), 0, 0.12 * s, 0));
  for (let i = 0; i < 6; i++) {
    const leaf = at(new THREE.Mesh(new THREE.IcosahedronGeometry(0.11 * s, 0), mat(i % 2 ? 0x16a34a : 0x22c55e, { flat: true })), (r() - 0.5) * 0.18 * s, 0.32 * s + r() * 0.25 * s, (r() - 0.5) * 0.18 * s);
    leaf.scale.set(1, 1.6, 0.6);
    leaf.rotation.set(r(), r() * 3, r());
    leaf.castShadow = true;
    g.add(leaf);
  }
  return g;
}

function hospitalBed(withPatient, r) {
  const g = new THREE.Group();
  const fm = mat(0xcbd5e1, { r: 0.4, m: 0.5 });
  g.add(at(box(0.62, 0.06, 1.15, fm), 0, 0.32, 0));
  for (const sx of [-0.28, 0.28]) for (const sz of [-0.52, 0.52]) g.add(at(cyl(0.02, 0.02, 0.32, fm, 6), sx, 0.16, sz));
  g.add(at(rbox(0.58, 0.12, 1.1, 0.04, mat(WHITE, { r: 0.9 })), 0, 0.41, 0));
  const back = at(rbox(0.58, 0.1, 0.4, 0.04, mat(WHITE, { r: 0.9 })), 0, 0.53, -0.38);
  back.rotation.x = 0.55;
  g.add(back);
  g.add(at(rbox(0.6, 0.07, 0.6, 0.03, mat(0x93c5fd, { r: 0.95 })), 0, 0.48, 0.22));
  g.add(at(box(0.62, 0.32, 0.04, fm), 0, 0.52, -0.58));
  g.add(at(box(0.62, 0.22, 0.04, fm), 0, 0.46, 0.58));
  // IV pole + monitor
  const pole = at(new THREE.Group(), 0.45, 0, -0.45);
  pole.add(at(cyl(0.015, 0.015, 1.4, fm, 6), 0, 0.7, 0));
  pole.add(at(rbox(0.12, 0.18, 0.05, 0.02, mat(0xe0f2fe, { t: 0.7 })), 0, 1.25, 0.03));
  g.add(pole);
  const mon = at(new THREE.Group(), -0.48, 0, -0.5);
  mon.add(at(cyl(0.02, 0.02, 1.0, fm, 6), 0, 0.5, 0));
  const mg = at(monitor('ecg', 0.32), 0, 0.72, 0.02);
  mg.rotation.y = 0.5;
  mon.add(mg);
  g.add(mon);
  if (withPatient) {
    const p = makeCharacter({ skin: [0xffffdfc4, 0xffc68642, 0xff8d5524, 0xffe0ac69][Math.floor(r() * 4)], hair: 0xff2c1810, outfit: 0xffa7c7e7, uniform: 'gown', hairStyle: ['short', 'bun', 'curly', 'bald'][Math.floor(r() * 4)], feminine: r() < 0.5 });
    p.update(0, { action: 'sleep', seated: true, emotion: 'tired' });
    p.root.position.set(0, 0.06, 0.15);
    p.root.children[1].visible = false;
    p.root.userData.dynamic = true;
    g.add(p.root);
    g.userData.patient = p;
  }
  return g;
}

function bed(color = 0x6366f1) {
  const g = new THREE.Group();
  const wm = mat(WOOD, { r: 0.7 });
  g.add(at(box(0.8, 0.22, 1.2, wm), 0, 0.12, 0));
  g.add(at(rbox(0.76, 0.14, 1.12, 0.05, mat(WHITE, { r: 0.95 })), 0, 0.3, 0));
  g.add(at(rbox(0.78, 0.06, 0.75, 0.03, mat(color, { r: 0.95 })), 0, 0.38, 0.2));
  g.add(at(rbox(0.5, 0.1, 0.22, 0.05, mat(WHITE, { r: 0.95 })), 0, 0.42, -0.42));
  g.add(at(box(0.84, 0.6, 0.06, wm), 0, 0.3, -0.6));
  g.userData.anchor = { x: 0, z: 0.0, ry: 0, pose: 'lie' };
  return g;
}

function wallBoard(text, kind, w = 1.1, h = 0.7, frame = 0x334155) {
  const g = new THREE.Group();
  g.add(at(box(w + 0.06, h + 0.06, 0.04, mat(frame)), 0, 0, 0));
  g.add(at(plane(w, h, kind ? screenMat(kind) : signMaterial(text, { bg: '#f8fafc', fg: '#0f172a' })), 0, 0, 0.025));
  return g;
}

function standingBoard(kind, label, color = 0x334155) {
  const g = new THREE.Group();
  for (const sx of [-0.45, 0.45]) g.add(at(box(0.04, 1.4, 0.04, mat(color)), sx, 0.7, 0));
  g.add(at(wallBoard(label, kind, 0.86, 0.6, color), 0, 1.05, 0.02));
  return g;
}

function corkBoard(r) {
  const g = new THREE.Group();
  for (const sx of [-0.48, 0.48]) g.add(at(box(0.05, 1.45, 0.05, mat(DARKWOOD)), sx, 0.72, 0));
  g.add(at(box(1.0, 0.75, 0.04, mat(0xc8a06a, { r: 1 })), 0, 1.05, 0));
  g.add(at(box(1.04, 0.79, 0.03, mat(DARKWOOD)), 0, 1.05, -0.02));
  const cols = [0xfef08a, 0xffffff, 0xbfdbfe, 0xfbcfe8, 0xbbf7d0];
  for (let i = 0; i < 9; i++) {
    const p = at(box(0.17, 0.2, 0.005, mat(cols[i % cols.length], { r: 1 })), -0.36 + (i % 4) * 0.24 + r() * 0.04, 1.28 - Math.floor(i / 4) * 0.25 - r() * 0.04, 0.025);
    p.rotation.z = (r() - 0.5) * 0.15;
    g.add(p);
    g.add(at(sphere(0.012, mat(0xef4444), 6), p.position.x, p.position.y + 0.08, 0.03));
  }
  const s = at(plane(0.6, 0.12, signMaterial('JOBS', { bg: '#1d4ed8', fg: '#ffffff', w: 512, h: 100 })), 0, 1.5, 0.03);
  g.add(s);
  return g;
}

function interviewSet() {
  const g = new THREE.Group();
  g.add(at(cyl(0.3, 0.3, 0.04, mat(WHITE), 20), 0, 0.48, 0));
  g.add(at(cyl(0.03, 0.03, 0.46, mat(METAL), 8), 0, 0.24, 0));
  const a = chair(0xf97316);
  a.position.set(-0.45, 0, 0);
  a.rotation.y = Math.PI / 2;
  const b = chair(0x334155);
  b.position.set(0.45, 0, 0);
  b.rotation.y = -Math.PI / 2;
  g.add(a, b);
  g.add(at(box(0.18, 0.01, 0.24, mat(WHITE)), 0.05, 0.505, 0));
  g.userData.anchor = { x: -0.45, z: 0, ry: Math.PI / 2, pose: 'sit' };
  return g;
}

function meetingTable(n = 4, color = WHITE, chairColor = 0x1f2937) {
  const g = new THREE.Group();
  g.add(at(rbox(1.3, 0.05, 0.7, 0.03, mat(color, { r: 0.4 })), 0, 0.5, 0));
  g.add(at(box(0.08, 0.48, 0.4, mat(METAL, { m: 0.5 })), 0, 0.25, 0));
  for (let i = 0; i < n; i++) {
    const side = i % 2 ? 1 : -1;
    const c = chair(chairColor);
    c.position.set(-0.35 + Math.floor(i / 2) * 0.7, 0, side * 0.5);
    c.rotation.y = side > 0 ? Math.PI : 0;
    g.add(c);
  }
  g.add(at(box(0.2, 0.01, 0.28, mat(WHITE)), -0.3, 0.53, 0.1));
  g.add(at(box(0.2, 0.01, 0.28, mat(0xfef08a)), 0.3, 0.53, -0.1));
  return g;
}

function cabinet(n = 2) {
  const g = new THREE.Group();
  for (let i = 0; i < n; i++) {
    const c = at(new THREE.Group(), -0.22 + i * 0.44, 0, 0);
    c.add(at(rbox(0.4, 1.1, 0.45, 0.02, mat(0x94a3b8, { m: 0.4, r: 0.5 })), 0, 0.55, 0));
    for (let d = 0; d < 4; d++) {
      c.add(at(box(0.36, 0.22, 0.01, mat(0xcbd5e1, { m: 0.3 })), 0, 0.17 + d * 0.26, 0.23));
      c.add(at(box(0.1, 0.02, 0.02, mat(0x475569)), 0, 0.22 + d * 0.26, 0.24));
    }
    g.add(c);
  }
  return g;
}

// ------------------------------------------------------------ registry

function furniture(item, ctx) {
  const key = item.type === 'workStation' ? (item.arg === 'desk' ? 'dev_desk' : item.arg) : item.id;
  const r = rng(ctx.buildingId + ':' + item.id);
  const accent = ctx.accent;
  switch (key) {
    // home
    case 'bed':
      return bed(0x8b5cf6);
    case 'fridge': {
      const g = new THREE.Group();
      g.add(at(rbox(0.6, 1.5, 0.55, 0.05, mat(WHITE, { r: 0.3, m: 0.1 })), 0, 0.75, -0.1));
      g.add(at(box(0.58, 0.01, 0.01, mat(0xcbd5e1)), 0, 1.0, 0.175));
      g.add(at(box(0.03, 0.3, 0.03, mat(METAL, { m: 0.8 })), 0.22, 1.2, 0.19));
      g.add(at(box(0.03, 0.4, 0.03, mat(METAL, { m: 0.8 })), 0.22, 0.65, 0.19));
      g.add(at(counter(0.7, 0xe7e5e4, 0x94a3b8), 0.7, 0, -0.1));
      g.add(at(cyl(0.12, 0.1, 0.12, mat(0x334155), 12), 0.65, 0.73, -0.1));
      return g;
    }
    case 'laptop': {
      const g = desk(0.9, 0.5);
      const lap = at(new THREE.Group(), 0, 0.53, 0);
      lap.add(at(box(0.36, 0.02, 0.24, mat(0x9ca3af, { m: 0.6 })), 0, 0, 0));
      const scr = at(new THREE.Group(), 0, 0, -0.12);
      scr.add(at(box(0.36, 0.24, 0.015, mat(0x9ca3af, { m: 0.6 })), 0, 0.12, 0));
      scr.add(at(plane(0.32, 0.2, screenMat('jobs')), 0, 0.12, 0.009));
      scr.rotation.x = -0.25;
      lap.add(scr);
      g.add(lap);
      const c = chair(0x8b5cf6);
      c.position.set(0, 0, 0.45);
      c.rotation.y = Math.PI;
      g.add(c);
      g.userData.anchor = { x: 0, z: 0.45, ry: Math.PI, pose: 'sit' };
      return g;
    }
    case 'wardrobe': {
      const g = new THREE.Group();
      g.add(at(rbox(0.9, 1.75, 0.5, 0.03, mat(0xd6b48a, { r: 0.6 })), 0, 0.875, -0.15));
      g.add(at(box(0.01, 1.6, 0.01, mat(DARKWOOD)), 0, 0.88, 0.105));
      for (const sx of [-0.07, 0.07]) g.add(at(box(0.02, 0.18, 0.03, mat(METAL, { m: 0.8 })), sx, 0.9, 0.12));
      g.add(at(box(0.3, 0.6, 0.02, mat(0xe0f2fe, { r: 0.05, m: 0.6 })), 0.6, 1.0, -0.38));
      return g;
    }
    case 'desk':
    case 'study':
      if (ctx.buildingId === 'library') return computerDesk('doc', false, 0x78350f);
      return (() => {
        const g = desk(0.95, 0.5);
        g.add(at(cyl(0.02, 0.02, 0.35, mat(0x1f2937), 6), -0.35, 0.7, -0.12));
        const shade2 = at(cone(0.1, 0.12, mat(0xfacc15, { e: 0xfacc15, ei: 0.2 }), 12), -0.3, 0.88, -0.1);
        g.add(shade2);
        for (let i = 0; i < 3; i++) g.add(at(box(0.22, 0.05, 0.3, mat([0xef4444, 0x3b82f6, 0x22c55e][i])), 0.2, 0.55 + i * 0.05, -0.05));
        g.add(at(box(0.3, 0.01, 0.22, mat(WHITE)), -0.05, 0.53, 0.08));
        const c = chair(0x0ea5e9);
        c.position.set(0, 0, 0.45);
        c.rotation.y = Math.PI;
        g.add(c);
        g.userData.anchor = { x: 0, z: 0.45, ry: Math.PI, pose: 'sit' };
        return g;
      })();
    case 'sofa':
    case 'lounge':
    case 'lobby':
      return sofa(key === 'lobby' ? 0xb91c1c : key === 'lounge' ? 0x0ea5e9 : 0x6366f1);
    case 'decor': {
      const g = new THREE.Group();
      g.add(at(plant(r, 1.4), -0.25, 0, 0));
      g.add(at(plant(r, 1.0), 0.25, 0, 0.1));
      g.add(at(cyl(0.45, 0.45, 0.01, mat(0xfbbf24, { r: 1 }), 24), 0, 0.005, 0.1));
      return g;
    }
    case 'mailbox': {
      const g = new THREE.Group();
      g.add(at(rbox(0.7, 0.55, 0.2, 0.02, mat(0x94a3b8, { m: 0.5, r: 0.4 })), 0, 1.05, -0.3));
      for (let i = 0; i < 6; i++) g.add(at(box(0.18, 0.14, 0.01, mat(0xcbd5e1, { m: 0.5 })), -0.22 + (i % 3) * 0.22, 1.15 - Math.floor(i / 3) * 0.2, -0.195));
      const t = desk(0.6, 0.35, WHITE);
      t.scale.y = 0.85;
      g.add(t);
      g.add(at(box(0.18, 0.01, 0.13, mat(0xfef3c7)), -0.1, 0.45, 0));
      g.add(at(box(0.18, 0.01, 0.13, mat(WHITE)), 0.08, 0.455, 0.03));
      return g;
    }
    // café / shops
    case 'counter':
    case 'snack':
    case 'foodcourt': {
      const g = counter(1.5, key === 'foodcourt' ? 0xdc2626 : 0x7c2d12);
      g.add(at(rbox(0.32, 0.38, 0.28, 0.03, mat(0x334155, { m: 0.5 })), -0.45, 0.86, -0.05));
      g.add(at(box(0.08, 0.08, 0.06, mat(0x111827)), -0.45, 0.78, 0.1));
      for (let i = 0; i < 3; i++) g.add(at(cyl(0.04, 0.03, 0.09, mat([0xffffff, 0xf97316, 0x22c55e][i]), 10), 0.15 + i * 0.12, 0.72, 0.05));
      const board = at(plane(1.3, 0.45, signMaterial(key === 'foodcourt' ? 'Burgers · Noodles · Salads' : key === 'snack' ? 'Popcorn · Drinks' : 'Coffee · Tea · Pastries', { bg: '#111827', fg: '#fde68a', w: 1024, h: 340 })), 0, 1.6, -0.35);
      g.add(board);
      return g;
    }
    case 'table1':
    case 'table2':
    case 'fountain_table': {
      const g = new THREE.Group();
      g.add(at(cyl(0.28, 0.28, 0.04, mat(WHITE, { r: 0.4 }), 18), 0, 0.5, 0));
      g.add(at(cyl(0.03, 0.03, 0.48, mat(0x111827), 8), 0, 0.25, 0));
      g.add(at(cyl(0.18, 0.18, 0.02, mat(0x111827), 12), 0, 0.01, 0));
      for (const a of [0, Math.PI]) {
        const c = chair(0x92400e);
        c.position.set(Math.sin(a) * 0.5, 0, Math.cos(a) * 0.5);
        c.rotation.y = a + Math.PI;
        g.add(c);
      }
      g.add(at(cyl(0.04, 0.03, 0.08, mat(WHITE), 10), 0.08, 0.56, 0));
      g.userData.anchor = { x: 0, z: 0.5, ry: Math.PI, pose: 'sit' };
      return g;
    }
    case 'clothes': {
      const g = new THREE.Group();
      g.add(at(box(1.0, 0.03, 0.03, mat(METAL, { m: 0.8 })), 0, 1.25, 0));
      for (const sx of [-0.5, 0.5]) g.add(at(box(0.03, 1.25, 0.03, mat(METAL, { m: 0.8 })), sx, 0.62, 0));
      const cols = [0x1f2937, 0x3b82f6, 0xf8fafc, 0xec4899, 0x10b981, 0xf97316, 0x2bb3a4];
      for (let i = 0; i < 7; i++) g.add(at(rbox(0.11, 0.55, 0.32, 0.03, mat(cols[i])), -0.4 + i * 0.13, 0.95, 0));
      g.add(at(cyl(0.18, 0.2, 0.05, mat(0xd6d3d1), 16), 0.8, 0.025, 0.2));
      return g;
    }
    case 'furniture':
      return (() => {
        const g = sofa(0xf59e0b, 1.1);
        g.add(at(plant(r, 1.1), 0.75, 0, -0.1));
        g.add(at(plane(0.24, 0.14, signMaterial('SALE', { bg: '#ef4444', fg: '#fff', w: 256, h: 140 })), 0, 0.75, -0.3));
        return g;
      })();
    case 'transit':
    case 'kiosk':
    case 'atm': {
      const g = new THREE.Group();
      const c2 = key === 'atm' ? 0x059669 : key === 'transit' ? 0x2563eb : 0xf97316;
      g.add(at(rbox(0.5, 1.4, 0.35, 0.05, mat(c2, { r: 0.4 })), 0, 0.7, -0.05));
      const s = at(plane(0.36, 0.28, screenMat(key === 'kiosk' ? 'jobs' : 'doc')), 0, 1.05, 0.13);
      s.rotation.x = -0.2;
      g.add(s);
      g.add(at(box(0.3, 0.04, 0.12, mat(0x1f2937)), 0, 0.78, 0.15));
      return g;
    }
    case 'shelves':
    case 'snacks':
    case 'stock_room': {
      const g = new THREE.Group();
      const sm = mat(0xe5e7eb, { m: 0.3, r: 0.5 });
      g.add(at(box(1.0, 1.4, 0.04, sm), 0, 0.7, -0.2));
      const goods = key === 'stock_room' ? [0xd6b48a, 0xc8a06a, 0xf8fafc] : key === 'snacks' ? [0xf97316, 0xef4444, 0xfacc15, 0x8b5cf6] : [0x22c55e, 0xef4444, 0xfacc15, 0xf97316, 0x84cc16];
      for (let s2 = 0; s2 < 4; s2++) {
        g.add(at(box(1.0, 0.03, 0.4, sm), 0, 0.1 + s2 * 0.38, 0));
        for (let i = 0; i < 7; i++) {
          const gm = mat(goods[(i + s2) % goods.length], { r: 0.6 });
          const it = key === 'shelves' ? at(sphere(0.06, gm, 8), -0.42 + i * 0.14, 0.18 + s2 * 0.38, 0.05) : at(box(0.11, 0.18, 0.2, gm), -0.42 + i * 0.14, 0.21 + s2 * 0.38, 0.03);
          g.add(it);
        }
      }
      return g;
    }
    case 'teller': {
      const g = counter(1.6, 0x065f46, 0xd1fae5);
      g.add(at(box(1.6, 0.6, 0.02, mat(0xe0f2fe, { r: 0.05, t: 0.35 })), 0, 0.98, 0));
      g.add(at(monitor('chart', 0.3), -0.4, 0.66, -0.12));
      return g;
    }
    case 'advice':
    case 'reporting_desk':
    case 'ledger_desk':
      return computerDesk('chart', key !== 'advice', 0x065f46);
    // university
    case 'registrar': {
      const g = counter(1.6, 0x1e3a8a, 0xf8fafc);
      g.add(at(monitor('doc', 0.3), -0.45, 0.66, -0.1));
      g.add(at(plane(0.9, 0.2, signMaterial('Registrar · Enrolment', { bg: '#1e3a8a', fg: '#fff', w: 900, h: 200 })), 0, 0.42, 0.26));
      return g;
    }
    case 'lecture': {
      const g = new THREE.Group();
      g.add(at(wallBoard('', 'doc', 1.6, 0.9), 0, 1.25, -0.3));
      g.add(at(rbox(0.4, 0.95, 0.35, 0.04, mat(DARKWOOD)), 0.9, 0.48, -0.05));
      for (let i = -1; i <= 1; i++) {
        const c = chair(0xca8a04, false);
        c.position.set(i * 0.5, 0, 0.55);
        g.add(c);
      }
      return g;
    }
    case 'exam': {
      const g = new THREE.Group();
      for (let i = 0; i < 4; i++) {
        const d = desk(0.4, 0.3, 0xd6b48a);
        d.scale.setScalar(0.95);
        d.position.set(-0.25 + (i % 2) * 0.5, 0, -0.25 + Math.floor(i / 2) * 0.5);
        d.add(at(box(0.18, 0.01, 0.24, mat(WHITE)), 0, 0.53, 0));
        g.add(d);
      }
      return g;
    }
    case 'stage':
    case 'graduation': {
      const g = new THREE.Group();
      g.add(at(rbox(1.4, 0.2, 0.9, 0.03, mat(0x7c3aed, { r: 0.8 })), 0, 0.1, -0.1));
      g.add(at(rbox(0.36, 0.7, 0.3, 0.03, mat(DARKWOOD)), 0, 0.55, -0.25));
      g.add(at(plane(1.3, 0.35, signMaterial('🎓 Graduation', { bg: '#4c1d95', fg: '#fde68a', w: 900, h: 240 })), 0, 1.35, -0.5));
      return g;
    }
    case 'shelf':
    case 'law_library':
    case 'records':
      return key === 'records' ? cabinet(2) : bookshelf();
    case 'certs': {
      const g = computerDesk('doc', false, 0x92400e);
      g.add(at(cyl(0.05, 0.07, 0.16, mat(0xfbbf24, { m: 0.8, r: 0.3 }), 10), 0.35, 0.6, -0.1));
      g.add(at(sphere(0.07, mat(0xfbbf24, { m: 0.8, r: 0.3 }), 10), 0.35, 0.74, -0.1));
      return g;
    }
    // employment
    case 'board':
      return corkBoard(r);
    case 'resume':
      return computerDesk('doc', false, 0xf97316);
    case 'practice':
      return interviewSet();
    // registry
    case 'register':
    case 'plan':
      return computerDesk('chart', false, 0x0369a1);
    // cinema / gym / park
    case 'tickets': {
      const g = new THREE.Group();
      g.add(at(rbox(1.0, 1.5, 0.6, 0.04, mat(0xb91c1c, { r: 0.6 })), 0, 0.75, -0.1));
      g.add(at(box(0.5, 0.4, 0.02, mat(0xfef3c7, { e: 0xfde68a, ei: 0.3 })), 0, 1.05, 0.21));
      g.add(at(plane(0.9, 0.22, signMaterial('TICKETS', { bg: '#fef3c7', fg: '#b91c1c', w: 600, h: 150 })), 0, 1.38, 0.205));
      return g;
    }
    case 'treadmill':
    case 'path': {
      const g = new THREE.Group();
      g.add(at(rbox(0.5, 0.12, 1.0, 0.04, mat(0x1f2937)), 0, 0.08, 0));
      g.add(at(box(0.44, 0.02, 0.9, mat(0x374151)), 0, 0.15, 0));
      for (const sx of [-0.22, 0.22]) g.add(at(box(0.04, 0.9, 0.04, mat(METAL, { m: 0.6 })), sx, 0.55, -0.42));
      g.add(at(box(0.5, 0.2, 0.08, mat(0x0d9488)), 0, 1.0, -0.42));
      return key === 'path' ? (() => {
        const p = new THREE.Group();
        p.add(at(box(0.9, 0.02, 0.9, mat(0xe7d7b8, { r: 1 })), 0, 0.01, 0));
        p.add(at(plane(0.6, 0.3, signMaterial('🏃 Jogging trail', { bg: '#365314', fg: '#ecfccb', w: 600, h: 220 })), 0, 0.85, -0.2));
        p.add(at(box(0.04, 0.85, 0.04, mat(DARKWOOD)), 0, 0.42, -0.22));
        return p;
      })() : g;
    }
    case 'weights': {
      const g = new THREE.Group();
      g.add(at(rbox(0.3, 0.08, 0.9, 0.03, mat(0x1f2937)), 0, 0.35, 0.1));
      g.add(at(box(0.05, 0.35, 0.05, mat(METAL, { m: 0.6 })), 0, 0.17, 0.1));
      for (const sx of [-0.35, 0.35]) g.add(at(box(0.04, 1.0, 0.04, mat(METAL, { m: 0.6 })), sx, 0.5, -0.3));
      const bar = at(cyl(0.02, 0.02, 1.0, mat(METAL, { m: 0.8 }), 8), 0, 0.85, -0.3);
      bar.rotation.z = Math.PI / 2;
      g.add(bar);
      for (const sx of [-0.42, 0.42]) {
        const p = at(cyl(0.16, 0.16, 0.05, mat(0x111827), 16), sx, 0.85, -0.3);
        p.rotation.z = Math.PI / 2;
        g.add(p);
      }
      return g;
    }
    case 'locker': {
      const g = new THREE.Group();
      for (let i = 0; i < 3; i++) {
        g.add(at(rbox(0.3, 1.6, 0.4, 0.02, mat([0x0d9488, 0x14b8a6, 0x0f766e][i], { m: 0.3, r: 0.5 })), -0.32 + i * 0.32, 0.8, -0.15));
        for (let v = 0; v < 4; v++) g.add(at(box(0.18, 0.015, 0.01, mat(0x134e4a)), -0.32 + i * 0.32, 1.4 - v * 0.04, 0.055));
      }
      return g;
    }
    case 'fountain': {
      const g = new THREE.Group();
      g.add(at(cyl(0.55, 0.6, 0.25, mat(0xd6d3d1), 20), 0, 0.12, 0));
      g.add(at(cyl(0.5, 0.5, 0.04, mat(0x38bdf8, { r: 0.1, t: 0.85 }), 20), 0, 0.23, 0));
      g.add(at(cyl(0.07, 0.1, 0.5, mat(0xd6d3d1), 10), 0, 0.45, 0));
      g.add(at(sphere(0.1, mat(0x7dd3fc, { t: 0.7, e: 0x38bdf8, ei: 0.3 }), 10), 0, 0.75, 0));
      return g;
    }
    case 'gallery': {
      const g = new THREE.Group();
      for (let i = 0; i < 2; i++) g.add(at(bench(DARKWOOD), 0, 0, -0.25 + i * 0.5));
      g.children.forEach((c) => c.scale.set(1.5, 1, 1));
      return g;
    }
    // workplaces
    case 'reception': {
      const g = counter(1.3, accent, 0xf8fafc);
      g.add(at(sphere(0.05, mat(0xfbbf24, { m: 0.8, r: 0.3 }), 10), 0.4, 0.7, 0.1));
      g.add(at(monitor('doc', 0.28), -0.3, 0.66, -0.1));
      g.add(at(plane(0.8, 0.18, signMaterial('Reception · Clock in', { bg: '#0f172a', fg: '#fff', w: 800, h: 180 })), 0, 0.4, 0.26));
      return g;
    }
    case 'hr':
    case 'manager':
    case 'manager_desk':
    case 'office_desk':
    case 'counselling_desk':
    case 'complaints_desk': {
      const g = computerDesk(key === 'complaints_desk' ? 'doc' : 'chart', false, 0x1f2937);
      const v = chair(accent);
      v.position.set(0, 0, -0.55);
      g.add(v);
      g.add(at(box(0.2, 0.06, 0.04, mat(0xfbbf24, { m: 0.7 })), 0.32, 0.56, 0.18));
      if (key === 'complaints_desk') g.add(at(torus(0.06, 0.01, mat(0x111827), Math.PI), 0.3, 0.6, 0.0));
      g.add(at(plant(r, 0.9), 0.62, 0, -0.2));
      return g;
    }
    case 'break': {
      const g = counter(1.0, 0x78716c, 0xf5f5f4);
      g.add(at(rbox(0.3, 0.38, 0.28, 0.03, mat(0x334155, { m: 0.5 })), -0.25, 0.86, -0.05));
      g.add(at(cyl(0.04, 0.03, 0.09, mat(WHITE), 10), 0.2, 0.72, 0.05));
      g.add(at(cyl(0.04, 0.03, 0.09, mat(0xef4444), 10), 0.32, 0.72, 0.0));
      return g;
    }
    case 'clinic':
    case 'consult_room': {
      const g = new THREE.Group();
      g.add(at(rbox(0.55, 0.12, 1.0, 0.04, mat(0x93c5fd, { r: 0.6 })), -0.15, 0.55, 0));
      g.add(at(box(0.5, 0.5, 0.9, mat(WHITE)), -0.15, 0.25, 0));
      g.add(at(box(0.5, 0.02, 0.5, mat(0xffffff, { r: 1 })), -0.15, 0.62, 0.15));
      // curtain
      const cm = mat(0x5eead4, { r: 1, t: 0.85 });
      g.add(at(box(0.02, 1.3, 1.0, cm), 0.35, 0.95, 0));
      g.add(at(box(0.02, 0.02, 1.1, mat(METAL)), 0.35, 1.62, 0));
      if (key === 'consult_room') {
        const d = desk(0.6, 0.4, WHITE);
        d.position.set(0.0, 0, -0.6);
        g.add(d);
        g.add(at(monitor('doc', 0.28), 0, 0.52, -0.62));
      }
      return g;
    }
    case 'standup':
      return (() => {
        const g = new THREE.Group();
        g.add(at(cyl(0.28, 0.28, 0.04, mat(WHITE), 18), 0, 0.95, 0.15));
        g.add(at(cyl(0.04, 0.04, 0.93, mat(METAL), 8), 0, 0.47, 0.15));
        g.add(at(standingBoard('kanban', '', 0x334155), 0, 0, -0.3));
        return g;
      })();
    case 'dev_desk':
      return computerDesk('code', true);
    case 'review':
      return (() => {
        const g = new THREE.Group();
        g.add(at(wallBoard('', 'code', 1.4, 0.8, 0x111827), 0, 1.2, -0.35));
        g.add(at(box(0.04, 1.2, 0.04, mat(0x111827)), 0, 0.6, -0.4));
        g.add(at(sofa(0x475569, 1.0), 0, 0, 0.35).rotateY(Math.PI));
        return g;
      })();
    case 'bedside':
    case 'ward_round':
      return hospitalBed(true, r);
    case 'emergency_bay': {
      const g = hospitalBed(true, r);
      const light = at(sphere(0.07, new THREE.MeshStandardMaterial({ color: 0xef4444, emissive: 0xef4444, emissiveIntensity: 1 }), 10), 0, 1.7, -0.58);
      light.userData.dynamic = true;
      g.add(light);
      g.userData.alarm = light;
      return g;
    }
    case 'nurse_station': {
      const g = counter(1.6, 0x0f766e, 0xf0fdfa);
      g.add(at(monitor('ecg', 0.3), -0.45, 0.66, -0.1));
      g.add(at(monitor('doc', 0.3), 0.15, 0.66, -0.1));
      g.add(at(box(0.22, 0.03, 0.3, mat(0x60a5fa)), 0.55, 0.69, 0.05));
      g.add(at(plane(1.0, 0.2, signMaterial("Nurses' Station", { bg: '#0f766e', fg: '#fff', w: 900, h: 180 })), 0, 0.42, 0.26));
      return g;
    }
    case 'med_cart':
    case 'dispensing_bench': {
      const g = new THREE.Group();
      const w = key === 'med_cart' ? 0.6 : 1.2;
      g.add(at(rbox(w, 0.8, 0.45, 0.03, mat(0xe2e8f0, { m: 0.2 })), 0, 0.45, 0));
      for (let d = 0; d < 4; d++) g.add(at(box(w - 0.06, 0.16, 0.01, mat([0xef4444, 0x3b82f6, 0x22c55e, 0xfacc15][d])), 0, 0.2 + d * 0.18, 0.23));
      if (key === 'med_cart') for (const sx of [-0.24, 0.24]) for (const sz of [-0.18, 0.18]) g.add(at(sphere(0.04, mat(0x111827), 8), sx, 0.04, sz));
      for (let i = 0; i < 6; i++) g.add(at(cyl(0.035, 0.035, 0.1, mat([0xf97316, 0xf8fafc, 0x93c5fd][i % 3], { r: 0.4 }), 10), -w / 2 + 0.1 + i * ((w - 0.2) / 5), 0.91, 0));
      return g;
    }
    case 'lab_terminal': {
      const g = computerDesk('chart', false, 0x0369a1);
      const mic = at(new THREE.Group(), 0.35, 0.53, 0);
      mic.add(at(box(0.14, 0.03, 0.14, mat(0x111827)), 0, 0.015, 0));
      mic.add(at(box(0.04, 0.22, 0.04, mat(WHITE)), 0, 0.12, -0.04));
      const tube = at(cyl(0.025, 0.025, 0.14, mat(0x111827), 8), 0, 0.22, 0.01);
      tube.rotation.x = 0.4;
      mic.add(tube);
      g.add(mic);
      return g;
    }
    case 'client_room':
    case 'meeting_room':
    case 'strategy_room':
    case 'audit_room': {
      const g = meetingTable(4, key === 'client_room' ? DARKWOOD : WHITE);
      if (key === 'strategy_room' || key === 'meeting_room') g.add(at(standingBoard(key === 'strategy_room' ? 'kanban' : 'chart', '', 0x334155), 0, 0, -0.75));
      if (key === 'audit_room') for (let i = 0; i < 4; i++) g.add(at(box(0.25, 0.08 + i * 0.03, 0.3, mat(0xfef3c7)), -0.45 + i * 0.3, 0.55 + (0.08 + i * 0.03) / 2, 0));
      return g;
    }
    case 'courtroom': {
      const g = new THREE.Group();
      g.add(at(rbox(1.5, 0.95, 0.5, 0.03, mat(DARKWOOD, { r: 0.5 })), 0, 0.48, -0.15));
      g.add(at(rbox(1.0, 0.25, 0.5, 0.03, mat(DARKWOOD, { r: 0.5 })), 0, 1.07, -0.2));
      g.add(at(plane(0.4, 0.4, signMaterial('⚖️', { bg: '#78350f', fg: '#fde68a', w: 256, h: 256 })), 0, 1.55, -0.42));
      g.add(at(cyl(0.02, 0.02, 1.8, mat(0x9ca3af), 6), 0.85, 0.9, -0.3));
      g.add(at(box(0.4, 0.26, 0.01, mat(0x2563eb)), 1.06, 1.6, -0.3));
      return g;
    }
  }
  // fallbacks by action type
  switch (item.type) {
    case 'shop':
      return counter(1.2, accent);
    case 'socialize':
    case 'relaxPark':
      return ctx.buildingId === 'park' ? bench() : sofa(accent);
    case 'bank':
      return counter(1.2, 0x065f46);
    case 'workStation':
      return computerDesk('doc');
    case 'studyDesk':
    case 'studyHome':
      return computerDesk('doc', false, 0x0ea5e9);
  }
  const g = desk(0.8, 0.5);
  g.add(at(box(0.3, 0.2, 0.2, mat(accent)), 0, 0.62, 0));
  return g;
}

// ------------------------------------------------------------ room

export function buildRoom(data) {
  const group = new THREE.Group();
  const { w, h, exitX, exitY, buildingId } = data;
  const items = data.items || [];
  const accent = col(data.accent ?? data.wall ?? 0x94a3b8);
  const wallBase = col(data.wall ?? 0x94a3b8).lerp(new THREE.Color(0xffffff), 0.72);
  const outdoor = buildingId === 'park';
  const kind = floorKind(buildingId, items);

  // floor
  const ft = floorTexture(kind, data.floor ?? 0xe5e7eb);
  ft.repeat.set(w / 2, h / 2);
  const floor = new THREE.Mesh(new THREE.PlaneGeometry(w, h), new THREE.MeshStandardMaterial({ map: ft, roughness: kind === 'marble' || kind === 'tile' ? 0.35 : 0.9 }));
  floor.rotation.x = -Math.PI / 2;
  floor.position.set((w - 1) / 2, 0, (h - 1) / 2);
  floor.receiveShadow = true;
  floor.userData.pick = { kind: 'ground' };
  group.add(floor);
  // floor base slab (gives the cutaway "diorama" look)
  const slab = new THREE.Mesh(new THREE.BoxGeometry(w + 0.3, 0.3, h + 0.3), mat(outdoor ? 0x6b4f2a : 0x475569, { r: 0.9 }));
  slab.position.set((w - 1) / 2, -0.151, (h - 1) / 2);
  slab.receiveShadow = true;
  group.add(slab);

  // walls
  const walls = [];
  function wall(len, x, z, ry, inward, withWindows) {
    const wg = new THREE.Group();
    const wm = mat(outdoor ? 0x3f7f2f : wallBase, { r: 0.92 });
    if (outdoor) {
      const hedge = rbox(len, 0.7, 0.35, 0.12, mat(0x3f7f2f, { r: 0.95, flat: true }));
      hedge.position.y = 0.35;
      wg.add(hedge);
    } else {
      const body = box(len, WALL_H, 0.12, wm);
      body.position.y = WALL_H / 2;
      wg.add(body);
      const wain = box(len, 0.7, 0.14, mat(shade(accent, 0.25), { r: 0.8 }));
      wain.position.y = 0.35;
      wg.add(wain);
      const trim = box(len, 0.05, 0.16, mat(shade(accent, -0.1), { r: 0.6 }));
      trim.position.y = 0.72;
      wg.add(trim);
      const top = box(len, 0.08, 0.16, mat(shade(accent, -0.2)));
      top.position.y = WALL_H;
      wg.add(top);
      if (withWindows) {
        const gm = new THREE.MeshStandardMaterial({ color: 0xbfe3ff, emissive: 0x9fd6ff, emissiveIntensity: 0.35, roughness: 0.05, metalness: 0.2 });
        for (let i = 1; i < len - 0.5; i += 2.4) {
          const win = new THREE.Mesh(new THREE.PlaneGeometry(1.2, 0.85), gm);
          win.position.set(-len / 2 + i + 0.6, 1.3, 0.065);
          wg.add(win);
          const fr = box(1.3, 0.06, 0.08, mat(WHITE));
          fr.position.set(-len / 2 + i + 0.6, 0.86, 0.08);
          wg.add(fr);
          const mull = box(0.04, 0.85, 0.07, mat(WHITE));
          mull.position.set(-len / 2 + i + 0.6, 1.3, 0.075);
          wg.add(mull);
        }
      }
    }
    wg.position.set(x, 0, z);
    wg.rotation.y = ry;
    wg.userData.inward = inward;
    wg.userData.dynamic = true;
    wg.userData.cut = 0;
    group.add(wg);
    walls.push(wg);
    wg.traverse((o) => {
      if (o.isMesh) {
        o.castShadow = true;
        o.receiveShadow = true;
      }
    });
    return wg;
  }
  const cx = (w - 1) / 2;
  const cz = (h - 1) / 2;
  wall(w + 0.12, cx, -0.56, 0, new THREE.Vector3(0, 0, 1), true);
  wall(h + 0.12, -0.56, cz, Math.PI / 2, new THREE.Vector3(1, 0, 0), false);
  wall(h + 0.12, w - 0.44, cz, -Math.PI / 2, new THREE.Vector3(-1, 0, 0), true);
  // front wall in two pieces around the exit
  const lA = -0.56;
  const lB = exitX - 0.6;
  const rA = exitX + 0.6;
  const rB = w - 0.44;
  wall(lB - lA, (lA + lB) / 2, h - 0.44, Math.PI, new THREE.Vector3(0, 0, -1), false);
  wall(rB - rA, (rA + rB) / 2, h - 0.44, Math.PI, new THREE.Vector3(0, 0, -1), false);

  // wall decor on the back wall: name sign + clock + art
  if (!outdoor) {
    const sm = signMaterial(data.name || '', { bg: hex(accent), fg: '#ffffff', emoji: data.emoji || '', w: 1024, h: 160 });
    const s = at(plane(Math.min(3.6, w * 0.32), 0.42, sm), cx, 1.82, -0.49);
    group.add(s);
    const clock = at(new THREE.Group(), w - 1.8, 1.75, -0.49);
    clock.add(at(cyl(0.18, 0.18, 0.04, mat(WHITE), 24), 0, 0, 0).rotateX(Math.PI / 2));
    clock.add(at(box(0.015, 0.12, 0.01, mat(0x111827)), 0, 0.05, 0.03));
    clock.add(at(box(0.09, 0.015, 0.01, mat(0x111827)), 0.04, 0, 0.03));
    group.add(clock);
  } else {
    const r = rng('park-room');
    for (let i = 0; i < 10; i++) {
      const side = i % 3;
      const t2 = tree(r, 1.4 + r());
      if (side === 0) t2.position.set(r() * w, 0, -1.3);
      else if (side === 1) t2.position.set(-1.3, 0, r() * h);
      else t2.position.set(w + 0.3, 0, r() * h);
      group.add(t2);
    }
  }

  if (!outdoor) decorate(group, data, accent, w, h, items);

  // rug in the middle
  if (!outdoor && kind !== 'carpet') {
    const rug = new THREE.Mesh(new THREE.PlaneGeometry(3.2, 2.0), mat(shade(accent, 0.15), { r: 1 }));
    rug.rotation.x = -Math.PI / 2;
    rug.position.set(cx, 0.008, cz + 0.6);
    rug.receiveShadow = true;
    group.add(rug);
  }

  // exit doormat + door
  const exit = new THREE.Group();
  const mm = new THREE.Mesh(new THREE.PlaneGeometry(0.9, 0.7), new THREE.MeshStandardMaterial({ color: 0x334155, roughness: 1 }));
  mm.rotation.x = -Math.PI / 2;
  mm.position.y = 0.01;
  exit.add(mm);
  const ringM = new THREE.MeshBasicMaterial({ color: 0x38bdf8, transparent: true, opacity: 0.8, depthWrite: false });
  const ring = new THREE.Mesh(new THREE.RingGeometry(0.3, 0.38, 32), ringM);
  ring.rotation.x = -Math.PI / 2;
  ring.position.y = 0.02;
  exit.add(ring);
  const exitLabel = labelSprite('Exit to city', { emoji: '🚪', worldH: 0.24 });
  exitLabel.position.y = 0.9;
  exit.add(exitLabel);
  exit.position.set(exitX, 0, exitY);
  exit.traverse((o) => (o.userData.pick = { kind: 'exit' }));
  group.add(exit);

  // furniture
  const ctx = { buildingId, accent };
  const itemObjs = new Map();
  for (const it of items) {
    const f = furniture(it, ctx);
    f.position.set(it.x, 0, it.y);
    // face into the room
    if (it.x <= 0) f.rotation.y = Math.PI / 2;
    else if (it.x >= w - 1) f.rotation.y = -Math.PI / 2;
    f.traverse((o) => {
      if (o.isMesh) {
        o.castShadow = true;
        o.receiveShadow = true;
      }
      if (!o.userData.pick) o.userData.pick = { kind: 'item', id: it.id };
    });
    mergeStatic(f);
    group.add(f);
    // highlight ring + label
    const hr = new THREE.Mesh(new THREE.RingGeometry(0.46, 0.54, 36), new THREE.MeshBasicMaterial({ color: 0xfacc15, transparent: true, opacity: 0, depthWrite: false }));
    hr.rotation.x = -Math.PI / 2;
    hr.position.set(it.x, 0.015, it.y);
    group.add(hr);
    const lab = labelSprite(it.name, { emoji: it.emoji, worldH: 0.26, sub: it.hint ? (it.hint.length > 38 ? it.hint.slice(0, 36) + '…' : it.hint) : '' });
    lab.position.set(it.x, 1.75, it.y);
    lab.visible = false;
    group.add(lab);
    f.userData.dynamic = true;
    hr.userData.dynamic = true;
    itemObjs.set(it.id, { obj: f, ring: hr, label: lab, data: it });
  }

  // NPCs
  const npcs = new Map();
  for (const n of data.npcs || []) {
    const look = { ...n.look, uniform: n.look?.uniform || uniformForRole(n.role) };
    const ch = makeCharacter(look, { name: n.name, role: n.role });
    ch.root.position.set(n.x, 0, n.y);
    ch.root.traverse((o) => (o.userData.pick = { kind: 'npc', id: n.id }));
    ch.root.userData.dynamic = true;
    group.add(ch.root);
    npcs.set(n.id, { ch, data: n, x: n.x, y: n.y, tx: n.x, ty: n.y, face: 0 });
  }

  exit.userData.dynamic = true;
  mergeStatic(group);

  // interior lights
  const lights = [];
  for (const [x, z] of [[w * 0.25, h * 0.4], [w * 0.75, h * 0.4]]) {
    const L = new THREE.PointLight(0xfff1d6, outdoor ? 0 : 3.2, 9, 1.4);
    L.position.set(x, 2.6, z);
    group.add(L);
    lights.push(L);
  }

  let t = 0;
  function update(dt, { camera, nearItem, nearNpc, hover, npcStates, night }) {
    t += dt;
    // cutaway: lower walls between camera and room centre
    const centre = new THREE.Vector3(cx, 0, cz);
    for (const wg of walls) {
      const toCam = new THREE.Vector3().subVectors(camera.position, wg.position);
      const outside = toCam.dot(wg.userData.inward) < 0;
      const target = outside ? 1 : 0;
      wg.userData.cut += (target - wg.userData.cut) * Math.min(1, dt * 8);
      wg.scale.y = 1 - wg.userData.cut * (outdoor ? 0.4 : 0.82);
    }
    for (const [id, o] of itemObjs) {
      const on = id === nearItem || id === hover;
      o.ring.material.opacity += ((on ? 0.95 : 0) - o.ring.material.opacity) * Math.min(1, dt * 10);
      o.ring.scale.setScalar(1 + Math.sin(t * 4) * 0.04);
      o.label.visible = on;
      if (o.obj.userData.patient) o.obj.userData.patient.update(dt, { action: 'sleep', seated: true, emotion: 'tired' });
      if (o.obj.userData.alarm) o.obj.userData.alarm.material.emissiveIntensity = 0.4 + (Math.sin(t * 6) > 0 ? 1.2 : 0);
    }
    for (const [id, n] of npcs) {
      const st = npcStates && npcStates[id];
      if (st) {
        n.tx = st[0];
        n.ty = st[1];
      }
      const px = n.ch.root.position.x;
      const pz = n.ch.root.position.z;
      const k = Math.min(1, dt * 10);
      const nx = px + (n.tx - px) * k;
      const nz = pz + (n.ty - pz) * k;
      const vx = (nx - px) / Math.max(dt, 1e-3);
      const vz = (nz - pz) / Math.max(dt, 1e-3);
      const speed = Math.hypot(vx, vz);
      n.ch.root.position.set(nx, 0, nz);
      if (speed > 0.2) n.face = Math.atan2(vx, vz);
      const talking = id === nearNpc;
      if (talking) {
        n.face = Math.atan2(camera.userData.playerX - nx, camera.userData.playerZ - nz);
      }
      n.ch.root.rotation.y += shortAngle(n.ch.root.rotation.y, n.face) * Math.min(1, dt * 8);
      const working = st && st[3] === 'working' && !talking && speed < 0.2;
      n.ch.update(dt, {
        walking: speed > 0.2,
        speed,
        action: talking ? 'talk' : working ? 'work' : 'idle',
        emotion: 'happy',
        showName: id === hover || talking,
        talking,
      });
    }
    for (const L of lights) L.intensity = outdoor ? 0 : 2.4 + night * 1.5;
  }

  return { group, update, items: itemObjs, npcs, bounds: { w, h }, walls, outdoor };
}

const POSTERS = {
  employment_center: [['Your career starts here', '#f97316'], ['Interview tips: STAR method', '#1d4ed8'], ['Tailor every resume', '#0f766e']],
  hospital: [['Wash hands · Save lives', '#0ea5e9'], ['Patient safety first', '#dc2626'], ['Ask · Listen · Explain', '#0f766e']],
  tech: [['Ship it! 🚀', '#7c3aed'], ['Code review = learning', '#0ea5e9'], ['Tests before merge', '#16a34a']],
  law: [['Justice · Integrity', '#78350f'], ['Know your precedent', '#1e3a8a']],
  finance: [['Reconcile daily', '#047857'], ['Numbers tell stories', '#1e3a8a']],
  office: [['Customers first', '#ea580c'], ['Lead with clarity', '#1e3a8a']],
  university: [['Learn it · Practice it', '#ca8a04'], ['Library open till 9pm', '#7c3aed']],
  home: [['Home sweet home', '#16a34a']],
  default: [['Welcome!', '#0ea5e9']],
};
function themeOf(id, items) {
  if (id === 'employment_center' || id === 'company_registry') return 'employment_center';
  if (id === 'st_gabriel' || id === 'riverside_clinic') return 'hospital';
  if (id === 'pixelforge' || id === 'nimbus_cloud') return 'tech';
  if (id === 'whitmore_lane' || id === 'civic_legal' || id === 'courthouse') return 'law';
  if (id === 'ledger_co' || id === 'ironclad_audit' || id === 'bank') return 'finance';
  if (id === 'meridian_group' || id === 'harbor_retail') return 'office';
  if (id === 'university' || id === 'library') return 'university';
  if (id === 'apartment_block') return 'home';
  return 'default';
}

/** Non-interactive dressing along the walls so rooms feel lived-in. */
function decorate(group, data, accent, w, h, items) {
  const r = rng('decor:' + data.buildingId);
  const theme = themeOf(data.buildingId, items);
  const taken = (x, y) => items.some((i) => Math.abs(i.x - x) < 1 && Math.abs(i.y - y) < 1);
  // corner plants
  for (const [x, z] of [[-0.15, -0.15], [w - 0.85, -0.15], [-0.15, h - 1.6], [w - 0.85, h - 1.6]]) {
    if (taken(Math.round(x), Math.round(z))) continue;
    group.add(at(plant(r, 1.5), x, 0, z));
  }
  // posters on the back wall between items
  const posters = POSTERS[theme] || POSTERS.default;
  let pi = 0;
  for (let x = 1.5; x < w - 1.5 && pi < posters.length; x += 3.4) {
    const [text, bg] = posters[pi++];
    const p = at(new THREE.Group(), x + (r() - 0.5) * 0.4, 1.25, -0.47);
    p.add(at(box(1.0, 0.62, 0.03, mat(0x111827)), 0, 0, 0));
    p.add(at(plane(0.92, 0.54, signMaterial(text, { bg, fg: '#ffffff', w: 600, h: 360 })), 0, 0, 0.02));
    group.add(p);
  }
  // side-wall art / TV
  const tv = at(new THREE.Group(), -0.47, 1.35, h * 0.42);
  tv.rotation.y = Math.PI / 2;
  tv.add(at(box(1.2, 0.7, 0.05, mat(0x0f172a)), 0, 0, 0));
  tv.add(at(plane(1.12, 0.62, screenMat(theme === 'employment_center' ? 'jobs' : theme === 'hospital' ? 'ecg' : theme === 'tech' ? 'code' : theme === 'finance' ? 'chart' : 'doc')), 0, 0, 0.03));
  if (theme !== 'home') group.add(tv);
  // waiting chairs along the left wall for public buildings
  if (['employment_center', 'hospital', 'finance', 'law', 'default'].includes(theme)) {
    for (let i = 0; i < 3; i++) {
      const z = h * 0.42 + 0.9 + i * 0.45;
      if (taken(0, Math.round(z))) continue;
      const c = chair(shade(accent, -0.1));
      c.position.set(-0.28, 0, z);
      c.rotation.y = Math.PI / 2;
      group.add(c);
    }
  }
  themedDressing(group, data.buildingId, accent, w, h, r);

  // water cooler on the right wall
  if (theme !== 'home') {
    const wc = at(new THREE.Group(), w - 0.75, 0, h * 0.42 + 1.4);
    wc.add(at(rbox(0.3, 0.8, 0.3, 0.03, mat(WHITE)), 0, 0.4, 0));
    wc.add(at(cyl(0.12, 0.12, 0.35, mat(0x7dd3fc, { t: 0.7, r: 0.1 }), 14), 0, 0.98, 0));
    if (!taken(w - 1, Math.round(h * 0.42 + 1.4))) group.add(wc);
  }
}

function runner(group, x, z0, z1, width, color) {
  const m = new THREE.Mesh(new THREE.PlaneGeometry(width, z1 - z0), mat(color, { r: 1 }));
  m.rotation.x = -Math.PI / 2;
  m.position.set(x, 0.009, (z0 + z1) / 2);
  m.receiveShadow = true;
  group.add(m);
}

/** Per-building wall dressing so sparse rooms still read as the real place. */
function themedDressing(group, id, accent, w, h, r) {
  const add = (o, x, z, ry = 0) => {
    o.position.set(x, 0, z);
    o.rotation.y = ry;
    group.add(o);
  };
  switch (id) {
    case 'bank': {
      const vault = at(new THREE.Group(), w - 0.47, 1.0, 2.6);
      vault.rotation.y = -Math.PI / 2;
      vault.add(at(cyl(0.62, 0.62, 0.12, mat(0x9ca3af, { m: 0.8, r: 0.3 }), 28), 0, 0, 0).rotateX(Math.PI / 2));
      vault.add(at(cyl(0.18, 0.18, 0.08, mat(0x6b7280, { m: 0.9, r: 0.3 }), 16), 0, 0, 0.1).rotateX(Math.PI / 2));
      for (let i = 0; i < 4; i++) vault.add(at(box(0.5, 0.04, 0.04, mat(0x4b5563, { m: 0.8 })), 0, 0, 0.14).rotateZ((i * Math.PI) / 4));
      group.add(vault);
      for (let i = 0; i < 4; i++) {
        const post = at(new THREE.Group(), 1.6 + i * 0.7, 0, 3.2);
        post.add(at(cyl(0.03, 0.03, 0.7, mat(0xd4a017, { m: 0.8, r: 0.3 }), 8), 0, 0.35, 0));
        post.add(at(cyl(0.12, 0.12, 0.03, mat(0xd4a017, { m: 0.8, r: 0.3 }), 12), 0, 0.015, 0));
        group.add(post);
        if (i < 3) group.add(at(box(0.66, 0.04, 0.04, mat(0x991b1b)), 1.95 + i * 0.7, 0.6, 3.2));
      }
      runner(group, 3.0, 2.0, h - 1.0, 1.2, 0x7f1d1d);
      break;
    }
    case 'courthouse': {
      const bench = new THREE.Group();
      bench.add(at(rbox(2.4, 0.9, 0.55, 0.03, mat(DARKWOOD, { r: 0.5 })), 0, 0.45, 0));
      bench.add(at(rbox(1.4, 0.3, 0.55, 0.03, mat(DARKWOOD, { r: 0.5 })), 0, 1.05, -0.05));
      bench.add(at(plane(0.45, 0.45, signMaterial('⚖️', { bg: '#78350f', fg: '#fde68a', w: 256, h: 256 })), 0, 1.55, -0.2));
      add(bench, 6.2, -0.15);
      for (const x of [4.6, 7.8]) {
        const f = at(new THREE.Group(), x, 0, -0.25);
        f.add(at(cyl(0.02, 0.02, 1.9, mat(0x9ca3af, { m: 0.6 }), 6), 0, 0.95, 0));
        f.add(at(box(0.5, 0.32, 0.01, mat(x < 6 ? 0x2563eb : 0x16a34a)), 0.26, 1.7, 0));
        group.add(f);
      }
      for (let i = 0; i < 3; i++) {
        add(bench3(), -0.1, 3.6 + i * 0.9, Math.PI / 2);
        add(bench3(), w - 0.9, 3.6 + i * 0.9, -Math.PI / 2);
      }
      runner(group, 5, 1.0, h - 0.6, 1.1, 0x7f1d1d);
      break;
    }
    case 'grocery': {
      for (const x of [0.6, 1.8, 9.2, 10.4]) {
        const fz = new THREE.Group();
        fz.add(at(rbox(1.1, 0.8, 0.6, 0.03, mat(WHITE, { r: 0.3 })), 0, 0.4, 0));
        fz.add(at(box(1.0, 0.03, 0.5, mat(0xbae6fd, { r: 0.05, t: 0.6 })), 0, 0.81, 0));
        for (let i = 0; i < 6; i++) fz.add(at(box(0.14, 0.12, 0.2, mat([0x3b82f6, 0xf97316, 0x22c55e][i % 3])), -0.38 + i * 0.15, 0.7, 0));
        add(fz, x, -0.1);
      }
      const co = counter(1.3, 0x15803d, 0xf0fdf4);
      co.add(at(monitor('doc', 0.26), -0.35, 0.66, -0.05));
      co.add(at(box(0.6, 0.02, 0.4, mat(0x111827)), 0.3, 0.67, 0));
      add(co, w - 1.1, h - 2.4, -Math.PI / 2);
      for (let i = 0; i < 2; i++) {
        const cart = new THREE.Group();
        cart.add(at(box(0.4, 0.3, 0.55, mat(0x9ca3af, { m: 0.7, t: 0.8 })), 0, 0.45, 0));
        for (const sx of [-0.15, 0.15]) for (const sz of [-0.2, 0.2]) cart.add(at(sphere(0.04, mat(0x111827), 8), sx, 0.04, sz));
        add(cart, 0.4 + i * 0.55, h - 2.0, 0.3);
      }
      break;
    }
    case 'gym': {
      const mm = new THREE.MeshStandardMaterial({ color: 0xdbeafe, roughness: 0.05, metalness: 0.6 });
      group.add(at(plane(w - 3, 1.5, mm), (w - 1) / 2, 1.2, -0.48));
      const cols = [0x0d9488, 0x8b5cf6, 0xf97316];
      for (let i = 0; i < 3; i++) {
        const mat2 = new THREE.Mesh(new THREE.PlaneGeometry(0.6, 1.5), mat(cols[i], { r: 1 }));
        mat2.rotation.x = -Math.PI / 2;
        mat2.position.set(2 + i * 0.9, 0.012, h - 3.0);
        group.add(mat2);
      }
      for (const [x, z, c] of [[w - 1.0, h - 2.2, 0xf472b6], [w - 1.5, h - 2.0, 0x60a5fa]]) group.add(at(sphere(0.3, mat(c, { r: 0.4 }), 18), x, 0.3, z));
      break;
    }
    case 'company_registry':
      add(cabinet(2), 0.6, -0.15);
      add(cabinet(2), 9.8, -0.15);
      break;
    case 'cinema': {
      runner(group, 5, 0.5, h - 0.6, 1.4, 0xb91c1c);
      const pm = new THREE.Group();
      pm.add(at(rbox(0.5, 0.6, 0.45, 0.03, mat(0xdc2626)), 0, 0.3, 0));
      pm.add(at(box(0.48, 0.5, 0.43, mat(0xfef9c3, { r: 0.05, t: 0.5 })), 0, 0.85, 0));
      for (let i = 0; i < 10; i++) pm.add(at(sphere(0.035, mat(0xfef3c7), 6), (r() - 0.5) * 0.35, 0.65 + r() * 0.15, (r() - 0.5) * 0.3));
      add(pm, w - 1.0, 4.4);
      break;
    }
    case 'corner_cafe':
      for (let i = 0; i < 3; i++) {
        const st = new THREE.Group();
        st.add(at(cyl(0.16, 0.16, 0.05, mat(0x92400e), 12), 0, 0.55, 0));
        st.add(at(cyl(0.025, 0.025, 0.55, mat(0x111827), 6), 0, 0.27, 0));
        add(st, 3.2 + i * 0.65, 1.75);
      }
      break;
  }
}

function bench3() {
  const g = bench(DARKWOOD);
  g.scale.set(1.3, 1, 1);
  return g;
}

export function shortAngle(a, b) {
  let d = (b - a) % (Math.PI * 2);
  if (d > Math.PI) d -= Math.PI * 2;
  if (d < -Math.PI) d += Math.PI * 2;
  return d;
}
