export enum ItemComponentType {
    U8 = "u8",
    U16 = "u16",
    U32 = "u32",
    U64 = "u64",
    S8 = "s8",
    S16 = "s16",
    S32 = "s32",
    F16 = "f16",
    F32 = "f32",
    F64 = "f64",
    String = "string",
}

/** Component data for tile/item custom properties */
class ItemComponentData {
    private type: ItemComponentType;
    private default: string | number;
    private min?: number;
    private max?: number;

    constructor(
        type: ItemComponentType,
        defaultValue: string | number,
        min?: number,
        max?: number,
    ) {
        this.type = type;
        this.default = defaultValue;
        if (min !== undefined) this.min = min;
        if (max !== undefined) this.max = max;
    }
}

// Factory helper - DRYs up the repetitive factory methods
const makeFactory =
    (type: ItemComponentType) =>
    (defaultValue: number, min?: number, max?: number) =>
        new ItemComponentData(type, defaultValue, min, max);

/**
 * Factory functions for creating typed item components.
 */
export const ItemComponent = {
    u8: makeFactory(ItemComponentType.U8),
    u16: makeFactory(ItemComponentType.U16),
    u32: makeFactory(ItemComponentType.U32),
    u64: makeFactory(ItemComponentType.U64),
    s8: makeFactory(ItemComponentType.S8),
    s16: makeFactory(ItemComponentType.S16),
    s32: makeFactory(ItemComponentType.S32),
    f16: makeFactory(ItemComponentType.F16),
    f32: makeFactory(ItemComponentType.F32),
    f64: makeFactory(ItemComponentType.F64),
    string: (defaultValue: string, min?: number, max?: number) =>
        new ItemComponentData(ItemComponentType.String, defaultValue, min, max),
} as const;

export type { ItemComponentData };
