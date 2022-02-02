const { Client } = require('pg');

const iterations = 1000; // number of times to insert randomized data
const inserts = 10000; // 10,000 rows
const keys = 100; // 100 unique keys will be used (100 rows each iteration)

const client = new Client({
    host: '127.0.0.1',
    port: 5432,
    user: 'tbd',
    password: 'tbd',
    database: 'tbd'
});

console.log('Connecting to access node...');
client.connect(async err => {
    if (err) throw err;

    console.log('Started at', new Date().toLocaleTimeString());
    for (let i = 0; i < iterations; i++) await insert(i + 1);
    console.log('Ended at', new Date().toISOString());

    process.exit(0);
});

async function insert(iteration) {
    let query = 'INSERT INTO samples (timestamp, key, value) VALUES ';
    let date = new Date();
    for (let i = 0; i < inserts; i++) {
        const mod = i % keys;
        const key = `${iteration}-${mod + 1}`;
        if (mod === 0) date = new Date(date.valueOf() + (iteration * 1000)) // Add one second
        const value = Math.random() * 100;
        query += `('${date.toISOString()}', '${key}', ${value})`;
        if (i < inserts - 1) query += ', ';
        else query += ';';
    }

    await client.query(query);

    console.log(`${iteration.toString().padStart(iterations.toString().length, '0')} / ${iterations} - ${((iteration / iterations) * 100).toFixed(1)}%`);
}
