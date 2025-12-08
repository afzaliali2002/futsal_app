import 'dart:io';
import 'package:flutter/material.dart';
import 'package:futsal_app/features/futsal/presentation/providers/futsal_view_model.dart';
import 'package:futsal_app/features/profile/presentation/view_models/user_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddFutsalGroundScreen extends StatefulWidget {
  const AddFutsalGroundScreen({super.key});

  @override
  State<AddFutsalGroundScreen> createState() => _AddFutsalGroundScreenState();
}

class _AddFutsalGroundScreenState extends State<AddFutsalGroundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final List<String> _selectedFeatures = [];
  bool _isLoading = false;
  File? _image;

  final List<String> _availableFeatures = [
    'دوش',
    'پارکینگ',
    'کافه',
    'وای فای',
    'رختکن',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveGround() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userViewModel = context.read<UserViewModel>();
    final ownerId = userViewModel.user?.uid;

    if (ownerId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('خطا: کاربر وارد نشده است. لطفا دوباره وارد شوید')),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final viewModel = context.read<FutsalViewModel>();
      await viewModel.addFutsalField(
        name: _nameController.text,
        address: _addressController.text,
        pricePerHour: double.parse(_priceController.text),
        features: _selectedFeatures,
        imageFile: _image,
        ownerId: ownerId, // Pass the ownerId here
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('زمین با موفقیت اضافه شد!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در افزودن زمین: $e')),
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
        title: const Text('افزودن زمین جدید'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'نام زمین'),
                validator: (v) =>
                    v!.isEmpty ? 'لطفاً نام زمین را وارد کنید' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'آدرس'),
                validator: (v) => v!.isEmpty ? 'لطفاً آدرس را وارد کنید' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                    labelText: 'قیمت برای ۱.۵ ساعت (افغانی)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty || double.tryParse(v) == null
                    ? 'لطفاً قیمت معتبری وارد کنید'
                    : null,
              ),
              const SizedBox(height: 24),
              const Text('امکانات', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: _availableFeatures.map((feature) {
                  final isSelected = _selectedFeatures.contains(feature);
                  return FilterChip(
                    label: Text(feature),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => isSelected
                          ? _selectedFeatures.remove(feature)
                          : _selectedFeatures.add(feature));
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text('تصویر زمین', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : const Center(
                          child: Icon(Icons.add_a_photo,
                              size: 50, color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveGround,
                      child: const Text('ذخیره زمین'),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
