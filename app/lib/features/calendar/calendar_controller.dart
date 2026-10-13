import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/settings.dart';
import '../../core/time/civil_date.dart';
import '../../core/time/clock.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/usecases/get_month_grid.dart';

/// Bengali month view is the default (FR-CAL-02).
enum CalendarMode { bengali, gregorian }

class CalendarState {
  const CalendarState({
    required this.mode,
    required this.selected,
    required this.month,
    this.direction = 0,
    this.resolving = false,
  });

  final CalendarMode mode;
  final CivilDate selected;

  /// Null while the Bengali month of [selected] is being looked up, or when the date
  /// is outside the installed packs.
  final MonthRef? month;

  /// −1 / +1 for the last month change (slide direction), 0 for a jump.
  final int direction;

  /// The month of [selected] is still being looked up.
  final bool resolving;

  CalendarState copyWith({
    CalendarMode? mode,
    CivilDate? selected,
    MonthRef? month,
    int? direction,
    bool clearMonth = false,
  }) => CalendarState(
    mode: mode ?? this.mode,
    selected: selected ?? this.selected,
    month: clearMonth ? null : (month ?? this.month),
    direction: direction ?? this.direction,
  );
}

final calendarProvider = NotifierProvider<CalendarController, CalendarState>(
  CalendarController.new,
);

class CalendarController extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    final today = CivilDate.ofInstant(ref.read(nowProvider));
    Future.microtask(() => _show(today, CalendarMode.bengali, direction: 0));
    return CalendarState(
      mode: CalendarMode.bengali,
      selected: today,
      month: null,
    );
  }

  /// The month that contains [date] in [mode]; Bengali months come from the packs.
  Future<MonthRef?> monthOf(CivilDate date, CalendarMode mode) async {
    if (mode == CalendarMode.gregorian) {
      return GregorianMonthRef(date.year, date.month);
    }
    final bn = await ref
        .read(panjikaRepositoryProvider)
        .bengaliDate(ref.read(traditionProvider), date);
    return bn == null ? null : BengaliMonthRef(bn.year, bn.monthIdx);
  }

  Future<void> _show(
    CivilDate date,
    CalendarMode mode, {
    required int direction,
  }) async {
    MonthRef? month;
    try {
      month = await monthOf(date, mode);
    } on Object {
      month = null; // no packs to read: the screen says "not downloaded"
    }
    if (!ref.mounted) return;
    state = CalendarState(
      mode: mode,
      selected: date,
      month: month,
      direction: direction,
    );
  }

  void next() => _step(1);
  void previous() => _step(-1);

  void _step(int delta) {
    final m = state.month;
    if (m == null) return;
    final next = switch (m) {
      BengaliMonthRef() => delta > 0 ? m.next : m.previous,
      GregorianMonthRef() => delta > 0 ? m.next : m.previous,
    };
    state = state.copyWith(month: next, direction: delta);
  }

  void select(CivilDate date) => state = state.copyWith(selected: date);

  /// Switching modes keeps the selected day (FR-CAL-02).
  Future<void> setMode(CalendarMode mode) =>
      _show(state.selected, mode, direction: 0);

  /// The "আজ / Today" button (FR-CAL-07).
  Future<void> goToday() => _show(
    CivilDate.ofInstant(ref.read(nowProvider)),
    state.mode,
    direction: 0,
  );

  void jumpTo(MonthRef month) =>
      state = state.copyWith(month: month, direction: 0);
}
