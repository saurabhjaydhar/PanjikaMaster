/// Maps a karana transition index k (0–59) to its `names(kind='karana')` row (spec §6.5.4):
/// k = 0 → Kimstughna (10); 57–59 → Shakuni, Chatushpada, Naga (7–9); otherwise the
/// movable karanas Bava…Vishti (0–6) repeating from k = 1.
int karanaNameIndex(int k) {
  if (k < 0 || k > 59) throw RangeError.range(k, 0, 59, 'k');
  if (k == 0) return 10;
  if (k >= 57) return k - 50;
  return (k - 1) % 7;
}
