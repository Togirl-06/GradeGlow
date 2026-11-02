import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../config/billing_config.dart';
import '../models/subscription_plan.dart';
import 'auth_service.dart';

export '../config/billing_config.dart' show BillingInterval;

/// Subscription state stored on `users/{uid}.plan`.
///
/// Client apps may **read** plan and restore to free locally for testing only
/// when Firebase is off. Paid upgrades must come from store billing / backend —
/// the UI no longer free-unlocks Premium.
class SubscriptionService extends ChangeNotifier {
  SubscriptionService(this._auth);

  final AuthService _auth;

  SubscriptionPlan _plan = SubscriptionPlan.free;
  SubscriptionPlan get plan => _plan;
  bool get isPremium => _plan.isPaid;

  String? _lastCheckoutError;
  String? get lastCheckoutError => _lastCheckoutError;

  /// Stripe checkout is live. Native App Store / Play IAP is not wired yet.
  static const bool billingLive = true;

  void syncFromPlanString(String? value) {
    _plan = SubscriptionPlan.fromString(value);
  }

  Future<void> loadPlan() async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    if (_auth.isDemoMode || !AppConfig.hasFirebase) {
      return;
    }

    final DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    _plan = SubscriptionPlan.fromString(doc.data()?['plan'] as String?);
    notifyListeners();
  }

  /// Internal / backend-only plan write. UI must not call this to fake Premium.
  Future<void> setPlan(SubscriptionPlan plan) async {
    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to manage subscription.');

    if (_auth.isDemoMode || !AppConfig.hasFirebase) {
      _plan = plan;
      notifyListeners();
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      <String, dynamic>{
        'plan': plan.firestoreValue,
        'planUpdatedAt': DateTime.now().toIso8601String(),
      },
      SetOptions(merge: true),
    );
    _plan = plan;
    notifyListeners();
  }

  /// Called after a verified store purchase (when IAP is live).
  Future<void> activateAfterPayment(SubscriptionPlan plan) => setPlan(plan);

  /// Opens Stripe checkout for Premium. Plan unlocks via confirm + webhook.
  Future<bool> purchasePremium() => startPremiumCheckout();

  Future<bool> startPremiumCheckout({
    BillingInterval interval = BillingInterval.monthly,
  }) async {
    _lastCheckoutError = null;
    final String? uid = _auth.uid;
    if (uid == null) {
      _lastCheckoutError = 'Sign in to start Premium.';
      return false;
    }

    try {
      final http.Response response = await http
          .post(
            BillingConfig.createCheckoutUri(),
            headers: const <String, String>{
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(<String, dynamic>{
              'uid': uid,
              'email': _auth.email ?? '',
              'interval': BillingConfig.planFor(interval).apiInterval,
              'successUrl': BillingConfig.webSuccessUrl(),
              'cancelUrl': BillingConfig.webCancelUrl(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      final Map<String, dynamic> data = _decodeJson(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final String? url = data['url'] as String?;
        if (url == null || url.isEmpty) {
          _lastCheckoutError = 'Checkout URL missing from Stripe.';
          return false;
        }
        debugPrint('Opening Stripe checkout: $url');
        final bool opened = await BillingConfig.openCheckoutUrl(url);
        if (!opened) {
          _lastCheckoutError =
              'Browser blocked checkout redirect. Allow popups or try again.';
        }
        return opened;
      }

      _lastCheckoutError = (data['detail'] as String?) ??
          (data['error'] as String?) ??
          'Checkout failed (${response.statusCode}).';
      debugPrint('Stripe checkout API error: $_lastCheckoutError');
      return false;
    } catch (error) {
      _lastCheckoutError =
          'Could not reach Stripe (${error.runtimeType}). Check your connection.';
      debugPrint('Stripe checkout failed: $error');
      return false;
    }
  }

  /// After Stripe redirects back with `?billing=success&session_id=...`.
  Future<bool> confirmCheckoutFromReturnUrl([Uri? uri]) async {
    final Uri source = uri ?? Uri.base;
    final String billing = source.queryParameters['billing'] ?? '';
    final String sessionId = source.queryParameters['session_id'] ?? '';
    if (billing != 'success' || sessionId.isEmpty) {
      return false;
    }
    return confirmCheckoutSession(sessionId);
  }

  Future<bool> confirmCheckoutSession(String sessionId) async {
    if (sessionId.isEmpty) return false;
    try {
      final http.Response response = await http
          .post(
            BillingConfig.confirmCheckoutUri(),
            headers: const <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, dynamic>{
              'sessionId': sessionId,
              'uid': _auth.uid,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final Map<String, dynamic> data = _decodeJson(response.body);
      final bool unlocked = data['unlocked'] == true;
      if (unlocked) {
        await loadPlan();
      }
      return unlocked;
    } catch (error) {
      debugPrint('confirmCheckoutSession failed: $error');
      return false;
    }
  }

  Map<String, dynamic> _decodeJson(String body) {
    try {
      final Object? parsed = jsonDecode(body);
      if (parsed is Map<String, dynamic>) return parsed;
      if (parsed is Map) {
        return parsed.map(
          (Object? k, Object? v) => MapEntry(k.toString(), v),
        );
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  Future<bool> purchasePremiumPlus() => startPremiumCheckout();

  Future<void> restoreFree() => setPlan(SubscriptionPlan.free);

  /// Restore purchases from the store (stub until IAP is connected).
  Future<bool> restorePurchases() async {
    if (!billingLive) return false;
    await loadPlan();
    return isPremium;
  }
}
