import * as fs from 'fs/promises';
import * as path from 'path';
import glob from 'glob-promise';
import { ImagePool } from '@squoosh/lib';
import { optimize } from 'svgo';

const inputFolderPath = "images";
const destinationFolder = "public";

// Process pictures
const picturePaths = await glob(`${inputFolderPath}/**/*.@(jpg|jpeg|png|webp)`);
console.log(`Found ${picturePaths.length} pictures.`);
const imagePool = new ImagePool();
await Promise.all(picturePaths.map(async (path, index) => {
    console.log(`${index + 1}) ${path}`);
    await processPicture(imagePool, path, getDestinationPath(path));
}));
imagePool.close();

// Process vector graphics
const svgPaths = await glob(`${inputFolderPath}/**/*.svg`);
console.log(`Found ${svgPaths.length} vector graphics.`);
await Promise.all(svgPaths.map(async (path, index) => {
    console.log(`${index + 1}) ${path}`);
    const svgString = await fs.readFile(path);
    const result = optimize(svgString, {});
    const optimizedSvgString = result.data;
    await writeFile(getDestinationPath(path), optimizedSvgString);
}));

function getDestinationPath(filePath) {
    let relativePath = path.relative(inputFolderPath, filePath);
    return `${destinationFolder}/${relativePath}`;
}

async function processPicture(imagePool, picturePath, destinationFolderPath) {
    const image = imagePool.ingestImage(picturePath);

    const extension = path.extname(picturePath);
    const fileName = path.basename(picturePath, extension);

    const destinationBase = `${destinationFolderPath}/${fileName}`;

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
    const decoded = await image.decoded;

    // Image sizes are based on common device screen sizes as described in https://docs.microsoft.com/en-us/windows/apps/design/layout/screen-sizes-and-breakpoints-for-responsive-design.
    const resizeLarge = {
        enabled: true,
    };
    const resizeMedium = {
        enabled: true,
    };
    const resizeSmall = {
        enabled: true
    };
    // TODO: Check this logic.
    if (decoded.width >= decoded.height) {
        resizeLarge.width = 1920;
        resizeMedium.width = 960;
        resizeSmall.width = 360;
    } else {
        resizeLarge.height = 1080;
        resizeMedium.height = 540;
        resizeSmall.height = 640;
    }

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

async function writeFile(filePath, content) {
    const folderPath = path.dirname(filePath);
    await fs.mkdir(folderPath, { recursive: true });
    await fs.writeFile(filePath, content);
}