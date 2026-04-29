const express = require('express');
const router = express.Router();
const protect = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');
const userController = require('../controllers/userController');

// get all employees, supports ?search=name&role=Cashier
router.get('/', protect, userController.getAllUsers);

// get single employee + attendance history
router.get('/:id', protect, userController.getUserByID);

// add new employee
router.post('/', protect, upload.single('profilePicture'), userController.addUser);

// edit employee
router.put('/:id', protect, upload.single('profilePicture'), userController.updateUser);

// deactivate employee
router.patch('/:id/deactivate', protect, userController.deactivateUser);

module.exports = router;