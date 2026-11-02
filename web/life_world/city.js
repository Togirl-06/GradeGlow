// Open-world city: ground, streets, decor, buildings, traffic and pedestrians.
import * as THREE from 'three';
import { box, cyl, sphere, mat, col, shade, hex, at, labelSprite, rng, plane, mergeStatic } from './util.js';
import { makeBuilding, nightMats, tree, bush, bench, car } from './buildings.js';
import { makeCharacter } from './characters.js';

const PX = 40; // texture pixels per tile

function tileType(x, y, cw, ch) {
  if (x % cw === 0 || y % ch === 0) return 'road';
  return y % ch >= 7 ? 'plaza' : 'grass';
}

function groundTexture(data) {
  const { w, h, cellW, cellH, districts } = data;
  const M = 1; // margin tiles around the city
  const c = document.createElement('canvas');
  c.width = (w + 2 * M) * PX;
  c.height = (h + 2 * M) * PX;
  const g = c.getContext('2d');
  g.fillStyle = '#86c96e';
  g.fillRect(0, 0, c.width, c.height);
  // pixel (0,0) of tile space = centre of tile (0,0)
  g.translate(PX * (M + 0.5), PX * (M + 0.5));
  const r = rng('ground');
  const dcol = (x, y) => {
    const cx = Math.min(Math.floor(x / cellW), Math.floor((w - 1) / cellW) - 1);
    const cy = Math.min(Math.floor(y / cellH), Math.floor((h - 1) / cellH) - 1);
    const d = districts.find((d) => d.col === cx && d.row === cy);
    return d ? col(d.color) : new THREE.Color(0xcccccc);
  };
  // pass 1: grass & plaza
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const t = tileType(x, y, cellW, cellH);
      const px = x * PX - PX / 2;
      const py = y * PX - PX / 2;
      if (t === 'grass') {
        const base = new THREE.Color(0x86c96e).lerp(dcol(x, y), 0.08);
        g.fillStyle = '#' + base.getHexString();
        g.fillRect(px, py, PX, PX);
        for (let i = 0; i < 14; i++) {
          g.fillStyle = r() < 0.5 ? 'rgba(255,255,255,0.07)' : 'rgba(0,60,0,0.08)';
          g.fillRect(px + r() * PX, py + r() * PX, 2, 3);
        }
      } else if (t === 'plaza') {
        const base = new THREE.Color(0xeee7da).lerp(dcol(x, y), 0.12);
        g.fillStyle = '#' + base.getHexString();
        g.fillRect(px, py, PX, PX);
        g.strokeStyle = 'rgba(120,100,80,0.18)';
        g.lineWidth = 1;
        for (let i = 0; i <= 2; i++) {
          g.beginPath();
          g.moveTo(px + (i * PX) / 2, py);
          g.lineTo(px + (i * PX) / 2, py + PX);
          g.stroke();
          g.beginPath();
          g.moveTo(px, py + (i * PX) / 2);
          g.lineTo(px + PX, py + (i * PX) / 2);
          g.stroke();
        }
      } else {
        g.fillStyle = '#86c96e';
        g.fillRect(px, py, PX, PX);
      }
    }
  }
  // pass 2: roads (drawn wider than a tile: 1.4 tiles)
  const RW = PX * 1.4;
  const SW = PX * 0.16; // kerb
  g.fillStyle = '#cbd5e1';
  for (let x = 0; x < w; x += cellW) g.fillRect(x * PX - RW / 2 - SW, -PX, RW + SW * 2, h * PX + PX * 2);
  for (let y = 0; y < h; y += cellH) g.fillRect(-PX, y * PX - RW / 2 - SW, w * PX + PX * 2, RW + SW * 2);
  g.fillStyle = '#4b5563';
  for (let x = 0; x < w; x += cellW) g.fillRect(x * PX - RW / 2, -PX, RW, h * PX + PX * 2);
  for (let y = 0; y < h; y += cellH) g.fillRect(-PX, y * PX - RW / 2, w * PX + PX * 2, RW);
  // asphalt speckle
  for (let i = 0; i < w * h * 3; i++) {
    g.fillStyle = r() < 0.5 ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.08)';
    g.fillRect(r() * w * PX, r() * h * PX, 2, 2);
  }
  // centre dashes
  g.fillStyle = '#fde68a';
  for (let x = 0; x < w; x += cellW) for (let y = 0; y < h * PX; y += PX * 0.9) {
    if ((y / PX) % cellH < 1.0 || (y / PX) % cellH > cellH - 1.0) continue;
    g.fillRect(x * PX - 2, y, 4, PX * 0.45);
  }
  for (let y = 0; y < h; y += cellH) for (let x = 0; x < w * PX; x += PX * 0.9) {
    if ((x / PX) % cellW < 1.0 || (x / PX) % cellW > cellW - 1.0) continue;
    g.fillRect(x, y * PX - 2, PX * 0.45, 4);
  }
  // crosswalks at each intersection approach
  g.fillStyle = 'rgba(255,255,255,0.85)';
  for (let x = 0; x < w; x += cellW) {
    for (let y = 0; y < h; y += cellH) {
      const cx = x * PX;
      const cy = y * PX;
      for (const s of [-1, 1]) {
        for (let i = -3; i <= 3; i++) {
          g.fillRect(cx + i * 7 - 2, cy + s * (RW / 2 + PX * 0.35) - PX * 0.18, 4, PX * 0.36);
          g.fillRect(cx + s * (RW / 2 + PX * 0.35) - PX * 0.18, cy + i * 7 - 2, PX * 0.36, 4);
        }
      }
    }
  }
  const t = new THREE.CanvasTexture(c);
  t.colorSpace = THREE.SRGBColorSpace;
  t.anisotropy = 8;
  return t;
}

const LAMP_HEAD = new THREE.MeshStandardMaterial({ color: 0xfff7d6, emissive: 0xffd27a, emissiveIntensity: 0 });
function lamp() {
  const g = new THREE.Group();
  const pm = mat(0x334155, { r: 0.5, m: 0.5 });
  g.add(at(cyl(0.03, 0.04, 1.6, pm, 6), 0, 0.8, 0));
  g.add(at(box(0.32, 0.04, 0.05, pm), 0.13, 1.58, 0));
  const head = new THREE.Mesh(new THREE.SphereGeometry(0.08, 10, 8), LAMP_HEAD);
  head.position.set(0.27, 1.52, 0);
  g.add(head);
  g.userData.head = head;
  g.traverse((o) => {
    if (o.isMesh) o.castShadow = true;
  });
  return g;
}

function busStop(r) {
  const g = new THREE.Group();
  const gm = mat(0xbae6fd, { r: 0.05, t: 0.4 });
  g.add(at(box(1.0, 0.04, 0.4, mat(0x0ea5e9)), 0, 1.0, 0));
  g.add(at(box(1.0, 0.9, 0.02, gm), 0, 0.55, -0.18));
  for (const x of [-0.48, 0.48]) g.add(at(box(0.04, 1.0, 0.04, mat(0x334155)), x, 0.5, -0.18));
  g.add(at(bench(0x0ea5e9), 0, 0, -0.05));
  return g;
}

function hills(group) {
  const r = rng('hills');
  const m = mat(0x6aa860, { r: 1, flat: true });
  const m2 = mat(0x8fbf7a, { r: 1, flat: true });
  for (let i = 0; i < 26; i++) {
    const a = (i / 26) * Math.PI * 2;
    const R = 72 + r() * 18;
    const h = 6 + r() * 10;
    const geo = new THREE.ConeGeometry(10 + r() * 10, h, 7);
    const mesh = new THREE.Mesh(geo, i % 2 ? m : m2);
    mesh.position.set(30 + Math.cos(a) * R, h / 2 - 1, 10 + Math.sin(a) * R * 0.75);
    mesh.rotation.y = r() * 3;
    group.add(mesh);
  }
}

/** Builds the whole city. */
export function buildCity(data) {
  const group = new THREE.Group();
  const { w, h, cellW, cellH } = data;
  const r = rng('city-decor');

  // outer ground
  const outerTex = (() => {
    const c = document.createElement('canvas');
    c.width = c.height = 128;
    const g = c.getContext('2d');
    g.fillStyle = '#86c96e';
    g.fillRect(0, 0, 128, 128);
    const rr = rng('outer');
    for (let i = 0; i < 400; i++) {
      g.fillStyle = rr() < 0.5 ? 'rgba(255,255,255,0.06)' : 'rgba(0,70,0,0.08)';
      g.fillRect(rr() * 128, rr() * 128, 2, 3);
    }
    const t = new THREE.CanvasTexture(c);
    t.wrapS = t.wrapT = THREE.RepeatWrapping;
    t.repeat.set(60, 60);
    t.colorSpace = THREE.SRGBColorSpace;
    return t;
  })();
  const outer = new THREE.Mesh(new THREE.PlaneGeometry(260, 260), new THREE.MeshStandardMaterial({ map: outerTex, roughness: 1 }));
  outer.rotation.x = -Math.PI / 2;
  outer.position.set(w / 2, -0.02, h / 2);
  outer.receiveShadow = true;
  outer.userData.pick = { kind: 'ground' };
  group.add(outer);

  // city ground
  const gt = groundTexture(data);
  const city = new THREE.Mesh(new THREE.PlaneGeometry(w + 2, h + 2), new THREE.MeshStandardMaterial({ map: gt, roughness: 0.95 }));
  city.rotation.x = -Math.PI / 2;
  city.position.set((w - 1) / 2, 0, (h - 1) / 2);
  city.receiveShadow = true;
  city.userData.pick = { kind: 'ground' };
  group.add(city);

  // lake to the south
  const lake = new THREE.Mesh(new THREE.PlaneGeometry(w + 30, 9), new THREE.MeshStandardMaterial({ color: 0x4fb3e8, roughness: 0.15, metalness: 0.2 }));
  lake.rotation.x = -Math.PI / 2;
  lake.position.set(w / 2, 0.01, h + 6.5);
  group.add(lake);
  const shore = new THREE.Mesh(new THREE.PlaneGeometry(w + 30, 1.2), new THREE.MeshStandardMaterial({ color: 0xe7d7a8, roughness: 1 }));
  shore.rotation.x = -Math.PI / 2;
  shore.position.set(w / 2, 0.005, h + 1.8);
  group.add(shore);
  // boardwalk railing
  const rm = mat(0x8b5a2b, { r: 0.9 });
  for (let x = -4; x < w + 4; x += 1.5) group.add(at(box(0.06, 0.4, 0.06, rm), x, 0.2, h + 2.3));
  group.add(at(box(w + 8, 0.05, 0.06, rm), w / 2, 0.38, h + 2.3));
  hills(group);

  // buildings
  const blocked = new Set();
  const buildings = new Map();
  for (const b of data.buildings) {
    const { group: bg, height } = makeBuilding(b);
    group.add(bg);
    for (let yy = b.y; yy < b.y + b.h; yy++) for (let xx = b.x; xx < b.x + b.w; xx++) blocked.add(xx + ',' + yy);
    const doorX = b.x + Math.floor(b.w / 2);
    const doorY = b.y + b.h;
    // door marker
    const marker = new THREE.Group();
    const ringM = new THREE.MeshBasicMaterial({ color: col(b.color), transparent: true, opacity: 0.85, depthWrite: false });
    const ring = new THREE.Mesh(new THREE.RingGeometry(0.28, 0.4, 32), ringM);
    ring.rotation.x = -Math.PI / 2;
    ring.position.y = 0.02;
    marker.add(ring);
    const arrowM = new THREE.MeshStandardMaterial({ color: col(b.color), emissive: col(b.color), emissiveIntensity: 0.55 });
    const arrow = new THREE.Mesh(new THREE.ConeGeometry(0.12, 0.22, 4), arrowM);
    arrow.rotation.x = Math.PI;
    arrow.position.y = 0.9;
    marker.add(arrow);
    marker.position.set(doorX, 0, doorY - 0.1);
    marker.userData.dynamic = true;
    marker.userData.pick = { kind: 'building', id: b.id };
    ring.userData.pick = arrow.userData.pick = marker.userData.pick;
    group.add(marker);
    const label = labelSprite(b.name, { emoji: b.emoji, worldH: 0.62, accent: '#' + col(b.color).getHexString(), sub: '' });
    label.position.set(b.x + (b.w - 1) / 2, height + 0.5, b.y + (b.h - 1) / 2 + 0.6);
    group.add(label);
    buildings.set(b.id, { data: b, group: bg, marker, ring, arrow, label, height, closed: null, doorX, doorY });
  }

  // street lamps along roads
  const lamps = [];
  for (let x = 0; x < w; x += cellW) {
    for (let y = 2; y < h; y += 3) {
      if (y % cellH === 0) continue;
      for (const s of [-1, 1]) {
        if ((x === 0 && s < 0) || (x === w - 1 && s > 0)) continue;
        const L = lamp();
        L.position.set(x + s * 0.78, 0, y);
        L.rotation.y = s > 0 ? Math.PI : 0;
        group.add(L);
        lamps.push(L);
      }
    }
  }
  for (let y = 0; y < h; y += cellH) {
    for (let x = 3; x < w; x += 4) {
      if (x % cellW === 0) continue;
      const s = y === 0 ? 1 : -1;
      const L = lamp();
      L.position.set(x, 0, y + s * 0.78);
      L.rotation.y = s > 0 ? Math.PI / 2 : -Math.PI / 2;
      group.add(L);
      lamps.push(L);
    }
  }

  // trees, bushes, flower beds, benches
  for (let y = 1; y < h; y++) {
    for (let x = 1; x < w; x++) {
      const t = tileType(x, y, cellW, cellH);
      if (t === 'road' || blocked.has(x + ',' + y)) continue;
      const nearDoor = [...buildings.values()].some((b) => Math.abs(b.doorX - x) <= 1 && Math.abs(b.doorY - y) <= 1);
      if (nearDoor) continue;
      if (t === 'grass') {
        const v = r();
        if (v < 0.42) group.add(at(tree(r, 0.95 + r() * 0.5), x + (r() - 0.5) * 0.5, 0, y + (r() - 0.5) * 0.5));
        else if (v < 0.62) group.add(at(bush(r, 1 + r()), x + (r() - 0.5) * 0.6, 0, y + (r() - 0.5) * 0.6));
      } else if (t === 'plaza' && y % cellH === 9) {
        if (x % 4 === 2 && r() < 0.6) group.add(at(bench(), x, 0, y + 0.3));
        else if (x % 4 === 0 && r() < 0.5) group.add(at(tree(r, 0.9), x, 0, y + 0.35));
      }
    }
  }
  // perimeter trees
  for (let x = -6; x < w + 6; x += 1.6) {
    group.add(at(tree(r, 1.2 + r() * 0.6), x + r() * 0.6, 0, -2.2 - r() * 3));
  }
  for (let y = -3; y < h + 2; y += 1.6) {
    group.add(at(tree(r, 1.2 + r() * 0.6), -2.4 - r() * 3, 0, y));
    group.add(at(tree(r, 1.2 + r() * 0.6), w + 1.4 + r() * 3, 0, y));
  }
  // bus stops
  for (const [x, y] of [[cellW * 3 + 6, cellH * 2 - 0.25], [cellW + 6, cellH - 0.25], [cellW * 2 + 6, cellH - 0.25]]) {
    const bs = busStop(r);
    bs.position.set(x, 0, y + 0.85);
    bs.rotation.y = Math.PI;
    group.add(bs);
  }

  // buildings are already merged individually; merge the remaining street decor
  for (const b of buildings.values()) b.group.userData.dynamic = true;
  mergeStatic(group);
  for (const b of buildings.values()) b.group.userData.dynamic = false;

  // ------------------------------------------------ traffic
  const nodes = [];
  for (let x = 0; x < w; x += cellW) for (let y = 0; y < h; y += cellH) nodes.push([x, y]);
  const neighbours = (n) => nodes.filter((m) => (m[0] === n[0] && Math.abs(m[1] - n[1]) === cellH) || (m[1] === n[1] && Math.abs(m[0] - n[0]) === cellW));
  const cars = [];
  const carCols = [0xef4444, 0x3b82f6, 0xfacc15, 0xf8fafc, 0x10b981, 0x111827, 0xf97316, 0xa855f7];
  for (let i = 0; i < 11; i++) {
    const c = car(carCols[i % carCols.length], r);
    const a = nodes[Math.floor(r() * nodes.length)];
    const nb = neighbours(a);
    const b = nb[Math.floor(r() * nb.length)];
    c.userData.dynamic = true;
    const o = { mesh: c, a, b, t: r(), speed: 2.0 + r() * 1.2, lane: 0.22 };
    group.add(c);
    cars.push(o);
  }
  function stepCar(o, dt, player) {
    const dx = o.b[0] - o.a[0];
    const dy = o.b[1] - o.a[1];
    const len = Math.hypot(dx, dy);
    const ux = dx / len;
    const uy = dy / len;
    // lane offset to the right of travel direction
    const lx = -uy * o.lane;
    const ly = ux * o.lane;
    const px = o.a[0] + dx * o.t + lx;
    const py = o.a[1] + dy * o.t + ly;
    let v = o.speed;
    if (player) {
      const ahead = (player.x - px) * ux + (player.z - py) * uy;
      const side = Math.abs((player.x - px) * -uy + (player.z - py) * ux);
      if (ahead > 0 && ahead < 1.6 && side < 0.7) v = 0;
    }
    for (const other of cars) {
      if (other === o) continue;
      const ox = other.mesh.position.x - px;
      const oz = other.mesh.position.z - py;
      const ah = ox * ux + oz * uy;
      if (ah > 0 && ah < 1.4 && Math.abs(ox * -uy + oz * ux) < 0.3) v = 0;
    }
    o.t += (v * dt) / len;
    if (o.t >= 1) {
      const nb = neighbours(o.b).filter((n) => !(n[0] === o.a[0] && n[1] === o.a[1]));
      o.a = o.b;
      o.b = nb.length ? nb[Math.floor(Math.random() * nb.length)] : o.a;
      o.t = 0;
    }
    o.mesh.position.set(px, 0, py);
    o.mesh.rotation.y = Math.atan2(ux, uy);
  }

  // ------------------------------------------------ pedestrians
  const peds = [];
  const skin = [0xffffdfc4, 0xfff1c27d, 0xffe0ac69, 0xffc68642, 0xff8d5524, 0xff5a3825];
  const hair = [0xff1b1b1b, 0xff2c1810, 0xff6b4423, 0xffb7872f, 0xffb5341f, 0xff9e9e9e];
  const outfit = [0xff10b981, 0xff3b82f6, 0xfff97316, 0xffec4899, 0xff8b5cf6, 0xff111827, 0xffeab308, 0xff64748b, 0xffef4444];
  const styles = ['short', 'long', 'curly', 'braids', 'afro', 'bun', 'bald'];
  for (let i = 0; i < 18; i++) {
    const look = {
      skin: skin[Math.floor(r() * skin.length)],
      hair: hair[Math.floor(r() * hair.length)],
      outfit: outfit[Math.floor(r() * outfit.length)],
      hairStyle: styles[Math.floor(r() * styles.length)],
      feminine: r() < 0.5,
      accessory: r() < 0.2 ? 'glasses' : r() < 0.1 ? 'cap' : 'none',
    };
    const ch = makeCharacter(look);
    ch.root.userData.dynamic = true;
    group.add(ch.root);
    const a = nodes[Math.floor(r() * nodes.length)];
    const nb = neighbours(a);
    const side = r() < 0.5 ? -1 : 1;
    peds.push({ ch, a, b: nb[Math.floor(r() * nb.length)], t: r(), speed: 0.75 + r() * 0.35, side, pause: 0 });
  }
  function stepPed(p, dt) {
    const dx = p.b[0] - p.a[0];
    const dy = p.b[1] - p.a[1];
    const len = Math.hypot(dx, dy) || 1;
    const ux = dx / len;
    const uy = dy / len;
    const off = 0.62 * p.side;
    const px = p.a[0] + dx * p.t - uy * off;
    const py = p.a[1] + dy * p.t + ux * off;
    if (p.pause > 0) {
      p.pause -= dt;
      p.ch.update(dt, { walking: false, emotion: 'happy' });
    } else {
      p.t += (p.speed * dt) / len;
      if (p.t >= 1) {
        const nb = neighbours(p.b);
        p.a = p.b;
        p.b = nb[Math.floor(Math.random() * nb.length)];
        p.t = 0;
        if (Math.random() < 0.3) p.pause = 1.5 + Math.random() * 3;
      }
      p.ch.update(dt, { walking: true, speed: p.speed, emotion: 'neutral' });
      p.ch.root.rotation.y = Math.atan2(ux, uy);
    }
    p.ch.root.position.set(px, 0, py);
  }

  // ------------------------------------------------ point lights for night
  const lightPool = [];
  for (let i = 0; i < 6; i++) {
    const L = new THREE.PointLight(0xffc977, 0, 5.5, 1.6);
    group.add(L);
    lightPool.push(L);
  }

  let t = 0;
  function update(dt, { night, player, goal }) {
    t += dt;
    LAMP_HEAD.emissiveIntensity = night * 2.2;
    for (const o of cars) stepCar(o, dt, player);
    for (const p of peds) stepPed(p, dt);
    // lights near the player
    if (player) {
      const near = lamps
        .map((L) => [L, (L.position.x - player.x) ** 2 + (L.position.z - player.z) ** 2])
        .sort((a, b) => a[1] - b[1])
        .slice(0, lightPool.length);
      near.forEach(([L], i) => {
        lightPool[i].position.set(L.position.x + (L.rotation.y === 0 ? 0.27 : -0.27), 1.45, L.position.z);
        lightPool[i].intensity = night * 2.4;
      });
    }
    for (const b of buildings.values()) {
      const pulse = 0.5 + 0.5 * Math.sin(t * 3 + b.doorX);
      const isGoal = goal === b.data.id;
      b.arrow.position.y = 0.85 + pulse * 0.12 + (isGoal ? 0.15 : 0);
      b.arrow.rotation.y += dt * 1.5;
      b.ring.scale.setScalar(isGoal ? 1.2 + pulse * 0.25 : 1 + pulse * 0.08);
      b.ring.material.opacity = b.closed ? 0.3 : isGoal ? 1 : 0.6 + pulse * 0.3;
    }
  }

  function setClosed(closedIds) {
    const set = new Set(closedIds || []);
    for (const b of buildings.values()) {
      const c = set.has(b.data.id);
      if (b.closed === c) continue;
      b.closed = c;
      const old = b.label;
      const nl = labelSprite(b.data.name, {
        emoji: b.data.emoji,
        worldH: 0.62,
        accent: c ? '#64748b' : '#' + col(b.data.color).getHexString(),
        sub: c ? 'Closed now' : 'Open',
        bg: c ? 'rgba(30,41,59,0.78)' : 'rgba(15,23,42,0.86)',
      });
      nl.position.copy(old.position);
      group.remove(old);
      old.material.map.dispose();
      old.material.dispose();
      group.add(nl);
      b.label = nl;
      b.arrow.material.color.set(c ? 0x64748b : col(b.data.color));
      b.arrow.material.emissive.set(c ? 0x334155 : col(b.data.color));
      b.ring.material.color.set(c ? 0x64748b : col(b.data.color));
    }
  }

  return { group, update, setClosed, buildings, lamps, bounds: { w, h } };
}

export { nightMats };
