const Attendance = require('../models/attendanceModel');

exports.startShift = async (req, res) => {
  try {
    const userID = req.user.userID;
    const { cashIn } = req.body;
    const role = req.user.role;

    // check for abandoned shift from previous day
    const abandonedShift = await Attendance.findAbandonedShift(userID);
    if (abandonedShift) {
      // flag it but don't block login — admin can review
      console.warn(`User ${userID} has an abandoned shift from ${abandonedShift.date_time}`);
    }

    // check if user already has active shift today
    const activeShift = await Attendance.findActiveShift(userID);
    if (activeShift) {
      return res.status(400).json({ message: 'Already has an active shift today' });
    }

    // cashier requires cashIn
    if (role === 'Cashier' && cashIn === undefined) {
      return res.status(400).json({ message: 'cashIn is required for cashiers' });
    }

    // clock in to attendance
    await Attendance.clockIn(userID);

    // create cash_in transaction (null for non-cashier)
    const transactionID = await Attendance.startCashIn(
      userID,
      role === 'Cashier' ? cashIn : null
    );

    res.status(201).json({
      message: 'Shift started',
      transactionID,
      cashIn: role === 'Cashier' ? cashIn : null
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.endShift = async (req, res) => {
  try {
    const userID = req.user.userID;
    const { cashOut } = req.body;
    const role = req.user.role;

    const activeShift = await Attendance.findActiveShift(userID);
    if (!activeShift) {
      return res.status(400).json({ message: 'No active shift found' });
    }

    // cashier requires cashOut
    if (role === 'Cashier' && cashOut === undefined) {
      return res.status(400).json({ message: 'cashOut is required for cashiers' });
    }

    // calculate total sales for cashier
    const totalSales = role === 'Cashier'
      ? await Attendance.calculateTotalSales(userID, activeShift.date_time, new Date())
      : null;

    // update cash_out on the cash_in record
    await Attendance.endCashOut(activeShift.transaction_id, role === 'Cashier' ? cashOut : null);

    // clock out attendance
    await Attendance.clockOut(userID);

    res.status(200).json({
      message: 'Shift ended',
      cashIn: activeShift.cash_in,
      cashOut: role === 'Cashier' ? cashOut : null,
      totalSales
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};