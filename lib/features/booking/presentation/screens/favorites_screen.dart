import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual favorite fields from a ViewModel
    final List<dynamic> favoriteFields = [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('علاقه‌مندی‌ها'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: favoriteFields.isEmpty
          ? _buildEmptyState(context)
          : _buildFavoritesList(favoriteFields),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'هیچ زمینی به علاقه‌مندی‌ها اضافه نشده است',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<dynamic> fields) {
    // TODO: Use FutsalCard and real data
    return ListView.builder(
      itemCount: fields.length,
      itemBuilder: (context, index) {
        // Replace with FutsalCard(field: fields[index])
        return const ListTile(
          title: Text('زمین مورد علاقه'),
        );
      },
    );
  }
}
