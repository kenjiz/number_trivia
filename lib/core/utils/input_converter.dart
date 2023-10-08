import 'package:dartz/dartz.dart';

import '../error/failures.dart';

class InputConverter {
  Either<Failure, int> stringToUnsignedInteger(String str) {
    final value = int.tryParse(str);
    if (value == null || value < 0) {
      return Left(InvalidInputFailure());
    }

    return Right(value);
  }
}

class InvalidInputFailure extends Failure {}
