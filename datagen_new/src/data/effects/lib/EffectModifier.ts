export enum EffectOperation {
    Add = "add",
    Subtract = "subtract",
    Multiply = "multiply",
    Divide = "divide",
    Power = "power",
}

export class EffectModifier {
    private value: string | number;
    private operation: EffectOperation;

    constructor(value: string | number, operation: EffectOperation) {
        this.value = value;
        this.operation = operation;
    }

    static add(value: string | number): EffectModifier {
        return new EffectModifier(value, EffectOperation.Add);
    }

    static subtract(value: string | number): EffectModifier {
        return new EffectModifier(value, EffectOperation.Subtract);
    }

    static multiply(value: string | number): EffectModifier {
        return new EffectModifier(value, EffectOperation.Multiply);
    }

    static divide(value: string | number): EffectModifier {
        return new EffectModifier(value, EffectOperation.Divide);
    }

    static power(value: string | number): EffectModifier {
        return new EffectModifier(value, EffectOperation.Power);
    }

    static multiplyByLevel(): EffectModifier {
        return new EffectModifier("level", EffectOperation.Multiply);
    }
}
