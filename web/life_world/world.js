// GradeGlow Life — 3D world renderer.
//
// Flutter (lib/life_sim) owns all game rules. This page only renders and
// collects input. Protocol (JSON strings via postMessage):
//   Flutter → page  {type:'gg-scene', mode:'city'|'interior', ...}  {type:'gg-frame', ...}
//   page → Flutter  {type:'gg-ready'} {type:'gg-tap', kind, id?, x?, y?}
//                   {type:'gg-move', dx, dy} {type:'gg-key', key} {type:'gg-error', message}
import * as THREE from 'three';
import { buildCity, nightMats } from './city.js';
import { buildRoom, shortAngle } from './interior.js';
import { makeCharacter } from './characters.js';
import { lerp, clamp } from './util.js';

const SEATED = new Set(['sit', 'study', 'useComputer', 'eat', 'work', 'sleep']);

export function createWorld(canvas, { send }) {
  let renderer;
  try {
    renderer = new THREE.WebGLRenderer({ canvas, antialias: true, powerPreference: 'high-performance' });
  } catch (e) {
    send({ type: 'gg-error', message: 'WebGL is not available: ' + e.message });
    throw e;
  }
  const lowEnd = (navigator.hardwareConcurrency || 4) <= 4 && /Mobi|Android/i.test(navigator.userAgent);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, lowEnd ? 1.25 : 2));
  renderer.shadowMap.enabled = true;
  renderer.shadowMap.type = THREE.PCFSoftShadowMap;
  renderer.outputColorSpace = THREE.SRGBColorSpace;
  renderer.toneMapping = THREE.ACESFilmicToneMapping;
  renderer.toneMappingExposure = 1.05;

  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(40, 1, 0.1, 400);
  camera.userData.playerX = 0;
  camera.userData.playerZ = 0;

  // sky dome
  const skyUniforms = {
    top: { value: new THREE.Color(0x5aa9e6) },
    horizon: { value: new THREE.Color(0xcfe8f7) },
    glow: { value: new THREE.Color(0xffd29a) },
    glowAmt: { value: 0 },
  };
  const sky = new THREE.Mesh(
    new THREE.SphereGeometry(300, 32, 16),
    new THREE.ShaderMaterial({
      side: THREE.BackSide,
      depthWrite: false,
      uniforms: skyUniforms,
      vertexShader: 'varying vec3 vP; void main(){ vP = normalize(position); gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0); }',
      fragmentShader:
        'uniform vec3 top; uniform vec3 horizon; uniform vec3 glow; uniform float glowAmt; varying vec3 vP;' +
        'void main(){ float h = clamp(vP.y*1.6, 0.0, 1.0); vec3 c = mix(horizon, top, pow(h, 0.7));' +
        ' c = mix(c, glow, glowAmt * pow(1.0 - h, 3.0)); gl_FragColor = vec4(c, 1.0); }',
    }),
  );
  scene.add(sky);
  // stars
  const starGeo = new THREE.BufferGeometry();
  const sp = [];
  for (let i = 0; i < 700; i++) {
    const v = new THREE.Vector3().randomDirection();
    if (v.y < 0.08) v.y = Math.abs(v.y) + 0.08;
    v.multiplyScalar(280);
    sp.push(v.x, v.y, v.z);
  }
  starGeo.setAttribute('position', new THREE.Float32BufferAttribute(sp, 3));
  const stars = new THREE.Points(starGeo, new THREE.PointsMaterial({ color: 0xffffff, size: 1.2, sizeAttenuation: false, transparent: true, opacity: 0 }));
  scene.add(stars);

  scene.fog = new THREE.Fog(0xcfe8f7, 45, 140);

  const hemi = new THREE.HemisphereLight(0xdbeafe, 0x6b8f5a, 0.9);
  scene.add(hemi);
  const sun = new THREE.DirectionalLight(0xffffff, 2.4);
  sun.castShadow = true;
  sun.shadow.mapSize.set(lowEnd ? 1024 : 2048, lowEnd ? 1024 : 2048);
  const S = 20;
  Object.assign(sun.shadow.camera, { left: -S, right: S, top: S, bottom: -S, near: 1, far: 90 });
  sun.shadow.bias = -0.0004;
  sun.shadow.normalBias = 0.03;
  scene.add(sun, sun.target);

  // ------------------------------------------------------ state
  const state = {
    mode: null,
    key: null,
    city: null,
    cityData: null,
    room: null,
    roomCache: new Map(),
    player: null,
    lookKey: '',
    frame: { x: 0, y: 0, walking: false, action: 'idle', emotion: 'neutral', minute: 600, daylight: 1, npcs: {}, nearItem: null, nearNpc: null, goal: null },
    pos: new THREE.Vector3(),
    face: 0,
    cam: { yaw: 0, pitch: 0.7, dist: 9.5, target: new THREE.Vector3() },
    hover: null,
    ripples: [],
  };

  function setLook(look) {
    const key = JSON.stringify(look || {});
    if (state.player && key === state.lookKey) return;
    if (state.player) scene.remove(state.player.root);
    state.player = makeCharacter(look || {}, { mood: true });
    state.player.root.traverse((o) => (o.userData.isPlayer = true));
    state.lookKey = key;
    scene.add(state.player.root);
    state.player.root.position.copy(state.pos);
  }

  function setScene(msg) {
    const key = msg.mode === 'city' ? 'city' : 'room:' + msg.buildingId;
    if (msg.look) setLook(msg.look);
    if (key === state.key) return;
    if (state.city) scene.remove(state.city.group);
    if (state.room) scene.remove(state.room.group);
    state.room = null;
    state.mode = msg.mode;
    state.key = key;
    if (msg.mode === 'city') {
      if (!state.city) {
        state.cityData = msg;
        state.city = buildCity(msg);
      }
      scene.add(state.city.group);
      state.cam.dist = camera.aspect < 0.8 ? 12 : clamp(state.cam.dist, 7, 14);
      state.cam.pitch = 0.7;
      scene.fog.near = 45;
      scene.fog.far = 140;
    } else {
      let room = state.roomCache.get(key);
      if (!room) {
        room = buildRoom(msg);
        state.roomCache.set(key, room);
        if (state.roomCache.size > 6) state.roomCache.delete(state.roomCache.keys().next().value);
      }
      state.room = room;
      scene.add(room.group);
      state.cam.yaw = 0;
      state.cam.pitch = 0.82;
      state.cam.dist = camera.aspect < 0.8 ? 17 : 12.5;
      scene.fog.near = 60;
      scene.fog.far = 220;
    }
    // snap player & camera
    if (msg.player) {
      state.frame.x = msg.player.x;
      state.frame.y = msg.player.y;
    }
    state.pos.set(state.frame.x, 0, state.frame.y);
    state.cam.target.set(state.pos.x, 0.5, state.pos.z);
    if (state.player) state.player.root.position.copy(state.pos);
  }

  function setFrame(f) {
    Object.assign(state.frame, f);
    if (state.city && f.closed) state.city.setClosed(f.closed);
    if (f.look) setLook(f.look);
  }

  // ------------------------------------------------------ lighting
  function applyTime(minute, daylight) {
    const h = minute / 60;
    const d = clamp(daylight, 0, 1);
    const night = 1 - d;
    const dayTop = new THREE.Color(0x4f9fe0);
    const dayHor = new THREE.Color(0xd6ecf8);
    const nightTop = new THREE.Color(0x070b1d);
    const nightHor = new THREE.Color(0x1b2747);
    skyUniforms.top.value.copy(nightTop).lerp(dayTop, d);
    skyUniforms.horizon.value.copy(nightHor).lerp(dayHor, d);
    const golden = d > 0.02 && d < 0.85 ? Math.sin((d / 0.85) * Math.PI) : 0;
    skyUniforms.glowAmt.value = golden * 0.9;
    skyUniforms.glow.value.set(h < 12 ? 0xffc28a : 0xff9a6b);
    stars.material.opacity = state.room ? 0 : Math.max(0, night - 0.35) * 1.4;
    if (state.room) {
      skyUniforms.top.value.set(0x0f172a);
      skyUniforms.horizon.value.set(0x334155).lerp(new THREE.Color(0x111827), night * 0.6);
      skyUniforms.glowAmt.value = 0;
    }
    scene.fog.color.copy(skyUniforms.horizon.value);

    // sun path: rises east (+x) at 6, sets west at 19
    const f = clamp((h - 6) / 13, 0, 1);
    const elev = Math.sin(f * Math.PI);
    const az = lerp(-1, 1, f);
    const dir = new THREE.Vector3(-az * 0.8, 0.35 + elev * 1.2, 0.55).normalize();
    if (d < 0.08) dir.set(0.4, 1.0, 0.5).normalize(); // moonlight
    const tgt = state.cam.target;
    sun.position.copy(tgt).addScaledVector(dir, 40);
    sun.target.position.copy(tgt);
    sun.intensity = d < 0.08 ? 0.45 : 0.4 + 2.3 * d;
    sun.color.set(d < 0.08 ? 0x9db6ff : 0xffffff).lerp(new THREE.Color(0xffb27a), golden * 0.55);
    hemi.intensity = 0.32 + 0.75 * d;
    hemi.color.set(0xdbeafe).lerp(new THREE.Color(0x3b4a7a), night * 0.8);
    hemi.groundColor.set(0x6b8f5a).lerp(new THREE.Color(0x1b2233), night * 0.8);
    renderer.toneMappingExposure = 1.0 + night * 0.12;
    for (const m of nightMats) {
      m.emissiveIntensity = clamp(night * 0.85, 0, 0.85);
    }
    return night;
  }

  // ------------------------------------------------------ input
  const ray = new THREE.Raycaster();
  const ndc = new THREE.Vector2();
  const pointers = new Map();
  let drag = null;
  let pinch = null;

  function pickAt(clientX, clientY) {
    const rect = canvas.getBoundingClientRect();
    ndc.set(((clientX - rect.left) / rect.width) * 2 - 1, -((clientY - rect.top) / rect.height) * 2 + 1);
    ray.setFromCamera(ndc, camera);
    const root = state.room ? state.room.group : state.city ? state.city.group : null;
    if (!root) return null;
    const hits = ray.intersectObject(root, true);
    for (const h of hits) {
      const p = h.object.userData.pick;
      if (!p || h.object.isSprite) continue;
      if (state.city && p.kind === 'building') {
        const b = state.city.buildings.get(p.id);
        if (b && b.group.userData.fade < 0.6) continue; // see-through building: click passes through
      }
      return { ...p, point: h.point };
    }
    return null;
  }

  function onTap(clientX, clientY) {
    const hit = pickAt(clientX, clientY);
    if (!hit) return;
    let msg;
    if (hit.kind === 'ground') {
      msg = { type: 'gg-tap', kind: 'tile', x: Math.round(hit.point.x), y: Math.round(hit.point.z) };
    } else if (hit.kind === 'npc') {
      const n = state.room && state.room.npcs.get(hit.id);
      const p = n ? n.ch.root.position : hit.point;
      msg = { type: 'gg-tap', kind: 'npc', id: hit.id, x: Math.round(p.x), y: Math.round(p.z) };
    } else {
      msg = { type: 'gg-tap', kind: hit.kind, id: hit.id };
    }
    ripple(hit.point, hit.kind === 'ground' ? 0x38bdf8 : 0xfacc15);
    send(msg);
  }

  function ripple(p, color) {
    const m = new THREE.Mesh(new THREE.RingGeometry(0.15, 0.22, 28), new THREE.MeshBasicMaterial({ color, transparent: true, opacity: 0.95, depthWrite: false }));
    m.rotation.x = -Math.PI / 2;
    m.position.set(p.x, 0.03, p.z);
    scene.add(m);
    state.ripples.push({ m, t: 0 });
  }

  canvas.addEventListener('pointerdown', (e) => {
    canvas.setPointerCapture(e.pointerId);
    pointers.set(e.pointerId, { x: e.clientX, y: e.clientY });
    if (pointers.size === 1) drag = { x: e.clientX, y: e.clientY, moved: 0, t: performance.now(), button: e.button };
    if (pointers.size === 2) {
      const [a, b] = [...pointers.values()];
      pinch = { d: Math.hypot(a.x - b.x, a.y - b.y), dist: state.cam.dist, ang: Math.atan2(b.y - a.y, b.x - a.x), yaw: state.cam.yaw };
      drag = null;
    }
  });
  canvas.addEventListener('pointermove', (e) => {
    const p = pointers.get(e.pointerId);
    if (!p) {
      if (e.pointerType === 'mouse') hoverAt(e.clientX, e.clientY);
      return;
    }
    const dx = e.clientX - p.x;
    const dy = e.clientY - p.y;
    p.x = e.clientX;
    p.y = e.clientY;
    if (pinch && pointers.size === 2) {
      const [a, b] = [...pointers.values()];
      const d = Math.hypot(a.x - b.x, a.y - b.y);
      state.cam.dist = clampDist(pinch.dist * (pinch.d / Math.max(20, d)));
      state.cam.yaw = pinch.yaw - (Math.atan2(b.y - a.y, b.x - a.x) - pinch.ang);
      return;
    }
    if (drag) {
      drag.moved += Math.abs(dx) + Math.abs(dy);
      if (drag.moved > 6) {
        state.cam.yaw -= dx * 0.0065;
        state.cam.pitch = clamp(state.cam.pitch + dy * 0.0045, 0.3, 1.38);
      }
    }
  });
  const end = (e) => {
    pointers.delete(e.pointerId);
    if (drag && drag.moved <= 6 && pointers.size === 0) onTap(e.clientX, e.clientY);
    if (pointers.size < 2) pinch = null;
    if (pointers.size === 0) drag = null;
  };
  canvas.addEventListener('pointerup', end);
  canvas.addEventListener('pointercancel', (e) => {
    pointers.delete(e.pointerId);
    drag = null;
    pinch = null;
  });
  canvas.addEventListener('contextmenu', (e) => e.preventDefault());
  canvas.addEventListener(
    'wheel',
    (e) => {
      e.preventDefault();
      state.cam.dist = clampDist(state.cam.dist * (1 + clamp(e.deltaY, -120, 120) * 0.0012));
    },
    { passive: false },
  );
  function clampDist(d) {
    return state.room ? clamp(d, 5, 17) : clamp(d, 5, 26);
  }

  let lastHover = 0;
  function hoverAt(x, y) {
    const now = performance.now();
    if (now - lastHover < 50) return;
    lastHover = now;
    const hit = pickAt(x, y);
    state.hover = hit && hit.kind !== 'ground' ? hit : null;
    canvas.style.cursor = state.hover ? 'pointer' : 'default';
  }

  // keyboard: camera-relative movement → tile directions
  const held = new Set();
  const MOVE_KEYS = { w: [0, 1], arrowup: [0, 1], s: [0, -1], arrowdown: [0, -1], a: [-1, 0], arrowleft: [-1, 0], d: [1, 0], arrowright: [1, 0] };
  function moveDir() {
    let f = 0;
    let r = 0;
    for (const k of held) {
      const v = MOVE_KEYS[k];
      if (v) {
        r += v[0];
        f += v[1];
      }
    }
    if (!f && !r) return null;
    const yaw = state.cam.yaw;
    const fx = -Math.sin(yaw);
    const fz = -Math.cos(yaw);
    const rx = Math.cos(yaw);
    const rz = -Math.sin(yaw);
    const vx = fx * f + rx * r;
    const vz = fz * f + rz * r;
    if (Math.abs(vx) > Math.abs(vz)) return [Math.sign(vx), 0];
    return [0, Math.sign(vz)];
  }
  let moveTimer = 0;
  window.addEventListener('keydown', (e) => {
    const k = e.key.toLowerCase();
    if (MOVE_KEYS[k]) {
      e.preventDefault();
      if (!held.has(k)) {
        held.add(k);
        const d = moveDir();
        if (d) send({ type: 'gg-move', dx: d[0], dy: d[1] });
        moveTimer = 0.12;
      }
      return;
    }
    if (e.repeat) return;
    if (k === 'e' || k === ' ' || k === 'enter') send({ type: 'gg-key', key: 'e' });
    else if (k === 'p') send({ type: 'gg-key', key: 'p' });
    else if (k === 'm') send({ type: 'gg-key', key: 'm' });
    else if (k === 'q') state.cam.yaw += Math.PI / 4;
    else if (k === 'r') state.cam.yaw -= Math.PI / 4;
  });
  window.addEventListener('keyup', (e) => held.delete(e.key.toLowerCase()));
  window.addEventListener('blur', () => held.clear());

  // ------------------------------------------------------ resize
  function resize() {
    const w = canvas.clientWidth || window.innerWidth;
    const h = canvas.clientHeight || window.innerHeight;
    renderer.setSize(w, h, false);
    camera.aspect = w / Math.max(1, h);
    camera.fov = camera.aspect < 0.8 ? 52 : 40;
    camera.updateProjectionMatrix();
  }
  window.addEventListener('resize', resize);
  resize();

  // ------------------------------------------------------ loop
  const clock = new THREE.Clock();
  const tmp = new THREE.Vector3();
  const prev = new THREE.Vector3();
  let speed = 0;

  function anchorFor(itemId) {
    if (!state.room || !itemId) return null;
    const it = state.room.items.get(itemId);
    const a = it && it.obj.userData.anchor;
    if (!a) return null;
    const p = it.obj.localToWorld(new THREE.Vector3(a.x, 0, a.z));
    return { p, ry: it.obj.rotation.y + a.ry, pose: a.pose };
  }

  function frame() {
    const dt = Math.min(0.05, clock.getDelta());
    const f = state.frame;

    if (held.size) {
      moveTimer -= dt;
      if (moveTimer <= 0) {
        const d = moveDir();
        if (d) send({ type: 'gg-move', dx: d[0], dy: d[1] });
        moveTimer = 0.07;
      }
    }

    // player
    if (state.player) {
      prev.copy(state.pos);
      tmp.set(f.x, 0, f.y);
      state.pos.lerp(tmp, Math.min(1, dt * 18));
      if (state.pos.distanceTo(tmp) > 3) state.pos.copy(tmp);
      const v = state.pos.distanceTo(prev) / Math.max(dt, 1e-3);
      speed = lerp(speed, v, Math.min(1, dt * 10));
      const root = state.player.root;
      const anchor = SEATED.has(f.action) && !f.walking ? anchorFor(f.nearItem) : null;
      if (anchor) {
        root.position.lerp(anchor.p, Math.min(1, dt * 10));
        state.face = anchor.ry;
      } else {
        root.position.copy(state.pos);
        if (speed > 0.3) state.face = Math.atan2(state.pos.x - prev.x, state.pos.z - prev.z);
        else if (state.room && f.nearNpc && state.room.npcs.get(f.nearNpc)) {
          const n = state.room.npcs.get(f.nearNpc).ch.root.position;
          state.face = Math.atan2(n.x - state.pos.x, n.z - state.pos.z);
        } else if (state.room && f.nearItem && state.room.items.get(f.nearItem) && f.action !== 'idle') {
          const o = state.room.items.get(f.nearItem).obj.position;
          state.face = Math.atan2(o.x - state.pos.x, o.z - state.pos.z);
        }
      }
      root.rotation.y += shortAngle(root.rotation.y, state.face) * Math.min(1, dt * 12);
      state.player.update(dt, {
        walking: speed > 0.3 && f.walking !== false,
        speed,
        action: f.action === 'walk' ? 'idle' : f.action,
        emotion: f.emotion,
        seated: !!anchor,
      });
      camera.userData.playerX = state.pos.x;
      camera.userData.playerZ = state.pos.z;
    }

    // camera
    const c = state.cam;
    tmp.set(state.pos.x, 0.55, state.pos.z);
    if (state.room) {
      const b = state.room.bounds;
      tmp.x = lerp((b.w - 1) / 2, state.pos.x, 0.35);
      tmp.z = lerp((b.h - 1) / 2, state.pos.z, 0.3) + 0.4;
      tmp.y = 0.3;
    }
    c.target.lerp(tmp, Math.min(1, dt * 6));
    const cp = Math.cos(c.pitch);
    camera.position.set(c.target.x + c.dist * cp * Math.sin(c.yaw), c.target.y + c.dist * Math.sin(c.pitch), c.target.z + c.dist * cp * Math.cos(c.yaw));
    camera.lookAt(c.target);
    sky.position.copy(camera.position);
    stars.position.copy(camera.position);

    const night = applyTime(f.minute ?? 600, f.daylight ?? 1);

    if (state.city && state.mode === 'city') {
      state.city.update(dt, { night, player: state.pos, goal: f.goal });
      // fade buildings that hide the player
      const head = new THREE.Vector3(state.pos.x, 0.6, state.pos.z);
      const dir = head.clone().sub(camera.position);
      const len = dir.length();
      ray.set(camera.position, dir.normalize());
      ray.far = len - 0.3;
      const blockers = new Set();
      for (const h of ray.intersectObjects([...state.city.buildings.values()].map((b) => b.group), true)) {
        const p = h.object.userData.pick;
        if (p && p.kind === 'building') blockers.add(p.id);
      }
      ray.far = Infinity;
      for (const [id, b] of state.city.buildings) {
        const g = b.group.userData;
        const target = blockers.has(id) ? 0.12 : 1;
        if (Math.abs(g.fade - target) < 0.005) continue;
        g.fade += (target - g.fade) * Math.min(1, dt * 8);
        for (const m of g.fadeMats) {
          const tr = g.fade < 0.99 || !!m.userData.baseTransparent;
          if (m.transparent !== tr) {
            m.transparent = tr;
            m.needsUpdate = true;
          }
          m.opacity = (m.userData.baseOpacity ?? 1) * g.fade;
          m.depthWrite = g.fade > 0.98;
        }
      }
      for (const b of state.city.buildings.values()) {
        const hov = state.hover && state.hover.kind === 'building' && state.hover.id === b.data.id;
        if (!b.label.userData.base) b.label.userData.base = b.label.scale.clone();
        const k = hov || f.goal === b.data.id ? 1.18 : 1;
        b.label.userData.k = lerp(b.label.userData.k ?? 1, k, Math.min(1, dt * 8));
        b.label.scale.copy(b.label.userData.base).multiplyScalar(b.label.userData.k);
        const dd = camera.position.distanceTo(b.label.position);
        const near = clamp((dd - 9) / 6, 0, 1);
        b.label.material.opacity = b.group.userData.fade < 0.6 ? 0 : near * clamp(1.4 - dd / 38, 0.25, 1);
        b.label.visible = b.label.material.opacity > 0.02;
      }
    }
    if (state.room) {
      state.room.update(dt, {
        camera,
        nearItem: f.nearItem,
        nearNpc: f.nearNpc,
        hover: state.hover && (state.hover.kind === 'item' || state.hover.kind === 'npc') ? state.hover.id : null,
        npcStates: f.npcs,
        night,
      });
    }

    for (let i = state.ripples.length - 1; i >= 0; i--) {
      const r = state.ripples[i];
      r.t += dt;
      r.m.scale.setScalar(1 + r.t * 4);
      r.m.material.opacity = Math.max(0, 0.95 - r.t * 1.6);
      if (r.t > 0.6) {
        scene.remove(r.m);
        r.m.geometry.dispose();
        r.m.material.dispose();
        state.ripples.splice(i, 1);
      }
    }

    renderer.render(scene, camera);
    requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);

  return { setScene, setFrame, state, camera, renderer };
}
