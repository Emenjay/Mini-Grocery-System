const express = require('express');
const router = express.Router();
const shiftController = require('../controllers/shiftController');

// start shift
router.post('/start', shiftController.startShift);

// end shift
router.post('/end', shiftController.endShift);

module.exports = router;