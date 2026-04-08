const express = require('express');
const router = express.Router();
const checkoutController = require('../controllers/checkoutModel');

// add new checkout record
router.post('/', checkoutController.checkout);

module.exports = router;