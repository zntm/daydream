import { existsSync, readdirSync, statSync } from "fs";
import { join } from "path";

/** Recursively sort object keys for deterministic JSON output */
const sortKeys = (obj: unknown): unknown => {
    if (obj === null || typeof obj !== "object") return obj;
    if (Array.isArray(obj)) return obj.map(sortKeys);

    return Object.fromEntries(
        Object.entries(obj)
            .sort(([a], [b]) => a.localeCompare(b))
            .map(([k, v]) => [k, sortKeys(v)]),
    );
};

/** Collect all export files from a directory */
const getExportFiles = (baseDir: string): string[] => {
    const exportDir = join(baseDir, "exports");
    if (!existsSync(exportDir)) return [];

    return readdirSync(exportDir)
        .filter(
            (f) => f.endsWith(".ts") && statSync(join(exportDir, f)).isFile(),
        )
        .map((f) => join(exportDir, f));
};

/** Main datagen loop */
const runDatagen = async () => {
    const srcDir = __dirname;
    const outDir = join(srcDir, "../generated");
    let fileCount = 0;

    for (const category of ["assets", "data"]) {
        const categoryDir = join(srcDir, category);
        if (!existsSync(categoryDir)) continue;

        for (const type of readdirSync(categoryDir)) {
            const typeDir = join(categoryDir, type);
            const exportFiles = getExportFiles(typeDir);

            for (const file of exportFiles) {
                try {
                    const module = await import(file);
                    let datagen = module.default;
                    if (!datagen) continue;

                    // Handle async exports
                    if (datagen instanceof Promise) {
                        datagen = await datagen;
                    }

                    // Flatten and write each entry
                    const entries = Array.isArray(datagen)
                        ? datagen.flat(Infinity)
                        : [datagen];

                    for (const entry of entries) {
                        const dest = join(
                            outDir,
                            category,
                            type,
                            entry.destination,
                        );
                        const json = JSON.stringify(
                            sortKeys(entry.data),
                            null,
                            "    ",
                        );

                        await Bun.write(dest, json, { mode: 0o644 });
                        fileCount++;
                    }
                } catch (err) {
                    const relPath = file.replace(srcDir, "");
                    console.error(`Error processing ${relPath}:`, err);
                }
            }
        }
    }

    console.log(`Generated ${fileCount} files.`);
};

runDatagen();
