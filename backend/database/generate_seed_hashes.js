const bcrypt = require('bcrypt');

// users

const seedUsers = [
    { Role: 'admin', Name: 'adminname', UserName: 'adminuname', PinCode: '1234'},
    { Role: 'cashier', Name: 'cashiername', UserName: 'cashieruname', PinCode: '1111'},

];

async function generatehashes() {
    console.log('Generating hashes for seed data..\n');

     for (const user of seedUsers) {
        const hash = await bcrypt.hash(user.PinCode, 10);
        console.log(`Role: ${user.Role}`);
        console.log(`Name: ${user.Name}`);
        console.log(`UserName: ${user.UserName}`);
        console.log(`Hash: ${hash}`);
        console.log('---');
    }
    
}

generatehashes();