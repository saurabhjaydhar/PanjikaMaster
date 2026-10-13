import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reads the current instant. Overridden in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// The current instant, refreshed on every minute boundary and at each instant
/// registered with [NowNotifier.wakeAt] (a tithi ending, sunrise), so open screens
/// update on time (FR-HOME-08). Midnight is a minute boundary.
final nowProvider = NotifierProvider<NowNotifier, DateTime>(NowNotifier.new);

class NowNotifier extends Notifier<DateTime> {
  final _wakes = SplayTreeSet<DateTime>();
  Timer? _timer;

  @override
  DateTime build() {
    ref.onDispose(() => _timer?.cancel());
    final now = ref.watch(clockProvider)();
    _schedule(now);
    return now;
  }

  /// Also tick exactly at these instants (past ones are ignored).
  void wakeAt(Iterable<DateTime> instants) {
    final now = ref.read(clockProvider)();
    _wakes.addAll([
      for (final i in instants)
        if (i.isAfter(now)) i.toUtc(),
    ]);
    _schedule(now);
  }

  /// Re-reads the clock now, e.g. when the app returns to the foreground (timers do not
  /// run in the background) or the device time changes.
  void refresh() => _tick();

  void _tick() {
    final now = ref.read(clockProvider)();
    state = now;
    _schedule(now);
  }

  void _schedule(DateTime now) {
    _timer?.cancel();
    _wakes.removeWhere((w) => !w.isAfter(now));
    var next = nextMinute(now);
    if (_wakes.isNotEmpty && _wakes.first.isBefore(next)) next = _wakes.first;
    _timer = Timer(next.difference(now), _tick);
  }
}

/// The next whole minute after [now] (UTC; IST is a whole number of minutes ahead).
DateTime nextMinute(DateTime now) {
  final us = now.toUtc().microsecondsSinceEpoch;
  const minute = Duration.microsecondsPerMinute;
  return DateTime.fromMicrosecondsSinceEpoch(
    (us ~/ minute + 1) * minute,
    isUtc: true,
  );
}
