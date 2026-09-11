import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/features/cart/services/cart_service.dart';
import 'package:mobile/features/product/screens/product_card.dart';
import 'package:mobile/features/product/services/favorites_service.dart';
import 'package:mobile/features/product/services/product_service.dart';
import 'package:mobile/features/profile/services/user_service.dart';

class SearchMarketScreen extends StatefulWidget {
  const SearchMarketScreen({super.key});

  @override
  State<SearchMarketScreen> createState() => _SearchMarketScreenState();
}

class _SearchMarketScreenState extends State<SearchMarketScreen> {
  // Brand Palette
  static const Color primaryGreen = Color(0xFF0F5A27);
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color accentOrange = Color(0xFFF57C00);
  static const Color lightBg = Color(0xFFF8FAF9);
  static const Color inputBg = Color(0xFFEFF2F1);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  // Controllers & Services
  final TextEditingController _searchController = TextEditingController();
  final CartService _cartService = CartService();
  final UserService _userService = UserService();

  // State Data
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _farmers = [];
  Set<String> _favoriteIds = {};
  final List<String> _recentSearches = [];

  bool _isLoading = true;
  String? _errorMessage;
  String? _addingProductId;

  // Filter & Search Controls
  int _selectedTabIndex = 0; // 0: All, 1: Products, 2: Farmers
  String _selectedCategory = 'All';
  String _sortBy = 'relevance'; // relevance, newest, price_low, price_high, moq_low
  bool _onlyAvailable = false;
  String _selectedCondition = 'All'; // All, Organic / GAP, Fresh Harvest
  String _selectedLocation = 'All';
  double? _maxMoq;
  bool _isGridView = true;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Vegetables', 'icon': Icons.eco_rounded},
    {'name': 'Fruits', 'icon': Icons.apple_rounded},
    {'name': 'Herbs & Spices', 'icon': Icons.grass_rounded},
    {'name': 'Seafood', 'icon': Icons.set_meal_rounded},
    {'name': 'Meat & Poultry', 'icon': Icons.egg_alt_rounded},
    {'name': 'Rice & Grains', 'icon': Icons.grain_rounded},
  ];

  final List<String> _provinces = [
    'All',
    'Kandal',
    'Battambang',
    'Siem Reap',
    'Kampot',
    'Takeo',
    'Phnom Penh',
    'Pursat',
    'Kampong Cham',
  ];

  final List<String> _popularKeywords = [
    'Fresh Greens',
    'Organic Tomato',
    'Battambang Orange',
    'Kampot Pepper',
    'Jasmine Rice',
    'Local Herbs',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadInitialData();
  }

  void _onSearchChanged() => setState(() {});

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================
  // DATA LOADING
  // ==========================================================

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ProductService.getAllProducts(),
        FavoritesService.getFavoriteIds(),
        _userService.getRecommendedFarmers(),
      ]);

      if (!mounted) return;

      final productsData = results[0];
      final favIdsData = results[1] as List<String>;
      final farmersData = results[2] as List<Map<String, dynamic>>;

      setState(() {
        _products = productsData
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        _favoriteIds = favIdsData.toSet();
        _farmers = farmersData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Load market products error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ==========================================================
  // SEARCH & FILTER LOGIC
  // ==========================================================

  int get _activeFilterCount {
    int count = 0;
    if (_sortBy != 'relevance') count++;
    if (_onlyAvailable) count++;
    if (_selectedCondition != 'All') count++;
    if (_selectedLocation != 'All') count++;
    if (_maxMoq != null) count++;
    return count;
  }

  List<Map<String, dynamic>> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    List<Map<String, dynamic>> list = List.from(_products);

    // 1. Category Filter
    if (_selectedCategory != 'All') {
      list = list.where((p) {
        final cat = p['category']?.toString().toLowerCase() ?? '';
        return cat == _selectedCategory.toLowerCase();
      }).toList();
    }

    // 2. Query Filter
    if (query.isNotEmpty) {
      list = list.where((p) {
        final name = p['name']?.toString().toLowerCase() ?? '';
        final desc = p['description']?.toString().toLowerCase() ?? '';
        final cat = p['category']?.toString().toLowerCase() ?? '';
        final loc = p['location']?.toString().toLowerCase() ?? '';
        final farmer = _getFarmerName(p).toLowerCase();

        return name.contains(query) ||
            desc.contains(query) ||
            cat.contains(query) ||
            loc.contains(query) ||
            farmer.contains(query);
      }).toList();
    }

    // 3. Availability Filter
    if (_onlyAvailable) {
      list = list.where((p) {
        final isAvail = p['isAvailable'] ?? true;
        final qty = _toNumber(p['quantity']);
        return isAvail && qty > 0;
      }).toList();
    }

    // 4. Condition / Certification Filter
    if (_selectedCondition == 'Organic / GAP') {
      list = list.where((p) {
        final cond = p['condition']?.toString().toLowerCase() ?? '';
        final name = p['name']?.toString().toLowerCase() ?? '';
        final desc = p['description']?.toString().toLowerCase() ?? '';
        return cond.contains('organic') ||
            cond.contains('gap') ||
            name.contains('organic') ||
            desc.contains('organic');
      }).toList();
    } else if (_selectedCondition == 'Fresh Harvest') {
      list = list.where((p) {
        final cond = p['condition']?.toString().toLowerCase() ?? '';
        return cond.contains('fresh');
      }).toList();
    }

    // 5. Location Filter
    if (_selectedLocation != 'All') {
      list = list.where((p) {
        final loc = p['location']?.toString().toLowerCase() ?? '';
        return loc.contains(_selectedLocation.toLowerCase());
      }).toList();
    }

    // 6. Max MOQ Filter
    if (_maxMoq != null) {
      list = list.where((p) {
        final moq = _toNumber(p['minOrder']);
        return moq <= _maxMoq!;
      }).toList();
    }

    // 7. Sorting
    switch (_sortBy) {
      case 'price_low':
        list.sort((a, b) => _toNumber(a['price']).compareTo(_toNumber(b['price'])));
        break;
      case 'price_high':
        list.sort((a, b) => _toNumber(b['price']).compareTo(_toNumber(a['price'])));
        break;
      case 'moq_low':
        list.sort((a, b) => _toNumber(a['minOrder']).compareTo(_toNumber(b['minOrder'])));
        break;
      case 'newest':
        list.sort((a, b) {
          final dateA = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime(2000);
          final dateB = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
        break;
      case 'relevance':
      default:
        // Default order
        break;
    }

    return list;
  }

  List<Map<String, dynamic>> get _filteredFarmers {
    final query = _searchController.text.trim().toLowerCase();

    // Collect all farmers from recommended list + publishers from products
    final map = <String, Map<String, dynamic>>{};

    for (final f in _farmers) {
      final id = f['id']?.toString() ?? '';
      if (id.isNotEmpty) map[id] = Map<String, dynamic>.from(f);
    }

    for (final p in _products) {
      final pub = p['publisher'];
      final fid = p['farmerId']?.toString() ?? (pub is Map ? pub['id']?.toString() : null);
      if (fid != null && fid.isNotEmpty && !map.containsKey(fid)) {
        map[fid] = {
          'id': fid,
          'farmerId': fid,
          'name': _getFarmerName(p),
          'businessName': _getFarmerName(p),
          'address': p['location']?.toString() ?? 'Cambodia',
          'avatarUrl': pub is Map ? pub['avatarUrl'] : null,
          'orderCount': 0,
        };
      }
    }

    var list = map.values.toList();

    if (query.isNotEmpty) {
      list = list.where((f) {
        final name = f['name']?.toString().toLowerCase() ?? '';
        final bName = f['businessName']?.toString().toLowerCase() ?? '';
        final address = f['address']?.toString().toLowerCase() ?? '';
        return name.contains(query) || bName.contains(query) || address.contains(query);
      }).toList();
    }

    if (_selectedLocation != 'All') {
      list = list.where((f) {
        final address = f['address']?.toString().toLowerCase() ?? '';
        return address.contains(_selectedLocation.toLowerCase());
      }).toList();
    }

    return list;
  }

  double _toNumber(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0.0;

  void _addRecentSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 6) _recentSearches.removeLast();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _sortBy = 'relevance';
      _onlyAvailable = false;
      _selectedCondition = 'All';
      _selectedLocation = 'All';
      _maxMoq = null;
      _selectedCategory = 'All';
    });
  }

  // ==========================================================
  // COMPREHENSIVE B2B FILTER BOTTOM SHEET
  // ==========================================================

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 16,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter & Sort Produce',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setSheetState(() {
                        _sortBy = 'relevance';
                        _onlyAvailable = false;
                        _selectedCondition = 'All';
                        _selectedLocation = 'All';
                        _maxMoq = null;
                      });
                      setState(() {});
                    },
                    child: const Text(
                      'Reset All',
                      style: TextStyle(
                        color: accentOrange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 1),

              // Scrollable Filter Sections
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Sort Options
                      _buildFilterSectionTitle('SORT PRODUCE BY'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChoiceChip(
                            label: 'Relevance',
                            selected: _sortBy == 'relevance',
                            onSelected: (val) {
                              setSheetState(() => _sortBy = 'relevance');
                              setState(() {});
                            },
                          ),
                          _buildChoiceChip(
                            label: 'Newest Harvest',
                            selected: _sortBy == 'newest',
                            onSelected: (val) {
                              setSheetState(() => _sortBy = 'newest');
                              setState(() {});
                            },
                          ),
                          _buildChoiceChip(
                            label: 'Price: Low to High',
                            selected: _sortBy == 'price_low',
                            onSelected: (val) {
                              setSheetState(() => _sortBy = 'price_low');
                              setState(() {});
                            },
                          ),
                          _buildChoiceChip(
                            label: 'Price: High to Low',
                            selected: _sortBy == 'price_high',
                            onSelected: (val) {
                              setSheetState(() => _sortBy = 'price_high');
                              setState(() {});
                            },
                          ),
                          _buildChoiceChip(
                            label: 'Lowest MOQ',
                            selected: _sortBy == 'moq_low',
                            onSelected: (val) {
                              setSheetState(() => _sortBy = 'moq_low');
                              setState(() {});
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 2. Condition / Quality
                      _buildFilterSectionTitle('QUALITY & CERTIFICATION'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'All',
                          'Organic / GAP',
                          'Fresh Harvest',
                        ].map((cond) {
                          return _buildChoiceChip(
                            label: cond,
                            selected: _selectedCondition == cond,
                            onSelected: (val) {
                              setSheetState(() => _selectedCondition = cond);
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // 3. Farm Location / Province
                      _buildFilterSectionTitle('ORIGIN / PROVINCE'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _provinces.map((prov) {
                          return _buildChoiceChip(
                            label: prov,
                            selected: _selectedLocation == prov,
                            onSelected: (val) {
                              setSheetState(() => _selectedLocation = prov);
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // 4. Availability Switch
                      _buildFilterSectionTitle('AVAILABILITY'),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Ready in Stock Only',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                            ),
                          ),
                          subtitle: const Text(
                            'Hide out-of-stock items for immediate order dispatch',
                            style: TextStyle(fontSize: 12, color: textMuted),
                          ),
                          activeTrackColor: primaryGreen,
                          value: _onlyAvailable,
                          onChanged: (val) {
                            setSheetState(() => _onlyAvailable = val);
                            setState(() {});
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 5. Maximum Minimum Order (MOQ)
                      _buildFilterSectionTitle('MAXIMUM MINIMUM ORDER (MOQ)'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChoiceChip(
                            label: 'Any MOQ',
                            selected: _maxMoq == null,
                            onSelected: (val) {
                              setSheetState(() => _maxMoq = null);
                              setState(() {});
                            },
                          ),
                          _buildChoiceChip(
                            label: '≤ 5 kg',
                            selected: _maxMoq == 5,
                            onSelected: (val) {
                              setSheetState(() => _maxMoq = 5);
                              setState(() {});
                            },
                          ),
                          _buildChoiceChip(
                            label: '≤ 10 kg',
                            selected: _maxMoq == 10,
                            onSelected: (val) {
                              setSheetState(() => _maxMoq = 10);
                              setState(() {});
                            },
                          ),
                          _buildChoiceChip(
                            label: '≤ 25 kg',
                            selected: _maxMoq == 25,
                            onSelected: (val) {
                              setSheetState(() => _maxMoq = 25);
                              setState(() {});
                            },
                          ),
                          _buildChoiceChip(
                            label: '≤ 50 kg',
                            selected: _maxMoq == 50,
                            onSelected: (val) {
                              setSheetState(() => _maxMoq = 50);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Apply Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply Filters (${_filteredProducts.length} Results)',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: textMuted,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: primaryLight,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? primaryGreen : Colors.grey.shade300,
        width: selected ? 1.5 : 1,
      ),
      labelStyle: TextStyle(
        color: selected ? primaryGreen : textDark,
        fontSize: 12,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // ==========================================================
  // FORMATTING & HELPERS
  // ==========================================================

  String _formatPrice(dynamic value) {
    final price = _toNumber(value);
    return '\$${price.toStringAsFixed(2)}/kg';
  }

  String _formatQuantity(dynamic value) {
    final qty = _toNumber(value);
    if (qty <= 0) return '0 kg';
    if (qty % 1 == 0) return '${qty.toInt()} kg';
    return '${qty.toStringAsFixed(1)} kg';
  }

  String _getProductImage(Map<String, dynamic> product) {
    final images = product['imageUrls'];
    if (images is List && images.isNotEmpty) {
      final image = images.first.toString().trim();
      if (image.isNotEmpty) {
        return ApiConstants.imageUrl(image);
      }
    }
    return '';
  }

  String _getFarmerName(Map<String, dynamic> product) {
    final publisher = product['publisher'];
    if (publisher is Map && publisher['name'] != null) {
      final name = publisher['name'].toString().trim();
      if (name.isNotEmpty) return name;
    }
    return product['farmerName']?.toString() ??
        product['farmName']?.toString() ??
        product['farmer']?['name']?.toString() ??
        'Local Farmer';
  }

  // ==========================================================
  // ACTIONS: CART & FAVORITES
  // ==========================================================

  Future<void> _toggleFavorite(String productId) async {
    if (productId.isEmpty) return;

    final wasFav = _favoriteIds.contains(productId);
    setState(() {
      if (wasFav) {
        _favoriteIds.remove(productId);
      } else {
        _favoriteIds.add(productId);
      }
    });

    try {
      final isFav = await FavoritesService.toggleFavorite(productId);
      if (!mounted) return;
      setState(() {
        if (isFav) {
          _favoriteIds.add(productId);
        } else {
          _favoriteIds.remove(productId);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (wasFav) {
          _favoriteIds.add(productId);
        } else {
          _favoriteIds.remove(productId);
        }
      });
    }
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    final pid = product['id']?.toString() ?? '';
    if (pid.isEmpty) return;

    final minOrder = _toNumber(product['minOrder']);
    final orderQty = minOrder > 0 ? minOrder : 1.0;

    setState(() => _addingProductId = pid);

    try {
      await _cartService.addToCart(
        productId: pid,
        quantity: orderQty,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Added ${product['name']} to cart',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.amberAccent,
            onPressed: () => context.push(AppRoutes.restaurantCart),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to cart: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _addingProductId = null);
    }
  }

  // ==========================================================
  // MAIN BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final bool isSearching = _searchController.text.trim().isNotEmpty ||
        _selectedCategory != 'All' ||
        _activeFilterCount > 0;

    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryGreen,
          onRefresh: _loadInitialData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Search Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: _buildSearchBar(),
                ),
              ),

              // Active Filters Row (if any applied)
              if (_activeFilterCount > 0 || _selectedCategory != 'All')
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildActiveFilterChipsRow(),
                  ),
                ),

              // If NOT searching: Show Recent, Trends & Categories
              if (!isSearching) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildRecentSearchesSection(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildPopularSearchesSection(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildCategoriesSection(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
              ],

              // Tab Switcher: All / Products / Farmers
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _buildTabSwitcher(),
                ),
              ),

              // Results Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: _buildResultHeader(),
                ),
              ),

              // Content Sliver
              _buildContentSliver(),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SEARCH BAR & HEADER
  // ==========================================================

  Widget _buildSearchBar() {
    final canPop = context.canPop();

    return Row(
      children: [
        if (canPop) ...[
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: textDark, size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],

        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: primaryGreen, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: _addRecentSearch,
                    style: const TextStyle(fontSize: 14, color: textDark),
                    decoration: const InputDecoration(
                      hintText: 'Search products, farms, or locations...',
                      hintStyle: TextStyle(fontSize: 13, color: textMuted),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.cancel_rounded, color: Colors.grey.shade400, size: 18),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Filter Button with Badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: _showFilters,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _activeFilterCount > 0 ? primaryGreen : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _activeFilterCount > 0 ? primaryGreen : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: _activeFilterCount > 0 ? Colors.white : primaryGreen,
                  size: 21,
                ),
              ),
            ),
            if (_activeFilterCount > 0)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: accentOrange,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    '$_activeFilterCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // ACTIVE FILTER CHIPS ROW
  // ==========================================================

  Widget _buildActiveFilterChipsRow() {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (_selectedCategory != 'All')
            _buildActivePill('Category: $_selectedCategory', () {
              setState(() => _selectedCategory = 'All');
            }),
          if (_sortBy != 'relevance')
            _buildActivePill('Sort: $_sortBy', () {
              setState(() => _sortBy = 'relevance');
            }),
          if (_onlyAvailable)
            _buildActivePill('In Stock', () {
              setState(() => _onlyAvailable = false);
            }),
          if (_selectedCondition != 'All')
            _buildActivePill(_selectedCondition, () {
              setState(() => _selectedCondition = 'All');
            }),
          if (_selectedLocation != 'All')
            _buildActivePill(_selectedLocation, () {
              setState(() => _selectedLocation = 'All');
            }),
          if (_maxMoq != null)
            _buildActivePill('MOQ ≤ ${_maxMoq!.toInt()}kg', () {
              setState(() => _maxMoq = null);
            }),
          GestureDetector(
            onTap: _clearAllFilters,
            child: Container(
              margin: const EdgeInsets.only(left: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePill(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
      decoration: BoxDecoration(
        color: primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: primaryGreen,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 14, color: primaryGreen),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DISCOVERY SECTIONS (RECENT, POPULAR, CATEGORIES)
  // ==========================================================

  Widget _buildRecentSearchesSection() {
    if (_recentSearches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
            GestureDetector(
              onTap: () => setState(_recentSearches.clear),
              child: const Text(
                'Clear',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _recentSearches.map((search) {
            return GestureDetector(
              onTap: () {
                _searchController.text = search;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history_rounded, size: 14, color: textMuted),
                    const SizedBox(width: 5),
                    Text(
                      search,
                      style: const TextStyle(fontSize: 12, color: textDark),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPopularSearchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Searches',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularKeywords.map((kw) {
            return GestureDetector(
              onTap: () => setState(() => _searchController.text = kw),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  kw,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryGreen,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Browse Categories',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
            if (_selectedCategory != 'All')
              GestureDetector(
                onTap: () => setState(() => _selectedCategory = 'All'),
                child: const Text(
                  'Show All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: primaryGreen,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final name = cat['name'] as String;
              final icon = cat['icon'] as IconData;
              final isSelected = _selectedCategory == name;

              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = name),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? primaryGreen : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 15,
                        color: isSelected ? Colors.white : primaryGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.white : textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // TAB SWITCHER
  // ==========================================================

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'All'),
          _buildTabItem(1, 'Products (${_filteredProducts.length})'),
          _buildTabItem(2, 'Farmers (${_filteredFarmers.length})'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : textMuted,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // RESULTS HEADER
  // ==========================================================

  Widget _buildResultHeader() {
    final count = _selectedTabIndex == 2
        ? _filteredFarmers.length
        : _filteredProducts.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$count items found',
          style: const TextStyle(
            fontSize: 13,
            color: textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Grid / List Toggle (when viewing products)
        if (_selectedTabIndex != 2)
          Row(
            children: [
              GestureDetector(
                onTap: _showFilters,
                child: Row(
                  children: [
                    const Icon(Icons.sort_rounded, size: 14, color: primaryGreen),
                    const SizedBox(width: 4),
                    Text(
                      'Sort: ${_getSortLabel()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!_isGridView) setState(() => _isGridView = true);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: _isGridView ? primaryLight : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.grid_view_rounded,
                          size: 16,
                          color: _isGridView ? primaryGreen : textMuted,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_isGridView) setState(() => _isGridView = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: !_isGridView ? primaryLight : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.view_agenda_outlined,
                          size: 16,
                          color: !_isGridView ? primaryGreen : textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'price_low':
        return 'Price ↑';
      case 'price_high':
        return 'Price ↓';
      case 'newest':
        return 'Newest';
      case 'moq_low':
        return 'Low MOQ';
      case 'relevance':
      default:
        return 'Relevance';
    }
  }

  // ==========================================================
  // MAIN CONTENT SLIVER
  // ==========================================================

  Widget _buildContentSliver() {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: CircularProgressIndicator(color: primaryGreen),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return SliverToBoxAdapter(
        child: _buildErrorState(),
      );
    }

    // 1. Farmers Tab
    if (_selectedTabIndex == 2) {
      final farmers = _filteredFarmers;
      if (farmers.isEmpty) {
        return SliverToBoxAdapter(child: _buildEmptyState('No farmers found'));
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildFarmerDirectoryCard(farmers[index]),
            childCount: farmers.length,
          ),
        ),
      );
    }

    // 2. All or Products Tab
    final products = _filteredProducts;

    if (products.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState('No produce found'));
    }

    // Grid View
    if (_isGridView) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.64,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildGridProductCard(products[index]),
            childCount: products.length,
          ),
        ),
      );
    }

    // List View
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            final pid = product['id']?.toString() ?? '';
            final isFav = _favoriteIds.contains(pid);

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ProductCard(
                imageUrl: _getProductImage(product),
                productName: product['name']?.toString() ?? 'Produce',
                farmName: _getFarmerName(product),
                price: _formatPrice(product['price']),
                location: product['location']?.toString() ?? 'Cambodia',
                availableQuantity: _formatQuantity(product['quantity']),
                isAvailable: product['isAvailable'] ?? true,
                isFavorite: isFav,
                minOrder: product['minOrder'] != null
                    ? '${product['minOrder']} kg'
                    : null,
                condition: product['condition']?.toString(),
                onTap: () {
                  context.push(
                    AppRoutes.productDetail,
                    extra: product,
                  ).then((_) async {
                    final favIds = await FavoritesService.getFavoriteIds();
                    if (mounted) setState(() => _favoriteIds = favIds.toSet());
                  });
                },
                onFavoritePressed: () => _toggleFavorite(pid),
                onAddToCart: () => _addToCart(product),
              ),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  // ==========================================================
  // PRODUCT & FARMER CARDS
  // ==========================================================

  Widget _buildGridProductCard(Map<String, dynamic> product) {
    final pid = product['id']?.toString() ?? '';
    final name = product['name']?.toString() ?? 'Product';
    final farmerName = _getFarmerName(product);
    final location = product['location']?.toString() ?? 'Cambodia';
    final priceStr = _formatPrice(product['price']);
    final isAvail = product['isAvailable'] ?? true;
    final isFav = _favoriteIds.contains(pid);
    final imageUrl = _getProductImage(product);
    final minOrder = _toNumber(product['minOrder']);
    final condition = product['condition']?.toString() ?? '';
    final isAdding = _addingProductId == pid;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push(
              AppRoutes.productDetail,
              extra: product,
            ).then((_) async {
              final favIds = await FavoritesService.getFavoriteIds();
              if (mounted) setState(() => _favoriteIds = favIds.toSet());
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Stack
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SizedBox(
                      height: 130,
                      width: double.infinity,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholderImage(),
                            )
                          : _buildPlaceholderImage(),
                    ),
                  ),

                  // Condition Badge
                  if (condition.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: condition.toLowerCase().contains('organic')
                              ? primaryGreen
                              : Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          condition,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(pid),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isFav ? Colors.redAccent : textMuted,
                        ),
                      ),
                    ),
                  ),

                  // MOQ Badge
                  if (minOrder > 0)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'MOQ: ${minOrder.toInt()}kg',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Product Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.storefront_outlined, size: 12, color: primaryGreen),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              farmerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 11, color: textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10, color: textMuted),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              priceStr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: primaryGreen,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (!isAvail || isAdding) ? null : () => _addToCart(product),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isAvail ? primaryGreen : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: isAdding
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      isAvail
                                          ? Icons.add_shopping_cart_rounded
                                          : Icons.block_rounded,
                                      size: 16,
                                      color: isAvail ? Colors.white : Colors.grey.shade600,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFarmerDirectoryCard(Map<String, dynamic> farmer) {
    final fid = farmer['id']?.toString() ?? farmer['farmerId']?.toString() ?? '';
    final name = farmer['name']?.toString() ?? 'Farmer';
    final farmName = farmer['businessName']?.toString() ?? name;
    final location = farmer['address']?.toString() ?? 'Cambodia';
    final ordersCount = farmer['orderCount'] ?? 0;
    final avatar = farmer['avatarUrl']?.toString();
    final imageUrl = avatar != null && avatar.isNotEmpty
        ? ApiConstants.imageUrl(avatar)
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (fid.isNotEmpty) {
              context.push(
                AppRoutes.restaurantFarmerProfile,
                extra: farmer,
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: primaryLight,
                      backgroundImage:
                          imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.agriculture_rounded,
                              color: primaryGreen, size: 28)
                          : null,
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(Icons.verified_rounded, color: primaryGreen, size: 16),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: textMuted),
                          const SizedBox(width: 3),
                          Text(
                            location,
                            style: const TextStyle(fontSize: 12, color: textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        ordersCount > 0 ? '$ordersCount completed orders' : 'Verified Producer',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, color: primaryGreen, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(Icons.eco_rounded, size: 40, color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildEmptyState(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 42, color: primaryGreen),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textDark),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search query, location, or reset filters.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _clearAllFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reset All Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'Unable to load market items',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            child: const Text('Try Again', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
