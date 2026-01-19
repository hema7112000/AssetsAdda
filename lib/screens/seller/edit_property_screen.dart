// lib/screens/seller/edit_property_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:real_estate_360/data/models/property_model.dart';
import 'package:real_estate_360/providers/auth_provider.dart';
import 'package:real_estate_360/providers/seller_provider.dart';
import 'package:real_estate_360/providers/property_provider.dart';

class EditPropertyScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const EditPropertyScreen({super.key, required this.propertyId});

  @override
  ConsumerState<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends ConsumerState<EditPropertyScreen> {
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
  List<File> _imageFiles = [];
  List<File> _documentFiles = [];
  File? _videoFile;
  double? _latitude;
  double? _longitude;
  Set<String> _selectedAmenities = {}; // DECLARED HERE

  bool _isLoading = false;
  bool _isInitialized = false;
  Property? _originalProperty; // To hold the initial data

  @override
  void initState() {
    super.initState();
    // Fetch the property data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final propertyAsync = ref.read(propertyDetailProvider(widget.propertyId));
      propertyAsync.when(
        data: (property) {
          if (!_isInitialized && property != null) {
            _originalProperty = property;
            _populateFields(property);
            setState(() {
              _isInitialized = true;
            });
          }
        },
        loading: () => {}, // Optionally show a loader
        error: (err, stack) => {}, // Optionally show an error
      );
    });
  }

  void _populateFields(Property property) {
    setState(() {
      _titleController.text = property.title;
      _descriptionController.text = property.description;
      _priceController.text = property.price.toString();
      _addressController.text = property.address;
      _pinCodeController.text = property.pinCode;
      _areaController.text = property.area.toString();
      _selectedType = property.type;
      _selectedPurpose = property.purpose;
      _selectedAmenities = property.amenities; // USED HERE
      _latitude = property.latitude;
      _longitude = property.longitude;
      // Note: We are not populating files (images, docs, video) from URLs.
    });
  }

  Future<void> _updateProperty() async {
    if (!_formKey.currentState!.validate() || _imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and add at least one image.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    // In a real app, you would upload new files and get URLs
    List<String> imageUrls = ['assets/images/apartment.jpg']; // Placeholder
    List<String> documentUrls = []; // Placeholder
    String? videoUrl; // Placeholder

    final user = ref.read(currentUserProvider);
    if (user == null || _originalProperty == null) return;

    final updatedProperty = _originalProperty!.copyWith( // Use copyWith for immutability
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
      type: _selectedType,
      purpose: _selectedPurpose,
      amenities: _selectedAmenities, // USED HERE
    );

    await ref.read(sellerProvider.notifier).updateProperty(updatedProperty);
    
    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property updated!')),
      );
    }
    setState(() { _isLoading = false; });
  }

  // --- UI Building Methods (you can copy these from AddPropertyScreen) ---
  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  // Add all other UI builders here: _buildImagePicker, _buildVideoPicker, etc.
  // For brevity, I am just putting a placeholder.
  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField(_titleController, 'Property Title'),
        _buildTextField(_descriptionController, 'Description', keyboardType: TextInputType.multiline),
        _buildTextField(_priceController, 'Price', keyboardType: TextInputType.number),
        _buildTextField(_addressController, 'Address'),
        _buildTextField(_pinCodeController, 'Pin Code'),
        _buildTextField(_areaController, 'Area (sqft)', keyboardType: TextInputType.number),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Property')),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFormFields(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _updateProperty,
                    child: const Text('Update Property'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}