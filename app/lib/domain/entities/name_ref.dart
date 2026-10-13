import '../../core/l10n/app_language.dart';

/// A name in both scripts, from the pack's `names` table (spec §13.1). The UI picks the
/// primary line by language and, with "names in both scripts", shows [other] below.
class NameRef {
  const NameRef(this.bn, this.en);

  final String bn;
  final String en;

  String of(AppLanguage language) => language == AppLanguage.bn ? bn : en;

  /// The other script, for the second line (spec §13.4).
  String other(AppLanguage language) => language == AppLanguage.bn ? en : bn;

  @override
  bool operator ==(Object other) =>
      other is NameRef && other.bn == bn && other.en == en;

  @override
  int get hashCode => Object.hash(bn, en);

  @override
  String toString() => '$bn / $en';
}
