import 'dart:io';

Future<void> ensureGoogleReachable() async {
  try {
    final List<InternetAddress> result = await InternetAddress.lookup('accounts.google.com')
        .timeout(const Duration(seconds: 8));
    if (result.isEmpty) {
      throw Exception('No internet connection. Connect to Wi‑Fi or mobile data and try again.');
    }
  } on SocketException {
    throw Exception('No internet connection. Connect to Wi‑Fi or mobile data and try again.');
  } on Exception catch (error) {
    if (error.toString().contains('No internet')) rethrow;
  }
}
