import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences sharedPreferences;

  setUp(() {
    sharedPreferences = MockSharedPreferences();
    dataSource =
        NumberTriviaLocalDataSourceImpl(sharedPreferences: sharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia_cache.json')));

    test('should return [NumberTrivia] when there\'s one in the cache',
        () async {
      // arrange
      when(() => sharedPreferences.getString(any())).thenReturn(
        fixture('trivia_cache.json'),
      );

      // act
      final result = await dataSource.getLastNumberTrivia();

      // assert
      verify(() => sharedPreferences.getString('CACHED_NUMBER_TRIVIA'))
          .called(1);
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw [CacheException] when there\'s no cache value',
        () async {
      // arrange
      when(() => sharedPreferences.getString(any())).thenReturn(null);

      // act
      final call = dataSource.getLastNumberTrivia;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });
  group('cacheNumberTrivia', () {
    const tNumberTriviaModel = NumberTriviaModel(
      number: 1,
      text: 'Test Trivia',
    );

    test('should call [SharedPreferences] to cache the data', () async {
      // Arrange
      when(() => sharedPreferences.setString(any(), any()))
          .thenAnswer((_) => Future.value(true));
      // Act
      dataSource.cacheNumberTrivia(tNumberTriviaModel);
      final expectedJsonString = jsonEncode(tNumberTriviaModel.toJson());

      // Assert
      verify(() => sharedPreferences.setString(
          'CACHED_NUMBER_TRIVIA', expectedJsonString)).called(1);
    });
  });
}
