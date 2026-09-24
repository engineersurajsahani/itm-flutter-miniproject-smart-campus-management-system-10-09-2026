# Smart Campus Flutter Application

The frontend client for the **Smart Campus Management System**, built with **Flutter** and Dart. It connects to the Express + SQLite backend REST API to deliver a responsive experience across Web, Desktop, and Mobile platforms.

---

## 📹 Video Demonstration

Watch the project walkthrough video:
- 🎬 **MP4 Video**: [`Group 6 Project .mp4`](file:///Users/adarsh/Desktop/Flutter/Assignment%20/itm-flutter-miniproject-smart-campus-management-system-10-09-2026/Group%206%20Project%20/Group%206%20Project%20.mp4)

---

## 🌟 Key Features

- **Role-Based Views**: Tailored interfaces for Admin, Faculty, and Student users.
- **Admin Dashboard**: System metrics, user registration, course allocation, and notice management.
- **Faculty Tools**: Student attendance tracking, grade entries, and class updates.
- **Student Portal**: Real-time attendance summary, grade views, enrolled courses, and notice board.
- **State Management**: Clean architecture powered by `provider`.
- **Responsive Layout**: Designed for Web, Mobile (Android/iOS), and Desktop (macOS/Windows/Linux).

---

## 📱 Main Screens & Navigation

| Role | Core Functions |
| --- | --- |
| **Admin** | Dashboard stats, Manage Students/Faculty/Courses, Register Users, System Notices |
| **Faculty** | Assigned Courses list, Mark Daily Attendance, Upload Assessment Grades, Post Notices |
| **Student** | Attendance Progress %, Subject Grades, Course Details, Campus Notice Board |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.13.0 or higher)
- Backend REST API running at `http://localhost:3000/api`

### Running the App

1. Install Dart & Flutter packages:
   ```bash
   flutter pub get
   ```

2. Launch in Chrome (Web):
   ```bash
   flutter run -d chrome
   ```

3. Launch on Android/iOS/Desktop:
   ```bash
   flutter run
   ```

---

## 🔑 Demo Credentials

- **Email**: `admin@campus.com`
- **Password**: `admin123`

---

## 📖 System Documentation

For full architectural diagrams, API reference, and database models, view:
- 📖 [`documentation.md`](file:///Users/adarsh/Desktop/Flutter/Assignment%20/itm-flutter-miniproject-smart-campus-management-system-10-09-2026/Group%206%20Project%20/documentation.md)

---

## 🧪 Verification & Build Commands

Run static analysis and generate production web build:

```bash
flutter analyze
flutter build web
```
