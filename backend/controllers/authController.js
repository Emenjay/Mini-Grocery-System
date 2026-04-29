const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');
const Attendance = require('../models/attendanceModel');
const PausedCart = require('../models/pausedCartModel');

// login authentication
exports.login = async (req, res) => {
  try {
    const { username, password } = req.body;
    
    // check if fields are provided
    if (!username || !password) {
        return res.status(400).json({ message: 'Username and password are required'});
    }

    // find user in db
    const user = await User.findByUsername(username);

    // check if username matches
    if (!user) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }

    // check if account is active
    if (!user.account_status) {
      return res.status(403).json({ message: 'Account is disabled' });
    }

    // check if password matches
    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }

     // check for abandoned shift from a previous day and warn, but leave it open
    const abandonedShift = await Attendance.findAbandonedAttendance(user.user_id);
    if (abandonedShift) {
      console.warn(`User ${user.user_id} has an abandoned attendance record from ${abandonedShift.clock_in_timestamp}`);
    }

    // only clock in if not already clocked in today (prevents duplicate rows on re-login)
    const alreadyClockedIn = await Attendance.findActiveAttendance(user.user_id);
    if (!alreadyClockedIn) {
      await Attendance.clockIn(user.user_id);
    }

    // generate token
    const token = jwt.sign(
      { userID: user.user_id, role: user.role_name },
      process.env.JWT_SECRET,
      { expiresIn: '12h' } // token expires after 13 hours
    );

    // if all previous condtions passed, login success
    res.status(200).json({
      message: 'Login successful',
      token,
      user: {
        id: user.user_id,
        fullName: user.full_name,
        username: user.username,
        role: user.role_name,
      }
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// clock out on logout
exports.logout = async (req, res) => {
  try {
    const userID = req.user.userID; // from JWT

    const activeAttendance = await Attendance.findActiveAttendance(userID);
    if (!activeAttendance) {
      return res.status(400).json({ message: 'No active attendance found' });
    }

    // silently delete all paused carts on logout
    await PausedCart.deleteAllPausedCarts(userID);

    await Attendance.clockOut(userID);

    res.status(200).json({ message: 'Logged out successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};