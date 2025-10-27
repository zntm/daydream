import { DatagenReturnData } from "../index";
import * as ExifReader from "exifreader";
import { Dirent, readdirSync } from "fs";
import { join } from "path";

export class Sprite {
    private xoffset: number;
    private yoffset: number;
    private length: number;
    private is_tile?: boolean;

    constructor(xoffset: number, yoffset: number, length: number = 1) {
        this.xoffset = xoffset;
        this.yoffset = yoffset;
        this.length = length;
    }

    setIsTile() {
        this.is_tile = true;
        return this;
    }
}

const getXOffset = (value: string, length: number, exif: ExifReader.Tags) => {
    if (value === "0" || value === "-l") {
        return 0;
    }

    const imageWidth = exif["Image Width"]?.value ?? 0;

    if (value === "-c") {
        return Math.floor(imageWidth / (length * 2));
    }

    if (value === "-r") {
        return Math.floor(imageWidth / length);
    }

    return parseInt(value);
};

const getYOffset = (value: string, exif: ExifReader.Tags) => {
    if (value === "0" || value === "-t") {
        return 0;
    }

    const imageHeight = exif["Image Height"]?.value ?? 0;

    if (value === "-m") {
        return Math.floor(imageHeight / 2);
    }

    if (value === "-b") {
        return Math.floor(imageHeight);
    }

    return parseInt(value);
};

const getMetadata = async (sourcePath: string) => {
    const f = Bun.file(sourcePath);
    const arrayBuffer = await f.arrayBuffer();
    const exif = ExifReader.load(arrayBuffer);
    return { exif, arrayBuffer };
};

const sequentialRegex = /^(\d+)(.*)\.png$/;

const sourceImageDir = join(__dirname, "./sprites");
const destImageDir = join(__dirname, "../generated/assets/sprites");

const allFiles = readdirSync(sourceImageDir, {
    recursive: true,
    withFileTypes: true,
}).filter((file) => !file.isDirectory() && file.name.endsWith(".png"));

const individualFiles: Dirent[] = [];

const imageGroups = new Map<string, Dirent[]>();

for (const file of allFiles) {
    const match = file.name.match(sequentialRegex);
    const relDir = file.parentPath.replace(sourceImageDir, "").substring(1);

    if (match) {
        const groupKey = relDir;

        if (!imageGroups.has(groupKey)) {
            imageGroups.set(groupKey, []);
        }

        imageGroups.get(groupKey)!.push(file);
    } else {
        individualFiles.push(file);
    }
}

const individualPromises = individualFiles.map(async (file) => {
    const sourcePath = join(file.parentPath, file.name);
    const relDir = file.parentPath.replace(sourceImageDir, "").substring(1);

    let [name, xoffsetStr, yoffsetStr, lengthStr]: any = file.name
        .replace(/\.png$/, "")
        .split(" ");

    const { exif, arrayBuffer } = await getMetadata(sourcePath);

    const isTile = name.startsWith("#");

    let length = lengthStr !== undefined ? parseInt(lengthStr) : 1;
    if (isTile) {
        length *= 5;
    }

    const xoffset = getXOffset(xoffsetStr, length, exif) ?? 0;
    const yoffset = getYOffset(yoffsetStr, exif) ?? 0;

    const data = new Sprite(xoffset, yoffset, length);

    if (isTile) {
        name = name.substring(1);
        data.setIsTile();
    }

    const outputFileName = `${name}.png`;
    const destFilePath = join(destImageDir, relDir, outputFileName);
    const jsonPath = join(
        "generated/assets/sprites",
        relDir,
        `${name}.png.json`,
    ).replace(/\\/g, "/");

    Bun.write(destFilePath, arrayBuffer, { createPath: true }).catch((error) =>
        console.error(`Error writing file ${destFilePath}: ${error}`),
    );

    return new DatagenReturnData(jsonPath, data);
});

const groupPromises = Array.from(imageGroups.entries()).map(
    async ([groupKey, files]) => {
        const destGroupDir = join(destImageDir, groupKey);

        files.sort((a, b) => {
            const aNum = parseInt(a.name.match(sequentialRegex)![1] ?? "0");
            const bNum = parseInt(b.name.match(sequentialRegex)![1] ?? "0");
            return aNum - bNum;
        });

        const fileProcessingPromises = files.map(async (file) => {
            const sourcePath = join(file.parentPath, file.name);

            const parts = file.name.replace(/\.png$/, "").split(" ");
            const [indexStr, xoffsetStr, yoffsetStr, lengthStr] = parts;

            const { exif, arrayBuffer } = await getMetadata(sourcePath);

            const length = lengthStr ? parseInt(lengthStr) : 1;
            const xoffset = getXOffset(xoffsetStr ?? "", length, exif) ?? 0;
            const yoffset = getYOffset(yoffsetStr ?? "", exif) ?? 0;

            const newOutputFileName = `${indexStr}.png`;
            const destPath = join(destGroupDir, newOutputFileName);

            await Bun.write(destPath, arrayBuffer, { createPath: true }).catch(
                (error) =>
                    console.error(`Error writing file ${destPath}: ${error}`),
            );

            return new Sprite(xoffset, yoffset, length);
        });

        const spriteDataArray = await Promise.all(fileProcessingPromises);

        return new DatagenReturnData(
            join("generated/assets/sprites", `${groupKey}.png.json`).replace(
                /\\/g,
                "/",
            ),
            spriteDataArray,
        );
    },
);

export default [...individualPromises, ...groupPromises];
