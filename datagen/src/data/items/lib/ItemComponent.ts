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

export class ItemComponent {
    private type: ItemComponentType;
    private default: string | number;
    private min?: number;
    private max?: number;

    constructor(
        type: ItemComponentType,
        defaultValue: string | number,
        min?: number,
        max?: number
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

    // Convenience factory methods
    static u8(defaultValue: number, min?: number, max?: number): ItemComponent {
        return new ItemComponent(ItemComponentType.U8, defaultValue, min ?? 0, max ?? 255);
    }

    static u16(defaultValue: number, min?: number, max?: number): ItemComponent {
        return new ItemComponent(ItemComponentType.U16, defaultValue, min ?? 0, max ?? 65535);
    }

    static u32(defaultValue: number, min?: number, max?: number): ItemComponent {
        return new ItemComponent(ItemComponentType.U32, defaultValue, min ?? 0, max ?? 4294967295);
    }

    static u64(defaultValue: number, min?: number, max?: number): ItemComponent {
        return new ItemComponent(ItemComponentType.U64, defaultValue, min, max);
    }

    static s8(defaultValue: number, min?: number, max?: number): ItemComponent {
        return new ItemComponent(ItemComponentType.S8, defaultValue, min ?? -128, max ?? 127);
    }

    static s16(defaultValue: number, min?: number, max?: number): ItemComponent {
        return new ItemComponent(ItemComponentType.S16, defaultValue, min ?? -32768, max ?? 32767);
    }

    static s32(defaultValue: number, min?: number, max?: number): ItemComponent {
        return new ItemComponent(ItemComponentType.S32, defaultValue, min ?? -2147483648, max ?? 2147483647);
    }

    static f16(defaultValue: number, min?: number, max?: number): ItemComponent {
        return new ItemComponent(ItemComponentType.F16, defaultValue, min, max);
    }

    static f32(defaultValue: number, min?: number, max?: number): ItemComponent {
        return new ItemComponent(ItemComponentType.F32, defaultValue, min, max);
    }

    static f64(defaultValue: number, min?: number, max?: number): ItemComponent {
        return new ItemComponent(ItemComponentType.F64, defaultValue, min, max);
    }

    static string(defaultValue: string, maxLength?: number): ItemComponent {
        return new ItemComponent(ItemComponentType.String, defaultValue, undefined, maxLength);
    }
}

// Legacy aliases for backwards compatibility
export class ItemStringComponent extends ItemComponent {
    constructor(defaultValue: string, maxLength?: number) {
        super(ItemComponentType.String, defaultValue, undefined, maxLength);
    }
}

export class ItemFloatComponent extends ItemComponent {
    constructor(defaultValue: number, min?: number, max?: number) {
        super(ItemComponentType.F64, defaultValue, min, max);
    }
}

export class ItemIntegerComponent extends ItemComponent {
    constructor(defaultValue: number, min?: number, max?: number) {
        super(ItemComponentType.S32, defaultValue, min, max);
    }
}

export class ItemBooleanComponent extends ItemComponent {
    constructor(defaultValue: boolean = false) {
        super(ItemComponentType.U8, defaultValue ? 1 : 0, 0, 1);
    }
}
