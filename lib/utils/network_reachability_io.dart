import 'dart:async';
import 'dart:io';

Future<void> ensureGoogleReachable() async {
  await _ensureHostReachable('accounts.google.com');
}

Future<void> ensureOpenAiReachable() async {
  await _ensureHostReachable('api.openai.com');
}

Future<void> _ensureHostReachable(String host) async {
  try {
    final List<InternetAddress> result =
        await InternetAddress.lookup(host).timeout(const Duration(seconds: 12));
    if (result.isEmpty) {
      throw Exception(_offlineMessage(host));
    }
  } on TimeoutException {
    throw Exception(
      host.contains('openai')
          ? 'Connection timed out reaching OpenAI. Try again in a moment.'
          : 'Connection timed out. Check your internet and try again.',
    );
  } on SocketException {
    throw Exception(_offlineMessage(host));
  }
}

String _offlineMessage(String host) {
  if (host.contains('openai')) {
    return 'Could not reach OpenAI. Check your internet connection and try again.';
  }
  return 'No internet connection. Connect to Wi‑Fi or mobile data and try again.';
}
