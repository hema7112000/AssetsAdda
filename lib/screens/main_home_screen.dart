// lib/screens/home_screen.dart
import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_360/data/models/property_model.dart';
import 'package:real_estate_360/providers/property_provider.dart';
import 'package:real_estate_360/providers/auth_provider.dart';
import 'package:real_estate_360/providers/theme_provider.dart';
import 'package:real_estate_360/core/theme/app_theme2.dart';
import 'package:real_estate_360/widgets/common/property_card.dart';
import 'package:real_estate_360/widgets/common/app_scaffold.dart';
import 'package:real_estate_360/widgets/auth/login_modal.dart';
import 'package:real_estate_360/widgets/common/theme_toggle.dart';
import 'package:real_estate_360/data/models/user_model.dart';

class MainHomeScreen extends ConsumerStatefulWidget {
  const MainHomeScreen({super.key});

  @override
  ConsumerState<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends ConsumerState<MainHomeScreen> {
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

  void _showLoginModal(String redirectTo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => LoginModal(redirectTo: redirectTo),
    );
  }

 
 void _handleActionRequiringLogin(String destinationPath) {
      final User? currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        print('User is logged in. Navigating to $destinationPath');
        context.go(destinationPath);
      } else {
        print('User is not logged in. Showing login modal.');
        _showLoginModal(destinationPath);
      }
    }
  @override
  Widget build(BuildContext context) {
    final propertyState = ref.watch(propertiesListProvider);
    final properties = propertyState.filteredProperties;
    final themeMode = ref.watch(themeProvider); // Watch theme changes

    return AppScaffold(
      title: 'Discover Properties',
      actions: [
        const ThemeToggle(),
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () => _handleActionRequiringLogin('/profile'),
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
                // 1. Glass Search Bar
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
                        ref
                            .read(propertiesListProvider.notifier)
                            .updateSearchQuery(query);
                      },
                      style: TextStyle(color: AppTheme.textColor),
                      decoration: InputDecoration(
                        hintText: 'Search by city, location...',
                        hintStyle: TextStyle(color: AppTheme.hintTextColor),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search, color: AppTheme.textColor),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Glass Filter Chips
                _buildFilterChips(propertyState.currentFilter),

                // 3. Glass Banner Carousel
                _buildBannerCarousel(properties),

                // 4. Glass Most Viewed Properties
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textColor,
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
                            onTitleTap: () =>
                                context.push('/property/${property.id}'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleActionRequiringLogin('/seller/add-property'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Property'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

Widget _buildFilterChips(PropertyFilter currentFilter) {
  return Stack(
    children: [
      // Background image with overlay
      Container(
        height: 360,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/analog-landscape-city-with-buildings.jpg'), // Add your hero image
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              AppTheme.isDarkMode 
                ? Colors.black.withOpacity(0.65) 
                : Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
      ),
      
      // Gradient overlay for better text visibility
      Container(
        height: 320,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppTheme.isDarkMode
              ? [
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ]
              : [
                  Colors.transparent,
                  Colors.black.withOpacity(0.2),
                ],
          ),
        ),
      ),
      
      // Content
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find Your Dream Property',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse by Property Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
            ),
            const SizedBox(height: 24),
            
            // Enhanced filter chips with glass morphism
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
    ],
  );
}

Widget _buildFilterChip(PropertyFilter filter, bool isSelected) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    child: GestureDetector(
      onTap: () {
        ref.read(propertiesListProvider.notifier).updateFilter(filter);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.9),
                    AppTheme.secondaryColor.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.6)
                : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.4)
                  : Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
           
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.2),
                          AppTheme.secondaryColor.withOpacity(0.2),
                        ],
                      ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _getFilterIcon(filter),
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filter.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 20,
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
                          // 🏙 Background image with blur effect
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
                                  color: Colors.grey[300],
                                  child: const Center(child: Icon(Icons.image)),
                                ),
                              ),
                            ),
                          ),

                          // Glass Overlay with gradient
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: AppTheme.isDarkMode
                                      ? [
                                          Colors.black.withOpacity(0.7),
                                          Colors.black.withOpacity(0.5),
                                        ]
                                      : [
                                          Colors.white.withOpacity(0.6),
                                          Colors.white.withOpacity(0.3),
                                        ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),

                          // Primary gradient overlay
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                              ),
                            ),
                          ),

                          // Bottom overlay for text readability
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                    Colors.black.withOpacity(0.6),
                                  ],
                                  stops: const [0.5, 0.8, 1.0],
                                ),
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
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 20,
                  color: AppTheme.textColor,
                ),
          ),
        ),
        ...mostViewedProperties.map((property) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: GestureDetector(
              onTap: () => context.push('/property/${property.id}'),
              child: Container(
                decoration: AppTheme.glassDecoration.copyWith(
                  gradient: AppTheme.cardGradient,
                ),
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
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: double.infinity,
                              height: 180,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                              ),
                              child: const Center(
                                  child: Icon(Icons.image, color: Colors.white)),
                            ),
                          ),
                        ),
                        // Glass overlay on image
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.4),
                              ],
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
                          child: GestureDetector(
                            onTap: () => _handleActionRequiringLogin('/favorites'),
                            child: Container(
                              padding: const EdgeInsets.all(6),
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
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Content with glass effect
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