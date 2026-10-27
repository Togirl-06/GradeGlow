// Procedural stylised characters (player + NPCs) with simple skeletal-style animation.
import * as THREE from 'three';
import { box, rbox, sphere, capsule, cyl, torus, mat, col, shade, group, at, labelSprite, hashStr, mergeStatic } from './util.js';

const HUMAN_SCALE = 0.46; // human units (≈1.9 tall incl. big head) → world (≈0.88 tiles)

const _hairGeo = new Map();
function capGeo(r, thetaLen) {
  const k = `${r}|${thetaLen}`;
  if (!_hairGeo.has(k)) _hairGeo.set(k, new THREE.SphereGeometry(r, 22, 14, 0, Math.PI * 2, 0, thetaLen));
  return _hairGeo.get(k);
}

let _shadowTex = null;
function blobShadow() {
  if (!_shadowTex) {
    const c = document.createElement('canvas');
    c.width = c.height = 64;
    const g = c.getContext('2d');
    const gr = g.createRadialGradient(32, 32, 2, 32, 32, 31);
    gr.addColorStop(0, 'rgba(0,0,0,0.42)');
    gr.addColorStop(1, 'rgba(0,0,0,0)');
    g.fillStyle = gr;
    g.fillRect(0, 0, 64, 64);
    _shadowTex = new THREE.CanvasTexture(c);
  }
  const m = new THREE.Mesh(
    new THREE.PlaneGeometry(0.9, 0.9),
    new THREE.MeshBasicMaterial({ map: _shadowTex, transparent: true, depthWrite: false }),
  );
  m.rotation.x = -Math.PI / 2;
  m.position.y = 0.012;
  m.renderOrder = 1;
  return m;
}

/** Default look used when nothing is provided. */
export const DEFAULT_LOOK = {
  skin: 0xffe0ac69,
  hair: 0xff2c1810,
  outfit: 0xff3b82f6,
  shoes: 0xff263238,
  hairStyle: 'short',
  accessory: 'none',
  faceShape: 'oval',
  eyeStyle: 'round',
  feminine: false,
  uniform: 'casual',
};

/** Infers a work uniform from an NPC role string. */
export function uniformForRole(role = '') {
  const r = role.toLowerCase();
  if (r.includes('nurs') || r.includes('matron')) return 'scrubs';
  if (r.includes('of medicine') || r.includes('medical student')) return 'labcoat';
  if (r.includes('of law')) return 'suit';
  if (r.includes('doctor') || r.startsWith('dr') || r.includes('physician') || r.includes('pharmac')) return 'labcoat';
  if (r.includes('lawyer') || r.includes('partner') || r.includes('judge') || r.includes('clerk') || r.includes('bank') || r.includes('director')) return 'suit';
  if (r.includes('patient')) return 'gown';
  return 'casual';
}

function pantsColor(outfit) {
  const c = col(outfit);
  const hsl = {};
  c.getHSL(hsl);
  if (hsl.l < 0.25) return new THREE.Color(0xd6c7a8); // light chinos under dark tops
  return new THREE.Color(0x2b3445);
}

/**
 * Builds a character. Returns an object with:
 *   root  – THREE.Group placed at the feet, facing +z
 *   update(dt, pose) – animates; pose = {walking, speed, action, emotion}
 */
export function makeCharacter(lookIn = {}, { mood = false, name = '', role = '' } = {}) {
  const look = { ...DEFAULT_LOOK, ...lookIn };
  const uniform = look.uniform || 'casual';
  const skin = mat(look.skin, { r: 0.62 });
  const hairM = mat(look.hair, { r: 0.55 });
  let top = col(look.outfit);
  let bottom = pantsColor(look.outfit);
  if (uniform === 'scrubs') {
    top = col(look.outfit);
    const h = {};
    top.getHSL(h);
    if (h.s < 0.2 || h.l < 0.2) top = new THREE.Color(0x2bb3a4);
    bottom = top.clone().multiplyScalar(0.88);
  } else if (uniform === 'suit') {
    top = new THREE.Color(0x1f2937);
    bottom = new THREE.Color(0x1f2937);
  } else if (uniform === 'gown') {
    top = new THREE.Color(0xa7c7e7);
    bottom = new THREE.Color(0xa7c7e7);
  }
  const topM = mat(top, { r: 0.85 });
  const botM = mat(bottom, { r: 0.85 });
  const shoeM = mat(look.shoes ?? 0xff263238, { r: 0.5 });
  const fem = !!look.feminine;

  const root = new THREE.Group();
  root.name = 'character';
  const body = new THREE.Group();
  body.scale.setScalar(HUMAN_SCALE);
  root.add(body);
  root.add(blobShadow());

  // ---- hips & legs
  const hips = at(new THREE.Group(), 0, 0.92, 0);
  body.add(hips);
  hips.add(at(rbox(fem ? 0.38 : 0.36, 0.22, 0.22, 0.08, botM), 0, 0, 0));

  function leg(side) {
    const p = at(new THREE.Group(), side * 0.1, -0.03, 0);
    p.add(at(capsule(0.078, 0.34, botM), 0, -0.22, 0));
    const knee = at(new THREE.Group(), 0, -0.44, 0);
    knee.add(at(capsule(0.066, 0.3, botM), 0, -0.2, 0));
    knee.add(at(rbox(0.14, 0.1, 0.27, 0.04, shoeM), 0, -0.42, 0.045));
    p.add(knee);
    hips.add(p);
    return { p, knee };
  }
  const legL = leg(1);
  const legR = leg(-1);

  // ---- torso
  const spine = at(new THREE.Group(), 0, 0.07, 0);
  hips.add(spine);
  const shoulderW = fem ? 0.4 : 0.46;
  spine.add(at(rbox(shoulderW, 0.52, 0.25, 0.1, topM), 0, 0.26, 0));
  if (uniform === 'scrubs') {
    // v-neck and a pocket
    const v = at(rbox(0.12, 0.08, 0.02, 0.01, skin), 0, 0.46, 0.125);
    spine.add(v);
    spine.add(at(box(0.1, 0.08, 0.01, shade(top, -0.15)), -0.1, 0.32, 0.128));
  } else if (uniform === 'labcoat') {
    const coat = mat(0xf8fafc, { r: 0.9 });
    spine.add(at(rbox(shoulderW + 0.04, 0.56, 0.27, 0.1, coat), 0, 0.25, 0));
    const tail = at(rbox(shoulderW * 0.92, 0.36, 0.25, 0.06, coat), 0, -0.14, 0);
    spine.add(tail);
    spine.add(at(box(0.11, 0.3, 0.02, top), 0, 0.33, 0.137)); // shirt strip
    spine.add(at(torus(0.06, 0.012, 0x334155, Math.PI), 0.12, 0.42, 0.14)); // stethoscope
  } else if (uniform === 'suit') {
    spine.add(at(box(0.1, 0.34, 0.02, 0xf8fafc), 0, 0.34, 0.127));
    spine.add(at(box(0.045, 0.26, 0.025, look.outfit), 0, 0.33, 0.135)); // tie in personal colour
  } else {
    spine.add(at(torus(0.085, 0.022, shade(top, -0.18)), 0, 0.51, 0.0).rotateX(Math.PI / 2)); // collar
    spine.add(at(box(0.36, 0.035, 0.255, 0x3a2a1f), 0, 0.0, 0)); // belt line
  }
  spine.add(at(cyl(0.06, 0.07, 0.12, skin, 10), 0, 0.56, 0));

  // ---- head
  const head = at(new THREE.Group(), 0, 0.78, 0.01);
  spine.add(head);
  const skull = sphere(0.205, skin, 24);
  const fs = look.faceShape;
  skull.scale.set(fs === 'round' ? 1.06 : fs === 'square' ? 1.03 : 0.98, fs === 'round' ? 1.0 : 1.08, 1.0);
  if (fs === 'heart') skull.scale.set(1.0, 1.06, 0.98);
  head.add(skull);
  head.add(at(sphere(0.045, skin, 10), 0.2, -0.01, 0));
  head.add(at(sphere(0.045, skin, 10), -0.2, -0.01, 0));
  head.add(at(sphere(0.03, shade(look.skin, -0.06), 10), 0, -0.03, 0.2));

  const eyeM = mat(0x1b1b1f, { r: 0.3 });
  const shineM = mat(0xffffff, { r: 0.2, e: 0xffffff, ei: 0.4 });
  const eyes = [];
  for (const s of [1, -1]) {
    const e = at(new THREE.Group(), s * 0.075, 0.02, 0.178);
    const pupil = sphere(0.032, eyeM, 12);
    const es = look.eyeStyle;
    pupil.scale.set(es === 'almond' ? 1.25 : 1, es === 'wide' ? 1.2 : es === 'sleepy' ? 0.7 : 1.05, 0.6);
    e.add(pupil);
    e.add(at(sphere(0.011, shineM, 6), s * -0.01, 0.012, 0.018));
    head.add(e);
    eyes.push(e);
    const brow = at(box(0.075, 0.016, 0.02, hairM), s * 0.078, 0.085, 0.185);
    brow.rotation.z = s * -0.08;
    head.add(brow);
    if (fem) head.add(at(box(0.06, 0.012, 0.01, eyeM), s * 0.08, 0.05, 0.19));
  }
  // cheeks (separately so scale chaining stays readable)
  for (const s of [1, -1]) {
    const ch = at(sphere(0.032, mat(0xf29a8e, { r: 0.9, t: 0.45 }), 8), s * 0.12, -0.05, 0.165);
    ch.scale.set(1, 0.6, 0.4);
    head.add(ch);
  }
  const mouthGroup = at(new THREE.Group(), 0, -0.095, 0.188);
  head.add(mouthGroup);
  const mouthM = mat(0x7a2f2f, { r: 0.6 });
  const smile = torus(0.042, 0.011, mouthM, Math.PI);
  smile.rotation.z = Math.PI;
  const frown = torus(0.035, 0.01, mouthM, Math.PI);
  const flat = box(0.06, 0.012, 0.01, mouthM);
  const oh = torus(0.017, 0.008, mouthM);
  for (const m of [smile, frown, flat, oh]) {
    m.castShadow = false;
    m.visible = false;
    mouthGroup.add(m);
  }
  frown.position.y = -0.03;

  // ---- hair
  const hs = look.hairStyle;
  if (hs !== 'bald') {
    const cap = new THREE.Mesh(capGeo(0.222, hs === 'afro' ? 1.5 : 1.75), hairM);
    cap.castShadow = true;
    cap.rotation.x = -0.42;
    cap.position.set(0, 0.012, -0.015);
    head.add(cap);
    if (hs === 'short' || hs === 'curly') {
      const fr = at(rbox(0.3, 0.06, 0.08, 0.03, hairM), 0, 0.15, 0.15);
      fr.rotation.x = 0.5;
      head.add(fr);
    }
    if (hs === 'long') {
      head.add(at(rbox(0.4, 0.5, 0.12, 0.06, hairM), 0, -0.2, -0.12));
      for (const s of [1, -1]) head.add(at(capsule(0.05, 0.28, hairM), s * 0.19, -0.14, 0.05));
      const fr = at(rbox(0.32, 0.07, 0.08, 0.035, hairM), 0.03, 0.14, 0.155);
      fr.rotation.set(0.5, 0, -0.18);
      head.add(fr);
    } else if (hs === 'curly') {
      const r = mulberry(hashStr('curl' + look.hair));
      for (let i = 0; i < 18; i++) {
        const th = r() * Math.PI * 2;
        const ph = 0.2 + r() * 1.05;
        const p = new THREE.Vector3().setFromSphericalCoords(0.23, ph, th);
        if (p.z > 0.12 && p.y < 0.12) continue;
        head.add(at(sphere(0.062, hairM, 8), p.x, p.y + 0.01, p.z - 0.02));
      }
    } else if (hs === 'braids') {
      for (let i = 0; i < 7; i++) {
        const a = -0.9 + (i / 6) * 1.8;
        const b = at(capsule(0.03, 0.42, hairM), Math.sin(a) * 0.19, -0.2, -Math.cos(a) * 0.17);
        b.rotation.x = 0.12;
        head.add(b);
      }
    } else if (hs === 'afro') {
      const a = at(sphere(0.31, hairM, 18), 0, 0.08, -0.04);
      a.scale.set(1, 0.92, 0.95);
      head.add(a);
    } else if (hs === 'bun') {
      head.add(at(sphere(0.1, hairM, 12), 0, 0.2, -0.13));
    }
  }
  // ---- accessories
  const acc = look.accessory;
  if (acc === 'glasses') {
    const gm = mat(0x111827, { r: 0.3, m: 0.4 });
    for (const s of [1, -1]) head.add(at(torus(0.048, 0.008, gm), s * 0.077, 0.02, 0.2));
    head.add(at(box(0.05, 0.01, 0.01, gm), 0, 0.025, 0.205));
  } else if (acc === 'cap') {
    const cm = mat(shade(look.outfit, -0.1), { r: 0.7 });
    head.add(at(cyl(0.215, 0.225, 0.12, cm, 20), 0, 0.15, -0.01));
    const top2 = at(sphere(0.215, cm, 16), 0, 0.2, -0.01);
    top2.scale.set(1, 0.42, 1);
    head.add(top2);
    head.add(at(box(0.24, 0.02, 0.18, cm), 0, 0.11, 0.22));
  } else if (acc === 'earrings') {
    const gm = mat(0xfbbf24, { r: 0.25, m: 0.8 });
    for (const s of [1, -1]) head.add(at(sphere(0.022, gm, 8), s * 0.2, -0.07, 0.01));
  } else if (acc === 'scarf') {
    const sm = mat(0xdc2626, { r: 0.9 });
    const sc = at(torus(0.1, 0.05, sm), 0, 0.53, 0);
    sc.rotation.x = Math.PI / 2;
    spine.add(sc);
    spine.add(at(rbox(0.09, 0.22, 0.05, 0.02, sm), 0.07, 0.38, 0.13));
  }

  // ---- arms
  function arm(side) {
    const p = at(new THREE.Group(), side * (shoulderW / 2 + 0.035), 0.47, 0);
    p.add(at(capsule(0.064, 0.2, uniform === 'labcoat' ? mat(0xf8fafc, { r: 0.9 }) : topM), 0, -0.14, 0));
    const elbow = at(new THREE.Group(), 0, -0.29, 0);
    elbow.add(at(capsule(0.054, 0.18, uniform === 'labcoat' || uniform === 'suit' ? (uniform === 'suit' ? topM : mat(0xf8fafc, { r: 0.9 })) : skin), 0, -0.12, 0));
    elbow.add(at(sphere(0.062, skin, 10), 0, -0.27, 0.01));
    p.add(elbow);
    p.rotation.z = side * 0.06;
    spine.add(p);
    return { p, elbow };
  }
  const armL = arm(1);
  const armR = arm(-1);

  // ---- mood orb (player only)
  let orb = null;
  if (mood) {
    orb = new THREE.Group();
    const core = new THREE.Mesh(new THREE.OctahedronGeometry(0.075, 2), new THREE.MeshStandardMaterial({ color: 0x34d399, emissive: 0x34d399, emissiveIntensity: 0.9, roughness: 0.3 }));
    const ring = new THREE.Mesh(new THREE.TorusGeometry(0.11, 0.012, 8, 32), new THREE.MeshStandardMaterial({ color: 0xffffff, emissive: 0x34d399, emissiveIntensity: 0.6 }));
    ring.rotation.x = Math.PI / 2.4;
    orb.add(core, ring);
    orb.position.y = 1.18;
    orb.userData.core = core;
    orb.userData.ring = ring;
    root.add(orb);
  }

  // speech bubble
  const bubble = labelSprite('…', { worldH: 0.26, bg: 'rgba(255,255,255,0.95)', fg: '#0f172a' });
  bubble.position.set(0.18, 1.12, 0);
  bubble.visible = false;
  root.add(bubble);

  let nameTag = null;
  if (name) {
    nameTag = labelSprite(name, { worldH: 0.2, sub: role, bg: 'rgba(15,23,42,0.82)' });
    nameTag.position.set(0, 1.08, 0);
    nameTag.visible = false;
    root.add(nameTag);
  }

  root.traverse((o) => {
    if (!o.isMesh || o === root.children[1]) return;
    if (!o.geometry.boundingSphere) o.geometry.computeBoundingSphere();
    o.castShadow = o.geometry.boundingSphere.radius * Math.max(o.scale.x, o.scale.y, o.scale.z) > 0.06;
  });

  // Merge rigid parts per "bone" so a character costs ~15 draw calls, not ~50.
  const keep = (...objs) => objs.forEach((o) => o && (o.userData.dynamic = true));
  keep(...eyes, mouthGroup);
  mergeStatic(head);
  for (const l of [legL, legR]) {
    mergeStatic(l.knee);
    keep(l.knee);
    mergeStatic(l.p);
    keep(l.p);
  }
  for (const a of [armL, armR]) {
    mergeStatic(a.elbow);
    keep(a.elbow);
    mergeStatic(a.p);
    keep(a.p);
  }
  keep(head);
  mergeStatic(spine);
  keep(spine);
  mergeStatic(hips);

  // ---- animation state
  let phase = Math.random() * 10;
  let t = Math.random() * 10;
  let blinkT = 2 + Math.random() * 3;
  const MOOD = { happy: 0x34d399, neutral: 0x38bdf8, proud: 0xfbbf24, tired: 0x94a3b8, stressed: 0xf97316, sad: 0x60a5fa };

  function setMouth(emotion, talking) {
    smile.visible = frown.visible = flat.visible = oh.visible = false;
    if (talking && Math.sin(t * 14) > 0.1) oh.visible = true;
    else if (emotion === 'happy' || emotion === 'proud') smile.visible = true;
    else if (emotion === 'sad' || emotion === 'stressed') frown.visible = true;
    else if (emotion === 'tired') flat.visible = true;
    else smile.visible = true;
  }

  function reset() {
    hips.position.set(0, 0.92, 0);
    hips.rotation.set(0, 0, 0);
    body.rotation.set(0, 0, 0);
    body.position.set(0, 0, 0);
    spine.rotation.set(0, 0, 0);
    head.rotation.set(0, 0, 0);
    for (const l of [legL, legR]) {
      l.p.rotation.set(0, 0, 0);
      l.knee.rotation.set(0, 0, 0);
    }
    armL.p.rotation.set(0, 0, 0.06);
    armR.p.rotation.set(0, 0, -0.06);
    armL.elbow.rotation.set(0, 0, 0);
    armR.elbow.rotation.set(0, 0, 0);
  }

  function update(dt, pose = {}) {
    t += dt;
    const action = pose.action || 'idle';
    const walking = !!pose.walking;
    const emotion = pose.emotion || 'neutral';
    reset();

    // blink
    blinkT -= dt;
    const closed = blinkT < 0.12 || action === 'sleep' || (emotion === 'tired' && Math.sin(t * 0.7) > 0.6);
    for (const e of eyes) e.scale.y = closed ? 0.12 : 1;
    if (blinkT < 0) blinkT = 2.5 + Math.random() * 3.5;

    const talking = action === 'talk' || pose.talking;
    setMouth(emotion, talking);
    bubble.visible = !!talking;
    if (nameTag) nameTag.visible = !!pose.showName && !talking;

    if (walking) {
      const sp = Math.max(0.6, pose.speed || 2.5);
      phase += dt * (5.5 + sp * 1.6);
      const s = Math.sin(phase);
      const amp = Math.min(0.75, 0.42 + sp * 0.08);
      legL.p.rotation.x = -s * amp;
      legR.p.rotation.x = s * amp;
      legL.knee.rotation.x = Math.max(0, s) * amp * 1.3;
      legR.knee.rotation.x = Math.max(0, -s) * amp * 1.3;
      armL.p.rotation.x = s * amp * 0.85;
      armR.p.rotation.x = -s * amp * 0.85;
      armL.elbow.rotation.x = -0.35;
      armR.elbow.rotation.x = -0.35;
      body.position.y = Math.abs(Math.cos(phase)) * 0.05;
      spine.rotation.x = 0.06 + sp * 0.01;
      spine.rotation.y = s * 0.08;
      head.rotation.y = -s * 0.05;
    } else {
      const br = Math.sin(t * 1.8);
      spine.position.y = 0.07 + br * 0.006;
      armL.p.rotation.z = 0.08 + br * 0.015;
      armR.p.rotation.z = -0.08 - br * 0.015;
      head.rotation.y = Math.sin(t * 0.37) * 0.18;
      head.rotation.x = Math.sin(t * 0.23) * 0.05;
      switch (action) {
        case 'sit':
        case 'study':
        case 'useComputer':
        case 'work':
        case 'eat': {
          const seated = !!pose.seated;
          if (seated) {
            hips.position.y = 0.5;
            legL.p.rotation.x = legR.p.rotation.x = -1.45;
            legL.knee.rotation.x = legR.knee.rotation.x = 1.45;
          }
          if (action === 'eat') {
            const k = (Math.sin(t * 2.4) + 1) / 2;
            armR.p.rotation.x = -0.6 - k * 1.2;
            armR.elbow.rotation.x = -1.4 * k - 0.4;
          } else if (action !== 'sit') {
            armL.p.rotation.x = armR.p.rotation.x = -0.75;
            armL.elbow.rotation.x = -0.8 + Math.sin(t * 13) * 0.08;
            armR.elbow.rotation.x = -0.8 + Math.cos(t * 11) * 0.08;
            head.rotation.x = 0.22;
            head.rotation.y = Math.sin(t * 0.6) * 0.08;
          }
          break;
        }
        case 'sleep':
          if (pose.seated) {
            body.rotation.x = -Math.PI / 2;
            body.position.set(0, 0.32, -0.42);
          } else {
            spine.rotation.x = 0.25;
            head.rotation.x = 0.4;
          }
          break;
        case 'talk':
          armR.p.rotation.x = -0.5 + Math.sin(t * 3.1) * 0.25;
          armR.p.rotation.z = -0.3;
          armR.elbow.rotation.x = -0.9;
          head.rotation.x = Math.sin(t * 5) * 0.06;
          break;
        case 'celebrate': {
          const j = Math.abs(Math.sin(t * 6));
          body.position.y = j * 0.16;
          armL.p.rotation.z = 2.7 + Math.sin(t * 12) * 0.2;
          armR.p.rotation.z = -2.7 - Math.sin(t * 12) * 0.2;
          break;
        }
        case 'frustrated':
          head.rotation.x = 0.35;
          armL.p.rotation.x = armR.p.rotation.x = -2.5;
          armL.p.rotation.z = 0.5;
          armR.p.rotation.z = -0.5;
          armL.elbow.rotation.x = armR.elbow.rotation.x = -1.7;
          break;
        default:
          if (emotion === 'tired' || emotion === 'sad') {
            spine.rotation.x = 0.12;
            head.rotation.x = 0.2;
          } else if (emotion === 'proud') {
            spine.rotation.x = -0.06;
            armL.p.rotation.z = 0.35;
            armR.p.rotation.z = -0.35;
          }
      }
    }

    if (orb) {
      const c = MOOD[emotion] ?? MOOD.neutral;
      orb.userData.core.material.color.setHex(c);
      orb.userData.core.material.emissive.setHex(c);
      orb.userData.ring.material.emissive.setHex(c);
      orb.position.y = 1.2 + Math.sin(t * 2.2) * 0.04 + (action === 'sleep' && pose.seated ? -0.4 : 0);
      orb.userData.core.rotation.y += dt * 1.6;
      orb.userData.ring.rotation.z += dt * 0.8;
    }
  }

  update(0, {});
  return { root, update, look };
}

function mulberry(a) {
  return () => {
    a |= 0;
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
