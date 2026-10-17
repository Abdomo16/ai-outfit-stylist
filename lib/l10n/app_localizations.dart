import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AI Outfit Stylist'**
  String get appName;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Your personal AI fashion assistant.'**
  String get welcomeTagline;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'WELCOME BACK'**
  String get welcomeBack;

  /// No description provided for @hiUser.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String hiUser(String name);

  /// No description provided for @aiReady.
  ///
  /// In en, this message translates to:
  /// **'AI Ready'**
  String get aiReady;

  /// No description provided for @premiumAi.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM AI'**
  String get premiumAi;

  /// No description provided for @generateYourOutfit.
  ///
  /// In en, this message translates to:
  /// **'Generate\nYour Outfit'**
  String get generateYourOutfit;

  /// No description provided for @generateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover your perfect look with AI\ntailored to your unique style.'**
  String get generateSubtitle;

  /// No description provided for @todayOutfit.
  ///
  /// In en, this message translates to:
  /// **'Today\'s outfit'**
  String get todayOutfit;

  /// No description provided for @chooseOccasionStyle.
  ///
  /// In en, this message translates to:
  /// **'Choose occasion and style'**
  String get chooseOccasionStyle;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @planTrip.
  ///
  /// In en, this message translates to:
  /// **'Plan a trip'**
  String get planTrip;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navWardrobe.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe'**
  String get navWardrobe;

  /// No description provided for @navGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get navGenerate;

  /// No description provided for @navSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

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

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccount;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeTitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @outfitDetails.
  ///
  /// In en, this message translates to:
  /// **'Outfit Details'**
  String get outfitDetails;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepOf(int step, int total);

  /// No description provided for @whatsTheOccasion.
  ///
  /// In en, this message translates to:
  /// **'What\'s the occasion?'**
  String get whatsTheOccasion;

  /// No description provided for @selectWhere.
  ///
  /// In en, this message translates to:
  /// **'Select where you\'re headed today'**
  String get selectWhere;

  /// No description provided for @pickStyle.
  ///
  /// In en, this message translates to:
  /// **'Pick your style preference'**
  String get pickStyle;

  /// No description provided for @chooseAesthetic.
  ///
  /// In en, this message translates to:
  /// **'Choose an aesthetic for your outfit AI'**
  String get chooseAesthetic;

  /// No description provided for @occasionUniversity.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get occasionUniversity;

  /// No description provided for @occasionWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get occasionWork;

  /// No description provided for @occasionDateNight.
  ///
  /// In en, this message translates to:
  /// **'Date Night'**
  String get occasionDateNight;

  /// No description provided for @occasionGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get occasionGym;

  /// No description provided for @occasionParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get occasionParty;

  /// No description provided for @occasionTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get occasionTravel;

  /// No description provided for @occasionEveryday.
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get occasionEveryday;

  /// No description provided for @styleStreetwear.
  ///
  /// In en, this message translates to:
  /// **'Streetwear'**
  String get styleStreetwear;

  /// No description provided for @styleElegant.
  ///
  /// In en, this message translates to:
  /// **'Elegant'**
  String get styleElegant;

  /// No description provided for @styleMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get styleMinimal;

  /// No description provided for @styleVintage.
  ///
  /// In en, this message translates to:
  /// **'Vintage'**
  String get styleVintage;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @regenerateOutfit.
  ///
  /// In en, this message translates to:
  /// **'Regenerate Outfit'**
  String get regenerateOutfit;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @aiSuggestion.
  ///
  /// In en, this message translates to:
  /// **'AI Suggestion'**
  String get aiSuggestion;

  /// No description provided for @curatedLook.
  ///
  /// In en, this message translates to:
  /// **'Your Curated Look'**
  String get curatedLook;

  /// No description provided for @colorMatch.
  ///
  /// In en, this message translates to:
  /// **'{percent}% color match'**
  String colorMatch(int percent);

  /// No description provided for @outfitReady.
  ///
  /// In en, this message translates to:
  /// **'Your outfit is ready'**
  String get outfitReady;

  /// No description provided for @pieces.
  ///
  /// In en, this message translates to:
  /// **'Pieces'**
  String get pieces;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemCount(int count);

  /// No description provided for @piecesHint.
  ///
  /// In en, this message translates to:
  /// **'Pin a piece to keep it, or swap it for another.'**
  String get piecesHint;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// No description provided for @pinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinned;

  /// No description provided for @unpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// No description provided for @swap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swap;

  /// No description provided for @iWoreThis.
  ///
  /// In en, this message translates to:
  /// **'I wore this'**
  String get iWoreThis;

  /// No description provided for @wornToday.
  ///
  /// In en, this message translates to:
  /// **'Saved to today\'s wear log'**
  String get wornToday;

  /// No description provided for @couldNotSaveWear.
  ///
  /// In en, this message translates to:
  /// **'Could not save what you wore.'**
  String get couldNotSaveWear;

  /// No description provided for @outfitSaved.
  ///
  /// In en, this message translates to:
  /// **'Outfit saved!'**
  String get outfitSaved;

  /// No description provided for @couldNotSaveOutfit.
  ///
  /// In en, this message translates to:
  /// **'Could not save outfit. Please try again.'**
  String get couldNotSaveOutfit;

  /// No description provided for @noOutfitGenerated.
  ///
  /// In en, this message translates to:
  /// **'No outfit generated. Please try again.'**
  String get noOutfitGenerated;

  /// No description provided for @selectOccasionAndStyle.
  ///
  /// In en, this message translates to:
  /// **'Please select both an occasion and a style.'**
  String get selectOccasionAndStyle;

  /// No description provided for @emptyWardrobe.
  ///
  /// In en, this message translates to:
  /// **'Your wardrobe is empty. Please add items first.'**
  String get emptyWardrobe;

  /// No description provided for @noMatchingOutfit.
  ///
  /// In en, this message translates to:
  /// **'No matching outfit found. Try a different occasion or add more clothes to your wardrobe!'**
  String get noMatchingOutfit;

  /// No description provided for @generateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate outfit. Please check your connection and try again.'**
  String get generateFailed;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location to build today\'s outfit.'**
  String get allowLocation;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @allowLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get allowLocationButton;

  /// No description provided for @createYourLook.
  ///
  /// In en, this message translates to:
  /// **'Create Your Look'**
  String get createYourLook;

  /// No description provided for @savedOutfits.
  ///
  /// In en, this message translates to:
  /// **'Saved Outfits'**
  String get savedOutfits;

  /// No description provided for @noSavedOutfits.
  ///
  /// In en, this message translates to:
  /// **'No Saved Outfits Yet'**
  String get noSavedOutfits;

  /// No description provided for @noSavedOutfitsBody.
  ///
  /// In en, this message translates to:
  /// **'Outfits you save will show up here.'**
  String get noSavedOutfitsBody;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get accountSecurity;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone and you will lose all saved settings, outfits, and wardrobe items.'**
  String get deleteAccountBody;

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

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get errorLoadingProfile;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @failedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get failedToPickImage;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @wardrobe.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe'**
  String get wardrobe;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryShirts.
  ///
  /// In en, this message translates to:
  /// **'Shirts'**
  String get categoryShirts;

  /// No description provided for @categoryPants.
  ///
  /// In en, this message translates to:
  /// **'Pants'**
  String get categoryPants;

  /// No description provided for @categoryJackets.
  ///
  /// In en, this message translates to:
  /// **'Jackets'**
  String get categoryJackets;

  /// No description provided for @categoryShoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get categoryShoes;

  /// No description provided for @categoryAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get categoryAccessories;

  /// No description provided for @emptyWardrobeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your wardrobe is empty'**
  String get emptyWardrobeTitle;

  /// No description provided for @emptyWardrobeBody.
  ///
  /// In en, this message translates to:
  /// **'Add clothes so the stylist can build outfits.'**
  String get emptyWardrobeBody;

  /// No description provided for @addClothes.
  ///
  /// In en, this message translates to:
  /// **'Add clothes'**
  String get addClothes;

  /// No description provided for @reasonWeather.
  ///
  /// In en, this message translates to:
  /// **'Works in {weather} weather.'**
  String reasonWeather(String weather);

  /// No description provided for @reasonSeason.
  ///
  /// In en, this message translates to:
  /// **'Works for {season}.'**
  String reasonSeason(String season);

  /// No description provided for @reasonStyleRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Style filter relaxed so an outfit could be made.'**
  String get reasonStyleRelaxed;

  /// No description provided for @reasonStyleMatch.
  ///
  /// In en, this message translates to:
  /// **'Matches {style}.'**
  String reasonStyleMatch(String style);

  /// No description provided for @reasonRepeated.
  ///
  /// In en, this message translates to:
  /// **'Repeated a piece because the wardrobe is small.'**
  String get reasonRepeated;

  /// No description provided for @reasonColorPair.
  ///
  /// In en, this message translates to:
  /// **'{left} pairs with {right}.'**
  String reasonColorPair(String left, String right);

  /// No description provided for @reasonColorClash.
  ///
  /// In en, this message translates to:
  /// **'{left} clashes with {right}.'**
  String reasonColorClash(String left, String right);

  /// No description provided for @reasonNeutral.
  ///
  /// In en, this message translates to:
  /// **'Some colors have no rule, so they stay neutral.'**
  String get reasonNeutral;

  /// No description provided for @generateWeek.
  ///
  /// In en, this message translates to:
  /// **'Generate this week'**
  String get generateWeek;

  /// No description provided for @markWorn.
  ///
  /// In en, this message translates to:
  /// **'I wore this'**
  String get markWorn;

  /// No description provided for @regenerateDay.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerateDay;

  /// No description provided for @packingList.
  ///
  /// In en, this message translates to:
  /// **'Packing list'**
  String get packingList;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search a city'**
  String get searchCity;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @addStop.
  ///
  /// In en, this message translates to:
  /// **'Add stop'**
  String get addStop;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endDate;

  /// No description provided for @generateTrip.
  ///
  /// In en, this message translates to:
  /// **'Generate trip'**
  String get generateTrip;

  /// No description provided for @noCities.
  ///
  /// In en, this message translates to:
  /// **'Add at least one city.'**
  String get noCities;

  /// No description provided for @tripTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get tripTitle;

  /// No description provided for @weekEmpty.
  ///
  /// In en, this message translates to:
  /// **'Generate a week from the forecast and your calendar.'**
  String get weekEmpty;

  /// No description provided for @couldNotReadWeather.
  ///
  /// In en, this message translates to:
  /// **'Could not read the weather. Try again.'**
  String get couldNotReadWeather;

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get userNotLoggedIn;
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
      <String>['ar', 'en'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
