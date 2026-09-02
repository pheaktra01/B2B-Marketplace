import 'package:flutter/material.dart';

import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/farmer/widgets/edit_product_screen.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/farmer/widgets/farmer_bottom_nav_bar.dart';
import 'package:mobile/features/farmer/widgets/farmer_product_card.dart';
import 'package:mobile/features/farmer/widgets/farmer_product_detail_screen.dart';
import 'package:mobile/features/product/screens/add_product_screen.dart';
import 'package:mobile/features/product/services/product_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFF1E5631);
  static const Color accentOrange = Color(0xFFB86A04);
  static const Color backgroundColor = Color(0xFFF7F6E8);

  // ============================================================
  // FILTER
  // ============================================================

  int _selectedFilterIndex = 0;

  // ============================================================
  // SEARCH
  // ============================================================

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  // ============================================================
  // PRODUCTS
  // ============================================================

  List<Map<String, dynamic>> _products = [];

  bool _isLoading = true;
  String? _error;

  // ============================================================
  // INIT / DISPOSE
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD PRODUCTS
  // ============================================================

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final products = await ProductService.getMyProducts();

      final convertedProducts = products
          .map<Map<String, dynamic>>(
            (product) => Map<String, dynamic>.from(product),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _products = convertedProducts;
        _isLoading = false;
      });

      debugPrint('========== INVENTORY PRODUCTS ==========');
      debugPrint('Total products: ${_products.length}');
      debugPrint('Products: $_products');
      debugPrint('========================================');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });

      debugPrint('Inventory error: $e');
    }
  }

  // ============================================================
  // VALUE HELPERS
  // ============================================================

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString().trim()) ?? 0;
  }

  bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final stringValue = value?.toString().trim().toLowerCase();

    return stringValue == 'true' || stringValue == '1' || stringValue == 'yes';
  }

  String _productCategory(Map<String, dynamic> product) {
    return product['category']?.toString().trim().toLowerCase() ?? '';
  }

  double _productQuantity(Map<String, dynamic> product) {
    return _toDouble(product['quantity']);
  }

  bool _productIsAvailable(Map<String, dynamic> product) {
    return _toBool(product['isAvailable']);
  }

  bool _isLowStock(Map<String, dynamic> product) {
    final quantity = _productQuantity(product);

    return quantity > 0 && quantity <= 20;
  }

  bool _isOutOfStock(Map<String, dynamic> product) {
    final quantity = _productQuantity(product);

    return quantity <= 0;
  }

  // ============================================================
  // LOCALIZED FILTERS
  // ============================================================

  List<String> _getFilters(AppLocalizations l10n) {
    return [
      l10n.allItems,
      l10n.vegetables,
      l10n.microgreens,
      l10n.lowStock,
      l10n.outOfStock,
    ];
  }

  // ============================================================
  // FILTER + SEARCH
  // ============================================================

  List<Map<String, dynamic>> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();

    return _products.where((product) {
      final name = product['name']?.toString().trim().toLowerCase() ?? '';

      final category = _productCategory(product);

      final description =
          product['description']?.toString().trim().toLowerCase() ?? '';

      final matchesSearch =
          query.isEmpty ||
          name.contains(query) ||
          category.contains(query) ||
          description.contains(query);

      if (!matchesSearch) {
        return false;
      }

      switch (_selectedFilterIndex) {
        case 0:
          // All Items
          return true;

        case 1:
          // Vegetables
          return category == 'vegetables';

        case 2:
          // Microgreens
          return category == 'microgreens';

        case 3:
          // Low Stock
          return _isLowStock(product);

        case 4:
          // Out of Stock
          return _isOutOfStock(product);

        default:
          return true;
      }
    }).toList();
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  int get _activeProducts {
    return _products.where((product) {
      return _productIsAvailable(product) && !_isOutOfStock(product);
    }).length;
  }

  int get _lowStockProducts {
    return _products.where((product) {
      return _isLowStock(product);
    }).length;
  }

  int get _outOfStockProducts {
    return _products.where((product) {
      return _isOutOfStock(product);
    }).length;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filters = _getFilters(l10n);

    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: const FarmerAppBar(),

      // ========================================================
      // BODY
      // ========================================================
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ==================================================
              // TITLE
              // ==================================================
              Text(
                l10n.myProducts,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                l10n.manageProductsDescription,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // SUMMARY
              // ==================================================
              _buildSummaryCards(l10n),

              const SizedBox(height: 16),

              // ==================================================
              // SEARCH
              // ==================================================
              _buildSearchBar(l10n),

              const SizedBox(height: 14),

              // ==================================================
              // FILTERS
              // ==================================================
              _buildFilters(filters),

              const SizedBox(height: 16),

              // ==================================================
              // PRODUCTS
              // ==================================================
              _buildProductContent(l10n),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // ========================================================
      // ADD PRODUCT
      // ========================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddProduct,
        backgroundColor: accentOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.addProduct,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================
      bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 2),
    );
  }

  // ============================================================
  // SUMMARY CARDS
  // ============================================================

  Widget _buildSummaryCards(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: l10n.activeProducts,
                value: _activeProducts.toString(),
                valueColor: primaryColor,
                icon: Icons.check_circle_outline,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildSummaryCard(
                title: l10n.lowStock,
                value: _lowStockProducts.toString(),
                valueColor: const Color(0xFFB71C1C),
                icon: Icons.warning_amber_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: l10n.outOfStock,
                value: _outOfStockProducts.toString(),
                valueColor: Colors.red.shade700,
                icon: Icons.inventory_2_outlined,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildSummaryCard(
                title: l10n.totalProducts,
                value: _products.length.toString(),
                valueColor: Colors.black87,
                icon: Icons.grid_view_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: valueColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: valueColor),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.4,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600], size: 20),

          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchYourProducts,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          if (_searchQuery.isNotEmpty)
            IconButton(
              tooltip: l10n.clearSearch,
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                _searchController.clear();

                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters(List<String> filters) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[800],
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // PRODUCT CONTENT
  // ============================================================

  Widget _buildProductContent(AppLocalizations l10n) {
    // ----------------------------------------------------------
    // LOADING
    // ----------------------------------------------------------

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    // ----------------------------------------------------------
    // ERROR
    // ----------------------------------------------------------

    if (_error != null) {
      return _buildErrorState(l10n);
    }

    // ----------------------------------------------------------
    // FILTERED PRODUCTS
    // ----------------------------------------------------------

    final products = _filteredProducts;

    // ----------------------------------------------------------
    // EMPTY
    // ----------------------------------------------------------

    if (products.isEmpty) {
      return _buildEmptyState(l10n);
    }

    // ----------------------------------------------------------
    // LIST
    // ----------------------------------------------------------

    return Column(
      children: products.map((product) {
        final id = product['id']?.toString();

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: FarmerProductCard(
            product: product,

            // ==================================================
            // VIEW DETAILS
            // ==================================================
            onTap: () async {
              if (id == null) {
                return;
              }

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FarmerProductDetailScreen(product: product),
                ),
              );

              if (!mounted) {
                return;
              }

              await _loadProducts();
            },

            // ==================================================
            // EDIT
            // ==================================================
            onEdit: () async {
              if (id == null) {
                return;
              }

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProductScreen(product: product),
                ),
              );

              if (!mounted) {
                return;
              }

              await _loadProducts();
            },

            // ==================================================
            // DELETE
            // ==================================================
            onDelete: () {
              _confirmDelete(product, l10n);
            },

            // ==================================================
            // AVAILABILITY
            // ==================================================
            onAvailabilityChanged: (value) {
              _toggleAvailability(product, value, l10n);
            },
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // ADD PRODUCT
  // ============================================================

  Future<void> _openAddProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddProductFlowScreen()),
    );

    if (!mounted) {
      return;
    }

    await _loadProducts();
  }

  // ============================================================
  // TOGGLE AVAILABILITY
  // ============================================================

  Future<void> _toggleAvailability(
    Map<String, dynamic> product,
    bool value,
    AppLocalizations l10n,
  ) async {
    final id = product['id']?.toString();

    if (id == null || id.isEmpty) {
      return;
    }

    final oldValue = _productIsAvailable(product);

    // ----------------------------------------------------------
    // OPTIMISTIC UPDATE
    // ----------------------------------------------------------

    setState(() {
      product['isAvailable'] = value;
    });

    try {
      await ProductService.updateProduct(
        productId: id,
        data: {'isAvailable': value},
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            value ? l10n.productIsNowAvailable : l10n.productIsNowUnavailable,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      // --------------------------------------------------------
      // ROLLBACK
      // --------------------------------------------------------

      setState(() {
        product['isAvailable'] = oldValue;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          content: Text('Failed to update availability: $e'),
        ),
      );
    }
  }

  // ============================================================
  // DELETE PRODUCT
  // ============================================================

  Future<void> _confirmDelete(
    Map<String, dynamic> product,
    AppLocalizations l10n,
  ) async {
    final id = product['id']?.toString();

    if (id == null || id.isEmpty) {
      return;
    }

    final name = product['name']?.toString().trim().isNotEmpty == true
        ? product['name'].toString().trim()
        : 'this product';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          // ----------------------------------------------------
          // TITLE
          // ----------------------------------------------------
          title: Text(
            l10n.deleteProduct,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          // ----------------------------------------------------
          // CONFIRMATION
          // ----------------------------------------------------
          content: Text(l10n.deleteProductConfirmation(name)),

          // ----------------------------------------------------
          // ACTIONS
          // ----------------------------------------------------
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(l10n.cancel),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    // ----------------------------------------------------------
    // DELETE FROM BACKEND
    // ----------------------------------------------------------

    try {
      await ProductService.deleteProduct(productId: id);

      if (!mounted) {
        return;
      }

      setState(() {
        _products.removeWhere((item) => item['id']?.toString() == id);
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.productDeletedSuccessfully),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          content: Text('Failed to delete product: $e'),
        ),
      );
    }
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(AppLocalizations l10n) {
    final hasFilters = _searchQuery.isNotEmpty || _selectedFilterIndex != 0;

    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters ? Icons.search_off : Icons.inventory_2_outlined,
                size: 45,
                color: primaryColor.withValues(alpha: 0.65),
              ),
            ),

            const SizedBox(height: 18),

            // --------------------------------------------------
            // EMPTY TITLE
            // --------------------------------------------------
            Text(
              hasFilters ? l10n.noMatchingProducts : l10n.noProductsListedYet,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            // --------------------------------------------------
            // EMPTY DESCRIPTION
            // --------------------------------------------------
            Text(
              hasFilters
                  ? l10n.tryChangingSearchFilter
                  : l10n.addFirstProductDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),

            const SizedBox(height: 20),

            // --------------------------------------------------
            // CLEAR FILTERS
            // --------------------------------------------------
            if (hasFilters)
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();

                  setState(() {
                    _searchQuery = '';
                    _selectedFilterIndex = 0;
                  });
                },
                icon: const Icon(Icons.clear),
                label: Text(l10n.clearFilters),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: const BorderSide(color: primaryColor),
                ),
              )
            // --------------------------------------------------
            // ADD PRODUCT
            // --------------------------------------------------
            else
              ElevatedButton.icon(
                onPressed: _openAddProduct,
                icon: const Icon(Icons.add),
                label: Text(l10n.addProduct),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 45,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 16),

            // --------------------------------------------------
            // ERROR TITLE
            // --------------------------------------------------
            Text(
              l10n.unableToLoadProducts,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // --------------------------------------------------
            // ERROR MESSAGE
            // --------------------------------------------------
            Text(
              _error ?? l10n.unknownErrorOccurred,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),

            const SizedBox(height: 18),

            // --------------------------------------------------
            // TRY AGAIN
            // --------------------------------------------------
            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
