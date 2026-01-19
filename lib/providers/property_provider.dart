// lib/providers/property_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_estate_360/data/models/property_model.dart';
import 'package:real_estate_360/data/services/api_service.dart';

// Enum for our filter options
enum PropertyFilter { forSale, forRent, apartment, villa, house, commercial, other }

// --- 1. The State Class ---
// This class holds all the data our UI needs.
class PropertyState {
  final List<Property> allProperties;
  final List<Property> filteredProperties;
  final PropertyFilter currentFilter;
  final String searchQuery;
  final bool isLoading;

  PropertyState({
    required this.allProperties,
    required this.filteredProperties,
    this.currentFilter = PropertyFilter.forSale,
    this.searchQuery = '',
    this.isLoading = false,
  });

  // A helper method to create a new state with some updated values
  PropertyState copyWith({
    List<Property>? allProperties,
    List<Property>? filteredProperties,
    PropertyFilter? currentFilter,
    String? searchQuery,
    bool? isLoading,
  }) {
    return PropertyState(
      allProperties: allProperties ?? this.allProperties,
      filteredProperties: filteredProperties ?? this.filteredProperties,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// --- 2. The Notifier Class ---
// This is the "brain" that contains the logic to change the state.
class PropertyNotifier extends StateNotifier<PropertyState> {
  final ApiService _apiService;

  PropertyNotifier(this._apiService) : super(PropertyState(allProperties: [], filteredProperties: []));

  // Method to fetch all properties from the API
  Future<void> fetchProperties() async {
    state = state.copyWith(isLoading: true);
    try {
      final properties = await _apiService.fetchProperties();
      state = state.copyWith(
        allProperties: properties,
        filteredProperties: properties, // Initially, filtered list is the same as the full list
        isLoading: false,
      );
      // Apply any default filters after fetching
      _applyFilters();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // You could add an error message to the state here if you want
    }
  }

  // Method to update the search query
  void updateSearchQuery(String query) {
    if (state.searchQuery != query) {
      state = state.copyWith(searchQuery: query);
      _applyFilters();
    }
  }

  // Method to update the active filter
  void updateFilter(PropertyFilter filter) {
    if (state.currentFilter != filter) {
      state = state.copyWith(currentFilter: filter);
      _applyFilters();
    }
  }

  // The core logic for filtering
  void _applyFilters() {
    var tempList = state.allProperties;

    // 1. Apply search query filter
    if (state.searchQuery.isNotEmpty) {
      tempList = tempList.where((property) {
        return property.title.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
            property.address.toLowerCase().contains(state.searchQuery.toLowerCase());
      }).toList();
    }

    // 2. Apply category filter
    switch (state.currentFilter) {
      case PropertyFilter.forSale:
        tempList = tempList.where((p) => p.purpose == ListingPurpose.sale).toList();
        break;
      case PropertyFilter.forRent:
        tempList = tempList.where((p) => p.purpose == ListingPurpose.rent).toList();
        break;
      case PropertyFilter.apartment:
        tempList = tempList.where((p) => p.type == PropertyType.apartment).toList();
        break;
      case PropertyFilter.villa:
        tempList = tempList.where((p) => p.type == PropertyType.villa).toList();
        break;
      case PropertyFilter.house:
        tempList = tempList.where((p) => p.type == PropertyType.house).toList();
        break;
      case PropertyFilter.commercial:
        tempList = tempList.where((p) => p.type == PropertyType.commercial).toList();
        break;
      case PropertyFilter.other:
      // No filter applied
        break;
    }
    
    // 3. Update the state with the newly filtered list
    state = state.copyWith(filteredProperties: tempList);
  }
}

// --- 3. The Providers ---

// The provider for the list of properties. This is what the HomeScreen will watch.
final propertiesListProvider = StateNotifierProvider<PropertyNotifier, PropertyState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PropertyNotifier(apiService);
});

// The provider for a single property. This remains the same and is used on the detail screen.
final propertyDetailProvider = FutureProvider.family<Property, String>((ref, id) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.fetchPropertyById(id);
});