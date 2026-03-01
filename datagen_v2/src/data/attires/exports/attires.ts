import { DatagenReturnData } from "../../../lib";
import { readdirSync } from "fs";
import { join } from "path";
import { Attire } from "../lib/Attire";

export default [
    ["eyes", "footwear", "hair", "pants", "shirt", "shirt_detail"].map((type) =>
        readdirSync(
            join(__dirname, `../../../assets/sprites/exports/attire/${type}`),
        )
            .map((file) => {
                const basePath = join(
                    __dirname,
                    `../../../assets/sprites/exports/attire/${type}/${file}`,
                );

                let colour = `phantasia:attire/${type}/${file}/colour`;

                let white: string | string[] | undefined;
                if (readdirSync(basePath).some((f) => f.startsWith("white"))) {
                    white = `phantasia:attire/${type}/${file}/white`;
                }

                return new DatagenReturnData(
                    `${type}/${file}.json`,
                    new Attire(
                        colour,
                        `phantasia:attire/${type}/${file}/icon`,
                        white,
                    ),
                );
            })
            .filter((attire) => attire),
    ),
].flat(Infinity);
