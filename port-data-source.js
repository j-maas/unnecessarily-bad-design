const ImagePool = require('@squoosh/lib').ImagePool;
const { inputFolder, destinationFolder, getSizes } = require("./scripts/processImages");

const imagePool = new ImagePool();

module.exports =
/**
 * @param { unknown } fromElm
 * @returns { Promise<unknown> }
 */
{
    imageSources: async function (filePath) {
        const picturePath = `${destinationFolder}/${filePath}.jpg`;
        const image = imagePool.ingestImage(picturePath);
        const info = (await image.decoded).bitmap;
        const sizes = getSizes(info.width, info.height);
        return [
            { src: `${filePath}.jpg`, width: sizes.original.width, height: sizes.original.height },
            { src: `${filePath}-large.jpg`, width: sizes.large.width, height: sizes.large.height },
            { src: `${filePath}-medium.jpg`, width: sizes.medium.width, height: sizes.medium.height },
            { src: `${filePath}-small.jpg`, width: sizes.small.width, height: sizes.small.height },
            { src: `${filePath}.webp`, width: sizes.original.width, height: sizes.original.height },
            { src: `${filePath}-large.webp`, width: sizes.large.width, height: sizes.large.height },
            { src: `${filePath}-medium.webp`, width: sizes.medium.width, height: sizes.medium.height },
            { src: `${filePath}-small.webp`, width: sizes.small.width, height: sizes.small.height },
        ];
    },
};