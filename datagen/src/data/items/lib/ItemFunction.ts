export class ItemFunction {
    private id: string;
    private parameters?: any[];

    constructor(id: string, parameters?: any[]) {
        this.id = id;

        if (parameters !== undefined) {
            this.parameters = parameters;
        }
    }
}

export enum ItemFunctionDataType {
    Anchor = "anchor",
    Button = "button",
    Checkbox = "checkbox",
    Dropdown = "dropdown",
    TextboxFloat = "textbox_float",
    TextboxInteger = "textbox_integer",
    TextboxString = "textbox_string",
}

export class ItemFunctionData {
    private type: ItemFunctionDataType;
    private x: number;
    private y: number;

    constructor(type: ItemFunctionDataType, x: number, y: number) {
        this.type = type;
        this.x = x;
        this.y = y;
    }
}

export class ItemFunctionAnchorData extends ItemFunctionData {
    private text: string;

    constructor(x: number, y: number, text: string) {
        super(ItemFunctionDataType.Anchor, x, y);

        this.text = text;
    }
}

export class ItemFunctionButtonData extends ItemFunctionData {
    private width?: number;
    private height?: number;
    private text?: string;
    private icon?: string;
    private on_select_release?: string;

    constructor(x: number, y: number, width?: number, height?: number) {
        super(ItemFunctionDataType.Button, x, y);

        this.width = width;
        this.height = height;
    }

    setText(text: string) {
        this.text = text;

        return this;
    }

    setIcon(icon: string) {
        this.icon = icon;

        return this;
    }

    setOnSelectRelease(on_select_release: string) {
        this.on_select_release = on_select_release;

        return this;
    }
}

class ItemFunctionTextboxNumberData extends ItemFunctionData {
    private width?: number;
    private height?: number;
    private placeholder?: string;
    private minNumber?: number;
    private maxNumber?: number;
    private component?: string;

    constructor(x: number, y: number, width?: number, height?: number) {
        super(ItemFunctionDataType.TextboxString, x, y);

        this.width = width;
        this.height = height;
    }

    setPlaceholder(placeholder: string) {
        this.placeholder = placeholder;

        return this;
    }

    setRange(minNumber: number, maxNumber: number) {
        this.minNumber = minNumber;
        this.maxNumber = maxNumber;

        return this;
    }

    setComponent(component: string) {
        this.component = component;

        return this;
    }
}

export class ItemFunctionTextboxFloatData extends ItemFunctionTextboxNumberData { }
export class ItemFunctionTextboxIntegerData extends ItemFunctionTextboxNumberData { }

export class ItemFunctionTextboxStringData extends ItemFunctionData {
    private width?: number;
    private height?: number;
    private placeholder?: string;
    private max_length?: number;
    private component?: string;

    constructor(x: number, y: number, width?: number, height?: number) {
        super(ItemFunctionDataType.TextboxString, x, y);

        this.width = width;
        this.height = height;
    }

    setPlaceholder(placeholder: string) {
        this.placeholder = placeholder;

        return this;
    }

    setMaxLength(max_length: number) {
        this.max_length = max_length;

        return this;
    }

    setComponent(component: string) {
        this.component = component;

        return this;
    }
}
