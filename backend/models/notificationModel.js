const db = require('../config/db');

const NotificationModel = {

  // insert a new notification
  async create(userId, type, title, message, referenceId = null) {
    const [result] = await db.query(
      `INSERT INTO notification (UserID, Type, Title, Message, ReferenceID, IsRead, CreatedAt)
       VALUES (?, ?, ?, ?, ?, FALSE, NOW())`,
      [userId, type, title, message, referenceId]
    );
    return result.insertId;
  },

  // return all notifications ordered newest-first
  async findAll({ limit = 50, offset = 0 } = {}) {
    
    const [rows] = await db.query(
      `SELECT * FROM notification
       ORDER BY CreatedAt DESC
       LIMIT ? OFFSET ?`,
      [limit, offset]
    );
    return rows;
  },

  // return only unread notifications
  async findUnread() {
    const [rows] = await db.query(
      `SELECT * FROM notification
       WHERE IsRead = 0
       ORDER BY CreatedAt DESC`
    );
    return rows;
  },

  // count unread notifications
  async countUnread() {
    const [[row]] = await db.query(
      `SELECT COUNT(*) AS count FROM notification WHERE IsRead = 0`
    );
    return row.count;
  },

  // mark a single notification as read
  async markOneRead(notificationId) {
    const [result] = await db.query(
      `UPDATE notification SET IsRead = 1 WHERE NotificationID = ?`,
      [notificationId]
    );
    return result.affectedRows;
  },

  // mark all notifications as read
  async markAllRead() {
    const [result] = await db.query(
      `UPDATE notification SET IsRead = 1 WHERE IsRead = 0`
    );
    return result.affectedRows;
  },

  // delete a single notification
  async deleteOne(notificationId) {
    const [result] = await db.query(
      `DELETE FROM notification WHERE NotificationID = ?`,
      [notificationId]
    );
    return result.affectedRows;
  },
};

module.exports = NotificationModel;