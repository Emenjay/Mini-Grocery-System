const Shift = require('../models/shiftModel');


// start user shift
exports.startShift = async (req, res) => {
  try {
    const userID = req.user.userID;
    const { startingCash } = req.body;

    // require userID
    if (!userID) {
      return res.status(400).json({ message: 'userID is required' });
    }

    // find user
    const user = await Shift.findUserByID(userID);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // if cashier user, require starting cash input
    if (user.Role === 'cashier' && startingCash === undefined) {
      return res.status(400).json({ message: 'startingCash is required for cashiers' });
    }

    // prevent double login for same user
    const activeShift = await Shift.findActiveShift(userID);
    if (activeShift) {
      return res.status(400).json({ message: 'User already has an active shift' });
    }

    // cashier passes startingCash, admin/inventory passes null
    const shiftID = await Shift.startShift(userID, user.Role === 'cashier' ? startingCash : null);

    // for checking values
    // console.log('Role:', user.Role);
    // console.log('startingCash:', startingCash);
    
    res.status(201).json({
      message: 'Shift started',
      shift: {
        shiftID,
        userID,
        role: user.Role,
        startingCash: user.Role === 'cashier' ? startingCash : null,
      }
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.endShift = async (req, res) => {
    try {
        const { userID, endingCash } = req.body;

        if (!userID || endingCash === undefined) {
            return res.status(400).json({ message: 'userID and endingCash are required'});
        }

        const activeShift = await Shift.findActiveShift(userID);
        if(!activeShift) {
            return res.status(400).json({ message: 'No active shift found for this user'});
        }

        // Calculate total sales from transactions made in this shift
        const totalSales = await Shift.calculateTotalSales(activeShift.ShiftID);

        await Shift.endShift(activeShift.ShiftID, endingCash, totalSales);

        res.status(200).json({
            message: 'Shift ended',
            shift: {
                shiftID: activeShift.ShiftID,
                userID,
                Time_In: activeShift.Time_In,
                endingCash,
                totalSales,
            }
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error'});
    }
}