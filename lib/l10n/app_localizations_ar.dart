// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'منسق الأزياء';

  @override
  String get welcomeTagline => 'مساعدك الشخصي في الأزياء.';

  @override
  String get welcomeBack => 'أهلاً بعودتك';

  @override
  String hiUser(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get aiReady => 'الذكاء جاهز';

  @override
  String get premiumAi => 'ذكاء مميز';

  @override
  String get generateYourOutfit => 'كوّن\nإطلالتك';

  @override
  String get generateSubtitle => 'اكتشف إطلالة تناسبك\nبأسلوبك الخاص.';

  @override
  String get todayOutfit => 'إطلالة النهاردة';

  @override
  String get chooseOccasionStyle => 'اختار المناسبة والستايل';

  @override
  String get thisWeek => 'الأسبوع ده';

  @override
  String get planTrip => 'خطّط لرحلة';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navWardrobe => 'الدولاب';

  @override
  String get navGenerate => 'توليد';

  @override
  String get navSaved => 'المحفوظ';

  @override
  String get navProfile => 'الحساب';

  @override
  String get login => 'دخول';

  @override
  String get register => 'تسجيل';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get email => 'البريد';

  @override
  String get password => 'كلمة السر';

  @override
  String get forgotPassword => 'نسيت كلمة السر؟';

  @override
  String get dontHaveAccount => 'معندكش حساب؟ سجّل';

  @override
  String get alreadyHaveAccount => 'عندك حساب؟ ادخل';

  @override
  String get welcomeTitle => 'أهلاً';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get outfitDetails => 'تفاصيل الإطلالة';

  @override
  String stepOf(int step, int total) {
    return 'خطوة $step من $total';
  }

  @override
  String get whatsTheOccasion => 'إيه المناسبة؟';

  @override
  String get selectWhere => 'اختار رايح فين النهاردة';

  @override
  String get pickStyle => 'اختار الستايل';

  @override
  String get chooseAesthetic => 'اختار الشكل اللي عايزه للإطلالة';

  @override
  String get occasionUniversity => 'جامعة';

  @override
  String get occasionWork => 'شغل';

  @override
  String get occasionDateNight => 'خروجة';

  @override
  String get occasionGym => 'جيم';

  @override
  String get occasionParty => 'حفلة';

  @override
  String get occasionTravel => 'سفر';

  @override
  String get occasionEveryday => 'يوم عادي';

  @override
  String get styleStreetwear => 'ستريت وير';

  @override
  String get styleElegant => 'أنيق';

  @override
  String get styleMinimal => 'بسيط';

  @override
  String get styleVintage => 'فينتج';

  @override
  String get generate => 'توليد';

  @override
  String get regenerateOutfit => 'إطلالة جديدة';

  @override
  String get generating => 'بيجهّز...';

  @override
  String get aiSuggestion => 'اقتراح';

  @override
  String get curatedLook => 'إطلالتك';

  @override
  String colorMatch(int percent) {
    return 'توافق الألوان $percent%';
  }

  @override
  String get outfitReady => 'الإطلالة جاهزة';

  @override
  String get pieces => 'القطع';

  @override
  String itemCount(int count) {
    return '$count قطع';
  }

  @override
  String get piecesHint => 'ثبّت قطعة عشان تفضل، أو غيّرها.';

  @override
  String get pin => 'تثبيت';

  @override
  String get pinned => 'مثبتة';

  @override
  String get unpin => 'إلغاء التثبيت';

  @override
  String get swap => 'تغيير';

  @override
  String get iWoreThis => 'لبستها';

  @override
  String get wornToday => 'اتسجلت في لبس النهاردة';

  @override
  String get couldNotSaveWear => 'ماتسجلش اللي لبستها.';

  @override
  String get outfitSaved => 'الإطلالة اتحفظت';

  @override
  String get couldNotSaveOutfit => 'ماتحفظتش الإطلالة. حاول تاني.';

  @override
  String get noOutfitGenerated => 'مفيش إطلالة. حاول تاني.';

  @override
  String get selectOccasionAndStyle => 'اختار المناسبة والستايل.';

  @override
  String get emptyWardrobe => 'الدولاب فاضي. ضيف هدوم الأول.';

  @override
  String get noMatchingOutfit =>
      'مفيش إطلالة مناسبة. غيّر المناسبة أو ضيف هدوم.';

  @override
  String get generateFailed => 'التوليد فشل. تأكد من الاتصال وحاول تاني.';

  @override
  String get allowLocation => 'اسمح بالموقع عشان نجهّز إطلالة النهاردة.';

  @override
  String get tryAgain => 'حاول تاني';

  @override
  String get allowLocationButton => 'السماح بالموقع';

  @override
  String get createYourLook => 'كوّن إطلالتك';

  @override
  String get savedOutfits => 'الإطلالات المحفوظة';

  @override
  String get noSavedOutfits => 'لسه مفيش إطلالات محفوظة';

  @override
  String get noSavedOutfitsBody => 'الإطلالات اللي تحفظها هتظهر هنا.';

  @override
  String get profile => 'الحساب';

  @override
  String get appearance => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get accountSecurity => 'أمان الحساب';

  @override
  String get logout => 'خروج';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountTitle => 'حذف الحساب';

  @override
  String get deleteAccountBody =>
      'متأكد إنك عايز تحذف الحساب؟ مش هتقدر ترجع في الخطوة دي، وهتخسر الإعدادات والإطلالات والدولاب.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get settings => 'الإعدادات';

  @override
  String get errorLoadingProfile => 'تعذّر تحميل الحساب';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get failedToPickImage => 'اختيار الصورة فشل';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'غامق';

  @override
  String get system => 'النظام';

  @override
  String get wardrobe => 'الدولاب';

  @override
  String get categoryAll => 'الكل';

  @override
  String get categoryShirts => 'قمصان';

  @override
  String get categoryPants => 'بناطيل';

  @override
  String get categoryJackets => 'جاكيتات';

  @override
  String get categoryShoes => 'أحذية';

  @override
  String get categoryAccessories => 'إكسسوارات';

  @override
  String get emptyWardrobeTitle => 'الدولاب فاضي';

  @override
  String get emptyWardrobeBody => 'ضيف هدوم عشان المنسق يقدر يكوّن إطلالات.';

  @override
  String get addClothes => 'ضيف هدوم';

  @override
  String reasonWeather(String weather) {
    return 'تناسب جو $weather.';
  }

  @override
  String reasonSeason(String season) {
    return 'تناسب فصل $season.';
  }

  @override
  String get reasonStyleRelaxed => 'فلتر الستايل اتوسع عشان نقدر نكوّن إطلالة.';

  @override
  String reasonStyleMatch(String style) {
    return 'بتناسب ستايل $style.';
  }

  @override
  String get reasonRepeated => 'قطعة اتكررت لأن الدولاب صغير.';

  @override
  String reasonColorPair(String left, String right) {
    return '$left يتناسق مع $right.';
  }

  @override
  String reasonColorClash(String left, String right) {
    return '$left يتضارب مع $right.';
  }

  @override
  String get reasonNeutral => 'بعض الألوان ملهاش قاعدة، فبتفضل محايدة.';

  @override
  String get generateWeek => 'جهّز الأسبوع';

  @override
  String get markWorn => 'لبستها';

  @override
  String get regenerateDay => 'إطلالة جديدة';

  @override
  String get packingList => 'قائمة السفر';

  @override
  String get searchCity => 'ابحث عن مدينة';

  @override
  String get search => 'بحث';

  @override
  String get addStop => 'ضيف محطة';

  @override
  String get startDate => 'البداية';

  @override
  String get endDate => 'النهاية';

  @override
  String get generateTrip => 'جهّز الرحلة';

  @override
  String get noCities => 'ضيف مدينة واحدة على الأقل.';

  @override
  String get tripTitle => 'رحلة';

  @override
  String get weekEmpty => 'جهّز أسبوع من الطقس وتقويم الموبايل.';

  @override
  String get couldNotReadWeather => 'مقراش الطقس. حاول تاني.';

  @override
  String get userNotLoggedIn => 'مش مسجّل دخول';
}
