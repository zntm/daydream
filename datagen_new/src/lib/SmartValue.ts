/**
 * SmartValue types for runtime-evaluated values in the game engine.
 * These serialize to JSON with a `type` discriminator.
 */

// Type discriminators
const TYPE_CHOOSE = "smart_value:choose";
const TYPE_CHOOSE_WEIGHTED = "smart_value:choose_weighted";
const TYPE_FLOAT_RANDOM = "smart_value:random";
const TYPE_INT_RANDOM = "smart_value:irandom";

// Data structures - simple objects, not classes
export interface WeightedOption<T = unknown> {
    readonly value: T;
    readonly weight: number;
}

interface ChooseValue<T = unknown> {
    readonly type: typeof TYPE_CHOOSE;
    readonly values: readonly T[];
}

interface ChooseWeightedValue<T = unknown> {
    readonly type: typeof TYPE_CHOOSE_WEIGHTED;
    readonly values: readonly WeightedOption<T>[];
}

interface FloatRandomValue {
    readonly type: typeof TYPE_FLOAT_RANDOM;
    readonly values: { readonly min: number; readonly max: number };
}

interface IntRandomValue {
    readonly type: typeof TYPE_INT_RANDOM;
    readonly values: { readonly min: number; readonly max: number };
}

export type SmartValueValueType =
    | ChooseValue
    | ChooseWeightedValue
    | FloatRandomValue
    | IntRandomValue;

/**
 * Factory functions for creating SmartValue objects.
 * No class overhead - just returns plain objects that serialize correctly.
 */
export const SmartValue = {
    /** Pick a random value from the array at runtime */
    Choose: <T>(values: T[]): ChooseValue<T> => ({
        type: TYPE_CHOOSE,
        values,
    }),

    /** Pick a weighted random value at runtime */
    ChooseWeighted: <T>(
        values: WeightedOption<T>[],
    ): ChooseWeightedValue<T> => ({
        type: TYPE_CHOOSE_WEIGHTED,
        values,
    }),

    /** Random float in range [min, max] */
    FloatRandom: (min: number, max: number): FloatRandomValue => ({
        type: TYPE_FLOAT_RANDOM,
        values: { min, max },
    }),

    /** Random int in range [min, max] */
    IntRandom: (min: number, max: number): IntRandomValue => ({
        type: TYPE_INT_RANDOM,
        values: { min, max },
    }),

    /** Helper to create a weighted option */
    weighted: <T>(value: T, weight: number): WeightedOption<T> => ({
        value,
        weight,
    }),
} as const;
