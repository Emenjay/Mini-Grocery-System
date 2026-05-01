//Russ's update: handle notifications for low stock, expired products, and employee login/logout events. 
const db                = require('../config/db');
const NotificationModel = require('../models/notificationModel');

//Thresholds (adjust to your business rules)
const LOW_STOCK_THRESHOLD = 5;  // units
const EXPIRY_WARN_DAYS    = 7;  // days before expiry to warn

//Internal helpers to check conditions and create notifications
async function checkAndNotifyLowStock(productId) {
  const [[product]] = await db.query(
    `SELECT product_id, product_name, stock_level FROM product WHERE product_id = ?`,
    [productId]
  );
  if (!product || product.stock_level > LOW_STOCK_THRESHOLD) return;

  const [[existing]] = await db.query(
    `SELECT NotificationID FROM Notification
     WHERE Type = 'LOW_STOCK' AND ReferenceID = ? AND IsRead = 0 LIMIT 1`,
    [productId]
  );
  if (existing) return;

  await NotificationModel.create(
    'LOW_STOCK',
    'Low Stock Alert',
    `"${product.product_name}" is running low — only ${product.stock_level} unit(s) left.`,
    productId
  );
}

// Checks for products nearing expiry and creates notifications if needed. 
async function checkAndNotifyExpiredProducts() {
  const [products] = await db.query(
    `SELECT product_id, product_name, ExpirationDate
     FROM product
     WHERE ExpirationDate IS NOT NULL
       AND ExpirationDate <= DATE_ADD(CURDATE(), INTERVAL ? DAY)`,
    [EXPIRY_WARN_DAYS]
  );

  for (const product of products) {
    const [[existing]] = await db.query(
      `SELECT NotificationID FROM Notification
       WHERE Type = 'EXPIRED_PRODUCT' AND ReferenceID = ? AND IsRead = 0 LIMIT 1`,
      [product.product_id]
    );
    if (existing) continue;

    const expiry   = new Date(product.ExpirationDate);
    const diffDays = Math.ceil((expiry - new Date()) / (1000 * 60 * 60 * 24));

    await NotificationModel.create(
      'EXPIRED_PRODUCT',
      diffDays <= 0 ? 'Product Expired' : 'Product Expiring Soon',
      diffDays <= 0
        ? `"${product.product_name}" has already expired (${expiry.toDateString()}).`
        : `"${product.product_name}" expires in ${diffDays} day(s) on ${expiry.toDateString()}.`,
      product.product_id
    );
  }
}

//login/logout notifications for employee shifts
async function notifyEmployeeLogin(userId, userName, startingCash, shiftId) {
  await NotificationModel.create(
    'EMPLOYEE_LOGIN',
    'Employee Shift Started',
    `${userName} started a shift with ₱${Number(startingCash).toFixed(2)} starting cash. (Shift #${shiftId})`,
    userId
  );
}

async function notifyEmployeeLogout(userId, userName, totalSales, endingCash, shiftId) {
  await NotificationModel.create(
    'EMPLOYEE_LOGOUT',
    'Employee Shift Ended',
    `${userName} ended shift #${shiftId}. Total Sales: ₱${Number(totalSales).toFixed(2)}, Ending Cash: ₱${Number(endingCash).toFixed(2)}.`,
    userId
  );
}

//HTTP handlers for the API routes
// GET /api/notifications  (?unread=true, ?limit=N, ?offset=M)
// Automatically runs expiry + low-stock checks on every fetch.
exports.getAll = async (req, res) => {
  try {
    // Run checks passively on every fetch — no cron needed
    await checkAndNotifyExpiredProducts();
    const [lowStockProducts] = await db.query(
      `SELECT product_id FROM product WHERE stock_level <= ?`,
      [LOW_STOCK_THRESHOLD]
    );
    for (const p of lowStockProducts) await checkAndNotifyLowStock(p.product_id);

    const { unread, limit = 50, offset = 0 } = req.query;
    const notifications = unread === 'true'
      ? await NotificationModel.findUnread()
      : await NotificationModel.findAll({ limit: parseInt(limit), offset: parseInt(offset) });
    const unreadCount = await NotificationModel.countUnread();

    res.json({ success: true, unreadCount, notifications });
  } catch (err) {
    console.error('notificationController.getAll:', err);
    res.status(500).json({ success: false, message: 'Failed to fetch notifications.' });
  }
};

//GET /api/notifications/unread-count
exports.getUnreadCount = async (req, res) => {
  try {
    const count = await NotificationModel.countUnread();
    res.json({ success: true, unreadCount: count });
  } catch (err) {
    console.error('notificationController.getUnreadCount:', err);
    res.status(500).json({ success: false, message: 'Failed to fetch unread count.' });
  }
};

//PATCH /api/notifications/:id/read
exports.markOneRead = async (req, res) => {
  try {
    const affected = await NotificationModel.markOneRead(req.params.id);
    if (!affected) return res.status(404).json({ success: false, message: 'Notification not found.' });
    res.json({ success: true, message: 'Notification marked as read.' });
  } catch (err) {
    console.error('notificationController.markOneRead:', err);
    res.status(500).json({ success: false, message: 'Failed to update notification.' });
  }
};

//PATCH /api/notifications/read-all
exports.markAllRead = async (req, res) => {
  try {
    await NotificationModel.markAllRead();
    res.json({ success: true, message: 'All notifications marked as read.' });
  } catch (err) {
    console.error('notificationController.markAllRead:', err);
    res.status(500).json({ success: false, message: 'Failed to update notifications.' });
  }
};

//DELETE /api/notifications/:id
exports.deleteOne = async (req, res) => {
  try {
    const affected = await NotificationModel.deleteOne(req.params.id);
    if (!affected) return res.status(404).json({ success: false, message: 'Notification not found.' });
    res.json({ success: true, message: 'Notification deleted.' });
  } catch (err) {
    console.error('notificationController.deleteOne:', err);
    res.status(500).json({ success: false, message: 'Failed to delete notification.' });
  }
};

//Exported helpers for other controllers 
exports.checkAndNotifyLowStock        = checkAndNotifyLowStock;
exports.checkAndNotifyExpiredProducts = checkAndNotifyExpiredProducts;
exports.notifyEmployeeLogin           = notifyEmployeeLogin;
exports.notifyEmployeeLogout          = notifyEmployeeLogout;