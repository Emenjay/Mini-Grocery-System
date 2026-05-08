const db = require('../config/db');
const Config = require('./configModel');

const Product = {

  // get all products, with filters and computed retail price
  getAllProducts: async (search = '', category = '', stockStatus = '', expirationFilter = '', sortName = '', sortPrice = '', page = 1, limit = 20, all = false) => {
  const keyword = `%${search}%`;
  const offset = (page - 1) * limit;

  // base query with joins to get category name and inventory details, also computes retail_price
  let query = `
    SELECT p.product_id, p.product_name, c.category_name, c.category_id,
           p.description, p.base_price, p.markup_price, p.markup_percent,
           p.is_fast_moving,
           ROUND(p.base_price + p.markup_price) AS retail_price,
           p.unit_measurement,
           i.stock_quantity, i.spoilage_date, i.stock_status, i.last_updated
    FROM product p
    JOIN category c ON p.category_id = c.category_id
    LEFT JOIN inventory i ON p.product_id = i.product_id
    WHERE (p.product_name LIKE ? OR c.category_name LIKE ?)
  `;

  const params = [keyword, keyword];

  // filter by category name
  if (category) {
    query += ` AND c.category_name = ?`;
    params.push(category);
  }

  // filter by stock status
  if (stockStatus) {
    query += ` AND i.stock_status = ?`;
    params.push(stockStatus);
  }

  // filter by expiration date - Option C preset options
  if (expirationFilter === 'Expired') {
    query += ` AND i.spoilage_date < CURDATE()`;
  } else if (expirationFilter === 'Expiring Soon') {
    query += ` AND i.spoilage_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)`;
  } else if (expirationFilter === 'Not Expiring Soon') {
    query += ` AND (i.spoilage_date > DATE_ADD(CURDATE(), INTERVAL 7 DAY) OR i.spoilage_date IS NULL)`;
  }

  // sorting - name and price can be combined
  const orderClauses = [];
  if (sortName === 'A-Z') orderClauses.push('p.product_name ASC');
  if (sortName === 'Z-A') orderClauses.push('p.product_name DESC');
  if (sortPrice === 'asc') orderClauses.push('retail_price ASC');
  if (sortPrice === 'desc') orderClauses.push('retail_price DESC');
  if (orderClauses.length > 0) {
    query += ` ORDER BY ${orderClauses.join(', ')}`;
  }

  // pagination
  // if all is true, skip pagination
  if (!all) {
    query += ` LIMIT ? OFFSET ?`;
    params.push(limit, offset);
  }


  const [rows] = await db.query(query, params);

  // get total count for pagination info (same filters, no limit/offset)
  let countQuery = `
    SELECT COUNT(*) AS total
    FROM product p
    JOIN category c ON p.category_id = c.category_id
    LEFT JOIN inventory i ON p.product_id = i.product_id
    WHERE (p.product_name LIKE ? OR c.category_name LIKE ?)
  `;
  const countParams = [keyword, keyword];

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
    pagination: {
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit)
    }
  };
},

  // find product by id, also returns retail_price
  findProductByID: async (productID) => {
    const [rows] = await db.query(
      `SELECT p.*, 
       ROUND (p.base_price + p.markup_price) AS retail_price,
          p.markup_percent, p.is_fast_moving,
          i.inventory_id, i.stock_quantity, i.spoilage_date, i.stock_status
      FROM product p
      LEFT JOIN inventory i ON p.product_id = i.product_id
      WHERE p.product_id = ?`,
      [productID]
    );
    return rows[0];
  },

  // added features: markup_percent and is_fast_moving, markup_price now calculated from base_price and percent
  // add new product, markup_price defaults to global default_markup from config
  addProduct: async (categoryID, productName, description, basePrice, unitMeasurement, markupPercent, isFastMoving) => {
  const defaultMarkup = await Config.get('default_markup');

  //compute markup_price from percent if provided, else use default
  let markupPrice = parseFloat(defaultMarkup);
  let resolvedPercent = 0;
  
  //if markupPercent is provided, use it to calculate markupPrice
  if (markupPercent !== undefined && markupPercent !== null) {
    resolvedPercent = parseFloat(markupPercent);
    markupPrice = Math.round(parseFloat(basePrice) * resolvedPercent / 100);
  }

  // insert product and return new product ID
  const [result] = await db.query(
      `INSERT INTO product (category_id, product_name, description, base_price, markup_price, markup_percent, unit_measurement, is_fast_moving)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [categoryID, productName, description || null, basePrice, markupPrice, resolvedPercent, unitMeasurement || null, isFastMoving ? 1 : 0]
  );
  return result.insertId;
},
  

  // update product, markup_price now editable only by admin (enforced in controller)
  updateProduct: async (productID, fields) => {
    const allowedFields = ['product_name', 'category_id', 'description', 'base_price', 'markup_price', 'markup_percent', 'unit_measurement', 'is_fast_moving'];
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
  },

  // get all categories for dropdown
  getAllCategories: async () => {
    const [rows] = await db.query('SELECT * FROM category ORDER BY category_name ASC');
    return rows;
  }

};

module.exports = Product;