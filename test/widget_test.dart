import 'package:flutter_test/flutter_test.dart';
import 'package:study_materials_catalog/core/auth/validators.dart';

void main() {
  test('email validator', () {
    expect(Validators.email(''), isNotNull);
    expect(Validators.email('abc'), isNotNull);
    expect(Validators.email('a@b.ua'), isNull);
  });

  test('password validator', () {
    expect(Validators.password('short1'), isNotNull);
    expect(Validators.password('onlyletters'), isNotNull);
    expect(Validators.password('abcdefg1'), isNull);
  });

  test('confirm validator', () {
    expect(Validators.confirm(() => 'a')('b'), isNotNull);
    expect(Validators.confirm(() => 'a')('a'), isNull);
  });
}
