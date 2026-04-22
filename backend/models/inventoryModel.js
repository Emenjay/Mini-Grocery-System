const db = require('../config/db');
const Config = require('./configModel');

const Inventory = {

  createInventory: async (productID, stockQuantity, spoilageDate) => {
    const status = await calculateStockStatus(stockQuantity);
    const [result] = await db.query(
      `INSERT INTO inventory (product_id, stock_quantity, spoilage_date, stock_status, last_updated)
       VALUES (?, ?, ?, ?, NOW())`,
      [productID, stockQuantity, spoilageDate || null, status]
    );
    return result.insertId;
  },

	// update inventory
  updateInventory: async (productID, fields) => {
    const allowedFields = ['stock_quantity', 'spoilage_date'];
    const keys = Object.keys(fields).filter(k => allowedFields.includes(k));
    if (keys.length === 0) return 0;

		// recalculate stock_status if stock_quantity is being updated
    if (fields.stock_quantity !== undefined) {
      // fetch low stock standard from config dynamically
      fields.stock_status = await calculateStockStatus(fields.stock_quantity);
      keys.push('stock_status');
    }

    const values = keys.map(k => fields[k]);
    const setClause = keys.map(k => `${k} = ?`).join(', ');

    const [result] = await db.query(
      `UPDATE inventory SET ${setClause}, last_updated = NOW() WHERE product_id = ?`,
      [...values, productID]
    );
    return result.affectedRows;
  },


	// deduct stock after checkout, allows negative stock for force checkout
  deductStock: async (productID, quantity) => {
  
  // fetch low stock standard from config
  const lowStockStandard = parseInt(await Config.get('low_stock_standard'));

  // first deduct the stock
  await db.query(
    `UPDATE inventory 
     SET stock_quantity = stock_quantity - ?,
         last_updated = NOW()
     WHERE product_id = ?`,
    [quantity, productID]
  );

  // fetch the new stock quantity
  const [rows] = await db.query(
    'SELECT stock_quantity FROM inventory WHERE product_id = ?',
    [productID]
  );
  const newQuantity = rows[0].stock_quantity;

  // calculate status
  let newStatus;
  if (newQuantity <= 0) {
    newStatus = 'Out of Stock';
  } else if (newQuantity <= lowStockStandard) {
    newStatus = 'Low Stock';
  } else {
    newStatus = 'In Stock';
  }

  // update status
  const [result] = await db.query(
    `UPDATE inventory SET stock_status = ? WHERE product_id = ?`,
    [newStatus, productID]
  );

  return result.affectedRows;
},

  getByProductID: async (productID) => {
    const [rows] = await db.query(
      'SELECT * FROM inventory WHERE product_id = ?',
      [productID]
    );
    return rows[0];
  }

};

// auto calculate stock status based on quantity
// fetches low_stock_standard from config table
async function calculateStockStatus(quantity) {
  const lowStockStandard = parseInt(await Config.get('low_stock_standard'));
  if (quantity <= 0) return 'Out of Stock';
  if (quantity <= lowStockStandard) return 'Low Stock';
  return 'In Stock';
}

module.exports = Inventory;