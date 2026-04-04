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
    const userID = req.user.userID;
    const { name, categoryID, basePrice, markupPrice, stockQty, expiryDate, productType, measurement, dateReceived, description } = req.body;

    // Validate required fields
    if (!name || !categoryID || !basePrice || !markupPrice || !stockQty  || !dateReceived || !productType === undefined) {
      return res.status(400).json({ message: 'name, categoryID, basePrice, markupPrice, stockQty, date received, and productType are required' });
    }

    // Generate product number e.g. 2026M0001
    const year = new Date().getFullYear();
    const count = await Product.getProductCount();
    const productNumber = `${year}M${String(count + 1).padStart(4, '0')}`;

    // Add product
    const productID = await Product.addProduct(
      productNumber, name, categoryID, basePrice, markupPrice, stockQty, expiryDate,  productType, measurement, dateReceived, description
    );

    // Log the action in inventory_logs
    await InventoryLog.addLog(productID, userID, 'Add', stockQty, 'Initial stock upon adding new product');

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
        expiryDate: expiryDate || null,
        productType, 
        measurement, 
        dateReceived, 
        description
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
    const userID = req.user.userID;
    const { name, categoryID, description, basePrice, stockQty, expiryDate } = req.body;

    const product = await Product.findProductByID(id);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    // Build only fields that were sent
    const fields = {};
    if (name !== undefined) fields['Name'] = name;
    if (categoryID !== undefined) fields['CategoryID'] = categoryID;
    if (description !== undefined) fields['Description'] = description;
    if (basePrice !== undefined) fields['BasePrice'] = basePrice;
    if (stockQty !== undefined) fields['StockQty'] = stockQty;
    if (expiryDate !== undefined) fields['ExpiryDate'] = expiryDate || null;

    if (Object.keys(fields).length === 0) {
      return res.status(400).json({ message: 'No fields provided to update' });
    }

    await Product.updateProduct(id, fields);

    // Log to inventory_logs only if stockQty changed
    if (stockQty !== undefined && stockQty !== product.StockQty) {
      const quantityChange = stockQty - product.StockQty;
      await InventoryLog.addLog(id, userID, 'Edit', quantityChange, 'Stock updated via edit');
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
    const { deleteReason } = req.body;

    const product = await Product.findProductByID(id);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    if (product.IsDeleted) {
      return res.status(400).json({ message: 'Product is already deleted' });
    }

    await Product.softDeleteProduct(id, deleteReason || null);

    res.status(200).json({ message: 'Product deleted successfully' });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};