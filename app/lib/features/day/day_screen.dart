import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../app/widgets/system_states.dart';
import '../../core/time/civil_date.dart';
import '../../core/time/clock.dart';
import '../../data/packs/update_providers.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../share/share_cards.dart';
import '../share/share_render.dart';
import '../share/share_sheet.dart';
import 'day_sections.dart';

/// Day detail (দিন, spec §11.4, §11.10): any date, every section, swipe or arrows for
/// the previous and next day (FR-DAY-01..05).
class DayScreen extends ConsumerStatefulWidget {
  const DayScreen({super.key, required this.date});

  final CivilDate date;

  @override
  ConsumerState<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends ConsumerState<DayScreen> {
  /// Pages are days relative to [DayScreen.date]; the middle page is that date.
  static const _origin = 100000;
  late final PageController _pages = PageController(initialPage: _origin);

  CivilDate _dateAt(int page) => widget.date.addDays(page - _origin);

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int delta) => _pages.animateToPage(
    (_pages.page?.round() ?? _origin) + delta,
    duration: context.motion(const Duration(milliseconds: 250)),
    curve: Curves.easeOutCubic,
  );

  /// Shares the day on screen as a card (FR-DAY-06, spec §11.8).
  void _share() {
    final date = _dateAt(_pages.page?.round() ?? _origin);
    final day = ref.read(dayPanjikaProvider(date)).value;
    final names = ref.read(namesProvider).value;
    if (day == null || names == null) return;
    final data = DayShareData(day: day, names: names);
    showShareSheet(
      context,
      card: (share) => DayShareCard(data: data, share: share),
      message: (share) => data.message(share, link: shareLink(data.path)),
      fileName: 'panjika-${date.toIso()}.png',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.dayTitle),
        actions: [
          IconButton(
            tooltip: l.shareAction,
            icon: const Icon(Icons.share),
            onPressed: _share,
          ),
          IconButton(
            tooltip: l.previousDay,
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _go(-1),
          ),
          IconButton(
            tooltip: l.nextDay,
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _go(1),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pages,
        itemBuilder: (context, page) => _DayPage(_dateAt(page)),
      ),
    );
  }
}

class _DayPage extends ConsumerWidget {
  const _DayPage(this.date);

  final CivilDate date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(dayPanjikaProvider(date));
    final now = ref.watch(nowProvider);
    final updates = ref.read(updateControllerProvider.notifier);
    return switch (day) {
      AsyncValue(value: final d?) => Stack(
        children: [
          ListView(
            padding: EdgeInsets.symmetric(
              horizontal: contentInset(MediaQuery.sizeOf(context).width),
              vertical: screenMargin(MediaQuery.sizeOf(context).width),
            ),
            children: [DaySections(d, now: now)],
          ),
          if (d.provenance.isSample) const SampleWatermark(),
        ],
      ),
      AsyncValue(isLoading: true) => const SizedBox.expand(),
      _ => SystemStateMessage(
        SystemState.notDownloaded,
        onAction: updates.available ? updates.downloadNow : null,
      ),
    };
  }
}
