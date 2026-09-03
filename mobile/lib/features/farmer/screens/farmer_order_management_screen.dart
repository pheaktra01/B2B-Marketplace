import 'package:flutter/material.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/farmer/widgets/farmer_bottom_nav_bar.dart';
import 'package:mobile/features/order/models/order_model.dart';
import 'package:mobile/features/order/services/order_service.dart';

class FarmerOrderManagementScreen extends StatefulWidget {
  const FarmerOrderManagementScreen({super.key});

  @override
  State<FarmerOrderManagementScreen> createState() =>
      _FarmerOrderManagementScreenState();
}

class _FarmerOrderManagementScreenState
    extends State<FarmerOrderManagementScreen> {
  static const primaryGreen = Color(0xFF1B5E20);
  static const pageBg = Color(0xFFF7F9F7);
  static const orange = Color(0xFFFF8F00);

  final OrderService _orderService = OrderService();
  late Future<List<OrderModel>> _ordersFuture;
  int _selectedFilter = 0;
  final _filters = const [
    'All',
    'Pending',
    'Confirmed',
    'Processing',
    'Shipped',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _ordersFuture = _orderService.getFarmerOrders();
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  List<OrderModel> _filteredOrders(List<OrderModel> orders) {
    if (_selectedFilter == 0) return orders;
    final status = _filters[_selectedFilter].toLowerCase();
    return orders
        .where((order) => _statusLabel(order.status).toLowerCase() == status)
        .toList();
  }

  Future<void> _changeStatus(OrderModel order, String status) async {
    try {
      await _orderService.updateOrderStatus(orderId: order.id, status: status);
      if (mounted) setState(_loadOrders);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to update order: $error')));
    }
  }

  List<Widget> _actionButtons(OrderModel order) {
    switch (order.status) {
      case 'pending':
        return [
          _actionButton(
            'Decline',
            () => _changeStatus(order, 'cancelled'),
            primary: false,
          ),
          _actionButton('Accept', () => _changeStatus(order, 'confirmed')),
        ];
      case 'confirmed':
        return [
          _actionButton(
            'Start preparing',
            () => _changeStatus(order, 'processing'),
          ),
        ];
      case 'processing':
        return [
          _actionButton(
            'Mark as shipped',
            () => _changeStatus(order, 'shipped'),
          ),
        ];
      case 'shipped':
        return [
          _actionButton(
            'Complete order',
            () => _changeStatus(order, 'delivered'),
          ),
        ];
      default:
        return [];
    }
  }

  Widget _actionButton(
    String text,
    VoidCallback onPressed, {
    bool primary = true,
  }) {
    return Expanded(
      child: primary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text(text),
            )
          : OutlinedButton(onPressed: onPressed, child: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      appBar: const FarmerAppBar(),
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unable to load orders'),
                  TextButton(
                    onPressed: () => setState(_loadOrders),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data ?? [];
          final activeCount = orders
              .where(
                (order) => !['delivered', 'cancelled'].contains(order.status),
              )
              .length;
          final visibleOrders = _filteredOrders(orders);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order management',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$activeCount active',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filters[index]),
                      selected: _selectedFilter == index,
                      selectedColor: primaryGreen,
                      labelStyle: TextStyle(
                        color: _selectedFilter == index
                            ? Colors.white
                            : Colors.black87,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedFilter = index);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: visibleOrders.isEmpty
                    ? const Center(child: Text('No orders found'))
                    : RefreshIndicator(
                        onRefresh: () async {
                          setState(_loadOrders);
                          await _ordersFuture;
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: visibleOrders.length,
                          itemBuilder: (context, index) =>
                              _orderCard(visibleOrders[index]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 1),
    );
  }

  Widget _orderCard(OrderModel order) {
    final items = order.items
        .map((item) => '${item.productName} (${item.quantity} kg)')
        .join(', ');
    final buttons = _actionButtons(order);
    final shortId = order.id.length > 8 ? order.id.substring(0, 8) : order.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #$shortId',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Chip(
                  label: Text(_statusLabel(order.status)),
                  backgroundColor: order.status == 'pending'
                      ? orange
                      : Colors.green.shade100,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              items.isEmpty ? 'No items' : items,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text('Delivery: ${order.deliveryMethod}'),
            Text(
              'Total: \$${order.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (buttons.isNotEmpty) ...[
              const Divider(height: 24),
              Row(
                children: [
                  for (var index = 0; index < buttons.length; index++) ...[
                    if (index > 0) const SizedBox(width: 8),
                    buttons[index],
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
