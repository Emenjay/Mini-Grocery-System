const db = require('../config/db');

const InventoryLog = {
  addLog: async (productID, userID, action, quantityChange, remarks) => {
    await db.query(
      `INSERT INTO inventory_logs (ProductID, UserID, Action, QuantityChange, Remarks, LogDate)
       VALUES (?, ?, ?, ?, ?, NOW())`,
      [productID, userID, action, quantityChange, remarks || null]
    );
  }
};

module.exports = InventoryLog;