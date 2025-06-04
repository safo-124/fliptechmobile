// lib/data/models/product_listing_model.dart
import 'package:equatable/equatable.dart';

// Simple stubs for related data that might come with a product
class SimpleArtisan extends Equatable {
  final String id;
  final String? name;
  const SimpleArtisan({required this.id, this.name});

  factory SimpleArtisan.fromJson(Map<String, dynamic> json) {
    return SimpleArtisan(id: json['id'], name: json['name']);
  }
  @override
  List<Object?> get props => [id, name];
}

class SimpleCategory extends Equatable {
  final String id;
  final String? name;
  const SimpleCategory({required this.id, this.name});

  factory SimpleCategory.fromJson(Map<String, dynamic> json) {
    return SimpleCategory(id: json['id'], name: json['name']);
  }
  @override
  List<Object?> get props => [id, name];
}


class ProductListing extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final List<String> images; // URLs
  final int? stockQuantity;
  final List<String> materials;
  final String? dimensions;
  final String? sku;
  final String? shippingDetails;
  final String status;
  final String artisanId; // Should always be present
  final SimpleArtisan? artisan; // Optional, if fetched with product details
  final String categoryId; // Should always be present
  final SimpleCategory? category; // Optional, if fetched with product details
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductListing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.images,
    this.stockQuantity,
    required this.materials,
    this.dimensions,
    this.sku,
    this.shippingDetails,
    required this.status,
    required this.artisanId,
    this.artisan,
    required this.categoryId,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductListing.fromJson(Map<String, dynamic> json) {
    return ProductListing(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'GHS',
      images: List<String>.from((json['images'] as List<dynamic>?)?.map((e) => e.toString()) ?? []),
      stockQuantity: json['stockQuantity'] as int?,
      materials: List<String>.from((json['materials'] as List<dynamic>?)?.map((e) => e.toString()) ?? []),
      dimensions: json['dimensions'] as String?,
      sku: json['sku'] as String?,
      shippingDetails: json['shippingDetails'] as String?,
      status: json['status'] as String,
      artisanId: json['artisanId'] as String? ?? (json['artisan'] != null ? json['artisan']['id'] as String : throw Exception('Missing artisanId')),
      artisan: json['artisan'] != null ? SimpleArtisan.fromJson(json['artisan']) : null,
      categoryId: json['categoryId'] as String? ?? (json['category'] != null ? json['category']['id'] as String : throw Exception('Missing categoryId')),
      category: json['category'] != null ? SimpleCategory.fromJson(json['category']) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id, title, description, price, currency, images, stockQuantity,
        materials, dimensions, sku, shippingDetails, status, artisanId, artisan,
        categoryId, category, createdAt, updatedAt
      ];
}