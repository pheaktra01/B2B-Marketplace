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
}
