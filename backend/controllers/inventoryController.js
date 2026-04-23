const Inventory = require('../models/inventoryModel');

exports.getInventoryDashboard = async (req, res) => {
  try {
    const counts = await Inventory.getDashboardCounts();
    res.status(200).json({
      message: 'Inventory dashboard retrieved successfully',
      dashboard: counts
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};