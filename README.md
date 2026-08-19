![BLOOM](assets/branding/bloom_logo.svg)

BLOOM is a personal finance and financial goals app built with Flutter. It tracks bank/e-wallet accounts, income and expense transactions, and savings goals. On native platforms (desktop/Android/iOS) data is stored locally with SQLite; on web it's in-memory only and resets on every reload (see [Web](#web) below). No bank passwords, PINs, OTPs, or credentials are ever requested — only balances you enter yourself.

## Running the app

This project is developed and tested on Windows via the desktop target, but the UI is mobile-first and intended for Android/iOS.

```
flutter pub get
flutter run -d windows
```

The window opens at a phone-sized 420×900 to reflect the mobile-first layout. Standard hot reload workflow applies (`r` reload, `R` restart, `q` quit).

To target Android/iOS instead, connect a device or emulator and run `flutter run` as usual — no platform-specific code changes are needed.

## Web

The web build swaps SQLite for an in-memory data layer (`lib/database/dao_factory.dart` picks the implementation per platform at compile time), since browsers have no filesystem for `sqflite`/`sqflite_common_ffi` to use. This means **web data does not persist** — every reload starts from a clean slate. That's intentional, not a bug.

```
flutter run -d chrome        # dev, with hot reload
flutter build web --release  # static bundle in build/web/, e.g. for deploying to Vercel (see vercel.json)
```

## Project structure

```
lib/
├── main.dart          # App entry point, provider wiring
├── models/            # Plain Dart data models (Account, Transaction, Goal, ...)
├── database/          # SQLite schema + DAOs (the only layer that imports sqflite)
├── services/          # Business logic (ChangeNotifier-based state + balance math)
├── screens/            # home / accounts / transactions / goals / analytics
├── widgets/            # Shared UI components
├── theme/              # Colors, type scale, spacing, ThemeData
└── utils/              # Formatters (currency, dates)
```

Data flows one direction: UI → Services → Database. Screens never touch SQLite directly, so the storage layer can be swapped for a cloud backend later without touching UI code.

## Testing

```
flutter test
```

- `test/services_test.dart` — integration tests against a real SQLite database, covering account balance math (income/expense/transfer effects, edits, deletes) and goal contribution/status logic.
- `test/widget_test.dart` — a UI smoke test confirming the app boots and renders.

## Design system

Deep Black / Off-White dominate the UI, with Bloom Pink (`#E85D9E`) as the sole brand accent. Colors and type scale live in `lib/theme/`.
