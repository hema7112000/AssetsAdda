// lib/screens/seller/add_property_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:real_estate_360/data/models/property_model.dart';
import 'package:real_estate_360/data/services/api_service.dart';
import 'package:real_estate_360/providers/auth_provider.dart';
import 'package:real_estate_360/providers/seller_provider.dart';
import 'package:real_estate_360/core/theme/app_theme2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:real_estate_360/widgets/common/app_scaffold.dart';

class AddPropertyScreen extends ConsumerStatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  ConsumerState<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // Form Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _areaController = TextEditingController();

  // State variables
  PropertyType _selectedType = PropertyType.apartment;
  ListingPurpose _selectedPurpose = ListingPurpose.sale;
  int _selectedCategoryId = 1; // Default category ID
  List<File> _imageFiles = [];
  List<File> _documentFiles = [];
  File? _videoFile;
  double? _latitude;
  double? _longitude;
  final Set<String> _selectedAmenities = {}; // Start with an empty set

  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;

  // List of all possible amenities for the UI
  final List<String> _allAmenities = [
    'Parking', 'Power Backup', 'Gym', 'Swimming Pool', 'Security', 'Garden', 'Clubhouse'
  ];

  // List of property categories with IDs
  final List<Map<String, dynamic>> _propertyCategories = [
    {'id': 1, 'name': 'Apartment'},
    {'id': 2, 'name': 'House'},
    {'id': 3, 'name': 'Villa'},
    {'id': 4, 'name': 'Condo'},
    {'id': 5, 'name': 'Townhouse'},
    {'id': 6, 'name': 'Studio'},
    {'id': 7, 'name': 'Land'},
    {'id': 8, 'name': 'Commercial'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _pinCodeController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  // API call to add property
  Future<bool> _addPropertyToApi() async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        setState(() {
          _errorMessage = "User not authenticated. Please login again.";
        });
        return false;
      }

      final apiService = ref.read(apiServiceProvider);

      // Upload images and get URLs
      List<String> imageUrls = [];
      if (_imageFiles.isNotEmpty) {
        setState(() { _isUploading = true; });
        
        try {
          for (var image in _imageFiles) {
            final imageUrl = await apiService.uploadImage(image, user.token ?? '');
            imageUrls.add(imageUrl);
          }
        } catch (e) {
          setState(() { 
            _isUploading = false;
            _errorMessage = 'Failed to upload images: $e';
          });
          return false;
        }
        
        setState(() { _isUploading = false; });
      }

      // Upload documents and get URLs
      List<String> documentUrls = [];
      if (_documentFiles.isNotEmpty) {
        try {
          for (var document in _documentFiles) {
            final documentUrl = await apiService.uploadDocument(document, user.token ?? '');
            documentUrls.add(documentUrl);
          }
        } catch (e) {
          setState(() { 
            _errorMessage = 'Failed to upload documents: $e';
          });
          return false;
        }
      }

      // Upload video and get URL
      String? videoUrl;
      if (_videoFile != null) {
        try {
          videoUrl = await apiService.uploadVideo(_videoFile!, user.token ?? '');
        } catch (e) {
          setState(() { 
            _errorMessage = 'Failed to upload video: $e';
          });
          return false;
        }
      }

      // Add property to API
      try {
        final response = await apiService.addProperty(
          userId: user.id,
          categoryId: _selectedCategoryId,
          title: _titleController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          location: _addressController.text,
          lat: _latitude ?? 0.0,
          longitude: _longitude ?? 0.0,
          pinCode: _pinCodeController.text,
          area: double.parse(_areaController.text),
          type: _selectedType.name,
          purpose: _selectedPurpose.name,
          amenities: _selectedAmenities,
          imageUrls: imageUrls,
          documentUrls: documentUrls,
          videoUrl: videoUrl,
        );

        print(response);

        // Create a Property object with the response data
        final newProperty = Property(
          id: response['propertyId'].toString(),
          title: _titleController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          address: _addressController.text,
          pinCode: _pinCodeController.text,
          area: double.parse(_areaController.text),
          imageUrls: imageUrls,
          documentUrls: documentUrls,
          videoUrl: videoUrl,
          latitude: _latitude,
          longitude: _longitude,
          sellerId: user.id,
          type: _selectedType,
          purpose: _selectedPurpose,
          amenities: _selectedAmenities,
        );

        // Add to local state
        await ref.read(sellerProvider.notifier).addProperty(newProperty);
        
        return true;
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to add property: $e';
        });
        return false;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
      return false;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // if (_imageFiles.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: const Text('Please add at least one image.'),
    //       backgroundColor: AppTheme.secondaryColor,
    //     ),
    //   );
    //   return;
    // }

    // if (_latitude == null || _longitude == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: const Text('Please set the property location on the map.'),
    //       backgroundColor: AppTheme.secondaryColor,
    //     ),
    //   );
    //   return;
    // }

    setState(() { 
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await _addPropertyToApi();
    
    if (mounted) {
      if (success) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Property submitted successfully!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      } else {
        // Show error message if needed
        if (_errorMessage != null) {
          print(_errorMessage);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
    
    setState(() { _isLoading = false; });
  }

  // --- UI Building Methods ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold,
          color: AppTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildSectionSubtitle(String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.hintTextColor,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textColor,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(color: AppTheme.textColor),
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: TextStyle(color: AppTheme.hintTextColor),
              filled: true,
              fillColor: AppTheme.isDarkMode 
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.02),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.isDarkMode 
                      ? Colors.white.withOpacity(0.15)
                      : Colors.black.withOpacity(0.08),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.isDarkMode 
                      ? Colors.white.withOpacity(0.15)
                      : Colors.black.withOpacity(0.08),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: validator ?? (value) => 
              value == null || value.isEmpty ? 'Please enter $label' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Property Images'),
        _buildSectionSubtitle('Add at least one image of your property'),
        Container(
          height: 120,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._imageFiles.asMap().entries.map((entry) {
                  int index = entry.key;
                  File file = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.isDarkMode 
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.black.withOpacity(0.08),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.white),
                              onPressed: () => setState(() => _imageFiles.remove(file)),
                            ),
                          ),
                        ),
                        if (index == 0)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black54,
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: const Text(
                                'Main Image',
                                style: TextStyle(color: Colors.white, fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                GestureDetector(
                  onTap: () async {
                    final List<XFile>? images = await _picker.pickMultiImage();
                    if (images != null) {
                      setState(() {
                        _imageFiles.addAll(images.map((xFile) => File(xFile.path)));
                      });
                    }
                  },
                  child: Container(
                    width: 100, 
                    height: 100, 
                    decoration: BoxDecoration(
                      color: AppTheme.isDarkMode 
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.isDarkMode 
                            ? Colors.white.withOpacity(0.15)
                            : Colors.black.withOpacity(0.08),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate, 
                          size: 30,
                          color: AppTheme.hintTextColor,
                        ),
                        Text(
                          'Add Image', 
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.hintTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_imageFiles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Note: The first image will be used as the main image',
              style: TextStyle(
                fontSize: 12, 
                color: AppTheme.hintTextColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Property Video (Optional)'),
        _buildSectionSubtitle('Add a video tour of your property'),
        _videoFile != null
          ? Container(
              decoration: AppTheme.glassDecoration,
              child: ListTile(
                leading: Icon(Icons.videocam, color: AppTheme.primaryColor),
                title: Text(
                  _videoFile!.path.split('/').last,
                  style: TextStyle(color: AppTheme.textColor),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => _videoFile = null),
                ),
              ),
            )
          : OutlinedButton.icon(
              icon: Icon(Icons.videocam, color: AppTheme.primaryColor),
              label: Text(
                'Select Video',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
              onPressed: () async {
                final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
                if (video != null) {
                  setState(() {
                    _videoFile = File(video.path);
                  });
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildDocumentPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Documents'),
        _buildSectionSubtitle('Add ownership proof and other documents'),
        ..._documentFiles.map((file) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: AppTheme.glassDecoration,
          child: ListTile(
            leading: Icon(Icons.description, color: AppTheme.primaryColor),
            title: Text(
              file.path.split('/').last,
              style: TextStyle(color: AppTheme.textColor),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => setState(() => _documentFiles.remove(file)),
            ),
          ),
        )),
        OutlinedButton.icon(
          icon: Icon(Icons.attach_file, color: AppTheme.primaryColor),
          label: Text(
            'Add Document',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf', 'doc', 'docx'],
            );
            if (result != null) {
              setState(() {
                _documentFiles.addAll(result.paths.map((path) => File(path!)).toList());
              });
            }
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppTheme.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Amenities'),
        _buildSectionSubtitle('Select all amenities available'),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _allAmenities.map((amenity) {
            final isSelected = _selectedAmenities.contains(amenity);
            return FilterChip(
              label: Text(
                amenity,
                style: TextStyle(
                  color: isSelected 
                      ? Colors.white 
                      : AppTheme.textColor,
                ),
              ),
              selected: isSelected,
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    _selectedAmenities.add(amenity);
                  } else {
                    _selectedAmenities.remove(amenity);
                  }
                });
              },
              backgroundColor: AppTheme.isDarkMode 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              selectedColor: AppTheme.primaryColor,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : AppTheme.isDarkMode 
                          ? Colors.white.withOpacity(0.15)
                          : Colors.black.withOpacity(0.08),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildLocationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Location'),
        _buildSectionSubtitle('Set the exact location of your property'),
        _latitude != null && _longitude != null
          ? Container(
              decoration: AppTheme.glassDecoration,
              child: ListTile(
                leading: Icon(Icons.location_on, color: AppTheme.primaryColor),
                title: Text(
                  'Location Selected',
                  style: TextStyle(color: AppTheme.textColor),
                ),
                subtitle: Text(
                  'Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}',
                  style: TextStyle(color: AppTheme.hintTextColor),
                ),
                trailing: TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Change'),
                  onPressed: () => _navigateToLocationPicker(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ),
            )
          : OutlinedButton.icon(
              icon: Icon(Icons.map, color: AppTheme.primaryColor),
              label: Text(
                'Set Location on Map',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
              onPressed: _navigateToLocationPicker,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
      ],
    );
  }

  Future<void> _navigateToLocationPicker() async {
    // Navigate to the location picker screen and wait for a result
    final result = await context.push<LatLng>('/seller/add-property/location');
    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Post New Property',
      body: _isLoading || _isUploading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryColor),
                const SizedBox(height: 16),
                Text(
                  _isUploading ? 'Uploading files...' : 'Submitting property...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Basic Information Section
                  _buildSectionTitle('Basic Information'),
                  _buildTextField(_titleController, 'Property Title'),
                  _buildTextField(
                    _descriptionController, 
                    'Description', 
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      if (value.length < 20) {
                        return 'Description should be at least 20 characters';
                      }
                      return null;
                    },
                  ),
                  
                  // Property Details Section
                  _buildSectionTitle('Property Details'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          _priceController, 
                          'Price', 
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          _areaController, 
                          'Area (sqft)', 
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter area';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  // Property Category Dropdown
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Property Category',
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.isDarkMode 
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.black.withOpacity(0.08),
                            ),
                          ),
                          child: DropdownButtonFormField<int>(
                            value: _selectedCategoryId,
                            decoration: InputDecoration(
                              hintText: 'Select Category',
                              hintStyle: TextStyle(color: AppTheme.hintTextColor),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            dropdownColor: AppTheme.surfaceColor,
                            style: TextStyle(color: AppTheme.textColor),
                            onChanged: (value) => setState(() => _selectedCategoryId = value!),
                            items: _propertyCategories.map<DropdownMenuItem<int>>(
                            (category) => DropdownMenuItem<int>(
                              value: category['id'] as int,
                              child: Text(category['name'].toString()),
                            ),
                          ).toList(),

                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Property Type Dropdown
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Property Type',
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.isDarkMode 
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.black.withOpacity(0.08),
                            ),
                          ),
                          child: DropdownButtonFormField<PropertyType>(
                            value: _selectedType,
                            decoration: InputDecoration(
                              hintText: 'Select Type',
                              hintStyle: TextStyle(color: AppTheme.hintTextColor),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            dropdownColor: AppTheme.surfaceColor,
                            style: TextStyle(color: AppTheme.textColor),
                            onChanged: (value) => setState(() => _selectedType = value!),
                            items: PropertyType.values.map((type) => 
                              DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type.name[0].toUpperCase() + type.name.substring(1),
                                  style: TextStyle(color: AppTheme.textColor),
                                ),
                              )
                            ).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Listing Purpose Dropdown
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Listing Purpose',
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.isDarkMode 
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.black.withOpacity(0.08),
                            ),
                          ),
                          child: DropdownButtonFormField<ListingPurpose>(
                            value: _selectedPurpose,
                            decoration: InputDecoration(
                              hintText: 'Select Purpose',
                              hintStyle: TextStyle(color: AppTheme.hintTextColor),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            dropdownColor: AppTheme.surfaceColor,
                            style: TextStyle(color: AppTheme.textColor),
                            onChanged: (value) => setState(() => _selectedPurpose = value!),
                            items: ListingPurpose.values.map((purpose) => 
                              DropdownMenuItem(
                                value: purpose,
                                child: Text(
                                  purpose.name[0].toUpperCase() + purpose.name.substring(1),
                                  style: TextStyle(color: AppTheme.textColor),
                                ),
                              )
                            ).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Location Section
                  _buildSectionTitle('Location Information'),
                  _buildTextField(_addressController, 'Address'),
                  _buildTextField(
                    _pinCodeController, 
                    'Pin Code',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a pin code';
                      }
                      if (value.length < 5) {
                        return 'Pin code should be at least 5 digits';
                      }
                      return null;
                    },
                  ),
                  _buildLocationPicker(),

                  // Media Section
                  _buildImagePicker(),
                  const SizedBox(height: 20),
                  _buildVideoPicker(),
                  const SizedBox(height: 20),
                  _buildDocumentPicker(),
                  
                  // Amenities Section
                  _buildAmenitiesPicker(),
                  
                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Submit Button
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit Property',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}