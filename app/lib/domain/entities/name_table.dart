import 'name_ref.dart';

/// Every display name from the packs' `names` table (spec §13.1), by kind and index.
class NameTable {
  NameTable(
    Map<String, List<NameRef>> byKind,
    Map<String, NameRef> traditions, {
    Map<(String, int), NameRef> glosses = const {},
  }) : _byKind = {
         for (final MapEntry(:key, :value) in byKind.entries)
           key: List.unmodifiable(value),
       },
       _traditions = Map.unmodifiable(traditions),
       _glosses = Map.unmodifiable(glosses);

  final Map<String, List<NameRef>> _byKind;
  final Map<String, NameRef> _traditions;
  final Map<(String, int), NameRef> _glosses;

  /// The name of [idx] (0-based) of [kind]. A valid pack has every row (FR-L10N-09),
  /// so a gap means the installed packs are broken.
  NameRef of(String kind, int idx) {
    final list = _byKind[kind];
    if (list == null || idx < 0 || idx >= list.length) {
      throw StateError('names($kind, $idx) missing from the installed packs');
    }
    return list[idx];
  }

  /// How many names [kind] has, e.g. 30 tithis.
  int countOf(String kind) => _byKind[kind]?.length ?? 0;

  /// The display name of a tradition id such as `drik_bishuddha`; the id itself if
  /// the packs don't name it.
  NameRef tradition(String id) => _traditions[id] ?? NameRef(id, id);

  /// The plain-language explanation for the glossary (FR-SET-07), if the pack has one.
  NameRef? glossOf(String kind, int idx) => _glosses[(kind, idx)];
}
