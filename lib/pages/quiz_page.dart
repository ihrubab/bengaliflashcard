import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/flashcard_storage.dart';
import 'dart:math';

class QuizPage extends StatefulWidget {
  final List<Flashcard> allFlashcards;

  QuizPage({required this.allFlashcards});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Flashcard> sessionCards = [];
  int _currentIndex = 0;
  List<String> _options = [];
  Random _random = Random();
  int _correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    prepareSession();
  }

  void prepareSession() {
    DateTime today = DateTime.now();
    List<Flashcard> dueCards = widget.allFlashcards.where((card) => !card.nextReviewDate.isAfter(today)).toList();

    if (dueCards.length > 50) {
      dueCards.shuffle();
      sessionCards = dueCards.take(50).toList();
    } else {
      List<Flashcard> unseenCards = widget.allFlashcards.where((card) => card.correctStreak == 0 && !dueCards.contains(card)).toList();
      sessionCards = [...dueCards];
      unseenCards.shuffle();
      int fillCount = 50 - sessionCards.length;
      sessionCards.addAll(unseenCards.take(fillCount));
    }

    generateOptions();
  }

  void generateOptions() {
    if (_currentIndex >= sessionCards.length) return;
    String correctAnswer = sessionCards[_currentIndex].meaning;
    _options = [correctAnswer];

    while (_options.length < 4 && _options.length < widget.allFlashcards.length) {
      String randomMeaning = widget.allFlashcards[_random.nextInt(widget.allFlashcards.length)].meaning;
      if (!_options.contains(randomMeaning)) {
        _options.add(randomMeaning);
      }
    }

    _options.shuffle();
  }

  void answerQuestion(String selected) async {
    Flashcard currentCard = sessionCards[_currentIndex];
    bool isCorrect = (selected == currentCard.meaning);

    if (isCorrect) {
      _correctAnswers++;
      currentCard.correctStreak++;
      currentCard.nextReviewDate = DateTime.now().add(Duration(days: 4));
    } else {
      currentCard.correctStreak = 0;
      currentCard.nextReviewDate = DateTime.now().add(Duration(days: 1));
      sessionCards.add(currentCard);
    }

    await FlashcardStorage.saveFlashcards(widget.allFlashcards);

    setState(() {
      _currentIndex++;
      if (_currentIndex < sessionCards.length) {
        generateOptions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= sessionCards.length) {
      return Scaffold(
        appBar: AppBar(title: Text('Quiz Finished')),
        body: Center(
          child: Text(
            'Quiz Completed!\nCorrect: \$_correctAnswers / \${sessionCards.length}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22),
          ),
        ),
      );
    }

    String question = sessionCards[_currentIndex].word;

    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcard Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What is the meaning of:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              question,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ..._options.map(
              (option) => ElevatedButton(
                onPressed: () => answerQuestion(option),
                child: Text(option),
              ),
            ),
          ],
        ),
      ),
    );
  }
}