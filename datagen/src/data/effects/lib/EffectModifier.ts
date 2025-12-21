export enum EffectOperation {
    Add = "add",
    Subtract = "subtract",
    Multiply = "multiply",
    Divide = "divide",
    Power = "power",
}

/**
 * Represents a modifier operation for effects and attribute buffs.
 * Unified system for both effects and armor/accessory modifiers.
 */
export class EffectModifier {
    private value: string | number;
    private operation: EffectOperation;

    /**
     * @param value - Modifier value, can be a number or "level" for dynamic calculation
     * @param operation - The operation to perform (add, subtract, multiply, divide, power)
     */
    constructor(value: string | number, operation: EffectOperation) {
        this.value = value;
        this.operation = operation;
    }

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

    /**
     * Creates a modifier that multiplies by the effect level
     */
    static multiplyByLevel() {
        return new EffectModifier("level", EffectOperation.Multiply);
    }
}
