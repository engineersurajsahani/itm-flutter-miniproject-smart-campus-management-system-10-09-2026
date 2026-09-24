const express = require('express');
const db = require('../config/db');
const auth = require('../middleware/auth');
const authorize = require('../middleware/role');

const router = express.Router();

router.use(auth);

router.get('/', authorize('admin', 'faculty'), (req, res) => {
    const { role } = req.query;
    try {
        let users;
        if (role) {
            users = db.prepare('SELECT id, name, email, role, department, created_at FROM users WHERE role = ?').all(role.toLowerCase());
        } else {
            users = db.prepare('SELECT id, name, email, role, department, created_at FROM users').all();
        }
        res.json(users);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.get('/:id', authorize('admin', 'faculty'), (req, res) => {
    try {
        const user = db.prepare('SELECT id, name, email, role, department, created_at FROM users WHERE id = ?').get(req.params.id);
        if (!user) return res.status(404).json({ error: 'User not found' });
        res.json(user);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.put('/:id', authorize('admin'), (req, res) => {
    const { name, email, department, role } = req.body;
    try {
        const existing = db.prepare('SELECT * FROM users WHERE id = ?').get(req.params.id);
        if (!existing) return res.status(404).json({ error: 'User not found' });

        const updatedName = name !== undefined ? name : existing.name;
        const updatedEmail = email !== undefined ? email : existing.email;
        const updatedDept = department !== undefined ? department : existing.department;
        const updatedRole = role !== undefined ? role.toLowerCase() : existing.role;

        const stmt = db.prepare('UPDATE users SET name = ?, email = ?, department = ?, role = ? WHERE id = ?');
        stmt.run(updatedName, updatedEmail, updatedDept, updatedRole, req.params.id);
        res.json({ message: 'User updated successfully' });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

router.delete('/:id', authorize('admin'), (req, res) => {
    try {
        const stmt = db.prepare('DELETE FROM users WHERE id = ?');
        const info = stmt.run(req.params.id);
        if (info.changes === 0) return res.status(404).json({ error: 'User not found' });
        res.json({ message: 'User deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
