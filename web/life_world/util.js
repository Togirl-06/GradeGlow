// Shared helpers for the GradeGlow 3D world: materials, primitives, text textures.
import * as THREE from 'three';
import { RoundedBoxGeometry } from './vendor/RoundedBoxGeometry.js';
import { mergeGeometries } from './vendor/BufferGeometryUtils.js';

/** Converts a Dart ARGB int (0xAARRGGBB) or '#rrggbb' to a THREE.Color. */
export function col(v) {
  if (v instanceof THREE.Color) return v.clone();
  if (typeof v === 'string') return new THREE.Color(v);
  return new THREE.Color((Number(v) >>> 0) & 0xffffff);
}

export function hex(v) {
  return '#' + col(v).getHexString();
}

/** Lighten (f>0) or darken (f<0) a colour, f in -1..1. */
export function shade(v, f) {
  const c = col(v);
  const t = f < 0 ? new THREE.Color(0x000000) : new THREE.Color(0xffffff);
  return c.lerp(t, Math.abs(f));
}

const _mats = new Map();
/** Cached standard material. opts: r(roughness) m(metalness) e(emissive) ei(emissiveIntensity) t(opacity) */
export function mat(color, opts = {}) {
  const c = col(color);
  const key = c.getHexString() + JSON.stringify(opts);
  let m = _mats.get(key);
  if (!m) {
    m = new THREE.MeshStandardMaterial({
      color: c,
      roughness: opts.r ?? 0.78,
      metalness: opts.m ?? 0.0,
      flatShading: !!opts.flat,
    });
    if (opts.e !== undefined) {
      m.emissive = col(opts.e);
      m.emissiveIntensity = opts.ei ?? 1;
    }
    if (opts.t !== undefined) {
      m.transparent = true;
      m.opacity = opts.t;
      m.depthWrite = opts.t > 0.6;
    }
    _mats.set(key, m);
  }
  return m;
}

const _geos = new Map();
function geo(key, make) {
  let g = _geos.get(key);
  if (!g) {
    g = make();
    _geos.set(key, g);
  }
  return g;
}

function finish(mesh, cast = true, receive = true) {
  mesh.castShadow = cast;
  mesh.receiveShadow = receive;
  return mesh;
}

export function box(w, h, d, color, opts) {
  const g = geo(`b${w}|${h}|${d}`, () => new THREE.BoxGeometry(w, h, d));
  return finish(new THREE.Mesh(g, color instanceof THREE.Material ? color : mat(color, opts)));
}

export function rbox(w, h, d, r, color, opts) {
  const rr = Math.min(r, w / 2 - 1e-3, h / 2 - 1e-3, d / 2 - 1e-3);
  const g = geo(`r${w}|${h}|${d}|${rr}`, () => new RoundedBoxGeometry(w, h, d, 3, rr));
  return finish(new THREE.Mesh(g, color instanceof THREE.Material ? color : mat(color, opts)));
}

export function cyl(rt, rb, h, color, seg = 16, opts) {
  const g = geo(`c${rt}|${rb}|${h}|${seg}`, () => new THREE.CylinderGeometry(rt, rb, h, seg));
  return finish(new THREE.Mesh(g, color instanceof THREE.Material ? color : mat(color, opts)));
}

export function sphere(r, color, seg = 16, opts) {
  const g = geo(`s${r}|${seg}`, () => new THREE.SphereGeometry(r, seg, Math.max(6, Math.round(seg * 0.75))));
  return finish(new THREE.Mesh(g, color instanceof THREE.Material ? color : mat(color, opts)));
}

export function capsule(r, len, color, opts) {
  const g = geo(`p${r}|${len}`, () => new THREE.CapsuleGeometry(r, len, 4, 10));
  return finish(new THREE.Mesh(g, color instanceof THREE.Material ? color : mat(color, opts)));
}

export function cone(r, h, color, seg = 12, opts) {
  const g = geo(`k${r}|${h}|${seg}`, () => new THREE.ConeGeometry(r, h, seg));
  return finish(new THREE.Mesh(g, color instanceof THREE.Material ? color : mat(color, opts)));
}

export function torus(r, tube, color, arc = Math.PI * 2, opts) {
  const g = geo(`t${r}|${tube}|${arc}`, () => new THREE.TorusGeometry(r, tube, 8, 20, arc));
  return finish(new THREE.Mesh(g, color instanceof THREE.Material ? color : mat(color, opts)));
}

export function plane(w, h, material) {
  const g = geo(`pl${w}|${h}`, () => new THREE.PlaneGeometry(w, h));
  return finish(new THREE.Mesh(g, material), false, true);
}

/** Position helper: returns obj after setting position (and optional y rotation). */
export function at(obj, x, y, z, ry = 0) {
  obj.position.set(x, y, z);
  if (ry) obj.rotation.y = ry;
  return obj;
}

export function group(...children) {
  const g = new THREE.Group();
  for (const c of children) if (c) g.add(c);
  return g;
}

// ---------------------------------------------------------------- text

const EMOJI_FONT = '"Apple Color Emoji","Segoe UI Emoji","Noto Color Emoji",sans-serif';
const UI_FONT = '700 {S}px "Nunito","Segoe UI",system-ui,-apple-system,Roboto,sans-serif';

function roundRect(ctx, x, y, w, h, r) {
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.arcTo(x + w, y, x + w, y + h, r);
  ctx.arcTo(x + w, y + h, x, y + h, r);
  ctx.arcTo(x, y + h, x, y, r);
  ctx.arcTo(x, y, x + w, y, r);
  ctx.closePath();
}

/**
 * Floating label (always faces the camera). Returns a Sprite whose scale is
 * set so that its height is `worldH` units.
 */
export function labelSprite(text, { emoji = '', bg = 'rgba(15,23,42,0.86)', fg = '#ffffff', accent = null, worldH = 0.42, sub = '' } = {}) {
  const S = 64;
  const c = document.createElement('canvas');
  const ctx = c.getContext('2d');
  ctx.font = UI_FONT.replace('{S}', S);
  const tw = ctx.measureText(text).width;
  let sw = 0;
  if (sub) {
    ctx.font = UI_FONT.replace('{S}', Math.round(S * 0.62)).replace('700', '600');
    sw = ctx.measureText(sub).width;
  }
  const ew = emoji ? S * 1.25 : 0;
  const padX = S * 0.5;
  const h = sub ? S * 2.25 : S * 1.5;
  const w = Math.ceil(padX * 2 + ew + Math.max(tw, sw));
  c.width = w;
  c.height = Math.ceil(h + 10);
  ctx.font = UI_FONT.replace('{S}', S);
  ctx.fillStyle = bg;
  roundRect(ctx, 2, 2, w - 4, h, h * 0.3);
  ctx.fill();
  if (accent) {
    ctx.strokeStyle = accent;
    ctx.lineWidth = 5;
    ctx.stroke();
  }
  // little pointer
  ctx.beginPath();
  ctx.moveTo(w / 2 - 10, h + 1);
  ctx.lineTo(w / 2 + 10, h + 1);
  ctx.lineTo(w / 2, h + 9);
  ctx.closePath();
  ctx.fillStyle = bg;
  ctx.fill();
  ctx.textBaseline = 'middle';
  const cy = sub ? h * 0.36 : h / 2 + 2;
  if (emoji) {
    ctx.font = `${Math.round(S * 0.92)}px ${EMOJI_FONT}`;
    ctx.fillText(emoji, padX - 4, cy + 2);
  }
  ctx.font = UI_FONT.replace('{S}', S);
  ctx.fillStyle = fg;
  ctx.fillText(text, padX + ew, cy);
  if (sub) {
    ctx.font = UI_FONT.replace('{S}', Math.round(S * 0.62)).replace('700', '600');
    ctx.fillStyle = 'rgba(255,255,255,0.72)';
    ctx.fillText(sub, padX + ew, h * 0.74);
  }
  const tex = new THREE.CanvasTexture(c);
  tex.colorSpace = THREE.SRGBColorSpace;
  tex.anisotropy = 4;
  const m = new THREE.SpriteMaterial({ map: tex, depthWrite: false, transparent: true });
  const s = new THREE.Sprite(m);
  s.center.set(0.5, 0);
  const sc = worldH / (h + 10) ;
  s.scale.set(c.width * sc, c.height * sc, 1);
  s.renderOrder = 10;
  return s;
}

/** Flat sign texture (for building fronts). */
export function signMaterial(text, { bg = '#1f2937', fg = '#ffffff', emoji = '', glow = false, font = 'sans', w = 1024, h = 192 } = {}) {
  const c = document.createElement('canvas');
  c.width = w;
  c.height = h;
  const ctx = c.getContext('2d');
  ctx.fillStyle = bg;
  ctx.fillRect(0, 0, w, h);
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  let size = Math.round(h * 0.52);
  const face = font === 'serif' ? `700 {S}px Georgia,"Times New Roman",serif` : UI_FONT;
  ctx.font = face.replace('{S}', size);
  const label = text;
  const ew = emoji ? size * 1.2 : 0;
  while (ctx.measureText(label).width + ew > w * 0.9 && size > 12) {
    size -= 2;
    ctx.font = face.replace('{S}', size);
  }
  const tw = ctx.measureText(label).width;
  if (emoji) {
    ctx.font = `${Math.round(size * 0.95)}px ${EMOJI_FONT}`;
    ctx.fillText(emoji, w / 2 - tw / 2 - ew / 2 + 4, h / 2 + 3);
    ctx.font = face.replace('{S}', size);
  }
  ctx.fillStyle = fg;
  if (glow) {
    ctx.shadowColor = fg;
    ctx.shadowBlur = 18;
  }
  ctx.fillText(label, w / 2 + ew / 2, h / 2 + 3);
  const tex = new THREE.CanvasTexture(c);
  tex.colorSpace = THREE.SRGBColorSpace;
  tex.anisotropy = 8;
  const m = new THREE.MeshStandardMaterial({ map: tex, roughness: 0.6 });
  if (glow) {
    m.emissive = new THREE.Color(0xffffff);
    m.emissiveMap = tex;
    m.emissiveIntensity = 0.5;
    m.userData.nightGlow = true;
  }
  return m;
}

/** Simple seeded RNG (mulberry32). */
export function rng(seed) {
  let a = typeof seed === 'number' ? seed >>> 0 : hashStr(String(seed));
  return () => {
    a |= 0;
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

export function hashStr(s) {
  let h = 2166136261;
  for (let i = 0; i < s.length; i++) {
    h ^= s.charCodeAt(i);
    h = Math.imul(h, 16777619);
  }
  return h >>> 0;
}

export function pick(r, list) {
  return list[Math.floor(r() * list.length) % list.length];
}

export const lerp = (a, b, t) => a + (b - a) * t;
export const clamp = (v, a, b) => (v < a ? a : v > b ? b : v);
export const smooth = (t) => t * t * (3 - 2 * t);

/**
 * Merges the static meshes under `root` into one mesh per (material, pick,
 * shadow) so a building or a room costs a handful of draw calls instead of
 * hundreds. Subtrees marked userData.dynamic are left untouched, as are
 * meshes with material arrays.
 */
export function mergeStatic(root) {
  root.updateMatrixWorld(true);
  const inv = new THREE.Matrix4().copy(root.matrixWorld).invert();
  const buckets = new Map();
  const victims = [];
  (function walk(o) {
    if (o !== root && o.userData.dynamic) return;
    if (o.isMesh && !Array.isArray(o.material) && o.geometry && o.geometry.attributes.position && !o.userData.keep) {
      const pk = o.userData.pick ? o.userData.pick.kind + ':' + (o.userData.pick.id ?? '') : '';
      const key = o.material.uuid + '|' + pk + '|' + (o.castShadow ? 1 : 0);
      let b = buckets.get(key);
      if (!b) buckets.set(key, (b = { mat: o.material, pick: o.userData.pick, cast: o.castShadow, geos: [] }));
      let g = o.geometry.index ? o.geometry.toNonIndexed() : o.geometry.clone();
      for (const name of Object.keys(g.attributes)) if (!['position', 'normal', 'uv'].includes(name)) g.deleteAttribute(name);
      if (!g.attributes.uv) g.setAttribute('uv', new THREE.Float32BufferAttribute(new Float32Array((g.attributes.position.count) * 2), 2));
      if (!g.attributes.normal) g.computeVertexNormals();
      g.applyMatrix4(new THREE.Matrix4().multiplyMatrices(inv, o.matrixWorld));
      b.geos.push(g);
      victims.push(o);
    }
    for (const c of o.children) walk(c);
  })(root);
  for (const v of victims) v.parent && v.parent.remove(v);
  for (const b of buckets.values()) {
    const geo = b.geos.length === 1 ? b.geos[0] : mergeGeometries(b.geos, false);
    if (!geo) continue;
    const m = new THREE.Mesh(geo, b.mat);
    m.castShadow = b.cast;
    m.receiveShadow = true;
    if (b.pick) m.userData.pick = b.pick;
    root.add(m);
  }
  return root;
}
