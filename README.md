# Noah Samol
# CPSC 4150
# Solo 4 — Local Data Storage (Persistence Across Launches)

# What the app stores and why
The app stores a simple list of text items (like quick notes or to-do tasks) so users can add, edit, and delete them.  
The list persists between launches so the user never loses their data.

# Storage used
- Web: `shared_preferences` (backed by browser LocalStorage)
- Mobile/Desktop: SQLite (via `sqflite`)

# How to run and test persistence
bash
flutter pub get
flutter run -d chrome (or any other supported device/simulator/emulator)
1. Add several items using the Add button. 
2. Close the tab or restart the app. 
3. The items should still be there after reload. 
4. Use Clear All to reset the list and verify that persistence updates correctly.

# Data format and edge case
Stored as a JSON list of objects, where each object has:
{"id": 1, "text": "Sample note", "created_at": 1730200000000}
How this handles the edge case: if stored data becomes corrupted or unreadable, the app automatically resets the list instead of crashing.