// GradeGlow 3D anatomy atlas: scene construction and picking.
// Works in the browser (global THREE) and in Node for tests (require).
(function (root, factory) {
  if (typeof module !== 'undefined' && module.exports) module.exports = factory;
  else root.GGAnatomy3D = factory;
})(typeof globalThis !== 'undefined' ? globalThis : this, function (THREE) {
  const DEG = Math.PI / 180;

  function material(color, opacity) {
    return new THREE.MeshStandardMaterial({
      color: new THREE.Color(color), roughness: 0.55, metalness: 0.05,
      transparent: opacity < 1, opacity: opacity, depthWrite: opacity >= 1,
    });
  }

  function partMesh(p, mat) {
    let geo;
    let mesh;
    switch (p.t) {
      case 'ellipsoid':
        geo = new THREE.SphereGeometry(1, 24, 16);
        mesh = new THREE.Mesh(geo, mat);
        mesh.scale.set(p.size[0], p.size[1], p.size[2]);
        break;
      case 'cyl':
        geo = new THREE.CylinderGeometry(p.r, p.r2, p.len, 16);
        mesh = new THREE.Mesh(geo, mat);
        break;
      case 'box':
        geo = new THREE.BoxGeometry(p.size[0], p.size[1], p.size[2]);
        mesh = new THREE.Mesh(geo, mat);
        break;
      case 'tube': {
        const pts = p.pts.map((q) => new THREE.Vector3(q[0], q[1], q[2]));
        const curve = new THREE.CatmullRomCurve3(pts);
        geo = new THREE.TubeGeometry(curve, Math.max(12, pts.length * 8), p.r, 10, false);
        mesh = new THREE.Mesh(geo, mat);
        return mesh;
      }
      default:
        throw new Error('Unknown shape ' + p.t);
    }
    mesh.position.set(p.pos[0], p.pos[1], p.pos[2]);
    mesh.rotation.set(p.rot[0] * DEG, p.rot[1] * DEG, p.rot[2] * DEG);
    return mesh;
  }

  /** Builds the scene. Returns { scene, groups: {id → Group}, pickables, skin }. */
  function build(data) {
    const scene = new THREE.Scene();
    const groups = {};
    const pickables = [];
    for (const s of data.structures) {
      const g = new THREE.Group();
      g.name = s.id;
      g.userData = { id: s.id, name: s.name, system: s.system, desc: s.desc };
      const mat = material(s.color, 1);
      for (const p of s.parts) {
        const m = partMesh(p, mat);
        m.userData = { id: s.id };
        g.add(m);
        pickables.push(m);
      }
      groups[s.id] = g;
      scene.add(g);
    }
    const skin = new THREE.Group();
    skin.name = 'skin';
    const skinMat = material('#d9a982', 0.16);
    for (const p of data.skin) skin.add(partMesh(p, skinMat));
    scene.add(skin);
    scene.updateMatrixWorld(true);
    return { scene, groups, pickables, skin };
  }

  /** The structure id hit first by a ray, considering only visible meshes. */
  function pickRay(origin, direction, pickables) {
    const ray = new THREE.Raycaster(origin, direction.clone().normalize(), 0, 100);
    const visible = pickables.filter((m) => {
      for (let o = m; o; o = o.parent) if (o.visible === false) return false;
      return true;
    });
    const hits = ray.intersectObjects(visible, false);
    return hits.length ? hits[0].object.userData.id : null;
  }

  function pickScreen(camera, ndcX, ndcY, pickables) {
    const ray = new THREE.Raycaster();
    ray.setFromCamera(new THREE.Vector2(ndcX, ndcY), camera);
    return pickRay(ray.ray.origin, ray.ray.direction, pickables);
  }

  function centre(group) {
    const box = new THREE.Box3().setFromObject(group);
    return box.getCenter(new THREE.Vector3());
  }

  /** Show only the given systems (array of ids); null shows all. */
  function setSystems(groups, systems) {
    for (const id in groups) {
      const g = groups[id];
      g.visible = !systems || systems.indexOf(g.userData.system) >= 0;
    }
  }

  return { build, pickRay, pickScreen, centre, setSystems };
});
