import { DatagenReturnData } from "../index";

export class Item {
    public type: ItemType;
    public sprite: string | ItemSprite;
    public inventory: string | ItemInventory;
    public properties?: any;

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
                ? properties
                : [properties];

            this.properties.sort();
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
    private second: number;

    constructor(id: string, second: number) {
        this.id = id;
        this.second = second;
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

export class ItemSoundEffect {
    private id: string;
    private gain?: number;

    constructor(id: string, gain?: number) {
        this.id = id;

        if (gain !== undefined) {
            this.gain = gain;
        }
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
    ItemTileHarvest,
    ItemTileParticle,
    ItemTilePlacement,
    ItemTileProperties,
} = import.meta.require("./items/tileItem");

const { default: woodItems } = import.meta.require("./items/woodItems");

export default [
    consumableItem(
        "apple",
        "#phantasia:item/generic/inventory_default",
        new ItemConsumable(
            8,
            4,
            new ItemCooldown("phantasia:food", 1),
            new ItemSoundEffect("phantasia:sound.eat"),
        ),
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
                    "#phantasia:tile/particle_colour/stone",
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
                new ItemSoundEffect("phantasia:sound.eat"),
            ),
            cookedConsumable: new ItemConsumable(
                8,
                8,
                new ItemCooldown("phantasia:food", 1),
                new ItemSoundEffect("phantasia:sound.eat"),
            ),
        },
        {
            id: "rabbit",
            rawConsumable: new ItemConsumable(
                3,
                2,
                new ItemCooldown("phantasia:food", 1),
                new ItemSoundEffect("phantasia:sound.eat"),
            ),
            cookedConsumable: new ItemConsumable(
                6,
                4,
                new ItemCooldown("phantasia:food", 1),
                new ItemSoundEffect("phantasia:sound.eat"),
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
        "globeflower",
        "lilybell",
        "orchids",
        "rose",
    ].map((id: string) =>
        tileItem(
            id,
            ItemType.Untouchable,
            "#phantasia:item/generic/inventory_default",
            ItemTileProperties.IsFoliage,
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
                "#phantasia:tile/particle_colour/plant",
            ),
        ),
    ),
    // Grass
    ...["", "borea", "dry", "myr"]
        .map((id: string) => {
            id = id !== "" ? `${id}_grass` : "grass";

            return ["short", "tall"].map((type: string) =>
                tileItem(
                    `${type}_${id}`,
                    ItemType.Untouchable,
                    "#phantasia:item/generic/inventory_default",
                    ItemTileProperties.IsFoliage,
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
                        "#phantasia:tile/particle_colour/plant",
                    ),
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
];
