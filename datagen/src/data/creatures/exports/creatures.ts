import { readdirSync } from "fs";
import { join } from "path";

export default readdirSync(join(__dirname, ".."))
    .map((type) => {
        if (!type.endsWith(".ts") || type === "exports") return null;
        return require(join(__dirname, "..", type)).default;
    })
    .filter((biome) => biome)
    .flat();
