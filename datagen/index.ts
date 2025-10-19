import { readdirSync } from "fs";
import { join } from "path";
import { parseArgs } from "util";

export class DatagenReturnData {
    public destination: string;
    public data: any;

    constructor(destination: string, data: any) {
        this.destination = destination;
        this.data = data;
    }
}

const exportData = (data: DatagenReturnData) => {
    const file = Bun.file(join(__dirname, data.destination));

    Bun.write(file, JSON.stringify(data.data, null, "    "));
};

readdirSync(join(__dirname, "./src"))
    .filter((dir) => dir.endsWith(".ts"))
    .forEach(async (dir: string) => {
        const datagen = (await import(`./src/${dir}`)).default;

        if (Array.isArray(datagen)) {
            datagen.forEach(exportData);
        } else {
            exportData(datagen);
        }
    });
