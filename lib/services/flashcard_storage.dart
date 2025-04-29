import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';

class FlashcardStorage {
  static const String _storageKey = 'flashcards';

  static Future<void> saveFlashcards(List<Flashcard> flashcards) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cardList = flashcards.map((card) => jsonEncode(card.toMap())).toList();
    await prefs.setStringList(_storageKey, cardList);
  }

  static Future<List<Flashcard>> loadFlashcards() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cardList = prefs.getStringList(_storageKey);
    if (cardList == null) return [];
    return cardList.map((str) => Flashcard.fromMap(jsonDecode(str))).toList();
  }

  static Future<void> clearFlashcards() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}