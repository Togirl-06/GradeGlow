import 'package:shared_preferences/shared_preferences.dart';

/// Optional saved email/password for the login form ("Remember me").
abstract final class LoginRememberStore {
  static const String _rememberKey = 'login_remember_me_v1';
  static const String _emailKey = 'login_saved_email_v1';
  static const String _passwordKey = 'login_saved_password_v1';

  static Future<LoginRemembered> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool remember = prefs.getBool(_rememberKey) ?? false;
    if (!remember) {
      return const LoginRemembered(
        remember: false,
        email: '',
        password: '',
      );
    }
    return LoginRemembered(
      remember: true,
      email: prefs.getString(_emailKey) ?? '',
      password: prefs.getString(_passwordKey) ?? '',
    );
  }

  static Future<void> save({
    required bool remember,
    required String email,
    required String password,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!remember) {
      await prefs.setBool(_rememberKey, false);
      await prefs.remove(_emailKey);
      await prefs.remove(_passwordKey);
      return;
    }
    await prefs.setBool(_rememberKey, true);
    await prefs.setString(_emailKey, email.trim());
    await prefs.setString(_passwordKey, password);
  }
}

class LoginRemembered {
  const LoginRemembered({
    required this.remember,
    required this.email,
    required this.password,
  });

  final bool remember;
  final String email;
  final String password;
}
