-- Table structures (CREATE statements)
-- Copy-paste, and run manually in phpMyAdmin, in SQL tab

CREATE DATABASE IF NOT EXISTS dingle_plaza_mart;
USE dingle_plaza_mart

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Role ENUM('admin','cashier','inventory') NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Username VARCHAR(50) NOT NULL UNIQUE,
    PinCodeHash VARCHAR(255) NOT NULL,
    IsActive BOOLEAN DEFAULT FALSE
)