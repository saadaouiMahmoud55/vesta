// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Vesta';

  @override
  String get tabExplore => 'Explore';

  @override
  String get tabSearch => 'Search';

  @override
  String get tabMap => 'Map';

  @override
  String get tabFavorites => 'Favorites';

  @override
  String get tabProfile => 'Profile';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmptyTitle => 'No new notifications';

  @override
  String get notificationsEmptyBody =>
      'New messages appear here until you read them.';

  @override
  String get chatTitle => 'Messages';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get languageLabel => 'Language';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authDisplayNameLabel => 'Full name';

  @override
  String get authLoginButton => 'Log in';

  @override
  String get authSignUpTitle => 'Create account';

  @override
  String get authSignUpButton => 'Sign up';

  @override
  String get authGoToSignUp => 'No account yet? Sign up';

  @override
  String get authGoToLogin => 'Already have an account? Log in';

  @override
  String get authLogoutButton => 'Log out';

  @override
  String get signInToContinueTitle => 'Sign in to continue';

  @override
  String get signInToContinueBody =>
      'Log in or create an account to save favorites, message owners and publish listings.';

  @override
  String get authErrorInvalidEmail => 'Enter a valid email address';

  @override
  String get authErrorPasswordShort =>
      'Password must have at least 8 characters';

  @override
  String get authErrorNameRequired => 'Enter your name';

  @override
  String get authErrorEmailInUse => 'This email is already used';

  @override
  String get authErrorWrongPassword => 'Wrong email or password';

  @override
  String get authErrorNoNetwork => 'No internet connection';

  @override
  String get authErrorUnknown => 'Something went wrong, please try again';

  @override
  String get publishTitle => 'Publish a listing';

  @override
  String get publishButton => 'Publish a listing';

  @override
  String get publishSubmit => 'Publish';

  @override
  String get publishSuccess => 'Your listing has been published';

  @override
  String get publishFieldTitle => 'Title';

  @override
  String get publishFieldDescription => 'Description';

  @override
  String get publishFieldPrice => 'Price (TND)';

  @override
  String get publishFieldCity => 'City';

  @override
  String get publishFieldBedrooms => 'Bedrooms (optional)';

  @override
  String get publishFieldBathrooms => 'Bathrooms (optional)';

  @override
  String get publishFieldArea => 'Area in m² (optional)';

  @override
  String get publishListingType => 'Listing type';

  @override
  String get publishTypeSale => 'For sale';

  @override
  String get publishTypeRent => 'For rent';

  @override
  String get publishRentPeriod => 'Rent period';

  @override
  String get publishPeriodNight => 'Per night';

  @override
  String get publishPeriodMonth => 'Per month';

  @override
  String get publishPeriodYear => 'Per year';

  @override
  String get publishPropertyType => 'Property type';

  @override
  String get propertyApartment => 'Apartment';

  @override
  String get propertyHouse => 'House';

  @override
  String get propertyVilla => 'Villa';

  @override
  String get propertyStudio => 'Studio';

  @override
  String get propertyRiad => 'Riad';

  @override
  String get propertyGuestHouse => 'Guest house';

  @override
  String get publishPhotosTitle => 'Photos (up to 10)';

  @override
  String get publishAddFromGallery => 'Gallery';

  @override
  String get publishAddFromCamera => 'Camera';

  @override
  String get publishRemovePhoto => 'Remove photo';

  @override
  String get listingErrorTitleRequired => 'Enter a title';

  @override
  String get listingErrorDescriptionRequired => 'Enter a description';

  @override
  String get listingErrorPriceInvalid =>
      'Enter a price between 1 and 50,000,000';

  @override
  String get listingErrorCityRequired => 'Enter a city';

  @override
  String get listingErrorRentPeriodRequired => 'Choose a rent period';

  @override
  String get listingErrorNumberInvalid => 'Enter a valid number';

  @override
  String get listingErrorNotSignedIn => 'Please sign in first';

  @override
  String get listingErrorNoPhotos => 'Add at least one photo';

  @override
  String get listingErrorTooManyPhotos => 'You can add up to 10 photos';

  @override
  String get publishPhotosDuplicates => 'Duplicate photos were not added';

  @override
  String get listingErrorNoNetwork => 'No internet connection';

  @override
  String get listingErrorPermissionDenied => 'You are not allowed to do this';

  @override
  String get listingErrorUnknown => 'Something went wrong, please try again';

  @override
  String get photoErrorTooLarge =>
      'This photo is too large, choose another one';

  @override
  String get photoErrorReadFailed => 'Could not read this photo';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileNameLabel => 'Name';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profileSaveButton => 'Save';

  @override
  String get profileChangePhoto => 'Change photo';

  @override
  String get profilePhotoGallery => 'Choose from gallery';

  @override
  String get profilePhotoCamera => 'Take a photo';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get profileMyListings => 'My listings';

  @override
  String get profileNoListings => 'You have no listings yet';

  @override
  String get profileListingsLoadError => 'Could not load your listings';

  @override
  String get profileEditListing => 'Edit this listing';

  @override
  String get profileDeleteListing => 'Delete this listing';

  @override
  String get profileDeleteConfirmTitle => 'Delete this listing?';

  @override
  String get profileDeleteConfirmBody =>
      'Its photos will be deleted too. This cannot be undone.';

  @override
  String get profileDeleteConfirm => 'Delete';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileListingDeleted => 'Listing deleted';

  @override
  String get profileErrorNameRequired => 'Name is required';

  @override
  String get profileErrorNoNetwork => 'No connection. Please try again.';

  @override
  String get profileErrorPermission => 'You are not allowed to do this';

  @override
  String get profileErrorNotSignedIn => 'Please sign in';

  @override
  String get profileErrorUnknown => 'Something went wrong. Please try again.';

  @override
  String get profilePhotoErrorTooLarge => 'This photo is too large';

  @override
  String get profilePhotoErrorRead => 'Could not read this photo';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptyBody =>
      'Tap the heart on a listing to save it here.';

  @override
  String get favoritesUnavailable => 'This listing is no longer available';

  @override
  String get favoritesRemove => 'Remove';

  @override
  String get favoritesRetry => 'Try again';

  @override
  String get favoritesErrorNoNetwork =>
      'No connection. Check your internet and try again.';

  @override
  String get favoritesErrorPermission => 'You are not allowed to do this.';

  @override
  String get favoritesErrorNotSignedIn => 'Sign in to save favorites.';

  @override
  String get favoritesErrorUnknown => 'Something went wrong. Please try again.';

  @override
  String get listingsEmpty => 'No listings yet';

  @override
  String get favoritesFilterAll => 'All';

  @override
  String get favoritesFilterBuy => 'Buy';

  @override
  String get favoritesFilterRent => 'Rent';

  @override
  String get favoritesFilterStay => 'Stay';

  @override
  String get favoritesFilterEmpty => 'No favorites in this category';

  @override
  String get favoritesEmptyAction => 'Explore listings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAbout => 'About Vesta';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacy => 'Privacy and account deletion';

  @override
  String get settingsContact => 'Contact us';

  @override
  String get settingsDeleteAccount => 'Delete my account';

  @override
  String get settingsLinkError => 'Could not open the link';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordBody =>
      'Enter your email. If an account exists, we send you a link to choose a new password.';

  @override
  String get forgotPasswordSend => 'Send link';

  @override
  String get forgotPasswordSent =>
      'If an account exists for this email, a reset link has been sent.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get verifyBannerText => 'Please verify your email address.';

  @override
  String get verifyBannerResend => 'Send again';

  @override
  String get verifyBannerSent => 'Verification email sent';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts, please try again in a few minutes';

  @override
  String get authWelcomeTitle => 'Welcome to Vesta';

  @override
  String get authWelcomeSubtitle =>
      'Sign in to contact owners, save favorites and publish your own place.';

  @override
  String get authContinueAsGuest => 'Continue as guest';

  @override
  String get loading => 'Loading…';

  @override
  String homePriceExample(String price) {
    return 'Example price: $price';
  }

  @override
  String get languageEn => 'English';

  @override
  String get languageFr => 'Français';

  @override
  String get languageAr => 'العربية';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get listingDetailNotFound => 'Listing not found';

  @override
  String get listingDetailLoadError => 'Could not load this listing.';

  @override
  String get listingDetailRetry => 'Try again';

  @override
  String get listingDetailNoPhoto => 'No photo';

  @override
  String get listingDetailBedrooms => 'Bedrooms';

  @override
  String get listingDetailBathrooms => 'Bathrooms';

  @override
  String get listingDetailArea => 'Area (m²)';

  @override
  String get listingDetailPerNight => '/ night';

  @override
  String get listingDetailPerMonth => '/ month';

  @override
  String get listingDetailPerYear => '/ year';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'This permanently deletes your account, your profile, your listings and their photos, and your favorites. Messages you sent stay in the other person\'s conversation. This cannot be undone.';

  @override
  String get deleteAccountPassword => 'Enter your password to confirm';

  @override
  String get deleteAccountConfirm => 'Delete';

  @override
  String get deleteAccountDone => 'Your account has been deleted.';

  @override
  String get searchHint => 'Search by city';

  @override
  String get searchNoResults => 'No listings match your search';

  @override
  String get searchFilters => 'Filters';

  @override
  String get searchPriceMin => 'Min price';

  @override
  String get searchPriceMax => 'Max price';

  @override
  String get searchOfferType => 'Offer type';

  @override
  String get searchPropertyType => 'Property type';

  @override
  String get searchAll => 'All';

  @override
  String get searchTypeSale => 'Sale';

  @override
  String get searchTypeRent => 'Rent';

  @override
  String get searchTypeStay => 'Stay';

  @override
  String get searchApply => 'Apply';

  @override
  String get searchReset => 'Reset';

  @override
  String get searchPropApartment => 'Apartment';

  @override
  String get searchPropHouse => 'House';

  @override
  String get searchPropVilla => 'Villa';

  @override
  String get searchPropStudio => 'Studio';

  @override
  String get searchPropRiad => 'Riad';

  @override
  String get searchPropGuestHouse => 'Guest house';

  @override
  String get mapMyLocation => 'My location';

  @override
  String get mapLocationDenied =>
      'Location permission denied. The map still works.';

  @override
  String get mapLocationDeniedForever =>
      'Location is blocked for Vesta. You can enable it in the app settings.';

  @override
  String get mapLocationServiceOff =>
      'Turn on location (GPS) on your phone to see where you are.';

  @override
  String get mapLocationError => 'Could not find your position. Try again.';

  @override
  String get mapOpenSettings => 'Settings';

  @override
  String get mapViewDetails => 'View details';

  @override
  String get mapNoListings => 'No listing with a location yet';

  @override
  String get mapPickerTitle => 'Choose the location';

  @override
  String get mapPickerHint => 'Tap the map to place the pin';

  @override
  String get mapPickerConfirm => 'Use this location';

  @override
  String get chatEmptyTitle => 'No conversations yet';

  @override
  String get chatEmptyBody => 'Open a listing and tap Contact owner to start.';

  @override
  String get chatContactOwner => 'Contact owner';

  @override
  String get chatOwnListing => 'This is your own listing';

  @override
  String get chatContactError => 'Could not open the chat, try again';

  @override
  String get chatUnknownUser => 'Vesta user';

  @override
  String get chatLoadError => 'Could not load your messages';

  @override
  String get chatRetry => 'Try again';

  @override
  String get chatListingRemoved => 'Listing no longer available';

  @override
  String get chatMessageHint => 'Write a message';

  @override
  String get chatSend => 'Send';

  @override
  String get chatSending => 'Sending…';

  @override
  String get chatNoMessages => 'No messages yet. Say hello!';

  @override
  String get chatSendError =>
      'Not sent yet. It will be sent when you are back online.';

  @override
  String get chatSendFailed => 'Message not sent, try again';

  @override
  String get chatToday => 'Today';

  @override
  String get chatYesterday => 'Yesterday';

  @override
  String get listingDetailAtAGlance => 'At a glance';

  @override
  String get listingDetailGuests => 'Guests';

  @override
  String get listingDetailReadMore => 'Read more';

  @override
  String get listingDetailReadLess => 'Read less';

  @override
  String get listingErrorGuestsInvalid =>
      'Enter a number of guests between 1 and 30';

  @override
  String get listingErrorRoomsInvalid => 'Enter a number between 0 and 20';

  @override
  String get publishFieldGuests => 'Maximum guests (optional)';

  @override
  String get publishAmenitiesTitle => 'Amenities';

  @override
  String publishAmenitiesCounter(int count) {
    return '$count / 10';
  }

  @override
  String get publishCheckIn => 'Check-in time';

  @override
  String get publishCheckOut => 'Check-out time';

  @override
  String get publishTimeNotSet => 'Not set';

  @override
  String get publishRulesTitle => 'House rules';

  @override
  String get amenityWifi => 'Wi-Fi';

  @override
  String get amenityAc => 'Air conditioning';

  @override
  String get amenityHeating => 'Heating';

  @override
  String get amenityKitchen => 'Kitchen';

  @override
  String get amenityParking => 'Parking';

  @override
  String get amenityPool => 'Pool';

  @override
  String get amenityBreakfast => 'Breakfast';

  @override
  String get amenityWashingMachine => 'Washing machine';

  @override
  String get amenityTv => 'TV';

  @override
  String get amenityGarden => 'Garden';

  @override
  String get ruleNoSmoking => 'No smoking';

  @override
  String get ruleNoPets => 'No pets';

  @override
  String get ruleNoParties => 'No parties';

  @override
  String get ruleQuietHours => 'Quiet hours';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingTitle1 => 'Find your place in Tunisia';

  @override
  String get onboardingBody1 =>
      'Browse guest houses, apartments and houses to stay, rent or buy.';

  @override
  String get onboardingTitle2 => 'Contact the owner';

  @override
  String get onboardingBody2 =>
      'Chat with the owner, or call or message them on WhatsApp.';

  @override
  String get onboardingTitle3 => 'Publish your own place';

  @override
  String get onboardingBody3 =>
      'Add your listing with photos in a few minutes.';

  @override
  String get profileStatusAvailable => 'Available';

  @override
  String get profileStatusReserved => 'Reserved';

  @override
  String get profileStatusSold => 'Sold';

  @override
  String get profileStatusRented => 'Rented';

  @override
  String get profileStatusUnavailable => 'Unavailable';

  @override
  String get profileStatusHidden => 'Hidden';

  @override
  String get profileStatusSheetTitle => 'Change the status';

  @override
  String get profileStatusUpdated => 'Status updated';

  @override
  String get profilePublishFirst => 'Publish your first listing';

  @override
  String get publishFieldPhone => 'Phone';

  @override
  String get publishWhatsapp => 'Available on WhatsApp';

  @override
  String get publishCityHelper => 'Start typing: Tunis, Sousse, Tozeur…';

  @override
  String get publishLocationSet => 'Set the exact location on the map';

  @override
  String get publishLocationChange => 'Change the location on the map';

  @override
  String get publishLocationHint =>
      'Without it, your listing appears near the city center on the map.';

  @override
  String get publishLocationSaved => 'Exact location saved';

  @override
  String get publishLocationRemove => 'Remove';

  @override
  String get listingErrorPhoneInvalid => 'Enter a valid Tunisian phone number';

  @override
  String get offerSale => 'For sale';

  @override
  String get offerRent => 'For rent';

  @override
  String get offerStay => 'Stay';

  @override
  String get unitNight => '/ night';

  @override
  String get unitMonth => '/ month';

  @override
  String get unitYear => '/ year';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonOffline => 'You are offline. Some content may not load.';

  @override
  String get contactCall => 'Call';

  @override
  String get contactWhatsapp => 'WhatsApp';

  @override
  String get contactSignInToSee => 'Sign in to see the contact';

  @override
  String get contactNoWhatsapp => 'WhatsApp is not installed on this phone';

  @override
  String get contactCallError => 'Could not open the phone app';

  @override
  String contactMessageSale(String title) {
    return 'Hello, I am interested in buying $title on Vesta';
  }

  @override
  String contactMessageRent(String title) {
    return 'Hello, I am interested in renting $title on Vesta';
  }

  @override
  String contactMessageStay(String title) {
    return 'Hello, I am interested in staying at $title on Vesta';
  }
}
