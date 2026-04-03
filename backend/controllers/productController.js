const Product = require('../models/productModel');

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