import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    super.key,
  });

  @override
  State<TriviaControls> createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final textFieldController = TextEditingController();

  @override
  void dispose() {
    textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Column(
        children: [
          _buildTextField(),
          const SizedBox(height: 10),
          _buildButtons(context),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: textFieldController,
      decoration: const InputDecoration(
        hintText: 'Input a number',
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      // keyboardType: TextInputType.number,
      textInputAction: TextInputAction.go,
      onSubmitted: (_) => _onGetConcretePressed(),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _onGetConcretePressed,
            child: const Text('Search'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _onGetRandomPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCACACA),
            ),
            child: const Text(
              'Get Random Trivia',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onGetConcretePressed() {
    context.read<NumberTriviaBloc>().add(
          NumberTriviaGetConcretePressed(
            numberString: textFieldController.text,
          ),
        );
    textFieldController.clear();
  }

  void _onGetRandomPressed() {
    context.read<NumberTriviaBloc>().add(
          const NumberTriviaGetRandomPressed(),
        );
  }
}
