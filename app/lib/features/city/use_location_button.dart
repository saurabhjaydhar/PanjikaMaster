import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../data/location/platform_location_service.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/location/location.dart';
import '../../l10n/gen/app_localizations.dart';

/// "Use my location" (FR-LOC-02..04): a rationale before the first system prompt,
/// one coarse fix, the nearest supported city with its distance and a warning past
/// 50 km. A denial or failure only says so: choosing from the list always works.
class UseLocationButton extends ConsumerStatefulWidget {
  const UseLocationButton({super.key, required this.onChosen});

  /// The user confirmed the nearest city.
  final ValueChanged<String> onChosen;

  @override
  ConsumerState<UseLocationButton> createState() => _UseLocationButtonState();
}

class _UseLocationButtonState extends ConsumerState<UseLocationButton> {
  bool _busy = false;

  Future<void> _run() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(locationServiceProvider);

    void tell(String message, {SnackBarAction? action}) => messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));

    final settingsAction = SnackBarAction(
      label: l.actionOpenSettings,
      onPressed: service.openAppSettings,
    );
    switch (await service.permission()) {
      case LocationPermission.deniedForever:
        tell(l.locationDeniedForever, action: settingsAction);
        return;
      case LocationPermission.notAsked || LocationPermission.denied:
        if (!mounted || !await _rationale(context)) return;
      case LocationPermission.granted:
        break;
    }

    setState(() => _busy = true);
    final result = await service.locate();
    final cities = result is Located
        ? await ref.read(panjikaRepositoryProvider).cities()
        : null;
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case Located(:final latitude, :final longitude):
        final nearest = nearestCity(cities!, latitude, longitude);
        if (nearest == null) {
          tell(l.locationUnavailable);
        } else if (await _confirm(context, nearest)) {
          widget.onChosen(nearest.city.id);
        }
      case LocationDenied(:final permanently):
        tell(
          permanently ? l.locationDeniedForever : l.locationDenied,
          action: permanently ? settingsAction : null,
        );
      case LocationServiceOff():
        tell(
          l.locationOff,
          action: SnackBarAction(
            label: l.actionTurnOn,
            onPressed: service.openLocationSettings,
          ),
        );
      case LocationUnavailable():
        tell(l.locationUnavailable);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(Space.minTouch),
        alignment: AlignmentDirectional.centerStart,
        // Room for a wrapped label at large text sizes.
        padding: const EdgeInsets.symmetric(
          horizontal: Space.l,
          vertical: Space.s,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.medium),
        ),
      ),
      onPressed: _busy ? null : _run,
      icon: _busy
          ? const SizedBox.square(
              dimension: Space.l,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.my_location),
      label: Text(_busy ? l.locating : l.useMyLocation),
    );
  }
}

/// Why the app asks, before Android's prompt (§19.1 L18).
Future<bool> _rationale(BuildContext context) async {
  final l = AppLocalizations.of(context);
  final ok = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => _Sheet(
      icon: Icons.my_location,
      lines: [
        Text(l.locationRationale, style: Theme.of(sheet).textTheme.bodyLarge),
      ],
      cancel: l.actionNotNow,
      confirm: l.actionContinue,
    ),
  );
  return ok ?? false;
}

/// The nearest city, its distance, and the far-away warning (FR-LOC-02, FR-LOC-03).
Future<bool> _confirm(BuildContext context, NearestCity nearest) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => Consumer(
      builder: (sheet, ref, _) {
        final l = AppLocalizations.of(sheet);
        final t = Theme.of(sheet).textTheme;
        final f = ref.watch(formatterProvider);
        final language = ref.watch(appLanguageProvider);
        return _Sheet(
          icon: Icons.location_city_outlined,
          lines: [
            Text(
              l.nearestCity(
                nearest.city.name.of(language),
                f.number(nearest.distanceKm.round()),
              ),
              style: t.titleMedium,
            ),
            if (nearest.isFar) ...[
              const SizedBox(height: Space.s),
              Text(
                l.cityFarWarning(f.number(farFromCityKm.round())),
                style: t.bodyMedium?.copyWith(color: sheet.colors.alta),
              ),
            ],
          ],
          cancel: l.actionNotNow,
          confirm: l.actionChooseCity,
        );
      },
    ),
  );
  return ok ?? false;
}

class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.icon,
    required this.lines,
    required this.cancel,
    required this.confirm,
  });

  final IconData icon;
  final List<Widget> lines;
  final String cancel;
  final String confirm;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(Space.xl, 0, Space.xl, Space.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(icon, color: context.colors.haldiStrong, size: Space.xxl),
          const SizedBox(height: Space.l),
          ...lines,
          const SizedBox(height: Space.xl),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: Space.s,
            runSpacing: Space.s,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirm),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
