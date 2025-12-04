export type SmartValue = number | SmartValueIntRandom | SmartValueFloatRandom | SmartValueChooseWeighted;

export class ChooseWeightedOption {
    value: any;
    weight: number;

    constructor(value: any, weight: number) {
        this.value = value;
        this.weight = weight;
    }
}

export class SmartValueIntRandom {
    values: { min: number; max: number };
    type: string = "smart_value:irandom";

    constructor(min: number, max: number) {
        this.values = { min, max };
    }
}

export class SmartValueFloatRandom {
    values: { min: number; max: number };
    type: string = "smart_value:random";

    constructor(min: number, max: number) {
        this.values = { min, max };
    }
}

export class SmartValueChoose {
    values: any[];
    type: string = "smart_value:choose";

    constructor(values: any[]) {
        this.values = values;
    }
}

export class SmartValueChooseWeighted {
    values: ChooseWeightedOption[];
    type: string = "smart_value:choose_weighted";

    constructor(values: ChooseWeightedOption[]) {
        this.values = values;
    }
}
