import '../../core/time/civil_date.dart';

/// What the Sources & verification screen says about an installed pack (spec §11.16,
/// FR-SET-02): which data, which tradition, which version, which dates, and how far
/// it has been checked.
class PackDetail {
  const PackDetail({
    required this.id,
    required this.kind,
    required this.tradition,
    required this.version,
    required this.from,
    required this.to,
    required this.isSample,
    this.validatedOn,
  });

  /// Without the version suffix (the manifest's `id`).
  final String id;

  /// 'global', 'cities' or 'observances'.
  final String kind;
  final String tradition;
  final int version;
  final CivilDate from;
  final CivilDate to;
  final bool isSample;

  /// The day the pack was last checked against the references, from
  /// `validation_summary.validated_on`. Null until a validation has run (T-503).
  final CivilDate? validatedOn;
}
