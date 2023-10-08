import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:number_trivia/core/error/failures.dart';

import '../../../../core/utils/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String kServerFailureMessage = 'Server Failure';
const String kCacheFailureMessage = 'Cache Failure';
const String kInvalidInputMessage =
    'Invalid input-the number should be positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required GetConcreteNumberTrivia concrete,
    required GetRandomNumberTrivia random,
    required this.inputConverter,
  })  : getConcreteNumberTrivia = concrete,
        getRandomNumberTrivia = random,
        super(EmptyNumberTrivia()) {
    on<NumberTriviaGetConcretePressed>(_onGetConcretePressedEvent);
    on<NumberTriviaGetRandomPressed>(_onGetRandomPresedEvent);
  }

  void _onGetConcretePressedEvent(
    NumberTriviaGetConcretePressed event,
    Emitter<NumberTriviaState> emit,
  ) async {
    emit(const NumberTriviaIsLoading());
    final parsedInt =
        inputConverter.stringToUnsignedInteger(event.numberString);

    await parsedInt.fold(
      (_) async {
        emit(const NumberTriviaError(message: kInvalidInputMessage));
      },
      (number) async {
        final result = await getConcreteNumberTrivia(Params(number: number));

        result.fold(
          (Failure failure) {
            switch (failure) {
              case CacheFailure():
                emit(const NumberTriviaError(message: kCacheFailureMessage));
                break;
              case ServerFailure():
                emit(const NumberTriviaError(message: kServerFailureMessage));
                break;
            }
          },
          (NumberTrivia numberTrivia) {
            emit(NumberTriviaLoaded(numberTrivia: numberTrivia));
          },
        );
      },
    );
  }

  void _onGetRandomPresedEvent(
    NumberTriviaGetRandomPressed event,
    Emitter<NumberTriviaState> emit,
  ) async {
    emit(const NumberTriviaIsLoading());
    final result = await getRandomNumberTrivia();

    result.fold(
      (Failure failure) {
        switch (failure) {
          case CacheFailure():
            emit(const NumberTriviaError(message: kCacheFailureMessage));
            break;
          case ServerFailure():
            emit(const NumberTriviaError(message: kServerFailureMessage));
            break;
        }
      },
      (NumberTrivia numberTrivia) {
        emit(NumberTriviaLoaded(numberTrivia: numberTrivia));
      },
    );
  }
}
