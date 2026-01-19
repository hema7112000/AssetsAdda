import 'package:json_annotation/json_annotation.dart';

// lib/data/models/property_model.dart

enum PropertyType { apartment, villa, commercial, land, house }
enum ListingPurpose { sale, rent }
enum PropertyStatus { pending, approved, rejected }

class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final String address;
  final String pinCode;
  final double area; // in sqft or sqm
  final List<String> imageUrls;
  final String? videoUrl;
  final List<String> documentUrls;
  final double? latitude;
  final double? longitude;
  final String sellerId;
  final PropertyType type;
  final ListingPurpose purpose;
  final PropertyStatus status;
  final DateTime createdAt;
  final Set<String> amenities;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.address,
    required this.pinCode,
    required this.area,
    required this.imageUrls,
    this.videoUrl,
    required this.documentUrls,
    this.latitude,
    this.longitude,
    required this.sellerId,
    required this.type,
    required this.purpose,
    required this.amenities, 
    this.status = PropertyStatus.pending, // Default status
  }) : createdAt = DateTime.now(); // Set creation time on instantiation

Property copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? address,
    String? pinCode,
    String? sellerId,
    double? area,
    PropertyType? type,
    ListingPurpose? purpose,
    Set<String>? amenities,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    List<String>? documentUrls,
    String? videoUrl,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      address: address ?? this.address,
       sellerId: sellerId ?? this.sellerId,
      pinCode: pinCode ?? this.pinCode,
      area: area ?? this.area,
      type: type ?? this.type,
      purpose: purpose ?? this.purpose,
      amenities: amenities ?? this.amenities,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      documentUrls: documentUrls ?? this.documentUrls,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
  // A factory constructor to create a Property from a map (e.g., from Firestore)
  factory Property.fromMap(Map<String, dynamic> map, String id) {
    return Property(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      address: map['address'] ?? '',
      pinCode: map['pinCode'] ?? '',
      area: (map['area'] ?? 0).toDouble(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      videoUrl: map['videoUrl'],
      documentUrls: List<String>.from(map['documentUrls'] ?? []),
      latitude: (map['latitude'])?.toDouble(),
      longitude: (map['longitude'])?.toDouble(),
      sellerId: map['sellerId'] ?? '',
      amenities: Set<String>.from(map['amenities'] ?? []),
      type: PropertyType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PropertyType.apartment,
      ),
      purpose: ListingPurpose.values.firstWhere(
        (e) => e.name == map['purpose'],
        orElse: () => ListingPurpose.sale,
      ),
      status: PropertyStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PropertyStatus.pending,
      ),
    );
  }
factory Property.fromJson(Map<String, dynamic> json) {
  return Property(
    id: json['id']?.toString() ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    address: json['address'] ?? '',
    pinCode: json['pinCode'] ?? '',
    area: (json['area'] ?? 0).toDouble(),
    imageUrls: List<String>.from(json['imageUrls'] ?? []),
    videoUrl: json['videoUrl'],
    documentUrls: List<String>.from(json['documentUrls'] ?? []),
    latitude: json['latitude']?.toDouble(),
    longitude: json['longitude']?.toDouble(),
    sellerId: json['sellerId']?.toString() ?? '',
    amenities: Set<String>.from(json['amenities'] ?? []),
    type: PropertyType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => PropertyType.apartment,
    ),
    purpose: ListingPurpose.values.firstWhere(
      (e) => e.name == json['purpose'],
      orElse: () => ListingPurpose.sale,
    ),
    status: PropertyStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => PropertyStatus.pending,
    ),
  );
}

  // A method to convert a Property to a map (e.g., for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'address': address,
      'pinCode': pinCode,
      'area': area,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'documentUrls': documentUrls,
      'latitude': latitude,
      'longitude': longitude,
      'sellerId': sellerId,
      'type': type.name,
      'purpose': purpose.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'amenities': amenities.toList(),
    };
  }
}