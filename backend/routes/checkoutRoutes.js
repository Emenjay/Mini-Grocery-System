const express = require('express');
const router = express.Router();
const protect = require('../middleware/authMiddleware');
const checkoutController = require('../controllers/checkoutController');

// transaction history
router.get('/', protect, checkoutController.getTransactionHistory);

// paused cart routes — must be before /:id
router.post('/pause', protect, checkoutController.pauseCart);
router.get('/paused', protect, checkoutController.getPausedCarts);
router.get('/paused/:id', protect, checkoutController.getPausedCartByID);
router.delete('/paused/:id', protect, checkoutController.discardPausedCart);

// checkout
router.post('/', protect, checkoutController.checkout);

// single transaction detail
router.get('/:id', checkoutController.getTransactionDetail);

module.exports = router;