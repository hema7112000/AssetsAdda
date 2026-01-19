// lib/screens/buyer/property_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_360/data/models/property_model.dart';
import 'package:real_estate_360/providers/property_provider.dart';
import 'package:real_estate_360/core/theme/app_theme2.dart'; // Using app_theme2 as requested
import 'package:real_estate_360/widgets/common/app_scaffold.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  ConsumerState<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsyncValue = ref.watch(propertyDetailProvider(widget.propertyId));

    // This structure is correct. The main Scaffold is here, and the UI with data is built inside.
    return Scaffold(
      body: propertyAsyncValue.when(
        data: (property) => _buildContent(context, property),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Property property) {
    // Mock seller data (in a real app, this would come from the property model or API)
    final seller = {
      'name': 'John Doe',
      'phone': '+1234567890',
      'email': 'john.doe@example.com',
      'postedDate': 'May 15, 2023',
    };

    // Mock amenities (in a real app, this would come from the property model or API)
    final amenities = [
      'Parking', 'Gym', 'Swimming Pool', 'Security', 'Garden', 'Elevator',
      'Power Backup', 'Water Supply', 'Club House', 'Play Area', 'Jogging Track'
    ];

    // The AppScaffold is correctly placed here, where 'property' is available.
    return AppScaffold(
      title: (property.title),
      actions: [
        IconButton(
          onPressed: () {
            _shareProperty(context, property);
          },
          icon: const Icon(Icons.share),
          tooltip: 'Share Property',
        ),
      ],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery Card
            Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: property.imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                property.imageUrls[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: AppTheme.cardGradient,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: property.imageUrls.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () => _pageController.animateToPage(
                              entry.key,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                            child: Container(
                              width: 12.0,
                              height: 12.0,
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(_currentImageIndex == entry.key ? 0.9 : 0.4),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Property Details Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${property.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      property.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.isDarkMode ? Colors.white : Colors.black87, // FIX: Explicitly set text color
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${property.address}, ${property.pinCode}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.isDarkMode ? Colors.white : Colors.black87, // FIX: Explicitly set text color
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.square_foot, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Area: ${property.area.toStringAsFixed(0)} sqft',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.isDarkMode ? Colors.white : Colors.black87, // FIX: Explicitly set text color
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.isDarkMode ? Colors.white : Colors.black87, // FIX: Explicitly set text color
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      property.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.isDarkMode ? Colors.white : Colors.black87, // FIX: Explicitly set text color
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Amenities Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amenities',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18,
                        color: AppTheme.isDarkMode ? Colors.white : Colors.black87, // FIX: Explicitly set text color
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: amenities.map((amenity) {
                        return Chip(
                          label: Text(
                            amenity,
                            style: TextStyle(color: AppTheme.isDarkMode ? Colors.white : Colors.black87), // FIX: Explicitly set text color
                          ),
                          backgroundColor: AppTheme.lightColor,
                          side: BorderSide(color: AppTheme.primaryColor),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Contact Seller Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Seller',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18,
                        color: AppTheme.isDarkMode ? Colors.white : Colors.black87, // FIX: Explicitly set text color
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.person, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          seller['name']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.isDarkMode ? Colors.white : Colors.black87, // FIX: Explicitly set text color
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          seller['phone']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.isDarkMode ? Colors.white : Colors.black87, // FIX: Explicitly set text color
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.email, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          seller['email']!,
                          style: TextStyle(
                            color: AppTheme.isDarkMode ? Colors.white : Colors.black87, // FIX: Explicitly set text color
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Posted on: ${seller['postedDate']}',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.isDarkMode ? Colors.white : Colors.black87, // FIX: Explicitly set text color
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons with Icons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // First button: Filled with orange color
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Schedule a call action
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Schedule a Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor, // Orange color
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Second button: Border only
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Send email action
                      },
                      icon: const Icon(Icons.email),
                      label: const Text('Send Email'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryColor), // Border color
                        foregroundColor: AppTheme.primaryColor, // Text and icon color
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Third button: Border only
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Schedule a visit action
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Schedule a Visit'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryColor), // Border color
                        foregroundColor: AppTheme.primaryColor, // Text and icon color
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _shareProperty(BuildContext context, Property property) {
    // Create a shareable text with property details
    final String shareText = 
        'Check out this property: ${property.title}\n'
        'Price: \$${property.price.toStringAsFixed(0)}\n'
        'Address: ${property.address}, ${property.pinCode}\n'
        'Area: ${property.area.toStringAsFixed(0)} sqft\n'
        'Description: ${property.description}\n'
        'View more details in the Real Estate 360 app!';
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality would open the share dialog here'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}