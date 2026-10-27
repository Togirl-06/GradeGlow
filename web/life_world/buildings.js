// Distinct 3D buildings for every GradeGlow city location.
import * as THREE from 'three';
import { box, rbox, cyl, sphere, cone, torus, plane, mat, col, shade, hex, at, signMaterial, rng, labelSprite, mergeStatic } from './util.js';

export const FLOOR_H = 1.15;

/** Materials whose emissive intensity follows the night (window lights, neon). */
export const nightMats = new Set();

// ------------------------------------------------------------ facades

const _facades = new Map();

/**
 * Canvas facade texture for a wall. Returns {map, emissiveMap}.
 * style: grid | glass | classic | brick | shop
 */
function facadeTex(style, wall, glassTint, cols, floors, seed, ground = 'plain') {
  const key = [style, hex(wall), hex(glassTint), cols, floors, seed, ground].join('|');
  if (_facades.has(key)) return _facades.get(key);
  const CW = 64;
  const CH = 72;
  const w = Math.max(1, cols) * CW;
  const h = Math.max(1, floors) * CH;
  const c = document.createElement('canvas');
  c.width = w;
  c.height = h;
  const e = document.createElement('canvas');
  e.width = w;
  e.height = h;
  const g = c.getContext('2d');
  const ge = e.getContext('2d');
  ge.fillStyle = '#000';
  ge.fillRect(0, 0, w, h);
  const r = rng(seed);
  const wallC = hex(wall);
  const glass = col(glassTint);
  const glassTop = '#' + glass.clone().lerp(new THREE.Color(0xe0f2fe), 0.55).getHexString();
  const glassBot = '#' + glass.clone().multiplyScalar(0.55).getHexString();

  function glassRect(x, y, ww, hh) {
    const gr = g.createLinearGradient(x, y, x + ww * 0.3, y + hh);
    gr.addColorStop(0, glassTop);
    gr.addColorStop(1, glassBot);
    g.fillStyle = gr;
    g.fillRect(x, y, ww, hh);
    // reflection streak
    g.fillStyle = 'rgba(255,255,255,0.16)';
    g.beginPath();
    g.moveTo(x + ww * 0.15, y + hh);
    g.lineTo(x + ww * 0.45, y);
    g.lineTo(x + ww * 0.62, y);
    g.lineTo(x + ww * 0.32, y + hh);
    g.fill();
  }
  function lit(x, y, ww, hh, p = 0.38) {
    if (r() < p) {
      const warm = r() < 0.8;
      ge.fillStyle = warm ? `rgba(255,${200 + Math.floor(r() * 40)},${120 + Math.floor(r() * 60)},1)` : 'rgba(190,225,255,1)';
      ge.fillRect(x, y, ww, hh);
    }
  }

  g.fillStyle = wallC;
  g.fillRect(0, 0, w, h);

  if (style === 'brick') {
    g.fillStyle = 'rgba(0,0,0,0.07)';
    for (let y = 0; y < h; y += 8) {
      g.fillRect(0, y, w, 1);
      for (let x = (y / 8) % 2 ? 0 : 8; x < w; x += 16) g.fillRect(x, y, 1, 8);
    }
  } else {
    // subtle noise panels
    g.fillStyle = 'rgba(0,0,0,0.035)';
    for (let i = 0; i < cols * floors; i++) g.fillRect(Math.floor(r() * w), Math.floor(r() * h), 30, 2);
  }

  for (let f = 0; f < floors; f++) {
    const y0 = h - (f + 1) * CH;
    const isGround = f === 0;
    if (style === 'glass') {
      glassRect(0, y0 + 6, w, CH - 10);
      for (let i = 0; i < cols; i++) lit(i * CW + 3, y0 + 8, CW - 6, CH - 14, 0.33);
      g.fillStyle = shade(wall, -0.25).getStyle();
      g.fillRect(0, y0 + CH - 6, w, 6);
      g.fillStyle = 'rgba(30,41,59,0.55)';
      for (let i = 0; i <= cols; i++) g.fillRect(i * CW - 1, y0, 3, CH);
      continue;
    }
    // floor band
    g.fillStyle = shade(wall, -0.08).getStyle();
    g.fillRect(0, y0 + CH - 5, w, 5);
    for (let i = 0; i < cols; i++) {
      const x0 = i * CW;
      if (isGround && ground === 'shop') {
        glassRect(x0 + 4, y0 + 12, CW - 8, CH - 18);
        lit(x0 + 4, y0 + 12, CW - 8, CH - 18, 0.85);
        g.fillStyle = shade(wall, -0.3).getStyle();
        g.fillRect(x0 + 2, y0 + 10, CW - 4, 3);
        continue;
      }
      let wx = x0 + 14;
      let wy = y0 + 14;
      let ww = CW - 28;
      let wh = CH - 30;
      if (style === 'classic') {
        wx = x0 + 18;
        ww = CW - 36;
        wy = y0 + 10;
        wh = CH - 22;
      } else if (style === 'grid') {
        wx = x0 + 8;
        ww = CW - 16;
        wy = y0 + 12;
        wh = CH - 26;
      }
      // frame
      g.fillStyle = style === 'brick' ? '#f8fafc' : shade(wall, 0.3).getStyle();
      g.fillRect(wx - 3, wy - 3, ww + 6, wh + 6);
      glassRect(wx, wy, ww, wh);
      if (style === 'classic') {
        g.fillStyle = shade(wall, 0.35).getStyle();
        g.beginPath();
        g.arc(wx + ww / 2, wy + 2, ww / 2 + 3, Math.PI, 0);
        g.fill();
        g.fillStyle = shade(wall, -0.2).getStyle();
        g.fillRect(wx - 5, wy + wh + 3, ww + 10, 4);
      }
      // mullion
      g.fillStyle = 'rgba(255,255,255,0.6)';
      g.fillRect(wx + ww / 2 - 1, wy, 2, wh);
      lit(wx, wy, ww, wh);
    }
  }
  const map = new THREE.CanvasTexture(c);
  map.colorSpace = THREE.SRGBColorSpace;
  map.anisotropy = 8;
  const emissiveMap = new THREE.CanvasTexture(e);
  emissiveMap.colorSpace = THREE.SRGBColorSpace;
  const out = { map, emissiveMap };
  _facades.set(key, out);
  return out;
}

function facadeMat(style, wall, glass, cols, floors, seed, ground) {
  const t = facadeTex(style, wall, glass, cols, floors, seed, ground);
  const m = new THREE.MeshStandardMaterial({
    map: t.map,
    emissive: new THREE.Color(0xffffff),
    emissiveMap: t.emissiveMap,
    emissiveIntensity: 0,
    roughness: style === 'glass' ? 0.25 : 0.82,
    metalness: style === 'glass' ? 0.25 : 0,
  });
  m.userData.nightGlow = true;
  nightMats.add(m);
  return m;
}

/** A box whose four sides are textured as facades; roof flat. */
function block(w, floors, d, style, wall, glass, seed, { ground = 'plain', roof = null, h = null } = {}) {
  const H = h ?? floors * FLOOR_H;
  const colsW = Math.max(1, Math.round(w / 0.85));
  const colsD = Math.max(1, Math.round(d / 0.85));
  const fw = facadeMat(style, wall, glass, colsW, floors, seed, ground);
  const fd = facadeMat(style, wall, glass, colsD, floors, seed + 7, 'plain');
  const roofM = mat(roof ?? shade(wall, -0.25), { r: 0.95 });
  const m = new THREE.Mesh(new THREE.BoxGeometry(w, H, d), [fd, fd, roofM, roofM, fw, fw]);
  m.position.y = H / 2;
  m.castShadow = m.receiveShadow = true;
  return m;
}

function parapet(g, w, d, y, color, t = 0.12, hgt = 0.22, z = 0) {
  const m = mat(color, { r: 0.9 });
  g.add(at(box(w, hgt, t, m), 0, y + hgt / 2, z + d / 2 - t / 2));
  g.add(at(box(w, hgt, t, m), 0, y + hgt / 2, z - d / 2 + t / 2));
  g.add(at(box(t, hgt, d, m), w / 2 - t / 2, y + hgt / 2, z));
  g.add(at(box(t, hgt, d, m), -w / 2 + t / 2, y + hgt / 2, z));
}

/** Gable roof: ridge along x, slopes toward ±z. */
function gableRoof(g, w, d, x, y, z, h, color) {
  const shape = new THREE.Shape();
  shape.moveTo(-d / 2, 0);
  shape.lineTo(d / 2, 0);
  shape.lineTo(0, h);
  shape.lineTo(-d / 2, 0);
  const geo = new THREE.ExtrudeGeometry(shape, { depth: w, bevelEnabled: false });
  const m = new THREE.Mesh(geo, mat(color, { r: 0.8, flat: true }));
  m.rotation.y = Math.PI / 2;
  m.position.set(x - w / 2, y, z);
  m.castShadow = m.receiveShadow = true;
  g.add(m);
}

function door(g, x, z, { w = 0.95, h = 1.05, frame = 0x334155, glass = 0x93c5fd, canopy = null, canopyDepth = 0.7 } = {}) {
  const fm = mat(frame, { r: 0.4, m: 0.3 });
  g.add(at(box(w + 0.14, h + 0.1, 0.08, fm), x, (h + 0.1) / 2, z + 0.02));
  const gm = mat(glass, { r: 0.1, m: 0.4, e: 0xfff3c4, ei: 0 });
  gm.userData.nightGlow = true;
  nightMats.add(gm);
  g.add(at(box(w, h, 0.06, gm), x, h / 2, z + 0.05));
  g.add(at(box(0.03, h, 0.07, fm), x, h / 2, z + 0.07));
  if (canopy !== null) {
    g.add(at(box(w + 0.6, 0.07, canopyDepth, mat(canopy, { r: 0.6 })), x, h + 0.28, z + canopyDepth / 2));
  }
}

function sign(g, text, x, y, z, w, h, opts = {}) {
  const m = signMaterial(text, opts);
  if (m.userData.nightGlow) nightMats.add(m);
  const p = at(plane(w, h, m), x, y, z + 0.011);
  p.castShadow = false;
  g.add(p);
  if (opts.backing !== false) g.add(at(box(w + 0.08, h + 0.08, 0.05, mat(opts.frame ?? 0x111827, { r: 0.5 })), x, y, z - 0.02));
  return p;
}

function columns(g, n, span, x, z, hgt, r = 0.12, color = 0xf8fafc) {
  const m = mat(color, { r: 0.7 });
  for (let i = 0; i < n; i++) {
    const cx = x - span / 2 + (span * i) / (n - 1);
    g.add(at(cyl(r, r * 1.08, hgt, m, 14), cx, hgt / 2 + 0.12, z));
    g.add(at(box(r * 2.6, 0.1, r * 2.6, m), cx, hgt + 0.17, z));
    g.add(at(box(r * 2.6, 0.12, r * 2.6, m), cx, 0.06, z));
  }
}

function pediment(g, w, x, y, z, d, color) {
  const shape = new THREE.Shape();
  shape.moveTo(-w / 2, 0);
  shape.lineTo(w / 2, 0);
  shape.lineTo(0, w * 0.22);
  shape.lineTo(-w / 2, 0);
  const geo = new THREE.ExtrudeGeometry(shape, { depth: d, bevelEnabled: false });
  const m = new THREE.Mesh(geo, mat(color, { r: 0.75 }));
  m.position.set(x, y, z - d / 2);
  m.castShadow = m.receiveShadow = true;
  g.add(m);
}

function steps(g, w, z, n = 3, color = 0xe7e5e4) {
  const m = mat(color, { r: 0.9 });
  for (let i = 0; i < n; i++) {
    g.add(at(box(w - i * 0.2, 0.08, 0.28, m), 0, 0.04 + i * 0.08, z - i * 0.24 + 0.24 * (n - 1)));
  }
}

function tree(r, scale = 1, kind = null) {
  const g = new THREE.Group();
  const trunk = at(cyl(0.05 * scale, 0.07 * scale, 0.5 * scale, mat(0x7c4a2d, { r: 0.9 }), 7), 0, 0.25 * scale, 0);
  g.add(trunk);
  const k = kind ?? (r() < 0.35 ? 'pine' : 'round');
  const leafC = [0x4ade80, 0x22c55e, 0x16a34a, 0x65a30d, 0x84cc16][Math.floor(r() * 5)];
  const lm = mat(leafC, { r: 0.85, flat: true });
  if (k === 'pine') {
    g.add(at(cone(0.38 * scale, 0.7 * scale, lm, 7), 0, 0.75 * scale, 0));
    g.add(at(cone(0.28 * scale, 0.55 * scale, lm, 7), 0, 1.08 * scale, 0));
  } else {
    const s1 = at(new THREE.Mesh(new THREE.IcosahedronGeometry(0.4 * scale, 1), lm), 0, 0.82 * scale, 0);
    const s2 = at(new THREE.Mesh(new THREE.IcosahedronGeometry(0.28 * scale, 1), lm), 0.18 * scale, 1.02 * scale, 0.05);
    for (const s of [s1, s2]) {
      s.castShadow = true;
      s.receiveShadow = true;
      g.add(s);
    }
  }
  g.rotation.y = r() * 6.28;
  return g;
}
export { tree };

function bush(r, s = 1) {
  const m = mat([0x4d7c0f, 0x3f6212, 0x15803d][Math.floor(r() * 3)], { r: 0.9, flat: true });
  const b = new THREE.Mesh(new THREE.IcosahedronGeometry(0.22 * s, 1), m);
  b.scale.y = 0.75;
  b.position.y = 0.14 * s;
  b.castShadow = true;
  return b;
}
export { bush };

function planter(r) {
  const g = new THREE.Group();
  g.add(at(box(0.5, 0.25, 0.5, mat(0xa8a29e)), 0, 0.125, 0));
  g.add(at(bush(r, 1.0), 0, 0.2, 0));
  return g;
}

function flowerBed(w, d, r) {
  const g = new THREE.Group();
  g.add(at(box(w, 0.12, d, mat(0x78716c)), 0, 0.06, 0));
  g.add(at(box(w - 0.08, 0.04, d - 0.08, mat(0x5b3a1e)), 0, 0.13, 0));
  const cols = [0xf472b6, 0xfacc15, 0xf87171, 0xa78bfa, 0xffffff];
  for (let i = 0; i < Math.round(w * d * 14); i++) {
    g.add(at(sphere(0.035, mat(cols[Math.floor(r() * cols.length)], { r: 0.6 }), 6), (r() - 0.5) * (w - 0.15), 0.18, (r() - 0.5) * (d - 0.15)));
  }
  return g;
}

function bench(color = 0x8b5a2b) {
  const g = new THREE.Group();
  const wm = mat(color, { r: 0.8 });
  const im = mat(0x374151, { r: 0.5, m: 0.5 });
  g.add(at(box(0.7, 0.04, 0.22, wm), 0, 0.22, 0));
  g.add(at(box(0.7, 0.18, 0.04, wm), 0, 0.36, -0.1));
  g.add(at(box(0.04, 0.22, 0.2, im), -0.3, 0.11, 0));
  g.add(at(box(0.04, 0.22, 0.2, im), 0.3, 0.11, 0));
  return g;
}
export { bench };

function umbrellaTable(color) {
  const g = new THREE.Group();
  g.add(at(cyl(0.22, 0.22, 0.03, mat(0xf8fafc), 16), 0, 0.36, 0));
  g.add(at(cyl(0.025, 0.025, 1.05, mat(0x6b7280), 6), 0, 0.52, 0));
  g.add(at(cone(0.5, 0.22, mat(color, { r: 0.7, flat: true }), 8), 0, 1.06, 0));
  for (const a of [0, 2.1, 4.2]) {
    const ch = at(rbox(0.16, 0.2, 0.16, 0.03, mat(0x1f2937)), Math.cos(a) * 0.33, 0.12, Math.sin(a) * 0.33);
    g.add(ch);
  }
  return g;
}

function awning(g, w, x, y, z, c1, c2 = 0xffffff, depth = 0.7) {
  const cv = document.createElement('canvas');
  cv.width = 256;
  cv.height = 16;
  const ctx = cv.getContext('2d');
  for (let i = 0; i < 8; i++) {
    ctx.fillStyle = i % 2 ? hex(c2) : hex(c1);
    ctx.fillRect(i * 32, 0, 32, 16);
  }
  const t = new THREE.CanvasTexture(cv);
  t.colorSpace = THREE.SRGBColorSpace;
  t.wrapS = THREE.RepeatWrapping;
  t.repeat.set(Math.max(1, w / 1.6), 1);
  const m = new THREE.MeshStandardMaterial({ map: t, roughness: 0.8, side: THREE.DoubleSide });
  const p = new THREE.Mesh(new THREE.PlaneGeometry(w, depth), m);
  p.rotation.x = -Math.PI / 2 + 0.45;
  p.position.set(x, y, z + depth * 0.45);
  p.castShadow = true;
  g.add(p);
  // scalloped front
  const front = new THREE.Mesh(new THREE.PlaneGeometry(w, 0.14), m);
  front.position.set(x, y - Math.sin(0.45) * depth * 0.5 - 0.07 + 0.02, z + depth * 0.9);
  g.add(front);
}

function car(color, r) {
  const g = new THREE.Group();
  const bm = mat(color, { r: 0.35, m: 0.35 });
  g.add(at(rbox(0.55, 0.22, 1.15, 0.08, bm), 0, 0.2, 0));
  g.add(at(rbox(0.5, 0.2, 0.62, 0.08, mat(0x1e293b, { r: 0.15, m: 0.5 })), 0, 0.38, -0.06));
  g.add(at(rbox(0.52, 0.06, 0.58, 0.03, bm), 0, 0.49, -0.06));
  const wm = mat(0x111827, { r: 0.8 });
  for (const sx of [-0.28, 0.28]) for (const sz of [-0.36, 0.36]) {
    const w = at(cyl(0.11, 0.11, 0.08, wm, 12), sx, 0.11, sz);
    w.rotation.z = Math.PI / 2;
    g.add(w);
  }
  const hl = mat(0xfffbeb, { e: 0xfff3c4, ei: 0.2 });
  hl.userData.nightGlow = true;
  nightMats.add(hl);
  g.add(at(box(0.12, 0.05, 0.02, hl), -0.17, 0.24, 0.58));
  g.add(at(box(0.12, 0.05, 0.02, hl), 0.17, 0.24, 0.58));
  g.add(at(box(0.12, 0.05, 0.02, mat(0xef4444, { e: 0xef4444, ei: 0.5 })), -0.17, 0.24, -0.58));
  g.add(at(box(0.12, 0.05, 0.02, mat(0xef4444, { e: 0xef4444, ei: 0.5 })), 0.17, 0.24, -0.58));
  return g;
}
export { car };

function ambulance() {
  const g = car(0xf8fafc, Math.random);
  g.add(at(rbox(0.56, 0.36, 0.6, 0.05, mat(0xf8fafc, { r: 0.4 })), 0, 0.46, -0.25));
  g.add(at(box(0.57, 0.06, 1.16, mat(0xef4444)), 0, 0.27, 0));
  g.add(at(box(0.3, 0.06, 0.08, mat(0x3b82f6, { e: 0x3b82f6, ei: 0.8 })), 0, 0.66, 0.02));
  return g;
}

function crossSign(color, s = 1) {
  const g = new THREE.Group();
  const m = mat(color, { r: 0.4, e: color, ei: 0.4 });
  m.userData.nightGlow = true;
  nightMats.add(m);
  g.add(box(0.22 * s, 0.7 * s, 0.1, m));
  g.add(box(0.7 * s, 0.22 * s, 0.1, m));
  return g;
}

function rooftopClutter(g, w, d, y, r) {
  const m = mat(0x9ca3af, { r: 0.6, m: 0.3 });
  const n = 1 + Math.floor(r() * 3);
  for (let i = 0; i < n; i++) {
    g.add(at(box(0.35 + r() * 0.3, 0.25, 0.35 + r() * 0.2, m), (r() - 0.5) * (w - 1), y + 0.12, (r() - 0.5) * (d - 1)));
  }
}

// ------------------------------------------------------------ archetypes

const W_GLASS = 0x7dd3fc;

const ARCH = {
  apartment_block(g, k) {
    const { W, D, r } = k;
    const bd = D - 0.6;
    const m = block(W, 6, bd, 'brick', 0xd28d66, 0x9fc5e8, 11, { roof: 0x6b7280 });
    m.position.z = -0.3;
    g.add(m);
    const fz = -0.3 + bd / 2;
    parapet(g, W, bd, 6 * FLOOR_H, 0xb4683f, 0.12, 0.22, -0.3);
    // balconies
    const slab = mat(0xe7e5e4, { r: 0.8 });
    const rail = mat(0xbae6fd, { r: 0.1, t: 0.45 });
    const cols = Math.round(W / 0.85);
    for (let f = 1; f < 6; f++) {
      for (let i = 0; i < cols; i += 2) {
        const x = -W / 2 + (i + 0.5) * (W / cols);
        g.add(at(box(0.8, 0.06, 0.4, slab), x, f * FLOOR_H + 0.05, fz + 0.2));
        g.add(at(box(0.8, 0.3, 0.03, rail), x, f * FLOOR_H + 0.22, fz + 0.39));
        if (r() < 0.5) {
          const p = planter(r);
          p.scale.setScalar(0.42);
          g.add(at(p, x + 0.24, f * FLOOR_H + 0.08, fz + 0.18));
        }
      }
    }
    g.add(at(cyl(0.35, 0.35, 0.6, mat(0x78716c), 12), W / 2 - 0.8, 6 * FLOOR_H + 0.3, -0.8));
    g.add(at(cone(0.38, 0.25, mat(0x57534e), 12), W / 2 - 0.8, 6 * FLOOR_H + 0.72, -0.8));
    rooftopClutter(g, W, bd, 6 * FLOOR_H, r);
    door(g, k.doorX, fz, { canopy: k.color, canopyDepth: 0.9 });
    sign(g, 'Greenview Apartments', k.doorX, 1.62, fz, 2.4, 0.32, { bg: '#14532d', fg: '#ecfccb', emoji: '🏠' });
    g.add(at(planter(r), k.doorX - 1.1, 0, fz + 0.4));
    g.add(at(planter(r), k.doorX + 1.1, 0, fz + 0.4));
  },

  corner_cafe(g, k) {
    const { W, D } = k;
    const bd = D - 1.6;
    const m = block(W, 2, bd, 'grid', 0xf5e6c8, 0xfcd34d, 21, { ground: 'shop', roof: 0x7c2d12 });
    m.position.z = -0.8;
    g.add(m);
    gableRoof(g, W + 0.2, bd + 0.3, 0, 2 * FLOOR_H, -0.8, 1.0, 0x9a3412);
    const fz = -0.8 + bd / 2;
    awning(g, W - 0.3, 0, 1.1, fz, 0xb45309, 0xfff7ed, 0.8);
    door(g, k.doorX, fz, { frame: 0x7c2d12, glass: 0xfde68a });
    sign(g, 'Corner Café', 0, 1.82, fz, 2.2, 0.36, { bg: '#7c2d12', fg: '#fff7ed', emoji: '☕', font: 'serif', glow: true });
    g.add(at(box(W - 0.4, 0.04, 1.5, mat(0xc4a484, { r: 0.9 })), 0, 0.02, fz + 0.78));
    for (const x of [-1.5, 1.5]) g.add(at(umbrellaTable(x < 0 ? 0xf97316 : 0x0ea5e9), x, 0.04, fz + 0.85));
  },

  university(g, k) {
    const { W, D, front } = k;
    const stone = 0xeadcb8;
    const m = block(W, 3, D - 1.2, 'classic', stone, 0xa5d8f3, 31, { roof: 0x8b6f47 });
    m.position.z = -0.6;
    g.add(m);
    const fz = -0.6 + (D - 1.2) / 2;
    parapet(g, W, D - 1.2, 3 * FLOOR_H, 0xd6c49a, 0.14, 0.3, -0.6);
    // portico
    columns(g, 6, 3.3, 0, fz + 0.75, 2.3, 0.11);
    g.add(at(box(3.8, 0.22, 1.1, mat(0xf5f5f4)), 0, 2.58, fz + 0.5));
    pediment(g, 3.9, 0, 2.69, fz + 0.5, 1.1, 0xf5f5f4);
    steps(g, 4.0, fz + 0.9, 3, 0xf5f5f4);
    door(g, k.doorX, fz, { w: 1.0, h: 1.5, frame: 0x78350f, glass: 0x7c4a2d });
    // clock tower
    const tw = at(new THREE.Group(), 0, 3 * FLOOR_H, -1.4);
    tw.add(at(box(1.5, 2.2, 1.5, mat(stone, { r: 0.85 })), 0, 1.1, 0));
    const face = signMaterial('🕓', { bg: '#f8fafc', fg: '#0f172a', w: 256, h: 256 });
    tw.add(at(plane(0.9, 0.9, face), 0, 1.45, 0.76));
    tw.add(at(box(1.7, 0.15, 1.7, mat(0xd6c49a)), 0, 2.27, 0));
    const dome = sphere(0.78, mat(0xd4a017, { r: 0.35, m: 0.6 }), 20);
    dome.scale.y = 0.85;
    tw.add(at(dome, 0, 2.35, 0));
    tw.add(at(cyl(0.02, 0.02, 0.6, mat(0x6b7280), 6), 0, 3.25, 0));
    g.add(tw);
    // banners
    for (const x of [-2.1, 2.1]) {
      g.add(at(box(0.04, 1.6, 0.04, mat(0x6b7280)), x, 0.8 + 1.4, fz + 0.06));
      g.add(at(box(0.4, 1.0, 0.02, mat(0x1d4ed8, { r: 0.7 })), x + 0.22, 2.0, fz + 0.06));
    }
    sign(g, 'Glowland University', 0, 2.78 + 0.45, fz + 1.06, 2.8, 0.32, { bg: '#f5f5f4', fg: '#78350f', font: 'serif', backing: false });
  },

  library(g, k) {
    const { W, D, front } = k;
    const m = block(W, 2, D - 0.9, 'classic', 0xc8a27a, 0xbfdbfe, 41, { roof: 0x5b4636, h: 2.9 });
    m.position.z = -0.45;
    g.add(m);
    const fz = -0.45 + (D - 0.9) / 2;
    columns(g, 4, 2.4, 0, fz + 0.45, 2.1, 0.1, 0xf5f5f4);
    g.add(at(box(2.9, 0.2, 0.8, mat(0xf5f5f4)), 0, 2.32, fz + 0.32));
    pediment(g, 3.0, 0, 2.42, fz + 0.32, 0.8, 0xf5f5f4);
    steps(g, 3.0, fz + 0.62, 2);
    door(g, k.doorX, fz, { w: 0.9, h: 1.4, frame: 0x451a03, glass: 0x92400e });
    sign(g, 'City Library', 0, 2.95, fz + 0.73, 1.9, 0.28, { bg: '#f5f5f4', fg: '#451a03', emoji: '📚', font: 'serif', backing: false });
  },

  st_gabriel(g, k) {
    const { W, D, front, r } = k;
    const white = 0xf3f6f9;
    const wing = block(W, 2, D - 0.6, 'grid', white, 0x93c5fd, 51, { roof: 0xcbd5e1 });
    wing.position.z = -0.3;
    g.add(wing);
    const tower = block(W * 0.62, 8, D * 0.55, 'grid', white, 0x7dd3fc, 52, { roof: 0x94a3b8 });
    tower.position.set(-W * 0.12, 0, -D * 0.18);
    g.add(tower);
    const th = 8 * FLOOR_H;
    // accent stripes
    const am = mat(k.color, { r: 0.6 });
    for (let f = 2; f <= 8; f += 2) g.add(at(box(W * 0.62 + 0.04, 0.08, D * 0.55 + 0.04, am), -W * 0.12, f * FLOOR_H - 0.02, -D * 0.18));
    // helipad
    g.add(at(cyl(0.95, 0.95, 0.06, mat(0x334155, { r: 0.9 }), 24), -W * 0.12, th + 0.03, -D * 0.18));
    const h = signMaterial('H', { bg: '#334155', fg: '#facc15', w: 256, h: 256 });
    const hp = at(plane(1.1, 1.1, h), -W * 0.12, th + 0.065, -D * 0.18);
    hp.rotation.x = -Math.PI / 2;
    g.add(hp);
    // big red cross
    const cs = crossSign(0xef4444, 1.1);
    cs.position.set(-W * 0.12, th - 0.9, -D * 0.18 + D * 0.275 + 0.06);
    g.add(cs);
    const fz = -0.3 + (D - 0.6) / 2;
    // ER canopy
    g.add(at(box(2.6, 0.12, 1.4, mat(0xffffff)), k.doorX, 1.45, fz + 0.7));
    for (const x of [-1.2, 1.2]) g.add(at(cyl(0.05, 0.05, 1.42, mat(0x94a3b8), 8), k.doorX + x, 0.71, fz + 1.3));
    sign(g, 'EMERGENCY', k.doorX, 1.62, fz + 1.41, 2.2, 0.25, { bg: '#dc2626', fg: '#ffffff', glow: true, backing: false });
    door(g, k.doorX, fz, { w: 1.3, h: 1.2, glass: 0xbae6fd });
    sign(g, "St Gabriel's Hospital", 0.4, 2 * FLOOR_H - 0.35, fz, 3.2, 0.36, { bg: '#ffffff', fg: '#b91c1c', emoji: '🏥' });
    const amb = ambulance();
    amb.position.set(W / 2 - 0.6, 0, fz + 1.4);
    amb.rotation.y = 0.15;
    g.add(amb);
  },

  riverside_clinic(g, k) {
    const { W, D } = k;
    const m = block(W, 2, D - 0.8, 'grid', 0xf8fafc, 0x99f6e4, 61, { ground: 'shop', roof: 0x94a3b8 });
    m.position.z = -0.4;
    g.add(m);
    const fz = -0.4 + (D - 0.8) / 2;
    g.add(at(box(W + 0.05, 0.25, D - 0.75, mat(k.color)), 0, 2 * FLOOR_H - 0.1, -0.4));
    door(g, k.doorX, fz, { canopy: k.color });
    sign(g, 'Riverside Community Clinic', 0, 2 * FLOOR_H + 0.35, fz, 3.4, 0.36, { bg: '#0f766e', fg: '#f0fdfa', emoji: '🩺' });
    const cs = crossSign(0x14b8a6, 0.8);
    cs.position.set(W / 2 - 0.6, 2 * FLOOR_H + 0.75, fz - 0.4);
    g.add(cs);
    g.add(at(flowerBed(1.2, 0.5, k.r), -1.5, 0, fz + 0.5));
  },

  tower(g, k, floors, style, glassTint, wall, sign1, setback = true) {
    const { W, D, r } = k;
    const base = block(W, 2, D - 0.6, style === 'glass' ? 'grid' : style, wall, glassTint, k.seed, { ground: 'shop' });
    base.position.z = -0.3;
    g.add(base);
    const tw = block(W - 1.0, floors - 2, D - 1.6, style, wall, glassTint, k.seed + 1);
    tw.position.set(0, 2 * FLOOR_H, -0.5);
    g.add(tw);
    let top = floors * FLOOR_H;
    if (setback) {
      const crown = block(W - 2.2, 2, D - 2.6, style, wall, glassTint, k.seed + 2);
      crown.position.set(0, top, -0.6);
      g.add(crown);
      top += 2 * FLOOR_H;
    }
    g.add(at(cyl(0.03, 0.03, 1.4, mat(0x9ca3af, { m: 0.6 }), 6), 0.6, top + 0.7, -0.6));
    const blink = mat(0xef4444, { e: 0xef4444, ei: 1 });
    g.add(at(sphere(0.05, blink, 8), 0.6, top + 1.42, -0.6));
    // accent fins
    const am = mat(k.color, { r: 0.4, m: 0.3 });
    for (const x of [-(W - 1) / 2, (W - 1) / 2]) g.add(at(box(0.12, (floors - 2) * FLOOR_H, 0.12, am), x, 2 * FLOOR_H + ((floors - 2) * FLOOR_H) / 2, -0.5 + (D - 1.6) / 2 + 0.06));
    const fz = -0.3 + (D - 0.6) / 2;
    door(g, k.doorX, fz, { w: 1.2, canopy: k.color });
    sign(g, sign1, 0, 2 * FLOOR_H - 0.3, fz, Math.min(W - 0.4, 3.6), 0.38, { bg: '#0f172a', fg: '#ffffff', emoji: k.emoji, glow: true });
    rooftopClutter(g, W, D - 0.6, 2 * FLOOR_H, r);
  },

  meridian_group(g, k) {
    ARCH.tower(g, k, 11, 'glass', 0xfdba74, 0x1e293b, 'Meridian Group');
  },
  ledger_co(g, k) {
    ARCH.tower(g, k, 7, 'grid', 0xa7f3d0, 0xe2e8f0, 'Ledger & Co', false);
  },
  ironclad_audit(g, k) {
    ARCH.tower(g, k, 9, 'glass', 0x94a3b8, 0x334155, 'Ironclad Audit');
  },

  harbor_retail(g, k) {
    const { W, D } = k;
    const m = block(W, 4, D - 0.7, 'glass', 0x0e7490, 0x67e8f9, 71, {});
    m.position.z = -0.35;
    g.add(m);
    const fz = -0.35 + (D - 0.7) / 2;
    g.add(at(box(W + 0.1, 0.3, D - 0.6, mat(0xf8fafc)), 0, 4 * FLOOR_H + 0.15, -0.35));
    door(g, k.doorX, fz, { w: 1.4, canopy: 0xf8fafc });
    sign(g, 'Harbor Retail Group', 0, 4 * FLOOR_H - 0.45, fz, 3.4, 0.4, { bg: '#083344', fg: '#a5f3fc', emoji: k.emoji, glow: true });
  },

  pixelforge(g, k) {
    const { W, D, r } = k;
    const m = block(W, 5, D - 0.7, 'grid', 0xede9fe, 0xc4b5fd, 81, { ground: 'shop' });
    m.position.z = -0.35;
    g.add(m);
    const fz = -0.35 + (D - 0.7) / 2;
    // colourful panels
    const cols = [0x8b5cf6, 0xa78bfa, 0xec4899, 0x22d3ee, 0xfacc15];
    for (let f = 1; f < 5; f++) for (let i = 0; i < 3; i++) {
      if (r() < 0.45) g.add(at(box(0.5, FLOOR_H * 0.9, 0.06, mat(cols[Math.floor(r() * cols.length)], { r: 0.5 })), -W / 2 + 0.5 + i * 1.7 + r() * 0.3, f * FLOOR_H + FLOOR_H / 2, fz + 0.03));
    }
    // pixel mural on side
    const cv = document.createElement('canvas');
    cv.width = cv.height = 128;
    const ctx = cv.getContext('2d');
    for (let y = 0; y < 16; y++) for (let x = 0; x < 16; x++) {
      ctx.fillStyle = `hsl(${(x * 18 + y * 9) % 360},80%,${45 + ((x * y) % 4) * 8}%)`;
      ctx.fillRect(x * 8, y * 8, 8, 8);
    }
    const mt = new THREE.CanvasTexture(cv);
    mt.magFilter = THREE.NearestFilter;
    mt.colorSpace = THREE.SRGBColorSpace;
    const mural = at(plane(D - 1.2, 3.2, new THREE.MeshStandardMaterial({ map: mt, roughness: 0.8 })), W / 2 + 0.011, 3.4, -0.35);
    mural.rotation.y = Math.PI / 2;
    g.add(mural);
    // rooftop garden
    g.add(at(box(W - 0.4, 0.15, D - 1.1, mat(0x65a30d, { r: 0.95 })), 0, 5 * FLOOR_H + 0.08, -0.35));
    for (let i = 0; i < 4; i++) g.add(at(tree(r, 0.6), -W / 2 + 0.8 + i * 1.1, 5 * FLOOR_H + 0.15, -0.6 + r() * 0.6));
    door(g, k.doorX, fz, { w: 1.2, canopy: 0x8b5cf6 });
    sign(g, 'PIXELFORGE', 0, 5 * FLOOR_H + 0.55, fz - 0.1, 3.4, 0.6, { bg: '#4c1d95', fg: '#f5d0fe', emoji: '🎮', glow: true });
  },

  nimbus_cloud(g, k) {
    const { W, D } = k;
    const base = block(W, 2, D - 0.7, 'glass', 0x0c4a6e, 0x7dd3fc, 91, {});
    base.position.z = -0.35;
    g.add(base);
    const R = Math.min(W, D) * 0.34;
    const tex = facadeTex('glass', 0x0c4a6e, 0x7dd3fc, 14, 7, 92);
    const tm = new THREE.MeshStandardMaterial({ map: tex.map, emissive: 0xffffff, emissiveMap: tex.emissiveMap, emissiveIntensity: 0, roughness: 0.2, metalness: 0.3 });
    tm.userData.nightGlow = true;
    nightMats.add(tm);
    const cylm = new THREE.Mesh(new THREE.CylinderGeometry(R, R, 7 * FLOOR_H, 28, 1, true), tm);
    cylm.position.set(0, 2 * FLOOR_H + 3.5 * FLOOR_H, -0.6);
    cylm.castShadow = true;
    g.add(cylm);
    g.add(at(cyl(R + 0.05, R + 0.05, 0.2, mat(0xe0f2fe), 28), 0, 9 * FLOOR_H + 0.1, -0.6));
    // cloud logo
    const cl = new THREE.Group();
    const cm = mat(0xffffff, { e: 0x7dd3fc, ei: 0.3 });
    cm.userData.nightGlow = true;
    nightMats.add(cm);
    for (const [x, y, s] of [[-0.3, 0, 0.3], [0, 0.15, 0.4], [0.32, 0, 0.3]]) cl.add(at(sphere(s, cm, 14), x, y, 0));
    cl.position.set(0, 9 * FLOOR_H + 0.7, -0.6);
    g.add(cl);
    const fz = -0.35 + (D - 0.7) / 2;
    door(g, k.doorX, fz, { w: 1.3, canopy: 0x0ea5e9 });
    sign(g, 'Nimbus Cloud Systems', 0, 2 * FLOOR_H - 0.3, fz, 3.4, 0.38, { bg: '#0c4a6e', fg: '#e0f2fe', emoji: '☁️', glow: true });
  },

  lawfirm(g, k, title, wall) {
    const { W, D } = k;
    const m = block(W, 4, D - 0.7, 'classic', wall, 0xbfdbfe, k.seed, { roof: 0x3f3f46 });
    m.position.z = -0.35;
    g.add(m);
    const fz = -0.35 + (D - 0.7) / 2;
    g.add(at(box(W + 0.12, 0.2, D - 0.55, mat(shade(wall, 0.25))), 0, 4 * FLOOR_H + 0.1, -0.35));
    awning(g, 1.6, k.doorX, 1.35, fz, k.color, 0x111827, 0.5);
    door(g, k.doorX, fz, { frame: 0x111827, glass: 0x1f2937, h: 1.15 });
    sign(g, title, 0, 2 * FLOOR_H - 0.2, fz, 3.0, 0.32, { bg: '#111827', fg: '#fde68a', emoji: k.emoji, font: 'serif' });
    for (const x of [-1.6, 1.6]) {
      const lamp = at(new THREE.Group(), k.doorX + x * 0.6, 0, fz + 0.3);
      lamp.add(at(cyl(0.03, 0.03, 1.2, mat(0x111827), 6), 0, 0.6, 0));
      const lm = mat(0xfff7d6, { e: 0xffd27a, ei: 0.2 });
      lm.userData.nightGlow = true;
      nightMats.add(lm);
      lamp.add(at(box(0.14, 0.2, 0.14, lm), 0, 1.25, 0));
      g.add(lamp);
    }
  },
  whitmore_lane(g, k) {
    ARCH.lawfirm(g, k, 'Whitmore & Lane LLP', 0x9a5b3c);
  },
  civic_legal(g, k) {
    ARCH.lawfirm(g, k, 'Civic Legal Aid', 0xc9a27e);
  },

  courthouse(g, k) {
    const { W, D } = k;
    const stone = 0xe7e5e4;
    const m = block(W, 3, D - 1.3, 'classic', stone, 0xcbd5e1, 101, { roof: 0x78716c });
    m.position.z = -0.65;
    g.add(m);
    const fz = -0.65 + (D - 1.3) / 2;
    columns(g, 4, W - 0.7, 0, fz + 0.8, 2.6, 0.1);
    g.add(at(box(W + 0.1, 0.22, 1.2, mat(0xf5f5f4)), 0, 2.88, fz + 0.5));
    pediment(g, W + 0.1, 0, 2.99, fz + 0.5, 1.2, 0xf5f5f4);
    steps(g, W, fz + 1.0, 3);
    door(g, k.doorX, fz, { w: 0.9, h: 1.6, frame: 0x44403c, glass: 0x57534e });
    sign(g, 'Courthouse', 0, 3.26, fz + 1.11, 1.6, 0.26, { bg: '#f5f5f4', fg: '#292524', emoji: '⚖️', font: 'serif', backing: false });
    const flag = at(new THREE.Group(), W / 2 - 0.2, 3 * FLOOR_H, -0.65);
    flag.add(at(cyl(0.02, 0.02, 1.6, mat(0x9ca3af), 6), 0, 0.8, 0));
    flag.add(at(box(0.55, 0.32, 0.01, mat(0x2563eb)), 0.3, 1.4, 0));
    g.add(flag);
  },

  mall(g, k) {
    const { W, D, r } = k;
    const m = block(W, 3, D - 0.8, 'grid', 0xfdf2f8, 0xf9a8d4, 111, { ground: 'shop', roof: 0xcbd5e1 });
    m.position.z = -0.4;
    g.add(m);
    const fz = -0.4 + (D - 0.8) / 2;
    // glass atrium
    const atr = block(2.2, 4, 1.0, 'glass', 0x9d174d, 0xfbcfe8, 112, {});
    atr.position.set(k.doorX, 0, fz + 0.15);
    g.add(atr);
    const cols = [0xec4899, 0xf59e0b, 0x8b5cf6, 0x10b981];
    for (let i = 0; i < 4; i++) {
      const x = -W / 2 + 0.45 + i * ((W - 0.9) / 3);
      if (Math.abs(x - k.doorX) < 1.3) continue;
      g.add(at(box(0.36, 1.4, 0.03, mat(cols[i], { r: 0.7 })), x, 2.3, fz + 0.04));
    }
    door(g, k.doorX, fz + 0.65, { w: 1.3, glass: 0xfbcfe8 });
    sign(g, 'GradeGlow Mall', k.doorX, 4 * FLOOR_H + 0.35, fz + 0.65, 2.7, 0.45, { bg: '#831843', fg: '#fce7f3', emoji: '🛍️', glow: true });
    for (const x of [-2, 2]) g.add(at(planter(r), k.doorX + x, 0, fz + 0.75));
  },

  grocery(g, k) {
    const { W, D, r } = k;
    const m = block(W, 2, D - 1.2, 'grid', 0xf0fdf4, 0xbbf7d0, 121, { ground: 'shop', roof: 0x166534 });
    m.position.z = -0.6;
    g.add(m);
    const fz = -0.6 + (D - 1.2) / 2;
    awning(g, W - 0.2, 0, 1.18, fz, 0x16a34a, 0xffffff, 0.75);
    door(g, k.doorX, fz, { glass: 0xbbf7d0 });
    sign(g, 'Fresh Mart', 0, 1.95, fz, 2.4, 0.4, { bg: '#14532d', fg: '#dcfce7', emoji: '🛒', glow: true });
    const fruit = [0xef4444, 0xf97316, 0xfacc15, 0x84cc16];
    for (let i = 0; i < 2; i++) {
      const x = (i ? 1 : -1) * 1.4;
      const crate = at(new THREE.Group(), k.doorX + x, 0, fz + 0.55);
      crate.add(at(box(0.8, 0.35, 0.45, mat(0xa16207)), 0, 0.18, 0));
      for (let j = 0; j < 10; j++) crate.add(at(sphere(0.065, mat(fruit[(i * 2 + j) % 4], { r: 0.5 }), 8), -0.32 + (j % 5) * 0.16, 0.4, -0.1 + Math.floor(j / 5) * 0.18));
      g.add(crate);
    }
  },

  bank(g, k) {
    const { W, D } = k;
    const m = block(W, 3, D - 1.1, 'classic', 0xf1f5f9, 0xbfdbfe, 131, { roof: 0x64748b });
    m.position.z = -0.55;
    g.add(m);
    const fz = -0.55 + (D - 1.1) / 2;
    columns(g, 4, W - 1.1, 0, fz + 0.5, 2.5, 0.11, 0xf8fafc);
    g.add(at(box(W - 0.3, 0.25, 0.9, mat(0xf8fafc)), 0, 2.78, fz + 0.35));
    g.add(at(box(W - 0.3, 0.06, 0.92, mat(0xd4a017, { r: 0.3, m: 0.7 })), 0, 2.93, fz + 0.35));
    steps(g, W - 0.6, fz + 0.75, 2);
    door(g, k.doorX, fz, { w: 0.95, h: 1.5, frame: 0xa16207, glass: 0x1e3a8a });
    sign(g, 'GLOW BANK', 0, 2.78, fz + 0.81, 2.2, 0.24, { bg: '#f8fafc', fg: '#065f46', emoji: '🏦', font: 'serif', backing: false });
  },

  employment_center(g, k) {
    const { W, D, r } = k;
    const m = block(W, 3, D - 0.8, 'glass', 0x7c2d12, 0xfed7aa, 141, {});
    m.position.z = -0.4;
    g.add(m);
    const fz = -0.4 + (D - 0.8) / 2;
    const om = mat(0xf97316, { r: 0.5 });
    for (let i = 0; i < 7; i++) g.add(at(box(0.1, 3 * FLOOR_H, 0.3, om), -W / 2 + 0.15 + i * ((W - 0.3) / 6), 1.5 * FLOOR_H, fz + 0.14));
    g.add(at(box(W + 0.2, 0.18, D - 0.6, mat(0xffffff)), 0, 3 * FLOOR_H + 0.09, -0.4));
    // big rooftop sign
    const s = sign(g, 'EMPLOYMENT CENTRE', 0, 3 * FLOOR_H + 0.75, fz - 0.4, W - 0.2, 0.7, { bg: '#ea580c', fg: '#ffffff', emoji: '💼', glow: true });
    g.add(at(box(0.08, 0.7, 0.08, mat(0x374151)), -1.5, 3 * FLOOR_H + 0.35, fz - 0.45));
    g.add(at(box(0.08, 0.7, 0.08, mat(0x374151)), 1.5, 3 * FLOOR_H + 0.35, fz - 0.45));
    // hiring banner
    sign(g, 'NOW HIRING · Interviews today', 0, 2 * FLOOR_H + 0.2, fz + 0.3, 3.4, 0.36, { bg: '#fff7ed', fg: '#c2410c', backing: false });
    g.add(at(box(2.4, 0.1, 1.2, mat(0xf97316)), k.doorX, 1.32, fz + 0.6));
    door(g, k.doorX, fz, { w: 1.4, h: 1.2, glass: 0xfed7aa });
    g.add(at(flowerBed(1.0, 0.5, r), -1.8, 0, fz + 0.5));
    g.add(at(flowerBed(1.0, 0.5, r), 1.8, 0, fz + 0.5));
  },

  company_registry(g, k) {
    const { W, D } = k;
    const m = block(W, 3, D - 0.9, 'grid', 0xe0f2fe, 0x7dd3fc, 151, { roof: 0x0369a1 });
    m.position.z = -0.45;
    g.add(m);
    const fz = -0.45 + (D - 0.9) / 2;
    g.add(at(box(W + 0.05, 0.3, 0.1, mat(k.color)), 0, 2 * FLOOR_H, fz + 0.05));
    door(g, k.doorX, fz, { canopy: k.color });
    sign(g, 'Company Registry', 0, 3 * FLOOR_H - 0.4, fz, 2.8, 0.34, { bg: '#0c4a6e', fg: '#e0f2fe', emoji: '📋' });
  },

  cinema(g, k) {
    const { W, D } = k;
    const m = block(W, 3, D - 0.9, 'grid', 0x7f1d1d, 0xfca5a5, 161, { roof: 0x450a0a });
    m.position.z = -0.45;
    g.add(m);
    const fz = -0.45 + (D - 0.9) / 2;
    // marquee
    g.add(at(box(W - 0.4, 0.5, 1.0, mat(0x111827)), 0, 1.55, fz + 0.5));
    sign(g, 'NOW SHOWING · The Interview', 0, 1.55, fz + 1.0, W - 0.6, 0.36, { bg: '#fefce8', fg: '#b91c1c', backing: false });
    const bulb = mat(0xfff7c2, { e: 0xffd166, ei: 0.4 });
    bulb.userData.nightGlow = true;
    nightMats.add(bulb);
    for (let i = 0; i < 14; i++) g.add(at(sphere(0.035, bulb, 6), -W / 2 + 0.3 + i * ((W - 0.6) / 13), 1.83, fz + 1.01));
    const v = sign(g, 'STARLIGHT', W / 2 - 0.5, 2.9, fz + 0.3, 2.3, 0.5, { bg: '#b91c1c', fg: '#fde68a', glow: true, backing: false });
    v.rotation.z = Math.PI / 2;
    v.position.x = W / 2 - 0.3;
    for (const x of [-1.6, 1.6]) sign(g, x < 0 ? '🎬' : '🍿', k.doorX + x * 0.85, 0.75, fz, 0.6, 0.9, { bg: '#1f2937', fg: '#ffffff', w: 256, h: 384 });
    door(g, k.doorX, fz, { w: 1.2, glass: 0x7f1d1d });
  },

  gym(g, k) {
    const { W, D } = k;
    const m = block(W, 2, D - 0.8, 'glass', 0x134e4a, 0x5eead4, 171, {});
    m.position.z = -0.4;
    g.add(m);
    const fz = -0.4 + (D - 0.8) / 2;
    g.add(at(box(W + 0.1, 0.5, D - 0.7, mat(0x0d9488)), 0, 2 * FLOOR_H + 0.25, -0.4));
    sign(g, 'PULSEFIT', 0, 2 * FLOOR_H + 0.25, fz + 0.06, 2.2, 0.36, { bg: '#0d9488', fg: '#ffffff', emoji: '🏋️', glow: true, backing: false });
    door(g, k.doorX, fz, { glass: 0x99f6e4 });
    // dumbbell sculpture
    const db = at(new THREE.Group(), -W / 2 + 0.6, 0, fz + 0.5);
    db.add(at(cyl(0.04, 0.04, 0.7, mat(0x6b7280, { m: 0.7 }), 8), 0, 0.3, 0).rotateZ(Math.PI / 2));
    for (const x of [-0.3, 0.3]) db.add(at(cyl(0.17, 0.17, 0.12, mat(0x111827), 14), x, 0.3, 0).rotateZ(Math.PI / 2));
    g.add(db);
  },

  park(g, k) {
    const { W, D, r } = k;
    // lawn
    g.add(at(box(W + 0.4, 0.06, D + 0.4, mat(0x7bc96f, { r: 1 })), 0, 0.03, 0));
    // paths
    const pm = mat(0xe7d7b8, { r: 1 });
    g.add(at(box(0.7, 0.02, D + 0.4, pm), k.doorX, 0.07, 0));
    g.add(at(box(W + 0.4, 0.02, 0.6, pm), 0, 0.07, -0.2));
    // fountain
    const f = at(new THREE.Group(), k.doorX, 0.06, -0.2);
    f.add(at(cyl(0.9, 1.0, 0.25, mat(0xd6d3d1), 24), 0, 0.12, 0));
    const water = at(cyl(0.82, 0.82, 0.05, mat(0x38bdf8, { r: 0.1, m: 0.2, t: 0.85 }), 24), 0, 0.22, 0);
    f.add(water);
    f.add(at(cyl(0.12, 0.16, 0.6, mat(0xd6d3d1), 12), 0, 0.5, 0));
    f.add(at(cyl(0.35, 0.2, 0.08, mat(0xd6d3d1), 16), 0, 0.82, 0));
    f.add(at(sphere(0.12, mat(0x7dd3fc, { t: 0.7, e: 0x38bdf8, ei: 0.3 }), 10), 0, 0.95, 0));
    g.add(f);
    // hedges
    const hm = mat(0x3f7f2f, { r: 0.95, flat: true });
    g.add(at(rbox(W + 0.3, 0.4, 0.3, 0.1, hm), 0, 0.2, -D / 2 - 0.05));
    for (const s of [-1, 1]) g.add(at(rbox(0.3, 0.4, D + 0.1, 0.1, hm), s * (W / 2 + 0.05), 0.2, 0));
    for (const s of [-1, 1]) g.add(at(rbox((W - 0.9) / 2, 0.4, 0.3, 0.1, hm), s * ((W + 0.9) / 4 + 0.1), 0.2, D / 2 + 0.05));
    // trees & benches
    for (let i = 0; i < 9; i++) {
      const tx = (r() - 0.5) * (W - 0.8);
      const tz = (r() - 0.5) * (D - 0.8);
      if (Math.abs(tx - k.doorX) < 0.7 || Math.abs(tz + 0.2) < 1.1) continue;
      g.add(at(tree(r, 1.15 + r() * 0.4), tx, 0.06, tz));
    }
    for (const x of [-1.4, 1.4]) g.add(at(bench(), k.doorX + x, 0.06, 0.9));
    // gate
    const gm = mat(0x365314, { r: 0.6 });
    for (const x of [-0.55, 0.55]) g.add(at(box(0.12, 1.6, 0.12, gm), k.doorX + x, 0.8, D / 2 + 0.05));
    g.add(at(box(1.3, 0.12, 0.14, gm), k.doorX, 1.62, D / 2 + 0.05));
    sign(g, 'Skyline Park', k.doorX, 1.9, D / 2 + 0.05, 1.8, 0.3, { bg: '#365314', fg: '#ecfccb', emoji: '🌳', backing: false });
  },
};

function generic(g, k) {
  const { W, D } = k;
  const m = block(W, 3, D - 0.8, 'grid', shade(k.color, 0.75), shade(k.color, 0.4), k.seed, { ground: 'shop' });
  m.position.z = -0.4;
  g.add(m);
  const fz = -0.4 + (D - 0.8) / 2;
  door(g, k.doorX, fz, { canopy: k.color });
  sign(g, k.name, 0, 3 * FLOOR_H - 0.4, fz, Math.min(W - 0.3, 3.4), 0.34, { bg: '#111827', fg: '#ffffff', emoji: k.emoji });
}

/**
 * Builds a building group in world space. b = {id,name,emoji,x,y,w,h,color,...}
 * Returns {group, height}.
 */
export function makeBuilding(b) {
  const g = new THREE.Group();
  const x0 = b.x - 0.5;
  const x1 = b.x + b.w - 0.5;
  const z0 = b.y - 0.5;
  const z1 = b.y + b.h - 0.5;
  const cx = (x0 + x1) / 2;
  const cz = (z0 + z1) / 2;
  g.position.set(cx, 0, cz);
  const W = b.w - 0.45;
  const D = b.h - 0.45;
  const doorX = b.x + Math.floor(b.w / 2) - cx;
  const k = {
    W,
    D,
    front: D / 2,
    doorX,
    color: b.color,
    emoji: b.emoji,
    name: b.name,
    seed: Number(String(b.id).split('').reduce((a, c) => a + c.charCodeAt(0), 0)),
    r: rng('b:' + b.id),
  };
  const fn = ARCH[b.id];
  if (fn) fn(g, k);
  else generic(g, k);

  let top = 0;
  const bbox = new THREE.Box3().setFromObject(g);
  top = bbox.max.y;
  g.traverse((o) => {
    o.userData.pick = { kind: 'building', id: b.id };
  });
  // per-building material clones so we can fade this building alone
  const fadeMats = [];
  const per = new Map();
  const cloneOf = (m) => {
    if (per.has(m)) return per.get(m);
    const c = m.clone();
    c.userData = { ...m.userData, baseOpacity: m.opacity, baseTransparent: m.transparent };
    if (m.userData.nightGlow) nightMats.add(c);
    per.set(m, c);
    fadeMats.push(c);
    return c;
  };
  g.traverse((o) => {
    if (!o.isMesh) return;
    o.material = Array.isArray(o.material) ? o.material.map(cloneOf) : cloneOf(o.material);
  });
  mergeStatic(g);
  g.userData.fadeMats = fadeMats;
  g.userData.fade = 1;
  g.userData.height = top;
  return { group: g, height: top };
}

