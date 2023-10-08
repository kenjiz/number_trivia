import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tNumberTriviaModel = NumberTriviaModel(
    number: 1,
    text: 'Test Trivia',
  );

  test('should be a subclass of [NumberTrivia] entity', () {
    expect(tNumberTriviaModel, isA<NumberTrivia>());
  });

  group('fromJson', () {
    test(
      'should return a valid model when the JSON number is an integer',
      () async {
        // Arrange
        final Map<String, dynamic> jsonMap = jsonDecode(fixture('trivia.json'));
        // Act
        final result = NumberTriviaModel.fromJson(jsonMap);
        // Assert
        expect(result, equals(tNumberTriviaModel));
      },
    );
    test(
      'should return a valid model when the JSON number is regarded as double',
      () async {
        // Arrange
        final Map<String, dynamic> jsonMap =
            jsonDecode(fixture('trivia_double.json'));
        // Act
        final result = NumberTriviaModel.fromJson(jsonMap);
        // Assert
        expect(result, equals(tNumberTriviaModel));
      },
    );
  });

  group('toJson', () {
    test('should return a JSON Map containing the proper data.', () {
      final result = tNumberTriviaModel.toJson();
      final expectedMap = {
        "text": "Test Trivia",
        "number": 1,
      };

      expect(result, equals(expectedMap));
    });
  });
}
