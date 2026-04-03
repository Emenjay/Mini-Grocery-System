const bcrypt = require('bcrypt');
const User = require('../models/userModel');

// login authentication
exports.login = async (req, res) => {
    try {
        const { username, pincode } = req.body;

        // check if fields are provided
        if (!username || !pincode) {
            return res.status(400).json({ message: 'Username and PIN are required'});
        }

        // find user in db
        const user = await User.findByUsername(username);
        if (!user) {
            return res.status(401).json({ message: 'Invalid username or PIN'});
        }

        // compare pin with hashed pin in db
        const match = await bcrypt.compare(pincode, user.PinCodeHash);
        if (!match) {
            return res.status(401).json({ message: 'Invalid username or PIN'});
        }

        // if all previous condtions passed, login success
        res.status(200).json({
            message: 'Login successful',
            user: {
                id: user.UserID,
                name: user.Name,
                username: user.UserName,
                role: user.Role,
            }
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error'});
    }
};