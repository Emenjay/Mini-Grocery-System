// talks to db, contains raw SQL queries and returns results to controller

// import db connection 
const db = require('../config/db');

const User = {

  // find user by username
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
  },

  // get all employees with on-duty status via single JOIN users and attendance
  getAllUsers: async (search = '', roleFilter = '') => {
    const keyword = `%${search}%`;

    // base query, join attendance to check if clocked in today with no clock out
    let query = `
      SELECT 
        u.user_id, u.full_name, u.username, u.contact_number,
        u.address, u.profile_picture, u.account_status, u.created_at,
        r.role_name,
      -- if a matching attendance row exists, they are on duty
        CASE WHEN a.attendance_id IS NOT NULL THEN TRUE ELSE FALSE END AS is_on_duty
      FROM users u
      JOIN role r ON u.role_id = r.role_id
      -- left join: only match open shifts from today (clock in but no clock out)
      LEFT JOIN attendance a 
        ON a.user_id = u.user_id
        AND a.clock_out_timestamp IS NULL
        AND DATE(a.clock_in_timestamp) = CURDATE()
      WHERE (u.full_name LIKE ? OR r.role_name LIKE ?)
    `;

    const params = [keyword, keyword];

    // optional role filter
    if (roleFilter) {
      query += ` AND r.role_name = ?`;
      params.push(roleFilter);
    }

    const [rows] = await db.query(query, params);
    return rows;
  },

  // get user by ID
  findByID: async (userID) => {
    const [rows] = await db.query(
      `SELECT u.user_id, u.full_name, u.username, u.contact_number,
              u.address, u.profile_picture, u.account_status, u.created_at,
              r.role_name, r.role_id
       FROM users u
       JOIN role r ON u.role_id = r.role_id
       WHERE u.user_id = ?`,
      [userID]
    );
    return rows[0];
  },

  // get attendance history for a user
  getAttendanceHistory: async (userID) => {
    const [rows] = await db.query(
      `SELECT 
        attendance_id,
        clock_in_timestamp,
        clock_out_timestamp
       FROM attendance
       WHERE user_id = ?
       ORDER BY clock_in_timestamp DESC`,
      [userID]
    );
    return rows;
  },

  // add new employee
  addUser: async (roleID, username, password, fullName, contactNumber, address, profilePicture) => {
    const [result] = await db.query(
      `INSERT INTO users (role_id, username, password, full_name, contact_number, address, profile_picture, account_status, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, TRUE, NOW())`,
      [roleID, username, password, fullName, contactNumber || null, address || null, profilePicture || null]
    );
    return result.insertId;
  },

  // check if username already exists to avoid duplicates
  isUsernameTaken: async (username, excludeUserID = null) => {
    let query = 'SELECT user_id FROM users WHERE username = ?';
    const params = [username];

    // when editing, exclude the current user from the check
    if (excludeUserID) {
      query += ' AND user_id != ?';
      params.push(excludeUserID);
    }

    const [rows] = await db.query(query, params);
    return rows.length > 0;
  },

  // update employee, update only changed fields
  updateUser: async (userID, fields) => {
    const allowedFields = [
      'full_name', 'contact_number', 'address',
      'profile_picture', 'username', 'password', 'role_id'
    ];
    const keys = Object.keys(fields).filter(k => allowedFields.includes(k));
    if (keys.length === 0) return 0;

    const values = keys.map(k => fields[k]);
    const setClause = keys.map(k => `${k} = ?`).join(', ');

    const [result] = await db.query(
      `UPDATE users SET ${setClause} WHERE user_id = ?`,
      [...values, userID]
    );
    return result.affectedRows;
  },

  // deactivate employee
  deactivateUser: async (userID) => {
    const [result] = await db.query(
      `UPDATE users SET account_status = FALSE WHERE user_id = ?`,
      [userID]
    );
    return result.affectedRows;
  }

};

module.exports = User;