const Transaction = require('../models/transactionModel');
const Inventory = require('../models/inventoryModel');

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

    // calculate total from cart items
    const totalAmount = cart.reduce((sum, item) => {
      return sum + (item.retail_price * item.quantity);
    }, 0);

    // validate amount received
    if (payment.amount_received < totalAmount) {
      return res.status(400).json({ message: 'Amount received is less than total amount' });
    }

    // calculate change
    const changeAmount = parseFloat((payment.amount_received - totalAmount).toFixed(2));

    // generate cart number
    const cartNo = await Transaction.generateCartNo();

    // create payment record
    const paymentID = await Transaction.createPayment(
      payment.payment_method,
      payment.reference_number
    );

    // create transaction record
    const transactionID = await Transaction.createTransaction(
      cartNo, userID, paymentID, totalAmount, payment.amount_received, changeAmount
    );

    // process each cart item
    const warnings = [];

    for (const item of cart) {
      const subtotal = parseFloat((item.retail_price * item.quantity).toFixed(2));

      // insert transaction detail
      await Transaction.createTransactionDetail(
        transactionID,
        item.product_id,
        item.product_name,
        item.quantity,
        item.retail_price,
        subtotal
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