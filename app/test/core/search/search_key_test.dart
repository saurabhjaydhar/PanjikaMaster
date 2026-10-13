// T-405: search normalisation (spec §13.6).
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/search/search_key.dart';

void main() {
  test('case, spaces, hyphens and punctuation do not matter', () {
    expect(searchKey('Purva Bhadrapada'), searchKey('purva-bhadrapada'));
    expect(searchKey('Kali  Puja'), 'kalipuja');
  });

  test('Latin diacritics fold to plain letters', () {
    expect(searchKey('Durgā'), 'durga');
    expect(searchKey('Śukla Saptamī'), 'suklasaptami');
  });

  test('Bengali and Latin digits match', () {
    expect(searchKey('২৫ আশ্বিন'), searchKey('25আশ্বিন'));
  });

  test('composed and decomposed য় ড় ঢ় meet', () {
    expect(searchKey('হাওড়া'), searchKey('হাওড়া'));
    expect(searchKey('য়'), 'য়');
  });

  test('Bengali spacing variants (কালীপূজা / কালী পূজা)', () {
    expect(searchKey('কালী পূজা'), searchKey('কালীপূজা'));
  });
}
