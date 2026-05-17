const Product = require('../models/productModel');
const Inventory = require('../models/inventoryModel');
const db = require('../config/db');

exports.getAllProducts = async (req, res) => {
  try {
    const { search, category, stockStatus, expirationFilter, sortName, sortPrice, page, limit, all, recentlyAdded } = req.query;
    const role = req.user.role;

    
    // cashier only sees approved products
    const isApprovedOnly = role === 'Cashier';
    // pass search to model, if no search/filter provided, defaults to return all
    const result = await Product.getAllProducts(
      search || '',
      category || '',
      stockStatus || '',
      expirationFilter || '',
      sortName || '',
      sortPrice || '',
      parseInt(page) || 1,
      parseInt(limit) || 20,
      all === 'true',
      recentlyAdded === 'true',
      isApprovedOnly
    );
    res.status(200).json({
      message: 'Products retrieved successfully',
      ...result
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.addProduct = async (req, res) => {
  try {
    const { categoryID, productName, description, basePrice, unitMeasurement, stockQuantity, spoilageDate, isFastMoving, receivedDate } = req.body;

    if (!categoryID || !productName || !basePrice) {
      return res.status(400).json({ message: 'categoryID, productName, and basePrice are required' });
    }

    // insert product - starts unapproved, markup defaults to 0
    const productID = await Product.addProduct(
     categoryID, productName, description, basePrice,
      unitMeasurement,
      isFastMoving === undefined ? null : isFastMoving, // null = no threshold
      receivedDate || null
      // receivedDate defaults to CURDATE() in schema if null
    );
    
    // create inventory record for the new product
    await Inventory.createInventory(productID, stockQuantity || 0, spoilageDate);

    res.status(201).json({
      message: 'Product added successfully. Pending admin approval.',
      product: {
        productID,
        productName,
        categoryID,
        basePrice,
        unitMeasurement: unitMeasurement || null,
        description: description || null,
        stockQuantity: stockQuantity || 0,
        spoilageDate: spoilageDate || null,
        isFastMoving: isFastMoving || false,
        receivedDate: receivedDate || 'today',
        isApproved: false
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { productName, categoryID, description, basePrice, markupPrice, unitMeasurement, stockQuantity, spoilageDate, isFastMoving, receivedDate } = req.body;
    const requestingRole = req.user.role; // from JWT

    const product = await Product.findProductByID(id);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    // build product builds
    const productFields = {};
    if (productName !== undefined) productFields['product_name'] = productName;
    if (categoryID !== undefined) productFields['category_id'] = categoryID;
    if (description !== undefined) productFields['description'] = description;
    if (basePrice !== undefined) productFields['base_price'] = basePrice;
    if (unitMeasurement !== undefined) productFields['unit_measurement'] = unitMeasurement;
    if (isFastMoving !== undefined) productFields['isfastmoving'] = isFastMoving;
    if (receivedDate !== undefined) productFields['received_date'] = receivedDate;

    // markup is admin only - setting markup also approves the product
    if (markupPrice !== undefined) {
      if (requestingRole !== 'Admin') {
        return res.status(403).json({ message: 'Only admin can update markup price' });
      }
      productFields['markup_price'] = markupPrice;
      // setting markup approves the product making it visible to cashier
      productFields['is_approved'] = true;
    }

    // build inventory fields
    const inventoryFields = {};
    if (stockQuantity !== undefined) inventoryFields['stock_quantity'] = stockQuantity;
    if (spoilageDate !== undefined) inventoryFields['spoilage_date'] = spoilageDate;

    // If no edits were made, keep current details
    if (Object.keys(productFields).length === 0 && Object.keys(inventoryFields).length === 0) {
      return res.status(400).json({ message: 'No fields provided to update' });
    }
    // if product fields were edited, update given details
    if (Object.keys(productFields).length > 0) await Product.updateProduct(id, productFields);
    // if inventory fields were updated, update inventory
    if (Object.keys(inventoryFields).length > 0) await Inventory.updateInventory(id, inventoryFields);

    res.status(200).json({ message: 'Product updated successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const product = await Product.findProductByID(id);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    await Product.deleteProduct(id);
    res.status(200).json({ message: 'Product deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getAllCategories = async (req, res) => {
  try {
    const categories = await Product.getAllCategories();
    res.status(200).json({ message: 'Categories retrieved successfully', categories });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.restockProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { quantity } = req.body;

    if (!quantity || quantity <= 0) {
      return res.status(400).json({ success: false, message: 'Quantity must be greater than 0.' });
    }

    // check if product exists
    const [[inventory]] = await db.query(
      `SELECT i.stock_quantity, p.product_id, p.product_name 
       FROM product p
       JOIN inventory i ON p.product_id = i.product_id
       WHERE p.product_id = ?`,
      [id]
    );

    // correct product name
    if (!inventory) {
      return res.status(404).json({ success: false, message: 'Product not found.' });
    }

    // update inventory stock
    await db.query(
      `UPDATE inventory SET stock_quantity = stock_quantity + ?, last_updated = NOW() WHERE product_id = ?`,
      [quantity, id]
    );

    const newStock = inventory.stock_quantity + quantity;

    res.json({
      success: true,
      message: `"${inventory.product_name}" restocked successfully.`,
      previous_stock: inventory.stock_quantity,
      added: quantity,
      new_stock: newStock,
    });
  } catch (err) {
    console.error('restockProduct:', err);
    res.status(500).json({ success: false, message: 'Failed to restock product.' });
  }
};