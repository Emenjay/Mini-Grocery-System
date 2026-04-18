const bcrypt = require('bcrypt');

// to run - node database/generate_seed_hashes.js

// role_id: 1 = Admin, 2 = Cashier, 3 = Inventory
const seedUsers = [
  { role_id: 1, full_name: 'Admin Name', username: 'adminuname', password: '1234' },
  { role_id: 2, full_name: 'Cashier Name', username: 'cashieruname', password: '1111' },
  { role_id: 3, full_name: 'Inventory Name', username: 'inventoryuname', password: '2222' },
];

async function generateHashes() {
  console.log('Generating hashes for seed data..\n');

  for (const user of seedUsers) {
    const hash = await bcrypt.hash(user.password, 10);
    console.log(`role_id: ${user.role_id}`);
    console.log(`full_name: ${user.full_name}`);
    console.log(`username: ${user.username}`);
    console.log(`hash: ${hash}`);
    console.log(`SQL: INSERT INTO user (role_id, username, password, full_name) VALUES (${user.role_id}, '${user.username}', '${hash}', '${user.full_name}');`);
    console.log('---');
  }
}

generateHashes();