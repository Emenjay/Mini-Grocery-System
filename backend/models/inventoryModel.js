const db = require('../config/db');
const Config = require('./configModel');

const Inventory = {

  createInventory: async (productID, stockQuantity, spoilageDate) => {
    const status = await calculateStockStatus(productID, stockQuantity);
    const [result] = await db.query(
      `INSERT INTO inventory (product_id, stock_quantity, spoilage_date, stock_status, last_updated)
       VALUES (?, ?, ?, ?, NOW())`,
      [productID, stockQuantity, spoilageDate || null, status]
    );
    return result.insertId;
  },

  updateInventory: async (productID, fields) => {
    const allowedFields = ['stock_quantity', 'spoilage_date'];
    const keys = Object.keys(fields).filter(k => allowedFields.includes(k));
    if (keys.length === 0) return 0;
    
		// recalculate stock_status if stock_quantity is being updated
    if (fields.stock_quantity !== undefined) {
      fields.stock_status = await calculateStockStatus(productID, fields.stock_quantity);
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

  deductStock: async (productID, quantity) => {
    const [[product]] = await db.query(
      'SELECT isfastmoving FROM product WHERE product_id = ?',
      [productID]
    );

    // isfastmoving: NULL = no threshold, false/0 = Normal(15), true/1 = Fast(50)
    const isfastmoving = product.isfastmoving;

    // fetch current stock before deducting
    const [[before]] = await db.query(
      'SELECT stock_quantity FROM inventory WHERE product_id = ?',
      [productID]
    );
    const currentStock = before.stock_quantity;

    // calculate how much to actually deduct - never go below 0
    const actualDeduct = Math.min(quantity, currentStock);

    await db.query(
      `UPDATE inventory 
       SET stock_quantity = stock_quantity - ?,
           last_updated = NOW()
       WHERE product_id = ?`,
      [actualDeduct, productID]
    );

    // fetch new quantity after deduction
    const [[after]] = await db.query(
      'SELECT stock_quantity FROM inventory WHERE product_id = ?',
      [productID]
    );
    const newQuantity = after.stock_quantity;

    // calculate status based on per-product threshold
    let newStatus;
    if (newQuantity <= 0) {
      newStatus = 'Out of Stock';
    } else if (isfastmoving === null || isfastmoving === undefined) {
      // NULL threshold - no Low Stock state, goes straight to In Stock
      newStatus = 'In Stock';
    } else {
      const lowStockThreshold = isfastmoving ? 50 : 15;
      newStatus = newQuantity <= lowStockThreshold ? 'Low Stock' : 'In Stock';
    }

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
  },

  getDashboardCounts: async () => {
    const [[productCount]] = await db.query(
      'SELECT COUNT(*) AS total_products FROM product'
    );
    const [[lowStockCount]] = await db.query(
      "SELECT COUNT(*) AS low_stock FROM inventory WHERE stock_status = 'Low Stock'"
    );
    const [[outOfStockCount]] = await db.query(
      "SELECT COUNT(*) AS out_of_stock FROM inventory WHERE stock_status = 'Out of Stock'"
    );
    const [[expiredCount]] = await db.query(
      'SELECT COUNT(*) AS expired FROM inventory WHERE spoilage_date < CURDATE()'
    );
    return {
      totalProducts: productCount.total_products,
      lowStock: lowStockCount.low_stock,
      outOfStock: outOfStockCount.out_of_stock,
      expired: expiredCount.expired
    };
  }
};

// NULL isfastmoving = no Low Stock state (skips straight to Out of Stock)
// 0/false = Normal threshold (15)
// 1/true  = Fast threshold (50)
async function calculateStockStatus(productID, quantity) {
  const [[product]] = await db.query(
    'SELECT isfastmoving FROM product WHERE product_id = ?',
    [productID]
  );
  const isfastmoving = product.isfastmoving;

  if (quantity <= 0) return 'Out of Stock';

  // NULL threshold - no Low Stock, anything above 0 is In Stock
  if (isfastmoving === null || isfastmoving === undefined) return 'In Stock';

  const lowStockThreshold = isfastmoving ? 50 : 15;
  if (quantity <= lowStockThreshold) return 'Low Stock';
  return 'In Stock';
}

module.exports = Inventory;