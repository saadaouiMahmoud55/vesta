import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Vesta'**
  String get appName;

  /// No description provided for @tabExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get tabExplore;

  /// No description provided for @tabSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tabSearch;

  /// No description provided for @tabMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get tabMap;

  /// No description provided for @tabFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get tabFavorites;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No new notifications'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'New messages appear here until you read them.'**
  String get notificationsEmptyBody;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chatTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authDisplayNameLabel;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginButton;

  /// No description provided for @authSignUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSignUpTitle;

  /// No description provided for @authSignUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUpButton;

  /// No description provided for @authGoToSignUp.
  ///
  /// In en, this message translates to:
  /// **'No account yet? Sign up'**
  String get authGoToSignUp;

  /// No description provided for @authGoToLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get authGoToLogin;

  /// No description provided for @authLogoutButton.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get authLogoutButton;

  /// No description provided for @signInToContinueTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinueTitle;

  /// No description provided for @signInToContinueBody.
  ///
  /// In en, this message translates to:
  /// **'Log in or create an account to save favorites, message owners and publish listings.'**
  String get signInToContinueBody;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must have at least 8 characters'**
  String get authErrorPasswordShort;

  /// No description provided for @authErrorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get authErrorNameRequired;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already used'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get authErrorNoNetwork;

  /// No description provided for @authErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please try again'**
  String get authErrorUnknown;

  /// No description provided for @publishTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish a listing'**
  String get publishTitle;

  /// No description provided for @publishButton.
  ///
  /// In en, this message translates to:
  /// **'Publish a listing'**
  String get publishButton;

  /// No description provided for @publishSubmit.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishSubmit;

  /// No description provided for @publishSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your listing has been published'**
  String get publishSuccess;

  /// No description provided for @publishFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get publishFieldTitle;

  /// No description provided for @publishFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get publishFieldDescription;

  /// No description provided for @publishFieldPrice.
  ///
  /// In en, this message translates to:
  /// **'Price (TND)'**
  String get publishFieldPrice;

  /// No description provided for @publishFieldCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get publishFieldCity;

  /// No description provided for @publishFieldBedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms (optional)'**
  String get publishFieldBedrooms;

  /// No description provided for @publishFieldBathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms (optional)'**
  String get publishFieldBathrooms;

  /// No description provided for @publishFieldArea.
  ///
  /// In en, this message translates to:
  /// **'Area in m² (optional)'**
  String get publishFieldArea;

  /// No description provided for @publishListingType.
  ///
  /// In en, this message translates to:
  /// **'Listing type'**
  String get publishListingType;

  /// No description provided for @publishTypeSale.
  ///
  /// In en, this message translates to:
  /// **'For sale'**
  String get publishTypeSale;

  /// No description provided for @publishTypeRent.
  ///
  /// In en, this message translates to:
  /// **'For rent'**
  String get publishTypeRent;

  /// No description provided for @publishRentPeriod.
  ///
  /// In en, this message translates to:
  /// **'Rent period'**
  String get publishRentPeriod;

  /// No description provided for @publishPeriodNight.
  ///
  /// In en, this message translates to:
  /// **'Per night'**
  String get publishPeriodNight;

  /// No description provided for @publishPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'Per month'**
  String get publishPeriodMonth;

  /// No description provided for @publishPeriodYear.
  ///
  /// In en, this message translates to:
  /// **'Per year'**
  String get publishPeriodYear;

  /// No description provided for @publishPropertyType.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get publishPropertyType;

  /// No description provided for @propertyApartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get propertyApartment;

  /// No description provided for @propertyHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get propertyHouse;

  /// No description provided for @propertyVilla.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get propertyVilla;

  /// No description provided for @propertyStudio.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get propertyStudio;

  /// No description provided for @propertyRiad.
  ///
  /// In en, this message translates to:
  /// **'Riad'**
  String get propertyRiad;

  /// No description provided for @propertyGuestHouse.
  ///
  /// In en, this message translates to:
  /// **'Guest house'**
  String get propertyGuestHouse;

  /// No description provided for @publishPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos (up to 10)'**
  String get publishPhotosTitle;

  /// No description provided for @publishAddFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get publishAddFromGallery;

  /// No description provided for @publishAddFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get publishAddFromCamera;

  /// No description provided for @publishRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get publishRemovePhoto;

  /// No description provided for @listingErrorTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get listingErrorTitleRequired;

  /// No description provided for @listingErrorDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a description'**
  String get listingErrorDescriptionRequired;

  /// No description provided for @listingErrorPriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a price between 1 and 50,000,000'**
  String get listingErrorPriceInvalid;

  /// No description provided for @listingErrorCityRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a city'**
  String get listingErrorCityRequired;

  /// No description provided for @listingErrorRentPeriodRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a rent period'**
  String get listingErrorRentPeriodRequired;

  /// No description provided for @listingErrorNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get listingErrorNumberInvalid;

  /// No description provided for @listingErrorNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in first'**
  String get listingErrorNotSignedIn;

  /// No description provided for @listingErrorNoPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add at least one photo'**
  String get listingErrorNoPhotos;

  /// No description provided for @listingErrorTooManyPhotos.
  ///
  /// In en, this message translates to:
  /// **'You can add up to 10 photos'**
  String get listingErrorTooManyPhotos;

  /// No description provided for @publishPhotosDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Duplicate photos were not added'**
  String get publishPhotosDuplicates;

  /// No description provided for @listingErrorNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get listingErrorNoNetwork;

  /// No description provided for @listingErrorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to do this'**
  String get listingErrorPermissionDenied;

  /// No description provided for @listingErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please try again'**
  String get listingErrorUnknown;

  /// No description provided for @photoErrorTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This photo is too large, choose another one'**
  String get photoErrorTooLarge;

  /// No description provided for @photoErrorReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read this photo'**
  String get photoErrorReadFailed;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditTitle;

  /// No description provided for @profileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileNameLabel;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// No description provided for @profileSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSaveButton;

  /// No description provided for @profileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profileChangePhoto;

  /// No description provided for @profilePhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profilePhotoGallery;

  /// No description provided for @profilePhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get profilePhotoCamera;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @profileMyListings.
  ///
  /// In en, this message translates to:
  /// **'My listings'**
  String get profileMyListings;

  /// No description provided for @profileNoListings.
  ///
  /// In en, this message translates to:
  /// **'You have no listings yet'**
  String get profileNoListings;

  /// No description provided for @profileListingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your listings'**
  String get profileListingsLoadError;

  /// No description provided for @profileEditListing.
  ///
  /// In en, this message translates to:
  /// **'Edit this listing'**
  String get profileEditListing;

  /// No description provided for @profileDeleteListing.
  ///
  /// In en, this message translates to:
  /// **'Delete this listing'**
  String get profileDeleteListing;

  /// No description provided for @profileDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this listing?'**
  String get profileDeleteConfirmTitle;

  /// No description provided for @profileDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Its photos will be deleted too. This cannot be undone.'**
  String get profileDeleteConfirmBody;

  /// No description provided for @profileDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profileDeleteConfirm;

  /// No description provided for @profileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// No description provided for @profileListingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Listing deleted'**
  String get profileListingDeleted;

  /// No description provided for @profileErrorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get profileErrorNameRequired;

  /// No description provided for @profileErrorNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Please try again.'**
  String get profileErrorNoNetwork;

  /// No description provided for @profileErrorPermission.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to do this'**
  String get profileErrorPermission;

  /// No description provided for @profileErrorNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in'**
  String get profileErrorNotSignedIn;

  /// No description provided for @profileErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get profileErrorUnknown;

  /// No description provided for @profilePhotoErrorTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This photo is too large'**
  String get profilePhotoErrorTooLarge;

  /// No description provided for @profilePhotoErrorRead.
  ///
  /// In en, this message translates to:
  /// **'Could not read this photo'**
  String get profilePhotoErrorRead;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a listing to save it here.'**
  String get favoritesEmptyBody;

  /// No description provided for @favoritesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This listing is no longer available'**
  String get favoritesUnavailable;

  /// No description provided for @favoritesRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get favoritesRemove;

  /// No description provided for @favoritesRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get favoritesRetry;

  /// No description provided for @favoritesErrorNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get favoritesErrorNoNetwork;

  /// No description provided for @favoritesErrorPermission.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to do this.'**
  String get favoritesErrorPermission;

  /// No description provided for @favoritesErrorNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save favorites.'**
  String get favoritesErrorNotSignedIn;

  /// No description provided for @favoritesErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get favoritesErrorUnknown;

  /// No description provided for @listingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No listings yet'**
  String get listingsEmpty;

  /// No description provided for @favoritesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get favoritesFilterAll;

  /// No description provided for @favoritesFilterBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get favoritesFilterBuy;

  /// No description provided for @favoritesFilterRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get favoritesFilterRent;

  /// No description provided for @favoritesFilterStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get favoritesFilterStay;

  /// No description provided for @favoritesFilterEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favorites in this category'**
  String get favoritesFilterEmpty;

  /// No description provided for @favoritesEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Explore listings'**
  String get favoritesEmptyAction;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Vesta'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy and account deletion'**
  String get settingsPrivacy;

  /// No description provided for @settingsContact.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get settingsContact;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsLinkError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get settingsLinkError;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email. If an account exists, we send you a link to choose a new password.'**
  String get forgotPasswordBody;

  /// No description provided for @forgotPasswordSend.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get forgotPasswordSend;

  /// No description provided for @forgotPasswordSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for this email, a reset link has been sent.'**
  String get forgotPasswordSent;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @verifyBannerText.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email address.'**
  String get verifyBannerText;

  /// No description provided for @verifyBannerResend.
  ///
  /// In en, this message translates to:
  /// **'Send again'**
  String get verifyBannerResend;

  /// No description provided for @verifyBannerSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get verifyBannerSent;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts, please try again in a few minutes'**
  String get authErrorTooManyRequests;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Vesta'**
  String get authWelcomeTitle;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to contact owners, save favorites and publish your own place.'**
  String get authWelcomeSubtitle;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get authContinueAsGuest;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @homePriceExample.
  ///
  /// In en, this message translates to:
  /// **'Example price: {price}'**
  String homePriceExample(String price);

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageFr.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFr;

  /// No description provided for @languageAr.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageAr;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsChangePassword;

  /// No description provided for @listingDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Listing not found'**
  String get listingDetailNotFound;

  /// No description provided for @listingDetailLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this listing.'**
  String get listingDetailLoadError;

  /// No description provided for @listingDetailRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get listingDetailRetry;

  /// No description provided for @listingDetailNoPhoto.
  ///
  /// In en, this message translates to:
  /// **'No photo'**
  String get listingDetailNoPhoto;

  /// No description provided for @listingDetailBedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get listingDetailBedrooms;

  /// No description provided for @listingDetailBathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get listingDetailBathrooms;

  /// No description provided for @listingDetailArea.
  ///
  /// In en, this message translates to:
  /// **'Area (m²)'**
  String get listingDetailArea;

  /// No description provided for @listingDetailPerNight.
  ///
  /// In en, this message translates to:
  /// **'/ night'**
  String get listingDetailPerNight;

  /// No description provided for @listingDetailPerMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get listingDetailPerMonth;

  /// No description provided for @listingDetailPerYear.
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get listingDetailPerYear;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account, your profile, your listings and their photos, and your favorites. Messages you sent stay in the other person\'s conversation. This cannot be undone.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm'**
  String get deleteAccountPassword;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountDone.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get deleteAccountDone;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by city'**
  String get searchHint;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No listings match your search'**
  String get searchNoResults;

  /// No description provided for @searchFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get searchFilters;

  /// No description provided for @searchPriceMin.
  ///
  /// In en, this message translates to:
  /// **'Min price'**
  String get searchPriceMin;

  /// No description provided for @searchPriceMax.
  ///
  /// In en, this message translates to:
  /// **'Max price'**
  String get searchPriceMax;

  /// No description provided for @searchOfferType.
  ///
  /// In en, this message translates to:
  /// **'Offer type'**
  String get searchOfferType;

  /// No description provided for @searchPropertyType.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get searchPropertyType;

  /// No description provided for @searchAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchAll;

  /// No description provided for @searchTypeSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get searchTypeSale;

  /// No description provided for @searchTypeRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get searchTypeRent;

  /// No description provided for @searchTypeStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get searchTypeStay;

  /// No description provided for @searchApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get searchApply;

  /// No description provided for @searchReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get searchReset;

  /// No description provided for @searchPropApartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get searchPropApartment;

  /// No description provided for @searchPropHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get searchPropHouse;

  /// No description provided for @searchPropVilla.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get searchPropVilla;

  /// No description provided for @searchPropStudio.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get searchPropStudio;

  /// No description provided for @searchPropRiad.
  ///
  /// In en, this message translates to:
  /// **'Riad'**
  String get searchPropRiad;

  /// No description provided for @searchPropGuestHouse.
  ///
  /// In en, this message translates to:
  /// **'Guest house'**
  String get searchPropGuestHouse;

  /// No description provided for @mapMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get mapMyLocation;

  /// No description provided for @mapLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. The map still works.'**
  String get mapLocationDenied;

  /// No description provided for @mapLocationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location is blocked for Vesta. You can enable it in the app settings.'**
  String get mapLocationDeniedForever;

  /// No description provided for @mapLocationServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Turn on location (GPS) on your phone to see where you are.'**
  String get mapLocationServiceOff;

  /// No description provided for @mapLocationError.
  ///
  /// In en, this message translates to:
  /// **'Could not find your position. Try again.'**
  String get mapLocationError;

  /// No description provided for @mapOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get mapOpenSettings;

  /// No description provided for @mapViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get mapViewDetails;

  /// No description provided for @mapNoListings.
  ///
  /// In en, this message translates to:
  /// **'No listing with a location yet'**
  String get mapNoListings;

  /// No description provided for @mapPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the location'**
  String get mapPickerTitle;

  /// No description provided for @mapPickerHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to place the pin'**
  String get mapPickerHint;

  /// No description provided for @mapPickerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Use this location'**
  String get mapPickerConfirm;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Open a listing and tap Contact owner to start.'**
  String get chatEmptyBody;

  /// No description provided for @chatContactOwner.
  ///
  /// In en, this message translates to:
  /// **'Contact owner'**
  String get chatContactOwner;

  /// No description provided for @chatOwnListing.
  ///
  /// In en, this message translates to:
  /// **'This is your own listing'**
  String get chatOwnListing;

  /// No description provided for @chatContactError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the chat, try again'**
  String get chatContactError;

  /// No description provided for @chatUnknownUser.
  ///
  /// In en, this message translates to:
  /// **'Vesta user'**
  String get chatUnknownUser;

  /// No description provided for @chatLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your messages'**
  String get chatLoadError;

  /// No description provided for @chatRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get chatRetry;

  /// No description provided for @chatListingRemoved.
  ///
  /// In en, this message translates to:
  /// **'Listing no longer available'**
  String get chatListingRemoved;

  /// No description provided for @chatMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get chatMessageHint;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @chatSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get chatSending;

  /// No description provided for @chatNoMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Say hello!'**
  String get chatNoMessages;

  /// No description provided for @chatSendError.
  ///
  /// In en, this message translates to:
  /// **'Not sent yet. It will be sent when you are back online.'**
  String get chatSendError;

  /// No description provided for @chatSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Message not sent, try again'**
  String get chatSendFailed;

  /// No description provided for @chatToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get chatToday;

  /// No description provided for @chatYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get chatYesterday;

  /// No description provided for @listingDetailAtAGlance.
  ///
  /// In en, this message translates to:
  /// **'At a glance'**
  String get listingDetailAtAGlance;

  /// No description provided for @listingDetailGuests.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get listingDetailGuests;

  /// No description provided for @listingDetailReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get listingDetailReadMore;

  /// No description provided for @listingDetailReadLess.
  ///
  /// In en, this message translates to:
  /// **'Read less'**
  String get listingDetailReadLess;

  /// No description provided for @listingErrorGuestsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number of guests between 1 and 30'**
  String get listingErrorGuestsInvalid;

  /// No description provided for @listingErrorRoomsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number between 0 and 20'**
  String get listingErrorRoomsInvalid;

  /// No description provided for @publishFieldGuests.
  ///
  /// In en, this message translates to:
  /// **'Maximum guests (optional)'**
  String get publishFieldGuests;

  /// No description provided for @publishAmenitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get publishAmenitiesTitle;

  /// No description provided for @publishAmenitiesCounter.
  ///
  /// In en, this message translates to:
  /// **'{count} / 10'**
  String publishAmenitiesCounter(int count);

  /// No description provided for @publishCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check-in time'**
  String get publishCheckIn;

  /// No description provided for @publishCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Check-out time'**
  String get publishCheckOut;

  /// No description provided for @publishTimeNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get publishTimeNotSet;

  /// No description provided for @publishRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'House rules'**
  String get publishRulesTitle;

  /// No description provided for @amenityWifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get amenityWifi;

  /// No description provided for @amenityAc.
  ///
  /// In en, this message translates to:
  /// **'Air conditioning'**
  String get amenityAc;

  /// No description provided for @amenityHeating.
  ///
  /// In en, this message translates to:
  /// **'Heating'**
  String get amenityHeating;

  /// No description provided for @amenityKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get amenityKitchen;

  /// No description provided for @amenityParking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get amenityParking;

  /// No description provided for @amenityPool.
  ///
  /// In en, this message translates to:
  /// **'Pool'**
  String get amenityPool;

  /// No description provided for @amenityBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get amenityBreakfast;

  /// No description provided for @amenityWashingMachine.
  ///
  /// In en, this message translates to:
  /// **'Washing machine'**
  String get amenityWashingMachine;

  /// No description provided for @amenityTv.
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get amenityTv;

  /// No description provided for @amenityGarden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get amenityGarden;

  /// No description provided for @ruleNoSmoking.
  ///
  /// In en, this message translates to:
  /// **'No smoking'**
  String get ruleNoSmoking;

  /// No description provided for @ruleNoPets.
  ///
  /// In en, this message translates to:
  /// **'No pets'**
  String get ruleNoPets;

  /// No description provided for @ruleNoParties.
  ///
  /// In en, this message translates to:
  /// **'No parties'**
  String get ruleNoParties;

  /// No description provided for @ruleQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get ruleQuietHours;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingStart;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Find your place in Tunisia'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Browse guest houses, apartments and houses to stay, rent or buy.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Contact the owner'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Chat with the owner, or call or message them on WhatsApp.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Publish your own place'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Add your listing with photos in a few minutes.'**
  String get onboardingBody3;

  /// No description provided for @profileStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get profileStatusAvailable;

  /// No description provided for @profileStatusReserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get profileStatusReserved;

  /// No description provided for @profileStatusSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get profileStatusSold;

  /// No description provided for @profileStatusRented.
  ///
  /// In en, this message translates to:
  /// **'Rented'**
  String get profileStatusRented;

  /// No description provided for @profileStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get profileStatusUnavailable;

  /// No description provided for @profileStatusHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get profileStatusHidden;

  /// No description provided for @profileStatusSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Change the status'**
  String get profileStatusSheetTitle;

  /// No description provided for @profileStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Status updated'**
  String get profileStatusUpdated;

  /// No description provided for @profilePublishFirst.
  ///
  /// In en, this message translates to:
  /// **'Publish your first listing'**
  String get profilePublishFirst;

  /// No description provided for @publishFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get publishFieldPhone;

  /// No description provided for @publishWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Available on WhatsApp'**
  String get publishWhatsapp;

  /// No description provided for @publishCityHelper.
  ///
  /// In en, this message translates to:
  /// **'Start typing: Tunis, Sousse, Tozeur…'**
  String get publishCityHelper;

  /// No description provided for @publishLocationSet.
  ///
  /// In en, this message translates to:
  /// **'Set the exact location on the map'**
  String get publishLocationSet;

  /// No description provided for @publishLocationChange.
  ///
  /// In en, this message translates to:
  /// **'Change the location on the map'**
  String get publishLocationChange;

  /// No description provided for @publishLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Without it, your listing appears near the city center on the map.'**
  String get publishLocationHint;

  /// No description provided for @publishLocationSaved.
  ///
  /// In en, this message translates to:
  /// **'Exact location saved'**
  String get publishLocationSaved;

  /// No description provided for @publishLocationRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get publishLocationRemove;

  /// No description provided for @listingErrorPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Tunisian phone number'**
  String get listingErrorPhoneInvalid;

  /// No description provided for @offerSale.
  ///
  /// In en, this message translates to:
  /// **'For sale'**
  String get offerSale;

  /// No description provided for @offerRent.
  ///
  /// In en, this message translates to:
  /// **'For rent'**
  String get offerRent;

  /// No description provided for @offerStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get offerStay;

  /// No description provided for @unitNight.
  ///
  /// In en, this message translates to:
  /// **'/ night'**
  String get unitNight;

  /// No description provided for @unitMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get unitMonth;

  /// No description provided for @unitYear.
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get unitYear;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @commonOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Some content may not load.'**
  String get commonOffline;

  /// No description provided for @contactCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get contactCall;

  /// No description provided for @contactWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get contactWhatsapp;

  /// No description provided for @contactSignInToSee.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see the contact'**
  String get contactSignInToSee;

  /// No description provided for @contactNoWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp is not installed on this phone'**
  String get contactNoWhatsapp;

  /// No description provided for @contactCallError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the phone app'**
  String get contactCallError;

  /// No description provided for @contactMessageSale.
  ///
  /// In en, this message translates to:
  /// **'Hello, I am interested in buying {title} on Vesta'**
  String contactMessageSale(String title);

  /// No description provided for @contactMessageRent.
  ///
  /// In en, this message translates to:
  /// **'Hello, I am interested in renting {title} on Vesta'**
  String contactMessageRent(String title);

  /// No description provided for @contactMessageStay.
  ///
  /// In en, this message translates to:
  /// **'Hello, I am interested in staying at {title} on Vesta'**
  String contactMessageStay(String title);
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
