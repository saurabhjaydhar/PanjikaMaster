import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/core/settings/settings.dart';

void main() {
  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsSourceProvider.overrideWithValue(MemorySettings())],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
