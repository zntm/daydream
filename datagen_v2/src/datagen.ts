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

const run = async () => {
    for (const dir of ["assets", "data"]) {
        const baseDir = join(__dirname, dir);
        if (!existsSync(baseDir)) continue;

        for (const type of readdirSync(baseDir)) {
            const exportsDir = join(baseDir, type, "exports");
            if (!existsSync(exportsDir)) continue;

            for (const e of readdirSync(exportsDir)) {
                const s = join(exportsDir, e);

                if (!statSync(s).isFile() || !e.endsWith(".ts")) continue;

                console.log(`Generating: ${dir}/${type}/${e}`);

                try {
                    let datagen = (await import(s)).default;

                    if (datagen instanceof Promise) {
                        datagen = await datagen;
                    }

                    for (const d of Array.isArray(datagen)
                        ? datagen.flat(Infinity)
                        : [datagen]) {
                        if (!d || !d.destination) continue;

                        d.data = recursiveSort(d.data);

                        const destination = join(
                            __dirname,
                            `../generated/${dir}/${type}/${d.destination}`,
                        );

                        // Ensure directory exists
                        const destDir = join(destination, "..");
                        if (!existsSync(destDir)) {
                            // Recursively create directories
                            const fs = await import("fs");
                            fs.mkdirSync(destDir, { recursive: true });
                        }

                        await Bun.write(
                            destination,
                            JSON.stringify(d.data, null, "    "),
                            { mode: 0o644 },
                        );
                    }
                } catch (error) {
                    console.error(`Error generating ${dir}/${type}/${e}:`, error);
                }
            }
        }
    }
};

run();
