const db = require('../config/db');
const NotificationModel = require('../models/notificationModel');

const LOW_STOCK_THRESHOLD = 15;
const EXPIRY_WARN_DAYS = 7;

// query for admin user_id dynamically
async function getAdminId() {
  const [[admin]] = await db.query(
    `SELECT u.user_id FROM users u
     JOIN role r ON u.role_id = r.role_id
     WHERE r.role_name = 'Admin'
     LIMIT 1`
  );
  return admin ? admin.user_id : null;
}

async function checkAndNotifyLowStock(productId) {
  const [[product]] = await db.query(
    `SELECT p.product_id, p.product_name, i.stock_quantity
     FROM product p
     JOIN inventory i ON p.product_id = i.product_id
     WHERE p.product_id = ?`,
    [productId]
  );
  if (!product || product.stock_quantity > LOW_STOCK_THRESHOLD) return;

  // avoid duplicate unread notifications for same product
  const [[existing]] = await db.query(
    `SELECT notification_id FROM notification
     WHERE type = 'LOW_STOCK' AND reference_id = ? AND is_read = 0 LIMIT 1`,
    [productId]
  );
  if (existing) return;

  const adminId = await getAdminId();
  if (!adminId) return;

  await NotificationModel.create(
    adminId,
    'LOW_STOCK',
    'Low Stock Alert',
    `"${product.product_name}" is running low — only ${product.stock_quantity} unit(s) left.`,
    productId
  );
}

async function checkAndNotifyExpiredProducts() {
  const [products] = await db.query(
    `SELECT p.product_id, p.product_name, i.spoilage_date
     FROM product p
     JOIN inventory i ON p.product_id = i.product_id
     WHERE i.spoilage_date IS NOT NULL
       AND i.spoilage_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY)`,
    [EXPIRY_WARN_DAYS]
  );

  const adminId = await getAdminId();
  if (!adminId) return;

  for (const product of products) {
    // avoid duplicate unread notifications for same product
    const [[existing]] = await db.query(
      `SELECT notification_id FROM notification
       WHERE type = 'EXPIRED_PRODUCT' AND reference_id = ? AND is_read = 0 LIMIT 1`,
      [product.product_id]
    );
    if (existing) continue;

    const expiry = new Date(product.spoilage_date);
    const diffDays = Math.ceil((expiry - new Date()) / (1000 * 60 * 60 * 24));

    await NotificationModel.create(
      adminId,
      'EXPIRED_PRODUCT',
      diffDays <= 0 ? 'Product Expired' : 'Product Expiring Soon',
      diffDays <= 0
        ? `"${product.product_name}" has already expired (${expiry.toDateString()}).`
        : `"${product.product_name}" expires in ${diffDays} day(s) on ${expiry.toDateString()}.`,
      product.product_id
    );
  }
}

async function notifyEmployeeLogin(userId, userName, startingCash, shiftId) {
  const adminId = await getAdminId();
  if (!adminId) return;

  await NotificationModel.create(
    adminId,
    'EMPLOYEE_LOGIN',
    'Employee Shift Started',
    `${userName} started a shift with ₱${Number(startingCash).toFixed(2)} starting cash. (Shift #${shiftId})`,
    userId
  );
}

async function notifyEmployeeLogout(userId, userName, totalSales, endingCash, shiftId) {
  const adminId = await getAdminId();
  if (!adminId) return;

  await NotificationModel.create(
    adminId,
    'EMPLOYEE_LOGOUT',
    'Employee Shift Ended',
    `${userName} ended shift #${shiftId}. Total Sales: ₱${Number(totalSales).toFixed(2)}, Ending Cash: ₱${Number(endingCash).toFixed(2)}.`,
    userId
  );
}

// GET /api/notification
exports.getAll = async (req, res) => {
  try {
    // delete notifications older than 7 days
    await db.query(
      `DELETE FROM notification WHERE created_at < DATE_SUB(NOW(), INTERVAL 7 DAY)`
    );
    // passively check for expired and low stock on every fetch
    await checkAndNotifyExpiredProducts();

    const [lowStockProducts] = await db.query(
      `SELECT p.product_id FROM product p
       JOIN inventory i ON p.product_id = i.product_id
       WHERE i.stock_quantity <= ?`,
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

// GET /api/notification/unread-count
exports.getUnreadCount = async (req, res) => {
  try {
    const count = await NotificationModel.countUnread();
    res.json({ success: true, unreadCount: count });
  } catch (err) {
    console.error('notificationController.getUnreadCount:', err);
    res.status(500).json({ success: false, message: 'Failed to fetch unread count.' });
  }
};

// PATCH /api/notification/:id/read
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

// PATCH /api/notification/read-all
exports.markAllRead = async (req, res) => {
  try {
    await NotificationModel.markAllRead();
    res.json({ success: true, message: 'All notifications marked as read.' });
  } catch (err) {
    console.error('notificationController.markAllRead:', err);
    res.status(500).json({ success: false, message: 'Failed to update notifications.' });
  }
};

// DELETE /api/notification/:id
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

// exported helpers for other controllers
exports.checkAndNotifyLowStock = checkAndNotifyLowStock;
exports.checkAndNotifyExpiredProducts = checkAndNotifyExpiredProducts;
exports.notifyEmployeeLogin = notifyEmployeeLogin;
exports.notifyEmployeeLogout = notifyEmployeeLogout;