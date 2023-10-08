import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpResponse200() =>
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => http.Response(fixture('trivia.json'), 200),
      );

  void setUpMockHttpResponse500() =>
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Something went wrong', 500));

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://numbersapi.com/1'));
  });

  group('getConcreteNumberTrivia', () {
    const tTestNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));

    test('''
          should perform a GET request with number being an enpoint
          with application/json as a content-type header''', () async {
      // Arrange
      setUpMockHttpResponse200();

      // Act
      dataSource.getConcreteNumberTrivia(tTestNumber);

      // Assert
      verify(() => mockHttpClient
              .get(Uri.parse('http://numbersapi.com/$tTestNumber'), headers: {
            'Content-Type': 'application/json',
          })).called(1);
    });

    test('should return number trivia when the response code is 200', () async {
      // Arrange
      setUpMockHttpResponse200();

      // Act
      final result = await dataSource.getConcreteNumberTrivia(tTestNumber);

      // Assert
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw [ServerException] when the response code is not 200',
        () async {
      // Arrange
      setUpMockHttpResponse500();

      // Act
      final call = dataSource.getConcreteNumberTrivia;

      // Assert
      expect(() => call(tTestNumber), throwsA(isA<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));

    test('''
          should perform a GET request with number being an enpoint
          with application/json as a content-type header''', () async {
      // Arrange
      setUpMockHttpResponse200();

      // Act
      dataSource.getRandomNumberTrivia();

      // Assert
      verify(() => mockHttpClient
              .get(Uri.parse('http://numbersapi.com/random'), headers: {
            'Content-Type': 'application/json',
          })).called(1);
    });

    test('should return number trivia when the response code is 200', () async {
      // Arrange
      setUpMockHttpResponse200();

      // Act
      final result = await dataSource.getRandomNumberTrivia();

      // Assert
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw [ServerException] when the response code is not 200',
        () async {
      // Arrange
      setUpMockHttpResponse500();

      // Act
      final call = dataSource.getRandomNumberTrivia;

      // Assert
      expect(() => call(), throwsA(isA<ServerException>()));
    });
  });
}
