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
import 'package:mobile/features/auth/screens/setup_profile_screen.dart';
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

import 'package:mobile/features/restaurant/screens/buyer_farmer_profile_screen.dart';
import 'package:mobile/features/restaurant/screens/home_screen.dart';
import 'package:mobile/features/restaurant/screens/search_market_screen.dart';
import 'package:mobile/features/restaurant/screens/user_profile_screen.dart';
import 'package:mobile/features/restaurant/widgets/restaurant_bottom_nav_bar.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static Page<dynamic> _buildAuthPage({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
          reverseCurve: Curves.easeInOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.03, 0.0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    errorBuilder: (context, state) {
      final path = state.uri.toString();
      if (path.contains('settings')) {
        final isRestaurant = path.contains('restaurant');
        return FarmerSettingsScreen(isRestaurant: isRestaurant);
      }
      return Scaffold(
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
      );
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => AppRoutes.splash,
      ),
      // Splash & Onboarding
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.language,
        pageBuilder: (context, state) => _buildAuthPage(
          key: state.pageKey,
          child: const LanguageSelectionScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.getStarted,
        pageBuilder: (context, state) => _buildAuthPage(
          key: state.pageKey,
          child: const GetStartedScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        pageBuilder: (context, state) => _buildAuthPage(
          key: state.pageKey,
          child: const RoleSelectionScreen(),
        ),
      ),

      // Auth
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _buildAuthPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        pageBuilder: (context, state) {
          final extra = state.extra;
          final role = extra is String
              ? extra
              : (extra is Map<String, dynamic>
                  ? extra['role']?.toString()
                  : null) ??
              'restaurant';
          return _buildAuthPage(
            key: state.pageKey,
            child: SignUpScreen(selectedRole: role),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.verifyPhone,
        pageBuilder: (context, state) {
          final args = state.extra as VerifyPhoneArgs;
          return _buildAuthPage(
            key: state.pageKey,
            child: VerifyPhoneScreen(
              type: args.type,
              phoneNumber: args.phoneNumber,
              selectedRole: args.selectedRole,
              userId: args.userId,
              initialOtp: args.initialOtp,
              password: args.password,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) => _buildAuthPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        pageBuilder: (context, state) {
          final args = state.extra as ResetPasswordArgs;
          return _buildAuthPage(
            key: state.pageKey,
            child: ResetPasswordScreen(
              phoneNumber: args.phoneNumber,
              otp: args.otp,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.setupProfile,
        pageBuilder: (context, state) {
          final role = state.extra is String
              ? state.extra as String
              : (state.extra is Map<String, dynamic>
                  ? (state.extra as Map<String, dynamic>)['role']?.toString()
                  : null) ??
              'restaurant';
          return _buildAuthPage(
            key: state.pageKey,
            child: SetupProfileScreen(role: role),
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
        builder: (context, state) {
          final isRestaurant = state.uri.queryParameters['role'] == 'restaurant' ||
              (state.extra is Map &&
                  (state.extra as Map)['isRestaurant'] == true);
          return FarmerSettingsScreen(isRestaurant: isRestaurant);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.restaurantSettings,
        builder: (context, state) =>
            const FarmerSettingsScreen(isRestaurant: true),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.farmerOrderDetail,
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

          orderId ??= state.uri.queryParameters['orderId'] ??
              state.uri.queryParameters['id'];

          if (orderId != null && orderId.isNotEmpty) {
            return OrderDetailTrackingScreen(
              orderId: orderId,
              initialOrder: initialOrder,
            );
          }

          return const FarmerOrderManagementScreen();
        },
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
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.restaurantFarmerProfile,
        builder: (context, state) {
          String farmerId = '';
          Map<String, dynamic>? initialData;

          final extra = state.extra;
          if (extra is String) {
            farmerId = extra;
          } else if (extra is Map<String, dynamic>) {
            farmerId = extra['farmerId']?.toString() ??
                extra['id']?.toString() ??
                '';
            initialData = extra;
          } else if (extra is Map) {
            farmerId = extra['farmerId']?.toString() ??
                extra['id']?.toString() ??
                '';
            initialData = Map<String, dynamic>.from(extra);
          }

          if (farmerId.isEmpty) {
            farmerId = state.uri.queryParameters['farmerId'] ??
                state.uri.queryParameters['id'] ??
                '';
          }

          return BuyerFarmerProfileScreen(
            farmerId: farmerId,
            initialFarmerData: initialData,
          );
        },
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
