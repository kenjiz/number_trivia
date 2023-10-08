import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';

class TriviaResultDisplay extends StatelessWidget {
  const TriviaResultDisplay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
        builder: (context, state) {
          switch (state) {
            case EmptyNumberTrivia():
              return const Center(
                child: Text(
                  'Start Searching',
                  style: TextStyle(fontSize: 24),
                ),
              );
            case NumberTriviaIsLoading():
              return const Center(
                child: CircularProgressIndicator(),
              );
            case NumberTriviaError():
              return Center(
                child: Text(state.message),
              );
            case NumberTriviaLoaded():
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      state.numberTrivia.number.toString(),
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.numberTrivia.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}
