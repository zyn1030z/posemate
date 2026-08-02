import 'package:flutter_test/flutter_test.dart';
import 'package:posely_ai/core/shared/utils/validators.dart';

void main() {
  group('Validators.email', () {
    const cases = <(String?, bool)>[
      (null, false),
      ('', false),
      ('   ', false),
      ('plainaddress', false),
      ('missing@tld', false),
      ('@example.com', false),
      ('user name@example.com', false),
      ('user@example.com.', false),
      ('a@b.co', true),
      ('user.name+tag@example.com', true),
      ('USER@EXAMPLE.COM', true),
      ('  padded@example.com  ', true),
    ];
    for (final (input, isValid) in cases) {
      test('"$input" is ${isValid ? 'valid' : 'invalid'}', () {
        expect(Validators.email(input), isValid ? isNull : isNotNull);
      });
    }
  });

  group('Validators.password', () {
    const cases = <(String?, bool)>[
      (null, false),
      ('', false),
      ('abc1234', false), // too short
      ('abcdefgh', false), // no digit
      ('12345678', false), // no letter
      ('abcd1234', true),
      ('P@ssw0rd!', true),
      ('longpassword9', true),
    ];
    for (final (input, isValid) in cases) {
      test('"$input" is ${isValid ? 'valid' : 'invalid'}', () {
        expect(Validators.password(input), isValid ? isNull : isNotNull);
      });
    }
  });

  group('Validators.required', () {
    const cases = <(String?, bool)>[
      (null, false),
      ('', false),
      ('   ', false),
      ('x', true),
      ('  x  ', true),
    ];
    for (final (input, isValid) in cases) {
      test('"$input" is ${isValid ? 'valid' : 'invalid'}', () {
        expect(Validators.required(input), isValid ? isNull : isNotNull);
      });
    }

    test('uses the field name in the message', () {
      expect(Validators.required(null, field: 'Name'), 'Name is required');
    });
  });

  group('Validators.confirmPassword', () {
    const original = 'abcd1234';
    const cases = <(String?, bool)>[
      (null, false),
      ('', false),
      ('abcd123', false), // mismatch
      ('ABCD1234', false), // case-sensitive mismatch
      ('abcd1234', true),
    ];
    for (final (input, isValid) in cases) {
      test('"$input" vs "$original" is ${isValid ? 'valid' : 'invalid'}', () {
        expect(
          Validators.confirmPassword(input, original),
          isValid ? isNull : isNotNull,
        );
      });
    }
  });
}
