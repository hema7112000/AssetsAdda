// lib/providers/favorites_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_estate_360/data/models/property_model.dart';

class FavoritesNotifier extends StateNotifier<List<Property>> {
  FavoritesNotifier() : super([]);

  void toggleFavorite(Property property) {
    if (state.contains(property)) {
      state = state.where((p) => p.id != property.id).toList();
    } else {
      state = [...state, property];
    }
  }

  bool isFavorite(String propertyId) {
    return state.any((property) => property.id == propertyId);
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Property>>(
  (ref) => FavoritesNotifier(),
);