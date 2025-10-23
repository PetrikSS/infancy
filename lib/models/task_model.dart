import 'package:flutter/foundation.dart';

class TaskModel {
  final String id;
  final String? familyId; // Делаем nullable
  final String title;
  final TaskType type;
  final String? category;
  final String? description;
  final DateTime? date;
  bool completed;
  final List<String> assignedUserIds;

  TaskModel({
    required this.id,
    this.familyId, // Теперь не required
    required this.title,
    required this.type,
    this.category,
    this.description,
    this.date,
    this.completed = false,
    List<String>? assignedUserIds,
  }) : assignedUserIds = assignedUserIds ?? [];

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    List<String> assignedIds = [];
    if (json['task_assignments'] != null) {
      assignedIds = (json['task_assignments'] as List)
          .map((a) => a['user_id'] as String)
          .toList();
    }

    return TaskModel(
      id: json['id'] as String,
      familyId: json['family_id'] as String?, // Теперь nullable
      title: json['title'] as String,
      type: TaskType.fromString(json['type'] as String),
      category: json['category'] as String?,
      description: json['description'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      completed: json['completed'] as bool? ?? false,
      assignedUserIds: assignedIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId, // Может быть null
      'title': title,
      'type': type.value,
      'category': category,
      'description': description,
      'date': date?.toIso8601String(),
      'completed': completed,
    };
  }

  TaskModel copyWith({
    String? id,
    String? familyId,
    String? title,
    TaskType? type,
    String? category,
    String? description,
    DateTime? date,
    bool? completed,
    List<String>? assignedUserIds,
  }) {
    return TaskModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      title: title ?? this.title,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      assignedUserIds: assignedUserIds ?? this.assignedUserIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel &&
        other.id == id &&
        other.familyId == familyId &&
        other.title == title &&
        other.type == type &&
        other.category == category &&
        other.description == description &&
        other.date == date &&
        other.completed == completed &&
        listEquals(other.assignedUserIds, assignedUserIds);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      familyId,
      title,
      type,
      category,
      description,
      date,
      completed,
      Object.hashAll(assignedUserIds),
    );
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, type: $type, familyId: $familyId, completed: $completed)';
  }
}

enum TaskType {
  task('task'),
  purchase('purchase'),
  wish('wish');

  const TaskType(this.value);
  final String value;

  factory TaskType.fromString(String value) {
    return TaskType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => TaskType.task,
    );
  }

  @override
  String toString() => value;
}