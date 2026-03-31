const express = require('express'); // for easier api building
const cors = require('cors');
require('dotenv').config();

// testing code

const app = express();
app.use(cors()); // allows flutter to call api
app.use(express.json());

app.listen(process.env.PORT, () => {
  console.log(`Server running on port ${process.env.PORT}`);
});