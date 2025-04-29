class Flashcard {
  final String word;
  final String meaning;
  DateTime nextReviewDate;
  int correctStreak;

  Flashcard({
    required this.word,
    required this.meaning,
    required this.nextReviewDate,
    this.correctStreak = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'meaning': meaning,
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'correctStreak': correctStreak,
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      word: map['word'],
      meaning: map['meaning'],
      nextReviewDate: DateTime.parse(map['nextReviewDate']),
      correctStreak: map['correctStreak'] ?? 0,
    );
  }
}