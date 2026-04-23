const Product = require('../models/productModel');
const Inventory = require('../models/inventoryModel');

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

exports.addProduct = async (req, res) => {
  try {
    const { categoryID, productName, description, basePrice, unitMeasurement, stockQuantity, spoilageDate } = req.body;

    // validate required fields, markup set automatically from config
    if (!categoryID || !productName || !basePrice) {
      return res.status(400).json({ message: 'categoryID, productName, and basePrice are required' });
    }

    // insert into product table
    const productID = await Product.addProduct(
      categoryID, productName, description, basePrice, unitMeasurement
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

exports.updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { productName, categoryID, description, basePrice, markupPrice, unitMeasurement, stockQuantity, spoilageDate } = req.body;
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
    if (basePrice !== undefined) productFields['base_price'] = basePrice;
    if (unitMeasurement !== undefined) productFields['unit_measurement'] = unitMeasurement;

    // markup_price is admin only
    if (markupPrice !== undefined) {
      if (requestingRole !== 'Admin') {
        return res.status(403).json({ message: 'Only admin can update markup price' });
      }
      productFields['markup_price'] = markupPrice;
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