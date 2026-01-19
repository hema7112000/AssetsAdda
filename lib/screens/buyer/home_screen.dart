// lib/screens/buyer/home_screen.dart
import 'package:flutter/material.dart';
import 'dart:ui'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_360/data/models/property_model.dart';
import 'package:real_estate_360/data/models/user_model.dart';
import 'package:real_estate_360/providers/auth_provider.dart';
import 'package:real_estate_360/providers/property_provider.dart';
import 'package:real_estate_360/core/theme/app_theme2.dart'; // Updated import
import 'package:real_estate_360/widgets/common/property_card.dart';
import 'package:real_estate_360/widgets/common/app_scaffold.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _bannerController = PageController();
  int _currentBanner = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(propertiesListProvider.notifier).fetchProperties();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _refreshProperties() async {
    await ref.read(propertiesListProvider.notifier).fetchProperties();
  }

  @override
  Widget build(BuildContext context) {
    final propertyState = ref.watch(propertiesListProvider);
    final properties = propertyState.filteredProperties;
    final user = ref.watch(currentUserProvider);
    print(user?.role.name);

     if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found. Please log in.')),
      );
    }

    final bool isSeller = user.role == UserRole.ROLE_SELLER;

    return AppScaffold(
      title: 'Discover Properties',
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () => context.push('/profile'),
        ),
      ],
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.glassBackgroundGradient,
        ),
        child: RefreshIndicator(
          onRefresh: _refreshProperties,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Search Bar with Glass Effect
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: AppTheme.glassDecoration.copyWith(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _searchController,
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: (query) {
                        ref.read(propertiesListProvider.notifier).updateSearchQuery(query);
                      },
                      style: TextStyle(color: AppTheme.textColor),
                      decoration: InputDecoration(
                        hintText: 'Search by city, location...',
                        hintStyle: TextStyle(color: AppTheme.hintTextColor),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search, color: AppTheme.textColor),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Filter Chips with Glass Effect
                _buildFilterChips(propertyState.currentFilter),

                // 3. Banner Carousel
                _buildBannerCarousel(properties),

                // 4. Most Viewed Properties
                if (properties.isNotEmpty) _buildMostViewedProperties(properties),

                // 5. All Properties Grid with Glass Cards
                if (propertyState.isLoading)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Container(
                        decoration: AppTheme.glassDecoration,
                        padding: const EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  )
                else if (properties.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Container(
                        decoration: AppTheme.glassDecoration,
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No properties found.',
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MasonryGridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      itemCount: properties.length,
                      itemBuilder: (context, index) {
                        final property = properties[index];
                        return Container(
                          decoration: AppTheme.glassDecoration.copyWith(
                            gradient: AppTheme.cardGradient,
                          ),
                          child: PropertyCard(
                            property: property,
                            onTitleTap: () => context.push('/property/${property.id}'),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),

     floatingActionButton: FloatingActionButton(
  onPressed: () {
    if (!isSeller) {
      context.push('/seller/add-property');
    } else {
      context.push('/profile');
    }
  },
  backgroundColor: AppTheme.secondaryColor,
  foregroundColor: Colors.white,
  child: Icon(
    isSeller ? Icons.add_home_work : Icons.home,
  ),
),
   
    );
  }

  Widget _buildFilterChips(PropertyFilter currentFilter) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Container(
        decoration: AppTheme.glassDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Browse by Property Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),          
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: PropertyFilter.values.map((filter) {
                return _buildFilterChip(filter, currentFilter == filter);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(PropertyFilter filter, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(propertiesListProvider.notifier).updateFilter(filter);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor 
              : AppTheme.surfaceColor, // FIXED: Changed from AppTheme.lightColor to AppTheme.surfaceColor
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.2) 
                    : AppTheme.primaryColor.withOpacity(0.1), // FIXED
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getFilterIcon(filter),
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filter.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textColor, // FIXED: Changed from AppTheme.darkColor to AppTheme.textColor
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFilterIcon(PropertyFilter filter) {
    switch (filter) {
      case PropertyFilter.other:
        return Icons.apps;
      case PropertyFilter.house:
        return Icons.home;
      case PropertyFilter.apartment:
        return Icons.apartment;
      case PropertyFilter.villa:
        return Icons.villa;
      case PropertyFilter.commercial:
        return Icons.store;
      default:
        return Icons.location_city;
    }
  }

  Widget _buildBannerCarousel(List<Property> properties) {
    final featuredProperties = properties.take(5).toList();

    if (featuredProperties.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Featured Properties',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: Stack(
            children: [
              // ---- PageView with Glass Effect ----
              PageView.builder(
                controller: _bannerController,
                onPageChanged: (index) {
                  setState(() {
                    _currentBanner = index;
                  });
                },
                itemCount: featuredProperties.length,
                itemBuilder: (context, index) {
                  final property = featuredProperties[index];
                  return GestureDetector(
                    onTap: () => context.push('/property/${property.id}'),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 🏙 Background image with blur
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                              child: Image.asset(
                                property.imageUrls.isNotEmpty
                                    ? property.imageUrls.first
                                    : 'assets/images/analog-landscape-city-with-buildings.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                  ),
                                  child: const Center(child: Icon(Icons.image, color: Colors.white)),
                                ),
                              ),
                            ),
                          ),

                          // Glass Overlay
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                              ),
                            ),
                          ),

                          // 📝 Text Content
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  property.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${property.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // ⚪ Glass Dots Indicator
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      featuredProperties.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: _currentBanner == index ? 20 : 6,
                        decoration: BoxDecoration(
                          gradient: _currentBanner == index
                              ? LinearGradient(
                                  colors: [
                                    AppTheme.secondaryColor,
                                    AppTheme.primaryColor,
                                  ],
                                )
                              : null,
                          color: _currentBanner == index
                              ? null
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMostViewedProperties(List<Property> properties) {
    final mostViewedProperties = properties.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
          child: Text(
            'Most Viewed Properties',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
        ),
        ...mostViewedProperties.map((property) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: GestureDetector(
              onTap: () => context.push('/property/${property.id}'),
              child: Container(
                decoration: AppTheme.glassDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with glass overlay
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Image.asset(
                            property.imageUrls.isNotEmpty 
                              ? property.imageUrls.first 
                              : 'assets/images/placeholder.png',
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: double.infinity,
                              height: 180,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                              ),
                              child: const Center(child: Icon(Icons.image, color: Colors.white)),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              property.type.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: AppTheme.cardGradient,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Icon(
                              Icons.favorite_border,
                              color: AppTheme.secondaryColor,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Content below the image
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.textColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            property.address,
                            style: TextStyle(
                              color: AppTheme.hintTextColor,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.square_foot,
                                size: 16,
                                color: AppTheme.hintTextColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${property.area.toStringAsFixed(0)} sqft',
                                style: TextStyle(
                                  color: AppTheme.hintTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '\$${property.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}