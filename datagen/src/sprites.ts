import { DatagenReturnData } from "../index";
import { Dirent, readdirSync } from "fs";
import { join } from "path";

export class SpriteAsset {
    private width: number;
    private height: number;
    private length: number;
    private edge_padding?: number;

    constructor(
        width: number,
        height: number,
        length: number = 1,
        edge_padding?: number,
    ) {
        this.width = width;
        this.height = height;
        this.length = length;

        if (edge_padding !== undefined) {
            this.edge_padding = edge_padding;
        }
    }
}

export default readdirSync(join(__dirname, "./sprites"), {
    recursive: true,
    withFileTypes: true,
})
    .filter((file: Dirent) => !file.isDirectory())
    .map((file: Dirent) => {
        let [name, width, height, length, edgePadding]: any = file.name
            .replace(/\.[a-z]+$/, "")
            .split(",");

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
