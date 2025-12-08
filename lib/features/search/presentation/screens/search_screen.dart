import 'package:flutter/material.dart';
import 'package:futsal_app/features/futsal/presentation/screens/field_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:futsal_app/features/futsal/data/repositories/futsal_repository_impl.dart';
import 'package:futsal_app/features/futsal/domain/usecases/search_futsal_fields_usecase.dart';
import '../providers/search_provider.dart';
import '../../../futsal/domain/entities/futsal_field.dart';
import '../../../futsal/presentation/widgets/futsal_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchProvider(
        SearchFutsalFieldsUseCase(
          FutsalRepositoryImpl(
            firestore: FirebaseFirestore.instance,
            storage: FirebaseStorage.instance,
          ),
        ),
      ),
      child: const _SearchScreenContent(),
    );
  }
}

class _SearchScreenContent extends StatefulWidget {
  const _SearchScreenContent();

  @override
  State<_SearchScreenContent> createState() => _SearchScreenContentState();
}

class _SearchScreenContentState extends State<_SearchScreenContent> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<SearchProvider>().performSearch(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'نام زمین را جستجو کنید...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: theme.hintColor),
          ),
          style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 18),
        ),
        actions: [
          if (searchProvider.searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
      body: _buildBody(searchProvider),
    );
  }

  Widget _buildBody(SearchProvider searchProvider) {
    if (searchProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('مشکلی پیش آمد. لطفا دوباره تلاش کنید.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onSearchChanged,
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      );
    }

    if (searchProvider.searchQuery.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('یک زمین فوتسال را با نام جستجو کنید.', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    if (searchProvider.results.isEmpty) {
      return Center(
        child: Text(
          'هیچ نتیجه‌ای برای "${searchProvider.searchQuery}" یافت نشد.',
          style: const TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: searchProvider.results.length,
      itemBuilder: (context, index) {
        final field = searchProvider.results[index];
        return FutsalCard(
          field: field,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FieldDetailScreen(field: field),
              ),
            );
          },
        );
      },
    );
  }
}
