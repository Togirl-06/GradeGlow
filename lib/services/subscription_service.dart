import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/subscription_plan.dart';
import 'auth_service.dart';

/// Subscription state stored on `users/{uid}.plan`.
/// Real billing (Stripe / App Store / Play) hooks in here later.
class SubscriptionService extends ChangeNotifier {
  SubscriptionService(this._auth);

  final AuthService _auth;

  SubscriptionPlan _plan = SubscriptionPlan.free;
  SubscriptionPlan get plan => _plan;
  bool get isPremium => _plan.isPaid;

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

  /// Demo / future webhook handler after payment succeeds.
  Future<void> activateAfterPayment(SubscriptionPlan plan) => setPlan(plan);

  Future<void> purchasePremium() => activateAfterPayment(SubscriptionPlan.premium);

  Future<void> purchasePremiumPlus() => activateAfterPayment(SubscriptionPlan.premiumPlus);

  Future<void> restoreFree() => setPlan(SubscriptionPlan.free);
}
