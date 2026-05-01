const Transaction = require('../models/transactionModel');
const Inventory = require('../models/inventoryModel');
const db = require('../config/db');
const Product = require('../models/productModel'); // add this

exports.checkout = async (req, res) => {
  try {
    const userID = req.user.userID;
    const { cart, payment } = req.body;
    
    // validate request body
    if (!cart || cart.length === 0) {
      return res.status(400).json({ message: 'Cart is empty' });
    }
    if (!payment || !payment.payment_method || !payment.amount_received) {
      return res.status(400).json({ message: 'Payment details are required' });
    }

    // compute total from cart items
    // fetch each product from db to get the real retail price
    // Flutter sends only product_id and quantity
    let totalAmount = 0;
    const resolvedCart = [];
  
    for (const item of cart) {
      const product = await Product.findProductByID(item.product_id);
      if (!product) {
        return res.status(404).json({ message: `Product ID ${item.product_id} not found` });
      }

      // backend computes retail price
      const retailPrice = parseFloat((parseFloat(product.base_price) + parseFloat(product.markup_price)).toFixed(2));
      const subtotal = parseFloat((retailPrice * item.quantity).toFixed(2));
      totalAmount += subtotal;

      resolvedCart.push({
        product_id: product.product_id,
        product_name: product.product_name,
        quantity: item.quantity,
        retail_price: retailPrice,
        subtotal
      });
    }

    totalAmount = parseFloat(totalAmount.toFixed(2));

    // validate amount recieved
    if (payment.amount_received < totalAmount) {
      return res.status(400).json({ message: 'Amount received is less than total amount' });
    }

    // calculate change
    const changeAmount = parseFloat((payment.amount_received - totalAmount).toFixed(2));
    
    // geneate cart number
    const cartNo = await Transaction.generateCartNo();
    
    // create payment record
    const paymentID = await Transaction.createPayment(payment.payment_method, payment.reference_number);
    
    // create transaction record
    const transactionID = await Transaction.createTransaction(
      cartNo, userID, paymentID, totalAmount, payment.amount_received, changeAmount
    );

    const warnings = [];
    // process each cart item
    for (const item of resolvedCart) {

      // insert transaction detail
      await Transaction.createTransactionDetail(
        transactionID, item.product_id, item.product_name,
        item.quantity, item.retail_price, item.subtotal
      );

      // deduct stock
      await Inventory.deductStock(item.product_id, item.quantity);

      // check stock after deduction and warn if needed
      const inventory = await Inventory.getByProductID(item.product_id);
      if (inventory.stock_status === 'Out of Stock') {
        warnings.push(`${item.product_name} is out of stock, please update inventory`);
      } else if (inventory.stock_status === 'Low Stock') {
        warnings.push(`${item.product_name} stock is low, please update inventory`);
      }
    }

    res.status(201).json({
      message: 'Transaction completed',
      cartNo,
      transactionID,
      totalAmount,
      changeAmount,
      warnings
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Russ's update: added getTransactionDetail function to fetch transaction details for receipt view in Flutter app
// GET /api/transactions/:id
exports.getTransactionDetail = async (req, res) => {
  try {
    const { id } = req.params;

    // fetch transaction info
    const [[transaction]] = await db.query(
      `SELECT
         t.transaction_id,
         t.cart_no,
         t.user_id,
         t.payment_id,
         t.total_amount,
         t.amount_received,
         t.change_amount,
         t.cash_in,
         t.cash_out,
         t.transaction_type,
         DATE_FORMAT(t.date_time, '%Y-%m-%d %h:%i:%s %p') AS date_time,
         u.full_name AS cashier_name
       FROM transaction t
       LEFT JOIN users u ON t.user_id = u.user_id
       WHERE t.transaction_id = ?`,
      [id]
    );

    // if transaction not found, return 404
    if (!transaction) {
      return res.status(404).json({ success: false, message: 'Transaction not found.' });
    }

    // fetch transaction items
    const [items] = await db.query(
      `SELECT
         detail_id,
         product_id,
         product_name,
         quantity_sold,
         retail_price,
         subtotal
       FROM transaction_detail
       WHERE transaction_id = ?`,
      [id]
    );

    // return transaction details and items
    res.json({
      success: true,
      receipt: {
        ...transaction,
        items,
      },
    });
  } catch (err) {
    console.error('getTransactionDetail:', err);
    res.status(500).json({ success: false, message: 'Failed to fetch transaction.' });
  }
};

//Russ's update: added getTransactionHistory function 
//GET /api/transaction
exports.getTransactionHistory = async (req, res) => {
  try {
    const { user_id, role } = req.user;
    const isAdmin = role === 'Admin';
    const [transactions] = await db.query(
      `SELECT
         t.transaction_id,
         t.cart_no,
         t.total_amount,
         t.transaction_type,
         DATE_FORMAT(t.date_time, '%Y-%m-%d %h:%i:%s %p') AS date_time,
         DATE(t.date_time) AS date_only,
         u.full_name AS cashier_name
       FROM transaction t
       LEFT JOIN users u ON t.user_id = u.user_id
       WHERE t.transaction_type = 'sale'
       ${!isAdmin ? 'AND t.user_id = ?' : ''}
       ORDER BY t.date_time DESC`,
      !isAdmin ? [user_id] : []
    );

    // Separate recent transactions (today) from previous transactions
    const today = new Date().toLocaleDateString('en-CA'); // format: YYYY-MM-DD
    const recent   = transactions.filter(t => new Date(t.date_only).toLocaleDateString('en-CA') === today);
    const previous = transactions.filter(t => new Date(t.date_only).toLocaleDateString('en-CA') !== today);

    //Remove date_only from response
    const clean = (list) => list.map(({ date_only, ...rest }) => rest);

    res.json({
      success: true,
      recent:   clean(recent),
      previous: clean(previous),
    });

  } catch (err) {
    console.error('getTransactionHistory:', err);
    res.status(500).json({ success: false, message: 'Failed to fetch transactions.' });
  }
};