import { readdirSync } from "fs";
import { join } from "path";
import { inspect } from "util";

export * from "./src/lib/DatagenReturnData";
export * from "./src/lib/SmartValue";
export * from "./src/lib/Sound";
export * from "./src/lib/Noise";
export * from "./src/lib/Attribute";
export * from "./src/lib/Entity";

import { DatagenReturnData } from "./src/lib/DatagenReturnData";

const _exportData = (data: DatagenReturnData) => {
    const file = Bun.file(join(__dirname, data.destination));

    if (typeof data.data === "object" && !Array.isArray(data.data)) {
        data.data = Object.fromEntries(Object.entries(data.data).sort());
    }

    Bun.write(file, JSON.stringify(data.data, null, "    "));
};

const exportData = (data: DatagenReturnData | DatagenReturnData[]) => {
    if (Array.isArray(data)) {
        data.flat(Infinity).forEach(_exportData);
    } else {
        _exportData(data);
    }
};

["data"].forEach((dir) =>
    readdirSync(join(__dirname, `./src/${dir}`))
        .filter((dir) => dir.endsWith(".ts"))
        .forEach(async (dir2: string) => {
            console.log(`Processing: '${dir2}'`);

            let { default: datagen } = await import(`./src/${dir}/${dir2}`);

            if (!datagen) {
                console.error(`Datagen function not found in ${dir2}`);

                return;
            }

            if (inspect(datagen).includes("pending")) {
                (await Promise.all(datagen)).map(exportData);

                return;
            }

            exportData(datagen);

            console.log(`Finished processing: '${dir2}'`);
        }),
);
