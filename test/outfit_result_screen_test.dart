import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_selctor/data/datasources/ai_service.dart';
import 'package:outfit_selctor/data/models/clothing_item_model.dart';
import 'package:outfit_selctor/data/models/outfit_model.dart';
import 'package:outfit_selctor/data/repositories/wardrobe_repository.dart';
import 'package:outfit_selctor/data/repositories/wear_log_repository.dart';
import 'package:outfit_selctor/features/outfit_generator/cubit/outfit_cubit.dart';
import 'package:outfit_selctor/features/outfit_generator/screens/outfit_result_screen.dart';
import 'package:outfit_selctor/l10n/app_localizations.dart';

class _Wardrobe implements WardrobeRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _AI implements AIService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _WearLog implements WearLogRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('every piece shows, including shoes, bag and accessory', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final cubit = OutfitCubit(_Wardrobe(), _AI(), wearLog: _WearLog());
    addTearDown(cubit.close);
    cubit.show(
      OutfitModel(
        id: 'o',
        name: '',
        occasion: 'date night',
        colorScore: 0.8,
        items: [
          ClothingItemModel(id: 'w', name: '', type: 'watch', color: 'black'),
          ClothingItemModel(id: 's', name: '', type: 'boots', color: 'brown'),
          ClothingItemModel(id: 'b', name: '', type: 'jeans', color: 'navy'),
          ClothingItemModel(id: 'bag', name: '', type: 'handbag', color: 'black'),
          ClothingItemModel(id: 't', name: '', type: 'shirt', color: 'white'),
        ],
      ),
      weather: 'cold',
      season: 'winter',
    );

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: OutfitResultScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shirt · Jeans · Boots · Handbag · Watch'), findsOneWidget);
    expect(find.text('Date Night'), findsOneWidget);
    expect(find.text('Cold'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('Swap shoes'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('ACCESSORIES'), 300);
    expect(find.text('5 items'), findsOneWidget);
    for (final label in ['TOPS', 'BOTTOMS', 'SHOES', 'BAGS', 'ACCESSORIES']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a piece on the board opens its details', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final cubit = OutfitCubit(_Wardrobe(), _AI(), wearLog: _WearLog());
    addTearDown(cubit.close);
    cubit.show(
      OutfitModel(
        id: 'o',
        name: '',
        occasion: 'university',
        colorScore: 1,
        items: [
          ClothingItemModel(id: 's', name: '', type: 'sneakers', color: 'black'),
          ClothingItemModel(id: 'b', name: '', type: 'trousers', color: 'black'),
          ClothingItemModel(id: 't', name: '', type: 'shirt', color: 'olive'),
        ],
      ),
    );

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: OutfitResultScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Sneakers').first);
    await tester.pumpAndSettle();

    final sheet = find.byType(BottomSheet);
    expect(sheet, findsOneWidget);
    expect(find.descendant(of: sheet, matching: find.text('SHOES')), findsOneWidget);
    expect(find.descendant(of: sheet, matching: find.text('Swap')), findsOneWidget);
    expect(find.descendant(of: sheet, matching: find.text('Pin')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
