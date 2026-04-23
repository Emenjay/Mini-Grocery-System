const express = require('express');
const router = express.Router();
const protect = require('../middleware/authMiddleware');
const inventoryController = require('../controllers/inventoryController');

router.get('/dashboard', protect, inventoryController.getInventoryDashboard);

module.exports = router;