const express = require('express');
const db = require('../config/db');
const auth = require('../middleware/auth');
const authorize = require('../middleware/role');

const router = express.Router();
router.use(auth);

router.post('/', authorize('faculty'), (req, res) => {
    const course_id = req.body.course_id ?? req.body.courseId;
    const date = req.body.date;
    const records = req.body.records || []; // records: [{student_id or studentId, status}]
    try {
        const deleteExisting = db.prepare('DELETE FROM attendance WHERE course_id = ? AND date = ?');
        const insert = db.prepare('INSERT INTO attendance (student_id, course_id, date, status, marked_by) VALUES (?, ?, ?, ?, ?)');
        const insertMany = db.transaction((recordsToInsert) => {
            deleteExisting.run(course_id, date);
            for (const record of recordsToInsert) {
                const studentId = record.student_id ?? record.studentId;
                insert.run(studentId, course_id, date, record.status, req.user.id);
            }
        });
        insertMany(records);
        res.status(201).json({ message: 'Attendance marked successfully' });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

router.get('/course/:courseId', authorize('admin', 'faculty'), (req, res) => {
    const { date } = req.query;
    const { courseId } = req.params;
    try {
        let attendance;
        if (date) {
            attendance = db.prepare(`
                SELECT a.*, u.name as student_name 
                FROM attendance a 
                JOIN users u ON a.student_id = u.id 
                WHERE a.course_id = ? AND a.date = ?
            `).all(courseId, date);
        } else {
            attendance = db.prepare(`
                SELECT a.*, u.name as student_name 
                FROM attendance a 
                JOIN users u ON a.student_id = u.id 
                WHERE a.course_id = ?
            `).all(courseId);
        }
        res.json(attendance);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.get('/student/:studentId', (req, res) => {
    const { studentId } = req.params;
    
    // Check if student is accessing their own attendance or if it's admin/faculty
    if (req.user.role === 'student' && req.user.id !== parseInt(studentId)) {
        return res.status(403).json({ error: 'Forbidden: Can only access own attendance' });
    }

    try {
        const attendance = db.prepare(`
            SELECT a.*, c.name as course_name, u.name as student_name 
            FROM attendance a 
            JOIN courses c ON a.course_id = c.id 
            JOIN users u ON a.student_id = u.id 
            WHERE a.student_id = ?
        `).all(studentId);
        res.json(attendance);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
