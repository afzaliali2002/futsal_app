// lib/features/futsal/presentation/screens/search_screen.dart
import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جستجو')),
      body: const Center(child: Text('صفحه جستجو')),
    );
  }
}