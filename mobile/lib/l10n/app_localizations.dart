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
  /// **'Orders'**
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
  /// **'\$ / kg'**
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
