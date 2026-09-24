const express = require('express');
const db = require('../config/db');
const auth = require('../middleware/auth');
const authorize = require('../middleware/role');

const router = express.Router();
router.use(auth);

router.get('/', (req, res) => {
    try {
        const role = req.user.role ? req.user.role.toLowerCase() : '';
        const pluralRole = role === 'student' ? 'students' : (role === 'faculty' ? 'faculty' : role);

        const notices = db.prepare(`
            SELECT n.*, u.name as poster_name 
            FROM notices n 
            JOIN users u ON n.posted_by = u.id 
            WHERE n.target_role = 'all' 
               OR LOWER(n.target_role) = ? 
               OR LOWER(n.target_role) = ? 
               OR ? = 'admin'
            ORDER BY n.created_at DESC
        `).all(role, pluralRole, role);
        res.json(notices);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/', authorize('admin', 'faculty'), (req, res) => {
    let { title, content, target_role, audience } = req.body;
    let targetRole = (target_role || audience || 'all').toLowerCase().trim();
    if (targetRole === 'students') targetRole = 'student';

    try {
        const stmt = db.prepare('INSERT INTO notices (title, content, target_role, posted_by) VALUES (?, ?, ?, ?)');
        const info = stmt.run(title, content, targetRole, req.user.id);
        res.status(201).json({ id: info.lastInsertRowid, message: 'Notice posted successfully' });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

router.delete('/:id', authorize('admin'), (req, res) => {
    try {
        const stmt = db.prepare('DELETE FROM notices WHERE id = ?');
        const info = stmt.run(req.params.id);
        if (info.changes === 0) return res.status(404).json({ error: 'Notice not found' });
        res.json({ message: 'Notice deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
