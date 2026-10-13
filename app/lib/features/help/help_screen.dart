import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/numbered_steps.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../core/platform/system_settings.dart';
import '../../l10n/gen/app_localizations.dart';

/// Sections of Help that other screens can link to.
enum HelpTopic { voice, reminders }

/// Help (সাহায্য, T-613): installing Google's Bengali voice for TalkBack (spec §13,
/// localisation), and the phone settings that keep reminders on time, with steps for
/// Xiaomi and Samsung phones (PRD risk table, §22.2).
class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key, this.topic});

  /// The section to scroll to on open.
  final HelpTopic? topic;

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  final _reminders = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.topic == HelpTopic.reminders) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = _reminders.currentContext;
        if (target != null && target.mounted) {
          unawaited(Scrollable.ensureVisible(target));
        }
      });
    }
  }

  Future<void> _open(SystemSettingsPage page) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await ref.read(systemSettingsProvider).open(page)) {
      messenger.showSnackBar(SnackBar(content: Text(l.helpOpenFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final app = l.appTitle;
    final margin = contentInset(MediaQuery.sizeOf(context).width);
    final muted = t.bodyMedium?.copyWith(color: c.inkMuted);

    Widget button(IconData icon, String label, SystemSettingsPage page) =>
        Padding(
          padding: const EdgeInsets.only(top: Space.s),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              icon: Icon(icon),
              label: Text(label),
              onPressed: () => unawaited(_open(page)),
            ),
          ),
        );

    List<(String, String?)> steps(List<String> texts) => [
      for (final s in texts) (s, null),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.menuHelp)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(margin, Space.s, margin, Space.xl),
        children: [
          SectionHeader(title: l.helpVoiceHeading),
          Text(l.helpVoiceIntro, style: t.bodyLarge),
          NumberedSteps(
            steps([
              l.helpVoiceStep1,
              l.helpVoiceStep2,
              l.helpVoiceStep3,
              l.helpVoiceStep4,
            ]),
          ),
          button(
            Icons.record_voice_over_outlined,
            l.helpOpenTts,
            SystemSettingsPage.tts,
          ),
          const SizedBox(height: Space.xl),
          SectionHeader(key: _reminders, title: l.helpRemindersHeading),
          Text(l.helpRemindersIntro, style: t.bodyLarge),
          NumberedSteps(
            steps([l.helpRemindersStep1(app), l.helpRemindersStep2(app)]),
          ),
          button(
            Icons.notifications_outlined,
            l.helpOpenNotifications,
            SystemSettingsPage.notifications,
          ),
          button(
            Icons.battery_saver_outlined,
            l.helpOpenBattery,
            SystemSettingsPage.battery,
          ),
          const SizedBox(height: Space.l),
          SectionHeader(title: l.helpXiaomiHeading),
          NumberedSteps(
            steps([
              l.helpXiaomiStep1(app),
              l.helpXiaomiStep2,
              l.helpXiaomiStep3,
              l.helpXiaomiStep4,
            ]),
          ),
          const SizedBox(height: Space.l),
          SectionHeader(title: l.helpSamsungHeading),
          NumberedSteps(
            steps([
              l.helpSamsungStep1(app),
              l.helpSamsungStep2(app),
              l.helpSamsungStep3(app),
            ]),
          ),
          const SizedBox(height: Space.l),
          Text(l.helpPathsVary, style: muted),
        ],
      ),
    );
  }
}
