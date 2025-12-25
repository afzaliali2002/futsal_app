import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/futsal_view_model.dart';
import '../widgets/futsal_field_card.dart';
import 'field_detail_screen.dart';

class TopRatedFutsalScreen extends StatelessWidget {
  const TopRatedFutsalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('برترین زمین‌ها'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Consumer<FutsalViewModel>(
        builder: (context, vm, child) {
          final topRatedFields = vm.fields.where((f) => f.rating >= 3.5).toList();

          if (topRatedFields.isEmpty) {
            return const Center(
              child: Text('هیچ زمین برتری یافت نشد.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: topRatedFields.length,
            itemBuilder: (context, index) {
              final field = topRatedFields[index];
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
