const express = require('express');
const router = express.Router();
const protect = require('../middleware/authMiddleware');
const checkoutController = require('../controllers/checkoutController');

//single transaction for receipt
router.get('/:id', checkoutController.getTransactionDetail);

//Russ's update: added getTransactionHistory function
router.get('/', protect, checkoutController.getTransactionHistory);

//checkout route
router.post('/', protect, checkoutController.checkout);

module.exports = router;