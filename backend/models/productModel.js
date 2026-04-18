const db = require('../config/db');

const Product = {
  // get all products / search product
  getAllProducts: async (search = '') => {
    const keyword = `%${search}%`; // % wildcards allow partial matching e.g. "oca" matches "Coca Cola"
    const [rows] = await db.query(
      `SELECT p.product_id, p.product_name, c.category_name,
              p.description, p.markup_price, p.unit_measurement,
              i.stock_quantity, i.spoilage_date, i.stock_status, i.last_updated
       FROM product p
       JOIN category c ON p.category_id = c.category_id
       LEFT JOIN inventory i ON p.product_id = i.product_id
       WHERE p.product_name LIKE ? OR c.category_name LIKE ?`,
      [keyword, keyword]
    );
    return rows;
  },

  // find product by id
  findProductByID: async (productID) => {
    const [rows] = await db.query(
      `SELECT p.*, i.inventory_id, i.stock_quantity, i.spoilage_date, i.stock_status
       FROM product p
       LEFT JOIN inventory i ON p.product_id = i.product_id
       WHERE p.product_id = ?`,
      [productID]
    );
    return rows[0];
  },

  // add new product
  addProduct: async (categoryID, productName, description, markupPrice, unitMeasurement) => {
    const [result] = await db.query(
      `INSERT INTO product (category_id, product_name, description, markup_price, unit_measurement)
       VALUES (?, ?, ?, ?, ?)`,
      [categoryID, productName, description || null, markupPrice, unitMeasurement || null]
    );
    return result.insertId;
  },

  // edit product details
  updateProduct: async (productID, fields) => {
    const allowedFields = ['product_name', 'category_id', 'description', 'markup_price', 'unit_measurement'];
    const keys = Object.keys(fields).filter(k => allowedFields.includes(k));
    if (keys.length === 0) return 0;

    const values = keys.map(k => fields[k]);
    const setClause = keys.map(k => `${k} = ?`).join(', ');

    const [result] = await db.query(
      `UPDATE product SET ${setClause} WHERE product_id = ?`,
      [...values, productID]
    );
    return result.affectedRows;
  },

  // delete product
  deleteProduct: async (productID) => {

    // delete inventory record first due to foreign key constraint
    await db.query('DELETE FROM inventory WHERE product_id = ?', [productID]);
    
    // then delete product
    const [result] = await db.query(
      'DELETE FROM product WHERE product_id = ?',
      [productID]
    );
    return result.affectedRows;
  }
};

module.exports = Product;