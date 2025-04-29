# Flashcard App

A simple Flutter Flashcard App with:
- Excel file upload (words and meanings)
- Multiple choice quiz
- Spaced repetition system (smart review scheduling)
- Daily session limit (50 cards/day)
- Offline progress saving

## Getting Started

- Upload your Excel (.xlsx) with Column A = Word and Column B = Meaning.
- Start daily quiz sessions and review mistakes smartly.
- App automatically saves your progress locally.

## Build Instructions

After cloning or downloading the project:
```bash
flutter pub get
flutter build apk --release
