import 'package:flutter/material.dart';

import 'package:mobile/features/farmer/screens/notifications_screen.dart';
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
  static const Color primaryColor = Color(0xFF1E5631);
  static const Color backgroundColor = Color(0xFFF7F6E8);

  int _selectedFilterIndex = 0;

  final List<String> _filters = [
    'All Items',
    'Vegetables',
    'Microgreens',
  ];

  final TextEditingController _searchController =
      TextEditingController();

  List<Map<String, dynamic>> _products = [];

  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

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
  // FILTER + SEARCH
  // ============================================================

  List<Map<String, dynamic>> get _filteredProducts {
    return _products.where((product) {
      // Search
      final name =
          product['name']?.toString().toLowerCase() ?? '';

      final category =
          product['category']?.toString().toLowerCase() ?? '';

      final matchesSearch =
          name.contains(_searchQuery.toLowerCase()) ||
          category.contains(_searchQuery.toLowerCase());

      if (!matchesSearch) {
        return false;
      }

      // Category filter
      if (_selectedFilterIndex == 0) {
        return true;
      }

      final selectedCategory =
          _filters[_selectedFilterIndex].toLowerCase();

      return category == selectedCategory;
    }).toList();
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  int get _activeProducts {
    return _products.where((product) {
      return product['isAvailable'] == true;
    }).length;
  }

  int get _lowStockProducts {
    return _products.where((product) {
      final quantity = _toDouble(product['quantity']);

      return quantity > 0 && quantity <= 20;
    }).length;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: FarmerAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const NotificationsScreen(),
                ),
              );
            },
          ),

          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage:
                  AssetImage('assets/profile.png'),
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              const Text(
                'My Products',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Manage the products you have listed for restaurants.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 16),

              _buildSummaryCards(),

              const SizedBox(height: 16),

              _buildSearchBar(),

              const SizedBox(height: 14),

              _buildFilters(),

              const SizedBox(height: 16),

              _buildProductContent(),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddProductFlowScreen(),
            ),
          );

          if (!mounted) return;

          await _loadProducts();
        },
        backgroundColor:
            const Color(0xFFB86A04),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(30),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: const Text(
          'Add Product',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      bottomNavigationBar:
          const FarmerBottomNavBar(
        currentIndex: 2,
      ),
    );
  }

  // ============================================================
  // SUMMARY CARDS
  // ============================================================

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'ACTIVE PRODUCTS',
            value: _activeProducts.toString(),
            valueColor: primaryColor,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildSummaryCard(
            title: 'LOW STOCK',
            value: _lowStockProducts.toString(),
            valueColor:
                const Color(0xFFB71C1C),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBar() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Colors.grey[600],
            size: 20,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration:
                  InputDecoration(
                hintText:
                    'Search your products...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                border:
                    InputBorder.none,
              ),
            ),
          ),

          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.clear,
                size: 18,
              ),
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

  Widget _buildFilters() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder:
            (_, _) =>
                const SizedBox(width: 8),
        itemBuilder:
            (context, index) {
          final isSelected =
              _selectedFilterIndex ==
                  index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex =
                    index;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration:
                  BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : Colors.grey[200],
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child: Text(
                _filters[index],
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.grey[800],
                  fontWeight:
                      FontWeight.w600,
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

  Widget _buildProductContent() {
    if (_isLoading) {
      return const Padding(
        padding:
            EdgeInsets.only(top: 80),
        child: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    final products =
        _filteredProducts;

    if (products.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: products.map((product) {
        final id = product['id']?.toString();

        return FarmerProductCard(
          product: product,

          // View details
          onTap: () {
            if (id == null) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    FarmerProductDetailScreen(
                  product: product,
                ),
              ),
            );
          },

          // Edit
          onEdit: () async {
            if (id == null) return;

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EditProductScreen(
                  product: product,
                ),
              ),
            );

            if (!mounted) return;

            await _loadProducts();
          },

          // Delete
          onDelete: () {
            _confirmDelete(product);
          },

          // Available toggle
          onAvailabilityChanged: (value) {
            _toggleAvailability(
              product,
              value,
            );
          },
        );
      }).toList(),
    );
  }



  // ============================================================
  // TOGGLE AVAILABLE
  // ============================================================

  Future<void> _toggleAvailability(
    Map<String, dynamic> product,
    bool value,
  ) async {
    final id =
        product['id']?.toString();

    if (id == null) return;

    try {
      await ProductService
          .updateProduct(
        productId: id,
        data: {
          'isAvailable': value,
        },
      );

      if (!mounted) return;

      setState(() {
        product['isAvailable'] =
            value;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Product is now available'
                : 'Product is now unavailable',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update product: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _confirmDelete(
    Map<String, dynamic> product,
  ) async {
    final id =
        product['id']?.toString();

    if (id == null) return;

    final name =
        product['name']?.toString() ??
            'this product';

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Product?',
          ),
          content: Text(
            'Are you sure you want to delete "$name"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ProductService.deleteProduct(
        productId: id,
      );

      if (!mounted) return;

      setState(() {
        _products.removeWhere(
          (item) =>
              item['id']?.toString() == id,
        );
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Product deleted successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete product: $e',
          ),
        ),
      );
    }
  }
  
  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 80,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons
                  .inventory_2_outlined,
              size: 70,
              color: Colors.grey[400],
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              'No products listed yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              'Add your first product to start selling to restaurants.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AddProductFlowScreen(),
                  ),
                );

                if (!mounted) return;

                await _loadProducts();
              },
              icon:
                  const Icon(Icons.add),
              label: const Text(
                'Add Product',
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryColor,
                foregroundColor:
                    Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorState() {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 60,
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),

            const SizedBox(
              height: 12,
            ),

            const Text(
              'Unable to load products',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              _error ?? 'Unknown error',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            ElevatedButton(
              onPressed:
                  _loadProducts,
              child: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// EDIT PRODUCT DIALOG
// ================================================================

class _EditProductDialog extends StatefulWidget {
  final Map<String, dynamic> product;

  final Future<void> Function({
    required String name,
    required double price,
    required double quantity,
    required String description,
  }) onSave;

  const _EditProductDialog({
    required this.product,
    required this.onSave,
  });

  @override
  State<_EditProductDialog> createState() =>
      _EditProductDialogState();
}

class _EditProductDialogState
    extends State<_EditProductDialog> {
  late final TextEditingController
      _nameController;

  late final TextEditingController
      _priceController;

  late final TextEditingController
      _quantityController;

  late final TextEditingController
      _descriptionController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(
      text:
          widget.product['name']
                  ?.toString() ??
              '',
    );

    _priceController =
        TextEditingController(
      text:
          widget.product['price']
                  ?.toString() ??
              '',
    );

    _quantityController =
        TextEditingController(
      text:
          widget.product['quantity']
                  ?.toString() ??
              '',
    );

    _descriptionController =
        TextEditingController(
      text:
          widget.product['description']
                  ?.toString() ??
              '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    final name =
        _nameController.text.trim();

    final price = double.tryParse(
      _priceController.text.trim(),
    );

    final quantity = double.tryParse(
      _quantityController.text.trim(),
    );

    final description =
        _descriptionController.text.trim();

    if (name.isEmpty ||
        price == null ||
        quantity == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid product information.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(
        name: name,
        price: price,
        quantity: quantity,
        description: description,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update product: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          const Text('Edit Product'),

      content:
          SingleChildScrollView(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            TextField(
              controller:
                  _nameController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Product Name',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            TextField(
              controller:
                  _priceController,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),
              decoration:
                  const InputDecoration(
                labelText: 'Price',
                prefixText: '\$ ',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            TextField(
              controller:
                  _quantityController,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),
              decoration:
                  const InputDecoration(
                labelText:
                    'Quantity',
                suffixText: ' kg',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            TextField(
              controller:
                  _descriptionController,
              maxLines: 3,
              decoration:
                  const InputDecoration(
                labelText:
                    'Description',
                border:
                    OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.pop(
                    context,
                    false,
                  );
                },
          child:
              const Text('Cancel'),
        ),

        ElevatedButton(
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                _InventoryScreenState
                    .primaryColor,
            foregroundColor:
                Colors.white,
          ),
          onPressed:
              _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                        Colors.white,
                  ),
                )
              : const Text(
                  'Save Changes',
                ),
        ),
      ],
    );
  }
}