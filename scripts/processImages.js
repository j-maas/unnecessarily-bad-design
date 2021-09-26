const fs = require('fs/promises');
const path = require('path');
const glob = require('glob-promise');
const { Image } = require('@j-maas/squoosh');
const { optimize } = require('svgo');

const inputFolder = "images";
const destinationFolder = "public";

async function process() {
    // Process pictures
    const picturePaths = await glob(`${inputFolder}/**/*.@(jpg|jpeg|png|webp)`);
    console.log(`Found ${picturePaths.length} pictures.`);
    for (let filePath of picturePaths) {
        await processPicture(filePath, getDestinationFolderPath(filePath));
    }

    // Process vector graphics
    const svgPaths = await glob(`${inputFolder}/**/*.svg`);
    console.log(`Found ${svgPaths.length} vector graphics.`);
    for (let [index, filePath] of svgPaths.entries()) {
        console.log(`${index + 1}) ${filePath}`);

        const svgString = await fs.readFile(filePath);
        const result = optimize(svgString, {});
        const optimizedSvgString = result.data;

        const destinationPath = `${getDestinationFolderPath(filePath)}/${path.basename(filePath)}`;
        await writeFile(destinationPath, optimizedSvgString);
    };
}

function getDestinationFolderPath(filePath) {
    let relativePath = path.dirname(path.relative(inputFolder, filePath));
    return `${destinationFolder}/${relativePath}`;
}

async function processPicture(picturePath, destinationFolderPath) {
    const extension = path.extname(picturePath);
    const fileName = path.basename(picturePath, extension);
    const destinationBase = `${destinationFolderPath}/${fileName}`;

    // Check if this picture was already processed.
    try {
        const suffixes = [".jpg", "-large.jpg", "-medium.jpg", "-small.jpg",
            ".webp", "-large.webp", "-medium.webp", "-small.webp",
        ];

        for (let suffix of suffixes) {
            const sourceLastModified = (await fs.stat(picturePath)).mtimeMs;
            const destinationLastModified = (await fs.stat(`${destinationBase}${suffix}`)).mtimeMs;
            if (sourceLastModified > destinationLastModified) {
                throw "Process picture";
            }
        };
        // If a path did not exist, we would have thrown an exception by now.
        console.log(`${picturePath} (already processed)`);
        return;
    } catch (e) {
        // Picture was not yet processed, do it now.
    }

    console.log(`${picturePath}`);

    const image = new Image(picturePath);

    const encodeOptions = {
        mozjpeg: {},
        webp: {},
    };

    // Original size
    await image.encode(encodeOptions);
    await Promise.all([
        writeFile(`${destinationBase}.jpg`, (await image.encodedWith.mozjpeg).binary),
        writeFile(`${destinationBase}.webp`, (await image.encodedWith.webp).binary)
    ]);

    // Resize
    const decoded = (await image.decoded).bitmap;

    // Image sizes are based on common device screen sizes as described in https://docs.microsoft.com/en-us/windows/apps/design/layout/screen-sizes-and-breakpoints-for-responsive-design.
    const sizes = getSizes(decoded.width, decoded.height);
    const resizeLarge = {
        enabled: true,
        width: sizes.large.width,
        height: sizes.large.height
    };
    const resizeMedium = {
        enabled: true,
        width: sizes.medium.width,
        height: sizes.medium.height
    };
    const resizeSmall = {
        enabled: true,
        width: sizes.small.width,
        height: sizes.small.height
    };

    await image.preprocess({ resize: resizeLarge });
    await image.encode(encodeOptions);
    await Promise.all([
        writeFile(`${destinationBase}-large.jpg`, (await image.encodedWith.mozjpeg).binary),
        writeFile(`${destinationBase}-large.webp`, (await image.encodedWith.webp).binary)
    ]);

    await image.preprocess({ resize: resizeMedium });
    await image.encode(encodeOptions);
    await Promise.all([
        writeFile(`${destinationBase}-medium.jpg`, (await image.encodedWith.mozjpeg).binary),
        writeFile(`${destinationBase}-medium.webp`, (await image.encodedWith.webp).binary)
    ]);

    await image.preprocess({ resize: resizeSmall });
    await image.encode(encodeOptions);
    await Promise.all([
        writeFile(`${destinationBase}-small.jpg`, (await image.encodedWith.mozjpeg).binary),
        writeFile(`${destinationBase}-small.webp`, (await image.encodedWith.webp).binary)
    ]);
}

function getSizes(width, height) {
    const sizes = {
        original: {
            width: width,
            height: height,
        },
        large: {},
        medium: {},
        small: {}
    };

    const aspectRatio = width / height;
    if (aspectRatio >= 1) {
        sizes.large.width = 1920;
        sizes.large.height = Math.round(1920 / aspectRatio);

        sizes.medium.width = 960;
        sizes.medium.height = Math.round(960 / aspectRatio);

        sizes.small.width = 360;
        sizes.small.height = Math.round(360 / aspectRatio);
    } else {
        sizes.large.width = Math.round(1080 * aspectRatio);
        sizes.large.height = 1080;

        sizes.medium.width = Math.round(540 * aspectRatio);
        sizes.medium.height = 540;

        sizes.small.width = Math.round(640 * aspectRatio);
        sizes.small.height = 640;
    }

    return sizes;
}

async function writeFile(filePath, content) {
    const folderPath = path.dirname(filePath);
    await fs.mkdir(folderPath, { recursive: true });
    await fs.writeFile(filePath, content);
}

module.exports = {
    inputFolder: inputFolder,
    destinationFolder,
    process,
    getSizes,
};