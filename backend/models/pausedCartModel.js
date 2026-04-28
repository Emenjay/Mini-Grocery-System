const db = require('../config/db');

const PausedCart = {

  // save a new paused cart with its items
  pauseCart: async (userID, cartNo, items) => {
    // create paused cart header
    const [result] = await db.query(
      `INSERT INTO paused_cart (user_id, cart_no, created_at)
       VALUES (?, ?, NOW())`,
      [userID, cartNo]
    );
    const pausedCartID = result.insertId;

    // insert each item
    for (const item of items) {
      await db.query(
        `INSERT INTO paused_cart_item
         (paused_cart_id, product_id, product_name, quantity, retail_price, subtotal)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [pausedCartID, item.product_id, item.product_name, item.quantity, item.retail_price, item.subtotal]
      );
    }

    return pausedCartID;
  },

  // get all paused carts for a cashier with item count and total
  getPausedCarts: async (userID) => {
    const [rows] = await db.query(
      `SELECT pc.paused_cart_id, pc.cart_no, pc.created_at,
              COUNT(pci.item_id) AS item_count,
              SUM(pci.subtotal) AS total_amount
       FROM paused_cart pc
       JOIN paused_cart_item pci ON pc.paused_cart_id = pci.paused_cart_id
       WHERE pc.user_id = ?
       GROUP BY pc.paused_cart_id`,
      [userID]
    );
    return rows;
  },

  // get a single paused cart with all its items
  getPausedCartByID: async (pausedCartID, userID) => {
    // get cart header, also verify it belongs to this cashier
    const [[cart]] = await db.query(
      `SELECT * FROM paused_cart
       WHERE paused_cart_id = ? AND user_id = ?`,
      [pausedCartID, userID]
    );
    if (!cart) return null;

    // get cart items
    const [items] = await db.query(
      `SELECT * FROM paused_cart_item WHERE paused_cart_id = ?`,
      [pausedCartID]
    );

    return { ...cart, items };
  },

  // delete a single paused cart and its items
  deletePausedCart: async (pausedCartID) => {
    // delete items first due to foreign key constraint
    await db.query('DELETE FROM paused_cart_item WHERE paused_cart_id = ?', [pausedCartID]);
    await db.query('DELETE FROM paused_cart WHERE paused_cart_id = ?', [pausedCartID]);
  },

  // delete all paused carts for a user, called silently on logout
  deleteAllPausedCarts: async (userID) => {
    // get all paused cart IDs for this user
    const [carts] = await db.query(
      'SELECT paused_cart_id FROM paused_cart WHERE user_id = ?',
      [userID]
    );

    // delete items for each cart first
    for (const cart of carts) {
      await db.query(
        'DELETE FROM paused_cart_item WHERE paused_cart_id = ?',
        [cart.paused_cart_id]
      );
    }

    // then delete all cart headers
    await db.query('DELETE FROM paused_cart WHERE user_id = ?', [userID]);
  }

};

module.exports = PausedCart;