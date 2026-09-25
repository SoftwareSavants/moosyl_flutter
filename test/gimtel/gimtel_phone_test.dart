import 'package:flutter_test/flutter_test.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_phone.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_models.dart';

void main() {
  group('normalizeGimtelPhone', () {
    for (final entry in {
      '36551929': '36551929',
      '+222 36 55 19 29': '36551929',
      '0022236551929': '36551929',
      '22236551929': '36551929',
      '36.55.19.29': '36551929',
    }.entries) {
      test('${entry.key} -> ${entry.value}', () {
        expect(normalizeGimtelPhone(entry.key), entry.value);
      });
    }
    for (final bad in [
      null,
      '',
      '1234567',
      '123456789',
      'abcdefgh',
      '2223655192'
    ]) {
      test('rejects $bad', () => expect(normalizeGimtelPhone(bad), isNull));
    }
  });

  test('groupPhonePairs', () {
    expect(groupPhonePairs('36551929'), '36 55 19 29');
    expect(groupPhonePairs('123'), '123');
  });

  test('gimtelStatusFrom treats unknown as pending', () {
    expect(gimtelStatusFrom('completed'), GimtelStatus.completed);
    expect(gimtelStatusFrom('expired'), GimtelStatus.expired);
    expect(gimtelStatusFrom('weird'), GimtelStatus.pending);
    expect(gimtelStatusFrom(null), GimtelStatus.pending);
  });
}
