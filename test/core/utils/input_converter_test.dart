import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/core/utils/input_converter.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });
  group('stringToUnsignedInt', () {
    test(
        'should return an integer when the string represents an unsigned integer',
        () async {
      // Arrange
      const str = '123';

      // Act
      final result = inputConverter.stringToUnsignedInteger(str);

      // Assert
      expect(result, equals(const Right(123)));
    });

    test('should return a [Failure] when the string is not an integer',
        () async {
      // Arrange
      const str = 'aaa';

      // Act
      final result = inputConverter.stringToUnsignedInteger(str);

      // Assert
      expect(result, equals(Left(InvalidInputFailure())));
    });

    test('should return a [Failure] when the string is a negative integer',
        () async {
      // Arrange
      const str = '-123';

      // Act
      final result = inputConverter.stringToUnsignedInteger(str);

      // Assert
      expect(result, equals(Left(InvalidInputFailure())));
    });
  });
}
