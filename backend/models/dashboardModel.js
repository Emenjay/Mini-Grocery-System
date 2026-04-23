const db = require('../config/db');

const Dashboard = {

  // daily total sales - sum of all sale transactions today
  getDailySales: async () => {
    const [[result]] = await db.query(
      `SELECT COALESCE(SUM(total_amount), 0) AS daily_sales
       FROM transaction
       WHERE transaction_type = 'sale'
       AND DATE(date_time) = CURDATE()`
    );
    return result.daily_sales;
  },

  // monthly total sales - sum of all sale transactions this month
  getMonthlySales: async () => {
    const [[result]] = await db.query(
      `SELECT COALESCE(SUM(total_amount), 0) AS monthly_sales
       FROM transaction
       WHERE transaction_type = 'sale'
       AND MONTH(date_time) = MONTH(NOW())
       AND YEAR(date_time) = YEAR(NOW())`
    );
    return result.monthly_sales;
  },

  // active shifts - list of users currently clocked in today
  getActiveShifts: async () => {
    const [rows] = await db.query(
      `SELECT 
        u.user_id, u.full_name, u.profile_picture,
        r.role_name,
        a.clock_in_timestamp
       FROM attendance a
       JOIN users u ON a.user_id = u.user_id
       JOIN role r ON u.role_id = r.role_id
       WHERE a.clock_out_timestamp IS NULL
       AND DATE(a.clock_in_timestamp) = CURDATE()`
    );
    return rows;
  }

};

module.exports = Dashboard;