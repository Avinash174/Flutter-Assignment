# Flutter Assignment

## Overview

This is a Flutter application refactored from GetX to the Provider architecture. It implements a fully functioning MVVM structure with real-world REST API integrations.

## Features

- Provider-based State Management (View / ViewModel separation)
- Full CRUD features interacting with a Node.js REST API
- Image Selection mechanism utilizing the native device gallery
- Loading states with `shimmer` package for visual feedback
- Image caching with `cached_network_image`
- Custom error and success alerts handled beautifully via `awesome_snackbar_content`
- Pull-to-refresh implementations for real-time data fetching
- Complete standard application theming with custom Google Fonts

## How to Run

1. `flutter pub get`
2. `flutter run`

## Required Packages

If running locally and dependencies are missing, ensure you run the following:

```bash
flutter pub add image_picker
flutter pub add awesome_snackbar_content
```

Note: Ensure you fully stop and completely rebuild the APK or iOS runner after fetching Native bindings for the `image_picker`.
