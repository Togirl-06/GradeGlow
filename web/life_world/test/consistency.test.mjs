// Keeps the 3D world in step with the Dart game data.
import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, '..', '..', '..');
const read = (p) => readFileSync(join(root, p), 'utf8');

test('every furniture item sold in the shop has a spot in the 3D apartment', () => {
  const shop = read('lib/life_sim/economy/shop_catalog.dart');
  const block = shop.slice(shop.indexOf('static const List<ShopItem> furniture'));
  const items = [];
  for (const m of block.matchAll(/id: '([a-z_]+)',[\s\S]*?category: ShopCategory\.(\w+)/g)) {
    if (m[2] !== 'furniture') break;
    items.push(m[1]);
  }
  assert.ok(items.length >= 5, `found furniture ${items}`);
  const interior = read('web/life_world/interior.js');
  const spots = interior.slice(interior.indexOf('const DECOR_SPOTS'), interior.indexOf('function addDecor'));
  for (const id of items) assert.match(spots, new RegExp(`\\b${id}: \\{`), `no 3D spot for ${id}`);
});

test('every school building on the map has its own 3D facade', () => {
  const map = read('lib/life_sim/world/city_map.dart');
  const ids = [...map.slice(map.indexOf('schoolIds'), map.indexOf('];', map.indexOf('schoolIds'))).matchAll(/'(school_[a-z_]+)'/g)].map((m) => m[1]);
  assert.ok(ids.length >= 12, `schools ${ids}`);
  const buildings = read('web/life_world/buildings.js');
  for (const id of ids) assert.match(buildings, new RegExp(`\\n  ${id}\\(g, k\\) \\{`), `no facade for ${id}`);
});

test('the apartment scene sends placed furniture to the 3D page', () => {
  const screen = read('lib/life_sim/ui/screens/life_game_screen.dart');
  assert.match(screen, /'decor': <String>\[\.\.\.g\.economy\.placedFurniture\]/);
  assert.match(read('web/life_world/interior.js'), /addDecor\(group, data\.decor\)/);
});
