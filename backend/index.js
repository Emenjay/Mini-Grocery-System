const express = require('express'); // for easier api building
const cors = require('cors');
require('dotenv').config();

// import routes
const authRoutes = require('./routes/authRoutes');
const attendanceRoutes = require('./routes/attendanceRoutes');
const productRoutes = require('./routes/productRoutes');
const checkoutRoutes = require('./routes/checkoutRoutes');
const userRoutes = require('./routes/userRoutes');
const configRoutes = require('./routes/configRoutes');
const inventoryRoutes = require('./routes/inventoryRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const notificationRoutes = require('./routes/notificationRoutes');


const app = express();
app.use(cors()); // allows flutter to call api
app.use(express.json());

// initialize SSE client map — keyed by userID, value is the res object
// used by pushToAdmins() in notificationController to send real-time events
app.set('sseClients', new Map());

// serve the uploads folder so Flutter can fetch images by URL
// e.g. http://192.168.1.x:3000/uploads/profiles/profile-123.jpg
app.use('/uploads', express.static('uploads'));

// login route
app.use('/api/auth', authRoutes);

// user routes
app.use('/api/users', userRoutes);

// attendance route
app.use('/api/attendance', attendanceRoutes);

// product route
app.use('/api/inventory', productRoutes);

// checkout route
app.use('/api/checkout', checkoutRoutes);

// config route
app.use('/api/config', configRoutes);

// inventory route
app.use('/api/inventory-dashboard', inventoryRoutes);

// dashboard route
app.use('/api/dashboard', dashboardRoutes);

// notification routes
app.use('/api/notification', notificationRoutes);

// Russ's update
// run daily checks for expired products and low stock
const db = require('./config/db');
const {
  checkAndNotifyExpiredProducts,
  checkAndNotifyLowStock,
  checkAndNotifyOutOfStock,
} = require('./controllers/notificationController');

// run stock and expiry checks once every 24 hours
async function runDailyChecks() {
  try {
    await checkAndNotifyExpiredProducts(app);

    const [lowStock] = await db.query(
      `SELECT p.product_id FROM product p
       JOIN inventory i ON p.product_id = i.product_id
       WHERE i.stock_quantity <= 15 AND i.stock_quantity > 0`
    );
    for (const p of lowStock) await checkAndNotifyLowStock(p.product_id, app);

    const [outOfStock] = await db.query(
      `SELECT p.product_id FROM product p
       JOIN inventory i ON p.product_id = i.product_id
       WHERE i.stock_quantity <= 0`
    );
    for (const p of outOfStock) await checkAndNotifyOutOfStock(p.product_id, app);
  } catch (err) {
    console.error('Daily notification check failed:', err);
  }
}

// run immediately on startup, then every 24 hours
runDailyChecks();
setInterval(runDailyChecks, 24 * 60 * 60 * 1000);
// end of Russ's update

app.listen(process.env.PORT, () => {
  console.log(`Server running on port ${process.env.PORT}`);
});