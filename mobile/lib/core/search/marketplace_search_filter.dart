class MarketplaceSearchFilter {
  final String query;
  final String category;
  final String condition;
  final String location;
  final double? maxMoq;
  final bool inStockOnly;
  final String sortBy;
  final String? farmerId;

  const MarketplaceSearchFilter({
    String? query,
    String? searchQuery,
    String? category,
    String? condition,
    String? location,
    this.maxMoq,
    bool? inStockOnly,
    String? sortBy,
    this.farmerId,
  })  : query = searchQuery ?? query ?? '',
        category = category ?? 'All',
        condition = condition ?? 'All',
        location = location ?? 'All',
        inStockOnly = inStockOnly ?? false,
        sortBy = sortBy ?? 'relevance';

  String get searchQuery => query;

  /// Factory for default blank filter
  factory MarketplaceSearchFilter.defaults() => const MarketplaceSearchFilter();

  /// Returns how many non-default filter constraints are active
  int get activeFilterCount {
    int count = 0;
    if (sortBy != 'relevance') count++;
    if (inStockOnly) count++;
    if (condition != 'All') count++;
    if (location != 'All') count++;
    if (maxMoq != null) count++;
    return count;
  }

  bool get hasActiveSearchOrFilter =>
      query.trim().isNotEmpty ||
      category != 'All' ||
      activeFilterCount > 0 ||
      (farmerId != null && farmerId!.isNotEmpty);

  MarketplaceSearchFilter copyWith({
    String? query,
    String? searchQuery,
    String? category,
    bool clearCategory = false,
    String? condition,
    String? location,
    double? maxMoq,
    bool clearMaxMoq = false,
    bool? inStockOnly,
    String? sortBy,
    String? farmerId,
    bool clearFarmerId = false,
  }) {
    return MarketplaceSearchFilter(
      query: searchQuery ?? query ?? this.query,
      category: clearCategory ? 'All' : (category ?? this.category),
      condition: condition ?? this.condition,
      location: location ?? this.location,
      maxMoq: clearMaxMoq ? null : (maxMoq ?? this.maxMoq),
      inStockOnly: inStockOnly ?? this.inStockOnly,
      sortBy: sortBy ?? this.sortBy,
      farmerId: clearFarmerId ? null : (farmerId ?? this.farmerId),
    );
  }

  /// Converts this filter to query parameters map for API call
  Map<String, String> toQueryParams({int page = 1, int limit = 12}) {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (query.trim().isNotEmpty) {
      params['search'] = query.trim();
    }
    if (category.isNotEmpty && category != 'All') {
      params['category'] = category;
    }
    if (condition.isNotEmpty && condition != 'All') {
      params['condition'] = condition;
    }
    if (location.isNotEmpty && location != 'All') {
      params['location'] = location;
    }
    if (maxMoq != null && maxMoq! > 0) {
      params['maxMoq'] = maxMoq!.toString();
    }
    if (inStockOnly) {
      params['inStockOnly'] = 'true';
    }
    if (sortBy.isNotEmpty && sortBy != 'relevance') {
      params['sortBy'] = sortBy;
    }
    if (farmerId != null && farmerId!.isNotEmpty) {
      params['farmerId'] = farmerId!;
    }

    return params;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketplaceSearchFilter &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          category == other.category &&
          condition == other.condition &&
          location == other.location &&
          maxMoq == other.maxMoq &&
          inStockOnly == other.inStockOnly &&
          sortBy == other.sortBy &&
          farmerId == other.farmerId;

  @override
  int get hashCode =>
      query.hashCode ^
      category.hashCode ^
      condition.hashCode ^
      location.hashCode ^
      maxMoq.hashCode ^
      inStockOnly.hashCode ^
      sortBy.hashCode ^
      farmerId.hashCode;
}
