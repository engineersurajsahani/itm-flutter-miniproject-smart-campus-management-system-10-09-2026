const express = require('express');
const db = require('../config/db');
const auth = require('../middleware/auth');
const authorize = require('../middleware/role');

const router = express.Router();

router.use(auth);

router.get('/', (req, res) => {
    try {
        const courses = db.prepare(`
            SELECT courses.*, users.name as faculty_name 
            FROM courses 
            LEFT JOIN users ON courses.faculty_id = users.id
        `).all();
        res.json(courses);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/', authorize('admin'), (req, res) => {
    const { name, code, faculty_id, department } = req.body;
    try {
        const stmt = db.prepare('INSERT INTO courses (name, code, faculty_id, department) VALUES (?, ?, ?, ?)');
        const info = stmt.run(name, code, faculty_id, department || null);
        res.status(201).json({ id: info.lastInsertRowid, name, code, faculty_id, department });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

router.put('/:id', authorize('admin'), (req, res) => {
    const { name, code, faculty_id, department } = req.body;
    try {
        const stmt = db.prepare('UPDATE courses SET name = ?, code = ?, faculty_id = ?, department = ? WHERE id = ?');
        const info = stmt.run(name, code, faculty_id, department || null, req.params.id);
        if (info.changes === 0) return res.status(404).json({ error: 'Course not found' });
        res.json({ message: 'Course updated successfully' });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

router.delete('/:id', authorize('admin'), (req, res) => {
    try {
        const stmt = db.prepare('DELETE FROM courses WHERE id = ?');
        const info = stmt.run(req.params.id);
        if (info.changes === 0) return res.status(404).json({ error: 'Course not found' });
        res.json({ message: 'Course deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
