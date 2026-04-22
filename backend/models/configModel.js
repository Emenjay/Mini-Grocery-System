const db = require('../config/db');

const Config = {

  // get a single config value by key
  get: async (key) => {
    const [rows] = await db.query(
      'SELECT config_value FROM config WHERE config_key = ?',
      [key]
    );
    return rows[0] ? rows[0].config_value : null;
  },

  // update a single config value by key
  update: async (key, value) => {
    const [result] = await db.query(
      'UPDATE config SET config_value = ? WHERE config_key = ?',
      [value, key]
    );
    return result.affectedRows;
  },

  // get all config values (for displaying current settings to admin)
  getAll: async () => {
    const [rows] = await db.query('SELECT * FROM config');
    return rows;
  }

};

module.exports = Config;