const db = require('../config/db');
const NotificationModel = require('../models/notificationModel');

const EXPIRY_WARN_DAYS = 7;

async function getAdminId() {
  const [[admin]] = await db.query(
    `SELECT u.user_id FROM users u
     JOIN role r ON u.role_id = r.role_id
     WHERE r.role_name = 'Admin'
     LIMIT 1`
  );
  return admin ? admin.user_id : null;
}

async function checkAndNotifyLowStock(productId, app) {
  const [[product]] = await db.query(
    `SELECT p.product_id, p.product_name, p.isfastmoving, i.stock_quantity
     FROM product p
     JOIN inventory i ON p.product_id = i.product_id
     WHERE p.product_id = ?`,
    [productId]
  );
  if (!product) return;

  // NULL threshold = no low-stock notifications for this product
  if (product.isfastmoving === null || product.isfastmoving === undefined) return;

  // per-product threshold: 0/false = 15, 1/true = 50
  const lowStockThreshold = product.isfastmoving ? 50 : 15;

  // only notify if stock is low but not yet zero (out-of-stock has its own notification)
  if (product.stock_quantity <= 0 || product.stock_quantity > lowStockThreshold) return;

  // avoid duplicate notifications for same product within 24h
  const [[existing]] = await db.query(
    `SELECT notification_id FROM notification
     WHERE type = 'LOW_STOCK' AND reference_id = ?
     AND created_at > DATE_SUB(NOW(), INTERVAL 24 HOUR) LIMIT 1`,
    [productId]
  );
  if (existing) return;

  const adminId = await getAdminId();
  if (!adminId) return;

  const notificationId = await NotificationModel.create(
    adminId, 'LOW_STOCK', 'Low Stock Alert',
    `"${product.product_name}" is running low — only ${product.stock_quantity} unit(s) left.`,
    productId
  );

  if (app) {
    pushToAdmins(app, {
      notification_id: notificationId,
      type: 'LOW_STOCK',
      title: 'Low Stock Alert',
      message: `"${product.product_name}" is running low — only ${product.stock_quantity} unit(s) left.`,
      is_read: false,
      created_at: new Date().toISOString(),
    });
  }
}

async function checkAndNotifyOutOfStock(productId, app) {
  const [[product]] = await db.query(
    `SELECT p.product_id, p.product_name, i.stock_quantity
     FROM product p
     JOIN inventory i ON p.product_id = i.product_id
     WHERE p.product_id = ?`,
    [productId]
  );
  if (!product || product.stock_quantity > 0) return;

  // avoid duplicate unread notifications for same product
  const [[existing]] = await db.query(
    `SELECT notification_id FROM notification
     WHERE type = 'OUT_OF_STOCK' AND reference_id = ?
     AND created_at > DATE_SUB(NOW(), INTERVAL 24 HOUR) LIMIT 1`,
    [productId]
  );
  if (existing) return;

  const adminId = await getAdminId();
  if (!adminId) return;

  const notificationId = await NotificationModel.create(
    adminId, 'OUT_OF_STOCK', 'Out of Stock Alert',
    `"${product.product_name}" has run out — restock needed.`,
    productId
  );

  // push real-time if app instance available
  if (app) {
    pushToAdmins(app, {
      notification_id: notificationId,
      type: 'OUT_OF_STOCK',
      title: 'Out of Stock Alert',
      message: `"${product.product_name}" has run out — restock needed.`,
      is_read: false,
      created_at: new Date().toISOString(),
    });
  }
}

async function checkAndNotifyExpiredProducts(app) {
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
    const [[existing]] = await db.query(
      `SELECT notification_id FROM notification
       WHERE type = 'EXPIRED_PRODUCT' AND reference_id = ?
       AND created_at > DATE_SUB(NOW(), INTERVAL 24 HOUR) LIMIT 1`,
      [product.product_id]
    );
    if (existing) continue;

    const expiry = new Date(product.spoilage_date);
    const diffDays = Math.ceil((expiry - new Date()) / (1000 * 60 * 60 * 24));
    const title   = diffDays <= 0 ? 'Product Expired' : 'Product Expiring Soon';
    const message = diffDays <= 0
      ? `"${product.product_name}" has already expired (${expiry.toDateString()}).`
      : `"${product.product_name}" expires in ${diffDays} day(s) on ${expiry.toDateString()}.`;

    const notificationId = await NotificationModel.create(
      adminId, 'EXPIRED_PRODUCT', title, message, product.product_id
    );

    if (app) {
      pushToAdmins(app, {
        notification_id: notificationId,
        type: 'EXPIRED_PRODUCT',
        title,
        message,
        is_read: false,
        created_at: new Date().toISOString(),
      });
    }
  }
}

async function notifyEmployeeLogin(userId, userName, startingCash, shiftId, app) {
  const adminId = await getAdminId();
  if (!adminId) return;
  const notificationId = await NotificationModel.create(
    adminId, 'EMPLOYEE_LOGIN', 'Employee Shift Started',
    `${userName} Has Logged In.`, userId
  );
  if (app) {
    pushToAdmins(app, {
      notification_id: notificationId, type: 'EMPLOYEE_LOGIN',
      title: 'Employee Shift Started', message: `${userName} Has Logged In.`,
      is_read: false, created_at: new Date().toISOString(),
    });
  }
}

async function notifyEmployeeLogout(userId, userName, totalSales, endingCash, shiftId, app) {
  const adminId = await getAdminId();
  if (!adminId) return;
  const notificationId = await NotificationModel.create(
    adminId, 'EMPLOYEE_LOGOUT', 'Employee Shift Ended',
    `${userName} Has Logged Out.`, userId
  );
  if (app) {
    pushToAdmins(app, {
      notification_id: notificationId, type: 'EMPLOYEE_LOGOUT',
      title: 'Employee Shift Ended', message: `${userName} Has Logged Out.`,
      is_read: false, created_at: new Date().toISOString(),
    });
  }
}

function pushToAdmins(app, notification) {
  const sseClients = app.get('sseClients');
  if (!sseClients) return;
  const payload = JSON.stringify(notification);
  for (const [userID, res] of sseClients.entries()) {
    try {
      res.write(`event: notification\ndata: ${payload}\n\n`);
    } catch (e) {
      sseClients.delete(userID);
    }
  }
}

// passive checks on every fetch
exports.getAll = async (req, res) => {
  try {
    await db.query(
      `DELETE FROM notification WHERE created_at < DATE_SUB(NOW(), INTERVAL 7 DAY)`
    );

    await checkAndNotifyExpiredProducts(req.app);

    // only check products that actually have a low-stock threshold (isfastmoving IS NOT NULL)
    const [lowStockProducts] = await db.query(
      `SELECT p.product_id, p.isfastmoving, i.stock_quantity
       FROM product p
       JOIN inventory i ON p.product_id = i.product_id
       WHERE p.isfastmoving IS NOT NULL
         AND i.stock_quantity > 0`
    );
    for (const p of lowStockProducts) {
      const threshold = p.isfastmoving ? 50 : 15;
      if (p.stock_quantity <= threshold) {
        await checkAndNotifyLowStock(p.product_id, req.app);
      }
    }

    const [outOfStockProducts] = await db.query(
      `SELECT p.product_id FROM product p
       JOIN inventory i ON p.product_id = i.product_id
       WHERE i.stock_quantity <= 0`
    );
    for (const p of outOfStockProducts) {
      await checkAndNotifyOutOfStock(p.product_id, req.app);
    }

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

exports.getUnreadCount = async (req, res) => {
  try {
    const count = await NotificationModel.countUnread();
    res.json({ success: true, unreadCount: count });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch unread count.' });
  }
};

exports.markOneRead = async (req, res) => {
  try {
    const affected = await NotificationModel.markOneRead(req.params.id);
    if (!affected) return res.status(404).json({ success: false, message: 'Notification not found.' });
    res.json({ success: true, message: 'Notification marked as read.' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to update notification.' });
  }
};

exports.markAllRead = async (req, res) => {
  try {
    await NotificationModel.markAllRead();
    res.json({ success: true, message: 'All notifications marked as read.' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to update notifications.' });
  }
};

exports.deleteOne = async (req, res) => {
  try {
    const affected = await NotificationModel.deleteOne(req.params.id);
    if (!affected) return res.status(404).json({ success: false, message: 'Notification not found.' });
    res.json({ success: true, message: 'Notification deleted.' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to delete notification.' });
  }
};

exports.stream = async (req, res) => {
  const { userID, role } = req.user;
  if (role !== 'Admin') {
    return res.status(403).json({ message: 'Only admin can subscribe to notifications' });
  }
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.flushHeaders();
  const sseClients = req.app.get('sseClients');
  sseClients.set(userID, res);
  const heartbeat = setInterval(() => {
    try { res.write('event: heartbeat\ndata: ping\n\n'); }
    catch (e) { clearInterval(heartbeat); sseClients.delete(userID); }
  }, 30000);
  req.on('close', () => { clearInterval(heartbeat); sseClients.delete(userID); });
};

exports.checkAndNotifyLowStock = checkAndNotifyLowStock;
exports.checkAndNotifyOutOfStock = checkAndNotifyOutOfStock;
exports.checkAndNotifyExpiredProducts = checkAndNotifyExpiredProducts;
exports.notifyEmployeeLogin = notifyEmployeeLogin;
exports.notifyEmployeeLogout = notifyEmployeeLogout;
exports.pushToAdmins = pushToAdmins;