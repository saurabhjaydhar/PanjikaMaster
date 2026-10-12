import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/panjika_app.dart';

void main() {
  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(const PanjikaApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
