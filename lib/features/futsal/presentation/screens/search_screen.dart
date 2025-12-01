// lib/features/futsal/presentation/screens/search_screen.dart
import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جستجو')),
      body: const Center(child: Text('صفحه جستجو')),
    );
  }
}