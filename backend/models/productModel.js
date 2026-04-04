const db = require('../config/db');

const Product = {
    // get all product
    getAllProducts: async () => {
        const [rows] = await db.query(
            `SELECT p.ProductID, p.ProductNumber, p.Name, CategoryName, 
                    p.BasePrice, p.MarkupPrice, p.StockQty, p.ExpiryDate, p.IsDeleted
                FROM products p 
                JOIN categories c ON p.CategoryID = c.CategoryID 
                WHERE p.IsDeleted = FALSE`
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
  }
};

module.exports = Product;