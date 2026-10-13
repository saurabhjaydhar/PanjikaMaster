// T-410: tradition change — unavailable keeps Drik; a supported change sets the
// setting, reloads what depends on it and fires the reminder hook once.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/features/settings/tradition.dart';

void main() {
  late ProviderContainer c;
  var reschedules = 0;

  ProviderContainer make(Set<String> available) {
    reschedules = 0;
    final container = ProviderContainer(
      overrides: [
        settingsSourceProvider.overrideWithValue(MemorySettings()),
        availableTraditionsProvider.overrideWithValue(available),
        rescheduleRemindersProvider.overrideWithValue(
          () async => reschedules++,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'Surya Siddhanta is not available yet: Drik stays, nothing rescheduled',
    () async {
      c = make(const {'drik_bishuddha'});
      expect(
        await c.read(traditionChangerProvider)('surya_siddhanta'),
        isFalse,
      );
      expect(c.read(traditionProvider), 'drik_bishuddha');
      expect(reschedules, 0);
    },
  );

  test(
    'a supported change switches, dependants reload, reminders reschedule once',
    () async {
      c = make(const {'drik_bishuddha', 'surya_siddhanta'});
      var rebuilds = 0;
      final dependant = Provider((ref) {
        rebuilds++;
        return ref.watch(traditionProvider);
      });
      expect(c.read(dependant), 'drik_bishuddha');
      expect(await c.read(traditionChangerProvider)('surya_siddhanta'), isTrue);
      expect(c.read(dependant), 'surya_siddhanta');
      expect(rebuilds, 2);
      expect(reschedules, 1);
      // Choosing the current tradition again does nothing.
      expect(await c.read(traditionChangerProvider)('surya_siddhanta'), isTrue);
      expect(reschedules, 1);
    },
  );
}
