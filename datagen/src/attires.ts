import { DatagenReturnData } from "../index";
import { existsSync, readdir, readdirSync } from "fs";
import { join } from "path";

export class Attire {
    private colour: string;
    private icon: string;
    private white?: string;

    constructor(colour: string, icon: string, white?: string) {
        this.colour = colour;
        this.icon = icon;
        this.white = white;
    }
}

export default [
    ["eyes", "footwear", "hair", "pants", "shirt", "shirt_detail"].map((type) =>
        readdirSync(join(__dirname, `./sprites/attire/${type}`))
            .map(
                (file) =>
                    new DatagenReturnData(
                        `generated/data/attires/${type}/${file}.json`,
                        new Attire(
                            `phantasia:attire/${type}/${file}/colour`,
                            `phantasia:attire/${type}/${file}/icon`,
                            existsSync(
                                join(
                                    __dirname,
                                    `./sprites/attire/${type}/${file}/white.png`,
                                ),
                            )
                                ? `phantasia:attire/${type}/${file}/white`
                                : undefined,
                        ),
                    ),
            )
            .filter((attire) => attire),
    ),
].flat();
