import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/network/network_info.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    const tNumberTriviaModel = NumberTriviaModel(
      number: tNumber,
      text: 'Test Trivia',
    );

    runTestOnline(() {
      setUp(() {
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
            .thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) async => tNumberTriviaModel);
      });

      test('should check if the device is online', () async {
        // act
        await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(() => mockNetworkInfo.isConnected).called(1);
      });

      test(
        'should return remote data when the call to remote data source is successfull',
        () async {
          // act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          // assert
          expect(result, equals(const Right(tNumberTriviaModel)));
          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
              .called(1);
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should cache the data locally when the call to remote data source is successfull',
        () async {
          // act
          await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
              .called(1);
          verify(() =>
                  mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
              .called(1);
          verifyNoMoreInteractions(mockLocalDataSource);
        },
      );

      test(
          'should return a server failure when the call to remote data source is unsuccessful.',
          () async {
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenThrow(ServerException());
        final result = await repository.getConcreteNumberTrivia(tNumber);
        expect(result, equals(Left(ServerFailure())));
        verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .called(1);
        verifyZeroInteractions(mockLocalDataSource);
        verifyNoMoreInteractions(mockRemoteDataSource);
      });
    });

    runTestOffline(() {
      setUp(() {
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
            .thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) async => tNumberTriviaModel);
      });

      test(
          'should return last locally cached data when the cached data is present',
          () async {
        // arrange
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        expect(result, equals(const Right(tNumberTriviaModel)));
        verify(() => mockLocalDataSource.getLastNumberTrivia()).called(1);
        verifyZeroInteractions(mockRemoteDataSource);
      });

      test('should return [CacheFailure] when there\'s no cache data present',
          () async {
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());

        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        expect(result, equals(Left(CacheFailure())));
        verify(() => mockLocalDataSource.getLastNumberTrivia()).called(1);
        verifyZeroInteractions(mockRemoteDataSource);
      });
    });
  });

  group('getRandomNumberTrivia', () {
    const tNumberTriviaModel = NumberTriviaModel(
      number: 1,
      text: 'Test Trivia',
    );

    runTestOnline(() {
      setUp(() {
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) async => tNumberTriviaModel);
      });

      test('should check if the device is online', () async {
        // act
        await repository.getRandomNumberTrivia();
        // assert
        verify(() => mockNetworkInfo.isConnected).called(1);
      });

      test(
        'should return remote data when the call to remote data source is successfull',
        () async {
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          expect(result, equals(const Right(tNumberTriviaModel)));
          verify(() => mockRemoteDataSource.getRandomNumberTrivia()).called(1);
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should cache the data locally when the call to remote data source is successfull',
        () async {
          // act
          await repository.getRandomNumberTrivia();
          // assert
          verify(() => mockRemoteDataSource.getRandomNumberTrivia()).called(1);
          verify(() =>
                  mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
              .called(1);
          verifyNoMoreInteractions(mockLocalDataSource);
        },
      );

      test(
          'should return a server failure when the call to remote data source is unsuccessful.',
          () async {
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenThrow(ServerException());
        final result = await repository.getRandomNumberTrivia();
        expect(result, equals(Left(ServerFailure())));
        verify(() => mockRemoteDataSource.getRandomNumberTrivia()).called(1);
        verifyZeroInteractions(mockLocalDataSource);
        verifyNoMoreInteractions(mockRemoteDataSource);
      });
    });

    runTestOffline(() {
      setUp(() {
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) async => tNumberTriviaModel);
      });

      test(
          'should return last locally cached data when the cached data is present',
          () async {
        // arrange
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        // act
        final result = await repository.getRandomNumberTrivia();
        // assert
        expect(result, equals(const Right(tNumberTriviaModel)));
        verify(() => mockLocalDataSource.getLastNumberTrivia()).called(1);
        verifyZeroInteractions(mockRemoteDataSource);
      });

      test('should return [CacheFailure] when there\'s no cache data present',
          () async {
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());

        // act
        final result = await repository.getRandomNumberTrivia();
        // assert
        expect(result, equals(Left(CacheFailure())));
        verify(() => mockLocalDataSource.getLastNumberTrivia()).called(1);
        verifyZeroInteractions(mockRemoteDataSource);
      });
    });
  });
}
