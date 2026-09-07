import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/order/models/order_model.dart';
import 'package:mobile/features/order/services/order_service.dart';
import 'package:mobile/features/product/services/product_service.dart';
import 'package:mobile/features/profile/services/user_service.dart';
import 'package:mobile/l10n/app_localizations.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  // ---------------------------------------------------------------------------
  // THEME COLORS
  // ---------------------------------------------------------------------------

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreenBg = Color(0xFFE8F5E9);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color cardBgColor = Colors.white;
  static const Color textDark = Color(0xFF1E1E1E);

  // ---------------------------------------------------------------------------
  // SERVICES & STATE
  // ---------------------------------------------------------------------------

  final UserService _userService = UserService();
  final OrderService _orderService = OrderService();

  bool _isLoading = true;
  String? _error;
  String _farmerName = '';
  List<Map<String, dynamic>> _myProducts = [];
  List<OrderModel> _farmerOrders = [];
  List<Map<String, dynamic>> _marketProducts = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _userService.getProfile().catchError((_) => <String, dynamic>{}),
        ProductService.getMyProducts().catchError((_) => <Map<String, dynamic>>[]),
        _orderService.getFarmerOrders().catchError((_) => <OrderModel>[]),
        ProductService.getAllProducts().catchError((_) => <dynamic>[]),
      ]);

      if (!mounted) return;

      final profileRes = results[0] as Map<String, dynamic>;
      final productsRes = results[1] as List<Map<String, dynamic>>;
      final ordersRes = results[2] as List<OrderModel>;
      final allProductsRes = results[3] as List<dynamic>;

      String name = '';
      if (profileRes['data'] != null && profileRes['data'] is Map) {
        name = profileRes['data']['name']?.toString() ?? '';
      } else if (profileRes['name'] != null) {
        name = profileRes['name'].toString();
      }

      setState(() {
        _farmerName = name;
        _myProducts = productsRes;
        _farmerOrders = ordersRes;
        _marketProducts = allProductsRes
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),

      // -----------------------------------------------------------------------
      // APP BAR
      // -----------------------------------------------------------------------
      appBar: const FarmerAppBar(),

      // -----------------------------------------------------------------------
      // FLOATING ACTION BUTTON
      // -----------------------------------------------------------------------
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(AppRoutes.farmerAddProduct);
          _loadDashboardData();
        },
        backgroundColor: accentOrange,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: Text(
          l10n.addProduct,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // BOTTOM NAVIGATION
      // -----------------------------------------------------------------------
      bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 0),

      // -----------------------------------------------------------------------
      // BODY
      // -----------------------------------------------------------------------
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: LinearProgressIndicator(
                          color: primaryGreen,
                          backgroundColor: lightGreenBg,
                        ),
                      ),
                    if (_error != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.red),
                              onPressed: _loadDashboardData,
                            ),
                          ],
                        ),
                      ),

                    // 1. Header Greeting
                    _buildHeaderGreeting(l10n),
                    const SizedBox(height: 20),

                    // 2. Summary Cards
                    _buildSummaryCards(l10n),
                    const SizedBox(height: 24),

                    // 3. Quick Actions
                    _buildQuickActions(context, l10n),
                    const SizedBox(height: 24),

                    // 4. Inventory Alerts
                    _buildInventoryAlerts(l10n),
                    const SizedBox(height: 24),

                    // 5. Market Opportunities
                    _buildMarketOpportunities(l10n),
                    const SizedBox(height: 24),

                    // 6. Sales Overview
                    _buildSalesOverviewChart(l10n),
                    const SizedBox(height: 24),

                    // 7. Active Orders
                    _buildActiveOrdersSection(l10n),
                    const SizedBox(height: 24),

                    // 8. My Products
                    _buildMyProductsSection(l10n),

                    // Space for FAB
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. HEADER GREETING
  // ===========================================================================

  Widget _buildHeaderGreeting(AppLocalizations l10n) {
    final displayName = _farmerName.isNotEmpty ? _farmerName : 'Farmer';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.goodMorning(displayName),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textDark,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  // ===========================================================================
  // 2. SUMMARY CARDS
  // ===========================================================================

  Widget _buildSummaryCards(AppLocalizations l10n) {
    // Calculate total sales from valid orders
    double totalSales = 0;
    int activeOrdersCount = 0;

    for (final order in _farmerOrders) {
      final s = order.status.toLowerCase();
      if (s != 'cancelled') {
        totalSales += order.total;
      }
      if (s == 'pending' || s == 'confirmed' || s == 'processing' || s == 'shipped') {
        activeOrdersCount++;
      }
    }

    // Low stock count
    int lowStockCount = 0;
    for (final p in _myProducts) {
      final qty = double.tryParse(p['quantity']?.toString() ?? '0') ?? 0;
      if (qty <= 15) lowStockCount++;
    }

    final List<Map<String, dynamic>> stats = [
      {
        'title': l10n.totalSales,
        'value': '\$${totalSales.toStringAsFixed(0)}',
        'icon': Icons.attach_money_rounded,
        'color': primaryGreen,
        'bg': const Color(0xFFE8F5E9),
      },
      {
        'title': l10n.activeOrders,
        'value': activeOrdersCount.toString(),
        'icon': Icons.shopping_bag_outlined,
        'color': const Color(0xFF0288D1),
        'bg': const Color(0xFFE1F5FE),
      },
      {
        'title': l10n.productsListed,
        'value': _myProducts.length.toString(),
        'icon': Icons.inventory_2_outlined,
        'color': const Color(0xFF7B1FA2),
        'bg': const Color(0xFFF3E5F5),
      },
      {
        'title': 'Low Stock Alert',
        'value': '$lowStockCount items',
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFE65100),
        'bg': const Color(0xFFFFE0B2),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final item = stats[index];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: item['bg'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      size: 18,
                      color: item['color'] as Color,
                    ),
                  ),
                ],
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  item['value'] as String,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: item['color'] as Color,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 3. QUICK ACTIONS
  // ===========================================================================

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    final List<Map<String, dynamic>> actions = [
      {
        'label': l10n.addProduct,
        'icon': Icons.add_box_rounded,
        'color': primaryGreen,
        'action': () async {
          await context.push(AppRoutes.farmerAddProduct);
          _loadDashboardData();
        },
      },
      {
        'label': l10n.orders,
        'icon': Icons.receipt_long_rounded,
        'color': const Color(0xFF1976D2),
        'action': () async {
          await context.push(AppRoutes.farmerOrders);
          _loadDashboardData();
        },
      },
      {
        'label': l10n.insights,
        'icon': Icons.insights_rounded,
        'color': const Color(0xFFE65100),
        'action': () async {
          await context.push(AppRoutes.farmerInventory);
          _loadDashboardData();
        },
      },
      {
        'label': l10n.messages,
        'icon': Icons.chat_bubble_outline_rounded,
        'color': const Color(0xFF388E3C),
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Messages module open')),
          );
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((act) {
            return Expanded(
              child: GestureDetector(
                onTap: act['action'] as VoidCallback?,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        act['icon'] as IconData,
                        color: act['color'] as Color,
                        size: 26,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        act['label'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ===========================================================================
  // 4. INVENTORY ALERTS
  // ===========================================================================

  Widget _buildInventoryAlerts(AppLocalizations l10n) {
    Map<String, dynamic>? lowStockProduct;
    for (final p in _myProducts) {
      final qty = double.tryParse(p['quantity']?.toString() ?? '0') ?? 0;
      if (qty <= 15) {
        lowStockProduct = p;
        break;
      }
    }

    final hasAlert = lowStockProduct != null;
    final titleText = hasAlert ? l10n.inventoryAlert : 'Inventory Status';
    final alertMessage = hasAlert
        ? '${lowStockProduct['name']} is almost sold out (${lowStockProduct['quantity']} kg left).'
        : 'All listed products currently have healthy inventory levels.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasAlert ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasAlert ? const Color(0xFFFFE0B2) : const Color(0xFFC8E6C9),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasAlert ? const Color(0xFFFFB74D) : primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasAlert ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: hasAlert ? const Color(0xFFE65100) : primaryGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alertMessage,
                  style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await context.push(AppRoutes.farmerInventory);
              _loadDashboardData();
            },
            child: Text(
              hasAlert ? l10n.restock : 'Manage',
              style: TextStyle(
                color: hasAlert ? const Color(0xFFE65100) : primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. MARKET OPPORTUNITIES
  // ===========================================================================

  Widget _buildMarketOpportunities(AppLocalizations l10n) {
    List<Map<String, dynamic>> opportunities = [];

    if (_marketProducts.isNotEmpty) {
      opportunities = _marketProducts.take(5).map((p) {
        return {
          'icon': Icons.eco_rounded,
          'iconColor': primaryGreen,
          'name': p['name']?.toString() ?? 'Crop',
          'trend': 'High Demand',
          'price': '\$${p['price']} / kg',
          'badge': 'Recommended',
          'badgeColor': primaryGreen,
        };
      }).toList();
    } else {
      opportunities = [
        {
          'icon': Icons.eco_rounded,
          'iconColor': primaryGreen,
          'name': 'Cucumber',
          'trend': 'High Demand',
          'price': '\$1.20 / kg',
          'badge': 'Recommended',
          'badgeColor': primaryGreen,
        },
        {
          'icon': Icons.nature_rounded,
          'iconColor': const Color(0xFFD32F2F),
          'name': 'Tomato',
          'trend': 'Good Price',
          'price': '\$1.80 / kg',
          'badge': 'Good Price',
          'badgeColor': const Color(0xFF0288D1),
        },
        {
          'icon': Icons.local_fire_department_rounded,
          'iconColor': const Color(0xFFE65100),
          'name': 'Chili',
          'trend': 'Demand Increasing',
          'price': '\$2.50 / kg',
          'badge': 'High Demand',
          'badgeColor': const Color(0xFFE65100),
        },
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: accentOrange,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.marketOpportunities,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                l10n.viewAll,
                style: const TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: opportunities.length,
            itemBuilder: (context, index) {
              final opp = opportunities[index];

              return Container(
                width: 170,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          opp['icon'] as IconData,
                          color: opp['iconColor'] as Color,
                          size: 26,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: (opp['badgeColor'] as Color).withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            opp['badge'] as String,
                            style: TextStyle(
                              color: opp['badgeColor'] as Color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opp['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          opp['trend'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      opp['price'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              await context.push(AppRoutes.farmerInventory);
              _loadDashboardData();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: primaryGreen, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(
              Icons.analytics_outlined,
              color: primaryGreen,
              size: 20,
            ),
            label: Text(
              l10n.viewMarketInsights,
              style: const TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 6. SALES OVERVIEW
  // ===========================================================================

  Widget _buildSalesOverviewChart(AppLocalizations l10n) {
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<double> barValues = List.filled(7, 0.0);

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonday = DateTime(monday.year, monday.month, monday.day);

    for (final order in _farmerOrders) {
      if (order.createdAt != null && order.status.toLowerCase() != 'cancelled') {
        final diff = order.createdAt!.difference(startOfMonday).inDays;
        if (diff >= 0 && diff < 7) {
          barValues[diff] += order.total;
        }
      }
    }

    double maxDataValue = 1.0;
    for (final val in barValues) {
      if (val > maxDataValue) maxDataValue = val;
    }

    final todayIndex = now.weekday - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.salesOverview,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  Text(
                    l10n.thisWeeksRevenue,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: lightGreenBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.growth,
                  style: const TextStyle(
                    color: primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 180,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final isSelected = index == todayIndex;
                final double barHeight = maxDataValue > 0
                    ? ((barValues[index] / maxDataValue) * 100).clamp(8.0, 110.0)
                    : 8.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 22,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryGreen
                            : primaryGreen.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? primaryGreen : Colors.grey[600],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 7. ACTIVE ORDERS
  // ===========================================================================

  Widget _buildActiveOrdersSection(AppLocalizations l10n) {
    final activeOrders = _farmerOrders.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.activeOrders,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            TextButton(
              onPressed: () async {
                await context.push(AppRoutes.farmerOrders);
                _loadDashboardData();
              },
              child: Text(
                l10n.manageOrders,
                style: const TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (activeOrders.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              'No recent orders',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeOrders.length,
            itemBuilder: (context, index) {
              final order = activeOrders[index];

              Color statusBg = const Color(0xFFFFE0B2);
              Color statusText = const Color(0xFFE65100);

              final s = order.status.toLowerCase();
              if (s == 'confirmed' || s == 'delivered') {
                statusBg = const Color(0xFFC8E6C9);
                statusText = primaryGreen;
              } else if (s == 'processing' || s == 'shipped') {
                statusBg = const Color(0xFFE1F5FE);
                statusText = const Color(0xFF0288D1);
              } else if (s == 'cancelled') {
                statusBg = const Color(0xFFFFCDD2);
                statusText = const Color(0xFFD32F2F);
              }

              final orderIdDisplay = order.id.length > 8
                  ? '#ORD-${order.id.substring(0, 8)}'
                  : '#ORD-${order.id}';

              final itemsText = order.items.isNotEmpty
                  ? order.items.map((i) => '${i.productName} (${i.quantity} kg)').join(', ')
                  : 'Order Items';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                orderIdDisplay,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  order.status.toUpperCase(),
                                  style: TextStyle(
                                    color: statusText,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            itemsText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Delivery: ${order.deliveryMethod}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // ===========================================================================
  // 8. MY PRODUCTS
  // ===========================================================================

  Widget _buildMyProductsSection(AppLocalizations l10n) {
    final recentProducts = _myProducts.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.myProducts,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            TextButton(
              onPressed: () async {
                await context.push(AppRoutes.farmerInventory);
                _loadDashboardData();
              },
              child: Text(
                l10n.viewAll,
                style: const TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recentProducts.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              'No products listed yet',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentProducts.length,
            itemBuilder: (context, index) {
              final prod = recentProducts[index];

              final String name = prod['name']?.toString() ?? 'Product';
              final String price = '\$${prod['price']} / kg';
              final double qtyNum = double.tryParse(prod['quantity']?.toString() ?? '0') ?? 0;
              final String qtyStr = '${qtyNum.toStringAsFixed(0)} kg left';

              String status = 'In Stock';
              Color statusColor = primaryGreen;
              if (qtyNum <= 0) {
                status = 'Out of Stock';
                statusColor = Colors.red;
              } else if (qtyNum <= 15) {
                status = 'Low Stock';
                statusColor = const Color(0xFFE65100);
              }

              String imageUrl = '';
              if (prod['images'] is List && (prod['images'] as List).isNotEmpty) {
                imageUrl = ApiConstants.imageUrl(prod['images'][0].toString());
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 54,
                              height: 54,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
                            )
                          : _buildFallbackImage(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            price,
                            style: const TextStyle(
                              fontSize: 13,
                              color: primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          qtyStr,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      width: 54,
      height: 54,
      color: Colors.grey[200],
      child: const Icon(
        Icons.eco_rounded,
        color: primaryGreen,
      ),
    );
  }
}
