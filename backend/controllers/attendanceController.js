const Attendance = require('../models/attendanceModel');

exports.startShift = async (req, res) => {
  try {
    const userID = req.user.userID;
    const { cashIn } = req.body;
    const role = req.user.role;

    // check for abandoned shift from previous day
    const abandonedShift = await Attendance.findAbandonedShift(userID);
    if (abandonedShift) {
      console.warn(`User ${userID} has an abandoned shift from ${abandonedShift.date_time}`);
    }

    // check if already has active shift today
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

    // create cash_in transaction
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

    // find active shift
    const activeShift = await Attendance.findActiveShift(userID);
    if (!activeShift) {
      return res.status(400).json({ message: 'No active shift found' });
    }

    // cashier requires cashOut
    if (role === 'Cashier' && cashOut === undefined) {
      return res.status(400).json({ message: 'cashOut is required for cashiers' });
    }

    // create cash_out record and get its timestamp
    const cashOutTime = await Attendance.endCashOut(
      activeShift.transaction_id,
      userID,
      role === 'Cashier' ? cashOut : null
    );

    // calculate total sales between cash_in and cash_out timestamps
    const totalSales = role === 'Cashier'
      ? await Attendance.calculateTotalSales(userID, activeShift.date_time, cashOutTime)
      : null;

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


// returns the active shift for today if one exists, null otherwise
// Flutter uses this on cash-in screen load to skip straight to POS if shift is already running
exports.getActiveShift = async (req, res) => {
  try {
    const userID = req.user.userID;
 
    const activeShift = await Attendance.findActiveShift(userID);
 
    res.status(200).json({
      hasActiveShift: !!activeShift,
      // only include cashIn if an active shift exists, so PosScreen can restore startingCash
      cashIn: activeShift ? activeShift.cash_in : null,
    });
 
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};