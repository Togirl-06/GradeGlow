import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

String generateAppleNonce([int length = 32]) {
  const String charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final Random random = Random.secure();
  return List<String>.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
}

String sha256ofString(String input) {
  final List<int> bytes = utf8.encode(input);
  return sha256.convert(bytes).toString();
}

bool isEduEmail(String email) => isEduEmailCheck(email);

bool isEduEmailCheck(String email) => email.trim().toLowerCase().endsWith('.edu');
