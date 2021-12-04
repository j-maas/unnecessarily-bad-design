const { ImagePool } = require('@squoosh/lib');
const { cpus } = require('os');
const { process } = require('./processImages');

const imagePool = new ImagePool(cpus().length);

process(imagePool);

imagePool.close();