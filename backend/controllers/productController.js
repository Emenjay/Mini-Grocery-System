const Product = require('../models/productModel');
const Inventory = require('../models/inventoryModel');

exports.getAllProducts = async (req, res) => { 
  try {
    const { search } = req.query; // get search query from URL e.g. ?search=coca

    // pass search to model, if no search provided defaults to empty string (returns all)
    const products = await Product.getAllProducts(search || '');

    res.status(200).json({
      message: 'Products retrieved successfully',
      products
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.addProduct = async (req, res) => {
  try {
    const { categoryID, productName, description, markupPrice, unitMeasurement, stockQuantity, spoilageDate } = req.body;

    // validate required fields
    if (!categoryID || !productName || !markupPrice) {
      return res.status(400).json({ message: 'categoryID, productName, and markupPrice are required' });
    }

    // insert into product table
    const productID = await Product.addProduct(
      categoryID, productName, description, markupPrice, unitMeasurement
    );

    // create inventory record for the new product
    await Inventory.createInventory(productID, stockQuantity || 0, spoilageDate);

    res.status(201).json({
      message: 'Product added successfully',
      product: {
        productID,
        productName,
        categoryID,
        markupPrice,
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
    const { productName, categoryID, description, markupPrice, unitMeasurement, stockQuantity, spoilageDate } = req.body;

    const product = await Product.findProductByID(id);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    // build product fields
    const productFields = {};
    if (productName !== undefined) productFields['product_name'] = productName;
    if (categoryID !== undefined) productFields['category_id'] = categoryID;
    if (description !== undefined) productFields['description'] = description;
    if (markupPrice !== undefined) productFields['markup_price'] = markupPrice;
    if (unitMeasurement !== undefined) productFields['unit_measurement'] = unitMeasurement;

    // build inventory fields
    const inventoryFields = {};
    if (stockQuantity !== undefined) inventoryFields['stock_quantity'] = stockQuantity;
    if (spoilageDate !== undefined) inventoryFields['spoilage_date'] = spoilageDate;

    // If no edits were made, keep current details
    if (Object.keys(productFields).length === 0 && Object.keys(inventoryFields).length === 0) {
      return res.status(400).json({ message: 'No fields provided to update' });
    }
    // if product fields were edited, update given details
    if (Object.keys(productFields).length > 0) {
      await Product.updateProduct(id, productFields);
    }
    // if inventory fields were updated, update inventory
    if (Object.keys(inventoryFields).length > 0) {
      await Inventory.updateInventory(id, inventoryFields);
    }

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