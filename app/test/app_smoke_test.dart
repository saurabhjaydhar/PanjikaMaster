import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/panjika_app.dart';

void main() {
  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PanjikaApp()));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
