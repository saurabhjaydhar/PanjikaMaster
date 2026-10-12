// T-107: language follows the device on first launch and switches instantly (FR-SET-05).
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/core/l10n/app_language.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';

const channel = MethodChannel('panjika/app_locale');

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  required List<Locale> device,
  SettingsSource? settings,
}) async {
  final container = ProviderContainer(
    overrides: [
      deviceLocalesProvider.overrideWithValue(device),
      settingsSourceProvider.overrideWithValue(settings ?? MemorySettings()),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const PanjikaApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  final calls = <MethodCall>[];
  String? systemTag;

  setUp(() {
    calls.clear();
    systemTag = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'get') return systemTag ?? '';
          if (call.method == 'set') {
            systemTag = (call.arguments as Map)['tag'] as String;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('Bengali device starts in Bengali', (tester) async {
    await pumpApp(tester, device: const [Locale('bn', 'IN')]);
    expect(find.text('বাংলা পঞ্জিকা'), findsOneWidget);
  });

  testWidgets('English device starts in English', (tester) async {
    await pumpApp(tester, device: const [Locale('en', 'GB')]);
    expect(find.text('Bangla Panjika'), findsOneWidget);
  });

  testWidgets(
    'switching language re-renders at once and keeps the same screen',
    (tester) async {
      final container = await pumpApp(tester, device: const [Locale('bn')]);
      final stateBefore = tester.state(find.byType(PanjikaApp));

      await container.read(appLanguageProvider.notifier).select(AppLanguage.en);
      await tester.pump();

      expect(find.text('Bangla Panjika'), findsOneWidget);
      expect(find.text('বাংলা পঞ্জিকা'), findsNothing);
      expect(
        tester.state(find.byType(PanjikaApp)),
        same(stateBefore),
        reason: 'no restart',
      );
      expect(systemTag, 'en', reason: 'mirrored to Android per-app language');
    },
  );

  testWidgets('a per-app language set in Android settings is picked up', (
    tester,
  ) async {
    systemTag = 'en';
    await pumpApp(tester, device: const [Locale('bn')]);
    expect(find.text('Bangla Panjika'), findsOneWidget);
  });

  testWidgets('numerals follow the language unless overridden', (tester) async {
    final container = await pumpApp(tester, device: const [Locale('bn')]);
    expect(container.read(formatterProvider).digits('12'), '১২');

    await container.read(appLanguageProvider.notifier).select(AppLanguage.en);
    expect(container.read(formatterProvider).digits('12'), '12');

    await container
        .read(numeralOverrideProvider.notifier)
        .set(NumeralStyle.bengali);
    expect(container.read(formatterProvider).digits('12'), '১২');
  });
}
