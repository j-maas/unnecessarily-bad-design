const { Image } = require("@y0hy0h/squoosh");
const { inputFolder, destinationFolder, getSizes } = require("./scripts/processImages");

module.exports =
/**
 * @param { unknown } fromElm
 * @returns { Promise<unknown> }
 */
{
    imageSources: async function (filePath) {
        const picturePath = `${destinationFolder}/${filePath}.jpg`;
        const image = new Image(picturePath);
        const info = (await image.decoded).bitmap;
        const sizes = getSizes(info.width, info.height);
        return [
            { src: `${filePath}.jpg`, width: sizes.original.width, height: sizes.original.height, mimeType: "image/jpeg" },
            { src: `${filePath}-large.jpg`, width: sizes.large.width, height: sizes.large.height, mimeType: "image/jpeg" },
            { src: `${filePath}-medium.jpg`, width: sizes.medium.width, height: sizes.medium.height, mimeType: "image/jpeg" },
            { src: `${filePath}-small.jpg`, width: sizes.small.width, height: sizes.small.height, mimeType: "image/jpeg" },
            { src: `${filePath}.webp`, width: sizes.original.width, height: sizes.original.height, mimeType: "image/webp" },
            { src: `${filePath}-large.webp`, width: sizes.large.width, height: sizes.large.height, mimeType: "image/webp" },
            { src: `${filePath}-medium.webp`, width: sizes.medium.width, height: sizes.medium.height, mimeType: "image/webp" },
            { src: `${filePath}-small.webp`, width: sizes.small.width, height: sizes.small.height, mimeType: "image/webp" },
        ];
    },
};