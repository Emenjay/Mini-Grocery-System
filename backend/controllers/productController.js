const Product = require('../models/productModel');
const Inventory = require('../models/inventoryModel');
const db = require('../config/db');
const { checkAndNotifyLowStock } = require('./notificationController');


exports.getAllProducts = async (req, res) => {
  try {
    const {search, category, stockStatus, expirationFilter, sortName, sortPrice, page, limit, all} = req.query;

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
      all === 'true' // converts string 'true' to boolean
    );
    res.status(200).json({
      message: 'Products retrieved successfully',
      ...result // spreads products and pagination into the response
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

//added features: markup_percent and is_fast_moving
exports.addProduct = async (req, res) => {
  try {
    const { categoryID, productName, description, basePrice, unitMeasurement, stockQuantity, spoilageDate, markupPercent, isFastMoving } = req.body;

    // validate required fields, markup set automatically from config
    if (!categoryID || !productName || !basePrice) {
      return res.status(400).json({ message: 'categoryID, productName, and basePrice are required' });
    }

    // insert into product table
    const productID = await Product.addProduct(
      categoryID, productName, description, basePrice, unitMeasurement, markupPercent, isFastMoving
    );

    // create inventory record for the new product
    await Inventory.createInventory(productID, stockQuantity || 0, spoilageDate);

    res.status(201).json({
      message: 'Product added successfully',
      product: {
        productID,
        productName,
        categoryID,
        basePrice,
        markupPercent: markupPercent || 0,
        isFastMoving: isFastMoving || false,
        unitMeasurement: unitMeasurement || null,
        description: description || null,
        stockQuantity: stockQuantity || 0,
        spoilageDate: spoilageDate || null
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

//added features: markup_percent and is_fast_moving, markup_price now calculated from base_price and percent, only admin can update pricing 
exports.updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { productName, categoryID, description, basePrice, markupPrice, markupPercent, isFastMoving, unitMeasurement, stockQuantity, spoilageDate } = req.body;
    const requestingRole = req.user.role; // from JWT

    const product = await Product.findProductByID(id);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    // build product fields
    const productFields = {};
    if (productName !== undefined) productFields['product_name'] = productName;
    if (categoryID !== undefined) productFields['category_id'] = categoryID;
    if (description !== undefined) productFields['description'] = description;
    if (unitMeasurement !== undefined) productFields['unit_measurement'] = unitMeasurement;
    if (isFastMoving !== undefined) productFields['is_fast_moving'] = isFastMoving ? 1 : 0;

    // markup_price is admin only
      if (basePrice !== undefined || markupPrice !== undefined || markupPercent !== undefined) {
      if (requestingRole !== 'Admin') {
        return res.status(403).json({ message: 'Only admin can update pricing' });
      }
    }

    // if basePrice or markupPercent provided, compute new markup_price, else if markupPrice provided, use it directly (manual override)
     const resolvedBase = basePrice !== undefined ? parseFloat(basePrice) : parseFloat(product.base_price);

      if (markupPercent !== undefined) {
        // compute markup_price from percent, rounded (no cents)
        const computedMarkup = Math.round(resolvedBase * parseFloat(markupPercent) / 100);
        productFields['markup_percent'] = parseFloat(markupPercent);
        productFields['markup_price'] = computedMarkup;
      } else if (markupPrice !== undefined) {
        productFields['markup_price'] = Math.round(parseFloat(markupPrice));
        productFields['markup_percent'] = 0; // manual override, clear percent
      }

      if (basePrice !== undefined) productFields['base_price'] = resolvedBase;
    

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

//Russ's update: added getNotifications function to check for low stock products and return notifications 
//PATCH /api/product/:id/restock
exports.restockProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { quantity } = req.body;

    if (!quantity || quantity <= 0) {
      return res.status(400).json({ success: false, message: 'Quantity must be greater than 0.' });
    }

    // check if product exists
    const [[product]] = await db.query(
      `SELECT product_id, product_name, stock_level FROM product WHERE product_id = ?`,
      [id]
    );

    if (!product) {
      return res.status(404).json({ success: false, message: 'Product not found.' });
    }

    // update stock level
    await db.query(
      `UPDATE product SET stock_level = stock_level + ? WHERE product_id = ?`,
      [quantity, id]
    );

    const newStock = product.stock_level + quantity;

    // check if product is still low stock after restock, if so send low stock notification
    res.json({
      success: true,
      message: `"${product.product_name}" restocked successfully.`,
      previous_stock: product.stock_level,
      added: quantity,
      new_stock: newStock,
    });

  } catch (err) {
    console.error('restockProduct:', err);
    res.status(500).json({ success: false, message: 'Failed to restock product.' });
  }
};