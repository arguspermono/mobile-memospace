# MemoSpace Development Tasks

This document breaks down the implementation into atomic, sequential, and AI-codegen friendly tasks based on the project specification.

## Task 1: Project Setup & Dependencies
- **Objective**: Configure the Flutter project and install required packages.
- **Files Involved**: `pubspec.yaml`, `lib/main.dart`
- **Dependencies**: None
- **Expected Output**: `pubspec.yaml` contains `provider`, `sqflite`, `path_provider`, `flutter_local_notifications`, `intl`, and `image_picker`. `flutter pub get` runs successfully. App runs to a blank screen.

## Task 2: Define Data Models
- **Objective**: Create serializable Dart classes for Category and Note.
- **Files Involved**: `lib/models/category_model.dart`, `lib/models/note_model.dart`
- **Dependencies**: Task 1
- **Expected Output**: Dart classes with `toMap()` and `fromMap()` methods. `Note` includes an `images` property (String) and `reminder_date`.

## Task 3: Database Initialization
- **Objective**: Set up the SQLite database connection and create tables.
- **Files Involved**: `lib/services/database_helper.dart`
- **Dependencies**: Task 2
- **Expected Output**: `DatabaseHelper` singleton that correctly opens the DB and executes `CREATE TABLE` for `categories` and `notes`.

## Task 4: Database CRUD - Categories
- **Objective**: Implement core SQLite operations for Categories.
- **Files Involved**: `lib/services/database_helper.dart`
- **Dependencies**: Task 3
- **Expected Output**: Methods for `insertCategory`, `getCategories`, `updateCategory`, and `deleteCategory` exist and are functional.

## Task 5: Database CRUD - Notes
- **Objective**: Implement core SQLite operations for Notes.
- **Files Involved**: `lib/services/database_helper.dart`
- **Dependencies**: Task 4
- **Expected Output**: Methods for `insertNote`, `getNotes`, `updateNote`, and `deleteNote` exist and are functional.

## Task 6: Provider Setup
- **Objective**: Create the global state manager and inject it.
- **Files Involved**: `lib/providers/note_provider.dart`, `lib/main.dart`
- **Dependencies**: Task 5
- **Expected Output**: `NoteProvider` class using `ChangeNotifier`. `ChangeNotifierProvider` wraps `MaterialApp` in `main.dart`. 

## Task 7: Core UI - Dashboard Layout
- **Objective**: Build the static layout for the Dashboard.
- **Files Involved**: `lib/screens/dashboard_screen.dart`, `lib/widgets/note_card.dart`
- **Dependencies**: Task 6
- **Expected Output**: A visually complete dashboard with an App Bar, Floating Action Button, and a static `ListView` of dummy `NoteCard` widgets.

## Task 8: UI + Provider Integration (Dashboard)
- **Objective**: Connect the Dashboard to fetch and display real data.
- **Files Involved**: `lib/screens/dashboard_screen.dart`, `lib/providers/note_provider.dart`
- **Dependencies**: Task 7
- **Expected Output**: `DashboardScreen` uses `Consumer<NoteProvider>` to dynamically list notes fetched from the DB on app start.

## Task 9: Core UI - Note Editor Layout
- **Objective**: Build the static layout for creating or editing notes.
- **Files Involved**: `lib/screens/note_editor_screen.dart`
- **Dependencies**: Task 8
- **Expected Output**: A screen with `TextField`s for Title and Content, and a 'Save' button in the AppBar.

## Task 10: UI + Provider Integration (Note Editor)
- **Objective**: Implement the logic to save a new or edited note.
- **Files Involved**: `lib/screens/note_editor_screen.dart`, `lib/providers/note_provider.dart`
- **Dependencies**: Task 9
- **Expected Output**: Tapping 'Save' calls Provider, writes to DB, pops the screen, and the Dashboard instantly reflects the new/updated note.

## Task 11: Implement Categories Feature
- **Objective**: Allow users to assign categories to notes.
- **Files Involved**: `lib/screens/note_editor_screen.dart`, `lib/widgets/category_chip.dart`
- **Dependencies**: Task 10
- **Expected Output**: Note Editor UI shows category chips. Selecting one saves the `category_id` correctly.

## Task 12: Implement Image Attachments
- **Objective**: Add `image_picker` functionality to attach images.
- **Files Involved**: `lib/screens/note_editor_screen.dart`, `lib/widgets/image_thumbnail.dart`
- **Dependencies**: Task 11
- **Expected Output**: Users can pick images from the gallery. Paths are stored as a JSON/comma-separated string in the DB. UI displays image thumbnails.

## Task 13: Implement Search & Pinning
- **Objective**: Add search filtering and pinning logic.
- **Files Involved**: `lib/screens/dashboard_screen.dart`, `lib/providers/note_provider.dart`
- **Dependencies**: Task 12
- **Expected Output**: Search bar filters the list. Pinned notes appear at the top of the list in the Dashboard.

## Task 14: Local Notifications Service
- **Objective**: Initialize the notification plugin.
- **Files Involved**: `lib/services/notification_service.dart`, `lib/main.dart`
- **Dependencies**: Task 13
- **Expected Output**: Permissions requested on startup. A dummy test notification can be triggered successfully.

## Task 15: Reminders Workflow Integration
- **Objective**: Connect `reminder_date` to actual scheduled notifications.
- **Files Involved**: `lib/screens/note_editor_screen.dart`, `lib/providers/note_provider.dart`
- **Dependencies**: Task 14
- **Expected Output**: User sets a date/time using Flutter's native pickers. Saving the note schedules a real notification via `NotificationService`.
