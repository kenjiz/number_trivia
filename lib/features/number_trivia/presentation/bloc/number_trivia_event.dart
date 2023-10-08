part of 'number_trivia_bloc.dart';

sealed class NumberTriviaEvent extends Equatable {
  const NumberTriviaEvent();
  @override
  List<Object?> get props => [];
}

class NumberTriviaGetConcretePressed extends NumberTriviaEvent {
  const NumberTriviaGetConcretePressed({required this.numberString});
  final String numberString;

  @override
  List<Object?> get props => [numberString];
}

class NumberTriviaGetRandomPressed extends NumberTriviaEvent {
  const NumberTriviaGetRandomPressed();
}
