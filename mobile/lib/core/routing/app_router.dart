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
import 'package:mobile/features/farmer/widgets/farmer_product_detail_screen.dart';

// Notification
import 'package:mobile/features/notification/screens/notifications_screen.dart';

// Order
import 'package:mobile/features/order/models/order_model.dart';
import 'package:mobile/features/order/screens/checkout_screen.dart';
import 'package:mobile/features/order/screens/order_success_screen.dart';
import 'package:mobile/features/order/screens/payment_method_screen.dart';

// Product
import 'package:mobile/features/product/screens/add_product_screen.dart';
import 'package:mobile/features/product/screens/product_detail_screen.dart';

// Restaurant
import 'package:mobile/features/restaurant/screens/home_screen.dart';
import 'package:mobile/features/restaurant/screens/search_market_screen.dart';
import 'package:mobile/features/restaurant/screens/user_profile_screen.dart';

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

      // Farmer routes
      GoRoute(
        path: AppRoutes.farmerDashboard,
        builder: (context, state) => const FarmerDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.farmerOrders,
        builder: (context, state) => const FarmerOrderManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.farmerInventory,
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.farmerAddProduct,
        builder: (context, state) => const AddProductFlowScreen(),
      ),
      GoRoute(
        path: AppRoutes.farmerProductDetail,
        builder: (context, state) {
          final product = state.extra as Map<String, dynamic>;
          return FarmerProductDetailScreen(product: product);
        },
      ),
      GoRoute(
        path: AppRoutes.farmerEditProduct,
        builder: (context, state) {
          final product = state.extra as Map<String, dynamic>;
          return EditProductScreen(product: product);
        },
      ),
      GoRoute(
        path: AppRoutes.farmerChat,
        builder: (context, state) => const ChatListScreen(isRestaurant: false),
      ),
      GoRoute(
        path: AppRoutes.farmerProfile,
        builder: (context, state) {
          final userId = state.extra as String?;
          return FarmerProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: AppRoutes.farmerSettings,
        builder: (context, state) => const FarmerSettingsScreen(),
      ),

      // Restaurant routes
      GoRoute(
        path: AppRoutes.restaurantHome,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.restaurantSearch,
        builder: (context, state) => const SearchMarketScreen(),
      ),
      GoRoute(
        path: AppRoutes.restaurantCart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
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
        path: AppRoutes.restaurantOrderSuccess,
        builder: (context, state) {
          final orders = state.extra is List<OrderModel>
              ? state.extra as List<OrderModel>
              : const <OrderModel>[];
          return OrderSuccessScreen(orders: orders);
        },
      ),
      GoRoute(
        path: AppRoutes.restaurantChat,
        builder: (context, state) => const ChatListScreen(isRestaurant: true),
      ),
      GoRoute(
        path: AppRoutes.restaurantProfile,
        builder: (context, state) => const UserProfileScreen(),
      ),

      // Shared / Details
      GoRoute(
        path: AppRoutes.productDetail,
        builder: (context, state) {
          final product = state.extra as Map<String, dynamic>;
          return ProductDetailScreen(product: product);
        },
      ),
      GoRoute(
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
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}
