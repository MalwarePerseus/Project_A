// lib/features/missions/screens/math_mission_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';

class MathMissionScreen extends StatefulWidget {
  final Map<String, dynamic> missionSettings;
  final VoidCallback onMissionComplete;

  const MathMissionScreen({
    Key? key,
    required this.missionSettings,
    required this.onMissionComplete,
  }) : super(key: key);

  @override
  _MathMissionScreenState createState() => _MathMissionScreenState();
}

class _MathMissionScreenState extends State<MathMissionScreen> {
  late List<MathProblem> _problems;
  late TextEditingController _answerController;
  int _currentProblemIndex = 0;
  bool _isAnswerWrong = false;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    _generateProblems();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _generateProblems() {
    final difficulty = widget.missionSettings['difficulty'] ?? 'medium';
    final count = widget.missionSettings['count'] ?? 3;

    _problems = List.generate(count, (_) => _generateProblem(difficulty));
  }

  MathProblem _generateProblem(String difficulty) {
    int num1, num2, answer;
    String operator;

    switch (difficulty) {
      case 'easy':
        num1 = _random.nextInt(10) + 1; // 1-10
        num2 = _random.nextInt(10) + 1; // 1-10
        operator = ['+', '-'][_random.nextInt(2)];
        break;
      case 'medium':
        num1 = _random.nextInt(50) + 10; // 10-59
        num2 = _random.nextInt(40) + 5; // 5-44
        operator = ['+', '-', '*'][_random.nextInt(3)];
        break;
      case 'hard':
        num1 = _random.nextInt(100) + 20; // 20-119
        num2 = _random.nextInt(80) + 10; // 10-89
        operator = ['+', '-', '*', '/'][_random.nextInt(4)];
        // Ensure division results in an integer
        if (operator == '/') {
          num2 = _random.nextInt(10) + 1; // 1-10
          num1 =
              num2 * (_random.nextInt(10) + 1); // Make sure it divides evenly
        }
        break;
      default:
        num1 = _random.nextInt(20) + 1; // 1-20
        num2 = _random.nextInt(20) + 1; // 1-20
        operator = ['+', '-'][_random.nextInt(2)];
    }

    // Calculate answer
    switch (operator) {
      case '+':
        answer = num1 + num2;
        break;
      case '-':
        // Ensure positive result for subtraction
        if (num1 < num2) {
          final temp = num1;
          num1 = num2;
          num2 = temp;
        }
        answer = num1 - num2;
        break;
      case '*':
        answer = num1 * num2;
        break;
      case '/':
        answer = num1 ~/ num2;
        break;
      default:
        answer = num1 + num2;
    }

    return MathProblem(
      num1: num1,
      num2: num2,
      operator: operator,
      answer: answer,
    );
  }

  void _checkAnswer() {
    final userAnswer = int.tryParse(_answerController.text.trim()) ?? 0;
    final correctAnswer = _problems[_currentProblemIndex].answer;

    if (userAnswer == correctAnswer) {
      // Correct answer
      setState(() {
        _isAnswerWrong = false;
        _answerController.clear();

        if (_currentProblemIndex < _problems.length - 1) {
          _currentProblemIndex++;
        } else {
          // All problems solved
          widget.onMissionComplete();
        }
      });
    } else {
      // Wrong answer
      setState(() {
        _isAnswerWrong = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentProblem = _problems[_currentProblemIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Math Mission'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Solve the problem to turn off the alarm',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _problems.length,
                  (index) => Container(
                    width: 12,
                    height: 12,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          index < _currentProblemIndex
                              ? Colors.green
                              : index == _currentProblemIndex
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 48),
              // Problem display
              Text(
                '${currentProblem.num1} ${currentProblem.operator} ${currentProblem.num2} = ?',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 48),
              // Answer input
              TextField(
                controller: _answerController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                autofocus: true,
                style: TextStyle(fontSize: 24),
                decoration: InputDecoration(
                  hintText: 'Enter your answer',
                  errorText: _isAnswerWrong ? 'Wrong answer, try again' : null,
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _checkAnswer(),
              ),
              SizedBox(height: 32),
              // Submit button
              ElevatedButton(
                onPressed: _checkAnswer,
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(minimumSize: Size(200, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MathProblem {
  final int num1;
  final int num2;
  final String operator;
  final int answer;

  MathProblem({
    required this.num1,
    required this.num2,
    required this.operator,
    required this.answer,
  });
}
