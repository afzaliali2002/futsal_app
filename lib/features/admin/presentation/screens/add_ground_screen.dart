
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:futsal_app/features/admin/presentation/screens/map_picker_screen.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';
import 'package:futsal_app/features/futsal/presentation/providers/futsal_view_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddGroundScreen extends StatefulWidget {
  final FutsalField? field;

  const AddGroundScreen({super.key, this.field});

  @override
  State<AddGroundScreen> createState() => _AddGroundScreenState();
}

class _AddGroundScreenState extends State<AddGroundScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _priceController;
  late TextEditingController _featuresController;
  late TextEditingController _descriptionController;
  late TextEditingController _cityController;
  late TextEditingController _phoneNumberController;
  File? _image;
  bool _isLoading = false;
  LatLng? _pickedLocation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.field?.name);
    _addressController = TextEditingController(text: widget.field?.address);
    _priceController =
        TextEditingController(text: widget.field?.pricePerHour.toStringAsFixed(0));
    _featuresController =
        TextEditingController(text: widget.field?.features.join(', '));
    _descriptionController =
        TextEditingController(text: widget.field?.description);
    _cityController = TextEditingController(text: widget.field?.city);
    _phoneNumberController =
        TextEditingController(text: widget.field?.phoneNumber);
    if (widget.field?.location != null) {
      _pickedLocation = LatLng(widget.field!.location!.latitude, widget.field!.location!.longitude);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _featuresController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Compress image to 50% of original quality
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => const MapPickerScreen(),
      ),
    );

    if (pickedLocation != null) {
      setState(() {
        _pickedLocation = pickedLocation;
      });

      try {
        final placemarks = await placemarkFromCoordinates(
          pickedLocation.latitude,
          pickedLocation.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          
          // Construct a better address to avoid Plus Codes (e.g., F37F+GWV)
          final parts = <String>[];
          
          // Use thoroughfare (street name) if available
          if (placemark.thoroughfare?.isNotEmpty == true) {
            String streetPart = placemark.thoroughfare!;
            if (placemark.subThoroughfare?.isNotEmpty == true) {
               streetPart += ' ${placemark.subThoroughfare}';
            }
            parts.add(streetPart);
          } else if (placemark.street?.isNotEmpty == true && !placemark.street!.contains('+')) {
             // Fallback to street if it doesn't look like a code
             parts.add(placemark.street!);
          }
          
          if (placemark.subLocality?.isNotEmpty == true) {
            parts.add(placemark.subLocality!);
          }
          if (placemark.locality?.isNotEmpty == true) {
            parts.add(placemark.locality!);
          }
          
          // Fallback if we couldn't get any meaningful parts
          if (parts.isEmpty) {
             if (placemark.name?.isNotEmpty == true) parts.add(placemark.name!);
             if (placemark.street?.isNotEmpty == true) parts.add(placemark.street!);
          }

          _addressController.text = parts.join(', ');
        }
      } catch (e) {
         if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not get address. Please enter manually. Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final futsalViewModel = Provider.of<FutsalViewModel>(context, listen: false);

    try {
      // Parse features from the text controller
      String? size;
      String? grassType;
      final otherFeatures = <String>[];
      final featuresFromTextField =
          _featuresController.text.split(',').map((e) => e.trim()).toList();

      for (final feature in featuresFromTextField) {
        final lowerFeature = feature.toLowerCase();
        if (lowerFeature.startsWith('size:')) {
          size = feature.substring('size:'.length).trim();
        } else if (lowerFeature.startsWith('grass:')) {
          grassType = feature.substring('grass:'.length).trim();
        } else if (feature.isNotEmpty) {
          otherFeatures.add(lowerFeature);
        }
      }

      final GeoPoint? location = _pickedLocation == null
          ? null
          : GeoPoint(_pickedLocation!.latitude, _pickedLocation!.longitude);

      if (widget.field == null) {
        final field = FutsalField(
          id: '', // Will be generated by repository
          name: _nameController.text,
          address: _addressController.text,
          pricePerHour: double.parse(_priceController.text),
          description: _descriptionController.text,
          city: _cityController.text,
          phoneNumber: _phoneNumberController.text,
          coverImageUrl: '', // Will be set by repository
          currency: 'USD', // Default currency
          ownerId: '', // This should be the current user's ID.
          size: size,
          grassType: grassType,
          lightsAvailable: otherFeatures.contains('lights'),
          parkingAvailable: otherFeatures.contains('parking'),
          changingRoomAvailable: otherFeatures.contains('changing room'),
          washroomAvailable: otherFeatures.contains('washroom'),
          location: location,
        );
        await futsalViewModel.addFutsalField(field: field, coverImage: _image);
      } else {
        final updatedField = widget.field!.copyWith(
          name: _nameController.text,
          address: _addressController.text,
          pricePerHour: double.parse(_priceController.text),
          description: _descriptionController.text,
          city: _cityController.text,
          phoneNumber: _phoneNumberController.text,
          size: size,
          grassType: grassType,
          lightsAvailable: otherFeatures.contains('lights'),
          parkingAvailable: otherFeatures.contains('parking'),
          changingRoomAvailable: otherFeatures.contains('changing room'),
          washroomAvailable: otherFeatures.contains('washroom'),
          location: location,
        );
        await futsalViewModel.updateGround(updatedField, coverImage: _image);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('زمین با موفقیت ذخیره شد')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ذخیره زمین: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.field == null ? 'اضافه کردن زمین' : 'ویرایش زمین'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_image != null)
                      Image.file(_image!, height: 200)
                    else if (widget.field?.coverImageUrl.isNotEmpty == true)
                      Image.network(
                        widget.field!.coverImageUrl,
                        height: 200,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error');
                          return const Icon(Icons.broken_image, size: 100, color: Colors.red);
                        },
                      ),
                    ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text('انتخاب عکس')),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'نام زمین'),
                      validator: (value) =>
                          value!.isEmpty ? 'فیلد نام الزامی است' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'آدرس'),
                      validator: (value) =>
                          value!.isEmpty ? 'فیلد آدرس الزامی است' : null,
                    ),
                     const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _pickOnMap,
                      icon: const Icon(Icons.map),
                      label: const Text('Choose from map'),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'توضیحات'),
                       maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'شهر'),
                       validator: (value) =>
                          value!.isEmpty ? 'فیلد شهر الزامی است' : null,
                    ),
                    const SizedBox(height: 20),
                     TextFormField(
                      controller: _phoneNumberController,
                      decoration: const InputDecoration(labelText: 'شماره تماس'),
                       validator: (value) =>
                          value!.isEmpty ? 'فیلد شماره تماس الزامی است' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'قیمت'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'فیلد قیمت الزامی است' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _featuresController,
                      decoration: const InputDecoration(
                          labelText: 'امکانات (با ویرگول جدا کنید)'),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _onSave,
                      child: const Text('ذخیره'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
