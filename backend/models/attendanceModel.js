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

    // find open attendance record for today (used for login clockIn guard(no dups))
  findActiveAttendance: async (userID) => {
    const [rows] = await db.query(
      `SELECT * FROM attendance
      WHERE user_id = ?
      AND clock_out_timestamp IS NULL
      AND DATE(clock_in_timestamp) = CURDATE()`,
      [userID]
    );
    return rows[0];
  },

  // find any unclosed attendance from a previous day (for warning on login)
  findAbandonedAttendance: async (userID) => {
    const [rows] = await db.query(
      `SELECT * FROM attendance
      WHERE user_id = ?
      AND clock_out_timestamp IS NULL
      AND DATE(clock_in_timestamp) < CURDATE()`,
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

  // update clock out timestamp for today's attendance record
  clockOut: async (userID) => {
  const [result] = await db.query(
    `UPDATE attendance 
     SET clock_out_timestamp = NOW()
     WHERE user_id = ? AND clock_out_timestamp IS NULL
     AND DATE(clock_in_timestamp) = CURDATE()`,
    [userID]
  );
  return result.affectedRows;
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

  endCashOut: async (transactionID, userID, cashOut) => {
    // 1. update cash_out on the cash_in record
    await db.query(
      `UPDATE transaction
       SET cash_out = ?
       WHERE transaction_id = ?`,
      [cashOut, transactionID]
    );

    // 2. create a new cash_out record and return its timestamp
    const [result] = await db.query(
      `INSERT INTO transaction (user_id, cash_out, transaction_type, date_time)
       VALUES (?, ?, 'cash_out', NOW())`,
      [userID, cashOut]
    );

    // get the cash_out timestamp
    const [rows] = await db.query(
      `SELECT date_time FROM transaction WHERE transaction_id = ?`,
      [result.insertId]
    );
    return rows[0].date_time;
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