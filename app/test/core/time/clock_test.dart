// T-212: the clock ticks on each minute boundary and exactly at registered instants.
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/time/clock.dart';

final start = DateTime.utc(2026, 10, 12, 5, 0, 20); // 10:30:20 IST

/// Runs [body] with fake time; the clock reads [start] + elapsed fake time.
void withFakeClock(void Function(FakeAsync async, ProviderContainer c) body) {
  fakeAsync((async) {
    final c = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(() => start.add(async.elapsed)),
      ],
    );
    body(async, c);
    c.dispose();
    expect(async.pendingTimers, isEmpty, reason: 'dispose cancels the timer');
  });
}

void main() {
  test('nextMinute', () {
    expect(nextMinute(start), DateTime.utc(2026, 10, 12, 5, 1));
    expect(
      nextMinute(DateTime.utc(2026, 10, 12, 5, 1)),
      DateTime.utc(2026, 10, 12, 5, 2),
    );
    expect(
      nextMinute(DateTime.utc(2026, 10, 12, 18, 29, 59, 999)),
      DateTime.utc(2026, 10, 12, 18, 30), // IST midnight
    );
  });

  test('ticks on the minute boundary, not before', () {
    withFakeClock((async, c) {
      final ticks = <DateTime>[];
      c.listen(nowProvider, (_, n) => ticks.add(n), fireImmediately: true);
      expect(ticks, [start]);
      async.elapse(const Duration(seconds: 39));
      expect(ticks, [start]);
      async.elapse(const Duration(seconds: 1));
      expect(ticks.last, DateTime.utc(2026, 10, 12, 5, 1));
      async.elapse(const Duration(minutes: 2));
      expect(ticks.skip(1), [
        DateTime.utc(2026, 10, 12, 5, 1),
        DateTime.utc(2026, 10, 12, 5, 2),
        DateTime.utc(2026, 10, 12, 5, 3),
      ]);
    });
  });

  test('fires exactly at a registered transition', () {
    withFakeClock((async, c) {
      final ticks = <DateTime>[];
      c.listen(nowProvider, (_, n) => ticks.add(n));
      final transition = DateTime.utc(2026, 10, 12, 5, 0, 31, 500);
      c.read(nowProvider.notifier).wakeAt([
        transition,
        start.subtract(const Duration(hours: 1)), // past: ignored
      ]);
      async.elapse(const Duration(seconds: 11));
      expect(ticks, isEmpty);
      async.elapse(const Duration(milliseconds: 500));
      expect(ticks, [transition]);
      async.elapse(const Duration(seconds: 29));
      expect(ticks, [transition, DateTime.utc(2026, 10, 12, 5, 1)]);
    });
  });

  test('refresh re-reads the clock at once', () {
    withFakeClock((async, c) {
      c.listen(nowProvider, (_, _) {});
      async.elapse(const Duration(seconds: 5));
      expect(c.read(nowProvider), start);
      c.read(nowProvider.notifier).refresh();
      expect(c.read(nowProvider), start.add(const Duration(seconds: 5)));
    });
  });
}
