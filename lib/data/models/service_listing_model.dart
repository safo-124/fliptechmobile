// lib/data/models/service_listing_model.dart
import 'package:equatable/equatable.dart';
import 'product_listing_model.dart'; // For SimpleArtisan, SimpleCategory if reusing

// Enums should match those in your Prisma schema and backend API
enum ServicePriceTypeEnum { FIXED, PER_HOUR, PER_DAY, CONTACT_FOR_QUOTE, PROJECT_BASED }
enum ServiceLocationTypeEnum { ON_SITE, ARTISAN_LOCATION, REMOTE_ONLINE }

String servicePriceTypeEnumToString(ServicePriceTypeEnum type) => type.toString().split('.').last;
ServicePriceTypeEnum servicePriceTypeEnumFromString(String? typeString) {
  if (typeString == null) return ServicePriceTypeEnum.CONTACT_FOR_QUOTE;
  return ServicePriceTypeEnum.values.firstWhere(
    (e) => e.toString().split('.').last == typeString.toUpperCase(),
    orElse: () => ServicePriceTypeEnum.CONTACT_FOR_QUOTE,
  );
}
// Similar helpers for ServiceLocationTypeEnum

class ServiceListing extends Equatable {
  final String? id; // Nullable if creating a new one
  final String title;
  final String description;
  final ServicePriceTypeEnum priceType;
  final double? price;
  final String? priceUnit;
  final String currency;
  final List<String> images; // URLs
  final ServiceLocationTypeEnum locationType;
  final String? serviceArea;
  final String? typicalDuration;
  final String status;
  final String artisanId;
  final SimpleArtisan? artisan;
  final String categoryId;
  final SimpleCategory? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ServiceListing({
    this.id,
    required this.title,
    required this.description,
    required this.priceType,
    this.price,
    this.priceUnit,
    this.currency = 'GHS',
    required this.images,
    required this.locationType,
    this.serviceArea,
    this.typicalDuration,
    required this.status,
    required this.artisanId,
    this.artisan,
    required this.categoryId,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceListing.fromJson(Map<String, dynamic> json) {
    return ServiceListing(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      priceType: servicePriceTypeEnumFromString(json['priceType'] as String?),
      price: (json['price'] as num?)?.toDouble(),
      priceUnit: json['priceUnit'] as String?,
      currency: json['currency'] as String? ?? 'GHS',
      images: List<String>.from((json['images'] as List<dynamic>?)?.map((e) => e.toString()) ?? []),
      locationType: ServiceLocationTypeEnum.values.firstWhere(
        (e) => e.toString().split('.').last == (json['locationType'] as String?)?.toUpperCase(),
        orElse: () => ServiceLocationTypeEnum.ARTISAN_LOCATION
      ),
      serviceArea: json['serviceArea'] as String?,
      typicalDuration: json['typicalDuration'] as String?,
      status: json['status'] as String,
      artisanId: json['artisanId'] as String? ?? (json['artisan'] != null ? json['artisan']['id'] as String : throw Exception('Missing artisanId')),
      artisan: json['artisan'] != null ? SimpleArtisan.fromJson(json['artisan']) : null,
      categoryId: json['categoryId'] as String? ?? (json['category'] != null ? json['category']['id'] as String : throw Exception('Missing categoryId')),
      category: json['category'] != null ? SimpleCategory.fromJson(json['category']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJsonForCreate() { // For sending to API
    return {
      'title': title,
      'description': description,
      'priceType': servicePriceTypeEnumToString(priceType),
      'price': price,
      'priceUnit': priceUnit,
      'currency': currency,
      'images': images,
      'locationType': locationType.toString().split('.').last,
      'serviceArea': serviceArea,
      'typicalDuration': typicalDuration,
      'categoryId': categoryId,
      'status': status, // Backend will set to PENDING_APPROVAL if artisan creates
      // 'artisanId': artisanId, // Backend should get this from auth token
    };
  }

  @override
  List<Object?> get props => [
    id, title, description, priceType, price, priceUnit, currency, images,
    locationType, serviceArea, typicalDuration, status, artisanId, categoryId,
    createdAt, updatedAt
  ];
}