-- sample data (INSERT statements)

INSERT INTO users (Role, Name, Username, PinCodeHash) VALUES
('admin', 'adminname', 'adminuname', '$2b$10$M8xDct06D.dhQ5yjvlKLau9af36nd3v9MpuLWgiYd4W83ZdJ29mcS' ),
('cashier', 'cashiername', 'cashieruname', '$2b$10$6M7SBGl/0ST4iAqupzyfD.y09r0r14N1dsm/tyRZ2GiqJxcx7IeMa' );


-- Category seed data
INSERT INTO categories (CategoryName, Description) VALUES
('Beverages', 'Non-alcoholic drinks. Soda, Water, Juice, etc'),
('Liquor & Tobacco', 'Alcoholic drinks and Cigarettes. Beer, Gin, Wine, etc'),
('Snacks & Sweets', 'Chips, Cookies, Chocolate, Candies'),
('Fresh & Prepared', 'Meals, Deli, Grab & Go'),
('Pantry Staples', 'Canned Goods, Rice, Oil'),
('Frozen Goods', 'Ice Cream, Frozen Meats'),
('Personal Care', 'Soap, Shampoo, Hygiene, etc'),
('Household Care', 'Dishwashing Liquid, Bleach, etc'),
('Miscellaneous', 'General Merchandise');