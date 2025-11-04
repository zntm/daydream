import { ChooseWeightedOption } from "../index";

enum SmartValueType {
    FloatRandom = "smart_value:random",
    IntRandom = "smart_value:irandom",
    Choose = "smart_value:choose",
    ChooseWeighted = "smart_value:choose_weighted",
}

class SmartValueRandom {
    min: number;
    max: number;

    constructor(min: number, max: number) {
        this.min = min;
        this.max = max;
    }
}

class SmartValue {
    constructor(
        public type: SmartValueType,
        public values: SmartValueRandom | any[] | ChooseWeightedOption[],
    ) {
        this.type = type;
        this.values = values;
    }
}

export class SmartValueFloatRandom extends SmartValue {
    constructor(min: number, max: number) {
        super(SmartValueType.FloatRandom, new SmartValueRandom(min, max));
    }
}

export class SmartValueIntRandom extends SmartValue {
    constructor(min: number, max: number) {
        super(SmartValueType.IntRandom, new SmartValueRandom(min, max));
    }
}

export class SmartValueChoose extends SmartValue {
    constructor(values: any[]) {
        super(SmartValueType.Choose, values);
    }
}

export class SmartValueChooseWeighted extends SmartValue {
    constructor(values: ChooseWeightedOption[]) {
        super(SmartValueType.ChooseWeighted, values);
    }
}
