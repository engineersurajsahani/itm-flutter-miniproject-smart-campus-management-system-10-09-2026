const express = require('express');
const db = require('../config/db');
const auth = require('../middleware/auth');
const authorize = require('../middleware/role');

const router = express.Router();
router.use(auth);

router.post('/', authorize('faculty'), (req, res) => {
    const student_id = req.body.student_id ?? req.body.studentId;
    const course_id = req.body.course_id ?? req.body.courseId;
    const exam_type = req.body.exam_type ?? req.body.examType;
    const marks = req.body.marks;
    const total_marks = req.body.total_marks ?? req.body.totalMarks ?? 100;

    try {
        const stmt = db.prepare('INSERT INTO grades (student_id, course_id, exam_type, marks, total_marks, uploaded_by) VALUES (?, ?, ?, ?, ?, ?)');
        const info = stmt.run(student_id, course_id, exam_type, marks, total_marks, req.user.id);
        res.status(201).json({ id: info.lastInsertRowid, message: 'Grade uploaded successfully' });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

router.get('/student/:studentId', (req, res) => {
    const { studentId } = req.params;
    
    if (req.user.role === 'student' && req.user.id !== parseInt(studentId)) {
        return res.status(403).json({ error: 'Forbidden: Can only access own grades' });
    }

    try {
        const grades = db.prepare(`
            SELECT g.*, c.name as course_name, u.name as student_name 
            FROM grades g 
            JOIN courses c ON g.course_id = c.id 
            JOIN users u ON g.student_id = u.id 
            WHERE g.student_id = ?
        `).all(studentId);
        res.json(grades);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.get('/course/:courseId', authorize('admin', 'faculty'), (req, res) => {
    const { courseId } = req.params;
    try {
        const grades = db.prepare(`
            SELECT g.*, u.name as student_name 
            FROM grades g 
            JOIN users u ON g.student_id = u.id 
            WHERE g.course_id = ?
        `).all(courseId);
        res.json(grades);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
