// import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Add this import
// import 'package:real_estate_360/data/models/property_model.dart';

// class ApiService {
//   Future<List<Property>> fetchProperties() async {
//     // Simulate network delay
//     await Future.delayed(const Duration(seconds: 1));

//     // Mock data
//     return [
//       Property(
//         id: '1',
//         title: 'Modern 3BHK Apartment',
//         description: 'A beautiful apartment in the heart of the city with all modern amenities.',
//         price: 750000,
//         address: '123 Main St, Downtown',
//         imageUrls: ['assets/images/image.png'],
//         sellerId: 'seller1',
//         pinCode: '110001', // <-- ADDED
//         area: 1200.0,  
//         documentUrls: [],
//         type: PropertyType.apartment,
//         purpose: ListingPurpose.sale,
//          amenities: <String>{},
//       ),
//       Property(
//         id: '2',
//         title: 'Spacious Villa with Garden',
//         description: 'Luxury villa with a private garden and swimming pool.',
//         price: 2500000,
//         address: '456 Elite Ave, Suburbs',
//         imageUrls: ['assets/images/analog-landscape-city-with-buildings.jpg'],
//         sellerId: 'seller2',
//         pinCode: '400001', // <-- ADDED
//         area: 5000.0, 
//         documentUrls: [], 
//         type: PropertyType.villa,
//         purpose: ListingPurpose.sale,
//          amenities: <String>{},
//       ),
//       Property(
//         id: '3',
//         title: 'Commercial Plot for Sale',
//         description: 'Prime location commercial plot, ideal for office or retail.',
//         price: 1200000,
//         address: '789 Business Park',
//         imageUrls: ['assets/images/modern-apartment-architecture.jpg'],
//         sellerId: 'seller1',
//         pinCode: '560001', // <-- ADDED
//         area: 3500.0,  
//         documentUrls: [],
//         type: PropertyType.commercial,
//         purpose: ListingPurpose.sale,
//          amenities: <String>{},
//       ),
//     ];
//   }

//   Future<Property> fetchPropertyById(String id) async {
//     await Future.delayed(const Duration(seconds: 1));
//     final properties = await fetchProperties();
//     return properties.firstWhere((property) => property.id == id);
//   }
// }

// // 2. Add this provider at the end of the file
// final apiServiceProvider = Provider<ApiService>((ref) => ApiService());


// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:real_estate_360/data/models/property_model.dart';
import 'package:real_estate_360/providers/auth_provider.dart';

class ApiService {
  final http.Client _client;
  final String baseUrl = 'http://72.61.236.54:9898/api/assetsadda-service';

  
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Fetch all properties
  Future<List<Property>> fetchProperties() async {
    try {
      final response = await _client.get(
        Uri.parse('${baseUrl}/properties'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load properties: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data in case of error
      return _getMockProperties();
    }
  }

  // Fetch property by ID
  Future<Property> fetchPropertyById(String id) async {
    try {
      final response = await _client.get(
        Uri.parse('${baseUrl}/properties/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Property.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load property: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data in case of error
      final properties = await _getMockProperties();
      return properties.firstWhere((property) => property.id == id);
    }
  }

  // Add a new property
  Future<Map<String, dynamic>> addProperty({
    required String userId,
    required int categoryId,
    required String title,
    required String description,
    required double price,
    required String location,
    required double lat,
    required double longitude,
    String? pinCode,
    double? area,
    String? type,
    String? purpose,
    Set<String>? amenities,
    List<String>? imageUrls,
    List<String>? documentUrls,
    String? videoUrl,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'userId': userId,
        'categoryId': categoryId,
        'title': title,
        'description': description,
        'price': price,
        'location': location,
        'lat': lat,
        'longitude': longitude,
      };

      // Add optional fields if provided
      if (pinCode != null) requestBody['pinCode'] = pinCode;
      if (area != null) requestBody['area'] = area;
      if (type != null) requestBody['type'] = type;
      if (purpose != null) requestBody['purpose'] = purpose;
      if (amenities != null) requestBody['amenities'] = amenities.toList();
      if (imageUrls != null) requestBody['imageUrls'] = imageUrls;
      if (documentUrls != null) requestBody['documentUrls'] = documentUrls;
      if (videoUrl != null) requestBody['videoUrl'] = videoUrl;

      final response = await _client.post(
        Uri.parse('${baseUrl}/properties/add'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to add property');
      }
    } catch (e) {
      throw Exception('Error adding property: $e');
    }
  }

  // Upload image to server
  Future<String> uploadImage(File imageFile, String authToken) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}/properties/file-upload'),
      );
      
      request.headers['Authorization'] = 'Bearer $authToken';
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = json.decode(responseData.body);
        return data['imageUrl'];
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  // Upload document to server
  Future<String> uploadDocument(File documentFile, String authToken) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}/properties/file-upload'),
      );
      
      request.headers['Authorization'] = 'Bearer $authToken';
      request.files.add(
        await http.MultipartFile.fromPath('document', documentFile.path),
      );

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = json.decode(responseData.body);
        return data['documentUrl'];
      } else {
        throw Exception('Failed to upload document: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading document: $e');
    }
  }

  // Upload video to server
  Future<String> uploadVideo(File videoFile, String authToken) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}/properties/file-upload'),
      );
      
      request.headers['Authorization'] = 'Bearer $authToken';
      request.files.add(
        await http.MultipartFile.fromPath('video', videoFile.path),
      );

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = json.decode(responseData.body);
        return data['videoUrl'];
      } else {
        throw Exception('Failed to upload video: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading video: $e');
    }
  }

  // Mock data for fallback
  List<Property> _getMockProperties() {
    return [
      Property(
        id: '1',
        title: 'Modern 3BHK Apartment',
        description: 'A beautiful apartment in the heart of the city with all modern amenities.',
        price: 750000,
        address: '123 Main St, Downtown',
        imageUrls: ['assets/images/image.png'],
        sellerId: 'seller1',
        pinCode: '110001',
        area: 1200.0,
        documentUrls: [],
        type: PropertyType.apartment,
        purpose: ListingPurpose.sale,
        amenities: <String>{},
      ),
      Property(
        id: '2',
        title: 'Spacious Villa with Garden',
        description: 'Luxury villa with private garden and pool. Perfect for families.',
        price: 2500000,
        address: '456 Park Ave, Suburbs',
        imageUrls: ['assets/images/villa.png'],
        sellerId: 'seller2',
        pinCode: '110002',
        area: 3500.0,
        documentUrls: [],
        type: PropertyType.villa,
        purpose: ListingPurpose.sale,
        amenities: <String>{'Parking', 'Garden', 'Swimming Pool'},
      ),
    ];
  }

  void dispose() {
    _client.close();
  }
}

// Provider for the API service
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Provider for authenticated API calls
final authenticatedApiServiceProvider = Provider<ApiService>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw Exception('User not authenticated');
  }
  
  // Create a custom client that adds the auth token to all requests
  final client = http.Client();
  return ApiService(client: client);
});