import {
    DatagenReturnData,
    SmartValue,
    SmartValueRandom,
    SmartValueType,
    Sound,
} from "../index";

export class Item {
    private type: ItemType;
    private sprite: string | ItemSprite;
    private inventory: string | ItemInventory;
    private properties?: any;

    constructor(
        type: ItemType,
        sprite: string | ItemSprite,
        inventory: string | ItemInventory,
        properties?: any,
    ) {
        this.type = type;
        this.sprite = sprite;
        this.inventory = inventory;

        if (properties !== undefined) {
            this.properties = Array.isArray(properties)
                ? properties.toSorted()
                : [properties];
        }
    }
}

export class ItemSprite {
    private xoffset: number;
    private yoffset: number;
    private length: number;

    constructor(xoffset: number, yoffset: number, length: number = 1) {
        this.xoffset = xoffset;
        this.yoffset = yoffset;
        this.length = length;
    }
}

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

export class ItemBooleanComponent extends ItemComponent {}

export class ItemConsumable {
    private hp: number;
    private saturation: number;
    private cooldown: any;
    private sfx: any;

    constructor(hp: number, saturation: number, cooldown: any, sfx: any) {
        this.hp = hp;
        this.saturation = saturation;
        this.cooldown = cooldown;
        this.sfx = sfx;
    }
}

export class ItemCooldown {
    private id: string;
    private seconds: number;

    constructor(id: string, seconds: number) {
        this.id = id;
        this.seconds = seconds;
    }
}

export class ItemDrop {
    private id: string;
    private amount?: number | SmartValue;
    private chance?: number;

    constructor(id: string, amount?: number | SmartValue, chance?: number) {
        this.id = id;
        this.amount = amount;
        this.chance = chance;
    }
}

export class ItemDurability {
    private amount: number;
    private bar: string;

    constructor(amount: number, bar: string) {
        this.amount = amount;
        this.bar = bar;
    }
}

export class ItemInventory {}

export class ItemHarvest {
    private hardness: number;
    private level?: number;

    constructor(hardness: number, level?: number) {
        this.hardness = hardness;

        if (level !== undefined) {
            this.level = level;
        }
    }
}

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

export class ItemFunctionTextboxFloatData extends ItemFunctionTextboxNumberData {}
export class ItemFunctionTextboxIntegerData extends ItemFunctionTextboxNumberData {}

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

export enum ItemType {
    Default = "default",
    Solid = "solid",
    Untouchable = "untouchable",
    Accessory = "accessory",
    Tool = "tool",
}

const { default: blockWallItems } = import.meta.require(
    "./items/blockWallItems",
);

const { default: consumableItem } = import.meta.require(
    "./items/consumableItem",
);

const { default: cookableConsumableItems } = import.meta.require(
    "./items/cookableConsumableItems",
);

const { default: oreItems } = import.meta.require("./items/oreItems");

const { default: tieredEquipmentItems } = import.meta.require(
    "./items/tieredEquipmentItems",
);

const {
    default: tileItem,
    ItemTileCondition,
    ItemTileDrop,
    ItemTileDropCondition,
    ItemTileHarvest,
    ItemTileParticle,
    ItemTilePlacement,
    ItemTilePlacementCondition,
    ItemTilePlacementConditionType,
    ItemTilePlacementConditionValue,
    ItemTileProperties,
} = import.meta.require("./items/tileItem");

const { default: toolItem } = import.meta.require("./items/toolItem");

const { default: woodItems } = import.meta.require("./items/woodItems");

export default [
    toolItem(
        "hatchet",
        68,
        "#phantasia:item/generic/inventory_tool",
        undefined,
        1,
        1,
    ),
    new DatagenReturnData(
        "generated/data/items/feather.json",
        new Item(
            ItemType.Default,
            "phantasia:item/feather",
            "#phantasia:item/generic/inventory_default",
        ),
    ),
    consumableItem(
        "apple",
        "#phantasia:item/generic/inventory_default",
        new ItemConsumable(
            8,
            4,
            new ItemCooldown("phantasia:food", 1),
            new Sound("phantasia:sound.eat"),
        ),
    ),
    ...[
        {
            id: "cactus",
            particleColour: ["#113402", "#032802"],
        },
        {
            id: "cattail",
            particleColour: "#phantasia:tile/particle_colour/plant",
            dropCondition: new ItemTileDropCondition().setIndex(2),
        },
        {
            id: "sunflower",
            particleColour: "#phantasia:tile/particle_colour/plant",
            dropCondition: new ItemTileDropCondition().setIndex(0),
        },
    ].map(({ id, particleColour, dropCondition }) =>
        tileItem(
            id,
            ItemType.Untouchable,
            "#phantasia:item/generic/inventory_default",
            [ItemTileProperties.CanMirror],
            [new ItemTileDrop(id).setCondition(dropCondition)],
            new ItemTileHarvest(
                0.38,
                0,
                new ItemTileParticle(
                    particleColour,
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            new ItemTilePlacement().setCondition(
                new ItemTilePlacementCondition(
                    ItemTilePlacementConditionType.Every,
                    [
                        {
                            condition: new ItemTilePlacementCondition(
                                ItemTilePlacementConditionType.Some,
                                [
                                    new ItemTilePlacementConditionValue(
                                        0,
                                        1,
                                        "default",
                                    ).setId(
                                        "#phantasia:tile/placement/plant_on",
                                    ),
                                    new ItemTilePlacementConditionValue(
                                        0,
                                        1,
                                        "default",
                                    ).setId("$ID"),
                                ],
                            ),
                        },
                        new ItemTilePlacementConditionValue(0, -1, "z").setId([
                            "$EMPTY",
                            "$ID",
                        ]),
                    ],
                ),
            ),
            "#phantasia:tile/sfx/leaves",
        ),
    ),
    tileItem(
        "furnace",
        ItemType.Untouchable,
        "#phantasia:item/generic/inventory_default",
        undefined,
        [
            new ItemTileDrop("phantasia:item/furnace").setCondition(
                new ItemTileCondition("#phantasia:item/type/pickaxe", 1),
            ),
        ],
        new ItemTileHarvest(
            0.36,
            0,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/stone",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/pickaxe"),
        ),
        undefined,
        "#phantasia:tile/sfx/stone",
    ),
    tileItem(
        "glass",
        ItemType.Untouchable,
        "#phantasia:item/generic/inventory_default",
        undefined,
        [
            new ItemTileDrop("phantasia:item/glass").setCondition(
                new ItemTileCondition("#phantasia:item/type/pickaxe", 1),
            ),
        ],
        new ItemTileHarvest(
            0.08,
            0,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/stone",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
            new ItemTileCondition("#phantasia:item/type/pickaxe"),
        ),
        undefined,
        "#phantasia:tile/sfx/stone",
    ),
    tileItem(
        "twig",
        ItemType.Untouchable,
        "#phantasia:item/generic/inventory_default",
        [ItemTileProperties.CanMirror],
        [new ItemTileDrop("phantasia:twig")],
        new ItemTileHarvest(
            0.11,
            0,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/twig",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
        ),
        new ItemTilePlacement().setIndex(
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(1, 3),
            ),
        ),
        "#phantasia:tile/sfx/wood",
    ),
    tileItem(
        "rock",
        ItemType.Untouchable,
        "#phantasia:item/generic/inventory_default",
        [ItemTileProperties.CanMirror],
        [new ItemTileDrop("phantasia:rock")],
        new ItemTileHarvest(
            0.11,
            0,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/stone",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
        ),
        new ItemTilePlacement().setIndex(
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(1, 4),
            ),
        ),
        "#phantasia:tile/sfx/stone",
    ),
    tileItem(
        "cactus_flower",
        ItemType.Untouchable,
        "#phantasia:item/generic/inventory_default",
        [ItemTileProperties.IsFoliage],
        [new ItemTileDrop("phantasia:cactus_flower")],
        new ItemTileHarvest(
            0.38,
            0,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/twig",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
        ),
        new ItemTilePlacement().setCondition(
            "#phantasia:tile/placement/condition_dry_plant",
        ),
        "#phantasia:tile/sfx/leaves",
    ),
    tileItem(
        "dead_bush",
        ItemType.Untouchable,
        "#phantasia:item/generic/inventory_default",
        [ItemTileProperties.CanMirror, ItemTileProperties.IsFoliage],
        [new ItemTileDrop("phantasia:twig")],
        new ItemTileHarvest(
            0.38,
            0,
            new ItemTileParticle(
                "#phantasia:tile/particle_colour/twig",
                "#phantasia:tile/generic/harvest_particle_frequency",
            ),
        ),
        new ItemTilePlacement().setCondition(
            "#phantasia:tile/placement/condition_dry_plant",
        ),
        "#phantasia:tile/sfx/wood",
    ),
    // Block Wall
    ...[
        {
            id: "dirt",
            properties: [
                ItemTileProperties.CanFlip,
                ItemTileProperties.CanMirror,
                ItemTileProperties.IsTile,
            ],
            harvest: new ItemTileHarvest(
                0.36,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/dirt",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            sfx: "#phantasia:tile/sfx/dirt",
        },
        {
            id: "lumin_moss",
            properties: [
                ItemTileProperties.CanFlip,
                ItemTileProperties.CanMirror,
                ItemTileProperties.IsTile,
            ],
            harvest: new ItemTileHarvest(
                0.26,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/lumin_moss",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            sfx: "#phantasia:tile/sfx/grass",
        },
        {
            id: "moss",
            properties: [
                ItemTileProperties.CanFlip,
                ItemTileProperties.CanMirror,
                ItemTileProperties.IsTile,
            ],
            harvest: new ItemTileHarvest(
                0.26,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/moss",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            sfx: "#phantasia:tile/sfx/grass",
        },
        {
            id: "sandstone",
            properties: [
                ItemTileProperties.CanFlip,
                ItemTileProperties.CanMirror,
                ItemTileProperties.IsTile,
            ],
            harvest: new ItemTileHarvest(
                0.22,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/sand",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new ItemTileCondition("#phantasia:item/type/pickaxe"),
            ),
            sfx: "#phantasia:tile/sfx/stone",
        },
        {
            id: "stone",
            properties: [
                ItemTileProperties.CanFlip,
                ItemTileProperties.CanMirror,
                ItemTileProperties.IsTile,
            ],
            harvest: new ItemTileHarvest(
                0.36,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new ItemTileCondition("#phantasia:item/type/pickaxe"),
            ),
            sfx: "#phantasia:tile/sfx/stone",
        },
        {
            id: "nightrock",
            properties: [
                ItemTileProperties.CanFlip,
                ItemTileProperties.CanMirror,
                ItemTileProperties.IsTile,
            ],
            harvest: new ItemTileHarvest(
                0.52,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/nightrock",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new ItemTileCondition("#phantasia:item/type/pickaxe"),
            ),
            sfx: "#phantasia:tile/sfx/stone",
        },
    ]
        .map(({ id, properties, harvest, sfx }) =>
            blockWallItems(id, properties, harvest, sfx),
        )
        .flat(),
    // Cookable Consumables
    ...[
        {
            id: "chicken",
            rawConsumable: new ItemConsumable(
                4,
                2,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sound.eat"),
            ),
            cookedConsumable: new ItemConsumable(
                8,
                8,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sound.eat"),
            ),
        },
        {
            id: "bunny",
            rawConsumable: new ItemConsumable(
                3,
                2,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sound.eat"),
            ),
            cookedConsumable: new ItemConsumable(
                6,
                4,
                new ItemCooldown("phantasia:food", 1),
                new Sound("phantasia:sound.eat"),
            ),
        },
    ]
        .map(({ id, rawConsumable, cookedConsumable }) =>
            cookableConsumableItems(id, rawConsumable, cookedConsumable),
        )
        .flat(),
    // Flowers
    ...[
        "bluebells",
        "daisy",
        "dandelion",
        "dendrobium",
        "globeflower",
        "lilybell",
        "orchids",
        "rose",
    ].map((id: string) =>
        tileItem(
            id,
            ItemType.Untouchable,
            "#phantasia:item/generic/inventory_default",
            [ItemTileProperties.CanMirror, ItemTileProperties.IsFoliage],
            [new ItemTileDrop(`phantasia:${id}`)],
            new ItemTileHarvest(
                0.38,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/plant",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            new ItemTilePlacement().setCondition(
                "#phantasia:tile/placement/condition_plant",
            ),
            "#phantasia:tile/sfx/leaves",
        ),
    ),
    // Grass
    ...["", "dry", "swamp", "taiga"]
        .map((id: string) => {
            id = id !== "" ? `grass_${id}` : "grass";

            return ["short", "tall"].map((type: string) =>
                tileItem(
                    `${type}_${id}`,
                    ItemType.Untouchable,
                    "#phantasia:item/generic/inventory_default",
                    [
                        ItemTileProperties.CanMirror,
                        ItemTileProperties.IsFoliage,
                    ],
                    [new ItemTileDrop(`phantasia:${type}_${id}`)],
                    new ItemTileHarvest(
                        0.38,
                        0,
                        new ItemTileParticle(
                            "#phantasia:tile/particle_colour/plant",
                            "#phantasia:tile/generic/harvest_particle_frequency",
                        ),
                    ),
                    new ItemTilePlacement().setCondition(
                        "#phantasia:tile/placement/condition_plant",
                    ),
                    "#phantasia:tile/sfx/leaves",
                ),
            );
        })
        .flat(),
    // Grass Block
    ...["", "taiga", "swamp"].map((id) => {
        id = id !== "" ? `grass_block_${id}` : "grass_block";

        return tileItem(
            id,
            ItemType.Untouchable,
            "#phantasia:item/generic/inventory_default",
            [ItemTileProperties.CanMirror, ItemTileProperties.IsTile],
            [new ItemTileDrop(`phantasia:dirt`)],
            new ItemTileHarvest(
                0.36,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/dirt",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
            ),
            "#phantasia/tile/sfx/dirt",
        );
    }),
    // Ore
    ...[
        {
            id: "coal",
            harvestLevel: 0,
            blockHarvest: new ItemTileHarvest(
                0.58,
                1,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new ItemTileCondition("#phantasia:item/type/pickaxe"),
            ),
            blockSFX: "#phantasia:tile/sfx/stone",
            oreHarvest: new ItemTileHarvest(
                0.38,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new ItemTileCondition("#phantasia:item/type/pickaxe"),
            ),
            oreSFX: "#phantasia:tile/sfx/stone",
        },
        {
            id: "copper",
            harvestLevel: 0,
            blockHarvest: new ItemTileHarvest(
                0.68,
                1,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new ItemTileCondition("#phantasia:item/type/pickaxe"),
            ),
            blockSFX: "#phantasia:tile/sfx/stone",
            oreHarvest: new ItemTileHarvest(
                0.42,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new ItemTileCondition("#phantasia:item/type/pickaxe"),
            ),
            oreSFX: "#phantasia:tile/sfx/stone",
            hasRawItem: true,
        },
        {
            id: "iron",
            harvestLevel: 0,
            blockHarvest: new ItemTileHarvest(
                0.78,
                1,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new ItemTileCondition("#phantasia:item/type/pickaxe"),
            ),
            blockSFX: "#phantasia:tile/sfx/stone",
            oreHarvest: new ItemTileHarvest(
                0.48,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new ItemTileCondition("#phantasia:item/type/pickaxe"),
            ),
            oreSFX: "#phantasia:tile/sfx/stone",
            hasRawItem: true,
        },
        {
            id: "gold",
            harvestLevel: 0,
            blockHarvest: new ItemTileHarvest(
                0.88,
                1,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new ItemTileCondition("#phantasia:item/type/pickaxe"),
            ),
            blockSFX: "#phantasia:tile/sfx/stone",
            oreHarvest: new ItemTileHarvest(
                0.56,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new ItemTileCondition("#phantasia:item/type/pickaxe"),
            ),
            oreSFX: "#phantasia:tile/sfx/stone",
            hasRawItem: true,
        },
        {
            id: "platinum",
            harvestLevel: 0,
            blockHarvest: new ItemTileHarvest(
                0.98,
                1,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new ItemTileCondition("#phantasia:item/type/pickaxe"),
            ),
            blockSFX: "#phantasia:tile/sfx/stone",
            oreHarvest: new ItemTileHarvest(
                0.72,
                0,
                new ItemTileParticle(
                    "#phantasia:tile/particle_colour/stone",
                    "#phantasia:tile/generic/harvest_particle_frequency",
                ),
                new ItemTileCondition("#phantasia:item/type/pickaxe"),
            ),
            oreSFX: "#phantasia:tile/sfx/stone",
            hasRawItem: true,
        },
    ]
        .map(
            ({
                id,
                harvestLevel,
                blockHarvest,
                blockSFX,
                oreHarvest,
                oreSFX,
                hasRawItem,
            }) =>
                oreItems(
                    id,
                    harvestLevel,
                    ItemTileProperties.IsTile,
                    blockHarvest,
                    blockSFX,
                    [
                        ItemTileProperties.CanFlip,
                        ItemTileProperties.CanMirror,
                        ItemTileProperties.IsTile,
                    ],
                    oreHarvest,
                    oreSFX,
                    hasRawItem,
                ),
        )
        .flat(),
    // Tiered Equipment
    ...[
        {
            id: "copper",
            helmet: { defense: 2, durability: 100 },
            breastplate: { defense: 4, durability: 136 },
            leggings: { defense: 3, durability: 108 },
            sword: { damage: 5, durability: 162 },
            pickaxe: { damage: 4, durability: 141 },
            axe: { damage: 4, durability: 133 },
            shovel: { damage: 3, durability: 125 },
            harvest: {
                hardness: 1.12,
                level: 2,
            },
        },
        {
            id: "iron",
            helmet: { defense: 4, durability: 277 },
            breastplate: { defense: 7, durability: 308 },
            leggings: { defense: 5, durability: 244 },
            sword: { damage: 7, durability: 367 },
            pickaxe: { damage: 6, durability: 319 },
            axe: { damage: 6, durability: 300 },
            shovel: { damage: 4, durability: 283 },
            harvest: {
                hardness: 1.19,
                level: 3,
            },
        },
        {
            id: "gold",
            helmet: { defense: 6, durability: 494 },
            breastplate: { defense: 11, durability: 671 },
            leggings: { defense: 8, durability: 531 },
            sword: { damage: 8, durability: 799 },
            pickaxe: { damage: 7, durability: 695 },
            axe: { damage: 7, durability: 653 },
            shovel: { damage: 5, durability: 616 },
            harvest: {
                hardness: 1.25,
                level: 4,
            },
        },
        {
            id: "platinum",
            helmet: { defense: 7, durability: 766 },
            breastplate: { defense: 13, durability: 1041 },
            leggings: { defense: 9, durability: 823 },
            sword: { damage: 13, durability: 1239 },
            pickaxe: { damage: 11, durability: 1078 },
            axe: { damage: 10, durability: 1012 },
            shovel: { damage: 7, durability: 955 },
            harvest: {
                hardness: 1.31,
                level: 5,
            },
        },
    ]
        .map(
            ({
                id,
                helmet,
                breastplate,
                leggings,
                sword,
                pickaxe,
                axe,
                shovel,
                harvest,
            }) =>
                tieredEquipmentItems(
                    id,
                    helmet,
                    breastplate,
                    leggings,
                    sword,
                    pickaxe,
                    axe,
                    shovel,
                    harvest,
                ),
        )
        .flat(),
    // Wood
    ...[
        {
            id: "birch",
            leavesParticleId: ["#051417", "#041013"],
            logParticleId: ["#4F5263", "#3E4051"],
        },
        {
            id: "oak",
            leavesParticleId: ["#122D2B", "#0B2021"],
            logParticleId: ["#3B160A", "#2D0B04"],
        },
        {
            id: "pine",
            leavesParticleId: ["#122D2B", "#0B2021"],
            logParticleId: ["#381D1E", "#301A1C"],
        },
    ]
        .map(({ id, leavesParticleId, logParticleId }): any =>
            woodItems(
                id,
                leavesParticleId,
                logParticleId,
                `#phantasia:tile/particle_colour/plank_${id}`,
            ),
        )
        .flat(),
    tileItem(
        "loot_blueprint",
        ItemType.Solid,
        "#phantasia:item/generic/inventory_default",
        undefined,
        undefined,
        undefined,
        undefined,
        "#phantasia:tile/sfx/stone",
        [
            {
                key: "id",
                component: new ItemStringComponent("id", 80),
            },
            {
                key: "turns_into",
                component: new ItemStringComponent("turns_into", 80),
            },
        ],
        [
            new ItemFunction("phantasia:open_menu", [
                new ItemFunctionButtonData(56, 56).setOnSelectRelease("exit"),
                // ID
                new ItemFunctionAnchorData(
                    480,
                    84,
                    "phantasia:tile.structure_blueprint.structure_id",
                ),
                new ItemFunctionTextboxStringData(480, 132, 17, 3)
                    .setComponent("id")
                    .setPlaceholder("ID")
                    .setMaxLength(80),
            ]),
        ],
    ),
    tileItem(
        "structure_blueprint",
        ItemType.Solid,
        "#phantasia:item/generic/inventory_default",
        undefined,
        undefined,
        undefined,
        undefined,
        "#phantasia:tile/sfx/stone",
        [
            {
                key: "id",
                component: new ItemStringComponent("id", 80),
            },
            {
                key: "turns_into",
                component: new ItemStringComponent("turns_into", 80),
            },
            {
                key: "xoffset",
                component: new ItemIntegerComponent("xoffset", -128, 127),
            },
            {
                key: "yoffset",
                component: new ItemIntegerComponent("yoffset", -128, 127),
            },
            {
                key: "xscale",
                component: new ItemIntegerComponent("xscale", 1, 255),
            },
            {
                key: "yscale",
                component: new ItemIntegerComponent("yscale", 1, 255),
            },
        ],
        [
            new ItemFunction("phantasia:open_menu", [
                new ItemFunctionButtonData(56, 56).setOnSelectRelease("exit"),
                // ID
                new ItemFunctionAnchorData(
                    480,
                    84,
                    "phantasia:tile.structure_blueprint.structure_id",
                ),
                new ItemFunctionTextboxStringData(480, 132, 17, 3)
                    .setComponent("id")
                    .setPlaceholder("ID")
                    .setMaxLength(80),
                // Offset
                new ItemFunctionAnchorData(
                    480,
                    248,
                    "phantasia:tile.structure_blueprint.offset",
                ),
                new ItemFunctionTextboxIntegerData(408, 552, 17, 3)
                    .setComponent("xoffset")
                    .setPlaceholder(
                        "phantasia:tile.structure_blueprint.xoffset",
                    )
                    .setRange(-128, 127),
                new ItemFunctionTextboxIntegerData(408, 552, 17, 3)
                    .setComponent("yoffset")
                    .setPlaceholder(
                        "phantasia:tile.structure_blueprint.yoffset",
                    )
                    .setRange(-128, 127),
                // Scale
                new ItemFunctionAnchorData(
                    480,
                    316,
                    "phantasia:tile.structure_blueprint.scale",
                ),
                new ItemFunctionTextboxIntegerData(408, 552, 17, 3)
                    .setComponent("xscale")
                    .setPlaceholder("phantasia:tile.structure_blueprint.xscale")
                    .setRange(1, 255),
                new ItemFunctionTextboxIntegerData(408, 552, 17, 3)
                    .setComponent("yscale")
                    .setPlaceholder("phantasia:tile.structure_blueprint.yscale")
                    .setRange(1, 255),
                new ItemFunctionButtonData(480, 480, 17, 3)
                    .setText("Export")
                    .setOnSelectRelease("phantasia:export_structure"),
            ]),
        ],
    ),
];
