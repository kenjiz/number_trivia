import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'core/network/network_info.dart';
import 'core/utils/input_converter.dart';
import 'features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'features/number_trivia/presentation/bloc/bloc.dart';

class InjectionContainer {
  const InjectionContainer._();

  static final serviceLocator = GetIt.instance;

  static Future<void> init() async {
    final sharedPrefs = await SharedPreferences.getInstance();

    //* * FEATURES
    //* NumberTrivia
    serviceLocator
      ..registerFactory(
        () => NumberTriviaBloc(
          concrete: serviceLocator(),
          random: serviceLocator(),
          inputConverter: serviceLocator(),
        ),
      )

      //* usecases
      ..registerLazySingleton(
        () => GetConcreteNumberTrivia(repository: serviceLocator()),
      )
      ..registerLazySingleton(
        () => GetRandomNumberTrivia(repository: serviceLocator()),
      )

      //* repositories
      ..registerLazySingleton<NumberTriviaRepository>(
        () => NumberTriviaRepositoryImpl(
          localDataSource: serviceLocator(),
          remoteDataSource: serviceLocator(),
          networkInfo: serviceLocator(),
        ),
      )

      //* data sources
      ..registerLazySingleton<NumberTriviaLocalDataSource>(
        () => NumberTriviaLocalDataSourceImpl(
          sharedPreferences: serviceLocator(),
        ),
      )
      ..registerLazySingleton<NumberTriviaRemoteDataSource>(
        () => NumberTriviaRemoteDataSourceImpl(
          client: serviceLocator(),
        ),
      )

      //* * CORE
      ..registerLazySingleton(
        () => InputConverter(),
      )
      ..registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImpl(serviceLocator()),
      )

      //* * EXTERNAL
      ..registerLazySingleton(
        () => http.Client(),
      )
      ..registerLazySingleton(
        () => InternetConnectionChecker.createInstance(),
      )
      ..registerLazySingleton<SharedPreferences>(
        () {
          return sharedPrefs;
        },
      );
  }
}
