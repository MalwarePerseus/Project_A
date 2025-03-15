// lib/features/missions/screens/memory_mission_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class MemoryMissionScreen extends StatefulWidget {
  final Map<String, dynamic> missionSettings;
  final VoidCallback onMissionComplete;

  const MemoryMissionScreen({
    Key? key,
    required this.missionSettings,
    required this.onMissionComplete,
  }) : super(key: key);

  @override
  _MemoryMissionScreenState createState() => _MemoryMissionScreenState();
}

class _MemoryMissionScreenState extends State<MemoryMissionScreen> {
  late int _pairCount;
  late int _timeLimit;
  late List<MemoryCard> _cards;
  int? _firstCardIndex;
  int? _secondCardIndex;
  bool _isProcessing = false;
  int _matchedPairs = 0;
  late Timer _timer;
  int _remainingSeconds = 0;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _pairCount = widget.missionSettings['pairs'] ?? 6;
    _timeLimit = widget.missionSettings['timeLimit'] ?? 60;
    _remainingSeconds = _timeLimit;
    _initializeCards();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _initializeCards() {
    // Create pairs of cards
    final List<MemoryCard> cards = [];

    // List of emoji pairs
    final List<String> emojis = [
      '🍎',
      '🍌',
      '🍒',
      '🍊',
      '🍇',
      '🍓',
      '🍉',
      '🍋',
      '🍍',
      '🥝',
      '🥑',
      '🥕',
      '🌽',
      '🍄',
      '🍔',
      '🍕',
      '🍦',
      '🍩',
      '🍪',
      '🍫',
    ];

    // Shuffle and select the required number of emojis
    emojis.shuffle();
    final selectedEmojis = emojis.take(_pairCount).toList();

    // Create pairs
    for (int i = 0; i < _pairCount; i++) {
      cards.add(MemoryCard(value: selectedEmojis[i]));
      cards.add(MemoryCard(value: selectedEmojis[i]));
    }

    // Shuffle the cards
    cards.shuffle();

    setState(() {
      _cards = cards;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer.cancel();
          _showTimeUpDialog();
        }
      });
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('Time\'s Up!'),
            content: Text('You ran out of time. Try again?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _matchedPairs = 0;
                    _firstCardIndex = null;
                    _secondCardIndex = null;
                    _remainingSeconds = _timeLimit;
                    _initializeCards();
                    _startTimer();
                  });
                },
                child: Text('Retry'),
              ),
            ],
          ),
    );
  }

  void _onCardTap(int index) {
    if (_isProcessing || _cards[index].isMatched || _cards[index].isFlipped) {
      return;
    }

    setState(() {
      _cards[index].isFlipped = true;

      if (_firstCardIndex == null) {
        _firstCardIndex = index;
      } else {
        _secondCardIndex = index;
        _isProcessing = true;

        // Check if cards match
        if (_cards[_firstCardIndex!].value == _cards[_secondCardIndex!].value) {
          _cards[_firstCardIndex!].isMatched = true;
          _cards[_secondCardIndex!].isMatched = true;
          _matchedPairs++;

          if (_matchedPairs == _pairCount) {
            _timer.cancel();
            widget.onMissionComplete();
          }

          _firstCardIndex = null;
          _secondCardIndex = null;
          _isProcessing = false;
        } else {
          // Cards don't match, flip them back after a delay
          Future.delayed(Duration(milliseconds: 1000), () {
            if (mounted) {
              setState(() {
                _cards[_firstCardIndex!].isFlipped = false;
                _cards[_secondCardIndex!].isFlipped = false;
                _firstCardIndex = null;
                _secondCardIndex = null;
                _isProcessing = false;
              });
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Mission'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Timer and progress
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Timer
                Row(
                  children: [
                    Icon(Icons.timer),
                    SizedBox(width: 8),
                    Text(
                      '$_remainingSeconds s',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Progress
                Text(
                  'Pairs: $_matchedPairs / $_pairCount',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Cards grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _pairCount <= 6 ? 3 : 4,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                return _buildCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform:
            _cards[index].isFlipped
                ? Matrix4.identity()
                : Matrix4.rotationY(pi),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              _cards[index].isMatched
                  ? Colors.green.shade100
                  : _cards[index].isFlipped
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child:
              _cards[index].isFlipped
                  ? Text(_cards[index].value, style: TextStyle(fontSize: 32))
                  : Icon(Icons.question_mark, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}

class MemoryCard {
  final String value;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.value,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
