const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const protect = require('../middleware/authMiddleware');

// get all products
router.get('/', protect, productController.getAllProducts);

// add new product
router.post('/', protect, productController.addProduct);

// edit/update product
router.put('/:id', protect, productController.updateProduct);

// soft delete product
router.delete('/:id', protect, productController.deleteProduct);

module.exports = router;