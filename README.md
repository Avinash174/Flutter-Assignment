# Service Management Module - Flutter Assignment

## 🚀 Overview

A high-performance Flutter application built for the **Machine Test Requirements**. This project implements a comprehensive Service Management system using **Provider MVVM** architecture, featuring dynamic category selection, multi-step forms, and real-time API integration with a Node.js backend.

## ✨ Features

- **Provider MVVM Architecture**: Strict separation of UI, Business Logic (ViewModel), and Data Layer (ApiProvider).
- **Multipart API Integration**: Implements the exact machine test payload requirements using `FormData` for real-time file uploads (Logo/Image).
- **Dynamic Dropdowns**: Auto-loading Sub-Categories based on the selected Category using live API endpoints.
- **Interactive Calendar**: Custom availability selection logic with multi-select date support and time-slot management.
- **Optimistic UI Deletion**: Instant item removal with automatic rollback on network failure.
- **Premium UX/UI**:
  - **Shimmer Effect**: Beautiful skeleton screens during loading.
  - **Cached Images**: High-performance image rendering with `cached_network_image`.
  - **Custom Notifications**: Styled alerts using `awesome_snackbar_content`.
  - **Smooth Transitions**: Custom `SlideTransition` for all page navigation.

## 🛠️ Technical Implementation

- **Base URL**: `https://velvook-node.creatamax.in`
- **State Management**: `Provider` + `ChangeNotifier`
- **Authentication**: JWT-based token persistence using `shared_preferences`.
- **API Methods**: `GET`, `POST` (Multipart), `PUT` (Multipart), and `DELETE`.

## 📦 Getting Started

1. **Fetch Dependencies**:

   ```bash
   flutter pub get
   ```

2. **Run the App**:

   ```bash
   flutter run --release
   ```

3. **Build APK**:
   ```bash
   flutter build apk --release
   ```
   _The generated APK can be found at: `build/app/outputs/flutter-apk/app-release.apk`_

## 📜 Assignment Requirements Status

| Requirement                 | Status         |
| --------------------------- | -------------- |
| Service Create Form         | ✅ Implemented |
| Service List/View Page      | ✅ Implemented |
| Category/Sub-Category API   | ✅ Implemented |
| FormData Payload Support    | ✅ Implemented |
| Bearer Token Authentication | ✅ Implemented |
| Availability Logic          | ✅ Implemented |

---