const db = require('../config/db');

const Attendance = {

  // find unclosed cash_in for today only
  findActiveShift: async (userID) => {
    const [rows] = await db.query(
      `SELECT * FROM transaction
       WHERE user_id = ?
       AND transaction_type = 'cash_in'
       AND cash_out IS NULL
       AND DATE(date_time) = CURDATE()`,
      [userID]
    );
    return rows[0];
  },

  // find any unclosed cash_in from a previous day (for admin flagging)
  findAbandonedShift: async (userID) => {
    const [rows] = await db.query(
      `SELECT * FROM transaction
       WHERE user_id = ?
       AND transaction_type = 'cash_in'
       AND cash_out IS NULL
       AND DATE(date_time) < CURDATE()`,
      [userID]
    );
    return rows[0];
  },

  // create clock in record in attendance table
  clockIn: async (userID) => {
    const [result] = await db.query(
      `INSERT INTO attendance (user_id, clock_in_timestamp)
       VALUES (?, NOW())`,
      [userID]
    );
    return result.insertId;
  },

  // create cash_in transaction record
  startCashIn: async (userID, cashIn) => {
    const [result] = await db.query(
      `INSERT INTO transaction (user_id, cash_in, transaction_type, date_time)
       VALUES (?, ?, 'cash_in', NOW())`,
      [userID, cashIn]
    );
    return result.insertId;
  },

  // update cash_out on the existing cash_in record
  endCashOut: async (transactionID, cashOut) => {
    await db.query(
      `UPDATE transaction
       SET cash_out = ?, transaction_type = 'cash_out'
       WHERE transaction_id = ?`,
      [cashOut, transactionID]
    );
  },

  // clock out in attendance table
  clockOut: async (userID) => {
    await db.query(
      `UPDATE attendance
       SET clock_out_timestamp = NOW()
       WHERE user_id = ?
       AND clock_out_timestamp IS NULL`,
      [userID]
    );
  },

  // calculate total sales between cash_in and cash_out timestamps
  calculateTotalSales: async (userID, cashInTime, cashOutTime) => {
    const [rows] = await db.query(
      `SELECT COALESCE(SUM(total_amount), 0) AS total_sales
       FROM transaction
       WHERE user_id = ?
       AND transaction_type = 'sale'
       AND date_time BETWEEN ? AND ?`,
      [userID, cashInTime, cashOutTime]
    );
    return rows[0].total_sales;
  }
};

module.exports = Attendance;