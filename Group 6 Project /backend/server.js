const express = require('express');
const cors = require('cors');
const db = require('./config/db'); // Ensures DB is initialized

const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const courseRoutes = require('./routes/courses');
const attendanceRoutes = require('./routes/attendance');
const gradeRoutes = require('./routes/grades');
const noticeRoutes = require('./routes/notices');
const dashboardRoutes = require('./routes/dashboard');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/courses', courseRoutes);
app.use('/api/attendance', attendanceRoutes);
app.use('/api/grades', gradeRoutes);
app.use('/api/notices', noticeRoutes);
app.use('/api/dashboard', dashboardRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Smart Campus Backend running on port ${PORT} (0.0.0.0)`);
});
