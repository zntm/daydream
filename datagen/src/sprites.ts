import { DatagenReturnData } from "../index";
import * as ExifReader from "exifreader";
import { Dirent, readdirSync } from "fs";
import { join } from "path";

export class SpriteAsset {
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

const getXOffset = (value: string, exif: ExifReader.Tags) => {
    if (value === "0" || value === "-l") {
        return 0;
    }

    if (value === "-c") {
        return Math.floor((exif["Image Width"]?.value ?? 0) / 2);
    }

    if (value === "-r") {
        return Math.floor(exif["Image Width"]?.value ?? 0);
    }

    return parseInt(value);
};

const getYOffset = (value: string, exif: ExifReader.Tags) => {
    if (value === "0" || value === "-t") {
        return 0;
    }

    if (value === "-m") {
        return Math.floor((exif["Image Height"]?.value ?? 0) / 2);
    }

    if (value === "-b") {
        return Math.floor(exif["Image Height"]?.value ?? 0);
    }

    return parseInt(value);
};

export default readdirSync(join(__dirname, "./sprites"), {
    recursive: true,
    withFileTypes: true,
})
    .filter((file: Dirent) => !file.isDirectory())
    .map(async (file: Dirent) => {
        let [name, xoffset, yoffset, length]: any = file.name
            .replace(/\.[a-z]+$/, "")
            .split(" ");

        const f = Bun.file(`${file.parentPath}\\${file.name}`);

        const arrayBuffer = await f.arrayBuffer();
        const exif = ExifReader.load(arrayBuffer);

        xoffset = getXOffset(xoffset, exif) ?? 0;
        yoffset = getYOffset(yoffset, exif) ?? 0;

        const data = new SpriteAsset(
            xoffset,
            yoffset,
            length !== undefined ? parseInt(length) : undefined,
        );

        if (name.startsWith("#")) {
            name = name.substring(1);

            data.setIsTile();
        }

        const dir = `${file.parentPath.substring(
            join(__dirname, "./").length,
        )}/${name}.png`;

        Bun.write(join(__dirname, `../generated/assets/${dir}`), arrayBuffer, {
            createPath: true,
        });

        return new DatagenReturnData(`generated/assets/${dir}.json`, data);
    });

/*
export default readdirSync(join(__dirname, "./sprites"), {
    recursive: true,
    withFileTypes: true,
})
    .filter((file: Dirent) => !file.isDirectory())
    .map((file: Dirent) => {
        let [name, width, height, length, edgePadding]: any = file.name
            .replace(/\.[a-z]+$/, "")
            .split(" ");

        width = parseInt(width.trim());
        height = parseInt(height.trim());

        length = length !== undefined ? parseInt(length.trim()) : 1;

        if (edgePadding) {
            edgePadding = parseInt(edgePadding.trim());
        }

        const dir = `${file.parentPath.substring(
            join(__dirname, "./").length,
        )}\\${name}${file.name.replace(/^[a-zA-Z0-9\,\ ]+/g, "")}`;

        const f = Bun.file(`${file.parentPath}\\${file.name}`);

        f.arrayBuffer()
            .then((arrayBuffer) => {
                Bun.write(
                    join(__dirname, `../generated/assets/${dir}`),
                    arrayBuffer,
                    {
                        createPath: true,
                    },
                );
            })
            .catch((error) => {
                console.error(`Error writing file ${dir}: ${error}`);
            });

        return new DatagenReturnData(
            `generated/assets/${dir}.json`,
            new SpriteAsset(width, height, length, edgePadding),
        );
    })
    .filter((data) => data !== undefined);
    */
