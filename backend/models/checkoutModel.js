const db = require('../config/db');

const checkout = async (req, res) => {
    const { transactionNo, shiftID, paymentMethod, amountReceived, cart } = req.body;

let totalAmount = 0;

for (let item of cart) {
    totalAmount += item.qty * item.price;
}

const changeAmount = amountReceived - totalAmount;

const transactionResult = await db.query(
`INSERT INTO Transactions
(TransactionNo, ShiftID, TransactionDate, TotalAmount, PaymentMethod, AmountRecieved, ChangeAmount)
VALUES (?, ?, NOW(), ?, ?, ?, ?)`,
[transactionNo, shiftID, totalAmount, paymentMethod, amountReceived, changeAmount]
);

const transactionID = transactionResult.insertId;

for (let item of cart) {

    await db.query(
    `INSERT INTO TransactionItems (TransactionID, ProductID, Qty, Price)
     VALUES (?, ?, ?, ?)`,
    [transactionID, item.productID, item.qty, item.price]
    );

    await db.query(
    `UPDATE Products SET Stock = Stock - ? WHERE ProductID = ?`,
    [item.qty, item.productID]
    );
}

res.json({
message: "Transaction completed",
transactionID: transactionID,
change: changeAmount
});

};

module.exports = checkout;