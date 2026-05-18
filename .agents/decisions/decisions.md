# Architectural Decisions

This document outlines the core technical decisions for the MemoSpace project and the rationale behind them.

## 1. Why SQLite over Supabase?
**Decision**: Use local SQLite (`sqflite`) instead of a Backend-as-a-Service like Supabase.
**Rationale**: MemoSpace is designed as a personal, privacy-focused application. SQLite provides zero-latency data access without requiring user authentication, network requests, or cloud infrastructure costs. It perfectly aligns with the offline-first requirement and keeps the app self-contained.

## 2. Why Provider over Riverpod/BLoC?
**Decision**: Use `provider` with `ChangeNotifier` for state management.
**Rationale**: Provider offers the best balance between simplicity and maintainability. BLoC introduces unnecessary boilerplate for a simple CRUD application, and Riverpod has a steeper learning curve. Provider natively integrates with Flutter's widget tree, keeping the architecture beginner-friendly while effectively decoupling UI from business logic.

## 3. Why Local Notifications?
**Decision**: Use `flutter_local_notifications` instead of Firebase Cloud Messaging (FCM).
**Rationale**: FCM requires a server environment to trigger push notifications. Since MemoSpace operates entirely on-device without a backend, local notifications allow the app to schedule and trigger OS-level alerts independently using native device APIs.

## 4. Why Layered Architecture?
**Decision**: Separate the application into distinct layers (UI, Provider, Service).
**Rationale**: This promotes modularity and separation of concerns. The UI layer only knows how to display data, the Provider acts as the mediator handling business rules, and the Service layer strictly handles raw data/OS operations. This ensures that refactoring one layer (e.g., swapping SQLite for Hive) does not impact the others.

## 5. Why Offline-First Approach?
**Decision**: Design the system to operate entirely offline without requiring internet connectivity.
**Rationale**: For a utility app like note-taking and reminders, users expect instant access to their data regardless of signal strength. Storing data and media locally ensures maximum reliability, speed, and privacy, drastically reducing the architectural complexity of data synchronization and conflict resolution.
