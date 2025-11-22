import { DatagenReturnData } from "../../index";
import { existsSync, readdir, readdirSync, statSync } from "fs";
import { join } from "path";

export class Attire {
    private colour: string | string[];
    private icon: string;
    private white?: string | string[];

    constructor(colour: string | string[], icon: string, white?: string | string[]) {
        this.colour = colour;
        this.icon = icon;
        this.white = white;
    }
}

export default [
    ["eyes", "footwear", "hair", "pants", "shirt", "shirt_detail"].map((type) =>
        readdirSync(join(__dirname, `./sprites/attire/${type}`))
            .map((file) => {
                const basePath = join(__dirname, `./sprites/attire/${type}/${file}`);

                // Check if colour is a directory with numbered sprites or a single file
                let colour: string | string[];
                const colourDir = join(basePath, "colour");
                const colourFile = join(basePath, "colour.png");

                if (existsSync(colourDir) && statSync(colourDir).isDirectory()) {
                    // Get all files in the colour directory and filter for numbered sprites
                    const files = readdirSync(colourDir);
                    const colourSprites: string[] = [];

                    // Find all numbered sprite files (e.g., "0.png", "0 -c 24.png", etc.)
                    for (let i = 0; i < 10; i++) { // Check up to 10 sprites
                        const matchingFile = files.find(f => f.match(new RegExp(`^${i}\\s`)) || f === `${i}.png`);
                        if (matchingFile) {
                            colourSprites.push(`phantasia:attire/${type}/${file}/colour/${i}`);
                        } else {
                            break; // Stop when we don't find the next sequential number
                        }
                    }

                    colour = colourSprites.length > 0 ? colourSprites : `phantasia:attire/${type}/${file}/colour`;
                } else {
                    colour = `phantasia:attire/${type}/${file}/colour`;
                }

                // Check if white is a directory with numbered sprites or a single file
                let white: string | string[] | undefined;
                const whiteDir = join(basePath, "white");
                const whiteFile = join(basePath, "white.png");

                if (existsSync(whiteDir) && statSync(whiteDir).isDirectory()) {
                    // Get all files in the white directory and filter for numbered sprites
                    const files = readdirSync(whiteDir);
                    const whiteSprites: string[] = [];

                    // Find all numbered sprite files (e.g., "0.png", "0 -c 24.png", etc.)
                    for (let i = 0; i < 10; i++) { // Check up to 10 sprites
                        const matchingFile = files.find(f => f.match(new RegExp(`^${i}\\s`)) || f === `${i}.png`);
                        if (matchingFile) {
                            whiteSprites.push(`phantasia:attire/${type}/${file}/white/${i}`);
                        } else {
                            break; // Stop when we don't find the next sequential number
                        }
                    }

                    white = whiteSprites.length > 0 ? whiteSprites : undefined;
                } else if (existsSync(whiteFile)) {
                    white = `phantasia:attire/${type}/${file}/white`;
                }

                return new DatagenReturnData(
                    `generated/data/attires/${type}/${file}.json`,
                    new Attire(
                        colour,
                        `phantasia:attire/${type}/${file}/icon`,
                        white,
                    ),
                );
            })
            .filter((attire) => attire),
    ),
].flat();
