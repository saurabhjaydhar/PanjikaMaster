import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/tokens.dart';
import '../../core/l10n/app_language.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../l10n/gen/app_localizations.dart';
import 'share_render.dart';

/// The share sheet (spec §11.8): বাংলা / English / দুই ভাষায় · Both, defaulting to the UI
/// language, a preview of the card, and Share. The card and message follow the
/// choice; the image is rendered from the preview itself.
Future<void> showShareSheet(
  BuildContext context, {
  required Widget Function(ShareLanguage share) card,
  required String Function(ShareLanguage share) message,
  required String fileName,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => _ShareSheet(card: card, message: message, fileName: fileName),
);

class _ShareSheet extends ConsumerStatefulWidget {
  const _ShareSheet({
    required this.card,
    required this.message,
    required this.fileName,
  });

  final Widget Function(ShareLanguage share) card;
  final String Function(ShareLanguage share) message;
  final String fileName;

  @override
  ConsumerState<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends ConsumerState<_ShareSheet> {
  final _card = GlobalKey();
  late ShareLanguage _share = ShareLanguage.of(ref.read(appLanguageProvider));
  bool _busy = false;

  Future<void> _send() async {
    setState(() => _busy = true);
    try {
      final png = await renderSharePng(_card);
      await ref
          .read(sharerProvider)
          .shareImage(
            png,
            text: widget.message(_share),
            fileName: widget.fileName,
          );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final bn = lookupAppLocalizations(AppLanguage.bn.locale);
    final en = lookupAppLocalizations(AppLanguage.en.locale);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Space.xl, 0, Space.xl, Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.shareSheetTitle, style: t.titleLarge),
            const SizedBox(height: Space.m),
            SegmentedButton<ShareLanguage>(
              showSelectedIcon: false,
              segments: [
                // Each option in its own script (spec §11.8).
                ButtonSegment(
                  value: ShareLanguage.bn,
                  label: Text(
                    AppLanguage.bn.endonym,
                    locale: AppLanguage.bn.locale,
                  ),
                ),
                ButtonSegment(
                  value: ShareLanguage.en,
                  label: Text(
                    AppLanguage.en.endonym,
                    locale: AppLanguage.en.locale,
                  ),
                ),
                ButtonSegment(
                  value: ShareLanguage.both,
                  label: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: bn.shareInBoth,
                          locale: AppLanguage.bn.locale,
                        ),
                        TextSpan(
                          text: bn.bothLanguages('', ''), // " · "
                        ),
                        TextSpan(
                          text: en.shareInBoth,
                          locale: AppLanguage.en.locale,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              selected: {_share},
              onSelectionChanged: (s) => setState(() => _share = s.single),
            ),
            const SizedBox(height: Space.l),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: AspectRatio(
                  aspectRatio: shareCardSize.aspectRatio,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: FittedBox(
                      child: ShareCardFrame(
                        language: _share.primary,
                        boundaryKey: _card,
                        child: widget.card(_share),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Space.l),
            FilledButton.icon(
              onPressed: _busy ? null : _send,
              icon: _busy
                  ? const SizedBox.square(
                      dimension: Space.l,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.share),
              label: Text(l.shareAction),
            ),
          ],
        ),
      ),
    );
  }
}
