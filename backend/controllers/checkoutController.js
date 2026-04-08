const checkoutModel = require('../models/checkoutModel');

exports.checkout = async (req, res) => {
    try {
        await checkoutModel.checkout(req, res);
    } catch (error) {
        console.error('❌ Checkout Error:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
}; 

