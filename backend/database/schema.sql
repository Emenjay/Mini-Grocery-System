-- Table structures (CREATE statements)
-- Copy-paste, and run manually in phpMyAdmin, in SQL tab

CREATE DATABASE IF NOT EXISTS dingle_plaza_mart;
USE dingle_plaza_mart

-- Create tables

-- 1. Role
CREATE TABLE role (
  role_id INT AUTO_INCREMENT PRIMARY KEY,
  role_name VARCHAR(50) NOT NULL
);

-- 2. Category
CREATE TABLE category (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL
);

-- 3. User
CREATE TABLE user (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  role_id INT NOT NULL,
  username VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  account_status BOOLEAN DEFAULT TRUE,
  created_at DATETIME DEFAULT NOW(),
  FOREIGN KEY (role_id) REFERENCES role(role_id)
);

-- 4. Attendance
CREATE TABLE attendance (
  attendance_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  clock_in_timestamp DATETIME NOT NULL,
  clock_out_timestamp DATETIME,
  FOREIGN KEY (user_id) REFERENCES user(user_id)
);

-- 5. Product
CREATE TABLE product (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  category_id INT NOT NULL,
  product_name VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  markup_price DECIMAL(10,2) NOT NULL,
  unit_measurement VARCHAR(50),
  FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- 6. Inventory
CREATE TABLE inventory (
  inventory_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  stock_quantity INT DEFAULT 0,
  spoilage_date DATE,
  stock_status ENUM('In Stock', 'Low Stock', 'Out of Stock') DEFAULT 'Out of Stock',
  last_updated DATETIME DEFAULT NOW(),
  FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- 7. Payment
CREATE TABLE payment (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  payment_method ENUM('Cash', 'GCash') NOT NULL,
  reference_number VARCHAR(100)
);

-- 8. Transaction
CREATE TABLE transaction (
  transaction_id INT AUTO_INCREMENT PRIMARY KEY,
  cart_no VARCHAR(20),
  user_id INT NOT NULL,
  payment_id INT,
  total_amount DECIMAL(10,2),
  amount_received DECIMAL(10,2),
  change_amount DECIMAL(10,2),
  cash_in DECIMAL(10,2),
  cash_out DECIMAL(10,2),
  date_time DATETIME DEFAULT NOW(),
  transaction_type ENUM('sale', 'cash_in', 'cash_out') NOT NULL,
  FOREIGN KEY (user_id) REFERENCES user(user_id),
  FOREIGN KEY (payment_id) REFERENCES payment(payment_id)
);

-- 9. Transaction Detail
CREATE TABLE transaction_detail (
  detail_id INT AUTO_INCREMENT PRIMARY KEY,
  transaction_id INT NOT NULL,
  product_id INT,
  product_name VARCHAR(100) NOT NULL,
  quantity_sold INT NOT NULL,
  retail_price DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES transaction(transaction_id),
  FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE SET NULL
);

-- 10. Notification
CREATE TABLE notification (
  notification_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  message VARCHAR(255) NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at DATETIME DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES user(user_id)
);