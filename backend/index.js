const express = require("express");

// test
const app = express();

port = 3000;

app.listen(port, () =>{
    console.log(`Successfully connected to ${port}`)
});