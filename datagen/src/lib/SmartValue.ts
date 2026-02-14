enum SmartValueType {
    Choose = "smart_value:choose",
    ChooseWeighted = "smart_value:choose_weighted",
    FloatRandom = "smart_value:random",
    IntRandom = "smart_value:irandom",
}

export type SmartValueValueType =
    | SmartValueChoose
    | SmartValueChooseWeighted
    | SmartValueFloatRandom
    | SmartValueIntRandom;

export class SmartValueChoose {
    values: any[];
    type: string = SmartValueType.Choose;

    constructor(values: any[]) {
        this.values = values;
    }
}

export class SmartValueChooseWeighted {
    values: SmartValueChooseWeightedOption[];
    type: string = SmartValueType.ChooseWeighted;

    constructor(values: SmartValueChooseWeightedOption[]) {
        this.values = values;
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

export class SmartValueFloatRandom {
    values: { min: number; max: number };
    type: string = SmartValueType.FloatRandom;

    constructor(min: number, max: number) {
        this.values = { min, max };
    }
}

export class SmartValueIntRandom {
    values: { min: number; max: number };
    type: string = SmartValueType.IntRandom;

    constructor(min: number, max: number) {
        this.values = { min, max };
    }
}

export abstract class SmartValue {
    static Choose(values: any[]) {
        return new SmartValueChoose(values);
    }

    static ChooseWeighted(values: SmartValueChooseWeightedOption[]) {
        return new SmartValueChooseWeighted(values);
    }

    static FloatRandom(min: number, max: number) {
        return new SmartValueFloatRandom(min, max);
    }

    static IntRandom(min: number, max: number) {
        return new SmartValueIntRandom(min, max);
    }
}
