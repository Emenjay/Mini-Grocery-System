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
    }
};

module.exports = Product;