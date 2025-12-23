
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:futsal_app/features/futsal/domain/entities/time_range.dart';
import 'package:futsal_app/features/futsal/presentation/screens/map_picker_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:futsal_app/features/futsal/presentation/providers/futsal_view_model.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';
import 'package:futsal_app/features/profile/presentation/view_models/user_view_model.dart';
import '../../domain/entities/futsal_field.dart';

class AddFutsalGroundScreen extends StatefulWidget {
  final FutsalField? field;
  const AddFutsalGroundScreen({super.key, this.field});

  @override
  State<AddFutsalGroundScreen> createState() => _AddFutsalGroundScreenState();
}

class _AddFutsalGroundScreenState extends State<AddFutsalGroundScreen> {
  int _currentStep = 0;
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // Controllers for all fields
  final _groundNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _groundType;
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  String? _currency;
  final Map<String, List<TimeRange>> _schedule = {};
  final _sizeController = TextEditingController();
  String? _grassType;
  bool _lightsAvailable = false;
  bool _parkingAvailable = false;
  bool _changingRoomAvailable = false;
  bool _washroomAvailable = false;
  File? _coverImage;
  final List<File> _galleryImages = [];
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool get isEditMode => widget.field != null;
  String? _existingCoverImageUrl;
  List<String> _existingGalleryImageUrls = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _populateFieldsForEdit();
    }
  }

  void _populateFieldsForEdit() {
    final field = widget.field!;
    _groundNameController.text = field.name;
    _descriptionController.text = field.description;
    _groundType = field.groundType;
    _addressController.text = field.address;
    _cityController.text = field.city;
    if (field.location != null) {
      _latitudeController.text = field.location!.latitude.toString();
      _longitudeController.text = field.location!.longitude.toString();
    }
    _priceController.text = field.pricePerHour.toStringAsFixed(0);
    if (field.discount != null) {
      _discountController.text = field.discount!.toStringAsFixed(0);
    }
    _currency = field.currency;
    _sizeController.text = field.size ?? '';
    _grassType = field.grassType;
    _lightsAvailable = field.lightsAvailable;
    _parkingAvailable = field.parkingAvailable;
    _changingRoomAvailable = field.changingRoomAvailable;
    _washroomAvailable = field.washroomAvailable;
    _existingCoverImageUrl = field.coverImageUrl;
    _existingGalleryImageUrls = field.galleryImageUrls;
    _phoneController.text = field.phoneNumber;
    _whatsappController.text = field.whatsappNumber ?? '';
    _emailController.text = field.email ?? '';
    _firstNameController.text = field.firstName ?? '';
    _lastNameController.text = field.lastName ?? '';
  }

  @override
  void dispose() {
    _groundNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _sizeController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  int? _findFirstInvalidStep() {
    for (int i = 0; i < _formKeys.length; i++) {
      if (_formKeys[i].currentState != null && !_formKeys[i].currentState!.validate()) {
        return i;
      }
    }
    if (_coverImage == null && !isEditMode) {
       return 4;
    }
    return null;
  }

  bool _areAllStepsValid() {
    return _findFirstInvalidStep() == null;
  }

  void _showErrorForStep(int stepIndex) {
    List<String> missing = [];
    switch (stepIndex) {
      case 0:
        if (_groundNameController.text.isEmpty) missing.add('نام زمین');
        if (_groundType == null) missing.add('نوع زمین');
        if (_descriptionController.text.isEmpty) missing.add('توضیحات');
        break;
      case 1:
        if (_addressController.text.isEmpty) missing.add('آدرس');
        if (_cityController.text.isEmpty) missing.add('شهر');
        break;
      case 2:
        if (_priceController.text.isEmpty) missing.add('قیمت');
        if (_currency == null) missing.add('واحد پول');
        break;
      case 4:
        if (_firstNameController.text.isEmpty) missing.add('نام');
        if (_lastNameController.text.isEmpty) missing.add('تخلص');
        if (_phoneController.text.isEmpty) missing.add('شماره تماس');
        if (_coverImage == null && !isEditMode) missing.add('تصویر کاور');
        break;
    }

    String stepTitle = '';
    final steps = _getSteps();
    if (stepIndex < steps.length) {
       final titleWidget = steps[stepIndex].title;
       if (titleWidget is Text) {
          stepTitle = titleWidget.data ?? '';
       }
    }

    String message;
    if (missing.isNotEmpty) {
      message = 'لطفا در بخش "$stepTitle"، موارد زیر را تکمیل کنید:\n${missing.join('، ')}';
    } else {
      message = 'لطفا خطاهای موجود در بخش "$stepTitle" را برطرف کنید.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _onStepContinue() {
    if (_formKeys[_currentStep].currentState != null && !_formKeys[_currentStep].currentState!.validate()) {
       _showErrorForStep(_currentStep);
       return;
    }

    if (_currentStep == 4 && _coverImage == null && !isEditMode) {
        _showErrorForStep(4);
        return;
    }

    if (_currentStep < _getSteps().length - 1) {
       setState(() => _currentStep++);
    } else {
       int? invalidStep = _findFirstInvalidStep();
       if (invalidStep != null) {
          setState(() => _currentStep = invalidStep);
          _showErrorForStep(invalidStep);
       } else {
          _submitForm();
       }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _pickOnMap() async {
    final initialLat = double.tryParse(_latitudeController.text);
    final initialLng = double.tryParse(_longitudeController.text);
    final initialLocation =
        (initialLat != null && initialLng != null)
            ? LatLng(initialLat, initialLng)
            : null;

    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => MapPickerScreen(initialLocation: initialLocation),
      ),
    );

    if (pickedLocation != null) {
      setState(() {
        _latitudeController.text = pickedLocation.latitude.toString();
        _longitudeController.text = pickedLocation.longitude.toString();
      });

      try {
        final placemarks = await placemarkFromCoordinates(
          pickedLocation.latitude,
          pickedLocation.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final address = '${placemark.street}, ${placemark.locality}';
          _addressController.text = address;
          if (_cityController.text.isEmpty) {
            _cityController.text = placemark.administrativeArea ?? '';
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Could not get address. Please enter manually. Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_areAllStepsValid() || _isLoading) return;

    setState(() => _isLoading = true);

    final userViewModel = context.read<UserViewModel>();
    final ownerId = userViewModel.user?.uid;
    final isGroundOwner = userViewModel.user?.role == UserRole.groundOwner;

    if (ownerId == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا: کاربر شناسایی نشد. لطفا دوباره وارد شوید.')),
      );
      return;
    }

    try {
      // Fix: Handle parsing errors for latitude/longitude
      double? lat;
      double? lng;
      
      try {
        if (_latitudeController.text.isNotEmpty) lat = double.parse(_latitudeController.text);
        if (_longitudeController.text.isNotEmpty) lng = double.parse(_longitudeController.text);
      } catch (_) {
        // If parsing fails, just ignore location or set default
      }

      final baseField = FutsalField(
        id: widget.field?.id ?? '',
        name: _groundNameController.text,
        groundType: _groundType,
        description: _descriptionController.text,
        address: _addressController.text,
        city: _cityController.text,
        location: (lat != null && lng != null)
            ? GeoPoint(lat, lng)
            : null,
        pricePerHour: double.parse(_priceController.text),
        discount: _discountController.text.isNotEmpty
            ? double.tryParse(_discountController.text) ?? 0.0
            : null,
        currency: _currency ?? 'AFN',
        schedule: _schedule, // Default empty schedule
        size: _sizeController.text.isNotEmpty ? _sizeController.text : null,
        grassType: _grassType,
        lightsAvailable: _lightsAvailable,
        parkingAvailable: _parkingAvailable,
        changingRoomAvailable: _changingRoomAvailable,
        washroomAvailable: _washroomAvailable,
        coverImageUrl: widget.field?.coverImageUrl ?? '',
        galleryImageUrls: widget.field?.galleryImageUrls ?? [],
        phoneNumber: _phoneController.text,
        whatsappNumber: _whatsappController.text.isNotEmpty
            ? _whatsappController.text
            : null,
        email:
            _emailController.text.isNotEmpty ? _emailController.text : null,
        firstName: _firstNameController.text.isNotEmpty ? _firstNameController.text : null,
        lastName: _lastNameController.text.isNotEmpty ? _lastNameController.text : null,
        ownerId: isEditMode ? widget.field!.ownerId : ownerId,
        autoAcceptBookings: true, // Default value
        bankDetails: null, // Default value
        status: isEditMode ? widget.field!.status : 'pending',
      );

      if (isEditMode) {
        final oldField = widget.field!;
        final criticalChanges = <String, dynamic>{};
        bool hasCriticalChanges = false;

        if (baseField.name != oldField.name) {
          criticalChanges['name'] = baseField.name;
          hasCriticalChanges = true;
        }
        if (baseField.address != oldField.address) {
          criticalChanges['address'] = baseField.address;
          hasCriticalChanges = true;
        }
        if (baseField.city != oldField.city) {
          criticalChanges['city'] = baseField.city;
          hasCriticalChanges = true;
        }
        if (baseField.groundType != oldField.groundType) {
          criticalChanges['groundType'] = baseField.groundType;
          hasCriticalChanges = true;
        }
        final newLat = baseField.location?.latitude;
        final newLng = baseField.location?.longitude;
        final oldLat = oldField.location?.longitude;
        final oldLng = oldField.location?.longitude;
        if (newLat != oldLat || newLng != oldLng) {
          criticalChanges['location'] = baseField.location;
          hasCriticalChanges = true;
        }
        if (baseField.pricePerHour != oldField.pricePerHour) {
          criticalChanges['pricePerHour'] = baseField.pricePerHour;
          hasCriticalChanges = true;
        }

        if (isGroundOwner && hasCriticalChanges) {
          final updatedField = baseField.copyWith(
            name: oldField.name,
            address: oldField.address,
            city: oldField.city,
            groundType: oldField.groundType,
            location: oldField.location,
            pricePerHour: oldField.pricePerHour,
            pendingUpdates: criticalChanges,
          );

          await context
              .read<FutsalViewModel>()
              .updateGround(updatedField, coverImage: _coverImage);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'تغییرات حساس برای تایید مدیر ارسال شد. سایر تغییرات اعمال شدند.')),
            );
            Navigator.of(context).pop();
          }
        } else {
          await context
              .read<FutsalViewModel>()
              .updateGround(baseField, coverImage: _coverImage);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('زمین با موفقیت ویرایش شد!')),
            );
            Navigator.of(context).pop();
          }
        }
      } else {
        await context.read<FutsalViewModel>().addFutsalField(
              field: baseField,
              coverImage: _coverImage,
              galleryImages: _galleryImages,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('زمین با موفقیت ثبت شد و در انتظار تایید مدیر است.')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ثبت زمین: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source, {bool isCover = false}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        if (isCover) {
          _coverImage = File(pickedFile.path);
        } else if (_galleryImages.length < 6) {
          _galleryImages.add(File(pickedFile.path));
        }
      });
    }
  }

  List<Step> _getSteps() {
    final isGroundOwner =
        context.read<UserViewModel>().user?.role == UserRole.groundOwner;
    final readOnlyStyle = const TextStyle(color: Colors.grey);
    // Helper to determine if a critical field should be read-only
    final isCriticalReadOnly = isEditMode && isGroundOwner;

    return [
      Step(
        title: const Text('۱. اطلاعات ابتدایی'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 && _formKeys[0].currentState?.validate() == true
            ? StepState.complete
            : StepState.indexed,
        content: Form(
          key: _formKeys[0],
          child: Column(children: [
            TextFormField(
              controller: _groundNameController,
              decoration: const InputDecoration(labelText: 'نام زمین'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'این فیلد الزامی است' : null,
              readOnly: isCriticalReadOnly,
              style: isCriticalReadOnly ? readOnlyStyle : null,
            ),
            const SizedBox(height: 16),
            IgnorePointer(
              ignoring: isCriticalReadOnly,
              child: DropdownButtonFormField<String>(
                value: _groundType,
                decoration: InputDecoration(
                    labelText: 'نوع زمین',
                    labelStyle: isCriticalReadOnly ? readOnlyStyle : null),
                items: ['چمن فوتبال', 'کورت فوتسال', 'زمین کریکت', 'کورت والیبال']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _groundType = v),
                validator: (v) => v == null ? 'لطفا یک نوع را انتخاب کنید' : null,
                style: isCriticalReadOnly ? readOnlyStyle : null,
              ),
            ),
            if (isCriticalReadOnly)
              const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('*تغییر نام و نوع زمین نیازمند تایید مدیر است',
                          style: TextStyle(fontSize: 11, color: Colors.orange)))),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'توضیحات'),
              maxLines: 3,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'این فیلد الزامی است' : null,
            ),
          ]),
        ),
      ),
      Step(
        title: const Text('۲. موقعیت'),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 && _formKeys[1].currentState?.validate() == true
            ? StepState.complete
            : StepState.indexed,
        content: Form(
          key: _formKeys[1],
          child: Column(children: [
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'آدرس'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'این فیلد الزامی است' : null,
              readOnly: isCriticalReadOnly,
              style: isCriticalReadOnly ? readOnlyStyle : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'شهر'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'این فیلد الزامی است' : null,
              readOnly: isCriticalReadOnly,
              style: isCriticalReadOnly ? readOnlyStyle : null,
            ),
            if (isCriticalReadOnly)
              const Padding(
                  padding: EdgeInsets.only(top: 4, bottom: 8),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('*تغییر آدرس نیازمند تایید مدیر است',
                          style: TextStyle(
                              fontSize: 11, color: Colors.orange)))),
            const SizedBox(height: 16),
            IgnorePointer(
              ignoring: isCriticalReadOnly,
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _latitudeController,
                        decoration:
                            const InputDecoration(labelText: 'عرض جغرافیایی'),
                        keyboardType: TextInputType.number,
                        readOnly: isCriticalReadOnly,
                        style: isCriticalReadOnly ? readOnlyStyle : null)),
                const SizedBox(width: 16),
                Expanded(
                    child: TextFormField(
                        controller: _longitudeController,
                        decoration:
                            const InputDecoration(labelText: 'طول جغرافیایی'),
                        keyboardType: TextInputType.number,
                        readOnly: isCriticalReadOnly,
                        style: isCriticalReadOnly ? readOnlyStyle : null)),
              ]),
            ),
            const SizedBox(height: 16),
            if (!isCriticalReadOnly)
              ElevatedButton.icon(
                  onPressed: _pickOnMap,
                  icon: const Icon(Icons.map),
                  label: const Text('انتخاب از روی نقشه'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40))),
          ]),
        ),
      ),
      Step(
        title: const Text('۳. قیمت گذاری'),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 && _formKeys[2].currentState?.validate() == true
            ? StepState.complete
            : StepState.indexed,
        content: Form(
          key: _formKeys[2],
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  decoration:
                      const InputDecoration(labelText: 'قیمت سانس'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'لطفا قیمت را وارد کنید' : null,
                  readOnly: isCriticalReadOnly, // Base price is critical
                  style: isCriticalReadOnly ? readOnlyStyle : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: IgnorePointer(
                  ignoring: isCriticalReadOnly,
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: const InputDecoration(labelText: 'واحد پول'),
                    items: ['افغانی', 'دالر']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _currency = v),
                    validator: (v) => v == null ? 'لطفا انتخاب کنید' : null,
                    style: isCriticalReadOnly ? readOnlyStyle : null,
                  ),
                ),
              ),
            ]),
            if (isCriticalReadOnly)
              const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('*تغییر قیمت پایه نیازمند تایید مدیر است',
                          style: TextStyle(
                              fontSize: 11, color: Colors.orange)))),
            const SizedBox(height: 16),
            TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(
                    labelText: 'تخفیف (اختیاری)',
                    hintText: 'مثال: 10 برای ۱۰٪'),
                keyboardType: TextInputType.number),
          ]),
        ),
      ),
      Step(
        title: const Text('۴. امکانات'),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _formKeys[3],
          child: Column(
            children: [
              TextFormField(
                  controller: _sizeController,
                  decoration: const InputDecoration(
                      labelText: 'اندازه (اختیاری)',
                      hintText: 'مثال: ۴۰ متر × ۲۰ متر')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                  value: _grassType,
                  decoration:
                      const InputDecoration(labelText: 'نوع چمن (اختیاری)'),
                  items: ['مصنوعی', 'طبیعی']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => _grassType = v)),
              SwitchListTile(
                  title: const Text('چراغ موجود است؟'),
                  value: _lightsAvailable,
                  onChanged: (v) => setState(() => _lightsAvailable = v)),
              SwitchListTile(
                  title: const Text('پارکینگ موجود است؟'),
                  value: _parkingAvailable,
                  onChanged: (v) => setState(() => _parkingAvailable = v)),
              SwitchListTile(
                  title: const Text('رختکن موجود است؟'),
                  value: _changingRoomAvailable,
                  onChanged: (v) =>
                      setState(() => _changingRoomAvailable = v)),
              SwitchListTile(
                  title: const Text('تشناب موجود است؟'),
                  value: _washroomAvailable,
                  onChanged: (v) => setState(() => _washroomAvailable = v)),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('۵. اطلاعات تماس و تصاویر'),
        isActive: _currentStep >= 4,
        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _formKeys[4],
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'نام'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'این فیلد الزامی است' : null),
            const SizedBox(height: 16),
            TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'تخلص'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'این فیلد الزامی است' : null),
            const SizedBox(height: 16),
            TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'شماره تماس'),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'این فیلد الزامی است' : null),
            const SizedBox(height: 16),
            TextFormField(
                controller: _whatsappController,
                decoration:
                    const InputDecoration(labelText: 'شماره واتساپ (اختیاری)'),
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'ایمیل (اختیاری)'),
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 24),
            const Text('تصویر کاور زمین',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery, isCover: true),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: _coverImage == null && !isEditMode
                            ? Colors.red
                            : Colors.grey),
                    borderRadius: BorderRadius.circular(8)),
                child: _coverImage != null
                    ? Image.file(_coverImage!, fit: BoxFit.cover)
                    : (isEditMode &&
                            _existingCoverImageUrl != null &&
                            _existingCoverImageUrl!.isNotEmpty
                        ? Image.network(_existingCoverImageUrl!, fit: BoxFit.cover)
                        : const Center(
                            child: Icon(Icons.add_a_photo,
                                size: 50, color: Colors.grey))),
              ),
            ),
            if (_coverImage == null && !isEditMode)
              const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('انتخاب تصویر کاور الزامی است',
                      style: TextStyle(color: Colors.red, fontSize: 12))),
            const SizedBox(height: 24),
            const Text('تصاویر گالری (اختیاری)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ..._galleryImages.map((image) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(image,
                        width: 100, height: 100, fit: BoxFit.cover))),
                if (_galleryImages.length < 6)
                  GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery),
                      child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.add, size: 40, color: Colors.grey))),
              ],
            )
          ]),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'ویرایش زمین' : 'ثبت زمین جدید')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
              onStepTapped: (step) => setState(() => _currentStep = step),
              steps: _getSteps(),
              controlsBuilder: (context, details) {
                final isLastStep = _currentStep == _getSteps().length - 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    children: <Widget>[
                      ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: Text(isLastStep ? 'ثبت نهایی' : 'ادامه')),
                      if (_currentStep > 0)
                        TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('قبلی')),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
