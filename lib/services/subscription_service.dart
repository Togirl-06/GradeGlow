import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/subscription_plan.dart';
import 'auth_service.dart';

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

  /// True when real IAP / Play Billing is wired. Until then, upgrade CTAs explain waitlist.
  static const bool billingLive = false;

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

  /// Called after a verified store purchase (when billing is live).
  Future<void> activateAfterPayment(SubscriptionPlan plan) => setPlan(plan);

  /// Purchase Premium via store — not available until [billingLive].
  Future<bool> purchasePremium() async {
    if (!billingLive) {
      debugPrint('Premium purchase blocked — billing not live yet.');
      return false;
    }
    await activateAfterPayment(SubscriptionPlan.premium);
    return true;
  }

  Future<bool> purchasePremiumPlus() async {
    if (!billingLive) return false;
    await activateAfterPayment(SubscriptionPlan.premiumPlus);
    return true;
  }

  Future<void> restoreFree() => setPlan(SubscriptionPlan.free);

  /// Restore purchases from the store (stub until IAP is connected).
  Future<bool> restorePurchases() async {
    if (!billingLive) return false;
    await loadPlan();
    return isPremium;
  }
}
