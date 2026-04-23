const express = require('express');
const router = express.Router();
const protect = require('../middleware/authMiddleware');
const dashboardController = require('../controllers/dashboardController');

router.get('/admin', protect, dashboardController.getAdminDashboard);

module.exports = router;