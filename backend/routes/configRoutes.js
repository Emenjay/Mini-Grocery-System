const express = require('express');
const router = express.Router();
const protect = require('../middleware/authMiddleware');
const configController = require('../controllers/configController');

// get all config values
router.get('/', protect, configController.getConfig);

// update a config value - admin only enforced on Flutter side
// ex: PATCH /api/config/default_markup
router.patch('/:key', protect, configController.updateConfig);

module.exports = router;