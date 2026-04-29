const Config = require('../models/configModel');

// GET all config values
exports.getConfig = async (req, res) => {
  try {
    const config = await Config.getAll();
    res.status(200).json({ message: 'Config retrieved successfully', config });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// PATCH update a single config value by key
// ex: PATCH /api/config/default_markup   body: { value: "15.00" }
//     PATCH /api/config/low_stock_standard   body: { value: "30" }
exports.updateConfig = async (req, res) => {
  try {
    const { key } = req.params;
    const { value } = req.body;

    // only allow known keys to prevent arbitrary config changes
    const allowedKeys = ['default_markup', 'low_stock_standard'];
    if (!allowedKeys.includes(key)) {
      return res.status(400).json({ message: `Invalid config key: ${key}` });
    }

    // if value left blank
    if (value === undefined || value === null) {
      return res.status(400).json({ message: 'value is required' });
    }

    // validate that value is a non-negative number
    if (isNaN(value) || parseFloat(value) < 0) {
      return res.status(400).json({ message: 'value must be a non-negative number' });
    }

    // if key exists
    const affected = await Config.update(key, value);
    if (affected === 0) {
      return res.status(404).json({ message: 'Config key not found' });
    }

    res.status(200).json({ message: `${key} updated successfully`, key, value });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};