const { ImagePool } = require('@squoosh/lib');
const { cpus } = require('os');
const { process } = require('./processImages');

async function run() {
    const imagePool = new ImagePool(cpus().length);
    await process(imagePool);
    imagePool.close();
}

run().catch(console.error);