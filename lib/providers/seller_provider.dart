// lib/providers/seller_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_estate_360/data/models/property_model.dart';
import 'package:real_estate_360/data/services/api_service.dart'; // We'll expand this later
import 'package:real_estate_360/providers/auth_provider.dart';

class SellerNotifier extends StateNotifier<AsyncValue<List<Property>>> {
  final ApiService _apiService;
  final String? _currentUserId;

  SellerNotifier(this._apiService, this._currentUserId) : super(const AsyncValue.loading()) {
    if (_currentUserId != null) {
      fetchSellerProperties();
    }
  }

  // In lib/providers/seller_provider.dart

Future<void> fetchSellerProperties() async {
  if (_currentUserId == null) return;
  state = const AsyncValue.loading();
  try {
    final allProperties = await _apiService.fetchProperties();
    var sellerProperties = allProperties.where((p) => p.sellerId == _currentUserId).toList();
    
    // --- ADD THIS LOGIC ---
    if (sellerProperties.isEmpty) {
      // If the seller has no properties, add 1-2 default examples for them to see
      sellerProperties = allProperties.take(2).toList(); 
    }
    
    state = AsyncValue.data(sellerProperties);
  } catch (e, stack) {
    state = AsyncValue.error(e, stack);
  }
}
  
  // Placeholder for adding a property
  Future<void> addProperty(Property property) async {
    // In a real app, you'd make an API call here
    // await _apiService.addProperty(property);
    // Then, refresh the list
    await fetchSellerProperties();
  }
  Future<void> updateProperty(Property updatedProperty) async {
    final currentList = state.value ?? [];
    final updatedList = currentList.map((property) {
      return property.id == updatedProperty.id ? updatedProperty : property;
    }).toList();
    state = AsyncValue.data(updatedList);
  }

  // Placeholder for deleting a property
  Future<void> deleteProperty(String propertyId) async {
    // In a real app: await _apiService.deleteProperty(propertyId);
    final currentList = state.value ?? [];
    state = AsyncValue.data(currentList.where((p) => p.id != propertyId).toList());
  }
}

// We need the current user's ID to fetch their properties.
// Assuming you have a currentUserProvider that gives a user object with an 'id' field.
final sellerProvider = StateNotifierProvider<SellerNotifier, AsyncValue<List<Property>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  // This assumes you have a way to get the current user.
  // Replace with your actual auth state management.
  final user = ref.watch(currentUserProvider); 
return SellerNotifier(apiService, user?.id?.toString());
});