import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/search/search_key.dart';
import '../../core/settings/settings.dart';
import '../../core/time/civil_date.dart';
import '../../core/time/clock.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../data/repositories/panjika_repository.dart';
import '../../domain/entities/panjika.dart';
import '../../domain/search/search_query.dart';

/// One search hit (spec §11.14).
sealed class SearchResult {
  const SearchResult();
}

/// A date: its civil date, and its Bengali date when the packs have it. A Bengali
/// date the packs don't cover has no civil date ([date] null): the app never guesses
/// one (CLAUDE.md, spec §11.9).
final class DateResult extends SearchResult {
  const DateResult({required this.date, required this.bengaliDate, this.asked});

  final CivilDate? date;
  final BengaliDate? bengaliDate;

  /// The Bengali date asked for, when [date] is unknown.
  final BengaliDay? asked;
}

/// An observance on a date (each installed occurrence).
final class FestivalResult extends SearchResult {
  const FestivalResult(this.observance);
  final ObservanceDate observance;
}

/// The hits for a query, and whether any of them comes from a sample pack (then the
/// screen shows the watermark, CLAUDE.md).
class SearchResults {
  const SearchResults(this.items, {required this.isSample});

  final List<SearchResult> items;
  final bool isSample;

  bool get isEmpty => items.isEmpty;
}

final searchServiceProvider = Provider<SearchService>(
  (ref) => SearchService(
    ref.watch(panjikaRepositoryProvider),
    tradition: ref.watch(traditionProvider),
    today: () => CivilDate.ofInstant(ref.read(nowProvider)),
  ),
);

/// Search over the installed packs (FR-SRCH-01, §13.6): dates in either calendar and
/// script, and festival names with spelling variants. The festival index is built
/// once per service.
class SearchService {
  SearchService(this._repo, {required this.tradition, required this.today});

  final DriftPanjikaRepository _repo;
  final String tradition;
  final CivilDate Function() today;
  List<({ObservanceDate o, List<String> keys})>? _index;

  Future<SearchResults> search(String input) async {
    final query = input.trim();
    if (query.isEmpty) return const SearchResults([], isSample: false);
    final names = await _repo.names();
    final out = <SearchResult>[];
    for (final q in parseDateQueries(query, names)) {
      out.addAll(await _resolve(q));
    }
    out.addAll(await _festivals(query));
    final packs = {
      for (final r in out)
        ...switch (r) {
          DateResult(:final bengaliDate?) => [bengaliDate.packId],
          FestivalResult(:final observance) => [observance.packId],
          _ => const <String>[],
        },
    };
    return SearchResults(out, isSample: await _repo.anySample(packs));
  }

  Future<List<SearchResult>> _resolve(DateQuery q) async {
    switch (q) {
      case GregorianDate(:final date):
        return [
          DateResult(
            date: date,
            bengaliDate: await _repo.bengaliDate(tradition, date),
          ),
        ];
      case GregorianDayMonth(:final day, :final month):
        final now = today();
        CivilDate? on(int year) =>
            CivilDate.tryParse('$year-${_two(month)}-${_two(day)}');
        final date = switch (on(now.year)) {
          final d? when d.compareTo(now) >= 0 => d,
          _ => on(now.year + 1),
        };
        if (date == null) return const [];
        return [
          DateResult(
            date: date,
            bengaliDate: await _repo.bengaliDate(tradition, date),
          ),
        ];
      case BengaliDay(:final day, :final monthIdx, :final year):
        final found = await _repo.bengaliDatesOf(tradition, monthIdx, day);
        final matches = [
          for (final MapEntry(key: date, value: bn) in found.entries)
            if (year == null || bn.year == year) (date, bn),
        ];
        if (matches.isEmpty) {
          return [DateResult(date: null, bengaliDate: null, asked: q)];
        }
        // Without a year: the next one from today, else the latest installed.
        final now = today();
        final pick = year != null
            ? matches.first
            : matches.firstWhere(
                (m) => m.$1.compareTo(now) >= 0,
                orElse: () => matches.last,
              );
        return [DateResult(date: pick.$1, bengaliDate: pick.$2)];
    }
  }

  Future<List<SearchResult>> _festivals(String query) async {
    final key = searchKey(query);
    if (key.length < 2) return const [];
    final index = _index ??= [
      for (final o in await _repo.observanceStarts(tradition))
        (
          o: o,
          keys: [
            searchKey(o.observance.name.bn),
            searchKey(o.observance.name.en),
          ],
        ),
    ];
    final hits = [
      for (final e in index)
        if (e.keys.any((k) => k.contains(key))) e.o,
    ];
    // Upcoming first, then past ones, latest first.
    final now = today();
    final upcoming = [
      for (final o in hits)
        if (o.date.compareTo(now) >= 0) o,
    ];
    final past = [
      for (final o in hits.reversed)
        if (o.date.compareTo(now) < 0) o,
    ];
    return [
      for (final o in [...upcoming, ...past]) FestivalResult(o),
    ];
  }
}

String _two(int n) => n.toString().padLeft(2, '0');
