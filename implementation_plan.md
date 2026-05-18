# MemoSpace: Implementation Plan

## 1. Architecture Overview
A beginner-friendly, decoupled architecture using **Provider** for state management and **Service classes** for local data & notifications.
- **UI Layer (`screens`, `widgets`)**: Consumes Providers, displays data, handles user inputs.
- **State Layer (`providers`)**: Holds business logic, calls services, notifies UI of changes.
- **Service Layer (`services`)**: Handles raw data operations (SQLite) and device APIs (Notifications).

## 2. Folder Structure
```text
lib/
├── models/         # Data models (Note, Category)
├── providers/      # State management (NoteProvider, ThemeProvider)
├── screens/        # Full screen views (Dashboard, NoteEditor)
├── widgets/        # Reusable UI components (NoteCard, CategoryChip)
├── services/       # External operations (DatabaseHelper, NotificationService)
├── utils/          # Constants, formatters, theme definitions
└── main.dart       # Entry point & Provider initialization
```

## 3. Feature Breakdown
- **Dashboard**: Summary stats (total notes, upcoming reminders), pinned notes, recent list.
- **CRUD Notes**: Create, read, update, and delete notes with title and rich text.
- **Categories**: Group notes by category (e.g., Work, Personal) with color tags.
- **Search**: Filter notes by title or content.
- **Pin/Favorite**: Quick toggle to keep important notes at the top.
- **Reminders**: Schedule local push notifications for specific notes.

## 4. Database Schema (SQLite)
**Table: `categories`**
- `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
- `name` (TEXT NOT NULL)
- `color_hex` (TEXT)

**Table: `notes`**
- `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
- `title` (TEXT NOT NULL)
- `content` (TEXT)
- `category_id` (INTEGER, FOREIGN KEY to categories.id)
- `is_pinned` (INTEGER DEFAULT 0)
- `reminder_date` (TEXT - ISO8601, nullable)
- `images` (TEXT - JSON string or comma-separated paths for multiple images)
- `created_at` (TEXT NOT NULL)
- `updated_at` (TEXT NOT NULL)

## 5. State Management Flow
1. **User Action**: User saves a note in `NoteEditorScreen`.
2. **Provider Call**: UI calls `context.read<NoteProvider>().addNote()`.
3. **Service Execution**: Provider calls `DatabaseHelper.insertNote()`.
4. **State Update**: Provider updates its internal list and calls `notifyListeners()`.
5. **UI Rebuild**: `Consumer<NoteProvider>` on the `DashboardScreen` rebuilds to show the new note.

## 6. Development Phases
- **Phase 1: Foundation (Days 1-2)**
  - Project setup, theming, and basic screen routing.
  - Implement static UI for Dashboard and Note Editor.
- **Phase 2: Database Storage (Days 3-4)**
  - Setup `sqflite` and `DatabaseHelper`.
  - Create models and basic CRUD operations.
- **Phase 3: State Integration & Media (Days 5-6)**
  - Integrate `Provider` to connect UI with the database.
  - Implement Search, Category filtering, and Pinning logic.
  - Add `image_picker` for attaching multiple images to notes.
- **Phase 4: Notifications (Days 7-8)**
  - Setup `flutter_local_notifications`.
  - Add reminder scheduling to Note Editor.
- **Phase 5: Polish (Day 9)**
  - Refactoring, bug fixes, and adding micro-animations.

## 7. Dependencies (`pubspec.yaml`)
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1                # State management
  sqflite: ^2.3.0                 # Local SQLite database
  path_provider: ^2.1.2           # Access file system for DB
  flutter_local_notifications: ^17.1.2 # Reminders
  intl: ^0.19.0                   # Date formatting
  image_picker: ^1.1.2            # Select images from gallery/camera
```

## 8. Coding Conventions
- **Modular Widgets**: Break large screens into smaller, reusable widgets inside `lib/widgets/`.
- **Naming**: Use `camelCase` for variables/functions, `PascalCase` for classes, `snake_case` for file names.
- **Safety**: Use `const` constructors wherever possible to optimize UI rebuilds.
- **Null Safety**: Rely on nullable types for optional fields (like `reminder_date`) instead of dummy values.
