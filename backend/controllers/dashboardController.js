const Dashboard = require('../models/dashboardModel');

exports.getAdminDashboard = async (req, res) => {
  try {
    // run all queries in parallel for faster response
    const [dailySales, monthlySales, activeShifts] = await Promise.all([
      Dashboard.getDailySales(),
      Dashboard.getMonthlySales(),
      Dashboard.getActiveShifts(),
    ]);

    res.status(200).json({
      message: 'Admin dashboard retrieved successfully',
      dashboard: {
        dailySales,
        monthlySales,
        activeShifts, // list of users currently on duty
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};