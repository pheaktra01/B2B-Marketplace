// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Marketplace';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get language => 'Language';

  @override
  String get chooseLanguage => 'Choose Your Language';

  @override
  String get selectLanguageDescription =>
      'Select your language to use\nPsarKasekor';

  @override
  String get continueButton => 'Continue';

  @override
  String get getStartedTitle => 'Direct from Farm to Your Kitchen';

  @override
  String get getStartedDescription =>
      'Connect with local farmers to get the freshest ingredients for your kitchen.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get trustedChefs => 'Trusted by over 500 top chefs';

  @override
  String get termsPrivacy =>
      'By continuing, you agree to our Terms and Privacy Policy';

  @override
  String get farmersMarket => 'Farmers Market';

  @override
  String get farmersMarketDescription =>
      'Fresh agricultural products marketplace for professional chefs.';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter phone number';

  @override
  String get invalidPhoneNumber => 'Invalid phone number';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get unknownUserRole => 'Unknown user role';

  @override
  String get unableToLogin => 'Unable to login';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String goodMorning(Object name) {
    return 'Good Morning, $name';
  }

  @override
  String get dashboardDescription =>
      'Connecting your harvest to 14 restaurant partners today.';

  @override
  String get totalSales => 'Total Sales';

  @override
  String get activeOrders => 'Active Orders';

  @override
  String get productsListed => 'Products Listed';

  @override
  String get monthlyGrowth => 'Monthly Growth';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get addProduct => 'Add Product';

  @override
  String get orders => 'Orders';

  @override
  String get insights => 'Insights';

  @override
  String get messages => 'Messages';

  @override
  String get inventoryAlert => 'Inventory Alert';

  @override
  String get organicTomatoAlmostSoldOut =>
      'Organic Tomato is almost sold out (Only 12 kg left).';

  @override
  String get restock => 'Restock';

  @override
  String get marketOpportunities => 'Market Opportunities';

  @override
  String get viewAll => 'View All';

  @override
  String get highDemand => 'High 🔥';

  @override
  String get goodPrice => 'Good Price';

  @override
  String get demandIncreasing => 'Demand Increasing';

  @override
  String get recommended => 'Recommended';

  @override
  String get viewMarketInsights => 'View Market Insights';

  @override
  String get salesOverview => 'Sales Overview';

  @override
  String get thisWeeksRevenue => 'This Week\'s Revenue';

  @override
  String get growth => '+18% Growth';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get manageOrders => 'Manage Orders';

  @override
  String get pending => 'Pending';

  @override
  String get approved => 'Approved';

  @override
  String get myProducts => 'My Products';

  @override
  String get lowStock => 'LOW STOCK';

  @override
  String get inStock => 'In Stock';

  @override
  String kgLeft(Object quantity) {
    return '$quantity kg left';
  }

  @override
  String get dashboard => 'Dashboard';

  @override
  String get inventory => 'Inventory';

  @override
  String get chat => 'Chat';

  @override
  String get profile => 'Profile';

  @override
  String get priceAndInventory => 'Price & Inventory';

  @override
  String get deliveryAndReview => 'Delivery & Review';

  @override
  String stepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String percentCompleted(int percent) {
    return '$percent% Completed';
  }

  @override
  String get productPhotos => 'PRODUCT PHOTOS';

  @override
  String photosCount(int count, int max) {
    return '$count/$max photos';
  }

  @override
  String get productName => 'Product Name';

  @override
  String get productNameHint => 'e.g. Fresh Organic Bok Choy';

  @override
  String get category => 'Category';

  @override
  String get vegetables => 'Vegetables';

  @override
  String get fruits => 'Fruits';

  @override
  String get herbsAndSpices => 'Herbs & Spices';

  @override
  String get riceAndGrains => 'Rice & Grains';

  @override
  String get eggsAndDairy => 'Eggs & Dairy';

  @override
  String get productCondition => 'Product Condition';

  @override
  String get fresh => 'Fresh';

  @override
  String get standardProduce => 'Standard produce';

  @override
  String get organic => 'Organic';

  @override
  String get chemicalFree => 'Chemical-free';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint =>
      'Describe quality, taste, or harvest details...';

  @override
  String get sellingPricePerKg => 'Selling Price per kg';

  @override
  String get perKg => '\$ / kg';

  @override
  String get availableQuantity => 'Available Quantity';

  @override
  String get minimumOrder => 'Minimum Order';

  @override
  String get harvestDate => 'Harvest Date';

  @override
  String get availableUntil => 'Available Until';

  @override
  String get selectDate => 'Select date';

  @override
  String get marketRecommendation => 'Market Recommendation';

  @override
  String get currentRestaurantDemand => 'Current restaurant demand';

  @override
  String get typicalMarketPrice => 'Typical market price';

  @override
  String get recommendedPrice => 'Recommended price';

  @override
  String useRecommendedPrice(String price) {
    return 'Use Recommended Price ($price)';
  }

  @override
  String get locationFarmOrigin => 'Location / Farm Origin';

  @override
  String get phnomPenh => 'Phnom Penh';

  @override
  String get kandal => 'Kandal';

  @override
  String get battambang => 'Battambang';

  @override
  String get siemReap => 'Siem Reap';

  @override
  String get kampongCham => 'Kampong Cham';

  @override
  String get deliveryMethod => 'Delivery Method';

  @override
  String get farmerDelivery => 'Farmer Delivery';

  @override
  String get deliverToBuyer => 'Deliver to buyer';

  @override
  String get buyerPickup => 'Buyer Pickup';

  @override
  String get pickupAtFarm => 'Pickup at farm';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get productPreview => 'PRODUCT PREVIEW';

  @override
  String get freshProduce => 'Fresh Produce';

  @override
  String get yourFarm => 'Your Farm';

  @override
  String get publishProduct => 'Publish Product';

  @override
  String get nextStep => 'Next Step';

  @override
  String get productPublished => 'Product Published!';

  @override
  String get productPublishedDescription =>
      'Your product is now available for restaurants in Cambodia to discover and order.';

  @override
  String get viewProductListing => 'View Product Listing';

  @override
  String get backToDashboard => 'Back to Dashboard';

  @override
  String get uploadProductPhotos => 'Upload Product Photos';

  @override
  String get addUpToFivePhotos => 'Add up to 5 photos';

  @override
  String addMorePhotos(int count, int max) {
    return 'Add More Photos ($count/$max)';
  }

  @override
  String get mainPhoto => 'Main';

  @override
  String get uploadAtLeastOnePhoto =>
      'Please upload at least one product photo';

  @override
  String get enterProductName => 'Please enter a product name';

  @override
  String get enterProductDescription => 'Please enter a product description';

  @override
  String get enterValidSellingPrice => 'Please enter a valid selling price';

  @override
  String get enterValidQuantity => 'Please enter a valid available quantity';

  @override
  String get enterValidMinimumOrder => 'Please enter a valid minimum order';

  @override
  String get minimumOrderGreaterThanQuantity =>
      'Minimum order cannot be greater than available quantity';

  @override
  String get availableUntilBeforeHarvest =>
      'Available Until cannot be before Harvest Date';

  @override
  String get enterValidDeliveryFee => 'Please enter a valid delivery fee';

  @override
  String get failedToSelectImages => 'Failed to select images';

  @override
  String get failedToPublishProduct => 'Failed to publish product';

  @override
  String maximumImages(int max) {
    return 'You can upload a maximum of $max images';
  }

  @override
  String onlyMoreImages(int remaining, int max) {
    return 'Only $remaining more image(s) can be added. Maximum is $max.';
  }

  @override
  String get availableLabel => 'Available: ';

  @override
  String get available => 'Available';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get inCart => 'In Cart';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get allOrders => 'All Orders';

  @override
  String get accepted => 'Accepted';

  @override
  String get preparing => 'Preparing';

  @override
  String get active => 'Active';

  @override
  String get orderManagement => 'Order Management';

  @override
  String get fiveMinutesAgo => '5 mins ago';

  @override
  String get heirloomTomatoes => 'Heirloom Tomatoes';

  @override
  String get babyArugula => 'Baby Arugula';

  @override
  String get microgreensMix => 'Microgreens Mix';

  @override
  String get rainbowCarrots => 'Rainbow Carrots (Bunch)';

  @override
  String get naturalHoney => 'Natural Honey';

  @override
  String get sourdoughStarterKit => 'Sourdough Starter Kit';

  @override
  String get butterheadLettuce => 'Butterhead Lettuce (30 heads)';

  @override
  String get freshMint => 'Fresh Mint';

  @override
  String get more => 'more';

  @override
  String get cases => 'Cases';

  @override
  String get items => 'Items';

  @override
  String get delivery => 'Delivery';

  @override
  String get pickup => 'Pickup';

  @override
  String get readyForPickup => 'Ready for Pickup';

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get startPreparing => 'Start Preparing';

  @override
  String get markAsReady => 'Mark as Ready';

  @override
  String get completeOrder => 'Complete Order';

  @override
  String get ready => 'Ready';

  @override
  String get manageProductsDescription =>
      'Manage the products you have listed for restaurants.';

  @override
  String get activeProducts => 'ACTIVE PRODUCTS';

  @override
  String get outOfStock => 'OUT OF STOCK';

  @override
  String get totalProducts => 'TOTAL PRODUCTS';

  @override
  String get allItems => 'All Items';

  @override
  String get microgreens => 'Microgreens';

  @override
  String get searchYourProducts => 'Search your products...';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noMatchingProducts => 'No matching products';

  @override
  String get noProductsListedYet => 'No products listed yet';

  @override
  String get tryChangingSearchFilter => 'Try changing your search or filter.';

  @override
  String get addFirstProductDescription =>
      'Add your first product to start selling to restaurants.';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get unableToLoadProducts => 'Unable to load products';

  @override
  String get unknownErrorOccurred => 'Unknown error occurred.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get deleteProduct => 'Delete Product?';

  @override
  String deleteProductConfirmation(Object name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get productDeletedSuccessfully => 'Product deleted successfully.';

  @override
  String get productIsNowAvailable => 'Product is now available.';

  @override
  String get productIsNowUnavailable => 'Product is now unavailable.';

  @override
  String failedToUpdateAvailability(Object error) {
    return 'Failed to update availability: $error';
  }

  @override
  String failedToDeleteProduct(Object error) {
    return 'Failed to delete product: $error';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get today => 'TODAY';

  @override
  String newNotifications(Object count) {
    return '$count NEW';
  }

  @override
  String newOrder(Object orderNumber) {
    return 'New Order #$orderNumber';
  }

  @override
  String orderMessage(
    Object productName,
    Object quantity,
    Object restaurantName,
  ) {
    return '$restaurantName ordered ${quantity}kg of $productName.';
  }

  @override
  String get viewOrder => 'View Order';

  @override
  String messageFromChef(Object chefName) {
    return 'Message from Chef $chefName';
  }

  @override
  String get chefMessage =>
      '\"Can we increase the delivery quantity for Tuesday? I need an extra 20 crates...\"';

  @override
  String get replyNow => 'Reply Now';

  @override
  String get paymentReceived => 'Payment Received';

  @override
  String paymentProcessed(Object amount, Object period) {
    return 'Your payment of $amount for $period has been processed successfully.';
  }

  @override
  String get checkBalance => 'Check Balance >';

  @override
  String get yesterday => 'YESTERDAY';

  @override
  String get orderDelivered => 'Order Delivered';

  @override
  String orderDeliveredMessage(Object orderNumber, Object restaurantName) {
    return 'Order #$orderNumber was successfully delivered to $restaurantName.';
  }

  @override
  String get viewDetails => 'View Details';

  @override
  String get systemUpdate => 'System Update';

  @override
  String get systemUpdateMessage =>
      'Verdant system maintenance complete. The new delivery tracking feature is now available!';

  @override
  String minutesAgo(Object minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(Object hours) {
    return '${hours}h ago';
  }

  @override
  String orderNumber(Object number) {
    return 'Order #$number';
  }

  @override
  String get unableToLoadNotifications => 'Unable to load notifications';

  @override
  String get notificationRemoved => 'Notification removed';

  @override
  String get clearAllNotificationsTitle => 'Clear all notifications?';

  @override
  String get clearAllNotificationsContent =>
      'This will permanently remove all your notifications.';

  @override
  String get clearAll => 'Clear All';

  @override
  String get allNotificationsCleared => 'All notifications cleared';

  @override
  String get clearAllNotifications => 'Clear all notifications';

  @override
  String get sendTestNotification => 'Send Test Notification';

  @override
  String get testNotificationSent =>
      'Test notification sent! Check your lock screen & status bar.';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get noNotificationsDescription =>
      'You will receive real-time updates here for orders, messages, stock, payments, and account activities.';

  @override
  String noCategoryNotifications(String category) {
    return 'No $category notifications';
  }

  @override
  String categoryNotificationsHeader(String category) {
    return '$category NOTIFICATIONS';
  }

  @override
  String get securityAlert => 'Security Alert';

  @override
  String get newLoginDetected => 'A new login was detected on your account.';

  @override
  String get securityAlertNotice =>
      'If this was you, you can safely ignore this notice. If you did not log in recently, we recommend reviewing your profile or updating your security credentials.';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get viewProfile => 'View Profile';

  @override
  String get notifCategoryAll => 'All';

  @override
  String get notifCategoryOrders => 'Orders';

  @override
  String get notifCategoryMessages => 'Messages';

  @override
  String get notifCategoryPayments => 'Payments';

  @override
  String get notifCategoryStock => 'Stock';

  @override
  String get notifCategoryAccount => 'Account';

  @override
  String get notifCategorySystem => 'System';

  @override
  String get justNow => 'Just now';

  @override
  String daysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get view => 'View';

  @override
  String get tagOrderPlaced => 'Order Placed';

  @override
  String get tagNewOrder => 'New Order';

  @override
  String get tagAccepted => 'Accepted';

  @override
  String get tagRejected => 'Rejected';

  @override
  String get tagReady => 'Ready';

  @override
  String get tagCompleted => 'Completed';

  @override
  String get tagCancelled => 'Cancelled';

  @override
  String get tagOrder => 'Order';

  @override
  String get tagPhoto => 'Photo';

  @override
  String get tagOrderChat => 'Order Chat';

  @override
  String get tagChat => 'Chat';

  @override
  String get tagPaymentFailed => 'Payment Failed';

  @override
  String get tagPaymentDone => 'Payment Done';

  @override
  String get tagPayment => 'Payment';

  @override
  String get tagOutOfStock => 'Out of Stock';

  @override
  String get tagLowStock => 'Low Stock';

  @override
  String get tagPublished => 'Published';

  @override
  String get tagUpdated => 'Updated';

  @override
  String get tagInventory => 'Inventory';

  @override
  String get tagSecurityAlert => 'Security Alert';

  @override
  String get tagDeviceLogin => 'Device Login';

  @override
  String get tagPassword => 'Password';

  @override
  String get tagPhone => 'Phone';

  @override
  String get tagAccount => 'Account';

  @override
  String get tagAnnouncement => 'Announcement';

  @override
  String get tagMaintenance => 'Maintenance';

  @override
  String get tagNewFeature => 'New Feature';

  @override
  String get tagPolicyUpdate => 'Policy Update';

  @override
  String get tagInterruption => 'Interruption';

  @override
  String get tagNotice => 'Notice';

  @override
  String get myOrders => 'My Orders';

  @override
  String get orderFilterAll => 'All';

  @override
  String get orderFilterActive => 'Active';

  @override
  String get orderFilterDelivered => 'Delivered';

  @override
  String get orderFilterCancelled => 'Cancelled';

  @override
  String get couldNotLoadOrders => 'Could not load your orders';

  @override
  String get retry => 'Retry';

  @override
  String get noOrdersFound => 'No orders found';

  @override
  String get noOrdersYet => 'You have not placed any orders yet.';

  @override
  String noFilteredOrders(String filter) {
    return 'No $filter orders available.';
  }

  @override
  String get exploreFreshProduce => 'Explore Fresh Produce';

  @override
  String orderNumberLabel(String id) {
    return 'Order #$id';
  }

  @override
  String moreItemsCount(int count) {
    return '+ $count more items';
  }

  @override
  String get deliveryMethodPickup => 'PICKUP';

  @override
  String get deliveryMethodDelivery => 'DELIVERY';

  @override
  String get totalColon => 'Total: ';

  @override
  String get orderStatusPending => 'Pending Confirmation';

  @override
  String get orderStatusConfirmed => 'Confirmed';

  @override
  String get orderStatusProcessing => 'Processing';

  @override
  String get orderStatusShipped => 'Out for Delivery';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderTracking => 'Order Tracking';

  @override
  String get failedToLoadOrderDetails => 'Failed to load order details';

  @override
  String get orderNotFound => 'Order not found';

  @override
  String orderStatusUpdated(String status) {
    return 'Order status updated to $status';
  }

  @override
  String unableToUpdateOrder(String error) {
    return 'Unable to update order: $error';
  }

  @override
  String get orderCancelledSubtitle => 'This order was cancelled.';

  @override
  String get orderDeliveredFarmerSubtitle =>
      'Order delivered and completed successfully.';

  @override
  String get orderDeliveredRestaurantSubtitle =>
      'Delivered to your kitchen successfully.';

  @override
  String get orderShippedFarmerSubtitle =>
      'Produce is out for delivery to the restaurant.';

  @override
  String get orderShippedRestaurantSubtitle =>
      'Produce is in transit to your kitchen.';

  @override
  String get orderProcessingFarmerSubtitle =>
      'You are harvesting and packaging this order.';

  @override
  String get orderProcessingRestaurantSubtitle =>
      'Farmer is harvesting and packaging your order.';

  @override
  String get orderConfirmedFarmerSubtitle =>
      'Order confirmed. Ready to start preparing.';

  @override
  String get orderConfirmedRestaurantSubtitle =>
      'Order confirmed by grower. Preparing fulfillment.';

  @override
  String get orderPendingFarmerSubtitle =>
      'New order received from buyer. Awaiting your confirmation.';

  @override
  String get orderPendingRestaurantSubtitle =>
      'Sent to farmer. Awaiting grower confirmation.';

  @override
  String get orderProgress => 'Order Progress';

  @override
  String get orderPlacedStep => 'Order Placed';

  @override
  String get orderPlacedFarmerDesc => 'Order received from buyer';

  @override
  String get orderPlacedRestaurantDesc => 'Order transmitted to farmer';

  @override
  String get confirmedStep => 'Confirmed';

  @override
  String get confirmedFarmerDesc => 'You confirmed the order';

  @override
  String get confirmedRestaurantDesc => 'Farmer confirmed harvest';

  @override
  String get processingStep => 'Processing';

  @override
  String get processingDesc => 'Harvesting & packaging';

  @override
  String get outForDeliveryStep => 'Out for Delivery';

  @override
  String get outForDeliveryFarmerDesc => 'On the way to buyer';

  @override
  String get outForDeliveryRestaurantDesc => 'On the way to your kitchen';

  @override
  String get deliveredStep => 'Delivered';

  @override
  String get deliveredFarmerDesc => 'Delivered & finalized';

  @override
  String get deliveredRestaurantDesc => 'Received & verified';

  @override
  String get deliveryDetails => 'Delivery Details';

  @override
  String get destinationAddress => 'Destination Address';

  @override
  String get defaultRestaurantAddress => 'Default Restaurant Kitchen Address';

  @override
  String get orderedAt => 'Ordered At';

  @override
  String get itemsInThisOrder => 'Items in this Order';

  @override
  String orderItemsCount(int count) {
    return '$count items';
  }

  @override
  String get paymentBreakdown => 'Payment Breakdown';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get transactionFee => 'Transaction Fee (5%)';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get paymentKhqr => 'Payment: KHQR (Bakong)';

  @override
  String get paymentCash => 'Payment: Cash on Delivery';

  @override
  String get declineOrder => 'Decline Order';

  @override
  String get acceptOrder => 'Accept Order';

  @override
  String get startPreparingProduce => 'Start Preparing Produce';

  @override
  String get markAsOutForDelivery => 'Mark as Out for Delivery';

  @override
  String get completeOrderDelivered => 'Complete Order (Delivered)';

  @override
  String get openChats => 'Open Chats';

  @override
  String get backToOrderManagement => 'Back to Order Management';

  @override
  String get messageGrowerFarmer => 'Message Grower / Farmer';

  @override
  String get backToMarketplace => 'Back to Marketplace';

  @override
  String get allMessages => 'All Messages';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get deliveries => 'Deliveries';

  @override
  String get support => 'Support';

  @override
  String get searchConversations => 'Search conversations...';

  @override
  String get editProfileInfo => 'Edit Profile Info';

  @override
  String get farmProducerName => 'Farm / Producer Name';

  @override
  String get location => 'Location';

  @override
  String get sustainabilityStoryBio => 'Sustainability Story / Bio';

  @override
  String get save => 'Save';

  @override
  String get profileInformationUpdated => 'Profile information updated!';

  @override
  String get viewPhoto => 'View Photo';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get avatarUpdated => 'Avatar updated!';

  @override
  String get coverPhotoUpdated => 'Cover photo updated!';

  @override
  String get coverPhotoOptions => 'Cover Photo Options';

  @override
  String get avatarOptions => 'Avatar Options';

  @override
  String get verifiedProducer => 'Verified Producer';

  @override
  String get promote => 'Promote';

  @override
  String get promoteActionTriggered => 'Promote Action Triggered';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get rating => 'Rating';

  @override
  String get since => 'Since';

  @override
  String get revenue => 'Revenue';

  @override
  String get manageInventory => 'Manage Inventory';

  @override
  String get viewOrders => 'View Orders';

  @override
  String get salesAnalytics => 'Sales Analytics';

  @override
  String get paymentSettings => 'Payment Settings';

  @override
  String get ourSustainabilityStory => 'Our Sustainability Story';

  @override
  String get certifiedOrganic => 'Certified Organic';

  @override
  String get rainwaterIrrigationSystem => 'Rainwater Irrigation System';

  @override
  String get sameDayLocalDelivery => 'Same-Day Local Delivery';

  @override
  String get sustainabilityReport => 'Sustainability Report';

  @override
  String get pesticideFree => 'Pesticide Free';

  @override
  String get renewableEnergy => 'Renewable Energy';

  @override
  String get currentOfferings => 'Current Offerings';

  @override
  String get freshFromOurLocalFarm => 'Fresh from our local farm';

  @override
  String get allProduce => 'All Produce';

  @override
  String get herbsSpices => 'Herbs & Spices';

  @override
  String get leafyGreens => 'Leafy Greens';

  @override
  String get freshHarvest => 'Fresh Harvest';

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get namePhoneNumberLocation => 'Name, Phone Number, Location';

  @override
  String get security => 'Security';

  @override
  String get changePassword => 'Change Password';

  @override
  String get preferences => 'Preferences';

  @override
  String get khmer => 'Khmer';

  @override
  String get english => 'English';

  @override
  String get receiveMarketAlerts => 'Receive market alerts';

  @override
  String get smsAlerts => 'SMS Alerts';

  @override
  String get receiveUpdatesViaSms => 'Receive updates via SMS';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get switchAppTheme => 'Switch app theme';

  @override
  String get supportAndInfo => 'Support & Info';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get aboutApp => 'About App';

  @override
  String get version210 => 'Version 2.1.0';

  @override
  String get logOut => 'Log Out';

  @override
  String get logoutConfirmation =>
      'Are you sure you want to log out of the app?';

  @override
  String get logoutFailed => 'Logout failed';

  @override
  String get logoutError => 'Logout error';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get createNewAccount => 'Create New Account';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordInstruction =>
      'Enter the phone number associated with your account. We\'ll send an OTP code to reset your password.';

  @override
  String get send => 'Send';

  @override
  String get sendCode => 'Send Code';

  @override
  String get phoneHint => '012345678 or +85512345678';

  @override
  String get unableToRequestOtp => 'Unable to request OTP';

  @override
  String get howToUseApp => 'How would you like to use PsarKasekor?';

  @override
  String get roleSelectionDescription =>
      'Join our leading agricultural network. Please choose your role to get started.';

  @override
  String get iAmRestaurant => 'I am a Restaurant';

  @override
  String get restaurantRoleDescription =>
      'Order fresh ingredients directly from local producers with reliable delivery.';

  @override
  String get buyerTag => 'Buyer';

  @override
  String get chefTag => 'Chef';

  @override
  String get iAmFarmer => 'I am a Farmer';

  @override
  String get farmerRoleDescription =>
      'Sell your bountiful harvest to major restaurants and manage wholesale orders.';

  @override
  String get sellerTag => 'Seller';

  @override
  String get producerTag => 'Producer';

  @override
  String get continueForward => 'Continue';

  @override
  String get signUpAsFarmer => 'Registering as: Farmer';

  @override
  String get signUpAsRestaurant => 'Registering as: Restaurant';

  @override
  String get createYourAccount => 'Create Your Account';

  @override
  String get signUpSubtitle => 'Join the leading agricultural trade network';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterFullName => 'Enter full name';

  @override
  String get pleaseEnterFullName => 'Please enter your full name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get reEnterPassword => 'Re-enter password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordLengthHint => 'At least 6 characters';

  @override
  String get agreeToTerms => 'I agree to the';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get andWord => 'and';

  @override
  String get mustAgreeToTerms => 'Please accept the terms and privacy policy';

  @override
  String get createAccount => 'Create Account';

  @override
  String get secureVerification => 'Secure Marketplace Verification';

  @override
  String get enterVerificationCode => 'Enter Verification Code';

  @override
  String weSentCodeTo(String phone) {
    return 'We sent a 6-digit verification code to\n$phone';
  }

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get enter6DigitCode => 'Please enter the 6-digit code';

  @override
  String get verify => 'Verify';

  @override
  String get didntReceiveCode => 'Didn\'t receive code? ';

  @override
  String get resendCode => 'Resend';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get verificationSuccess => 'Phone verified successfully';

  @override
  String get invalidOtp => 'Invalid or expired OTP';

  @override
  String get wrongNumberChange => 'Incorrect phone number? Change number';

  @override
  String yourOtpCodeIs(String otp) {
    return 'Your verification code is: $otp';
  }

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordDescription =>
      'Please create a new password that you don\'t use elsewhere.';

  @override
  String get newPassword => 'New Password';

  @override
  String get enterNewPassword => 'Enter new password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get pleaseEnterNewPassword => 'Please enter a new password';

  @override
  String get passwordResetSuccess => 'Password reset successfully';

  @override
  String get help => 'Help';

  @override
  String get accountCreatedSuccess => 'Account created successfully';

  @override
  String get setupYourProfile => 'Set Up Your Profile';

  @override
  String setupProfileSubtitle(String role) {
    return 'Add an avatar and your $role information to build trust in the marketplace';
  }

  @override
  String get chooseAvatar => 'Choose Avatar';

  @override
  String get farm => 'Farm';

  @override
  String get restaurant => 'Restaurant';

  @override
  String nameOfRole(String role) {
    return '$role Name';
  }

  @override
  String get farmerNameHint => 'e.g. Battambang Organic Farm';

  @override
  String get restaurantNameHint => 'e.g. Angkor Khmer Restaurant';

  @override
  String get addressLocation => 'Address / Location';

  @override
  String get addressHint => 'e.g. Phnom Penh or Province...';

  @override
  String get shortBio => 'Short Bio / Description';

  @override
  String get farmerBioHint =>
      'Briefly describe the agricultural produce you grow...';

  @override
  String get restaurantBioHint =>
      'Briefly describe your cuisine or ingredient needs...';

  @override
  String get saveAndStart => 'Save & Start';

  @override
  String get skipForNow => 'Skip for now (complete later)';

  @override
  String failedToPickImage(String error) {
    return 'Failed to pick image: $error';
  }

  @override
  String failedToSaveProfile(String error) {
    return 'Failed to save profile: $error';
  }
}
