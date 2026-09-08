import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/core/routing/route_args.dart';

// Auth
import 'package:mobile/features/auth/screens/forgot_password_screen.dart';
import 'package:mobile/features/auth/screens/get_started_screen.dart';
import 'package:mobile/features/auth/screens/language_selection_screen.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';
import 'package:mobile/features/auth/screens/reset_password_screen.dart';
import 'package:mobile/features/auth/screens/role_selection_screen.dart';
import 'package:mobile/features/auth/screens/sign_up_screen.dart';
import 'package:mobile/features/auth/screens/splash_screen.dart';
import 'package:mobile/features/auth/screens/verify_phone_screen.dart';

// Cart
import 'package:mobile/features/cart/screens/cart_screen.dart';

// Chat
import 'package:mobile/features/chat/screens/chat_list_screen.dart';
import 'package:mobile/features/chat/screens/chat_screen.dart';

// Farmer
import 'package:mobile/features/farmer/screens/farmer_dashboard_screen.dart';
import 'package:mobile/features/farmer/screens/farmer_order_management_screen.dart';
import 'package:mobile/features/farmer/screens/farmer_profile_screen.dart';
import 'package:mobile/features/farmer/screens/farmer_settings_screen.dart';
import 'package:mobile/features/farmer/screens/inventory_screen.dart';
import 'package:mobile/features/farmer/widgets/edit_product_screen.dart';
import 'package:mobile/features/farmer/widgets/farmer_bottom_nav_bar.dart';
import 'package:mobile/features/farmer/widgets/farmer_product_detail_screen.dart';

// Notification
import 'package:mobile/features/notification/screens/notifications_screen.dart';

// Order
import 'package:mobile/features/order/models/order_model.dart';
import 'package:mobile/features/order/screens/checkout_screen.dart';
import 'package:mobile/features/order/screens/order_detail_tracking_screen.dart';
import 'package:mobile/features/order/screens/order_success_screen.dart';
import 'package:mobile/features/order/screens/payment_method_screen.dart';
import 'package:mobile/features/order/screens/restaurant_orders_screen.dart';

// Product
import 'package:mobile/features/product/screens/add_product_screen.dart';
import 'package:mobile/features/product/screens/favorite_products_screen.dart';
import 'package:mobile/features/product/screens/product_detail_screen.dart';

// Restaurant
import 'package:mobile/features/restaurant/screens/home_screen.dart';
import 'package:mobile/features/restaurant/screens/search_market_screen.dart';
import 'package:mobile/features/restaurant/screens/user_profile_screen.dart';
import 'package:mobile/features/restaurant/widgets/restaurant_bottom_nav_bar.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Route not found: ${state.uri.toString()}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      // Splash & Onboarding
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.language,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.getStarted,
        builder: (context, state) => const GetStartedScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      // Auth
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) {
          final extra = state.extra;
          final role = extra is String
              ? extra
              : (extra is Map<String, dynamic>
                  ? extra['role']?.toString()
                  : null) ??
              'restaurant';
          return SignUpScreen(selectedRole: role);
        },
      ),
      GoRoute(
        path: AppRoutes.verifyPhone,
        builder: (context, state) {
          final args = state.extra as VerifyPhoneArgs;
          return VerifyPhoneScreen(
            type: args.type,
            phoneNumber: args.phoneNumber,
            selectedRole: args.selectedRole,
            userId: args.userId,
            initialOtp: args.initialOtp,
            password: args.password,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) {
          final args = state.extra as ResetPasswordArgs;
          return ResetPasswordScreen(
            phoneNumber: args.phoneNumber,
            otp: args.otp,
          );
        },
      ),

      // ======================================================
      // FARMER SHELL (Tabs with IndexedStack - No Transition)
      // ======================================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: FarmerBottomNavBar(
              navigationShell: navigationShell,
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.farmerDashboard,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FarmerDashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.farmerOrders,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FarmerOrderManagementScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.farmerInventory,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: InventoryScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.farmerChat,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ChatListScreen(isRestaurant: false),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.farmerProfile,
                pageBuilder: (context, state) {
                  final userId = state.extra as String?;
                  return NoTransitionPage(
                    child: FarmerProfileScreen(userId: userId),
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // Farmer Detail Routes (Fullscreen over root navigator)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.farmerAddProduct,
        builder: (context, state) => const AddProductFlowScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.farmerProductDetail,
        builder: (context, state) {
          final product = state.extra as Map<String, dynamic>;
          return FarmerProductDetailScreen(product: product);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.farmerEditProduct,
        builder: (context, state) {
          final product = state.extra as Map<String, dynamic>;
          return EditProductScreen(product: product);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.farmerSettings,
        builder: (context, state) => const FarmerSettingsScreen(),
      ),

      // ======================================================
      // RESTAURANT SHELL (Tabs with IndexedStack - No Transition)
      // ======================================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: RestaurantBottomNavBar(
              navigationShell: navigationShell,
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.restaurantHome,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.restaurantSearch,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SearchMarketScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.restaurantCart,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CartScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.restaurantChat,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ChatListScreen(isRestaurant: true),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.restaurantProfile,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: UserProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // Restaurant Detail Routes (Fullscreen over root navigator)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.restaurantCheckout,
        builder: (context, state) {
          final args = state.extra as CheckoutArgs;
          return CheckoutScreen(
            cart: args.cart,
            deliveryAddress: args.deliveryAddress,
            deliveryNotes: args.deliveryNotes,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.restaurantPaymentMethod,
        builder: (context, state) {
          final args = state.extra as PaymentMethodArgs;
          return PaymentMethodScreen(
            cart: args.cart,
            deliveryNotes: args.deliveryNotes,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.restaurantOrderSuccess,
        builder: (context, state) {
          final orders = state.extra is List<OrderModel>
              ? state.extra as List<OrderModel>
              : const <OrderModel>[];
          return OrderSuccessScreen(orders: orders);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.restaurantOrders,
        builder: (context, state) => const RestaurantOrdersScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.restaurantOrderTracking,
        builder: (context, state) {
          final args = state.extra;
          String? orderId;
          OrderModel? initialOrder;

          if (args is OrderTrackingArgs) {
            orderId = args.orderId;
            if (args.order is OrderModel) {
              initialOrder = args.order as OrderModel;
            }
          } else if (args is OrderModel) {
            orderId = args.id;
            initialOrder = args;
          } else if (args is String && args.isNotEmpty) {
            orderId = args;
          } else if (args is Map) {
            orderId = args['orderId']?.toString() ?? args['id']?.toString();
          }

          // Check query parameters: /restaurant/orders/tracking?orderId=...
          orderId ??= state.uri.queryParameters['orderId'] ??
              state.uri.queryParameters['id'];

          if (orderId != null && orderId.isNotEmpty) {
            return OrderDetailTrackingScreen(
              orderId: orderId,
              initialOrder: initialOrder,
            );
          }

          // Fallback if no specific order was specified: show the orders list
          return const RestaurantOrdersScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.restaurantFavorites,
        builder: (context, state) => const FavoriteProductsScreen(),
      ),

      // Shared / Details (Fullscreen over root navigator)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.productDetail,
        builder: (context, state) {
          final product = state.extra as Map<String, dynamic>;
          return ProductDetailScreen(product: product);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.chatConversation,
        builder: (context, state) {
          final args = state.extra as ChatConversationArgs;
          return ChatScreen(
            conversationId: args.conversationId,
            participantName: args.participantName,
            participantAvatarUrl: args.participantAvatarUrl,
            isOnline: args.isOnline,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}
