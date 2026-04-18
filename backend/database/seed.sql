-- Insert seed data

--- Mandatory ---
-- Roles
INSERT INTO role (role_name) VALUES
('Admin'),
('Cashier'),
('Inventory');

-- Categories
INSERT INTO category (category_name) VALUES
('Beverages'),
('Liquor & Tobacco'),
('Snacks & Sweets'),
('Fresh & Prepared'),
('Pantry Staples'),
('Frozen Goods'),
('Personal Care'),
('Household Care'),
('Miscellaneous');


--- For testing ---

-- seed user data
INSERT INTO user (role_id, username, password, full_name) VALUES (1, 'adminuname', '$2b$10$CRl4l6lOVhXSRB9BEdVvguZetaFKqLnGfsYVCs0v2XlNVoE5rlDrW', 'Admin Name');
INSERT INTO user (role_id, username, password, full_name) VALUES (2, 'cashieruname', '$2b$10$PBHC/pukZf7HxzY5vACwY.wvdXCU4ROkMucNRXVsJDhqe.dXA4gtG', 'Cashier Name');
INSERT INTO user (role_id, username, password, full_name) VALUES (3, 'inventoryuname', '$2b$10$nY2.BEbyDjIl7CtFk2Zxy.dWCv4sgnJJtSK5.dJ/B2h/5ICQDiE9W', 'Inventory Name');