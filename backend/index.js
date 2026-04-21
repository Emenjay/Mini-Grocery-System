const express = require('express'); // for easier api building
const cors = require('cors');
require('dotenv').config();

// import routes
const authRoutes = require('./routes/authRoutes');
const attendanceRoutes = require('./routes/attendanceRoutes');
const productRoutes = require('./routes/productRoutes');
const checkoutRoutes = require('./routes/checkoutRoutes');
const userRoutes = require('./routes/userRoutes');

// testing code

const app = express();
app.use(cors()); // allows flutter to call api
app.use(express.json());

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



app.listen(process.env.PORT, () => {
  console.log(`Server running on port ${process.env.PORT}`);
});



// Test query
// db.query('SELECT 1')
//   .then(() => console.log('✅ MySQL Connected!'))
//   .catch(err => console.error('❌ DB Error:', err));