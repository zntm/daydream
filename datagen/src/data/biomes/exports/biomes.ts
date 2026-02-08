import { readdirSync } from "fs";
import { join } from "path";

export default readdirSync(join(__dirname, "./biomes"))
    .filter(file => file.endsWith(".ts"))
    .flatMap(
        (file) =>
            require(join(__dirname, "./biomes", file))
                .default,
    )
    .flat(Infinity);
