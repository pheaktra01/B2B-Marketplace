import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/order/models/order_model.dart';
import 'package:mobile/features/order/services/order_service.dart';
import 'package:mobile/l10n/app_localizations.dart';

class OrderDetailTrackingScreen extends StatefulWidget {
  final String orderId;
  final OrderModel? initialOrder;

  const OrderDetailTrackingScreen({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  State<OrderDetailTrackingScreen> createState() =>
      _OrderDetailTrackingScreenState();
}

class _OrderDetailTrackingScreenState extends State<OrderDetailTrackingScreen> {
  static const Color primaryGreen = Color(0xFF135A27);
  static const Color pageBgColor = Color(0xFFF7F9F8);

  final OrderService _orderService = OrderService();

  OrderModel? _order;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFarmer = false;

  @override
  void initState() {
    super.initState();
    _order = widget.initialOrder;
    _checkRole();
    if (_order == null) {
      _loadOrder();
    }
  }

  Future<void> _checkRole() async {
    final role = (await AuthService.getUserRole())?.toLowerCase();
    if (mounted) {
      setState(() {
        _isFarmer = role == 'farmer';
      });
    }
  }

  Future<void> _changeStatus(String status) async {
    if (_order == null) return;
    setState(() => _isLoading = true);
    try {
      final updated = await _orderService.updateOrderStatus(
        orderId: _order!.id,
        status: status,
      );
      if (!mounted) return;
      setState(() {
        _order = updated;
        _isLoading = false;
      });
      final l10n = AppLocalizations.of(context);
      final statusDisplay = updated.getLocalizedStatus(l10n);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.orderStatusUpdated(statusDisplay) ??
                'Order status updated to $statusDisplay',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.unableToUpdateOrder(e.toString()) ??
                'Unable to update order: $e',
          ),
        ),
      );
    }
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final order = await _orderService.getOrderById(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: pageBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              if (_isFarmer) {
                context.go(AppRoutes.farmerOrders);
              } else {
                context.go(AppRoutes.restaurantOrders);
              }
            }
          },
        ),
        title: Text(
          _order != null
              ? (l10n?.orderNumberLabel(_order!.displayId) ??
                  'Order #${_order!.displayId}')
              : (l10n?.orderTracking ?? 'Order Tracking'),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: primaryGreen),
            onPressed: _loadOrder,
          ),
        ],
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations? l10n) {
    if (_isLoading && _order == null) {
      return const Center(
        child: CircularProgressIndicator(color: primaryGreen),
      );
    }

    if (_errorMessage != null && _order == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50, color: Colors.red.shade400),
              const SizedBox(height: 12),
              Text(
                l10n?.failedToLoadOrderDetails ?? 'Failed to load order details',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadOrder,
                style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                child: Text(
                  l10n?.retry ?? 'Retry',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_order == null) {
      return Center(child: Text(l10n?.orderNotFound ?? 'Order not found'));
    }

    final order = _order!;

    return RefreshIndicator(
      onRefresh: _loadOrder,
      color: primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            _buildStatusHeader(order, l10n),

            const SizedBox(height: 16),

            // Visual Tracking Stepper
            _buildTrackingTimeline(order, l10n),

            const SizedBox(height: 16),

            // Delivery Details Card
            _buildDeliveryCard(order, l10n),

            const SizedBox(height: 16),

            // Order Items Card
            _buildItemsCard(order, l10n),

            const SizedBox(height: 16),

            // Summary Breakdown Card
            _buildFinancialSummary(order, l10n),

            const SizedBox(height: 24),

            // Action Buttons
            _buildBottomButtons(order, l10n),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(OrderModel order, AppLocalizations? l10n) {
    final isCancelled = order.status.toLowerCase() == 'cancelled';
    final isDelivered = order.status.toLowerCase() == 'delivered';

    Color bannerBg;
    Color textColor;
    IconData icon;
    String subtitle;

    if (isCancelled) {
      bannerBg = Colors.red.shade50;
      textColor = Colors.red.shade800;
      icon = Icons.cancel_outlined;
      subtitle = l10n?.orderCancelledSubtitle ?? 'This order was cancelled.';
    } else if (isDelivered) {
      bannerBg = primaryGreen.withValues(alpha: 0.1);
      textColor = primaryGreen;
      icon = Icons.check_circle_outline;
      subtitle = _isFarmer
          ? (l10n?.orderDeliveredFarmerSubtitle ??
              'Order delivered and completed successfully.')
          : (l10n?.orderDeliveredRestaurantSubtitle ??
              'Delivered to your kitchen successfully.');
    } else if (order.status.toLowerCase() == 'shipped') {
      bannerBg = Colors.teal.shade50;
      textColor = Colors.teal.shade800;
      icon = Icons.local_shipping_outlined;
      subtitle = _isFarmer
          ? (l10n?.orderShippedFarmerSubtitle ??
              'Produce is out for delivery to the restaurant.')
          : (l10n?.orderShippedRestaurantSubtitle ??
              'Produce is in transit to your kitchen.');
    } else if (order.status.toLowerCase() == 'processing') {
      bannerBg = Colors.indigo.shade50;
      textColor = Colors.indigo.shade800;
      icon = Icons.inventory_2_outlined;
      subtitle = _isFarmer
          ? (l10n?.orderProcessingFarmerSubtitle ??
              'You are harvesting and packaging this order.')
          : (l10n?.orderProcessingRestaurantSubtitle ??
              'Farmer is harvesting and packaging your order.');
    } else if (order.status.toLowerCase() == 'confirmed') {
      bannerBg = Colors.blue.shade50;
      textColor = Colors.blue.shade800;
      icon = Icons.thumb_up_outlined;
      subtitle = _isFarmer
          ? (l10n?.orderConfirmedFarmerSubtitle ??
              'Order confirmed. Ready to start preparing.')
          : (l10n?.orderConfirmedRestaurantSubtitle ??
              'Order confirmed by grower. Preparing fulfillment.');
    } else {
      bannerBg = const Color(0xFFFFF3E0);
      textColor = const Color(0xFFE65100);
      icon = Icons.hourglass_top_outlined;
      subtitle = _isFarmer
          ? (l10n?.orderPendingFarmerSubtitle ??
              'New order received from buyer. Awaiting your confirmation.')
          : (l10n?.orderPendingRestaurantSubtitle ??
              'Sent to farmer. Awaiting grower confirmation.');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: textColor.withValues(alpha: 0.15),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(icon, color: textColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.getLocalizedStatus(l10n),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline(OrderModel order, AppLocalizations? l10n) {
    final steps = [
      {
        'title': l10n?.orderPlacedStep ?? 'Order Placed',
        'desc': _isFarmer
            ? (l10n?.orderPlacedFarmerDesc ?? 'Order received from buyer')
            : (l10n?.orderPlacedRestaurantDesc ??
                'Order transmitted to farmer'),
      },
      {
        'title': l10n?.confirmedStep ?? 'Confirmed',
        'desc': _isFarmer
            ? (l10n?.confirmedFarmerDesc ?? 'You confirmed the order')
            : (l10n?.confirmedRestaurantDesc ?? 'Farmer confirmed harvest'),
      },
      {
        'title': l10n?.processingStep ?? 'Processing',
        'desc': l10n?.processingDesc ?? 'Harvesting & packaging',
      },
      {
        'title': l10n?.outForDeliveryStep ?? 'Out for Delivery',
        'desc': _isFarmer
            ? (l10n?.outForDeliveryFarmerDesc ?? 'On the way to buyer')
            : (l10n?.outForDeliveryRestaurantDesc ??
                'On the way to your kitchen'),
      },
      {
        'title': l10n?.deliveredStep ?? 'Delivered',
        'desc': _isFarmer
            ? (l10n?.deliveredFarmerDesc ?? 'Delivered & finalized')
            : (l10n?.deliveredRestaurantDesc ?? 'Received & verified'),
      },
    ];

    final isCancelled = order.status.toLowerCase() == 'cancelled';
    final currentStep = order.progressStepIndex;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.orderProgress ?? 'Order Progress',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 18),
          if (isCancelled)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n?.orderCancelledSubtitle ??
                          'This order has been cancelled.',
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(steps.length, (index) {
              final isDone = index <= currentStep;
              final isCurrent = index == currentStep;
              final isLast = index == steps.length - 1;

              Color dotColor = isDone ? primaryGreen : Colors.grey.shade300;
              Color lineColor =
                  index < currentStep ? primaryGreen : Colors.grey.shade200;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline column with icon & line
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? primaryGreen
                              : (isDone
                                  ? primaryGreen.withValues(alpha: 0.15)
                                  : Colors.grey.shade100),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: dotColor,
                            width: isCurrent ? 2 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: isDone
                              ? Icon(
                                  Icons.check,
                                  size: 13,
                                  color: isCurrent
                                      ? Colors.white
                                      : primaryGreen,
                                )
                              : null,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 36,
                          color: lineColor,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Step descriptions
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps[index]['title']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isDone
                                  ? Colors.black87
                                  : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            steps[index]['desc']!,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDone
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(OrderModel order, AppLocalizations? l10n) {
    final methodLabel = order.deliveryMethod.toLowerCase() == 'pickup'
        ? (l10n?.deliveryMethodPickup.toUpperCase() ?? 'PICKUP')
        : (l10n?.deliveryMethodDelivery.toUpperCase() ?? 'DELIVERY');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.deliveryDetails ?? 'Delivery Details',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            Icons.local_shipping_outlined,
            l10n?.deliveryMethod ?? 'Delivery Method',
            methodLabel,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.location_on_outlined,
            l10n?.destinationAddress ?? 'Destination Address',
            order.deliveryAddress.isNotEmpty
                ? order.deliveryAddress
                : (l10n?.defaultRestaurantAddress ??
                    'Default Restaurant Kitchen Address'),
          ),
          if (order.formattedDate.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              l10n?.orderedAt ?? 'Ordered At',
              order.formattedDate,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsCard(OrderModel order, AppLocalizations? l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.itemsInThisOrder ?? 'Items in this Order',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n?.orderItemsCount(order.items.length) ??
                      '${order.items.length} items',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 0.8,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? Image.network(
                              ApiConstants.imageUrl(item.imageUrl!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.eco_outlined,
                                color: primaryGreen,
                                size: 22,
                              ),
                            )
                          : const Icon(
                              Icons.eco_outlined,
                              color: primaryGreen,
                              size: 22,
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)} kg'
                          '${item.unitPrice > 0 ? ' × \$${item.unitPrice.toStringAsFixed(2)}/kg' : ''}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(OrderModel order, AppLocalizations? l10n) {
    final isKhqr = order.paymentMethod.toLowerCase() == 'khqr';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.paymentBreakdown ?? 'Payment Breakdown',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          _buildPriceRow(
              l10n?.subtotal ?? 'Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildPriceRow(l10n?.deliveryFee ?? 'Delivery Fee',
              '\$${order.deliveryFee.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildPriceRow(
            '${l10n?.transactionFee ?? 'Transaction Fee'} (5%)',
            '\$${order.transactionFee.toStringAsFixed(2)}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.totalAmount ?? 'Total Amount',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Payment Method Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  isKhqr ? Icons.qr_code_2 : Icons.payments_outlined,
                  size: 18,
                  color: primaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  isKhqr
                      ? (l10n?.paymentKhqr ?? 'Payment: KHQR (Bakong)')
                      : (l10n?.paymentCash ?? 'Payment: Cash on Delivery'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: order.paymentStatus.toLowerCase() == 'completed'
                        ? primaryGreen.withValues(alpha: 0.1)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.paymentStatus.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: order.paymentStatus.toLowerCase() == 'completed'
                          ? primaryGreen
                          : const Color(0xFFE65100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: primaryGreen),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(OrderModel order, AppLocalizations? l10n) {
    if (_isFarmer) {
      final status = order.status.toLowerCase();
      return Column(
        children: [
          // Farmer order workflow action buttons
          if (status == 'pending') ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _changeStatus('cancelled'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n?.declineOrder ?? 'Decline Order'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _changeStatus('confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n?.acceptOrder ?? 'Accept Order'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ] else if (status == 'confirmed') ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _changeStatus('processing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.inventory_2_outlined, size: 18),
                label: Text(
                  l10n?.startPreparingProduce ?? 'Start Preparing Produce',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ] else if (status == 'processing') ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _changeStatus('shipped'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.local_shipping_outlined, size: 18),
                label: Text(
                  l10n?.markAsOutForDelivery ?? 'Mark as Out for Delivery',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ] else if (status == 'shipped') ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _changeStatus('delivered'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text(
                  l10n?.completeOrderDelivered ?? 'Complete Order (Delivered)',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          // Farmer Chat Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                context.go(AppRoutes.farmerChat);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryGreen,
                side: const BorderSide(color: primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.chat_outlined, size: 18),
              label: Text(
                l10n?.openChats ?? 'Open Chats',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Back to Orders
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton.icon(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.farmerOrders);
                }
              },
              icon: const Icon(Icons.arrow_back_rounded,
                  size: 18, color: Colors.grey),
              label: Text(
                l10n?.backToOrderManagement ?? 'Back to Order Management',
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              context.go(AppRoutes.restaurantChat);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.chat_outlined, size: 18),
            label: Text(
              l10n?.messageGrowerFarmer ?? 'Message Grower / Farmer',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.restaurantHome),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade800,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.storefront_outlined, size: 18),
            label: Text(
              l10n?.backToMarketplace ?? 'Back to Marketplace',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
