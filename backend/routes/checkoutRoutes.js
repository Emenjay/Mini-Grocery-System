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

// paused cart routes
router.post('/pause', protect, checkoutController.pauseCart);
router.get('/paused', protect, checkoutController.getPausedCarts);
router.get('/paused/:id', protect, checkoutController.getPausedCartByID);
router.delete('/paused/:id', protect, checkoutController.discardPausedCart);

module.exports = router;