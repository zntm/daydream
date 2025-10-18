import { readdirSync } from "fs";
import { join } from "path";

export class DatagenReturnData {
    private destination: string;
    private data: any;

    constructor(destination: string, data: any) {
        this.destination = destination;
        this.data = data;
    }
}

readdirSync(join(__dirname, "./datagen")).forEach(async (dir: string) => {
    const datagen = (await import(`./datagen/${dir}`)).default;

    const file = Bun.file(join(__dirname, datagen.destination));

    Bun.write(file, JSON.stringify(datagen.data, null, "    "));
});
