const db = require('../config/db');

const Inventory = {
  
    createInventory: async (productID, stockQuantity, spoilageDate) => {
        const [result] = await db.query(
            `INSERT INTO inventory (product_id, stock_quantity, spoilage_date, stock_status, last_updated)
            VALUES (?, ?, ?, ?, NOW())`,
            [productID, stockQuantity, spoilageDate || null, calculateStockStatus(stockQuantity)]
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
        fields.stock_status = calculateStockStatus(fields.stock_quantity);
        keys.push('stock_status');
        }

        const values = keys.map(k => fields[k]);
        const setClause = keys.map(k => `${k} = ?`).join(', ');

        const [result] = await db.query(
            `UPDATE inventory SET ${setClause}, last_updated = NOW() WHERE product_id = ?`,
            [...values, productID]
        );
        return result.affectedRows;
    }
    };

    // auto calculate stock status based on quantity
    function calculateStockStatus(quantity) {
        if (quantity <= 0) return 'Out of Stock';
        if (quantity <= 20) return 'Low Stock'; // low stock standard to be finalized
        return 'In Stock';
    }

    module.exports = Inventory;