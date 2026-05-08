const db = require('../config/db');
const Config = require('./configModel');

const Inventory = {

  createInventory: async (productID, stockQuantity, spoilageDate) => {
    // fetch isfastmoving for this product to calculate correct status
    const status = await calculateStockStatus(productID, stockQuantity);
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
      // use per-product isfastmoving to recalculate status
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

	// deduct stock after checkout, allows negative stock for force checkout
  deductStock: async (productID, quantity) => {
    // fetch isfastmoving to determine correct low stock threshold
    const [[product]] = await db.query(
      'SELECT isfastmoving FROM product WHERE product_id = ?',
      [productID]
    );
    const lowStockThreshold = product.isfastmoving ? 50 : 15;

    // deduct stock
    await db.query(
      `UPDATE inventory 
       SET stock_quantity = stock_quantity - ?,
           last_updated = NOW()
       WHERE product_id = ?`,
      [quantity, productID]
    );

    // fetch new quantity
    const [rows] = await db.query(
      'SELECT stock_quantity FROM inventory WHERE product_id = ?',
      [productID]
    );
    const newQuantity = rows[0].stock_quantity;

    // calculate new status using per-product threshold
    let newStatus;
    if (newQuantity <= 0) {
      newStatus = 'Out of Stock';
    } else if (newQuantity <= lowStockThreshold) {
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
  },

  // get inventory dashboard counts
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

// auto calculate stock status based on quantity
// fetches per-product isfastmoving
async function calculateStockStatus(productID, quantity) {
  const [[product]] = await db.query(
    'SELECT isfastmoving FROM product WHERE product_id = ?',
    [productID]
  );
  const lowStockThreshold = product.isfastmoving ? 50 : 15;
  if (quantity <= 0) return 'Out of Stock';
  if (quantity <= lowStockThreshold) return 'Low Stock';
  return 'In Stock';
}

module.exports = Inventory;