import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:typed_data';
import '../models/flashcard.dart';
import '../services/flashcard_storage.dart';
import 'quiz_page.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  List<Flashcard> allFlashcards = [];

  Future<void> pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      Uint8List fileBytes = result.files.first.bytes!;
      var excel = Excel.decodeBytes(fileBytes);
      List<Flashcard> loadedCards = [];

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          if (row.length >= 2 && row[0] != null && row[1] != null) {
            loadedCards.add(
              Flashcard(
                word: row[0]!.value.toString(),
                meaning: row[1]!.value.toString(),
                nextReviewDate: DateTime.now(),
              ),
            );
          }
        }
      }

      List<Flashcard> existingCards = await FlashcardStorage.loadFlashcards();
      for (var card in loadedCards) {
        if (!existingCards.any((e) => e.word == card.word && e.meaning == card.meaning)) {
          existingCards.add(card);
        }
      }

      await FlashcardStorage.saveFlashcards(existingCards);

      setState(() {
        allFlashcards = existingCards;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Excel File'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickExcelFile,
              child: Text('Pick Excel File'),
            ),
            SizedBox(height: 20),
            allFlashcards.isNotEmpty
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizPage(allFlashcards: allFlashcards),
                        ),
                      );
                    },
                    child: Text('Start Quiz'),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}