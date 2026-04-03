const db = require('../config/db');

const Shift = {

    // find user by yd
    findUserByID: async (userID) => {
        const [rows] = await db.query(
            'SELECT * FROM users WHERE UserID = ?', [userID]
        );
        return rows[0];
    },
    // start shift, input user id and starting cash
    startShift: async (userID, startingCash) => {
        const [result] = await db.query(
            'INSERT INTO attendance_shifts (UserID, Time_In, StartingCash) VALUES (?, NOW(), ?)',
            [userID, startingCash]
        );
        return result.insertId
    },

    // end shift, input ending cash and total sales of current session/shift
    endShift: async (shiftID, endingCash, totalSales) => {
        const [result] = await db.query(
            'UPDATE attendance_shifts SET Time_Out = NOW(), EndingCash = ?, TotalSales = ? WHERE ShiftID = ?',
            [endingCash, totalSales, shiftID]
        );
        return result.affectedRows;
    },

    // find active user by finding shifts with no timeout yet
    findActiveShift: async (userID) => {
        const [rows] = await db.query(
            'SELECT * FROM attendance_shifts WHERE UserID = ? AND Time_Out IS NULL',
            [userID]
        );
        return rows[0];
    },

    // calculate total sales from all transactions made in current shift
    calculateTotalSales: async (shiftID) => {
        const [rows] = await db.query(
            'SELECT COALESCE(SUM(TotalAmount), 0) AS totalSales FROM transactions WHERE ShiftID = ?',
            [shiftID]
        );
        return rows[0].totalSales;
    },
}

module.exports = Shift;