import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/futsal_view_model.dart';
import '../widgets/futsal_field_card.dart';
import 'field_detail_screen.dart';

class FavoriteFutsalScreen extends StatelessWidget {
  const FavoriteFutsalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زمین‌های مورد علاقه'),
      ),
      body: Consumer<FutsalViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteFields = vm.fields.where((field) => field.isFavorite).toList();

          if (favoriteFields.isEmpty) {
            return const Center(
              child: Text(
                'شما هنوز هیچ زمینی را به لیست مورد علاقه خود اضافه نکرده‌اید.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: favoriteFields.length,
            itemBuilder: (context, index) {
              final field = favoriteFields[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FieldDetailScreen(field: field),
                    ),
                  );
                },
                child: FutsalFieldCard(field: field),
              );
            },
          );
        },
      ),
    );
  }
}