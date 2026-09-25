const db = require('./config/db');
const bcrypt = require('bcryptjs');

async function seed() {
    try {
        const hashedPassword = await bcrypt.hash('admin123', 10);
        const stmt = db.prepare(`
            INSERT OR IGNORE INTO users (name, email, password, role) 
            VALUES (?, ?, ?, ?)
        `);
        
        stmt.run('Admin', 'admin@campus.com', hashedPassword, 'admin');
        console.log('Seed successful: Admin user created or already exists.');
    } catch (error) {
        console.error('Error seeding admin user:', error.message);
    }
}

seed();
