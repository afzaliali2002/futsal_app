import 'package:flutter/material.dart';
import 'package:futsal_app/features/futsal/presentation/providers/futsal_view_model.dart';
import 'package:futsal_app/features/futsal/presentation/widgets/futsal_field_card.dart';
import 'package:provider/provider.dart';

class FavoriteFutsalScreen extends StatelessWidget {
  const FavoriteFutsalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FutsalViewModel>();
    final favoriteFields = vm.fields.where((field) => field.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('علاقه‌مندی‌ها'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: favoriteFields.isEmpty
          ? const Center(
              child: Text('هیچ زمین موردعلاقه‌ای یافت نشد.'),
            )
          : ListView.builder(
              itemCount: favoriteFields.length,
              itemBuilder: (context, index) {
                final field = favoriteFields[index];
                return FutsalFieldCard(field: field);
              },
            ),
    );
  }
}
