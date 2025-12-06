import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جستجو'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('صفحه جستجو'),
      ),
    );
  }
}
