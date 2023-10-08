import 'package:flutter/material.dart';

import '../widgets/trivia_controls.dart';
import '../widgets/trivia_result_display.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Trivia'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          TriviaResultDisplay(),
          SizedBox(height: 20),
          TriviaControls(),
        ],
      ),
    );
  }
}
