import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_selctor/data/models/clothing_item_model.dart';
import 'package:outfit_selctor/data/models/pending_wardrobe_item.dart';
import 'package:outfit_selctor/data/repositories/wardrobe_repository.dart';
import 'package:outfit_selctor/features/wardrobe/cubit/wardrobe_cubit.dart';
import 'package:outfit_selctor/features/wardrobe/cubit/wardrobe_state.dart';
import 'package:outfit_selctor/features/wardrobe/screens/wardrobe_screen.dart';
import 'package:outfit_selctor/l10n/app_localizations.dart';

const _trousers = PendingWardrobeItem(
  jobId: 'job-1',
  id: 'p1',
  reason: PendingWardrobeItem.cutOff,
  type: 'trousers',
  category: 'Bottoms',
  color: 'navy',
);

class FakeRepository implements WardrobeRepository {
  final items = [
    ClothingItemModel(id: 'a', name: '', type: 'shirt', color: 'olive'),
  ];
  final resolved = <List<List<PendingWardrobeItem>>>[];

  @override
  Future<List<ClothingItemModel>> getClothingItems() async => List.of(items);

  @override
  Future<List<PendingWardrobeItem>> addClothingItem(ClothingItemModel item) async =>
      const [_trousers];

  @override
  Future<void> keepPendingItems(
    List<PendingWardrobeItem> all,
    List<PendingWardrobeItem> keep,
  ) async {
    resolved.add([all, keep]);
    for (final item in keep) {
      items.add(ClothingItemModel(id: item.id, name: '', type: item.type, color: item.color));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(WardrobeCubit cubit) {
  return BlocProvider.value(
    value: cubit,
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

Future<WardrobeCubit> _uploadWithPending(WidgetTester tester, FakeRepository repository) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  final cubit = WardrobeCubit(repository);
  addTearDown(cubit.close);
  await tester.pumpWidget(_app(cubit));
  await tester.pumpAndSettle();

  cubit.addClothingItems([File('photo.jpg')]);
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  testWidgets('a partly visible item waits in a sheet and joins on keep', (tester) async {
    final repository = FakeRepository();
    final cubit = await _uploadWithPending(tester, repository);

    expect(find.text('Partly visible items'), findsOneWidget);
    expect(find.text('Navy Trousers'), findsOneWidget);
    expect(find.text('Only part of it is in the photo'), findsOneWidget);
    expect(repository.resolved, isEmpty);

    expect(find.text('Add selected'), findsOneWidget);
    await tester.tap(find.text('Navy Trousers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add 1 item'));
    await tester.pumpAndSettle();

    expect(repository.resolved, [
      [
        [_trousers],
        [_trousers],
      ],
    ]);
    expect(find.text('Partly visible items'), findsNothing);
    expect(find.text('Navy Trousers'), findsOneWidget);
    expect((cubit.state as WardrobeLoaded).pending, isEmpty);
  });

  testWidgets('skip drops the partly visible item', (tester) async {
    final repository = FakeRepository();
    final cubit = await _uploadWithPending(tester, repository);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(repository.resolved, [
      [
        [_trousers],
        <PendingWardrobeItem>[],
      ],
    ]);
    expect(find.text('Navy Trousers'), findsNothing);
    expect(find.text('Olive Shirt'), findsOneWidget);
    expect((cubit.state as WardrobeLoaded).pending, isEmpty);
  });
}
