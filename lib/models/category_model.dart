import 'package:flutter/material.dart';

class TaskCategory {
  final int? id;
  final String name;
  final String color; // HEX
  final String icon; // named icon key
  final int? ownerId; // null یعنی دسته‌بندی پیش‌فرض سیستم
  final DateTime createdAt;

  TaskCategory({
    this.id,
    required this.name,
    this.color = '#22C55E',
    this.icon = 'folder',
    this.ownerId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  static const List<String> defaultCategories = [
    'شخصی', 'مدرسه', 'پروژه', 'مطالعه', 'کار', 'سایر'
  ];

  Color get colorValue {
    final hex = color.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData get iconData {
    switch (icon) {
      case 'person':
        return Icons.person_outline;
      case 'school':
        return Icons.school_outlined;
      case 'work':
        return Icons.work_outline;
      case 'book':
        return Icons.menu_book_outlined;
      case 'project':
        return Icons.dashboard_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'color': color,
        'icon': icon,
        'owner_id': ownerId,
        'created_at': createdAt.toIso8601String(),
      };

  factory TaskCategory.fromMap(Map<String, dynamic> map) => TaskCategory(
        id: map['id'] as int?,
        name: map['name'] as String,
        color: map['color'] as String? ?? '#7C5CFF',
        icon: map['icon'] as String? ?? 'folder',
        ownerId: map['owner_id'] as int?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
