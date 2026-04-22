const db = require('../config/db');
const Config = require('./configModel');

const Product = {

  // get all products, also returns computed retail_price
  getAllProducts: async (search = '') => {
    const keyword = `%${search}%`;
    const [rows] = await db.query(
      `SELECT p.product_id, p.product_name, c.category_name,
              p.description, p.base_price, p.markup_price,
              -- retail price computed on the backend for reference
              (p.base_price + p.markup_price) AS retail_price,
              p.unit_measurement,
              i.stock_quantity, i.spoilage_date, i.stock_status, i.last_updated
       FROM product p
       JOIN category c ON p.category_id = c.category_id
       LEFT JOIN inventory i ON p.product_id = i.product_id
       WHERE p.product_name LIKE ? OR c.category_name LIKE ?`,
      [keyword, keyword]
    );
    return rows;
  },

  // find product by id, also returns retail_price
  findProductByID: async (productID) => {
    const [rows] = await db.query(
      `SELECT p.*, 
              (p.base_price + p.markup_price) AS retail_price,
              i.inventory_id, i.stock_quantity, i.spoilage_date, i.stock_status
       FROM product p
       LEFT JOIN inventory i ON p.product_id = i.product_id
       WHERE p.product_id = ?`,
      [productID]
    );
    return rows[0];
  },

  // add new product, markup_price defaults to global default_markup from config
  addProduct: async (categoryID, productName, description, basePrice, unitMeasurement) => {
    // fetch default markup from config table
    const defaultMarkup = await Config.get('default_markup');

    const [result] = await db.query(
      `INSERT INTO product (category_id, product_name, description, base_price, markup_price, unit_measurement)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [categoryID, productName, description || null, basePrice, defaultMarkup, unitMeasurement || null]
    );
    return result.insertId;
  },

  // update product, markup_price now editable only by admin (enforced in controller)
  updateProduct: async (productID, fields) => {
    const allowedFields = ['product_name', 'category_id', 'description', 'base_price', 'markup_price', 'unit_measurement'];
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
    // delete inventory record first
    await db.query('DELETE FROM inventory WHERE product_id = ?', [productID]);
    // then delete product
    const [result] = await db.query('DELETE FROM product WHERE product_id = ?', [productID]);
    return result.affectedRows;
  }

};

module.exports = Product;