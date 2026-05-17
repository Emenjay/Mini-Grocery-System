const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');
const Attendance = require('../models/attendanceModel');
const PausedCart = require('../models/pausedCartModel');
const { notifyEmployeeLogin, notifyEmployeeLogout } = require('./notificationController');

// login authentication
exports.login = async (req, res) => {
  try {
    const { username, password } = req.body;

    // check if fields are provided
    if (!username || !password) {
      return res.status(400).json({ message: 'Username and password are required' });
    }

    // find user in db
    const user = await User.findByUsername(username);

    // check if username matches
    if (!user) {
      return res.status(401).json({ message: 'Invalid username or password:' });
    }

    // check if account is active
    if (user.account_status === 0 || user.account_status === false || user.account_status === '0') {
      return res.status(403).json({ message: 'Account is disabled:' });
    }

    // check if password matches
    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.status(401).json({ message: 'Invalid username or password:' });
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

    // notify admin that employee logged in
    // use user.full_name (from DB), user.user_id as shiftId placeholder, pass req.app for SSE push
    await notifyEmployeeLogin(user.user_id, user.full_name, 0, user.user_id, req.app);

    // generate token - include username and fullName so Flutter can display them
    const token = jwt.sign(
      { userID: user.user_id, role: user.role_name, username: user.username, fullName: user.full_name },
      process.env.JWT_SECRET,
      { expiresIn: '12h' }
    );

    // if all previous conditions passed, login success
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
    // fullName is now in the JWT payload so we can use it here without a DB query
    const fullName = req.user.fullName || 'Unknown User';

    const activeAttendance = await Attendance.findActiveAttendance(userID);
    if (!activeAttendance) {
      return res.status(400).json({ message: 'No active attendance found' });
    }

    // silently delete all paused carts on logout
    await PausedCart.deleteAllPausedCarts(userID);

    await Attendance.clockOut(userID);

    // notify admin that employee logged out, pass req.app for SSE push
    await notifyEmployeeLogout(userID, fullName, 0, 0, userID, req.app);

    res.status(200).json({ message: 'Logged out successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};