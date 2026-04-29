const Transaction = require('../models/transactionModel');
const Inventory = require('../models/inventoryModel');
const Product = require('../models/productModel');
const PausedCart = require('../models/pausedCartModel');

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

// save current cart as paused
exports.pauseCart = async (req, res) => {
  try {
    const userID = req.user.userID;
    const { cart } = req.body;

    if (!cart || cart.length === 0) {
      return res.status(400).json({ message: 'Cart is empty' });
    }

    // resolve prices from backend, same logic as checkout
    const resolvedItems = [];
    for (const item of cart) {
      const product = await Product.findProductByID(item.product_id);
      if (!product) {
        return res.status(404).json({ message: `Product ID ${item.product_id} not found` });
      }
      const retailPrice = parseFloat((parseFloat(product.base_price) + parseFloat(product.markup_price)).toFixed(2));
      const subtotal = parseFloat((retailPrice * item.quantity).toFixed(2));
      resolvedItems.push({
        product_id: product.product_id,
        product_name: product.product_name,
        quantity: item.quantity,
        retail_price: retailPrice,
        subtotal
      });
    }

    // generate unique cart number for this paused cart
    const cartNo = await Transaction.generateCartNo();
    const pausedCartID = await PausedCart.pauseCart(userID, cartNo, resolvedItems);

    res.status(201).json({
      message: 'Cart paused successfully',
      pausedCartID,
      cartNo
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// get all paused carts for the cashier
exports.getPausedCarts = async (req, res) => {
  try {
    const userID = req.user.userID;
    const carts = await PausedCart.getPausedCarts(userID);
    res.status(200).json({
      message: 'Paused carts retrieved successfully',
      carts
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// get a specific paused cart with items
// flutter loads these items back into the cart UI for resuming
exports.getPausedCartByID = async (req, res) => {
  try {
    const userID = req.user.userID;
    const { id } = req.params;

    const cart = await PausedCart.getPausedCartByID(id, userID);
    if (!cart) {
      return res.status(404).json({ message: 'Paused cart not found' });
    }

    res.status(200).json({
      message: 'Paused cart retrieved successfully',
      cart
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// discard a paused cart manually
exports.discardPausedCart = async (req, res) => {
  try {
    const userID = req.user.userID;
    const { id } = req.params;

    const cart = await PausedCart.getPausedCartByID(id, userID);
    if (!cart) {
      return res.status(404).json({ message: 'Paused cart not found' });
    }

    await PausedCart.deletePausedCart(id);

    res.status(200).json({ message: 'Paused cart discarded successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};