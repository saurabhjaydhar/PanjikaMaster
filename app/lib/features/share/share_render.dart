import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme/app_theme.dart';
import '../../core/l10n/app_language.dart';

/// Share cards are 1080 × 1350 px (spec §11.8), whatever the screen or text size.
const shareCardSize = Size(1080, 1350);

/// Which language a share card and its message use (spec §11.8): Bengali, English,
/// or both (the Bengali name as the hero with the English below).
enum ShareLanguage {
  bn,
  en,
  both;

  /// The language of the card's main text.
  AppLanguage get primary => this == en ? AppLanguage.en : AppLanguage.bn;

  static ShareLanguage of(AppLanguage ui) =>
      ui == AppLanguage.en ? ShareLanguage.en : ShareLanguage.bn;
}

/// Where share links point. Empty until the share domain exists, and then the
/// message carries no link. TODO(T-304)
const shareBaseUrl = String.fromEnvironment('PANJIKA_SHARE_BASE_URL');

/// The link for an in-app [path] (e.g. `/festival/kali_puja?date=…`), or null.
String? shareLink(String path, {String base = shareBaseUrl}) =>
    base.isEmpty ? null : '${base.replaceAll(RegExp(r'/+$'), '')}$path';

/// Lays a card out at its fixed size: no text scaling and the light theme in the
/// card's language, so every phone produces the same image.
class ShareCardFrame extends StatelessWidget {
  const ShareCardFrame({
    super.key,
    required this.language,
    required this.child,
    this.boundaryKey,
  });

  final AppLanguage language;
  final Widget child;

  /// Put on the [RepaintBoundary] that [renderSharePng] reads.
  final GlobalKey? boundaryKey;

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      size: shareCardSize,
      textScaler: TextScaler.noScaling,
      disableAnimations: true,
    ),
    child: Theme(
      data: buildPanjikaTheme(Brightness.light, language),
      child: Localizations.override(
        context: context,
        locale: language.locale,
        child: RepaintBoundary(
          key: boundaryKey,
          child: SizedBox.fromSize(
            size: shareCardSize,
            child: Material(child: child),
          ),
        ),
      ),
    ),
  );
}

/// The card under [boundaryKey] as PNG bytes, 1080 × 1350.
Future<Uint8List> renderSharePng(GlobalKey boundaryKey) async {
  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage();
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}

/// Hands an image and its message to the system share sheet.
abstract interface class Sharer {
  Future<void> shareImage(
    Uint8List png, {
    required String text,
    required String fileName,
  });
}

final sharerProvider = Provider<Sharer>((ref) => const PlatformSharer());

class PlatformSharer implements Sharer {
  const PlatformSharer();

  @override
  Future<void> shareImage(
    Uint8List png, {
    required String text,
    required String fileName,
  }) => SharePlus.instance.share(
    ShareParams(
      text: text,
      files: [XFile.fromData(png, mimeType: 'image/png', name: fileName)],
    ),
  );
}
