# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run in debug mode
flutter run --profile    # Run in profile mode
flutter run --release    # Run in release mode
flutter analyze          # Static analysis / lint
flutter test             # Run tests
```

To generate app icons after modifying `flutter_launcher_icons.yaml`:
```bash
flutter pub run flutter_launcher_icons
```

## Architecture

**view_fix** is a single-page WebView browser app. It loads web pages inside the app with custom controls (favorites, zoom, navigation, auto-hide toolbar, screen wakelock).

### Structure

```
lib/
├── main.dart                    # Entry point; initializes FavoritesService
├── app.dart                     # Root MaterialApp
├── pages/home_page.dart         # Main page; owns all WebView state
├── services/favorites_service.dart  # Persistent favorites via SharedPreferences
└── widgets/app_bar_title.dart   # Custom AppBar with nav/zoom/favorites controls
```

### Key design decisions

- **State management**: Plain `StatefulWidget` + `setState()` — no external state management library.
- **Parent-to-child callbacks**: `HomePage` passes callbacks down to `AppBarTitle` to keep the WebView controller in the parent while exposing controls in the child.
- **Auto-hide AppBar**: An 8-second `Timer` collapses the toolbar after inactivity. Resets via a JavaScript bridge (`TouchBridge` channel) that fires on every tap inside the WebView.
- **Zoom**: Implemented client-side by injecting `document.body.style.zoom` JavaScript; clamped to 0.5–3.0.
- **Favorites serialization**: `FavoritesService` stores `FavoriteUrl` objects as a `StringList` in SharedPreferences, using `|||` as a field delimiter. Use `getFavoritesSimple()` — `getFavorites()` contains legacy/incomplete fallback logic.
- **YouTube guard**: Navigation to YouTube URLs is blocked in the WebView's `onNavigationRequest` callback.

### Notable conventions

- Some inline comments are written in Italian.
- `widgets/webview3.dart` is entirely commented out (legacy code, kept for reference).
- App version and build number are managed in `pubspec.yaml` (`version: major.minor.patch+build`).
