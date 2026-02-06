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

for (const dir of ["assets", "data"]) {
    if (!existsSync(join(__dirname, dir))) continue;

    for (const type of readdirSync(join(__dirname, dir))) {
        for (const e of readdirSync(
            join(__dirname, `./${dir}/${type}/exports`),
        )) {
            const s = join(__dirname, `./${dir}/${type}/exports/${e}`);

            if (!statSync(s).isFile() || !(e as string).endsWith(".ts"))
                continue;

            const datagen: any[] = import.meta.require(s).default;

            try {
                for (const d of Array.isArray(datagen)
                    ? datagen.flat(Infinity)
                    : [datagen]) {
                    d.data = recursiveSort(d.data);

                    Bun.write(
                        join(
                            __dirname,
                            `../generated/${dir}/${type}/${d.destination}`,
                        ),
                        JSON.stringify(d.data, null, "    "),
                        {
                            mode: 0o644,
                        },
                    );
                }
            } catch (error) {
                console.error(`Error generating ${dir}/${type}/${e}:`, error);
            }
        }
    }
}
