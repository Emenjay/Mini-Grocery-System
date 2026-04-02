const express = require('express'); // for easier api building
const cors = require('cors');
require('dotenv').config();
const db = require('./config/db'); // import db config

const authRoutes = require('./routes/authRoutes'); // import auth route
const shiftRoutes = require('./routes/shiftRoutes'); // import shift route

// testing code

const app = express();
app.use(cors()); // allows flutter to call api
app.use(express.json());

// login auth
app.use('/api/auth', authRoutes);

// shift route
app.use('/api/shift', shiftRoutes);

app.listen(process.env.PORT, () => {
  console.log(`Server running on port ${process.env.PORT}`);
});



// Test query
// db.query('SELECT 1')
//   .then(() => console.log('✅ MySQL Connected!'))
//   .catch(err => console.error('❌ DB Error:', err));