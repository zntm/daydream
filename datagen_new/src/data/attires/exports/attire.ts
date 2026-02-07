import { DatagenReturnData } from "../../../lib";
import { readdirSync } from "fs";
import { join } from "path";
import { Attire } from "../lib/Attire";

const types = ["eyes", "footwear", "hair", "pants", "shirt", "shirt_detail"];
const attireSourceDir = join(
    __dirname,
    "../../../../../datagen/src/data/sprites/attire"
);

export default types
    .map((type) => {
        const typePath = join(attireSourceDir, type);
        try {
            return readdirSync(typePath).map((file) => {
                const basePath = join(typePath, file);

                const colour = `phantasia:attire/${type}/${file}/colour`;

                let white: string | undefined;
                try {
                    if (
                        readdirSync(basePath).some((f) =>
                            f.startsWith("white")
                        )
                    ) {
                        white = `phantasia:attire/${type}/${file}/white`;
                    }
                } catch (e) {
                    // Ignore errors if directory doesn't exist or is a file
                }

                return new DatagenReturnData(
                    `${type}/${file}.json`,
                    new Attire(
                        colour,
                        `phantasia:attire/${type}/${file}/icon`,
                        white
                    )
                );
            });
        } catch (e) {
            console.error(`Error reading attire type ${type}:`, e);
            return [];
        }
    })
    .flat();
