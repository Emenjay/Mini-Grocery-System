const bcrypt = require('bcrypt');
const User = require('../models/userModel');
const fs = require('fs');
const path = require('path');
const db = require('../config/db');

// get all employees
// supports ?search=name and ?role=Cashier query params
exports.getAllUsers = async (req, res) => {
  try {
    const { search, role } = req.query;
    const users = await User.getAllUsers(search || '', role || '');

    res.status(200).json({
      message: 'Users retrieved successfully',
      users
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// get single employee by ID
// returns profile info + attendance history (or account info if admin)
exports.getUserByID = async (req, res) => {
  try {
    const { id } = req.params;

    const user = await User.findByID(id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // get attendance history for non-admin roles
    // for admin, Flutter can choose to show account info instead on the frontend
    const attendance = await User.getAttendanceHistory(id);

    res.status(200).json({
      message: 'User retrieved successfully',
      user,
      attendance // frontend shows this for staff, hides for admin
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// add new employee
// expects multipart/form-data because of optional image upload
exports.addUser = async (req, res) => {
  try {
    const { roleID, username, password, fullName, contactNumber, address } = req.body;

    // validate required fields
    if (!roleID || !username || !password || !fullName) {
      return res.status(400).json({ message: 'roleID, username, password, and fullName are required' });
    }

    // check if username is already taken
    const taken = await User.isUsernameTaken(username);
    if (taken) {
      return res.status(409).json({ message: 'Username already exists' });
    }

    // hash the password before storing
    const hashedPassword = await bcrypt.hash(password, 10);

    // if a file was uploaded, multer puts it in req.file
    // store relative path so it works on any machine after deployment
    const profilePicture = req.file ? `uploads/profiles/${req.file.filename}` : null;

    const userID = await User.addUser(
      roleID, username, hashedPassword, fullName,
      contactNumber, address, profilePicture
    );

    res.status(201).json({
      message: 'Employee added successfully',
      user: {
        userID,
        fullName,
        username,
        roleID,
        contactNumber: contactNumber || null,
        address: address || null,
        profilePicture
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// edit employee
// admin can edit everything, non-admin fields are a subset
exports.updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { fullName, contactNumber, address, username, password, roleID } = req.body;
    const requestingRole = req.user.role; // from JWT via authMiddleware

    // check employee exists
    const existing = await User.findByID(id);
    if (!existing) {
      return res.status(404).json({ message: 'User not found' });
    }

    // build fields object, all roles can edit
    const fields = {};
    if (fullName !== undefined) fields['full_name'] = fullName;
    if (contactNumber !== undefined) fields['contact_number'] = contactNumber;
    if (address !== undefined) fields['address'] = address;

    // handle new profile picture if uploaded
    if (req.file) {
      // delete the old picture file from disk to free up space
      if (existing.profile_picture) {
        const oldPath = path.join(__dirname, '..', existing.profile_picture);
        if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
      }
      fields['profile_picture'] = `uploads/profiles/${req.file.filename}`;
    }

    // admin only fields: username, password, role
    if (requestingRole === 'Admin') {
      if (username !== undefined) {
        // make sure new username isn't taken
        const taken = await User.isUsernameTaken(username, id);
        if (taken) {
          return res.status(409).json({ message: 'Username already exists' });
        }
        fields['username'] = username;
      }
      if (password !== undefined) {
        // hash new password before updating
        fields['password'] = await bcrypt.hash(password, 10);
      }
      if (roleID !== undefined) fields['role_id'] = roleID;
    }

    if (Object.keys(fields).length === 0) {
      return res.status(400).json({ message: 'No fields provided to update' });
    }

    await User.updateUser(id, fields);

    res.status(200).json({ message: 'Employee updated successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// deactivate employee
exports.deactivateUser = async (req, res) => {
  try {
    const { id } = req.params;

    const user = await User.findByID(id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // prevent admin from deactivating themselves
    if (parseInt(id) === req.user.userID) {
      return res.status(400).json({ message: 'You cannot deactivate your own account' });
    }

    await User.deactivateUser(id);

    res.status(200).json({ message: 'Employee deactivated successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// returns all roles for frontend dropdowns
exports.getRoles = async (req, res) => {
  try {
    const [roles] = await db.query(
      // exclude Admin role - staff cannot be assigned admin through this form
      `SELECT role_id, role_name FROM role WHERE role_name != 'Admin' ORDER BY role_name ASC`
    );
    res.status(200).json({ message: 'Roles retrieved successfully', roles });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};