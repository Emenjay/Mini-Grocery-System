const express = require('express');
const router = express.Router();
const protect = require('../middleware/authMiddleware');
const checkoutController = require('../controllers/checkoutController');

router.post('/', protect, checkoutController.checkout);

module.exports = router;