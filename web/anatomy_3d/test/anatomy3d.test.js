// node --test web/anatomy_3d/test/
const test = require('node:test');
const assert = require('node:assert');
const path = require('node:path');
const THREE = require(path.join(__dirname, '..', 'three.min.js'));
const data = require(path.join(__dirname, '..', 'structures.js'));
const A = require(path.join(__dirname, '..', 'anatomy3d.js'))(THREE);

test('every structure builds into meshes', () => {
  const b = A.build(data);
  assert.strictEqual(Object.keys(b.groups).length, data.structures.length);
  for (const s of data.structures) assert.ok(b.groups[s.id].children.length >= 1, s.id);
});

test('every structure can be tapped with only its own system shown', () => {
  const b = A.build(data);
  b.skin.visible = false;
  const dirs = [[0, 0, 1], [0, 0, -1], [1, 0, 0], [-1, 0, 0], [0, 1, 0], [0, -1, 0], [1, 0, 1], [-1, 0, 1], [1, 1, 1], [-1, -1, 1]];
  const unreachable = [];
  for (const s of data.structures) {
    A.setSystems(b.groups, [s.system]);
    // Aim at a point on the structure itself (thin curved tubes have empty bounding-box centres).
    const m = b.groups[s.id].children[0];
    const pos = m.geometry.attributes.position;
    const c = new THREE.Vector3().fromBufferAttribute(pos, Math.floor(pos.count / 2)).applyMatrix4(m.matrixWorld);
    const ok = dirs.some((d) => {
      const dir = new THREE.Vector3(d[0], d[1], d[2]).normalize();
      const origin = c.clone().add(dir.clone().multiplyScalar(3));
      return A.pickRay(origin, dir.clone().negate(), b.pickables) === s.id;
    });
    if (!ok) unreachable.push(s.id);
  }
  assert.deepStrictEqual(unreachable, []);
});

test('paired and lateral organs sit on the anatomically correct side', () => {
  const b = A.build(data);
  const x = (id) => A.centre(b.groups[id]).x;
  // Patient's left is +x in the model.
  assert.ok(x('heart') > 0, 'heart apex to the left');
  assert.ok(x('stomach') > 0 && x('spleen') > 0, 'stomach and spleen on the left');
  assert.ok(x('liver') < 0 && x('gallbladder') < 0 && x('appendix') < 0, 'liver, gallbladder, appendix on the right');
  assert.ok(x('kidney_l') > 0 && x('kidney_r') < 0);
  assert.ok(A.centre(b.groups.kidney_r).y < A.centre(b.groups.kidney_l).y, 'right kidney lower than the left');
});

test('vertical order follows the body', () => {
  const b = A.build(data);
  const y = (id) => A.centre(b.groups[id]).y;
  assert.ok(y('brain') > y('thyroid') && y('thyroid') > y('heart') && y('heart') > y('diaphragm') && y('diaphragm') > y('stomach') && y('stomach') > y('bladder'));
  assert.ok(y('femur_l') > y('tibia_fibula_l'));
});

test('a camera tap in front of the heart picks the heart when only the heart system is shown', () => {
  const b = A.build(data);
  b.skin.visible = false;
  A.setSystems(b.groups, ['cardiovascular']);
  const cam = new THREE.PerspectiveCamera(40, 1, 0.01, 50);
  const c = A.centre(b.groups.heart);
  cam.position.set(c.x, c.y, c.z + 1.5);
  cam.lookAt(c);
  cam.updateMatrixWorld(true);
  assert.strictEqual(A.pickScreen(cam, 0, 0, b.pickables), 'heart');
});
