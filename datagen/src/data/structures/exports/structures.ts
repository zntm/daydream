import { readdirSync } from "fs";
import { join } from "path";

export default readdirSync(join(__dirname, ".."))
    .map((file) => {
        if (!file.endsWith(".ts") || file === "exports") return null;
        return require(join(__dirname, "..", file)).default;
    })
    .filter((structure) => structure)
    .flat();
