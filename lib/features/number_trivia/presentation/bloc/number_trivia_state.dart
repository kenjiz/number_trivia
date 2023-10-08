part of 'number_trivia_bloc.dart';

sealed class NumberTriviaState extends Equatable {
  const NumberTriviaState();

  @override
  List<Object> get props => [];
}

final class EmptyNumberTrivia extends NumberTriviaState {}

final class NumberTriviaIsLoading extends NumberTriviaState {
  const NumberTriviaIsLoading();
}

final class NumberTriviaLoaded extends NumberTriviaState {
  final NumberTrivia numberTrivia;
  const NumberTriviaLoaded({required this.numberTrivia});

  @override
  List<Object> get props => [numberTrivia];
}

final class NumberTriviaError extends NumberTriviaState {
  final String message;
  const NumberTriviaError({required this.message});

  @override
  List<Object> get props => [message];
}
