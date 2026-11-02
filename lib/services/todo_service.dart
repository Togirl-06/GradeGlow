import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/todo_item.dart';
import '../utils/todo_day.dart';
import 'auth_service.dart';

class TodoService extends ChangeNotifier {
  TodoService(this._auth);

  final AuthService _auth;
  final List<TodoItem> _demoTodos = <TodoItem>[];

  Stream<List<TodoItem>> watchTodayTodos() {
    final String? uid = _auth.uid;
    if (uid == null) return Stream<List<TodoItem>>.value(<TodoItem>[]);

    final String day = todayDayKey;

    if (_auth.isDemoMode) {
      return Stream<List<TodoItem>>.multi((StreamController<List<TodoItem>> controller) {
        void emit() => controller.add(todosForDay(_demoTodos, day));
        emit();
        void listener() => emit();
        addListener(listener);
        controller.onCancel = () => removeListener(listener);
      });
    }

    if (!AppConfig.hasFirebase) {
      return Stream<List<TodoItem>>.value(todosForDay(_demoTodos, day));
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todos')
        .orderBy('scheduledAt')
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snap) => todosForDay(
            snap.docs
                .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => TodoItem.fromMap(doc.id, doc.data()))
                .toList(),
            day,
          ),
        );
  }

  Future<TodoItem> addTodo({
    required String title,
    required DateTime scheduledAt,
    String activityType = 'Study',
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to add a to-do.');

    final String trimmed = title.trim();
    if (trimmed.isEmpty) throw Exception('Enter a task name.');

    final String day = todoDayKey(scheduledAt);
    final String id = AppConfig.hasFirebase && !_auth.isDemoMode
        ? FirebaseFirestore.instance.collection('users').doc(uid).collection('todos').doc().id
        : 'demo-todo-${DateTime.now().millisecondsSinceEpoch}';

    final TodoItem item = TodoItem(
      id: id,
      title: trimmed,
      scheduledAt: scheduledAt,
      activityType: activityType,
      completed: false,
      dayKey: day,
    );

    if (_auth.isDemoMode || !AppConfig.hasFirebase) {
      _demoTodos.add(item);
      notifyListeners();
      return item;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).collection('todos').doc(id).set(item.toMap());
    return item;
  }

  Future<void> toggleTodo(String id, bool completed) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    if (_auth.isDemoMode || !AppConfig.hasFirebase) {
      final int index = _demoTodos.indexWhere((TodoItem t) => t.id == id);
      if (index >= 0) {
        _demoTodos[index] = _demoTodos[index].copyWith(completed: completed);
        notifyListeners();
      }
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todos')
        .doc(id)
        .update(<String, dynamic>{'completed': completed});
  }

  Future<void> deleteTodo(String id) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    if (_auth.isDemoMode || !AppConfig.hasFirebase) {
      _demoTodos.removeWhere((TodoItem t) => t.id == id);
      notifyListeners();
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).collection('todos').doc(id).delete();
  }
}
