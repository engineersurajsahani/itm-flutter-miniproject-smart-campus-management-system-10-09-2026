# Smart Campus Management System

![Project Status](https://img.shields.io/badge/Status-Completed-success)
![Framework](https://img.shields.io/badge/Frontend-Flutter-blue)
![Backend](https://img.shields.io/badge/Backend-Node.js%20%7C%20Express-green)
![Database](https://img.shields.io/badge/Database-SQLite-lightgrey)

A centralized, role-based Smart Campus Management System designed to manage students, faculty, courses, attendance, grades, notices, and academic records. Developed as the Group 6 Flutter Mini-Project.

---

## 📹 Video Demonstration

Watch the complete demonstration video showcasing system features and workflows:
- 🎬 **MP4 Video**: [`Group 6 Project .mp4`](file:///Users/adarsh/Desktop/Flutter/Assignment%20/itm-flutter-miniproject-smart-campus-management-system-10-09-2026/Group%206%20Project%20/Group%206%20Project%20.mp4)


---

## 📂 Repository Structure

```
.
├── Group 6 Project/              # Main Project Directory
│   ├── backend/                  # Node.js + Express + SQLite REST API backend
│   ├── smart_campus/             # Flutter Multi-Platform App (UI / Frontend)
│   ├── Group 6 Project .mp4      # Project Video Demonstration (MP4)
│   ├── documentation.md          # Technical documentation
│   └── README.md                 # Group 6 Project detailed README
├── documentation.md              # Technical documentation (Root copy)
└── README.md                     # Root project overview
```

---

## 🚀 Quick Start

### 1. Backend Setup

```bash
cd "Group 6 Project /backend"
npm install
npm run seed
npm start
```
*Backend API server runs at `http://localhost:3000`.*

### 2. Frontend Setup (Flutter)

```bash
cd "Group 6 Project /smart_campus"
flutter pub get
flutter run -d chrome
```

---

## 🔑 Key Features & Role-Based Access (RBAC)

- **Admin**: Complete system overview, student & faculty registration, course creation, notice management.
- **Faculty**: Attendance tracking, grade entry, class schedule management, announcement publishing.
- **Student**: View personal attendance percentages, course enrollment, subject grades, and institutional notices.

---

## 🔑 Demo Credentials

- **Admin Email**: `admin@campus.com`
- **Admin Password**: `admin123`

---

## 🛠️ Technology Stack

- **Frontend**: Flutter, Dart, Provider (State Management), HTTP package, Material 3 design.
- **Backend**: Node.js, Express.js, JWT Authentication, bcryptjs.
- **Database**: SQLite (`better-sqlite3`).

---

## 📖 Detailed Documentation

For full system architecture, database schema, API documentation, and component details:
- 📖 [Technical Documentation (`documentation.md`)](file:///Users/adarsh/Desktop/Flutter/Assignment%20/itm-flutter-miniproject-smart-campus-management-system-10-09-2026/documentation.md)
- 📖 [Group 6 Project README](file:///Users/adarsh/Desktop/Flutter/Assignment%20/itm-flutter-miniproject-smart-campus-management-system-10-09-2026/Group%206%20Project%20/README.md)
- 📖 [Smart Campus App README](file:///Users/adarsh/Desktop/Flutter/Assignment%20/itm-flutter-miniproject-smart-campus-management-system-10-09-2026/Group%206%20Project%20/smart_campus/README.md)
