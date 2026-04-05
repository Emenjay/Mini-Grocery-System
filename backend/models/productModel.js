const db = require('../config/db');

const Product = {
    // get all product
    getAllProducts: async (search = '') => {
        const keyword = `%${search}%`; // % wildcards allow partial matching e.g. "oca" matches "Coca Cola"
        const [rows] = await db.query(
            `SELECT p.ProductID, p.ProductNumber, p.Name, CategoryName, 
                    p.BasePrice, p.MarkupPrice, p.StockQty, p.ExpiryDate, p.IsDeleted
                FROM products p 
                JOIN categories c ON p.CategoryID = c.CategoryID 
                WHERE p.IsDeleted = FALSE
                AND (p.Name LIKE ? OR p.ProductNumber LIKE ?)`, // search by name or product number
                [keyword, keyword]
        );
        return rows;
    },

    // get product count for productNumber
    getProductCount: async () => {
    const year = new Date().getFullYear();
    const [rows] = await db.query(
      `SELECT COUNT(*) AS count FROM products 
      WHERE ProductNumber LIKE ?`,
      [`${year}M%`]
  );
  return rows[0].count;
},

  // add new product
  addProduct: async (productNumber, name, categoryID, basePrice, markupPrice, stockQty, expiryDate, productType, measurement, dateReceived, description) => {
    const [result] = await db.query(
      `INSERT INTO products (ProductNumber, Name, CategoryID, BasePrice, MarkupPrice, StockQty, ExpiryDate, ProductType, Measurement, DateReceived, Description)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [productNumber, name, categoryID, basePrice, markupPrice, stockQty, expiryDate, productType, measurement, dateReceived, description || null]
    );
    return result.insertId;
  },

  // edit product details
  updateProduct: async (productID, fields) => {
    const allowedFields = ['Name', 'CategoryID', 'Description', 'BasePrice', 'StockQty', 'ExpiryDate'];
    
    const keys = Object.keys(fields).filter(k => allowedFields.includes(k));
    if (keys.length === 0) return 0;

    const values = keys.map(k => fields[k]);
    const setClause = keys.map(k => `${k} = ?`).join(', ');

    const [result] = await db.query(
      `UPDATE products SET ${setClause} WHERE ProductID = ?`,
      [...values, productID]
    );
    return result.affectedRows;
  },

  // soft delete product (not deleted from database)
  softDeleteProduct: async (productID, deleteReason) => {
    const [result] = await db.query(
      `UPDATE products SET IsDeleted = TRUE, DeleteReason = ? WHERE ProductID = ?`,
      [deleteReason, productID]
    );
    return result.affectedRows;
  },

  // find product using ID
  findProductByID: async (productID) => {
    const [rows] = await db.query(
      'SELECT * FROM products WHERE ProductID = ?', [productID]
    );
    return rows[0];
  }
};

module.exports = Product;