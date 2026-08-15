import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Permanently removes all Firestore + Storage data for a user.
class AccountDeletionService {
  AccountDeletionService._();

  static const List<String> _userSubcollections = <String>[
    'notes',
    'chat_messages',
    'summary_subjects',
    'summaries',
    'study_plan',
    'exam_dates',
    'quizzes',
    'flashcards',
    'todos',
  ];

  static Future<void> wipeUserData(String uid) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentReference<Map<String, dynamic>> userRef =
        db.collection('users').doc(uid);

    await _deleteUploadedMaterials(db, uid);
    await _deleteAuthoredSolutions(db, uid);
    await _deleteCreatedCourses(db, uid);
    await _deleteChatSessions(userRef);

    for (final String name in _userSubcollections) {
      await _deleteCollection(userRef.collection(name));
    }

    await userRef.delete();
    await _deleteStoragePrefix('users/$uid');
  }

  static Future<void> _deleteUploadedMaterials(
    FirebaseFirestore db,
    String uid,
  ) async {
    final QuerySnapshot<Map<String, dynamic>> materials = await db
        .collection('materials')
        .where('uploaderId', isEqualTo: uid)
        .get();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> material in materials.docs) {
      final String materialId = material.id;
      final String fileName = material.data()['fileName'] as String? ?? '';

      try {
        await FirebaseStorage.instance
            .ref('users/$uid/materials/$materialId-$fileName')
            .delete();
      } catch (_) {}
      try {
        await FirebaseStorage.instance
            .ref('materials/$materialId-$fileName')
            .delete();
      } catch (_) {}

      final QuerySnapshot<Map<String, dynamic>> questions = await db
          .collection('questions')
          .where('materialId', isEqualTo: materialId)
          .get();
      await _deleteDocumentRefs(questions.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> d) => d.reference));

      await material.reference.delete();
    }
  }

  static Future<void> _deleteAuthoredSolutions(FirebaseFirestore db, String uid) async {
    final QuerySnapshot<Map<String, dynamic>> solutions = await db
        .collection('solutions')
        .where('authorId', isEqualTo: uid)
        .get();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> solution in solutions.docs) {
      await _deleteCollection(solution.reference.collection('votes'));
      await solution.reference.delete();
    }
  }

  static Future<void> _deleteCreatedCourses(FirebaseFirestore db, String uid) async {
    final QuerySnapshot<Map<String, dynamic>> courses = await db
        .collection('courses')
        .where('createdBy', isEqualTo: uid)
        .get();
    await _deleteDocumentRefs(courses.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> d) => d.reference));
  }

  static Future<void> _deleteChatSessions(DocumentReference<Map<String, dynamic>> userRef) async {
    final QuerySnapshot<Map<String, dynamic>> sessions =
        await userRef.collection('chat_sessions').get();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> session in sessions.docs) {
      await _deleteCollection(session.reference.collection('messages'));
      await session.reference.delete();
    }
  }

  static Future<void> _deleteCollection(CollectionReference<Map<String, dynamic>> collection) async {
    while (true) {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await collection.limit(200).get();
      if (snapshot.docs.isEmpty) return;
      await _deleteDocumentRefs(snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> d) => d.reference));
    }
  }

  static Future<void> _deleteDocumentRefs(Iterable<DocumentReference<Map<String, dynamic>>> refs) async {
    final List<DocumentReference<Map<String, dynamic>>> batchRefs = refs.toList();
    if (batchRefs.isEmpty) return;

    for (int i = 0; i < batchRefs.length; i += 450) {
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      final int end = (i + 450 < batchRefs.length) ? i + 450 : batchRefs.length;
      for (int j = i; j < end; j++) {
        batch.delete(batchRefs[j]);
      }
      await batch.commit();
    }
  }

  static Future<void> _deleteStoragePrefix(String path) async {
    try {
      final Reference root = FirebaseStorage.instance.ref(path);
      final ListResult listing = await root.listAll();
      for (final Reference item in listing.items) {
        await item.delete();
      }
      for (final Reference prefix in listing.prefixes) {
        await _deleteStoragePrefix(prefix.fullPath);
      }
    } catch (_) {}
  }
}
