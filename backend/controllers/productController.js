const Product = require('../models/productModel');
const InventoryLog = require('../models/inventoryLogModel');

exports.getAllProducts = async (req, res) => {
    try {
        const products = await Product.getAllProducts();
        res.status(200).json({
            message: 'Products retrieved successfully',
            products
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error'});
    }
};

exports.addProduct = async (req, res) => {
  try {
    const { userID, name, categoryID, basePrice, markupPrice, stockQty, expiryDate } = req.body;

    // Validate required fields
    if (!name || !categoryID || !basePrice || !markupPrice || stockQty === undefined) {
      return res.status(400).json({ message: 'name, categoryID, basePrice, markupPrice, and stockQty are required' });
    }

    // Generate product number e.g. PRD-0001
    const count = await Product.getProductCount();
    const productNumber = `PRD-${String(count + 1).padStart(4, '0')}`;

    // Add product
    const productID = await Product.addProduct(
      productNumber, name, categoryID, basePrice, markupPrice, stockQty, expiryDate
    );

    // Log the action in inventory_logs
    await InventoryLog.addLog(productID, userID, 'Add', stockQty, 'Initial stock upon new adding product');

    res.status(201).json({
      message: 'Product added successfully',
      product: {
        productID,
        productNumber,
        name,
        categoryID,
        basePrice,
        markupPrice,
        stockQty,
        expiryDate: expiryDate || null
      }
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};