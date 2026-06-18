import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/solution.dart';
import 'auth_service.dart';

class SolutionService extends ChangeNotifier {
  SolutionService(this._auth);

  final AuthService _auth;
  static const int verifiedSolverThreshold = 10;
  final Map<String, List<QuestionSolution>> _demoSolutions = <String, List<QuestionSolution>>{};

  Future<QuestionSolution?> getTopSolution(String questionId) async {
    if (!AppConfig.hasFirebase) {
      final List<QuestionSolution> items = List<QuestionSolution>.from(_demoSolutions[questionId] ?? <QuestionSolution>[]);
      if (items.isEmpty) return null;
      items.sort((QuestionSolution a, QuestionSolution b) => b.score.compareTo(a.score));
      return items.first;
    }
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('solutions')
        .where('questionId', isEqualTo: questionId)
        .limit(20)
        .get();
    final List<QuestionSolution> items = snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => QuestionSolution.fromMap(doc.id, doc.data()))
        .toList();
    if (items.isEmpty) return null;
    items.sort((QuestionSolution a, QuestionSolution b) => b.score.compareTo(a.score));
    return items.first;
  }

  Stream<List<QuestionSolution>> watchSolutions(String questionId) {
    if (!AppConfig.hasFirebase) {
      final List<QuestionSolution> items = List<QuestionSolution>.from(_demoSolutions[questionId] ?? <QuestionSolution>[]);
      items.sort((QuestionSolution a, QuestionSolution b) => b.score.compareTo(a.score));
      return Stream<List<QuestionSolution>>.value(items);
    }
    return FirebaseFirestore.instance
        .collection('solutions')
        .where('questionId', isEqualTo: questionId)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      final List<QuestionSolution> items = snapshot.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                QuestionSolution.fromMap(doc.id, doc.data()),
          )
          .toList();
      items.sort((QuestionSolution a, QuestionSolution b) => b.score.compareTo(a.score));
      return items;
    });
  }

  Future<void> submitSolution({
    required String questionId,
    required String stepByStep,
    required String finalAnswer,
    bool anonymous = false,
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to post a solution.');

    final DocumentReference<Map<String, dynamic>> ref =
        FirebaseFirestore.instance.collection('solutions').doc();

    final QuestionSolution solution = QuestionSolution(
      id: ref.id,
      questionId: questionId,
      authorId: anonymous ? '' : uid,
      authorName: anonymous ? 'Anonymous' : _auth.displayName,
      stepByStep: stepByStep.trim(),
      finalAnswer: finalAnswer.trim(),
      upvotes: 0,
      downvotes: 0,
      verified: false,
      createdAt: DateTime.now(),
    );

    if (!AppConfig.hasFirebase) {
      _demoSolutions.putIfAbsent(questionId, () => <QuestionSolution>[]).add(solution);
      notifyListeners();
      return;
    }

    await ref.set(solution.toMap());

    await FirebaseFirestore.instance.collection('questions').doc(questionId).update(<String, dynamic>{
      'hasSolution': true,
    });

    if (!anonymous) {
      final DocumentReference<Map<String, dynamic>> userRef =
          FirebaseFirestore.instance.collection('users').doc(uid);
      await FirebaseFirestore.instance.runTransaction((Transaction tx) async {
        final DocumentSnapshot<Map<String, dynamic>> snap = await tx.get(userRef);
        final int count = (snap.data()?['solutionsCount'] as num?)?.toInt() ?? 0;
        final int next = count + 1;
        tx.set(userRef, <String, dynamic>{
          'solutionsCount': next,
          'verifiedSolver': next >= verifiedSolverThreshold,
        }, SetOptions(merge: true));
      });
    }
  }

  Future<void> vote(String solutionId, {required bool upvote}) async {
    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to vote.');

    final DocumentReference<Map<String, dynamic>> ref =
        FirebaseFirestore.instance.collection('solutions').doc(solutionId);
    final DocumentReference<Map<String, dynamic>> voteRef = ref.collection('votes').doc(uid);

    await FirebaseFirestore.instance.runTransaction((Transaction tx) async {
      final DocumentSnapshot<Map<String, dynamic>> voteSnap = await tx.get(voteRef);
      final DocumentSnapshot<Map<String, dynamic>> solutionSnap = await tx.get(ref);
      int upvotes = (solutionSnap.data()?['upvotes'] as num?)?.toInt() ?? 0;
      int downvotes = (solutionSnap.data()?['downvotes'] as num?)?.toInt() ?? 0;
      final String? previous = voteSnap.data()?['type'] as String?;

      if (previous == 'up') upvotes--;
      if (previous == 'down') downvotes--;

      if (upvote) {
        upvotes++;
        tx.set(voteRef, <String, dynamic>{'type': 'up'});
      } else {
        downvotes++;
        tx.set(voteRef, <String, dynamic>{'type': 'down'});
      }

      final bool verified = upvotes >= 5;
      tx.update(ref, <String, dynamic>{
        'upvotes': upvotes,
        'downvotes': downvotes,
        'verified': verified,
      });
    });
  }
}
