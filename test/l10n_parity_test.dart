import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Placeholder names (`{name}`) used by a message, sorted.
List<String> _placeholders(String message) => RegExp(r'\{(\w+)\}')
    .allMatches(message)
    .map((m) => m.group(1)!)
    .toSet()
    .toList()
  ..sort();

Map<String, String> _messages(String locale) {
  final json = jsonDecode(File('lib/l10n/$locale.arb').readAsStringSync())
      as Map<String, dynamic>;
  return {
    for (final e in json.entries)
      if (!e.key.startsWith('@')) e.key: e.value as String,
  };
}

void main() {
  final en = _messages('en');

  for (final locale in ['fr', 'ar']) {
    group('$locale.arb', () {
      final other = _messages(locale);

      test('has exactly the keys of en.arb', () {
        expect(other.keys.toSet().difference(en.keys.toSet()), isEmpty,
            reason: 'keys missing from en.arb');
        expect(en.keys.toSet().difference(other.keys.toSet()), isEmpty,
            reason: 'keys missing from $locale.arb');
      });

      test('uses the same placeholders as en.arb for every key', () {
        for (final key in en.keys.where(other.containsKey)) {
          expect(_placeholders(other[key]!), _placeholders(en[key]!),
              reason: '$locale.arb "$key"');
        }
      });
    });
  }
}
