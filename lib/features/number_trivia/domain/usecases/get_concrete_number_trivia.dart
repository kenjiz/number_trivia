import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';

import '../../../../core/error/failures.dart';
import '../entities/number_trivia.dart';

class GetConcreteNumberTrivia
    implements UseCaseWithParams<NumberTrivia, Params> {
  const GetConcreteNumberTrivia({
    required this.repository,
  });

  final NumberTriviaRepository repository;

  @override
  Future<Either<Failure, NumberTrivia>> call(Params params) async {
    return await repository.getConcreteNumberTrivia(params.number);
  }
}

class Params extends Equatable {
  final int number;

  const Params({
    required this.number,
  });

  @override
  List<Object> get props => [number];
}
