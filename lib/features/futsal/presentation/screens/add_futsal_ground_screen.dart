import 'package:flutter/material.dart';
import 'package:futsal_app/features/futsal/presentation/providers/futsal_view_model.dart';
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

  final List<String> _availableFeatures = [
    'دوش', // Shower
    'پارکینگ', // Parking
    'کافه', // Cafe
    'وای فای', // Wi-Fi
    'رختکن', // Locker Room
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveGround() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final viewModel = context.read<FutsalViewModel>();
      await viewModel.addFutsalField(
        name: _nameController.text,
        address: _addressController.text,
        pricePerHour: double.parse(_priceController.text),
        features: _selectedFeatures,
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
                validator: (value) => value!.isEmpty ? 'لطفاً نام زمین را وارد کنید' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'آدرس'),
                validator: (value) => value!.isEmpty ? 'لطفاً آدرس را وارد کنید' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'قیمت برای ۱.۵ ساعت (افغانی)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty || double.tryParse(value) == null ? 'لطفاً قیمت معتبری وارد کنید' : null,
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
                      setState(() {
                        if (selected) {
                          _selectedFeatures.add(feature);
                        } else {
                          _selectedFeatures.remove(feature);
                        }
                      });
                    },
                  );
                }).toList(),
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
