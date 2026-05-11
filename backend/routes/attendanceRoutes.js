const express = require('express');
const router = express.Router();
const protect = require('../middleware/authMiddleware');
const attendanceController = require('../controllers/attendanceController');

// get active shift for the logged-in user (used by Flutter on cash-in screen load)
router.get('/active', protect, attendanceController.getActiveShift);

// start shift
router.post('/start', protect, attendanceController.startShift);

// end shift
router.post('/end', protect, attendanceController.endShift);

module.exports = router;