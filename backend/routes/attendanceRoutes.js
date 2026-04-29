const express = require('express');
const router = express.Router();
const protect = require('../middleware/authMiddleware');
const attendanceController = require('../controllers/attendanceController');

// start shift
router.post('/start', protect, attendanceController.startShift);

// end shift
router.post('/end', protect, attendanceController.endShift);

module.exports = router;