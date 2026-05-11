const db = require('../config/db');
const Config = require('./configModel');

const Product = {

  getAllProducts: async (search = '', category = '', stockStatus = '', expirationFilter = '', sortName = '', sortPrice = '', page = 1, limit = 20, all = false, recentlyAdded = false, isApprovedOnly = false) => {
  const keyword = `%${search}%`;
  const offset = (page - 1) * limit;

  let query = `
    SELECT p.product_id, p.product_name, c.category_name, c.category_id,
          p.description, p.base_price, p.markup_price, p.isfastmoving,
          p.is_approved, p.received_date,
          CEIL(p.base_price * (1 + p.markup_price / 100)) AS retail_price,
          p.unit_measurement,
          i.stock_quantity, i.spoilage_date, i.stock_status, i.last_updated
    FROM product p
    JOIN category c ON p.category_id = c.category_id
    LEFT JOIN inventory i ON p.product_id = i.product_id
    WHERE p.product_name LIKE ?
  `;

  const params = [keyword];

  // approved only filter for cashier
  if (isApprovedOnly) {
    query += ` AND p.is_approved = TRUE`;
  }

  // category filter
  if (category) {
    query += ` AND c.category_name = ?`;
    params.push(category);
  }

  // stock status filter
  if (stockStatus) {
    query += ` AND i.stock_status = ?`;
    params.push(stockStatus);
  }

  // expiry filter
  if (expirationFilter === 'Expired') {
    query += ` AND i.spoilage_date < CURDATE()`;
  } else if (expirationFilter === 'Expiring Soon') {
    query += ` AND i.spoilage_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)`;
  } else if (expirationFilter === 'Not Expiring Soon') {
    query += ` AND (i.spoilage_date > DATE_ADD(CURDATE(), INTERVAL 7 DAY) OR i.spoilage_date IS NULL)`;
  }

  // sorting
  const orderClauses = [];

  // if recentlyAdded is requested and no explicit sort is given, use last_updated
  if (recentlyAdded && sortName === '' && sortPrice === '') {
    orderClauses.push('i.last_updated DESC');
  }

  if (sortName === 'A-Z') orderClauses.push('p.product_name ASC');
  if (sortName === 'Z-A') orderClauses.push('p.product_name DESC');
  if (sortPrice === 'asc') orderClauses.push('retail_price ASC');
  if (sortPrice === 'desc') orderClauses.push('retail_price DESC');

  if (orderClauses.length > 0) {
    query += ` ORDER BY ${orderClauses.join(', ')}`;
  }

  // pagination
  if (!all) {
    query += ` LIMIT ? OFFSET ?`;
    params.push(limit, offset);
  }

  const [rows] = await db.query(query, params);

  // count query – same filters, no pagination
  let countQuery = `
    SELECT COUNT(*) AS total
    FROM product p
    JOIN category c ON p.category_id = c.category_id
    LEFT JOIN inventory i ON p.product_id = i.product_id
    WHERE p.product_name LIKE ?
  `;
  const countParams = [keyword];

  if (isApprovedOnly) countQuery += ` AND p.is_approved = TRUE`;
  if (category) { countQuery += ` AND c.category_name = ?`; countParams.push(category); }
  if (stockStatus) { countQuery += ` AND i.stock_status = ?`; countParams.push(stockStatus); }
  if (expirationFilter === 'Expired') {
    countQuery += ` AND i.spoilage_date < CURDATE()`;
  } else if (expirationFilter === 'Expiring Soon') {
    countQuery += ` AND i.spoilage_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)`;
  } else if (expirationFilter === 'Not Expiring Soon') {
    countQuery += ` AND (i.spoilage_date > DATE_ADD(CURDATE(), INTERVAL 7 DAY) OR i.spoilage_date IS NULL)`;
  }

  const [[{ total }]] = await db.query(countQuery, countParams);

  return {
    products: rows,
    pagination: { total, page, limit, totalPages: Math.ceil(total / limit) }
  };
},

  findProductByID: async (productID) => {
    const [rows] = await db.query(
      `SELECT p.*,
              CEIL(p.base_price * (1 + p.markup_price / 100)) AS retail_price,
              i.inventory_id, i.stock_quantity, i.spoilage_date, i.stock_status
       FROM product p
       LEFT JOIN inventory i ON p.product_id = i.product_id
       WHERE p.product_id = ?`,
      [productID]
    );
    return rows[0];
  },

  // add new product
  addProduct: async (categoryID, productName, description, basePrice, unitMeasurement, isFastMoving, receivedDate) => {
    // new products start unapproved - admin must set markup to approve
    // markup_price starts at 0 until admin sets it
    const [result] = await db.query(
      `INSERT INTO product (category_id, product_name, description, base_price, markup_price, unit_measurement, isfastmoving, received_date, is_approved)
       VALUES (?, ?, ?, ?, 0, ?, ?, ?, FALSE)`,
      [categoryID, productName, description || null, basePrice, unitMeasurement || null, isFastMoving || false, receivedDate || null]
    );
    return result.insertId;
  },

  // update product, markup_price editable only by admin (enforced in controller)
  updateProduct: async (productID, fields) => {
    const allowedFields = ['product_name', 'category_id', 'description', 'base_price', 'markup_price', 'unit_measurement', 'isfastmoving', 'received_date', 'is_approved'];
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

  deleteProduct: async (productID) => {
    await db.query('DELETE FROM inventory WHERE product_id = ?', [productID]);
    const [result] = await db.query('DELETE FROM product WHERE product_id = ?', [productID]);
    return result.affectedRows;
  },

  // get all categories for dropdown
  getAllCategories: async () => {
    const [rows] = await db.query('SELECT * FROM category ORDER BY category_name ASC');
    return rows;
  }
};

module.exports = Product;