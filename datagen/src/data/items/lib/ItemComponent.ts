export enum ItemComponentType {
    Boolean = "boolean",
    Float = "float",
    Integer = "integer",
    String = "string",
}

export class ItemComponent {
    private type: ItemComponentType;
    private default_value: string | number;

    constructor(type: ItemComponentType, default_value: string | number) {
        this.type = type;
        this.default_value = default_value;
    }
}

export class ItemStringComponent extends ItemComponent {
    private max_length?: number;

    constructor(default_value: string | number, max_length?: number) {
        super(ItemComponentType.String, default_value);

        this.max_length = max_length;
    }
}

export class ItemFloatComponent extends ItemComponent {
    private min_value?: number;
    private max_value?: number;

    constructor(
        default_value: string | number,
        min_value?: number,
        max_value?: number,
    ) {
        super(ItemComponentType.Float, default_value);

        this.min_value = min_value;
        this.max_value = max_value;
    }
}

export class ItemIntegerComponent extends ItemComponent {
    private min_value?: number;
    private max_value?: number;

    constructor(
        default_value: string | number,
        min_value?: number,
        max_value?: number,
    ) {
        super(ItemComponentType.Integer, default_value);

        this.min_value = min_value;
        this.max_value = max_value;
    }
}

export class ItemBooleanComponent extends ItemComponent { }
