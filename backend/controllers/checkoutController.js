const Transaction = require('../models/transactionModel');
const Inventory = require('../models/inventoryModel');
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