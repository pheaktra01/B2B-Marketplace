import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/search/marketplace_search_filter.dart';
import 'package:mobile/features/product/services/product_service.dart';

class PaginatedSearchController extends ChangeNotifier {
  PaginatedSearchController({
    MarketplaceSearchFilter? initialFilter,
    this.farmerId,
    this.limit = 12,
    this.debounceDuration = const Duration(milliseconds: 350),
    bool autoLoad = true,
  }) : _filter = initialFilter ?? const MarketplaceSearchFilter() {
    if (autoLoad) {
      loadInitial();
    }
  }

  final String? farmerId;
  final int limit;
  final Duration debounceDuration;

  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  int _total = 0;
  String? _error;
  MarketplaceSearchFilter _filter;
  Timer? _debounceTimer;

  // Getters
  List<Map<String, dynamic>> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  int get page => _page;
  int get total => _total;
  String? get error => _error;
  MarketplaceSearchFilter get filter => _filter;
  bool get isEmpty => !_isLoading && _items.isEmpty && _error == null;

  /// Loads the first page with current filters
  Future<void> loadInitial({bool silent = false}) async {
    _debounceTimer?.cancel();
    _page = 1;
    _hasMore = true;
    _error = null;

    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final result = await ProductService.getPaginatedProducts(
        page: _page,
        limit: limit,
        filter: _filter,
        farmerId: farmerId,
      );

      final List<Map<String, dynamic>> fetched =
          (result['data'] as List? ?? []).cast<Map<String, dynamic>>();

      _items = fetched;
      _total = (result['total'] as num?)?.toInt() ?? fetched.length;
      _hasMore = (result['hasMore'] as bool?) ?? (_items.length < _total);
      _isLoading = false;
      _error = null;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
    }

    notifyListeners();
  }

  /// Loads the next page for infinite scrolling
  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _page + 1;
      final result = await ProductService.getPaginatedProducts(
        page: nextPage,
        limit: limit,
        filter: _filter,
        farmerId: farmerId,
      );

      final List<Map<String, dynamic>> fetched =
          (result['data'] as List? ?? []).cast<Map<String, dynamic>>();

      if (fetched.isEmpty) {
        _hasMore = false;
      } else {
        _page = nextPage;
        _items.addAll(fetched);
        _total = (result['total'] as num?)?.toInt() ?? _items.length;
        _hasMore = (result['hasMore'] as bool?) ?? (_items.length < _total);
      }
      _isLoadingMore = false;
    } catch (e) {
      _isLoadingMore = false;
      // Keep existing items even if loadMore fails
    }

    notifyListeners();
  }

  /// Called on search bar text change, debouncing API calls to prevent lag
  void onSearchQueryChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      if (_filter.searchQuery == query) return;
      _filter = _filter.copyWith(searchQuery: query);
      loadInitial();
    });
  }

  /// Updates current filter and re-fetches
  void updateFilter(MarketplaceSearchFilter newFilter) {
    _debounceTimer?.cancel();
    _filter = newFilter;
    loadInitial();
  }

  /// Updates category filter specifically (e.g. from category pills)
  void setCategory(String? category) {
    if (_filter.category == category) {
      // Toggle off if already selected
      updateFilter(_filter.copyWith(clearCategory: true));
    } else {
      updateFilter(_filter.copyWith(category: category));
    }
  }

  /// Resets all filters back to defaults
  void resetFilter() {
    _debounceTimer?.cancel();
    _filter = const MarketplaceSearchFilter();
    loadInitial();
  }

  /// Refreshes data while keeping current state
  Future<void> refresh() async {
    await loadInitial(silent: false);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
