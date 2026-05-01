const express                = require('express');
const router                 = express.Router();
const notificationController = require('../controllers/notificationController');
const protect = require('../middleware/authMiddleware');

//Protect all notification routes — only owners/admins should see these.
router.use(protect);

//GET    /api/notification               → list all (supports ?unread=true)
router.get('/',             notificationController.getAll);

//GET    /api/notification/unread-count  → badge count
router.get('/unread-count', notificationController.getUnreadCount);

//PATCH  /api/notification/read-all      → mark all read
router.patch('/read-all',   notificationController.markAllRead);

//PATCH  /api/notification/:id/read      → mark one read
router.patch('/:id/read',   notificationController.markOneRead);

//DELETE /api/notification/:id           → delete one
router.delete('/:id',       notificationController.deleteOne);

module.exports = router;