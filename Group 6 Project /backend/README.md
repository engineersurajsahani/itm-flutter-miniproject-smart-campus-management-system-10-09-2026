# Smart Campus Backend API

Node.js + Express REST API server backed by SQLite (`better-sqlite3`) for the Smart Campus Management System.

---

## 🛠️ Tech Stack & Dependencies

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: SQLite (`better-sqlite3`)
- **Auth & Security**: `jsonwebtoken` (JWT), `bcryptjs`, CORS middleware

---

## 🚀 Setup & Execution

1. Install dependencies:
   ```bash
   npm install
   ```

2. Seed default admin user:
   ```bash
   npm run seed
   ```

3. Start server:
   ```bash
   npm start
   ```
   *Listens on port `3000` (`http://localhost:3000` / `0.0.0.0:3000`).*

---

## 📡 API Endpoints

- `POST /api/auth/login` - User login & token generation
- `POST /api/auth/register` - User registration (Admin only)
- `GET /api/users` - Fetch user listing
- `GET /api/courses` - Fetch courses & enrollments
- `GET /api/attendance` - Fetch attendance records
- `GET /api/grades` - Fetch academic grades
- `GET /api/notices` - Fetch announcements
- `GET /api/dashboard` - Role-based dashboard statistics
