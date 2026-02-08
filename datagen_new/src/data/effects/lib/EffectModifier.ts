export enum EffectOperation {
    Add = "add",
    Subtract = "subtract",
    Multiply = "multiply",
    Divide = "divide",
    Power = "power",
}

// Keep class for export compatibility
export class EffectModifier {
    private value: string | number;
    private operation: EffectOperation;

    constructor(value: string | number, operation: EffectOperation) {
        this.value = value;
        this.operation = operation;
    }

    // Factory methods
    static add(value: string | number) {
        return new EffectModifier(value, EffectOperation.Add);
    }
    static subtract(value: string | number) {
        return new EffectModifier(value, EffectOperation.Subtract);
    }
    static multiply(value: string | number) {
        return new EffectModifier(value, EffectOperation.Multiply);
    }
    static divide(value: string | number) {
        return new EffectModifier(value, EffectOperation.Divide);
    }
    static power(value: string | number) {
        return new EffectModifier(value, EffectOperation.Power);
    }
    static multiplyByLevel() {
        return new EffectModifier("level", EffectOperation.Multiply);
    }
}
