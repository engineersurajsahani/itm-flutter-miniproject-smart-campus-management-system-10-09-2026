const express = require('express');
const db = require('../config/db');
const auth = require('../middleware/auth');

const router = express.Router();
router.use(auth);

router.get('/stats', (req, res) => {
    const { id, role } = req.user;
    try {
        if (role === 'admin') {
            const students = db.prepare("SELECT COUNT(*) as count FROM users WHERE role='student'").get().count;
            const faculty = db.prepare("SELECT COUNT(*) as count FROM users WHERE role='faculty'").get().count;
            const courses = db.prepare("SELECT COUNT(*) as count FROM courses").get().count;
            const notices = db.prepare("SELECT COUNT(*) as count FROM notices").get().count;
            
            return res.json({
                total_students: students,
                total_faculty: faculty,
                total_courses: courses,
                total_notices: notices,
                students: students,
                faculty: faculty,
                courses: courses,
                notices: notices
            });
        } 
        
        else if (role === 'faculty') {
            const coursesCount = db.prepare("SELECT COUNT(*) as count FROM courses WHERE faculty_id = ?").get(id).count;
            const students = db.prepare(`
                SELECT COUNT(DISTINCT student_id) as count 
                FROM attendance 
                JOIN courses ON attendance.course_id = courses.id 
                WHERE courses.faculty_id = ?
            `).get(id).count;
            const notices = db.prepare("SELECT COUNT(*) as count FROM notices WHERE target_role='all' OR target_role='faculty'").get().count;
            
            return res.json({
                courses_count: coursesCount,
                my_courses: coursesCount,
                total_students: students,
                recent_notices: notices
            });
        } 
        
        else if (role === 'student') {
            const coursesCount = db.prepare("SELECT COUNT(DISTINCT course_id) as count FROM attendance WHERE student_id = ?").get(id).count;
            
            const totalClasses = db.prepare("SELECT COUNT(*) as count FROM attendance WHERE student_id = ?").get(id).count;
            const presentClasses = db.prepare("SELECT COUNT(*) as count FROM attendance WHERE student_id = ? AND status='present'").get(id).count;
            const attendancePercentage = totalClasses === 0 ? 0 : (presentClasses / totalClasses) * 100;
            
            const avgGrade = db.prepare("SELECT AVG((marks * 100.0) / total_marks) as avg FROM grades WHERE student_id = ?").get(id).avg || 0;
            
            return res.json({
                courses_count: coursesCount,
                my_courses: coursesCount,
                attendance_percentage: parseFloat(attendancePercentage.toFixed(2)),
                attendance_percent: parseFloat(attendancePercentage.toFixed(2)),
                average_grade: parseFloat(avgGrade.toFixed(2))
            });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
