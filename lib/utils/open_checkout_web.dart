// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Hard redirect — avoids popup blockers and url_launcher web quirks.
Future<bool> openCheckoutInBrowser(String url) async {
  html.window.location.assign(url);
  return true;
}
