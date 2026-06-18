import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../config/app_config.dart';
import '../utils/apple_auth.dart';
import '../utils/network_reachability.dart';

class AuthService extends ChangeNotifier {
  AuthService() {
    if (AppConfig.hasFirebase) {
      _auth = FirebaseAuth.instance;
      _auth!.authStateChanges().listen((User? user) {
        _firebaseUser = user;
        _demoSignedIn = false;
        notifyListeners();
      });
    }
  }

  FirebaseAuth? _auth;
  User? _firebaseUser;
  bool _demoSignedIn = false;
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null || _demoSignedIn;
  bool get isDemoMode => _demoSignedIn || !AppConfig.hasFirebase;
  String? get uid => _demoSignedIn ? 'demo-user' : _firebaseUser?.uid;
  String get email =>
      _demoSignedIn ? 'demo@studybuddy.app' : (_firebaseUser?.email ?? '');
  String get displayName {
    if (_demoSignedIn) return 'Demo Student';
    return _firebaseUser?.displayName ?? _firebaseUser?.email?.split('@').first ?? 'Student';
  }

  bool get hasEduEmail => isEduEmailCheck(email);

  bool get isEmailVerified => _demoSignedIn || (_firebaseUser?.emailVerified ?? false);

  Future<void> initialize() async {
    if (!AppConfig.hasFirebase) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    _firebaseUser = _auth!.currentUser;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    _requireFirebase();
    await _auth!.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<void> signUpWithEmail(String email, String password) async {
    _requireFirebase();
    final String trimmed = email.trim();
    if (!isEduEmailCheck(trimmed)) {
      throw Exception('Sign up requires a school email ending in .edu');
    }
    final UserCredential result =
        await _auth!.createUserWithEmailAndPassword(email: trimmed, password: password);
    await result.user?.sendEmailVerification();
    await reloadUser();
  }

  Future<void> reloadUser() async {
    if (!AppConfig.hasFirebase || _auth == null) return;
    await _auth!.currentUser?.reload();
    _firebaseUser = _auth!.currentUser;
    notifyListeners();
  }

  Future<void> sendEmailVerification() async {
    _requireFirebase();
    final User? user = _auth!.currentUser;
    if (user == null) throw Exception('Sign in first.');
    if (!isEduEmail(user.email ?? '')) {
      throw Exception('Verification is for school emails ending in .edu');
    }
    await user.sendEmailVerification();
  }

  Future<void> signInWithApple() async {
    _requireFirebase();

    final String rawNonce = generateAppleNonce();
    final String nonce = sha256ofString(rawNonce);

    final AuthorizationCredentialAppleID appleCredential =
        await SignInWithApple.getAppleIDCredential(
      scopes: <AppleIDAuthorizationScopes>[
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final OAuthCredential credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    final UserCredential result = await _auth!.signInWithCredential(credential);
    final String? givenName = appleCredential.givenName;
    final String? familyName = appleCredential.familyName;
    if (result.user != null && result.user!.displayName == null && givenName != null) {
      final String name = familyName != null ? '$givenName $familyName' : givenName;
      await result.user!.updateDisplayName(name);
    }
  }

  GoogleSignIn _googleSignIn() {
    final String clientId = AppConfig.googleWebClientId;
    if (clientId.isEmpty) {
      throw Exception(
        'Add GOOGLE_WEB_CLIENT_ID to .env (Firebase Console → Authentication → Google → Web client ID).',
      );
    }
    if (kIsWeb) {
      return GoogleSignIn(clientId: clientId);
    }
    return GoogleSignIn(serverClientId: clientId);
  }

  Future<void> signInWithGoogle() async {
    if (!AppConfig.hasFirebase) {
      await signInDemo();
      return;
    }

    try {
      if (kIsWeb) {
        await _auth!.signInWithPopup(GoogleAuthProvider());
        return;
      }

      await ensureGoogleReachable();

      final GoogleSignIn googleSignIn = _googleSignIn();
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        throw Exception('Google sign-in was cancelled.');
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      await _auth!.signInWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      throw Exception(_googleSignInErrorMessage(error.message));
    } catch (error) {
      final String message = error.toString();
      if (message.contains('Api10') || message.contains('10:')) {
        throw Exception(
          'Google Sign-In is not configured for this device. '
          'Add your SHA-1 fingerprint in Firebase Console, download a new google-services.json, '
          'then rebuild the app. Run: .\\scripts\\get_sha1.ps1',
        );
      }
      if (message.contains('network_error') ||
          message.contains('ApiException: 7') ||
          message.contains('ApiException: 7:')) {
        throw Exception(
          'Could not reach Google Sign-In (network error). '
          'On an emulator: cold-boot or restart the device, open Chrome and visit google.com, '
          'and confirm a Google account is added under Settings → Passwords & accounts. '
          'If google.com does not load, fix emulator internet/DNS (AVD Manager → Wipe Data, or use a physical device). '
          'You can also sign in with email below.',
        );
      }
      throw Exception(_googleSignInErrorMessage(message));
    }
  }

  String _googleSignInErrorMessage(String? message) {
    final String detail = (message ?? 'Google sign-in failed.').trim();
    if (detail.contains('origin_mismatch') ||
        detail.contains('unauthorized-domain') ||
        detail.contains('auth/unauthorized-domain')) {
      return 'This page URL is not authorized for Google sign-in. '
          'Open Firebase Console → Authentication → Settings → Authorized domains '
          'and add the host you are using (localhost is included by default for dev). '
          'Then reload and try again.';
    }
    return detail.isEmpty ? 'Google sign-in failed.' : detail;
  }

  Future<void> signInDemo() async {
    _demoSignedIn = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    if (_demoSignedIn) {
      _demoSignedIn = false;
      notifyListeners();
      return;
    }
    if (AppConfig.hasFirebase) {
      if (!kIsWeb) {
        await _googleSignIn().signOut();
      }
      await _auth!.signOut();
    }
  }

  Future<void> updateDisplayName(String name) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) throw Exception('Name cannot be empty.');

    if (_demoSignedIn) return;

    _requireFirebase();
    final User? user = _auth!.currentUser;
    if (user == null) throw Exception('Sign in first.');
    await user.updateDisplayName(trimmed);
    await reloadUser();
  }

  Future<void> deleteAccount() async {
    if (_demoSignedIn) {
      _demoSignedIn = false;
      notifyListeners();
      return;
    }

    _requireFirebase();
    final User? user = _auth!.currentUser;
    if (user == null) throw Exception('Sign in first.');

    try {
      if (!kIsWeb) {
        await _googleSignIn().signOut();
      }
      await user.delete();
    } on FirebaseAuthException catch (error) {
      if (error.code == 'requires-recent-login') {
        throw Exception('Sign out and sign in again, then try deleting your account.');
      }
      throw Exception(error.message ?? 'Could not delete account.');
    }
    _firebaseUser = null;
    notifyListeners();
  }

  void _requireFirebase() {
    if (!AppConfig.hasFirebase) {
      throw Exception(
        'Firebase is not configured. Copy .env.example to .env and add your Firebase keys.',
      );
    }
  }
}
