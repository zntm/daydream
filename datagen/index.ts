import { existsSync, readdirSync, statSync } from "fs";
import { join } from "path";

const recursiveSort = (obj: any): any => {
    if (typeof obj === "object" && !Array.isArray(obj)) {
        obj = Object.fromEntries(Object.entries(obj).sort());

        for (const [key, value] of Object.entries(obj)) {
            obj[key] = recursiveSort(value);
        }
    }

    return obj;
};

const processExports = async (dir: string, type: string) => {
    const exportsDir = join(__dirname, `./src/${dir}/${type}/exports`);
    if (!existsSync(exportsDir)) return;

    for (const e of readdirSync(exportsDir)) {
        const s = join(exportsDir, e);

        if (!statSync(s).isFile() || !e.endsWith(".ts")) continue;

        console.log(`Processing: ${dir}/${type}/${e}`);

        try {
            const module = await import(s);
            let datagen = module.default;

            if (!datagen) {
                console.error(`Default export not found in ${s}`);
                continue;
            }

            if (datagen instanceof Promise) {
                datagen = await datagen;
            }

            for (const d of Array.isArray(datagen)
                ? datagen.flat(Infinity)
                : [datagen]) {
                d.data = recursiveSort(d.data);

                const destination = join(
                    __dirname,
                    `./generated/${dir}/${type}/${d.destination}`,
                );

                // Ensure directory exists
                const destDir = join(destination, "..");
                if (!existsSync(destDir)) {
                    await Bun.write(join(destDir, ".keep"), ""); // Simple way to ensure dir exists via Bun.write? No, let's use fs.
                }

                Bun.write(destination, JSON.stringify(d.data, null, "    "));
            }
        } catch (error) {
            console.error(`Error generating ${dir}/${type}/${e}:`, error);
        }
    }
};

const run = async () => {
    for (const dir of ["assets", "data"]) {
        const baseDir = join(__dirname, `./src/${dir}`);
        if (!existsSync(baseDir)) continue;

        for (const type of readdirSync(baseDir)) {
            const typePath = join(baseDir, type);
            if (!statSync(typePath).isDirectory()) continue;

            await processExports(dir, type);
        }
    }
    console.log("Datagen completed.");
};

run();
