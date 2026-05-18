# MemoSpace Development Workflow

This document outlines the linear, beginner-friendly process for building MemoSpace, ensuring smooth integration between the UI, state, and local data.

## 1. Feature Development Order
We will build the application in manageable, step-by-step layers:
1. **Core UI Shell**: Setup basic screens (`DashboardScreen`, `NoteEditorScreen`) with mock data.
2. **Database Foundation**: Implement the `DatabaseHelper` and define the SQLite schema.
3. **State Integration**: Connect the UI to the Database using `Provider` to replace mock data with real data.
4. **Media & Details**: Add `image_picker` for attaching multiple images and implement Category/Pinning logic.
5. **Reminders**: Integrate `flutter_local_notifications` for scheduling alerts.
6. **Polish**: Final UI tweaks, micro-animations, and cleanup.

## 2. UI → Provider → DB Workflow
When building a data-driven feature (like saving or deleting a note), always follow this one-way flow:
1. **UI Layer**: User interacts with a Widget (e.g., taps the "Save" button in `NoteEditorScreen`).
2. **Provider Action**: The Widget triggers a method on the Provider: `context.read<NoteProvider>().addNote(newNote)`.
3. **Service Call**: The Provider waits for the Database Service to perform the operation: `await DatabaseHelper.insertNote(newNote)`.
4. **State Update**: Once the database confirms success, the Provider updates its local list in memory and calls `notifyListeners()`.
5. **UI Rebuild**: Widgets listening to the Provider via `Consumer<NoteProvider>` automatically rebuild to show the updated data.

## 3. Reminder Workflow
Handling local notifications follows this sequence:
1. **User Input**: User selects a reminder date and time in the UI.
2. **Database Save**: The note is saved/updated in the SQLite database with the new `reminder_date`.
3. **Schedule Notification**: Right after the DB save is successful, the Provider calls the `NotificationService` to schedule the device alert using the Note's unique ID.
4. **Update/Cancel**: If a note is deleted or its reminder is changed, the Provider calls the `NotificationService` to cancel the existing notification (using the Note ID), and schedules a new one if needed.

## 4. Testing Flow
For a simple and practical approach, we will rely on manual functional testing:
- **Test UI First**: Ensure buttons, text fields, and scrolling work visually before hooking up logic.
- **Log Outputs**: Use `debugPrint()` statements in Providers and Database helpers to verify data is passing correctly between layers.
- **Verify Persistence**: Restart the app completely. If the data (notes, pins, images) is still there, your database is working.
- **Test Edge Cases**: What happens if a title is empty? What if the user denies camera permissions? Ensure the app shows a simple `SnackBar` error instead of crashing.

## 5. Integration Flow
How to safely piece features together:
1. **Model First**: Always create the Dart `Model` (e.g., `note_model.dart`) to define your data structure.
2. **UI Second**: Build a static UI using a dummy/hardcoded version of the Model.
3. **Service Third**: Write the raw SQLite operations in `DatabaseHelper` in isolation.
4. **Provider Last**: Tie the UI and the Service together using the Provider. Do not skip directly to connecting UI to the DB.
