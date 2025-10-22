import { readdirSync } from "fs";
import { join } from "path";

export class DatagenReturnData {
    public destination: string;
    public data: any;

    constructor(destination: string, data: any) {
        this.destination = destination;
        this.data = data;
    }
}

export enum SmartValueType {
    FloatRandom,
    IntRandom,
    Choose,
    ChooseWeighted,
}

export class SmartValueRandom {
    min: number;
    max: number;

    constructor(min: number, max: number) {
        this.min = min;
        this.max = max;
    }
}

export class SmartValueChooseWeightedOption {
    value: any;
    weight: number;

    constructor(value: any, weight: number) {
        this.value = value;
        this.weight = weight;
    }
}

export class SmartValue {
    constructor(
        public type: SmartValueType,
        public values:
            | SmartValueRandom
            | any[]
            | SmartValueChooseWeightedOption[],
    ) {
        this.type = type;
        this.values = values;
    }
}

const exportData = (data: DatagenReturnData) => {
    const file = Bun.file(join(__dirname, data.destination));

    if (typeof data.data === "object" && !Array.isArray(data.data)) {
        data.data = Object.fromEntries(Object.entries(data.data).sort());
    }

    Bun.write(file, JSON.stringify(data.data, null, "    "));
};

readdirSync(join(__dirname, "./src"))
    .filter((dir) => dir.endsWith(".ts"))
    .forEach((dir: string) => {
        console.log(`Processing: '${dir}'`);

        const { default: datagen } = import.meta.require(`./src/${dir}`);

        if (!datagen) {
            console.error(`Datagen function not found in ${dir}`);

            return;
        }

        if (Array.isArray(datagen)) {
            datagen.forEach(exportData);
        } else {
            exportData(datagen);
        }

        console.log(`Finished processing: '${dir}'`);
    });
