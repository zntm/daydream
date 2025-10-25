import { readdirSync } from "fs";
import { join } from "path";
import { inspect } from "util";

export class DatagenReturnData {
    public destination: string;
    public data: any;

    constructor(destination: string, data: any) {
        this.destination = destination;
        this.data = data;
    }
}

export enum SmartValueType {
    FloatRandom = "smart_value:random",
    IntRandom = "smart_value:irandom",
    Choose = "smart_value:choose",
    ChooseWeighted = "smart_value:choose_weighted",
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

export class Sound {
    private id: string;
    private gain?: number;

    constructor(id: string, gain?: number) {
        this.id = id;

        if (gain !== undefined) {
            this.gain = gain;
        }
    }
}

export class Noise {
    private min?: number;
    private max?: number;
    private octaves: number;

    constructor(octaves: number, min?: number, max?: number) {
        this.octaves = octaves;
        this.min = min;
        this.max = max;
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
    .forEach(async (dir: string) => {
        console.log(`Processing: '${dir}'`);

        let { default: datagen } = await import(`./src/${dir}`);

        if (inspect(datagen).includes("pending")) {
            (await Promise.all(datagen)).map((d) => {
                if (Array.isArray(d)) {
                    d.forEach(exportData);
                } else {
                    exportData(d);
                }
            });

            return;
        }

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
