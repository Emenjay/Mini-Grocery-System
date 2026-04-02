// talks to db, contains raw SQL queries and returns results to controller

// import db connection 
const db = require('../config/db');

const User = {
    findByUsername: async (username) => {
        const [rows] = await db.query(
            'SELECT * FROM users WHERE UserName = ?', [username]
        );
        return rows[0];
    }
};

module.exports = User;