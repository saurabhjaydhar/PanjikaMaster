import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/shell/not_found_screen.dart';
import '../../app/widgets/name_text.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/entities/panjika.dart';
import '../../l10n/gen/app_localizations.dart';

final _observanceProvider = FutureProvider.family<Observance?, String>(
  (ref, id) => ref.watch(panjikaRepositoryProvider).observance(id),
);

/// Where `/festival/<id>` links land (T-411). The festival detail itself comes with
/// TODO(T-511); until then this names the festival and says "coming soon".
class FestivalLinkScreen extends ConsumerWidget {
  const FestivalLinkScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return switch (ref.watch(_observanceProvider(id))) {
      AsyncValue(value: final o?) => Scaffold(
        appBar: AppBar(title: NameText(o.name)),
        body: StateMessage(message: l.comingSoon, kind: StateKind.comingSoon),
      ),
      AsyncValue(isLoading: true) => const Scaffold(body: SizedBox.expand()),
      _ => NotFoundScreen(message: l.festivalNotFound),
    };
  }
}
