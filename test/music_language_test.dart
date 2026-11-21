import 'package:flutter_test/flutter_test.dart';
import 'package:anahad/models/music_language.dart';

void main() {
  group('ANAHAD Music Language Model Tests', () {
    test('Supported languages include all user-requested regional languages', () {
      final languages = MusicLanguage.supportedLanguages;

      // English, Hindi, Marathi, Gujarati, Rajasthani specifically requested
      final ids = languages.map((l) => l.id).toSet();
      expect(ids.contains('hindi'), isTrue);
      expect(ids.contains('english'), isTrue);
      expect(ids.contains('marathi'), isTrue);
      expect(ids.contains('gujarati'), isTrue);
      expect(ids.contains('rajasthani'), isTrue);
      expect(ids.contains('punjabi'), isTrue);
    });

    test('Each language has native script, valid gradients, and search queries', () {
      for (final lang in MusicLanguage.supportedLanguages) {
        expect(lang.name.isNotEmpty, isTrue);
        expect(lang.nativeName.isNotEmpty, isTrue);
        expect(lang.searchQuery.isNotEmpty, isTrue);
        expect(lang.albumQuery.isNotEmpty, isTrue);
        expect(lang.gradient.length, greaterThanOrEqualTo(2));
        expect(lang.subgenres.isNotEmpty, isTrue);
      }
    });

    test('Gujarati and Rajasthani contain regional subgenres', () {
      final gujarati = MusicLanguage.supportedLanguages.firstWhere((l) => l.id == 'gujarati');
      expect(gujarati.nativeName, equals('ગુજરાતી'));
      expect(gujarati.subgenres.contains('Navratri Garba'), isTrue);

      final rajasthani = MusicLanguage.supportedLanguages.firstWhere((l) => l.id == 'rajasthani');
      expect(rajasthani.nativeName, equals('राजस्थानी'));
      expect(rajasthani.subgenres.contains('Marwadi Folk'), isTrue);

      final marathi = MusicLanguage.supportedLanguages.firstWhere((l) => l.id == 'marathi');
      expect(marathi.nativeName, equals('मराठी'));
      expect(marathi.subgenres.contains('Lavani & Folk'), isTrue);
    });
  });
}
