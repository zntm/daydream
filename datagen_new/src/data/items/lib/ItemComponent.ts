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

        if (min !== undefined) {
            this.min = min;
        }

        if (max !== undefined) {
            this.max = max;
        }
    }
}

export abstract class ItemComponent {
    static u8(
        defaultValue: number,
        min?: number,
        max?: number,
    ): ItemComponentData {
        return new ItemComponentData(
            ItemComponentType.U8,
            defaultValue,
            min,
            max,
        );
    }

    static u16(
        defaultValue: number,
        min?: number,
        max?: number,
    ): ItemComponentData {
        return new ItemComponentData(
            ItemComponentType.U16,
            defaultValue,
            min,
            max,
        );
    }

    static u32(
        defaultValue: number,
        min?: number,
        max?: number,
    ): ItemComponentData {
        return new ItemComponentData(
            ItemComponentType.U32,
            defaultValue,
            min,
            max,
        );
    }

    static u64(
        defaultValue: number,
        min?: number,
        max?: number,
    ): ItemComponentData {
        return new ItemComponentData(
            ItemComponentType.U64,
            defaultValue,
            min,
            max,
        );
    }

    static s8(
        defaultValue: number,
        min?: number,
        max?: number,
    ): ItemComponentData {
        return new ItemComponentData(
            ItemComponentType.S8,
            defaultValue,
            min,
            max,
        );
    }

    static s16(
        defaultValue: number,
        min?: number,
        max?: number,
    ): ItemComponentData {
        return new ItemComponentData(
            ItemComponentType.S16,
            defaultValue,
            min,
            max,
        );
    }

    static s32(
        defaultValue: number,
        min?: number,
        max?: number,
    ): ItemComponentData {
        return new ItemComponentData(
            ItemComponentType.S32,
            defaultValue,
            min,
            max,
        );
    }

    static f16(
        defaultValue: number,
        min?: number,
        max?: number,
    ): ItemComponentData {
        return new ItemComponentData(
            ItemComponentType.F16,
            defaultValue,
            min,
            max,
        );
    }

    static f32(
        defaultValue: number,
        min?: number,
        max?: number,
    ): ItemComponentData {
        return new ItemComponentData(
            ItemComponentType.F32,
            defaultValue,
            min,
            max,
        );
    }

    static f64(
        defaultValue: number,
        min?: number,
        max?: number,
    ): ItemComponentData {
        return new ItemComponentData(
            ItemComponentType.F64,
            defaultValue,
            min,
            max,
        );
    }

    static string(
        defaultValue: string,
        min?: number,
        max?: number,
    ): ItemComponentData {
        return new ItemComponentData(
            ItemComponentType.String,
            defaultValue,
            min,
            max,
        );
    }
}

export type { ItemComponentData };
