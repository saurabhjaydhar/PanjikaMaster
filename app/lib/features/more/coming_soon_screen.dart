import 'package:flutter/material.dart';

import '../../app/widgets/panjika_widgets.dart';
import '../../l10n/gen/app_localizations.dart';

/// A More destination whose screen arrives in a later task (see docs/phases/). It has
/// its own title and Back, so the menu is complete and every entry is reachable.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: StateMessage(
      message: AppLocalizations.of(context).comingSoon,
      kind: StateKind.comingSoon,
    ),
  );
}
