import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_selctor/data/models/clothing_item_model.dart';
import 'package:outfit_selctor/data/repositories/wardrobe_repository.dart';
import 'package:outfit_selctor/features/wardrobe/cubit/wardrobe_cubit.dart';
import 'package:outfit_selctor/features/wardrobe/screens/wardrobe_screen.dart';
import 'package:outfit_selctor/l10n/app_localizations.dart';

class FakeRepository implements WardrobeRepository {
  final items = [
    ClothingItemModel(id: 'a', name: '', type: 'jeans', color: 'blue'),
    ClothingItemModel(id: 'b', name: '', type: 't-shirt', color: 'white'),
    ClothingItemModel(id: 'c', name: '', type: 'sneakers', color: 'black'),
  ];
  final deleted = <List<String>>[];

  @override
  Future<List<ClothingItemModel>> getClothingItems() async => List.of(items);

  @override
  Future<void> deleteClothingItems(List<String> ids) async {
    deleted.add(ids);
    items.removeWhere((item) => ids.contains(item.id));
  }

  @override
  Future<void> deleteClothingItem(String id) => deleteClothingItems([id]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(FakeRepository repository) {
  return BlocProvider(
    create: (_) => WardrobeCubit(repository),
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: WardrobeScreen(),
    ),
  );
}

void _tallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('long press selects, tap adds, delete removes after confirming', (tester) async {
    _tallScreen(tester);
    final repository = FakeRepository();
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('Blue Jeans'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.longPress(find.text('Blue Jeans'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);
    expect(find.text('Delete (1)'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);

    await tester.tap(find.text('White T-shirt'));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(find.text('Delete (2)'));
    await tester.pumpAndSettle();
    expect(find.text('Delete 2 items?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(repository.deleted, [
      ['a', 'b'],
    ]);
    expect(find.text('Blue Jeans'), findsNothing);
    expect(find.text('Black Sneakers'), findsOneWidget);
    expect(find.text('2 items deleted'), findsOneWidget);
    expect(find.text('2 selected'), findsNothing);
  });

  testWidgets('select all, cancel and the close button leave items alone', (tester) async {
    _tallScreen(tester);
    final repository = FakeRepository();
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Black Sneakers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();
    expect(find.text('3 selected'), findsOneWidget);
    expect(find.text('Deselect all'), findsOneWidget);

    await tester.tap(find.text('Delete (3)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.deleted, isEmpty);
    expect(find.text('3 selected'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('3 selected'), findsNothing);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
