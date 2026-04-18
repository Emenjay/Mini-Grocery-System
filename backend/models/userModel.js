// talks to db, contains raw SQL queries and returns results to controller

// import db connection 
const db = require('../config/db');

const User = {
  findByUsername: async (username) => {
    const [rows] = await db.query(
      `SELECT u.user_id, u.username, u.password, u.full_name, u.account_status,
              r.role_name
       FROM users u
       JOIN role r ON u.role_id = r.role_id
       WHERE u.username = ?`,
      [username]
    );
    return rows[0];
  }
};

module.exports = User;