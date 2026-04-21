const db = require('../config/db');

const Transaction = {

	// count all transactions
	getTransactionCount: async () => {
		const [rows] = await db.query(
				'SELECT COUNT(*) AS count FROM transaction'
		);
		return rows[0].count;
	},

	// generate cart number
	generateCartNo: async () => {
		const count = await Transaction.getTransactionCount();
		return `#${String(count + 1).padStart(6, '0')}`;
	},

	// create payment detail
	createPayment: async (paymentMethod, referenceNumber) => {
		const [result] = await db.query(
				`INSERT INTO payment (payment_method, reference_number)
				VALUES (?, ?)`,
				[paymentMethod, referenceNumber || null]
		);
		return result.insertId;
	},

	// create transaction
	createTransaction: async (cartNo, userID, paymentID, totalAmount, amountReceived, changeAmount) => {
		const [result] = await db.query(
		`INSERT INTO transaction (cart_no, user_id, payment_id, total_amount, amount_received, 
				change_amount, transaction_type, date_time)
		VALUES (?, ?, ?, ?, ?, ?, 'sale', NOW())`,
		[cartNo, userID, paymentID, totalAmount, amountReceived, changeAmount]
		);
		return result.insertId;
	},

	// create transaction detail
	createTransactionDetail: async (transactionID, productID, productName, quantitySold, retailPrice, subtotal) => {
		await db.query(
				`INSERT INTO transaction_detail (transaction_id, product_id, product_name, quantity_sold, retail_price, subtotal)
				VALUES (?, ?, ?, ?, ?, ?)`,
				[transactionID, productID, productName, quantitySold, retailPrice, subtotal]
		);
	}
	};

	module.exports = Transaction;