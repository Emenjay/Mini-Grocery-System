const db = require('../config/db');

//Data access layer for notifications.
const NotificationModel = {

  /**
   * Insert a new notification record.
   * @param {'LOW_STOCK'|'EXPIRED_PRODUCT'|'EMPLOYEE_LOGIN'|'EMPLOYEE_LOGOUT'} type
   * @param {string} title
   * @param {string} message
   * @param {number|null} referenceId  – ProductID or UserID
   */

  //Create a new notification.
  async create(type, title, message, referenceId = null) {
    const [result] = await db.query(
      `INSERT INTO Notification (Type, Title, Message, ReferenceID)
       VALUES (?, ?, ?, ?)`,
      [type, title, message, referenceId]
    );
    return result.insertId;
  },

  //Return all notifications ordered newest-first. 
  async findAll({ limit = 50, offset = 0 } = {}) {
    const [rows] = await db.query(
      `SELECT * FROM Notification
       ORDER BY CreatedAt DESC`
    );
    return rows;
  },

  //Return only unread notifications. 
  async findUnread() {
    const [rows] = await db.query(
      `SELECT * FROM Notification
       WHERE IsRead = 0
       ORDER BY CreatedAt DESC`
    );
    return rows;
  },

  //Count of unread notifications (for badge).
  async countUnread() {
    const [[row]] = await db.query(
      `SELECT COUNT(*) AS count FROM Notification WHERE IsRead = 0`
    );
    return row.count;
  },

  //Mark a single notification as read.
  async markOneRead(notificationId) {
    const [result] = await db.query(
      `UPDATE Notification SET IsRead = 1 WHERE NotificationID = ?`,
      [notificationId]
    );
    return result.affectedRows;
  },

  //Mark ALL notifications as read.
  async markAllRead() {
    const [result] = await db.query(
      `UPDATE Notification SET IsRead = 1 WHERE IsRead = 0`
    );
    return result.affectedRows;
  },

  //Delete a single notification.
  async deleteOne(notificationId) {
    const [result] = await db.query(
      `DELETE FROM Notification WHERE NotificationID = ?`,
      [notificationId]
    );
    return result.affectedRows;
  },
};

module.exports = NotificationModel;