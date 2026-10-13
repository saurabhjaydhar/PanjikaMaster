import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/name_text.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../core/l10n/panjika_formatter.dart';
import '../../core/time/civil_date.dart';
import '../../core/time/clock.dart';
import '../../data/notifications/notification_permission.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/entities/panjika.dart';
import '../../domain/reminders/plan_reminders.dart';
import '../../domain/reminders/reminder_config.dart';
import '../../l10n/gen/app_localizations.dart';
import 'notifications_off_note.dart';
import 'reminder_prefs.dart';

/// Whether the phone lets the app post notifications; re-read when the screen opens.
final notificationsAllowedProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(notificationPermissionProvider).granted(),
);

final _observanceProvider = FutureProvider.family<Observance?, String>(
  (ref, id) => ref.watch(panjikaRepositoryProvider).observance(id),
);

/// Reminders (অনুস্মারক, spec §11.13, FR-REM-01..02): recurring Ekadashi / Purnima /
/// Amavasya, festival reminders with their timings, "add a festival", and a banner
/// when the phone blocks notifications.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final config = ref.watch(reminderConfigProvider);
    final allowed = ref.watch(notificationsAllowedProvider).value ?? true;
    final margin = contentInset(MediaQuery.sizeOf(context).width);
    final prefs = ref.read(reminderConfigProvider.notifier);

    Future<void> turnOn(Future<void> Function() change) async {
      final ok = await ensureNotificationPermission(
        ref.read(notificationPermissionProvider),
      );
      ref.invalidate(notificationsAllowedProvider);
      if (ok) await change();
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.menuReminders)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(margin, Space.s, margin, Space.xl),
        children: [
          if (!allowed) ...[
            const NotificationsOffNote(),
            const SizedBox(height: Space.m),
          ],
          if (config.isEmpty) ...[
            Text(
              l.remindersEmpty,
              style: t.bodyLarge?.copyWith(color: c.inkMuted),
            ),
            const SizedBox(height: Space.m),
          ],
          SectionHeader(title: l.sectionRecurring),
          for (final (kind, label) in [
            (RecurringKind.ekadashi, l.recurringEkadashi),
            (RecurringKind.purnima, l.recurringPurnima),
            (RecurringKind.amavasya, l.recurringAmavasya),
          ])
            _ReminderRow(
              title: Text(label, style: t.bodyLarge),
              times: config.recurring[kind],
              onToggle: (on) => on
                  ? turnOn(
                      () => prefs.setRecurring(
                        kind,
                        ReminderConfig.recurringDefault,
                      ),
                    )
                  : prefs.setRecurring(kind, null),
              onEdit: (times) => prefs.setRecurring(kind, times),
            ),
          const SizedBox(height: Space.l),
          SectionHeader(title: l.sectionFestivalReminders),
          for (final MapEntry(key: id, value: times)
              in config.festivals.entries)
            _ReminderRow(
              title: switch (ref.watch(_observanceProvider(id)).value) {
                final Observance o => NameText(o.name, style: t.bodyLarge),
                _ => Text(id, style: t.bodyLarge), // l10n-ok: not in the packs
              },
              times: times,
              onToggle: (on) => prefs.setFestival(id, null),
              onEdit: (next) => prefs.setFestival(id, next),
            ),
          const SizedBox(height: Space.s),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              onPressed: () => context.go(Routes.festivals),
              icon: const Icon(Icons.add),
              label: Text(l.addFestivalReminder),
            ),
          ),
          const SizedBox(height: Space.l),
          // Inexact alarms on some phones (TODO(Q7)): point to the settings guide.
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => context.push(Routes.helpReminders),
              icon: const Icon(Icons.help_outline),
              label: Text(l.remindersHelpLink),
            ),
          ),
        ],
      ),
    );
  }
}

/// The text for a list of timings, e.g. "আগের দিন রাত ৮:০০".
String timingSummary(
  AppLocalizations l,
  PanjikaFormatter f,
  List<ReminderTime> times,
  CivilDate today,
) {
  String one(ReminderTime t) {
    final clock = f.time(istInstant(today, t.minutes));
    return switch (t.timing) {
      ReminderTiming.dayBefore => l.timingDayBefore(clock),
      ReminderTiming.morningOf => l.timingMorningOf(clock),
      ReminderTiming.tithiStart => l.timingTithiStart,
    };
  }

  final parts = times.map(one).toList();
  return parts.length == 1 ? parts.single : l.timingBoth(parts[0], parts[1]);
}

class _ReminderRow extends ConsumerWidget {
  const _ReminderRow({
    required this.title,
    required this.times,
    required this.onToggle,
    required this.onEdit,
  });

  final Widget title;
  final List<ReminderTime>? times;
  final Future<void> Function(bool on) onToggle;
  final Future<void> Function(List<ReminderTime> times) onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatterProvider);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final today = CivilDate.ofInstant(ref.watch(nowProvider));
    final on = times != null;
    return InkWell(
      onTap: on ? () => _editTimes(context, times!, onEdit) : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Space.minTouch),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Space.s),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    if (on)
                      Text(
                        timingSummary(l, f, times!, today),
                        style: t.bodyMedium?.copyWith(color: c.inkMuted),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: Space.m),
              Switch(value: on, onChanged: onToggle),
            ],
          ),
        ),
      ),
    );
  }
}

/// Day before and/or on the morning, each with its own time (spec §11.13). At least
/// one stays on; the "tithi begins" option needs exact alarms. TODO(Q7)
Future<void> _editTimes(
  BuildContext context,
  List<ReminderTime> current,
  Future<void> Function(List<ReminderTime>) onEdit,
) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (sheet) => _TimingSheet(current: current, onEdit: onEdit),
);

class _TimingSheet extends ConsumerStatefulWidget {
  const _TimingSheet({required this.current, required this.onEdit});

  final List<ReminderTime> current;
  final Future<void> Function(List<ReminderTime>) onEdit;

  @override
  ConsumerState<_TimingSheet> createState() => _TimingSheetState();
}

class _TimingSheetState extends ConsumerState<_TimingSheet> {
  late final Map<ReminderTiming, int?> _times = {
    for (final timing in const [
      ReminderTiming.dayBefore,
      ReminderTiming.morningOf,
    ])
      timing: widget.current
          .where((t) => t.timing == timing)
          .firstOrNull
          ?.minutes,
  };

  List<ReminderTime> get _value => [
    for (final MapEntry(key: timing, value: minutes) in _times.entries)
      if (minutes != null) ReminderTime(timing, minutes),
  ];

  Future<void> _set(ReminderTiming timing, int? minutes) async {
    setState(() => _times[timing] = minutes);
    await widget.onEdit(_value);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatterProvider);
    final t = Theme.of(context).textTheme;
    final today = CivilDate.ofInstant(ref.watch(nowProvider));
    final defaults = {
      ReminderTiming.dayBefore: 20 * 60,
      ReminderTiming.morningOf: 6 * 60,
    };
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.xl, 0, Space.xl, Space.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.timingSheetTitle, style: t.titleLarge),
            const SizedBox(height: Space.m),
            for (final (timing, label) in [
              (ReminderTiming.dayBefore, l.timingDayBeforeOption),
              (ReminderTiming.morningOf, l.timingMorningOption),
            ])
              Row(
                children: [
                  Checkbox(
                    value: _times[timing] != null,
                    // The last timing can't be unticked: turn the reminder off instead.
                    onChanged: _times[timing] != null && _value.length == 1
                        ? null
                        : (v) => _set(timing, v! ? defaults[timing] : null),
                  ),
                  Expanded(child: Text(label, style: t.bodyLarge)),
                  if (_times[timing] case final minutes?)
                    TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: minutes ~/ 60,
                            minute: minutes % 60,
                          ),
                          helpText: l.changeTime,
                        );
                        if (picked != null) {
                          await _set(timing, picked.hour * 60 + picked.minute);
                        }
                      },
                      child: Text(f.time(istInstant(today, minutes))),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
