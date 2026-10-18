// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AI Outfit Stylist';

  @override
  String get welcomeTagline => 'Your personal AI fashion assistant.';

  @override
  String get welcomeBack => 'WELCOME BACK';

  @override
  String hiUser(String name) {
    return 'Hi, $name';
  }

  @override
  String get aiReady => 'AI Ready';

  @override
  String get premiumAi => 'PREMIUM AI';

  @override
  String get generateYourOutfit => 'Generate\nYour Outfit';

  @override
  String get generateSubtitle =>
      'Discover your perfect look with AI\ntailored to your unique style.';

  @override
  String get todayOutfit => 'Today\'s outfit';

  @override
  String get chooseOccasionStyle => 'Choose occasion and style';

  @override
  String get thisWeek => 'This week';

  @override
  String get planTrip => 'Plan a trip';

  @override
  String get navHome => 'Home';

  @override
  String get navWardrobe => 'Wardrobe';

  @override
  String get navGenerate => 'Generate';

  @override
  String get navSaved => 'Saved';

  @override
  String get navProfile => 'Profile';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get createAccount => 'Create Account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get getStarted => 'Get Started';

  @override
  String get outfitDetails => 'Outfit Details';

  @override
  String stepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get whatsTheOccasion => 'What\'s the occasion?';

  @override
  String get selectWhere => 'Select where you\'re headed today';

  @override
  String get pickStyle => 'Pick your style preference';

  @override
  String get chooseAesthetic => 'Choose an aesthetic for your outfit AI';

  @override
  String get occasionUniversity => 'University';

  @override
  String get occasionWork => 'Work';

  @override
  String get occasionDateNight => 'Date Night';

  @override
  String get occasionGym => 'Gym';

  @override
  String get occasionParty => 'Party';

  @override
  String get occasionTravel => 'Travel';

  @override
  String get occasionEveryday => 'Everyday';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleElegant => 'Elegant';

  @override
  String get styleMinimal => 'Minimal';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get generate => 'Generate';

  @override
  String get regenerateOutfit => 'Regenerate Outfit';

  @override
  String get generating => 'Generating...';

  @override
  String get aiSuggestion => 'AI Suggestion';

  @override
  String get curatedLook => 'Your Curated Look';

  @override
  String colorMatch(int percent) {
    return '$percent% color match';
  }

  @override
  String get outfitReady => 'Your outfit is ready';

  @override
  String get pieces => 'Pieces';

  @override
  String itemCount(int count) {
    return '$count items';
  }

  @override
  String get piecesHint => 'Pin a piece to keep it, or swap it for another.';

  @override
  String get pin => 'Pin';

  @override
  String get pinned => 'Pinned';

  @override
  String get unpin => 'Unpin';

  @override
  String get swap => 'Swap';

  @override
  String get iWoreThis => 'I wore this';

  @override
  String get wornToday => 'Saved to today\'s wear log';

  @override
  String get couldNotSaveWear => 'Could not save what you wore.';

  @override
  String get outfitSaved => 'Outfit saved!';

  @override
  String get couldNotSaveOutfit => 'Could not save outfit. Please try again.';

  @override
  String get noOutfitGenerated => 'No outfit generated. Please try again.';

  @override
  String get selectOccasionAndStyle =>
      'Please select both an occasion and a style.';

  @override
  String get emptyWardrobe => 'Your wardrobe is empty. Please add items first.';

  @override
  String get noMatchingOutfit =>
      'No matching outfit found. Try a different occasion or add more clothes to your wardrobe!';

  @override
  String get generateFailed =>
      'Failed to generate outfit. Please check your connection and try again.';

  @override
  String get allowLocation => 'Allow location to build today\'s outfit.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get allowLocationButton => 'Allow location';

  @override
  String get createYourLook => 'Create Your Look';

  @override
  String get savedOutfits => 'Saved Outfits';

  @override
  String get noSavedOutfits => 'No Saved Outfits Yet';

  @override
  String get noSavedOutfitsBody => 'Outfits you save will show up here.';

  @override
  String get profile => 'Profile';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get accountSecurity => 'Account Security';

  @override
  String get logout => 'Logout';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountBody =>
      'Are you sure you want to delete your account? This action cannot be undone and you will lose all saved settings, outfits, and wardrobe items.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get settings => 'Settings';

  @override
  String get errorLoadingProfile => 'Error loading profile';

  @override
  String get retry => 'Retry';

  @override
  String get failedToPickImage => 'Failed to pick image';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get wardrobe => 'Wardrobe';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryTops => 'Tops';

  @override
  String get categoryBottoms => 'Bottoms';

  @override
  String get categoryOuterwear => 'Outerwear';

  @override
  String get categoryDresses => 'Dresses';

  @override
  String get categoryShoes => 'Shoes';

  @override
  String get categoryBags => 'Bags';

  @override
  String get categoryAccessories => 'Accessories';

  @override
  String get typeTShirt => 'T-shirt';

  @override
  String get typeShirt => 'Shirt';

  @override
  String get typeBlouse => 'Blouse';

  @override
  String get typePolo => 'Polo';

  @override
  String get typeTankTop => 'Tank top';

  @override
  String get typeSweater => 'Sweater';

  @override
  String get typeHoodie => 'Hoodie';

  @override
  String get typeSweatshirt => 'Sweatshirt';

  @override
  String get typeCardigan => 'Cardigan';

  @override
  String get typeJeans => 'Jeans';

  @override
  String get typeTrousers => 'Trousers';

  @override
  String get typeChinos => 'Chinos';

  @override
  String get typeJoggers => 'Joggers';

  @override
  String get typeShorts => 'Shorts';

  @override
  String get typeSkirt => 'Skirt';

  @override
  String get typeLeggings => 'Leggings';

  @override
  String get typeJacket => 'Jacket';

  @override
  String get typeDenimJacket => 'Denim jacket';

  @override
  String get typeLeatherJacket => 'Leather jacket';

  @override
  String get typePufferJacket => 'Puffer jacket';

  @override
  String get typeCoat => 'Coat';

  @override
  String get typeBlazer => 'Blazer';

  @override
  String get typeVest => 'Vest';

  @override
  String get typeDress => 'Dress';

  @override
  String get typeJumpsuit => 'Jumpsuit';

  @override
  String get typeSneakers => 'Sneakers';

  @override
  String get typeBoots => 'Boots';

  @override
  String get typeHeels => 'Heels';

  @override
  String get typeFlats => 'Flats';

  @override
  String get typeSandals => 'Sandals';

  @override
  String get typeFlipFlops => 'Flip flops';

  @override
  String get typeLoafers => 'Loafers';

  @override
  String get typeFormalShoes => 'Formal shoes';

  @override
  String get typeHandbag => 'Handbag';

  @override
  String get typeBackpack => 'Backpack';

  @override
  String get typeCrossbodyBag => 'Crossbody bag';

  @override
  String get typeToteBag => 'Tote bag';

  @override
  String get typeWallet => 'Wallet';

  @override
  String get typeCap => 'Cap';

  @override
  String get typeHat => 'Hat';

  @override
  String get typeSunglasses => 'Sunglasses';

  @override
  String get typeWatch => 'Watch';

  @override
  String get typeBelt => 'Belt';

  @override
  String get typeScarf => 'Scarf';

  @override
  String get typeTie => 'Tie';

  @override
  String get typeSocks => 'Socks';

  @override
  String get typeJewelry => 'Jewelry';

  @override
  String get colorWhite => 'White';

  @override
  String get colorCream => 'Cream';

  @override
  String get colorBeige => 'Beige';

  @override
  String get colorTan => 'Tan';

  @override
  String get colorKhaki => 'Khaki';

  @override
  String get colorBrown => 'Brown';

  @override
  String get colorLightGrey => 'Light grey';

  @override
  String get colorGrey => 'Grey';

  @override
  String get colorCharcoal => 'Charcoal';

  @override
  String get colorBlack => 'Black';

  @override
  String get colorNavy => 'Navy';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorLightBlue => 'Light blue';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorOlive => 'Olive';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorRed => 'Red';

  @override
  String get colorBurgundy => 'Burgundy';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorNone => 'None';

  @override
  String twoColors(String first, String second) {
    return '$first & $second';
  }

  @override
  String itemTitle(String color, String type) {
    return '$color $type';
  }

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get selectAll => 'Select all';

  @override
  String get deselectAll => 'Deselect all';

  @override
  String deleteSelected(int count) {
    return 'Delete ($count)';
  }

  @override
  String deleteItemsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count items?',
      one: 'Delete 1 item?',
    );
    return '$_temp0';
  }

  @override
  String get deleteItemsBody =>
      'They and their photos will be removed. This can\'t be undone.';

  @override
  String itemsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items deleted',
      one: '1 item deleted',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed => 'Couldn\'t delete. Please try again.';

  @override
  String get partialItemsTitle => 'Partly visible items';

  @override
  String get partialItemsBody =>
      'These weren\'t fully in the photo. Choose which to add anyway.';

  @override
  String get partialReasonCutOff => 'Only part of it is in the photo';

  @override
  String get partialReasonHidden => 'Mostly hidden under another item';

  @override
  String get partialItemsTip =>
      'For a full card, photograph it alone, laid flat or on a hanger.';

  @override
  String partialKeepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count items',
      one: 'Add 1 item',
      zero: 'Add selected',
    );
    return '$_temp0';
  }

  @override
  String get partialSkip => 'Skip';

  @override
  String get analyzingTitle => 'Analyzing your clothes';

  @override
  String get analyzingSubtitle => 'AI is finding each item and its details';

  @override
  String analyzingCount(int done, int total) {
    return '$done of $total';
  }

  @override
  String get emptyWardrobeTitle => 'Your wardrobe is empty';

  @override
  String get emptyWardrobeBody =>
      'Add clothes so the stylist can build outfits.';

  @override
  String get addClothes => 'Add clothes';

  @override
  String reasonWeather(String weather) {
    return 'Works in $weather weather.';
  }

  @override
  String reasonSeason(String season) {
    return 'Works for $season.';
  }

  @override
  String get reasonStyleRelaxed =>
      'Style filter relaxed so an outfit could be made.';

  @override
  String reasonStyleMatch(String style) {
    return 'Matches $style.';
  }

  @override
  String get reasonRepeated =>
      'Repeated a piece because the wardrobe is small.';

  @override
  String reasonColorPair(String left, String right) {
    return '$left pairs with $right.';
  }

  @override
  String reasonColorClash(String left, String right) {
    return '$left clashes with $right.';
  }

  @override
  String get reasonNeutral => 'Some colors have no rule, so they stay neutral.';

  @override
  String get generateWeek => 'Generate this week';

  @override
  String get markWorn => 'I wore this';

  @override
  String get regenerateDay => 'Regenerate';

  @override
  String get packingList => 'Packing list';

  @override
  String get searchCity => 'Search a city';

  @override
  String get search => 'Search';

  @override
  String get addStop => 'Add stop';

  @override
  String get startDate => 'Start';

  @override
  String get endDate => 'End';

  @override
  String get generateTrip => 'Generate trip';

  @override
  String get noCities => 'Add at least one city.';

  @override
  String get tripTitle => 'Trip';

  @override
  String get weekEmpty =>
      'Generate a week from the forecast and your calendar.';

  @override
  String get couldNotReadWeather => 'Could not read the weather. Try again.';

  @override
  String get userNotLoggedIn => 'User not logged in';
}
