// Renders real screens to PNG files (build/screens/) so the look can be
// reviewed outside a device. Real fonts are loaded so text is readable.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:ai_study_buddy/vu_v2/design/vu_v2_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

bool _fontsLoaded = false;

Future<void> loadFonts() async {
  if (_fontsLoaded) return;
  _fontsLoaded = true;
  Future<void> load(String family, List<String> paths) async {
    final FontLoader l = FontLoader(family);
    bool any = false;
    for (final String p in paths) {
      final File f = File(p);
      if (f.existsSync()) {
        l.addFont(Future<ByteData>.value(ByteData.view(Uint8List.fromList(f.readAsBytesSync()).buffer)));
        any = true;
      }
    }
    if (any) await l.load();
  }

  const List<String> sans = <String>[
    '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
    '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf',
    '/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf',
  ];
  for (final String fam in <String>['FlutterTest', 'Ahem', 'Roboto', '.SF UI Text', '.SF Pro Text', 'Inter', 'Poppins', 'packages/cupertino_icons/CupertinoIcons']) {
    await load(fam, sans);
  }
  await load('monospace', <String>['/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf']);
  // Material icons ship with the Flutter SDK.
  final String root = Platform.environment['FLUTTER_ROOT'] ?? File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  await load('MaterialIcons', <String>['$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
}

final GlobalKey _boundary = GlobalKey();

Future<void> pumpShot(WidgetTester t, CareerSimStore s, Widget home, {Size size = const Size(1440, 900)}) async {
  await loadFonts();
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  final ThemeData theme = vuV2DarkTheme();
  VuV2Colors.syncTo(theme);
  await t.pumpWidget(ChangeNotifierProvider<CareerSimStore>.value(
    value: s,
    child: RepaintBoundary(key: _boundary, child: MaterialApp(debugShowCheckedModeBanner: false, theme: theme, home: home)),
  ));
  await settle(t);
}

Future<void> settle(WidgetTester t) async {
  for (int i = 0; i < 20; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> save(WidgetTester t, String name) async {
  await settle(t);
  final RenderRepaintBoundary b = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await t.runAsync(() async {
    final ui.Image img = await b.toImage();
    final ByteData? png = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory('build/screens').createSync(recursive: true);
    File('build/screens/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}
