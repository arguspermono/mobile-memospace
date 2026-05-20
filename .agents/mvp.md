# MemoSpace: MVP Product Plan

## 1. Product Goal
To provide a fast, reliable, and entirely offline personal workspace for capturing thoughts, organizing tasks, and setting reliable reminders without the clutter of complex enterprise tools.

## 2. Target Users
- Students managing assignments and study notes.
- Professionals needing a quick, distraction-free way to capture meeting takeaways.
- Everyday users looking for a simple, privacy-focused daily planner and reminder tool.

## 3. MVP Features (In-Scope)
To guarantee a functional, stable, and beginner-friendly v1.0 release, development is strictly limited to the following core features:
- **Dashboard Summary**: A home screen showing total notes, upcoming reminders, and pinned items.
- **CRUD Notes**: The ability to Create, Read, Update, and Delete plain-text notes (with optional multiple image attachments).
- **Categories**: Grouping notes by user-defined categories (e.g., Work, Personal).
- **Search**: A simple text search to filter notes by title or content.
- **Pin/Favorite**: Toggling important notes to appear at the top of lists.
- **Reminder Notifications**: Scheduling local device alerts for specific notes.
- **Local Persistence**: Saving all data offline securely using SQLite.

## 4. Non-MVP Features (Out-of-Scope)
*Do not implement these during the MVP phase to prevent feature creep:*
- Rich text editing (bold, italics, bullet lists formatting)
- Cloud synchronization or cross-device syncing
- User authentication / Login systems
- Multi-user collaboration or note sharing

## 5. Success Criteria
The MVP is considered ready for release when:
1. A user can open the app and successfully save a note in under a few seconds.
2. The app works flawlessly in airplane mode (100% offline functionality).
3. Scheduled reminders reliably trigger the device's native notification system at the set time.
4. The SQLite database handles saving, querying, and deleting without app crashes.

## 6. Future Roadmap (v2.0+)
Once the MVP is launched and stable, the following enhancements will be evaluated:
- **v1.1**: App theming (Custom colors and Dark/Light mode toggles) and Optical Character Recognition (OCR) [SHIPPED].
- **v1.5**: Full Rich text editor support.
- **v2.0**: Optional Cloud sync/backup (e.g., via Firebase or Supabase).
- **v2.5**: Collaborative folders and shared notes with other users.
