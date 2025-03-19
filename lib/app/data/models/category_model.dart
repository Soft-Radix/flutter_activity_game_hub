import 'package:flutter/material.dart';

class GameCategory {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final Color color;

  GameCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.color,
  });

  factory GameCategory.fromJson(Map<String, dynamic> json) {
    return GameCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconPath: json['iconPath'] as String,
      color: Color(json['color'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'color': color.value,
    };
  }
}
