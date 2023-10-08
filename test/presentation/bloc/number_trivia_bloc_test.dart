import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/utils/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

class MockNumberTriviaBloc
    extends MockBloc<NumberTriviaEvent, NumberTriviaState>
    implements NumberTriviaBloc {}

void main() {
  late MockGetConcreteNumberTrivia getConcreteNumberTrivia;
  late MockGetRandomNumberTrivia getRandomNumberTrivia;
  late MockInputConverter inputConverter;
  late NumberTriviaBloc bloc;

  setUp(() {
    getConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    getRandomNumberTrivia = MockGetRandomNumberTrivia();
    inputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      concrete: getConcreteNumberTrivia,
      random: getRandomNumberTrivia,
      inputConverter: inputConverter,
    );
  });

  group('NumberTriviaBloc', () {
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    test('initial state should be [EmptyNumberTrivia]', () async {
      // Assert
      expect(bloc.state, equals(EmptyNumberTrivia()));
    });

    group('_onGetConcretePressedEvent', () {
      const tNumberString = '1';
      const tNumberParsed = 1;

      setUpAll(() {
        registerFallbackValue(const Params(number: tNumberParsed));
      });

      void setUpMockInputConverterSuccess() =>
          when(() => inputConverter.stringToUnsignedInteger(any()))
              .thenReturn(const Right(tNumberParsed));

      void setUpMockInputConverterFailed() =>
          when(() => inputConverter.stringToUnsignedInteger(any()))
              .thenReturn(Left(InvalidInputFailure()));

      void setUpMockGetConcreteUseCaseSuccess() =>
          when(() => getConcreteNumberTrivia(any())).thenAnswer(
            (_) async => const Right(tNumberTrivia),
          );

      void setUpMockGetConcreteUseCaseServerFailed() =>
          when(() => getConcreteNumberTrivia(any())).thenAnswer(
            (_) async => Left(ServerFailure()),
          );

      void setUpMockGetConcreteUseCaseCacheFailed() =>
          when(() => getConcreteNumberTrivia(any())).thenAnswer(
            (_) async => Left(CacheFailure()),
          );

      blocTest('''should call the [InputConverter] to validate
        and convert the string to unsigned integer''',
          setUp: () {
            setUpMockInputConverterSuccess();
            setUpMockGetConcreteUseCaseSuccess();
          },
          build: () => bloc,
          act: (bloc) => bloc.add(
                const NumberTriviaGetConcretePressed(
                    numberString: tNumberString),
              ),
          verify: (_) {
            verify(() => inputConverter.stringToUnsignedInteger(tNumberString))
                .called(1);
          });

      blocTest(
        'should emit [NumberTriviaError] with right message when input is invalid',
        setUp: () {
          setUpMockInputConverterFailed();
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
            const NumberTriviaGetConcretePressed(numberString: tNumberString)),
        expect: () => const [
          NumberTriviaIsLoading(),
          NumberTriviaError(message: kInvalidInputMessage),
        ],
      );

      blocTest(
        'should emit [NumberTriviaLoading] first when event is being called',
        setUp: () {
          setUpMockInputConverterSuccess();
          setUpMockGetConcreteUseCaseSuccess();
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          const NumberTriviaGetConcretePressed(
            numberString: tNumberString,
          ),
        ),
        expect: () => const [
          NumberTriviaIsLoading(),
          NumberTriviaLoaded(numberTrivia: tNumberTrivia),
        ],
      );

      blocTest(
        'should emit [NumberTriviaLoading] and [NumberTriviaLoaded] with right data when successfull.',
        setUp: () {
          setUpMockInputConverterSuccess();

          setUpMockGetConcreteUseCaseSuccess();
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          const NumberTriviaGetConcretePressed(numberString: tNumberString),
        ),
        expect: () => const [
          NumberTriviaIsLoading(),
          NumberTriviaLoaded(numberTrivia: tNumberTrivia),
        ],
        verify: (_) {
          verify(() =>
                  getConcreteNumberTrivia(const Params(number: tNumberParsed)))
              .called(1);
        },
      );

      blocTest(
        'should emit [NumberTriviaLoading] and [NumberTriviaError] with right message when server fails',
        setUp: () {
          setUpMockInputConverterSuccess();
          setUpMockGetConcreteUseCaseServerFailed();
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          const NumberTriviaGetConcretePressed(numberString: tNumberString),
        ),
        expect: () => const [
          NumberTriviaIsLoading(),
          NumberTriviaError(message: kServerFailureMessage),
        ],
        verify: (_) {
          verify(() =>
                  getConcreteNumberTrivia(const Params(number: tNumberParsed)))
              .called(1);
        },
      );

      blocTest(
          'should emit [NumberTriviaLoading] and [NumberTriviaError] with right message when cache fails',
          setUp: () {
            setUpMockInputConverterSuccess();
            setUpMockGetConcreteUseCaseCacheFailed();
          },
          build: () => bloc,
          act: (bloc) => bloc.add(
                const NumberTriviaGetConcretePressed(
                    numberString: tNumberString),
              ),
          expect: () => const [
                NumberTriviaIsLoading(),
                NumberTriviaError(message: kCacheFailureMessage),
              ],
          verify: (_) {
            verify(() => getConcreteNumberTrivia(
                const Params(number: tNumberParsed))).called(1);
          });
    });

    group('_onGetRandomPressedEvent', () {
      void setUpMockGetRandomUseCaseSuccess() =>
          when(() => getRandomNumberTrivia()).thenAnswer(
            (_) async => const Right(tNumberTrivia),
          );

      void setUpMockGetRandomUseCaseServerFailed() =>
          when(() => getRandomNumberTrivia()).thenAnswer(
            (_) async => Left(ServerFailure()),
          );

      void setUpMockGetRandomUseCaseCacheFailed() =>
          when(() => getRandomNumberTrivia()).thenAnswer(
            (_) async => Left(CacheFailure()),
          );

      blocTest(
        'should emit [NumberTriviaLoading] first when event is being called',
        setUp: () {
          setUpMockGetRandomUseCaseSuccess();
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          const NumberTriviaGetRandomPressed(),
        ),
        expect: () => const [
          NumberTriviaIsLoading(),
          NumberTriviaLoaded(numberTrivia: tNumberTrivia),
        ],
      );

      blocTest(
        'should emit [NumberTriviaLoading] and [NumberTriviaLoaded] with right data when successfull.',
        setUp: () {
          setUpMockGetRandomUseCaseSuccess();
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          const NumberTriviaGetRandomPressed(),
        ),
        expect: () => const [
          NumberTriviaIsLoading(),
          NumberTriviaLoaded(numberTrivia: tNumberTrivia),
        ],
        verify: (_) {
          verify(() => getRandomNumberTrivia()).called(1);
        },
      );

      blocTest(
        'should emit [NumberTriviaLoading] and [NumberTriviaError] with right message when server fails',
        setUp: () {
          setUpMockGetRandomUseCaseServerFailed();
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          const NumberTriviaGetRandomPressed(),
        ),
        expect: () => const [
          NumberTriviaIsLoading(),
          NumberTriviaError(message: kServerFailureMessage),
        ],
        verify: (_) {
          verify(() => getRandomNumberTrivia()).called(1);
        },
      );

      blocTest(
        'should emit [NumberTriviaLoading] and [NumberTriviaError] with right message when cache fails',
        setUp: () {
          setUpMockGetRandomUseCaseCacheFailed();
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          const NumberTriviaGetRandomPressed(),
        ),
        expect: () => const [
          NumberTriviaIsLoading(),
          NumberTriviaError(message: kCacheFailureMessage),
        ],
        verify: (_) {
          verify(() => getRandomNumberTrivia()).called(1);
        },
      );
    });
  });
}
