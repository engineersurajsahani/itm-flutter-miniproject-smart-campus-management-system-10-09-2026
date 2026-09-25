# Smart Campus Management System - Group 6 Project

A comprehensive, full-stack Smart Campus Management System featuring a responsive **Flutter multi-platform frontend** and a lightweight **Express + SQLite REST API backend**. 

This system provides centralized administrative, faculty, and student management with secure Role-Based Access Control (RBAC).

---

## 📁 Workspace Structure

```
Group 6 Project/
├── backend/                  # Node.js + Express REST API Server
│   ├── config/               # Database initialization & config (campus.db)
│   ├── middleware/           # Auth & authorization middlewares
│   ├── routes/               # API routes (auth, users, courses, attendance, grades, notices, dashboard)
│   ├── package.json          # Node dependencies & scripts
│   ├── seed.js               # Admin account seed script
│   └── server.js             # Server entry point (Port 3000)
├── smart_campus/             # Flutter Multi-Platform Application
│   ├── lib/                  # Dart source code (screens, providers, models, services)
│   ├── assets/               # Images and static assets
│   ├── pubspec.yaml          # Flutter dependencies & assets configuration
│   └── README.md             # Flutter app specific README
├── documentation.md          # Complete technical documentation
├── Group 6 Project .mp4      # Primary MP4 Video Demonstration Walkthrough
└── build.yaml                # Build configuration
```

---

## 📹 Video Demonstration

Watch the complete demonstration video showcasing all features (Admin, Faculty, Student roles):
- 🎬 **MP4 Format**: [`Group 6 Project .mp4`](file:///Users/adarsh/Desktop/Flutter/Assignment%20/itm-flutter-miniproject-smart-campus-management-system-10-09-2026/Group%206%20Project%20/Group%206%20Project%20.mp4)

---

## ✨ Features by Role

### 👑 Admin
- **Dashboard Overview**: Real-time stats for total students, faculty, courses, and active notices.
- **User Management**: Register and manage Admin, Faculty, and Student accounts.
- **Course Administration**: Create, update, and assign courses to faculty and enrolled students.
- **Campus Notices**: Publish and review institution-wide announcements.

### 👩‍🏫 Faculty
- **Course View**: Access assigned courses and student rosters.
- **Attendance Management**: Mark and record daily attendance for enrolled students.
- **Grade Management**: Input and update student assessment grades and academic results.
- **Announcements**: Post notices for assigned classes and general campus news.

### 🎓 Student
- **Academic Dashboard**: Check personal attendance records, percentage summary, and subject grades.
- **Course Catalog**: View enrolled courses and course details.
- **Noticeboard**: Stay updated with real-time campus notices and department announcements.
- **Session Info**: Recent login tracking and active session stats.

---

## 🛠️ Technology Stack

- **Frontend**: Flutter (Dart), `provider` for state management, `http` package for API calls, `google_fonts`, `shared_preferences`.
- **Backend**: Node.js, Express.js.
- **Database**: SQLite via `better-sqlite3`.
- **Authentication**: JWT (JSON Web Tokens) & `bcryptjs` password hashing.
- **Supported Platforms**: Web (Chrome/Edge), Android, iOS, macOS, Windows, Linux.

---

## 🚀 Quick Start Guide

### 1. Start Backend API Server

Navigate to the `backend/` directory, install dependencies, seed default data, and start the server:

```bash
cd backend
npm install
npm run seed
npm start
```
*The server will run on `http://localhost:3000` (listening on `0.0.0.0:3000`).*

### 2. Run Flutter Client Application

In a separate terminal window, navigate to `smart_campus/`, fetch dependencies, and run the app:

```bash
cd smart_campus
flutter pub get
flutter run -d chrome
```

---

## 🔐 Default Admin Credentials

Upon running `npm run seed` inside `backend/`, the following default admin user is initialized:

- **Role**: Admin
- **Email**: `admin@campus.com`
- **Password**: `admin123`

---

## 📡 Backend API Endpoints Summary

| Endpoint | Method | Description | Access |
| --- | --- | --- | --- |
| `/api/auth/login` | `POST` | User authentication & JWT issuance | Public |
| `/api/auth/register` | `POST` | Register a new user | Admin |
| `/api/users` | `GET`, `POST`, `PUT`, `DELETE` | User CRUD operations | Admin |
| `/api/courses` | `GET`, `POST`, `PUT`, `DELETE` | Course & enrollment management | Admin / Faculty |
| `/api/attendance` | `GET`, `POST` | Mark and view attendance records | Admin / Faculty / Student |
| `/api/grades` | `GET`, `POST` | Record and view student grades | Admin / Faculty / Student |
| `/api/notices` | `GET`, `POST`, `DELETE` | Campus announcements | All roles |
| `/api/dashboard` | `GET` | Role-specific dashboard statistics | Authenticated |

---

## 📖 Full System Documentation

For detailed database schemas, entity-relationship details, architectural diagrams, and comprehensive API docs, see:
- 📄 [`documentation.md`](file:///Users/adarsh/Desktop/Flutter/Assignment%20/itm-flutter-miniproject-smart-campus-management-system-10-09-2026/Group%206%20Project%20/documentation.md)

---

## 🧪 Verification & Build

To test and build the Flutter application:

```bash
cd smart_campus
flutter analyze
flutter build web
```
