import 'package:dartz/dartz.dart';

import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';

import '../entities/number_trivia.dart';

class GetRandomNumberTrivia implements UseCase<NumberTrivia> {
  const GetRandomNumberTrivia({
    required this.repository,
  });

  final NumberTriviaRepository repository;

  @override
  Future<Either<Failure, NumberTrivia>> call() async {
    return await repository.getRandomNumberTrivia();
  }
}
