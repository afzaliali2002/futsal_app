import 'package:flutter/material.dart';
import 'package:futsal_app/core/services/cloudinary_service.dart';
import 'package:futsal_app/features/futsal/presentation/screens/field_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
            cloudinary: cloudinary,
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

  // Filter State
  RangeValues _priceRange = const RangeValues(100, 1500);
  String? _selectedCity;

  // Cities list
  final List<String> _cities = ['Kabul', 'Herat', 'Mazar-i-Sharif', 'Kandahar', 'Jalalabad'];
  final Map<String, String> _cityLabels = {
    'Kabul': 'کابل',
    'Herat': 'هرات',
    'Mazar-i-Sharif': 'مزارشریف',
    'Kandahar': 'قندهار',
    'Jalalabad': 'جلال‌آباد',
  };

  bool _isFilterActive = false;

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

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('فیلترها', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    if (_isFilterActive)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _priceRange = const RangeValues(100, 1500);
                            _selectedCity = null;
                            _isFilterActive = false;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('حذف فیلترها'),
                      )
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),

                // Price Filter
                Text('محدوده قیمت: ${_priceRange.start.round()} - ${_priceRange.end.round()} افغانی',
                    style: Theme.of(context).textTheme.titleMedium),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 2000,
                  divisions: 40,
                  labels: RangeLabels(
                    _priceRange.start.round().toString(),
                    _priceRange.end.round().toString(),
                  ),
                  onChanged: (values) {
                    setSheetState(() => _priceRange = values);
                  },
                ),

                const SizedBox(height: 16),

                // City Filter
                Text('شهر', style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  spacing: 8,
                  children: _cities.map((city) {
                    return ChoiceChip(
                      label: Text(_cityLabels[city] ?? city),
                      selected: _selectedCity?.toLowerCase() == city.toLowerCase(),
                      onSelected: (selected) {
                        setSheetState(() => _selectedCity = selected ? city : null);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _priceRange = _priceRange;
                      _selectedCity = _selectedCity;
                      _isFilterActive = true;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('اعمال فیلتر'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<FutsalField> _getFilteredResults(List<FutsalField> results) {
    if (!_isFilterActive) return results;

    return results.where((field) {
      // 1. Price
      if (field.pricePerHour < _priceRange.start || field.pricePerHour > _priceRange.end) {
        return false;
      }

      // 2. City
      if (_selectedCity != null) {
        final engCity = _selectedCity!.toLowerCase();
        final faCity = _cityLabels[_selectedCity!]?.toLowerCase() ?? engCity;
        
        final city = field.city.toLowerCase();
        final address = field.address.toLowerCase();

        // Check against both English and Persian names
        bool matches = city.contains(engCity) || 
                       city.contains(faCity) || 
                       address.contains(engCity) || 
                       address.contains(faCity);

        if (!matches) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchProvider = context.watch<SearchProvider>();
    final results = _getFilteredResults(searchProvider.results);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('جستجو', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // Search Bar & Filter Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'نام زمین را جستجو کنید...',
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        suffixIcon: searchProvider.searchQuery.isNotEmpty
                            ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear())
                            : null,
                      ),
                      onChanged: (_) {}, // already handled by listener
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _showFilterSheet,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isFilterActive
                          ? theme.primaryColor
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.tune,
                        color: _isFilterActive
                            ? Colors.white
                            : theme.iconTheme.color),
                  ),
                ),
              ],
            ),
          ),

          // Results Info
          if (_isFilterActive && results.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              child: Text(
                '${results.length} زمین یافت شد',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.right,
              ),
            ),

          // Results
          Expanded(
            child: _buildBody(searchProvider, results),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SearchProvider searchProvider, List<FutsalField> results) {
    if (searchProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('مشکلی پیش آمد'),
            TextButton(
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
            Icon(Icons.search_rounded, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('نام زمین مورد نظر را جستجو کنید',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_dissatisfied, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              searchProvider.results.isEmpty
                  ? 'نتیجه‌ای یافت نشد'
                  : 'با فیلترهای انتخاب شده موردی یافت نشد',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final field = results[index];
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
