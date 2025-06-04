// lib/data/models/category_model.dart
import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String type; // e.g., "PRODUCT", "SERVICE", "TRAINING"
  final String? description;
  final String? parentId;
  // Add subCategories if you fetch them hierarchically and need them in the model
  // final List<Category>? subCategories; 

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.parentId,
    // this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      parentId: json['parentId'],
      // subCategories: json['subCategories'] != null
      //     ? (json['subCategories'] as List).map((i) => Category.fromJson(i)).toList()
      //     : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'parentId': parentId,
      // 'subCategories': subCategories?.map((i) => i.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, name, type, description, parentId/*, subCategories*/];
}