import 'package:flutter/material.dart';
import '../../../futsal/domain/entities/futsal_field.dart';
import '../../../futsal/domain/usecases/search_futsal_fields_usecase.dart';

class SearchProvider extends ChangeNotifier {
  final SearchFutsalFieldsUseCase searchFutsalFieldsUseCase;

  SearchProvider(this.searchFutsalFieldsUseCase);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<FutsalField> _results = [];
  List<FutsalField> get results => _results;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _error;
  String? get error => _error;

  Future<void> performSearch(String query) async {
    _searchQuery = query;
    _error = null;
    if (query.isEmpty) {
      _results = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _results = await searchFutsalFieldsUseCase(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
