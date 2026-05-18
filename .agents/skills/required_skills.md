# Required Skills for MemoSpace

Based on the MemoSpace implementation plan, here are the practical skills you'll need to master, formatted as a checklist.

## 1. Flutter Fundamentals
- [ ] Understand the difference between `StatelessWidget` and `StatefulWidget`.
- [ ] Build basic UI layouts using `Row`, `Column`, `Stack`, and `Container`.
- [ ] Implement scrolling with `ListView.builder` (for the Dashboard and Notes list).
- [ ] Use `TextField` and `TextFormField` for note title and rich text input.
- [ ] Apply theming and styling using `ThemeData` and `const` constructors for performance.

## 2. Forms & Validation
- [ ] Use the `Form` widget and `GlobalKey<FormState>` to wrap inputs.
- [ ] Validate user input (e.g., ensuring a note has at least a title before saving).
- [ ] Manage focus nodes to move between title and content fields smoothly.

## 3. Navigation
- [ ] Push and pop screens using `Navigator.push` and `Navigator.pop`.
- [ ] Pass data between screens (e.g., passing an existing `Note` ID or object to the `NoteEditorScreen` for updating).

## 4. Async Programming
- [ ] Understand `Future`, `async`, and `await` for handling database operations and notifications.
- [ ] Use `FutureBuilder` to display loading indicators while fetching initial data from the database.

## 5. State Management Concepts & Provider
- [ ] Understand the concept of separating UI layer from the business/service layer.
- [ ] Use `ChangeNotifier` to create a `NoteProvider` that holds the state of your notes and categories.
- [ ] Use `ChangeNotifierProvider` to inject the state into the widget tree.
- [ ] Use `Consumer` and `context.read()` / `context.watch()` to read data and trigger targeted UI rebuilds.
- [ ] Update state and properly call `notifyListeners()` when a note is added, updated, deleted, or pinned.

## 6. SQLite & Local Data (sqflite)
- [ ] Understand basic SQL commands (CREATE TABLE, INSERT, SELECT, UPDATE, DELETE).
- [ ] Initialize a local SQLite database using the `sqflite` and `path_provider` packages.
- [ ] Map Dart objects (`Note` and `Category` models) to SQL rows (serialization/deserialization with `toMap` and `fromMap`).
- [ ] Handle simple relationships (e.g., filtering notes by `category_id`).
- [ ] Parse and stringify lists (like storing multiple image paths as a comma-separated string in the `images` column).

## 7. Media Handling
- [ ] Request permissions for accessing the device gallery.
- [ ] Pick multiple images using the `image_picker` package.
- [ ] Display selected images in the UI using `Image.file()`.

## 8. Local Notifications
- [ ] Configure platform-specific permissions for notifications (Android/iOS).
- [ ] Initialize the `flutter_local_notifications` plugin.
- [ ] Schedule a local notification based on a specific `reminder_date`.
- [ ] Handle notification interactions (e.g., tapping the notification to open the app or a specific note).
