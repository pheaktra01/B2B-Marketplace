import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get chooseLanguage;

  /// No description provided for @selectLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Select your language to use\nPsarKasekor'**
  String get selectLanguageDescription;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @getStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Direct from Farm to Your Kitchen'**
  String get getStartedTitle;

  /// No description provided for @getStartedDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect with local farmers to get the freshest ingredients for your kitchen.'**
  String get getStartedDescription;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @trustedChefs.
  ///
  /// In en, this message translates to:
  /// **'Trusted by over 500 top chefs'**
  String get trustedChefs;

  /// No description provided for @termsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms and Privacy Policy'**
  String get termsPrivacy;

  /// No description provided for @farmersMarket.
  ///
  /// In en, this message translates to:
  /// **'Farmers Market'**
  String get farmersMarket;

  /// No description provided for @farmersMarketDescription.
  ///
  /// In en, this message translates to:
  /// **'Fresh agricultural products marketplace for professional chefs.'**
  String get farmersMarketDescription;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @unknownUserRole.
  ///
  /// In en, this message translates to:
  /// **'Unknown user role'**
  String get unknownUserRole;

  /// No description provided for @unableToLogin.
  ///
  /// In en, this message translates to:
  /// **'Unable to login'**
  String get unableToLogin;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning, {name}'**
  String goodMorning(Object name);

  /// No description provided for @dashboardDescription.
  ///
  /// In en, this message translates to:
  /// **'Connecting your harvest to 14 restaurant partners today.'**
  String get dashboardDescription;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSales;

  /// No description provided for @activeOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get activeOrders;

  /// No description provided for @productsListed.
  ///
  /// In en, this message translates to:
  /// **'Products Listed'**
  String get productsListed;

  /// No description provided for @monthlyGrowth.
  ///
  /// In en, this message translates to:
  /// **'Monthly Growth'**
  String get monthlyGrowth;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'ORDERS'**
  String get orders;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @inventoryAlert.
  ///
  /// In en, this message translates to:
  /// **'Inventory Alert'**
  String get inventoryAlert;

  /// No description provided for @organicTomatoAlmostSoldOut.
  ///
  /// In en, this message translates to:
  /// **'Organic Tomato is almost sold out (Only 12 kg left).'**
  String get organicTomatoAlmostSoldOut;

  /// No description provided for @restock.
  ///
  /// In en, this message translates to:
  /// **'Restock'**
  String get restock;

  /// No description provided for @marketOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Market Opportunities'**
  String get marketOpportunities;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @highDemand.
  ///
  /// In en, this message translates to:
  /// **'High 🔥'**
  String get highDemand;

  /// No description provided for @goodPrice.
  ///
  /// In en, this message translates to:
  /// **'Good Price'**
  String get goodPrice;

  /// No description provided for @demandIncreasing.
  ///
  /// In en, this message translates to:
  /// **'Demand Increasing'**
  String get demandIncreasing;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @viewMarketInsights.
  ///
  /// In en, this message translates to:
  /// **'View Market Insights'**
  String get viewMarketInsights;

  /// No description provided for @salesOverview.
  ///
  /// In en, this message translates to:
  /// **'Sales Overview'**
  String get salesOverview;

  /// No description provided for @thisWeeksRevenue.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Revenue'**
  String get thisWeeksRevenue;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'+18% Growth'**
  String get growth;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @manageOrders.
  ///
  /// In en, this message translates to:
  /// **'Manage Orders'**
  String get manageOrders;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @myProducts.
  ///
  /// In en, this message translates to:
  /// **'My Products'**
  String get myProducts;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'LOW STOCK'**
  String get lowStock;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @kgLeft.
  ///
  /// In en, this message translates to:
  /// **'{quantity} kg left'**
  String kgLeft(Object quantity);

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @priceAndInventory.
  ///
  /// In en, this message translates to:
  /// **'Price & Inventory'**
  String get priceAndInventory;

  /// No description provided for @deliveryAndReview.
  ///
  /// In en, this message translates to:
  /// **'Delivery & Review'**
  String get deliveryAndReview;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepOf(int step, int total);

  /// No description provided for @percentCompleted.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Completed'**
  String percentCompleted(int percent);

  /// No description provided for @productPhotos.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT PHOTOS'**
  String get productPhotos;

  /// No description provided for @photosCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max} photos'**
  String photosCount(int count, int max);

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @productNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Fresh Organic Bok Choy'**
  String get productNameHint;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @vegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get vegetables;

  /// No description provided for @fruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get fruits;

  /// No description provided for @herbsAndSpices.
  ///
  /// In en, this message translates to:
  /// **'Herbs & Spices'**
  String get herbsAndSpices;

  /// No description provided for @riceAndGrains.
  ///
  /// In en, this message translates to:
  /// **'Rice & Grains'**
  String get riceAndGrains;

  /// No description provided for @eggsAndDairy.
  ///
  /// In en, this message translates to:
  /// **'Eggs & Dairy'**
  String get eggsAndDairy;

  /// No description provided for @productCondition.
  ///
  /// In en, this message translates to:
  /// **'Product Condition'**
  String get productCondition;

  /// No description provided for @fresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get fresh;

  /// No description provided for @standardProduce.
  ///
  /// In en, this message translates to:
  /// **'Standard produce'**
  String get standardProduce;

  /// No description provided for @organic.
  ///
  /// In en, this message translates to:
  /// **'Organic'**
  String get organic;

  /// No description provided for @chemicalFree.
  ///
  /// In en, this message translates to:
  /// **'Chemical-free'**
  String get chemicalFree;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe quality, taste, or harvest details...'**
  String get descriptionHint;

  /// No description provided for @sellingPricePerKg.
  ///
  /// In en, this message translates to:
  /// **'Selling Price per kg'**
  String get sellingPricePerKg;

  /// No description provided for @perKg.
  ///
  /// In en, this message translates to:
  /// **'/ kg'**
  String get perKg;

  /// No description provided for @availableQuantity.
  ///
  /// In en, this message translates to:
  /// **'Available Quantity'**
  String get availableQuantity;

  /// No description provided for @minimumOrder.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order'**
  String get minimumOrder;

  /// No description provided for @harvestDate.
  ///
  /// In en, this message translates to:
  /// **'Harvest Date'**
  String get harvestDate;

  /// No description provided for @availableUntil.
  ///
  /// In en, this message translates to:
  /// **'Available Until'**
  String get availableUntil;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @marketRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Market Recommendation'**
  String get marketRecommendation;

  /// No description provided for @currentRestaurantDemand.
  ///
  /// In en, this message translates to:
  /// **'Current restaurant demand'**
  String get currentRestaurantDemand;

  /// No description provided for @typicalMarketPrice.
  ///
  /// In en, this message translates to:
  /// **'Typical market price'**
  String get typicalMarketPrice;

  /// No description provided for @recommendedPrice.
  ///
  /// In en, this message translates to:
  /// **'Recommended price'**
  String get recommendedPrice;

  /// No description provided for @useRecommendedPrice.
  ///
  /// In en, this message translates to:
  /// **'Use Recommended Price ({price})'**
  String useRecommendedPrice(String price);

  /// No description provided for @locationFarmOrigin.
  ///
  /// In en, this message translates to:
  /// **'Location / Farm Origin'**
  String get locationFarmOrigin;

  /// No description provided for @phnomPenh.
  ///
  /// In en, this message translates to:
  /// **'Phnom Penh'**
  String get phnomPenh;

  /// No description provided for @kandal.
  ///
  /// In en, this message translates to:
  /// **'Kandal'**
  String get kandal;

  /// No description provided for @battambang.
  ///
  /// In en, this message translates to:
  /// **'Battambang'**
  String get battambang;

  /// No description provided for @siemReap.
  ///
  /// In en, this message translates to:
  /// **'Siem Reap'**
  String get siemReap;

  /// No description provided for @kampongCham.
  ///
  /// In en, this message translates to:
  /// **'Kampong Cham'**
  String get kampongCham;

  /// No description provided for @deliveryMethod.
  ///
  /// In en, this message translates to:
  /// **'Delivery Method'**
  String get deliveryMethod;

  /// No description provided for @farmerDelivery.
  ///
  /// In en, this message translates to:
  /// **'Farmer Delivery'**
  String get farmerDelivery;

  /// No description provided for @deliverToBuyer.
  ///
  /// In en, this message translates to:
  /// **'Deliver to buyer'**
  String get deliverToBuyer;

  /// No description provided for @buyerPickup.
  ///
  /// In en, this message translates to:
  /// **'Buyer Pickup'**
  String get buyerPickup;

  /// No description provided for @pickupAtFarm.
  ///
  /// In en, this message translates to:
  /// **'Pickup at farm'**
  String get pickupAtFarm;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFee;

  /// No description provided for @productPreview.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT PREVIEW'**
  String get productPreview;

  /// No description provided for @freshProduce.
  ///
  /// In en, this message translates to:
  /// **'Fresh Produce'**
  String get freshProduce;

  /// No description provided for @yourFarm.
  ///
  /// In en, this message translates to:
  /// **'Your Farm'**
  String get yourFarm;

  /// No description provided for @publishProduct.
  ///
  /// In en, this message translates to:
  /// **'Publish Product'**
  String get publishProduct;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get nextStep;

  /// No description provided for @productPublished.
  ///
  /// In en, this message translates to:
  /// **'Product Published!'**
  String get productPublished;

  /// No description provided for @productPublishedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your product is now available for restaurants in Cambodia to discover and order.'**
  String get productPublishedDescription;

  /// No description provided for @viewProductListing.
  ///
  /// In en, this message translates to:
  /// **'View Product Listing'**
  String get viewProductListing;

  /// No description provided for @backToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get backToDashboard;

  /// No description provided for @uploadProductPhotos.
  ///
  /// In en, this message translates to:
  /// **'Upload Product Photos'**
  String get uploadProductPhotos;

  /// No description provided for @addUpToFivePhotos.
  ///
  /// In en, this message translates to:
  /// **'Add up to 5 photos'**
  String get addUpToFivePhotos;

  /// No description provided for @addMorePhotos.
  ///
  /// In en, this message translates to:
  /// **'Add More Photos ({count}/{max})'**
  String addMorePhotos(int count, int max);

  /// No description provided for @mainPhoto.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get mainPhoto;

  /// No description provided for @uploadAtLeastOnePhoto.
  ///
  /// In en, this message translates to:
  /// **'Please upload at least one product photo'**
  String get uploadAtLeastOnePhoto;

  /// No description provided for @enterProductName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a product name'**
  String get enterProductName;

  /// No description provided for @enterProductDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a product description'**
  String get enterProductDescription;

  /// No description provided for @enterValidSellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid selling price'**
  String get enterValidSellingPrice;

  /// No description provided for @enterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid available quantity'**
  String get enterValidQuantity;

  /// No description provided for @enterValidMinimumOrder.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid minimum order'**
  String get enterValidMinimumOrder;

  /// No description provided for @minimumOrderGreaterThanQuantity.
  ///
  /// In en, this message translates to:
  /// **'Minimum order cannot be greater than available quantity'**
  String get minimumOrderGreaterThanQuantity;

  /// No description provided for @availableUntilBeforeHarvest.
  ///
  /// In en, this message translates to:
  /// **'Available Until cannot be before Harvest Date'**
  String get availableUntilBeforeHarvest;

  /// No description provided for @enterValidDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid delivery fee'**
  String get enterValidDeliveryFee;

  /// No description provided for @failedToSelectImages.
  ///
  /// In en, this message translates to:
  /// **'Failed to select images'**
  String get failedToSelectImages;

  /// No description provided for @failedToPublishProduct.
  ///
  /// In en, this message translates to:
  /// **'Failed to publish product'**
  String get failedToPublishProduct;

  /// No description provided for @maximumImages.
  ///
  /// In en, this message translates to:
  /// **'You can upload a maximum of {max} images'**
  String maximumImages(int max);

  /// No description provided for @onlyMoreImages.
  ///
  /// In en, this message translates to:
  /// **'Only {remaining} more image(s) can be added. Maximum is {max}.'**
  String onlyMoreImages(int remaining, int max);

  /// No description provided for @availableLabel.
  ///
  /// In en, this message translates to:
  /// **'Available: '**
  String get availableLabel;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @inCart.
  ///
  /// In en, this message translates to:
  /// **'In Cart'**
  String get inCart;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @allOrders.
  ///
  /// In en, this message translates to:
  /// **'All Orders'**
  String get allOrders;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparing;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @orderManagement.
  ///
  /// In en, this message translates to:
  /// **'Order Management'**
  String get orderManagement;

  /// No description provided for @fiveMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'5 mins ago'**
  String get fiveMinutesAgo;

  /// No description provided for @heirloomTomatoes.
  ///
  /// In en, this message translates to:
  /// **'Heirloom Tomatoes'**
  String get heirloomTomatoes;

  /// No description provided for @babyArugula.
  ///
  /// In en, this message translates to:
  /// **'Baby Arugula'**
  String get babyArugula;

  /// No description provided for @microgreensMix.
  ///
  /// In en, this message translates to:
  /// **'Microgreens Mix'**
  String get microgreensMix;

  /// No description provided for @rainbowCarrots.
  ///
  /// In en, this message translates to:
  /// **'Rainbow Carrots (Bunch)'**
  String get rainbowCarrots;

  /// No description provided for @naturalHoney.
  ///
  /// In en, this message translates to:
  /// **'Natural Honey'**
  String get naturalHoney;

  /// No description provided for @sourdoughStarterKit.
  ///
  /// In en, this message translates to:
  /// **'Sourdough Starter Kit'**
  String get sourdoughStarterKit;

  /// No description provided for @butterheadLettuce.
  ///
  /// In en, this message translates to:
  /// **'Butterhead Lettuce (30 heads)'**
  String get butterheadLettuce;

  /// No description provided for @freshMint.
  ///
  /// In en, this message translates to:
  /// **'Fresh Mint'**
  String get freshMint;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get more;

  /// No description provided for @cases.
  ///
  /// In en, this message translates to:
  /// **'Cases'**
  String get cases;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @readyForPickup.
  ///
  /// In en, this message translates to:
  /// **'Ready for Pickup'**
  String get readyForPickup;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @startPreparing.
  ///
  /// In en, this message translates to:
  /// **'Start Preparing'**
  String get startPreparing;

  /// No description provided for @markAsReady.
  ///
  /// In en, this message translates to:
  /// **'Mark as Ready'**
  String get markAsReady;

  /// No description provided for @completeOrder.
  ///
  /// In en, this message translates to:
  /// **'Complete Order'**
  String get completeOrder;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @manageProductsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage the products you have listed for restaurants.'**
  String get manageProductsDescription;

  /// No description provided for @activeProducts.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE PRODUCTS'**
  String get activeProducts;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'OUT OF STOCK'**
  String get outOfStock;

  /// No description provided for @totalProducts.
  ///
  /// In en, this message translates to:
  /// **'TOTAL PRODUCTS'**
  String get totalProducts;

  /// No description provided for @allItems.
  ///
  /// In en, this message translates to:
  /// **'All Items'**
  String get allItems;

  /// No description provided for @microgreens.
  ///
  /// In en, this message translates to:
  /// **'Microgreens'**
  String get microgreens;

  /// No description provided for @searchYourProducts.
  ///
  /// In en, this message translates to:
  /// **'Search your products...'**
  String get searchYourProducts;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @noMatchingProducts.
  ///
  /// In en, this message translates to:
  /// **'No matching products'**
  String get noMatchingProducts;

  /// No description provided for @noProductsListedYet.
  ///
  /// In en, this message translates to:
  /// **'No products listed yet'**
  String get noProductsListedYet;

  /// No description provided for @tryChangingSearchFilter.
  ///
  /// In en, this message translates to:
  /// **'Try changing your search or filter.'**
  String get tryChangingSearchFilter;

  /// No description provided for @addFirstProductDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your first product to start selling to restaurants.'**
  String get addFirstProductDescription;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @unableToLoadProducts.
  ///
  /// In en, this message translates to:
  /// **'Unable to load products'**
  String get unableToLoadProducts;

  /// No description provided for @unknownErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred.'**
  String get unknownErrorOccurred;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product?'**
  String get deleteProduct;

  /// No description provided for @deleteProductConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String deleteProductConfirmation(Object name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @productDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully.'**
  String get productDeletedSuccessfully;

  /// No description provided for @productIsNowAvailable.
  ///
  /// In en, this message translates to:
  /// **'Product is now available.'**
  String get productIsNowAvailable;

  /// No description provided for @productIsNowUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Product is now unavailable.'**
  String get productIsNowUnavailable;

  /// No description provided for @failedToUpdateAvailability.
  ///
  /// In en, this message translates to:
  /// **'Failed to update availability: {error}'**
  String failedToUpdateAvailability(Object error);

  /// No description provided for @failedToDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product: {error}'**
  String failedToDeleteProduct(Object error);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// No description provided for @newNotifications.
  ///
  /// In en, this message translates to:
  /// **'{count} NEW'**
  String newNotifications(Object count);

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New Order #{orderNumber}'**
  String newOrder(Object orderNumber);

  /// No description provided for @orderMessage.
  ///
  /// In en, this message translates to:
  /// **'{restaurantName} ordered {quantity}kg of {productName}.'**
  String orderMessage(
    Object productName,
    Object quantity,
    Object restaurantName,
  );

  /// No description provided for @viewOrder.
  ///
  /// In en, this message translates to:
  /// **'View Order'**
  String get viewOrder;

  /// No description provided for @messageFromChef.
  ///
  /// In en, this message translates to:
  /// **'Message from Chef {chefName}'**
  String messageFromChef(Object chefName);

  /// No description provided for @chefMessage.
  ///
  /// In en, this message translates to:
  /// **'\"Can we increase the delivery quantity for Tuesday? I need an extra 20 crates...\"'**
  String get chefMessage;

  /// No description provided for @replyNow.
  ///
  /// In en, this message translates to:
  /// **'Reply Now'**
  String get replyNow;

  /// No description provided for @paymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment Received'**
  String get paymentReceived;

  /// No description provided for @paymentProcessed.
  ///
  /// In en, this message translates to:
  /// **'Your payment of {amount} for {period} has been processed successfully.'**
  String paymentProcessed(Object amount, Object period);

  /// No description provided for @checkBalance.
  ///
  /// In en, this message translates to:
  /// **'Check Balance >'**
  String get checkBalance;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get yesterday;

  /// No description provided for @orderDelivered.
  ///
  /// In en, this message translates to:
  /// **'Order Delivered'**
  String get orderDelivered;

  /// No description provided for @orderDeliveredMessage.
  ///
  /// In en, this message translates to:
  /// **'Order #{orderNumber} was successfully delivered to {restaurantName}.'**
  String orderDeliveredMessage(Object orderNumber, Object restaurantName);

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @systemUpdate.
  ///
  /// In en, this message translates to:
  /// **'System Update'**
  String get systemUpdate;

  /// No description provided for @systemUpdateMessage.
  ///
  /// In en, this message translates to:
  /// **'Verdant system maintenance complete. The new delivery tracking feature is now available!'**
  String get systemUpdateMessage;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(Object minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(Object hours);

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{number}'**
  String orderNumber(Object number);

  /// No description provided for @unableToLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Unable to load notifications'**
  String get unableToLoadNotifications;

  /// No description provided for @notificationRemoved.
  ///
  /// In en, this message translates to:
  /// **'Notification removed'**
  String get notificationRemoved;

  /// No description provided for @clearAllNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all notifications?'**
  String get clearAllNotificationsTitle;

  /// No description provided for @clearAllNotificationsContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove all your notifications.'**
  String get clearAllNotificationsContent;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @allNotificationsCleared.
  ///
  /// In en, this message translates to:
  /// **'All notifications cleared'**
  String get allNotificationsCleared;

  /// No description provided for @clearAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear all notifications'**
  String get clearAllNotifications;

  /// No description provided for @sendTestNotification.
  ///
  /// In en, this message translates to:
  /// **'Send Test Notification'**
  String get sendTestNotification;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent! Check your lock screen & status bar.'**
  String get testNotificationSent;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @noNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'You will receive real-time updates here for orders, messages, stock, payments, and account activities.'**
  String get noNotificationsDescription;

  /// No description provided for @noCategoryNotifications.
  ///
  /// In en, this message translates to:
  /// **'No {category} notifications'**
  String noCategoryNotifications(String category);

  /// No description provided for @categoryNotificationsHeader.
  ///
  /// In en, this message translates to:
  /// **'{category} NOTIFICATIONS'**
  String categoryNotificationsHeader(String category);

  /// No description provided for @securityAlert.
  ///
  /// In en, this message translates to:
  /// **'Security Alert'**
  String get securityAlert;

  /// No description provided for @newLoginDetected.
  ///
  /// In en, this message translates to:
  /// **'A new login was detected on your account.'**
  String get newLoginDetected;

  /// No description provided for @securityAlertNotice.
  ///
  /// In en, this message translates to:
  /// **'If this was you, you can safely ignore this notice. If you did not log in recently, we recommend reviewing your profile or updating your security credentials.'**
  String get securityAlertNotice;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @notifCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notifCategoryAll;

  /// No description provided for @notifCategoryOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get notifCategoryOrders;

  /// No description provided for @notifCategoryMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get notifCategoryMessages;

  /// No description provided for @notifCategoryPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get notifCategoryPayments;

  /// No description provided for @notifCategoryStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get notifCategoryStock;

  /// No description provided for @notifCategoryAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get notifCategoryAccount;

  /// No description provided for @notifCategorySystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get notifCategorySystem;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(int days);

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @tagOrderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get tagOrderPlaced;

  /// No description provided for @tagNewOrder.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get tagNewOrder;

  /// No description provided for @tagAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get tagAccepted;

  /// No description provided for @tagRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get tagRejected;

  /// No description provided for @tagReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get tagReady;

  /// No description provided for @tagCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get tagCompleted;

  /// No description provided for @tagCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get tagCancelled;

  /// No description provided for @tagOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get tagOrder;

  /// No description provided for @tagPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get tagPhoto;

  /// No description provided for @tagOrderChat.
  ///
  /// In en, this message translates to:
  /// **'Order Chat'**
  String get tagOrderChat;

  /// No description provided for @tagChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get tagChat;

  /// No description provided for @tagPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get tagPaymentFailed;

  /// No description provided for @tagPaymentDone.
  ///
  /// In en, this message translates to:
  /// **'Payment Done'**
  String get tagPaymentDone;

  /// No description provided for @tagPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get tagPayment;

  /// No description provided for @tagOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get tagOutOfStock;

  /// No description provided for @tagLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get tagLowStock;

  /// No description provided for @tagPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get tagPublished;

  /// No description provided for @tagUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get tagUpdated;

  /// No description provided for @tagInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get tagInventory;

  /// No description provided for @tagSecurityAlert.
  ///
  /// In en, this message translates to:
  /// **'Security Alert'**
  String get tagSecurityAlert;

  /// No description provided for @tagDeviceLogin.
  ///
  /// In en, this message translates to:
  /// **'Device Login'**
  String get tagDeviceLogin;

  /// No description provided for @tagPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get tagPassword;

  /// No description provided for @tagPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get tagPhone;

  /// No description provided for @tagAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get tagAccount;

  /// No description provided for @tagAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get tagAnnouncement;

  /// No description provided for @tagMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get tagMaintenance;

  /// No description provided for @tagNewFeature.
  ///
  /// In en, this message translates to:
  /// **'New Feature'**
  String get tagNewFeature;

  /// No description provided for @tagPolicyUpdate.
  ///
  /// In en, this message translates to:
  /// **'Policy Update'**
  String get tagPolicyUpdate;

  /// No description provided for @tagInterruption.
  ///
  /// In en, this message translates to:
  /// **'Interruption'**
  String get tagInterruption;

  /// No description provided for @tagNotice.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get tagNotice;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @orderFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get orderFilterAll;

  /// No description provided for @orderFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get orderFilterActive;

  /// No description provided for @orderFilterDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderFilterDelivered;

  /// No description provided for @orderFilterCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderFilterCancelled;

  /// No description provided for @couldNotLoadOrders.
  ///
  /// In en, this message translates to:
  /// **'Could not load your orders'**
  String get couldNotLoadOrders;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get noOrdersFound;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'You have not placed any orders yet.'**
  String get noOrdersYet;

  /// No description provided for @noFilteredOrders.
  ///
  /// In en, this message translates to:
  /// **'No {filter} orders available.'**
  String noFilteredOrders(String filter);

  /// No description provided for @exploreFreshProduce.
  ///
  /// In en, this message translates to:
  /// **'Explore Fresh Produce'**
  String get exploreFreshProduce;

  /// No description provided for @orderNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderNumberLabel(String id);

  /// No description provided for @moreItemsCount.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more items'**
  String moreItemsCount(int count);

  /// No description provided for @deliveryMethodPickup.
  ///
  /// In en, this message translates to:
  /// **'PICKUP'**
  String get deliveryMethodPickup;

  /// No description provided for @deliveryMethodDelivery.
  ///
  /// In en, this message translates to:
  /// **'DELIVERY'**
  String get deliveryMethodDelivery;

  /// No description provided for @totalColon.
  ///
  /// In en, this message translates to:
  /// **'Total: '**
  String get totalColon;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Confirmation'**
  String get orderStatusPending;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get orderStatusProcessing;

  /// No description provided for @orderStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Out for Delivery'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @orderTracking.
  ///
  /// In en, this message translates to:
  /// **'Order Tracking'**
  String get orderTracking;

  /// No description provided for @failedToLoadOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load order details'**
  String get failedToLoadOrderDetails;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orderNotFound;

  /// No description provided for @orderStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Order status updated to {status}'**
  String orderStatusUpdated(String status);

  /// No description provided for @unableToUpdateOrder.
  ///
  /// In en, this message translates to:
  /// **'Unable to update order: {error}'**
  String unableToUpdateOrder(String error);

  /// No description provided for @orderCancelledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This order was cancelled.'**
  String get orderCancelledSubtitle;

  /// No description provided for @orderDeliveredFarmerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Order delivered and completed successfully.'**
  String get orderDeliveredFarmerSubtitle;

  /// No description provided for @orderDeliveredRestaurantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delivered to your kitchen successfully.'**
  String get orderDeliveredRestaurantSubtitle;

  /// No description provided for @orderShippedFarmerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Produce is out for delivery to the restaurant.'**
  String get orderShippedFarmerSubtitle;

  /// No description provided for @orderShippedRestaurantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Produce is in transit to your kitchen.'**
  String get orderShippedRestaurantSubtitle;

  /// No description provided for @orderProcessingFarmerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are harvesting and packaging this order.'**
  String get orderProcessingFarmerSubtitle;

  /// No description provided for @orderProcessingRestaurantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Farmer is harvesting and packaging your order.'**
  String get orderProcessingRestaurantSubtitle;

  /// No description provided for @orderConfirmedFarmerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed. Ready to start preparing.'**
  String get orderConfirmedFarmerSubtitle;

  /// No description provided for @orderConfirmedRestaurantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed by grower. Preparing fulfillment.'**
  String get orderConfirmedRestaurantSubtitle;

  /// No description provided for @orderPendingFarmerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'New order received from buyer. Awaiting your confirmation.'**
  String get orderPendingFarmerSubtitle;

  /// No description provided for @orderPendingRestaurantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sent to farmer. Awaiting grower confirmation.'**
  String get orderPendingRestaurantSubtitle;

  /// No description provided for @orderProgress.
  ///
  /// In en, this message translates to:
  /// **'Order Progress'**
  String get orderProgress;

  /// No description provided for @orderPlacedStep.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get orderPlacedStep;

  /// No description provided for @orderPlacedFarmerDesc.
  ///
  /// In en, this message translates to:
  /// **'Order received from buyer'**
  String get orderPlacedFarmerDesc;

  /// No description provided for @orderPlacedRestaurantDesc.
  ///
  /// In en, this message translates to:
  /// **'Order transmitted to farmer'**
  String get orderPlacedRestaurantDesc;

  /// No description provided for @confirmedStep.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmedStep;

  /// No description provided for @confirmedFarmerDesc.
  ///
  /// In en, this message translates to:
  /// **'You confirmed the order'**
  String get confirmedFarmerDesc;

  /// No description provided for @confirmedRestaurantDesc.
  ///
  /// In en, this message translates to:
  /// **'Farmer confirmed harvest'**
  String get confirmedRestaurantDesc;

  /// No description provided for @processingStep.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processingStep;

  /// No description provided for @processingDesc.
  ///
  /// In en, this message translates to:
  /// **'Harvesting & packaging'**
  String get processingDesc;

  /// No description provided for @outForDeliveryStep.
  ///
  /// In en, this message translates to:
  /// **'Out for Delivery'**
  String get outForDeliveryStep;

  /// No description provided for @outForDeliveryFarmerDesc.
  ///
  /// In en, this message translates to:
  /// **'On the way to buyer'**
  String get outForDeliveryFarmerDesc;

  /// No description provided for @outForDeliveryRestaurantDesc.
  ///
  /// In en, this message translates to:
  /// **'On the way to your kitchen'**
  String get outForDeliveryRestaurantDesc;

  /// No description provided for @deliveredStep.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get deliveredStep;

  /// No description provided for @deliveredFarmerDesc.
  ///
  /// In en, this message translates to:
  /// **'Delivered & finalized'**
  String get deliveredFarmerDesc;

  /// No description provided for @deliveredRestaurantDesc.
  ///
  /// In en, this message translates to:
  /// **'Received & verified'**
  String get deliveredRestaurantDesc;

  /// No description provided for @deliveryDetails.
  ///
  /// In en, this message translates to:
  /// **'Delivery Details'**
  String get deliveryDetails;

  /// No description provided for @destinationAddress.
  ///
  /// In en, this message translates to:
  /// **'Destination Address'**
  String get destinationAddress;

  /// No description provided for @defaultRestaurantAddress.
  ///
  /// In en, this message translates to:
  /// **'Default Restaurant Kitchen Address'**
  String get defaultRestaurantAddress;

  /// No description provided for @orderedAt.
  ///
  /// In en, this message translates to:
  /// **'Ordered At'**
  String get orderedAt;

  /// No description provided for @itemsInThisOrder.
  ///
  /// In en, this message translates to:
  /// **'Items in this Order'**
  String get itemsInThisOrder;

  /// No description provided for @orderItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String orderItemsCount(int count);

  /// No description provided for @paymentBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Payment Breakdown'**
  String get paymentBreakdown;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @transactionFee.
  ///
  /// In en, this message translates to:
  /// **'Transaction Fee (5%)'**
  String get transactionFee;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @paymentKhqr.
  ///
  /// In en, this message translates to:
  /// **'Payment: KHQR (Bakong)'**
  String get paymentKhqr;

  /// No description provided for @paymentCash.
  ///
  /// In en, this message translates to:
  /// **'Payment: Cash on Delivery'**
  String get paymentCash;

  /// No description provided for @declineOrder.
  ///
  /// In en, this message translates to:
  /// **'Decline Order'**
  String get declineOrder;

  /// No description provided for @acceptOrder.
  ///
  /// In en, this message translates to:
  /// **'Accept Order'**
  String get acceptOrder;

  /// No description provided for @startPreparingProduce.
  ///
  /// In en, this message translates to:
  /// **'Start Preparing Produce'**
  String get startPreparingProduce;

  /// No description provided for @markAsOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Mark as Out for Delivery'**
  String get markAsOutForDelivery;

  /// No description provided for @completeOrderDelivered.
  ///
  /// In en, this message translates to:
  /// **'Complete Order (Delivered)'**
  String get completeOrderDelivered;

  /// No description provided for @openChats.
  ///
  /// In en, this message translates to:
  /// **'Open Chats'**
  String get openChats;

  /// No description provided for @backToOrderManagement.
  ///
  /// In en, this message translates to:
  /// **'Back to Order Management'**
  String get backToOrderManagement;

  /// No description provided for @messageGrowerFarmer.
  ///
  /// In en, this message translates to:
  /// **'Message Grower / Farmer'**
  String get messageGrowerFarmer;

  /// No description provided for @backToMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Back to Marketplace'**
  String get backToMarketplace;

  /// No description provided for @allMessages.
  ///
  /// In en, this message translates to:
  /// **'All Messages'**
  String get allMessages;

  /// No description provided for @restaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurants;

  /// No description provided for @deliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get deliveries;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @searchConversations.
  ///
  /// In en, this message translates to:
  /// **'Search conversations...'**
  String get searchConversations;

  /// No description provided for @editProfileInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile Info'**
  String get editProfileInfo;

  /// No description provided for @farmProducerName.
  ///
  /// In en, this message translates to:
  /// **'Farm / Producer Name'**
  String get farmProducerName;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @sustainabilityStoryBio.
  ///
  /// In en, this message translates to:
  /// **'Sustainability Story / Bio'**
  String get sustainabilityStoryBio;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @profileInformationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile information updated!'**
  String get profileInformationUpdated;

  /// No description provided for @viewPhoto.
  ///
  /// In en, this message translates to:
  /// **'View Photo'**
  String get viewPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @avatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated!'**
  String get avatarUpdated;

  /// No description provided for @coverPhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Cover photo updated!'**
  String get coverPhotoUpdated;

  /// No description provided for @coverPhotoOptions.
  ///
  /// In en, this message translates to:
  /// **'Cover Photo Options'**
  String get coverPhotoOptions;

  /// No description provided for @avatarOptions.
  ///
  /// In en, this message translates to:
  /// **'Avatar Options'**
  String get avatarOptions;

  /// No description provided for @verifiedProducer.
  ///
  /// In en, this message translates to:
  /// **'Verified Producer'**
  String get verifiedProducer;

  /// No description provided for @promote.
  ///
  /// In en, this message translates to:
  /// **'Promote'**
  String get promote;

  /// No description provided for @promoteActionTriggered.
  ///
  /// In en, this message translates to:
  /// **'Promote Action Triggered'**
  String get promoteActionTriggered;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @since.
  ///
  /// In en, this message translates to:
  /// **'Since'**
  String get since;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @manageInventory.
  ///
  /// In en, this message translates to:
  /// **'Manage Inventory'**
  String get manageInventory;

  /// No description provided for @viewOrders.
  ///
  /// In en, this message translates to:
  /// **'View Orders'**
  String get viewOrders;

  /// No description provided for @salesAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Sales Analytics'**
  String get salesAnalytics;

  /// No description provided for @paymentSettings.
  ///
  /// In en, this message translates to:
  /// **'Payment Settings'**
  String get paymentSettings;

  /// No description provided for @ourSustainabilityStory.
  ///
  /// In en, this message translates to:
  /// **'Our Sustainability Story'**
  String get ourSustainabilityStory;

  /// No description provided for @certifiedOrganic.
  ///
  /// In en, this message translates to:
  /// **'Certified Organic'**
  String get certifiedOrganic;

  /// No description provided for @rainwaterIrrigationSystem.
  ///
  /// In en, this message translates to:
  /// **'Rainwater Irrigation System'**
  String get rainwaterIrrigationSystem;

  /// No description provided for @sameDayLocalDelivery.
  ///
  /// In en, this message translates to:
  /// **'Same-Day Local Delivery'**
  String get sameDayLocalDelivery;

  /// No description provided for @sustainabilityReport.
  ///
  /// In en, this message translates to:
  /// **'Sustainability Report'**
  String get sustainabilityReport;

  /// No description provided for @pesticideFree.
  ///
  /// In en, this message translates to:
  /// **'Pesticide Free'**
  String get pesticideFree;

  /// No description provided for @renewableEnergy.
  ///
  /// In en, this message translates to:
  /// **'Renewable Energy'**
  String get renewableEnergy;

  /// No description provided for @currentOfferings.
  ///
  /// In en, this message translates to:
  /// **'Current Offerings'**
  String get currentOfferings;

  /// No description provided for @freshFromOurLocalFarm.
  ///
  /// In en, this message translates to:
  /// **'Fresh from our local farm'**
  String get freshFromOurLocalFarm;

  /// No description provided for @allProduce.
  ///
  /// In en, this message translates to:
  /// **'All Produce'**
  String get allProduce;

  /// No description provided for @herbsSpices.
  ///
  /// In en, this message translates to:
  /// **'Herbs & Spices'**
  String get herbsSpices;

  /// No description provided for @leafyGreens.
  ///
  /// In en, this message translates to:
  /// **'Leafy Greens'**
  String get leafyGreens;

  /// No description provided for @freshHarvest.
  ///
  /// In en, this message translates to:
  /// **'Fresh Harvest'**
  String get freshHarvest;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @namePhoneNumberLocation.
  ///
  /// In en, this message translates to:
  /// **'Name, Phone Number, Location'**
  String get namePhoneNumberLocation;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @khmer.
  ///
  /// In en, this message translates to:
  /// **'Khmer'**
  String get khmer;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @receiveMarketAlerts.
  ///
  /// In en, this message translates to:
  /// **'Receive market alerts'**
  String get receiveMarketAlerts;

  /// No description provided for @smsAlerts.
  ///
  /// In en, this message translates to:
  /// **'SMS Alerts'**
  String get smsAlerts;

  /// No description provided for @receiveUpdatesViaSms.
  ///
  /// In en, this message translates to:
  /// **'Receive updates via SMS'**
  String get receiveUpdatesViaSms;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @switchAppTheme.
  ///
  /// In en, this message translates to:
  /// **'Switch app theme'**
  String get switchAppTheme;

  /// No description provided for @supportAndInfo.
  ///
  /// In en, this message translates to:
  /// **'Support & Info'**
  String get supportAndInfo;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @version210.
  ///
  /// In en, this message translates to:
  /// **'Version 2.1.0'**
  String get version210;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of the app?'**
  String get logoutConfirmation;

  /// No description provided for @logoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed'**
  String get logoutFailed;

  /// No description provided for @logoutError.
  ///
  /// In en, this message translates to:
  /// **'Logout error'**
  String get logoutError;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get createNewAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter the phone number associated with your account. We\'ll send an OTP code to reset your password.'**
  String get forgotPasswordInstruction;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'012345678 or +85512345678'**
  String get phoneHint;

  /// No description provided for @unableToRequestOtp.
  ///
  /// In en, this message translates to:
  /// **'Unable to request OTP'**
  String get unableToRequestOtp;

  /// No description provided for @howToUseApp.
  ///
  /// In en, this message translates to:
  /// **'How would you like to use PsarKasekor?'**
  String get howToUseApp;

  /// No description provided for @roleSelectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Join our leading agricultural network. Please choose your role to get started.'**
  String get roleSelectionDescription;

  /// No description provided for @iAmRestaurant.
  ///
  /// In en, this message translates to:
  /// **'I am a Restaurant'**
  String get iAmRestaurant;

  /// No description provided for @restaurantRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Order fresh ingredients directly from local producers with reliable delivery.'**
  String get restaurantRoleDescription;

  /// No description provided for @buyerTag.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get buyerTag;

  /// No description provided for @chefTag.
  ///
  /// In en, this message translates to:
  /// **'Chef'**
  String get chefTag;

  /// No description provided for @iAmFarmer.
  ///
  /// In en, this message translates to:
  /// **'I am a Farmer'**
  String get iAmFarmer;

  /// No description provided for @farmerRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Sell your bountiful harvest to major restaurants and manage wholesale orders.'**
  String get farmerRoleDescription;

  /// No description provided for @sellerTag.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get sellerTag;

  /// No description provided for @producerTag.
  ///
  /// In en, this message translates to:
  /// **'Producer'**
  String get producerTag;

  /// No description provided for @continueForward.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueForward;

  /// No description provided for @signUpAsFarmer.
  ///
  /// In en, this message translates to:
  /// **'Registering as: Farmer'**
  String get signUpAsFarmer;

  /// No description provided for @signUpAsRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Registering as: Restaurant'**
  String get signUpAsRestaurant;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get createYourAccount;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the leading agricultural trade network'**
  String get signUpSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enterFullName;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @reEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get reEnterPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordLengthHint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordLengthHint;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the'**
  String get agreeToTerms;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @andWord.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get andWord;

  /// No description provided for @mustAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms and privacy policy'**
  String get mustAgreeToTerms;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @secureVerification.
  ///
  /// In en, this message translates to:
  /// **'Secure Marketplace Verification'**
  String get secureVerification;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterVerificationCode;

  /// No description provided for @weSentCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit verification code to\n{phone}'**
  String weSentCodeTo(String phone);

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @enter6DigitCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit code'**
  String get enter6DigitCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive code? '**
  String get didntReceiveCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @verificationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Phone verified successfully'**
  String get verificationSuccess;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired OTP'**
  String get invalidOtp;

  /// No description provided for @wrongNumberChange.
  ///
  /// In en, this message translates to:
  /// **'Incorrect phone number? Change number'**
  String get wrongNumberChange;

  /// No description provided for @yourOtpCodeIs.
  ///
  /// In en, this message translates to:
  /// **'Your verification code is: {otp}'**
  String yourOtpCodeIs(String otp);

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Please create a new password that you don\'t use elsewhere.'**
  String get resetPasswordDescription;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get passwordResetSuccess;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreatedSuccess;

  /// No description provided for @setupYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Set Up Your Profile'**
  String get setupYourProfile;

  /// No description provided for @setupProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add an avatar and your {role} information to build trust in the marketplace'**
  String setupProfileSubtitle(String role);

  /// No description provided for @chooseAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose Avatar'**
  String get chooseAvatar;

  /// No description provided for @farm.
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get farm;

  /// No description provided for @restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// No description provided for @nameOfRole.
  ///
  /// In en, this message translates to:
  /// **'{role} Name'**
  String nameOfRole(String role);

  /// No description provided for @farmerNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Battambang Organic Farm'**
  String get farmerNameHint;

  /// No description provided for @restaurantNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Angkor Khmer Restaurant'**
  String get restaurantNameHint;

  /// No description provided for @addressLocation.
  ///
  /// In en, this message translates to:
  /// **'Address / Location'**
  String get addressLocation;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Phnom Penh or Province...'**
  String get addressHint;

  /// No description provided for @shortBio.
  ///
  /// In en, this message translates to:
  /// **'Short Bio / Description'**
  String get shortBio;

  /// No description provided for @farmerBioHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe the agricultural produce you grow...'**
  String get farmerBioHint;

  /// No description provided for @restaurantBioHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your cuisine style, farm-to-table preferences, and fresh ingredient needs...'**
  String get restaurantBioHint;

  /// No description provided for @saveAndStart.
  ///
  /// In en, this message translates to:
  /// **'Save & Start'**
  String get saveAndStart;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now (complete later)'**
  String get skipForNow;

  /// No description provided for @failedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String failedToPickImage(String error);

  /// No description provided for @failedToSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile: {error}'**
  String failedToSaveProfile(String error);

  /// No description provided for @favoriteProducts.
  ///
  /// In en, this message translates to:
  /// **'Favorite Products'**
  String get favoriteProducts;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorite products yet'**
  String get noFavoritesYet;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any produce in the marketplace\nto save it here for fast kitchen re-ordering.'**
  String get favoritesEmptySubtitle;

  /// No description provided for @browseProduce.
  ///
  /// In en, this message translates to:
  /// **'Browse Produce'**
  String get browseProduce;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to Favorites'**
  String get addedToFavorites;

  /// No description provided for @couldNotLoadFavorites.
  ///
  /// In en, this message translates to:
  /// **'Could not load favorites'**
  String get couldNotLoadFavorites;

  /// No description provided for @failedAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to cart: {error}'**
  String failedAddToCart(String error);

  /// No description provided for @addedProduceToCart.
  ///
  /// In en, this message translates to:
  /// **'Added {name} to cart'**
  String addedProduceToCart(String name);

  /// No description provided for @minOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Min: {minOrder}'**
  String minOrderLabel(String minOrder);

  /// No description provided for @lowStockCount.
  ///
  /// In en, this message translates to:
  /// **'Low Stock ({count} kg)'**
  String lowStockCount(String count);

  /// No description provided for @inStockCount.
  ///
  /// In en, this message translates to:
  /// **'In Stock ({count} kg)'**
  String inStockCount(String count);

  /// No description provided for @productLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Product link copied to clipboard!'**
  String get productLinkCopied;

  /// No description provided for @enterOrderQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter Order Quantity'**
  String get enterOrderQuantity;

  /// No description provided for @minOrderAvailableStock.
  ///
  /// In en, this message translates to:
  /// **'Minimum order: {min} kg\nAvailable stock: {stock} kg'**
  String minOrderAvailableStock(String min, String stock);

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @minOrderQuantityIs.
  ///
  /// In en, this message translates to:
  /// **'Minimum order quantity is {min} kg'**
  String minOrderQuantityIs(String min);

  /// No description provided for @cannotExceedStock.
  ///
  /// In en, this message translates to:
  /// **'Cannot exceed available stock of {stock} kg'**
  String cannotExceedStock(String stock);

  /// No description provided for @adjustedToMaxStock.
  ///
  /// In en, this message translates to:
  /// **'Adjusted to maximum available stock: {stock} kg'**
  String adjustedToMaxStock(String stock);

  /// No description provided for @addedProductToCart.
  ///
  /// In en, this message translates to:
  /// **'Added {quantity} kg {product} to cart'**
  String addedProductToCart(String quantity, String product);

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'VIEW CART'**
  String get viewCart;

  /// No description provided for @wholesaleUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'WHOLESALE UNIT PRICE'**
  String get wholesaleUnitPrice;

  /// No description provided for @minimumWholesaleOrder.
  ///
  /// In en, this message translates to:
  /// **'Min. wholesale order: {min} kg'**
  String minimumWholesaleOrder(String min);

  /// No description provided for @orderQuantityHeader.
  ///
  /// In en, this message translates to:
  /// **'ORDER QUANTITY'**
  String get orderQuantityHeader;

  /// No description provided for @resetToMin.
  ///
  /// In en, this message translates to:
  /// **'Reset to Min'**
  String get resetToMin;

  /// No description provided for @priceEstimate.
  ///
  /// In en, this message translates to:
  /// **'PRICE ESTIMATE'**
  String get priceEstimate;

  /// No description provided for @produceSubtotalCalc.
  ///
  /// In en, this message translates to:
  /// **'Produce Subtotal ({quantity} kg × \${price})'**
  String produceSubtotalCalc(String quantity, String price);

  /// No description provided for @estimatedDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Estimated Delivery Fee'**
  String get estimatedDeliveryFee;

  /// No description provided for @freeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeDelivery;

  /// No description provided for @estimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated Total'**
  String get estimatedTotal;

  /// No description provided for @farmerAndProducer.
  ///
  /// In en, this message translates to:
  /// **'FARMER & PRODUCER'**
  String get farmerAndProducer;

  /// No description provided for @verifiedLocalProducer.
  ///
  /// In en, this message translates to:
  /// **'Verified Local Producer'**
  String get verifiedLocalProducer;

  /// No description provided for @chatAction.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatAction;

  /// No description provided for @harvestAndLogistics.
  ///
  /// In en, this message translates to:
  /// **'HARVEST & LOGISTICS'**
  String get harvestAndLogistics;

  /// No description provided for @farmOrigin.
  ///
  /// In en, this message translates to:
  /// **'Farm Origin'**
  String get farmOrigin;

  /// No description provided for @productDescriptionHeader.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT DESCRIPTION'**
  String get productDescriptionHeader;

  /// No description provided for @moreFromThisFarm.
  ///
  /// In en, this message translates to:
  /// **'More From This Farm'**
  String get moreFromThisFarm;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(int count);

  /// No description provided for @kgLeftCount.
  ///
  /// In en, this message translates to:
  /// **'{quantity} kg left'**
  String kgLeftCount(String quantity);

  /// No description provided for @totalKg.
  ///
  /// In en, this message translates to:
  /// **'TOTAL ({quantity} kg)'**
  String totalKg(String quantity);

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// No description provided for @updateProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Update Profile Picture'**
  String get updateProfilePicture;

  /// No description provided for @updateCoverBanner.
  ///
  /// In en, this message translates to:
  /// **'Update Cover Banner'**
  String get updateCoverBanner;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @useDeviceCamera.
  ///
  /// In en, this message translates to:
  /// **'Use your device camera'**
  String get useDeviceCamera;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @selectExistingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Select an existing photo'**
  String get selectExistingPhoto;

  /// No description provided for @failedPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String failedPickImage(String error);

  /// No description provided for @failedSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile: {error}'**
  String failedSaveProfile(String error);

  /// No description provided for @editFarmProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Farm Profile'**
  String get editFarmProfile;

  /// No description provided for @editRestaurantProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Restaurant Profile'**
  String get editRestaurantProfile;

  /// No description provided for @manageFarmIdentity.
  ///
  /// In en, this message translates to:
  /// **'Manage your farm identity & contact information'**
  String get manageFarmIdentity;

  /// No description provided for @manageRestaurantDetails.
  ///
  /// In en, this message translates to:
  /// **'Manage your restaurant details & delivery address'**
  String get manageRestaurantDetails;

  /// No description provided for @farmAndBusinessDetails.
  ///
  /// In en, this message translates to:
  /// **'Farm & Business Details'**
  String get farmAndBusinessDetails;

  /// No description provided for @restaurantBrandIdentity.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Brand & Identity'**
  String get restaurantBrandIdentity;

  /// No description provided for @restaurantBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Restaurant / Business Name'**
  String get restaurantBusinessName;

  /// No description provided for @displayedOnMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Displayed prominently on marketplace listings'**
  String get displayedOnMarketplace;

  /// No description provided for @publicRestaurantName.
  ///
  /// In en, this message translates to:
  /// **'Your public restaurant or kitchen business name'**
  String get publicRestaurantName;

  /// No description provided for @ownerContactName.
  ///
  /// In en, this message translates to:
  /// **'Owner / Contact Person Name'**
  String get ownerContactName;

  /// No description provided for @managerContactName.
  ///
  /// In en, this message translates to:
  /// **'Manager / Contact Person Name'**
  String get managerContactName;

  /// No description provided for @pleaseEnterContactName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a contact name'**
  String get pleaseEnterContactName;

  /// No description provided for @contactAndLocation.
  ///
  /// In en, this message translates to:
  /// **'Contact & Location'**
  String get contactAndLocation;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a contact phone number'**
  String get pleaseEnterPhone;

  /// No description provided for @farmLocationOrigin.
  ///
  /// In en, this message translates to:
  /// **'Farm Location / Origin'**
  String get farmLocationOrigin;

  /// No description provided for @restaurantDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Restaurant / Delivery Address'**
  String get restaurantDeliveryAddress;

  /// No description provided for @helpsLocateProduce.
  ///
  /// In en, this message translates to:
  /// **'Helps restaurants locate local farm produce'**
  String get helpsLocateProduce;

  /// No description provided for @usedAsDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Used as primary delivery address for produce orders'**
  String get usedAsDeliveryAddress;

  /// No description provided for @sustainabilityStory.
  ///
  /// In en, this message translates to:
  /// **'Sustainability & Farm Story'**
  String get sustainabilityStory;

  /// No description provided for @restaurantBioNeeds.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Bio & Sourcing Needs'**
  String get restaurantBioNeeds;

  /// No description provided for @farmStoryQuality.
  ///
  /// In en, this message translates to:
  /// **'Farm Story & Produce Quality'**
  String get farmStoryQuality;

  /// No description provided for @restaurantDescConcept.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Description & Concept'**
  String get restaurantDescConcept;

  /// No description provided for @farmStoryHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your farming practices, organic cultivation, harvest frequency...'**
  String get farmStoryHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @photosAndBranding.
  ///
  /// In en, this message translates to:
  /// **'Photos & Branding'**
  String get photosAndBranding;

  /// No description provided for @tapToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get tapToChange;

  /// No description provided for @cover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get cover;

  /// No description provided for @profileAvatar.
  ///
  /// In en, this message translates to:
  /// **'Profile Avatar'**
  String get profileAvatar;

  /// No description provided for @clickToReplacePhoto.
  ///
  /// In en, this message translates to:
  /// **'Click to replace photo'**
  String get clickToReplacePhoto;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'SPENT'**
  String get spent;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'FAVORITES'**
  String get favorites;

  /// No description provided for @businessProfile.
  ///
  /// In en, this message translates to:
  /// **'Business Profile'**
  String get businessProfile;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @favoritesProduct.
  ///
  /// In en, this message translates to:
  /// **'Favorites Product'**
  String get favoritesProduct;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @logOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get logOutConfirmMessage;

  /// No description provided for @restaurantProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Restaurant profile updated successfully! 🍽️'**
  String get restaurantProfileUpdated;

  /// No description provided for @farmProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Farm profile updated successfully! 🌾'**
  String get farmProfileUpdated;

  /// No description provided for @verifiedRestaurantBuyer.
  ///
  /// In en, this message translates to:
  /// **'Verified Restaurant Buyer'**
  String get verifiedRestaurantBuyer;

  /// No description provided for @managerContact.
  ///
  /// In en, this message translates to:
  /// **'Manager / Contact'**
  String get managerContact;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get contactPhone;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @aboutKitchenConcept.
  ///
  /// In en, this message translates to:
  /// **'About Kitchen & Concept'**
  String get aboutKitchenConcept;

  /// No description provided for @accountRole.
  ///
  /// In en, this message translates to:
  /// **'Account Role'**
  String get accountRole;

  /// No description provided for @commercialRestaurantBuyer.
  ///
  /// In en, this message translates to:
  /// **'Commercial Restaurant & Kitchen Buyer'**
  String get commercialRestaurantBuyer;

  /// No description provided for @editBusinessDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Business Details'**
  String get editBusinessDetails;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @purchasingAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Purchasing Analytics'**
  String get purchasingAnalytics;

  /// No description provided for @analyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time spending & ordering metrics for your restaurant.'**
  String get analyticsSubtitle;

  /// No description provided for @avgOrder.
  ///
  /// In en, this message translates to:
  /// **'AVG ORDER'**
  String get avgOrder;

  /// No description provided for @orderStatusOverview.
  ///
  /// In en, this message translates to:
  /// **'Order Status Overview'**
  String get orderStatusOverview;

  /// No description provided for @activeInProgress.
  ///
  /// In en, this message translates to:
  /// **'Active / In Progress'**
  String get activeInProgress;

  /// No description provided for @deliveredCompleted.
  ///
  /// In en, this message translates to:
  /// **'Delivered & Completed'**
  String get deliveredCompleted;

  /// No description provided for @cancelledStatus.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelledStatus;

  /// No description provided for @viewAllOrdersHistory.
  ///
  /// In en, this message translates to:
  /// **'View All Orders in History'**
  String get viewAllOrdersHistory;

  /// No description provided for @preferredPaymentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred default payment method for faster checkout.'**
  String get preferredPaymentSubtitle;

  /// No description provided for @khqrTitle.
  ///
  /// In en, this message translates to:
  /// **'KHQR (Bakong / QR Pay)'**
  String get khqrTitle;

  /// No description provided for @khqrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan & pay instantly with any Cambodian banking app (ABA, ACLEDA, Canadia, Wing, etc.)'**
  String get khqrSubtitle;

  /// No description provided for @khqrBadge.
  ///
  /// In en, this message translates to:
  /// **'Instant • Recommended'**
  String get khqrBadge;

  /// No description provided for @codTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery (COD)'**
  String get codTitle;

  /// No description provided for @codSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay cash upon receiving and inspecting produce directly at your kitchen.'**
  String get codSubtitle;

  /// No description provided for @codBadge.
  ///
  /// In en, this message translates to:
  /// **'Pay on Arrival'**
  String get codBadge;

  /// No description provided for @paymentSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'Payments are processed securely through the National Bank of Cambodia Bakong network and direct verified vendor settlement.'**
  String get paymentSecurityNote;

  /// No description provided for @confirmPreferredMethod.
  ///
  /// In en, this message translates to:
  /// **'Confirm Preferred Method'**
  String get confirmPreferredMethod;

  /// No description provided for @defaultPaymentSetTo.
  ///
  /// In en, this message translates to:
  /// **'Default payment method set to {method}'**
  String defaultPaymentSetTo(String method);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
