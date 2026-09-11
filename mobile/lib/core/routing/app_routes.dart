class AppRoutes {
  // Splash & Onboarding
  static const String splash = '/splash';
  static const String language = '/language';
  static const String getStarted = '/get-started';
  static const String roleSelection = '/role-selection';

  // Auth
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String verifyPhone = '/verify-phone';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String setupProfile = '/setup-profile';

  // Farmer
  static const String farmerDashboard = '/farmer';
  static const String farmerOrders = '/farmer/orders';
  static const String farmerInventory = '/farmer/inventory';
  static const String farmerAddProduct = '/farmer/inventory/add';
  static const String farmerProductDetail = '/farmer/inventory/detail';
  static const String farmerEditProduct = '/farmer/inventory/edit';
  static const String farmerChat = '/farmer/chat';
  static const String farmerProfile = '/farmer/profile';
  static const String farmerSettings = '/farmer/settings';

  // Restaurant
  static const String restaurantHome = '/restaurant';
  static const String restaurantSearch = '/restaurant/search';
  static const String restaurantCart = '/restaurant/cart';
  static const String restaurantCheckout = '/restaurant/checkout';
  static const String restaurantPaymentMethod = '/restaurant/payment-method';
  static const String restaurantOrderSuccess = '/restaurant/order-success';
  static const String restaurantChat = '/restaurant/chat';
  static const String restaurantProfile = '/restaurant/profile';
  static const String restaurantOrders = '/restaurant/orders';
  static const String restaurantOrderTracking = '/restaurant/orders/tracking';
  static const String restaurantFavorites = '/restaurant/favorites';
  static const String restaurantFarmerProfile = '/restaurant/farmer-profile';

  // Shared / Details
  static const String productDetail = '/product/detail';
  static const String chatConversation = '/chat/conversation';
  static const String notifications = '/notifications';
}
