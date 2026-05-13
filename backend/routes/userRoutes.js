const express = require('express');
const router = express.Router();
const protect = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');
const userController = require('../controllers/userController');

// get all employees, supports ?search=name&role=Cashier
router.get('/', protect, userController.getAllUsers);

// GET /api/users/roles - fetch all roles for add staff dropdown
router.get('/roles', protect, userController.getRoles);

// get single employee + attendance history
router.get('/:id', protect, userController.getUserByID);

// add new employee
router.post('/', protect, upload.single('profilePicture'), userController.addUser);

// edit employee
router.put('/:id', protect, upload.single('profilePicture'), userController.updateUser);

// deactivate employee
router.patch('/:id/deactivate', protect, userController.deactivateUser);

// toggle duty status (clock in/out)
router.post('/:id/toggle-duty', protect, userController.toggleDuty);

module.exports = router;