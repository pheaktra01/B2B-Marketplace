import 'package:flutter/material.dart';
import 'package:mobile/features/notification/screens/notifications_screen.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/farmer/widgets/farmer_bottom_nav_bar.dart';
import 'package:mobile/features/product/screens/add_product_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() =>
      _FarmerDashboardScreenState();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),

      // -----------------------------------------------------------------------
      // APP BAR
      // -----------------------------------------------------------------------
      appBar: FarmerAppBar(
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 26,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/profile.png'),
            ),
          ),
        ],
      ),

      // -----------------------------------------------------------------------
      // FLOATING ACTION BUTTON
      // -----------------------------------------------------------------------
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductFlowScreen(),
            ),
          );
        },
        backgroundColor: accentOrange,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        icon: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 24,
        ),
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
      bottomNavigationBar: const FarmerBottomNavBar(
        currentIndex: 0,
      ),

      // -----------------------------------------------------------------------
      // BODY
      // -----------------------------------------------------------------------
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 900,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
    );
  }

  // ===========================================================================
  // 1. HEADER GREETING
  // ===========================================================================

  Widget _buildHeaderGreeting(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.goodMorning('Pheaktra'),
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
    final List<Map<String, dynamic>> stats = [
      {
        'title': l10n.totalSales,
        'value': '\$1,250',
        'icon': Icons.attach_money_rounded,
        'color': primaryGreen,
        'bg': const Color(0xFFE8F5E9),
      },
      {
        'title': l10n.activeOrders,
        'value': '8',
        'icon': Icons.shopping_bag_outlined,
        'color': const Color(0xFF0288D1),
        'bg': const Color(0xFFE1F5FE),
      },
      {
        'title': l10n.productsListed,
        'value': '15',
        'icon': Icons.inventory_2_outlined,
        'color': const Color(0xFF7B1FA2),
        'bg': const Color(0xFFF3E5F5),
      },
      {
        'title': l10n.monthlyGrowth,
        'value': '+18%',
        'icon': Icons.trending_up_rounded,
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
            border: Border.all(
              color: Colors.grey.shade200,
            ),
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

  Widget _buildQuickActions(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final List<Map<String, dynamic>> actions = [
      {
        'label': l10n.addProduct,
        'icon': Icons.add_box_rounded,
        'color': primaryGreen,
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductFlowScreen(),
            ),
          );
        },
      },
      {
        'label': l10n.orders,
        'icon': Icons.receipt_long_rounded,
        'color': const Color(0xFF1976D2),
        'action': () {},
      },
      {
        'label': l10n.insights,
        'icon': Icons.insights_rounded,
        'color': const Color(0xFFE65100),
        'action': () {},
      },
      {
        'label': l10n.messages,
        'icon': Icons.chat_bubble_outline_rounded,
        'color': const Color(0xFF388E3C),
        'action': () {},
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
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFE0B2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFB74D),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
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
                  l10n.inventoryAlert,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Organic Tomato is almost sold out (Only 12 kg left).',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              l10n.restock,
              style: const TextStyle(
                color: Color(0xFFE65100),
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
    final List<Map<String, dynamic>> opportunities = [
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
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
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
                            color: (opp['badgeColor'] as Color)
                                .withValues(alpha: 0.12),
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
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: primaryGreen,
                width: 1.5,
              ),
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
    final List<double> barValues = [
      50,
      90,
      70,
      130,
      100,
      150,
      120,
    ];

    final List<String> days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    const double maxDataValue = 150.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
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
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                7,
                (index) {
                  final isSelected = index == 5;

                  final double barHeight =
                      (barValues[index] / maxDataValue) * 110;

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
                          color: isSelected
                              ? primaryGreen
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  );
                },
              ),
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
    final List<Map<String, dynamic>> orders = [
      {
        'id': '#ORD-9821',
        'restaurant': 'The Grand Bistro',
        'product': 'Fresh Cucumber',
        'qty': '50 kg',
        'value': '\$60.00',
        'status': 'Pending',
        'statusBg': const Color(0xFFFFE0B2),
        'statusText': const Color(0xFFE65100),
      },
      {
        'id': '#ORD-9819',
        'restaurant': 'Green Plate Kitchen',
        'product': 'Organic Tomatoes',
        'qty': '100 kg',
        'value': '\$180.00',
        'status': 'Approved',
        'statusBg': const Color(0xFFC8E6C9),
        'statusText': primaryGreen,
      },
    ];

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
              onPressed: () {},
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
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
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
                              order['id'] as String,
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
                                color: order['statusBg'] as Color,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                order['status'] as String,
                                style: TextStyle(
                                  color: order['statusText'] as Color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          order['restaurant'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${order['product']} • ${order['qty']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    order['value'] as String,
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
    final List<Map<String, dynamic>> products = [
      {
        'name': 'Organic Tomatoes',
        'price': '\$1.80 / kg',
        'qty': '12 kg left',
        'status': 'Low Stock',
        'statusColor': const Color(0xFFE65100),
        'image': 'https://picsum.photos/id/1080/100/100',
      },
      {
        'name': 'Crispy Cucumber',
        'price': '\$1.20 / kg',
        'qty': '240 kg left',
        'status': 'In Stock',
        'statusColor': primaryGreen,
        'image': 'https://picsum.photos/id/292/100/100',
      },
    ];

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
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final prod = products[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      prod['image'] as String,
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          width: 54,
                          height: 54,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.eco_rounded,
                            color: primaryGreen,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prod['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          prod['price'] as String,
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
                        prod['qty'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prod['status'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: prod['statusColor'] as Color,
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
}