import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/course.dart';
import 'auth_service.dart';

class CourseService extends ChangeNotifier {
  CourseService(this._auth);

  final AuthService _auth;
  final List<Course> _demoCourses = <Course>[];

  Stream<List<Course>> watchCourses() {
    if (!AppConfig.hasFirebase) {
      return Stream<List<Course>>.value(List<Course>.from(_demoCourses));
    }
    return FirebaseFirestore.instance
        .collection('courses')
        .orderBy('code')
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => Course.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<Course>> watchMyCourses(List<String> courseIds) {
    if (courseIds.isEmpty) return Stream<List<Course>>.value(<Course>[]);
    return watchCourses().map(
      (List<Course> all) => all.where((Course c) => courseIds.contains(c.id)).toList(),
    );
  }

  List<Course> searchCourses(List<Course> courses, String query) {
    if (query.trim().isEmpty) return courses;
    final String q = query.trim().toLowerCase();
    return courses.where((Course c) {
      return c.code.toLowerCase().contains(q) ||
          c.professor.toLowerCase().contains(q) ||
          c.semester.toLowerCase().contains(q) ||
          c.name.toLowerCase().contains(q);
    }).toList();
  }

  Future<Course?> findExisting({
    required String code,
    required String professor,
    required String semester,
  }) async {
    final String normalizedCode = code.trim().toUpperCase();
    final String prof = professor.trim();
    final String sem = semester.trim();

    if (!AppConfig.hasFirebase) {
      return _demoCourses.cast<Course?>().firstWhere(
            (Course? c) =>
                c?.code == normalizedCode && c?.professor == prof && c?.semester == sem,
            orElse: () => null,
          );
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('code', isEqualTo: normalizedCode)
        .where('professor', isEqualTo: prof)
        .where('semester', isEqualTo: sem)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final QueryDocumentSnapshot<Map<String, dynamic>> doc = snapshot.docs.first;
    return Course.fromMap(doc.id, doc.data());
  }

  Future<Course> addCourse({
    required String code,
    required String professor,
    required String semester,
    String name = '',
    String school = '',
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to add a course.');

    final String normalizedCode = code.trim().toUpperCase();
    final String prof = professor.trim();
    final String sem = semester.trim();

    if (normalizedCode.isEmpty || prof.isEmpty || sem.isEmpty) {
      throw Exception('Course code, professor, and semester are required.');
    }

    final Course? existing = await findExisting(
      code: normalizedCode,
      professor: prof,
      semester: sem,
    );
    if (existing != null) return existing;

    final Course course = Course(
      id: AppConfig.hasFirebase
          ? FirebaseFirestore.instance.collection('courses').doc().id
          : 'demo-${DateTime.now().millisecondsSinceEpoch}',
      code: normalizedCode,
      name: name.trim().isEmpty ? normalizedCode : name.trim(),
      professor: prof,
      semester: sem,
      school: school.trim(),
      createdBy: uid,
    );

    if (!AppConfig.hasFirebase) {
      _demoCourses.add(course);
      notifyListeners();
      return course;
    }

    await FirebaseFirestore.instance.collection('courses').doc(course.id).set(course.toMap());
    notifyListeners();
    return course;
  }
}
