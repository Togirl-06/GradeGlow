// Standalone preview (open life_world/index.html?demo=1). Mirrors the Dart
// world data and runs a tiny movement sim so the 3D view can be tried and
// tested without Flutter. The real game is driven by lib/life_sim.
import { ROOMS, STATIONS, EMPLOYERS, DISTRICTS, BUILDINGS, GRID } from './demo_data.js';
import { hashStr } from './util.js';

const cellW = GRID.cellW;
const cellH = GRID.cellH;
const W = GRID.cols * cellW + 1;
const H = GRID.rows * cellH + 1;

function buildings() {
  return BUILDINGS.map((b) => ({ ...b }));
}

const SKIN = [0xffffdfc4, 0xfff1c27d, 0xffe0ac69, 0xffc68642, 0xff8d5524, 0xff5a3825];
const HAIR = [0xff1b1b1b, 0xff2c1810, 0xff6b4423, 0xffb7872f, 0xffb5341f, 0xff9e9e9e, 0xff3f51b5];
const tone = (v, t) => (v >= 0 && v < t.length ? t[v] : v);

function npcLook(n) {
  const fem = hashStr(n.id) % 2 === 0;
  const r = n.role.toLowerCase();
  return {
    skin: tone(n.skin, SKIN),
    hair: tone(n.hair, HAIR),
    outfit: n.outfit,
    hairStyle: n.hairStyle || (fem ? 'long' : 'short'),
    feminine: fem,
    accessory: r.includes('prof') || r.includes('librar') ? 'glasses' : 'none',
  };
}

function nameFor(seed) {
  const first = ['Amara', 'Diego', 'Priya', 'Tomás', 'Yuki', 'Kofi', 'Elena', 'Marcus', 'Nadia', 'Owen', 'Zara', 'Felix'];
  const last = ['Okafor', 'Lindqvist', 'Rao', 'Moreau', 'Tanaka', 'Mensah', 'Rossi', 'Bennett', 'Haddad', 'Novak'];
  const h = hashStr(seed);
  return first[h % first.length] + ' ' + last[(h >>> 8) % last.length];
}

function roomFor(b) {
  const e = b.employer ? EMPLOYERS.find((x) => x.id === b.employer) : null;
  if (e) {
    const items = [
      { id: 'reception', name: 'Reception', emoji: '🛎️', x: 1, y: 6, type: 'clockIn', arg: e.id, hint: 'Clock in / out.' },
      { id: 'hr', name: 'HR Office', emoji: '📇', x: 10, y: 6, type: 'hrDesk', arg: e.id, hint: 'Interviews, contracts, raises, resignation.' },
      { id: 'break', name: 'Break Room', emoji: '☕', x: 10, y: 1, type: 'breakRoom', hint: 'Coffee and a chat.' },
    ];
    if (e.hires.some((h) => ['nurse', 'doctor', 'pharmacist'].includes(h))) items.push({ id: 'clinic', name: 'Walk-in Clinic', emoji: '🩹', x: 7, y: 6, type: 'healthCheck', hint: 'Paid health check-up.' });
    const st = [];
    for (const c of e.hires) for (const s of STATIONS[c] || []) st.push([c, s]);
    st.forEach(([c, s], k) => items.push({ id: s.id + '@' + c, name: s.name, emoji: s.emoji, x: 1 + 2 * (k % 4), y: 1 + 2 * Math.floor(k / 4), type: 'workStation', arg: s.id, hint: `Work station for ${c.replace('_', ' ')}s.` }));
    const npcs = [
      { id: 'hr_' + e.id, name: e.interviewer.name, role: e.interviewer.title, x: 9, y: 6, look: { skin: e.interviewer.skin, hair: e.interviewer.hair, outfit: e.interviewer.outfit, hairStyle: e.interviewer.hairStyle, feminine: hashStr(e.interviewer.name) % 2 === 0 } },
      ...e.hires.map((h, c) => {
        const n = { id: `col_${e.id}_${c}`, name: nameFor(`${e.id}|${c}`), role: 'Colleague', x: 3 + 4 * (c % 2), y: 7 - Math.floor(c / 2), skin: 1 + (c % 4), hair: c % 5, outfit: e.accent };
        n.role = h === 'nurse' ? 'Staff nurse' : h === 'doctor' ? 'Doctor' : h === 'pharmacist' ? 'Pharmacist' : h === 'lawyer' ? 'Associate lawyer' : 'Colleague';
        return { ...n, look: npcLook(n) };
      }),
    ];
    return { buildingId: b.id, name: b.name, emoji: b.emoji, w: 12, h: 9, exitX: 5, exitY: 8, floor: 0xfff1f5f9, wall: e.accent, accent: e.accent, items, npcs };
  }
  const r = ROOMS[b.id] || { items: [], npcs: [], floor: 0xffe5e7eb, wall: 0xff94a3b8 };
  return {
    buildingId: b.id,
    name: b.name,
    emoji: b.emoji,
    w: 12,
    h: 9,
    exitX: 5,
    exitY: 8,
    floor: r.floor,
    wall: r.wall,
    accent: b.color,
    walls: r.walls || [],
    zones: r.zones || [],
    items: r.items,
    npcs: r.npcs.map((n) => ({ ...n, look: npcLook(n) })),
  };
}

function bfs(w, h, sx, sy, gx, gy, ok) {
  if (!ok(gx, gy) || !ok(sx, sy)) return [];
  if (sx === gx && sy === gy) return [[sx, sy]];
  const prev = new Int32Array(w * h).fill(-1);
  const q = [sy * w + sx];
  prev[sy * w + sx] = sy * w + sx;
  for (let head = 0; head < q.length; head++) {
    const cur = q[head];
    const cx = cur % w;
    const cy = Math.floor(cur / w);
    for (const [dx, dy] of [[1, 0], [-1, 0], [0, 1], [0, -1]]) {
      const nx = cx + dx;
      const ny = cy + dy;
      if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
      const ni = ny * w + nx;
      if (prev[ni] !== -1 || !ok(nx, ny)) continue;
      prev[ni] = cur;
      if (nx === gx && ny === gy) {
        const p = [];
        let c = ni;
        while (c !== sy * w + sx) {
          p.push([c % w, Math.floor(c / w)]);
          c = prev[c];
        }
        p.push([sx, sy]);
        return p.reverse();
      }
      q.push(ni);
    }
  }
  return [];
}

/** Scene messages for test harnesses (same shape the Dart side sends). */
export function cityScene() {
  return { type: 'gg-scene', mode: 'city', w: W, h: H, cellW, cellH, districts: DISTRICTS, buildings: buildings(), player: { x: 3, y: 7 } };
}
export function roomScene(id) {
  const b = buildings().find((x) => x.id === id);
  return { type: 'gg-scene', mode: 'interior', ...roomFor(b), player: { x: 5, y: 7 } };
}

const ACTION_FOR = {
  openLab: 'study',
  lectureHall: 'study', sleep: 'sleep', eatHome: 'eat', laptop: 'useComputer', studyHome: 'study', studyDesk: 'study', relaxHome: 'sit', relaxPark: 'sit', socialize: 'talk', workStation: 'work', graduation: 'celebrate', watchMovie: 'sit', breakRoom: 'sit', workout: 'work', resumeDesk: 'useComputer', certDesk: 'study' };

export function runDemo(world, params) {
  const B = buildings();
  const blocked = new Set();
  for (const b of B) for (let y = b.y; y < b.y + b.h; y++) for (let x = b.x; x < b.x + b.w; x++) blocked.add(x + ',' + y);
  const walk = (x, y) => x >= 0 && y >= 0 && x < W && y < H && !blocked.has(x + ',' + y);

  const look = {
    skin: 0xffc68642,
    hair: 0xff1b1b1b,
    outfit: 0xfff97316,
    hairStyle: params.get('hair') || 'curly',
    accessory: params.get('acc') || 'none',
    feminine: params.get('fem') !== '0',
    uniform: params.get('uniform') || 'casual',
  };
  const [hh, mm] = (params.get('time') || '10:30').split(':').map(Number);
  const s = {
    mode: 'city',
    room: null,
    bx: 7 + 1 + 2,
    by: 7,
    ix: 5,
    iy: 7,
    fx: 0,
    fy: 0,
    queue: [],
    stepT: 0,
    goal: null,
    goalItem: null,
    goalNpc: null,
    minute: hh * 60 + (mm || 0),
    action: null,
    actionT: 0,
    toast: '',
    toastT: 0,
    clockRate: params.has('clock') ? Number(params.get('clock')) || 10 : 0,
  };
  const startB = B.find((b) => b.id === (params.get('near') || 'apartment_block'));
  s.bx = startB.x + Math.floor(startB.w / 2);
  s.by = startB.y + startB.h;
  s.fx = s.bx;
  s.fy = s.by;
  const STEP = 0.26;

  const cityMsg = () => ({ type: 'gg-scene', mode: 'city', w: W, h: H, cellW, cellH, districts: DISTRICTS, buildings: B, look, player: { x: s.bx, y: s.by } });
  function enter(b) {
    s.mode = 'interior';
    s.room = roomFor(b);
    s.ix = s.room.exitX;
    s.iy = s.room.exitY - 1;
    s.fx = s.ix;
    s.fy = s.iy;
    world.setScene({ type: 'gg-scene', mode: 'interior', buildingId: b.id, ...s.room, look, player: { x: s.ix, y: s.iy } });
  }
  function leave() {
    s.mode = 'city';
    s.room = null;
    s.fx = s.bx;
    s.fy = s.by;
    world.setScene(cityMsg());
  }

  const toastEl = document.getElementById('toast');
  function say(t) {
    s.toast = t;
    s.toastT = 3.5;
    if (toastEl) {
      toastEl.textContent = t;
      toastEl.style.opacity = 1;
    }
  }

  const roomBlocked = (x, y) => {
    const r = s.room;
    if (x < 0 || y < 0 || x >= r.w || y >= r.h) return true;
    return r.items.some((i) => i.x === x && i.y === y) || r.npcs.some((n) => n.x === x && n.y === y) || (r.walls || []).some((w) => w[0] === x && w[1] === y);
  };

  function goNextTo(x, y) {
    let best = null;
    for (const [dx, dy] of [[0, 1], [1, 0], [-1, 0], [0, -1]]) {
      const nx = x + dx;
      const ny = y + dy;
      if (roomBlocked(nx, ny)) continue;
      const p = bfs(s.room.w, s.room.h, s.ix, s.iy, nx, ny, (a, b) => !roomBlocked(a, b));
      if (p.length && (!best || p.length < best.length)) best = p;
    }
    if (!best) return false;
    s.queue = best.slice(1);
    if (!s.queue.length) arrive();
    return true;
  }

  function arrive() {
    if (s.mode === 'city' && s.goal) {
      const b = B.find((x) => x.id === s.goal);
      s.goal = null;
      if (b) enter(b);
    } else if (s.goalItem) {
      const it = s.goalItem;
      s.goalItem = null;
      s.action = ACTION_FOR[it.type] || 'idle';
      s.actionT = 2.6;
      say(it.type === 'openLab' ? `${it.emoji} ${it.name} — opens the ${it.name} activity in the app. ${it.hint}` : `${it.emoji} ${it.name} — ${it.hint || 'opens in the game'}`);
    } else if (s.goalNpc) {
      const n = s.goalNpc;
      s.goalNpc = null;
      s.action = 'talk';
      s.actionT = 2.4;
      say(`💬 ${n.name} (${n.role}): "Hi! Welcome."`);
    } else if (s.goalExit) {
      s.goalExit = false;
      leave();
    }
  }

  function onMessage(m) {
    if (m.type === 'gg-tap') {
      s.queue = [];
      s.goal = s.goalItem = s.goalNpc = null;
      s.goalExit = false;
      if (s.mode === 'city') {
        if (m.kind === 'building') {
          const b = B.find((x) => x.id === m.id);
          s.goal = b.id;
          const p = bfs(W, H, s.bx, s.by, b.x + Math.floor(b.w / 2), b.y + b.h, walk);
          s.queue = p.slice(1);
          if (!s.queue.length) arrive();
        } else if (m.kind === 'tile') {
          s.queue = bfs(W, H, s.bx, s.by, m.x, m.y, walk).slice(1);
        }
      } else {
        const r = s.room;
        if (m.kind === 'exit') {
          s.goalExit = true;
          s.queue = bfs(r.w, r.h, s.ix, s.iy, r.exitX, r.exitY, (a, b) => !roomBlocked(a, b)).slice(1);
          if (!s.queue.length) arrive();
        } else if (m.kind === 'item') {
          const it = r.items.find((i) => i.id === m.id);
          s.goalItem = it;
          if (!goNextTo(it.x, it.y)) s.goalItem = null;
        } else if (m.kind === 'npc') {
          const n = r.npcs.find((i) => i.id === m.id);
          s.goalNpc = n;
          if (!goNextTo(n.x, n.y)) s.goalNpc = null;
        } else if (m.kind === 'tile' && !roomBlocked(m.x, m.y)) {
          s.queue = bfs(r.w, r.h, s.ix, s.iy, m.x, m.y, (a, b) => !roomBlocked(a, b)).slice(1);
        }
      }
    } else if (m.type === 'gg-move' && !s.queue.length) {
      if (s.mode === 'city') {
        const nx = s.bx + m.dx;
        const ny = s.by + m.dy;
        if (walk(nx, ny)) s.queue = [[nx, ny]];
        else {
          const b = B.find((b) => Math.abs(b.x + Math.floor(b.w / 2) - s.bx) + Math.abs(b.y + b.h - s.by) <= 1);
          if (b) enter(b);
        }
      } else {
        const nx = s.ix + m.dx;
        const ny = s.iy + m.dy;
        if (!roomBlocked(nx, ny)) s.queue = [[nx, ny]];
        else if (ny >= s.room.h) leave();
      }
    } else if (m.type === 'gg-key' && m.key === 'e') {
      if (s.mode === 'city') {
        const b = B.find((b) => Math.abs(b.x + Math.floor(b.w / 2) - s.bx) + Math.abs(b.y + b.h - s.by) <= 1);
        if (b) enter(b);
      } else if (Math.abs(s.ix - s.room.exitX) + Math.abs(s.iy - s.room.exitY) <= 1) leave();
      else {
        const it = s.room.items.find((i) => Math.abs(i.x - s.ix) + Math.abs(i.y - s.iy) <= 1);
        if (it) {
          s.goalItem = it;
          arrive();
        }
      }
    }
  }

  if (!params.get('scene') && params.get('at')) {
    const [x, y] = params.get('at').split(',').map(Number);
    s.bx = s.fx = x;
    s.by = s.fy = y;
  }
  world.setScene(cityMsg());
  const startIn = params.get('scene');
  if (startIn) {
    const b = B.find((x) => x.id === startIn);
    if (b) enter(b);
    if (params.get('at')) {
      const [x, y] = params.get('at').split(',').map(Number);
      s.ix = s.fx = x;
      s.iy = s.fy = y;
    }
  } else if (params.get('at')) {
    const [x, y] = params.get('at').split(',').map(Number);
    s.bx = s.fx = x;
    s.by = s.fy = y;
  }
  if (params.get('yaw')) world.state.cam.yaw = Number(params.get('yaw'));
  if (params.get('pitch')) world.state.cam.pitch = Number(params.get('pitch'));
  if (params.get('dist')) world.state.cam.dist = Number(params.get('dist'));
  if (params.get('action')) {
    s.action = params.get('action');
    s.actionT = 1e9;
  }

  let last = performance.now();
  function tick() {
    const now = performance.now();
    const dt = Math.min(0.05, (now - last) / 1000);
    last = now;
    s.minute = (s.minute + dt * s.clockRate) % 1440;
    const inside = s.mode === 'interior';
    let cx = inside ? s.ix : s.bx;
    let cy = inside ? s.iy : s.by;
    let walking = false;
    if (s.queue.length) {
      walking = true;
      s.stepT += dt;
      const [nx, ny] = s.queue[0];
      const k = Math.min(1, s.stepT / STEP);
      s.fx = cx + (nx - cx) * k;
      s.fy = cy + (ny - cy) * k;
      if (s.stepT >= STEP) {
        s.stepT = 0;
        if (inside) {
          s.ix = nx;
          s.iy = ny;
        } else {
          s.bx = nx;
          s.by = ny;
        }
        s.queue.shift();
        s.fx = nx;
        s.fy = ny;
        if (!s.queue.length) arrive();
      }
    } else {
      s.fx = inside ? s.ix : s.bx;
      s.fy = inside ? s.iy : s.by;
    }
    if (s.actionT > 0) {
      s.actionT -= dt;
      if (s.actionT <= 0) s.action = null;
    }
    if (s.toastT > 0) {
      s.toastT -= dt;
      if (s.toastT <= 0 && toastEl) toastEl.style.opacity = 0;
    }
    const h = s.minute / 60;
    const daylight = h < 5 || h >= 20 ? 0 : h < 8 ? (h - 5) / 3 : h < 17 ? 1 : 1 - (h - 17) / 3;
    let nearItem = null;
    let nearNpc = null;
    if (inside) {
      let bd = 2.2;
      for (const i of s.room.items) {
        const d = Math.abs(i.x - s.fx) + Math.abs(i.y - s.fy);
        if (d < bd) {
          bd = d;
          nearItem = i.id;
        }
      }
      for (const n of s.room.npcs) if (Math.abs(n.x - s.fx) + Math.abs(n.y - s.fy) <= 1.6) nearNpc = n.id;
    }
    const closed = B.filter((b) => !(b.open === 0 && b.close >= 24) && !(h >= b.open && h < b.close)).map((b) => b.id);
    world.setFrame({
      x: s.fx,
      y: s.fy,
      walking,
      action: s.action || (walking ? 'walk' : 'idle'),
      emotion: 'happy',
      minute: s.minute,
      daylight,
      nearItem: s.action === 'talk' ? null : nearItem,
      nearNpc: s.action === 'talk' ? nearNpc : null,
      goal: s.goal,
      closed,
      npcs: inside ? Object.fromEntries(s.room.npcs.map((n) => [n.id, [n.x, n.y, 0, 'working']])) : {},
    });
    requestAnimationFrame(tick);
  }
  requestAnimationFrame(tick);
  return onMessage;
}
