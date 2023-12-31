import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:number_trivia/core/error/exceptions.dart';
import '../models/number_trivia_model.dart';

abstract class NumberTriviaRemoteDataSource {
  /// Calls the https://numbersapi.com/{number} endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);

  /// Calls the https://numbersapi.com/random endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  const NumberTriviaRemoteDataSourceImpl({required this.client});

  final http.Client client;

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async {
    return _getNumberTrivia('http://numbersapi.com/$number');
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() async {
    return _getNumberTrivia('http://numbersapi.com/random');
  }

  Future<NumberTriviaModel> _getNumberTrivia(String url) async {
    final response = await client.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 200) {
      throw ServerException();
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    return NumberTriviaModel.fromJson(json);
  }
}
