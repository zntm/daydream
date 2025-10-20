import { DatagenReturnData } from "../index";

export class Item {
    public type: string;
    public sprite: string | ItemSprite;
    public inventory: string | ItemInventory;
    public properties?: any;

    constructor(
        type: string,
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

export class ItemInventory {}

export class ItemHarvest {
    private hardness: number;
    private level: number;

    constructor(hardness: number, level: number) {
        this.hardness = hardness;
        this.level = level;
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

export class ItemDurability {
    private amount: number;
    private bar: string;

    constructor(amount: number, bar: string) {
        this.amount = amount;
        this.bar = bar;
    }
}

export enum ItemType {
    Default = "default",
    Solid = "solid",
    Untouchable = "untouchable",
    Tool = "tool",
}

const { default: consumableItem } = import.meta.require(
    "./items/consumableItem",
);

const { default: oreItems } = import.meta.require("./items/oreItems");

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
    ),
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
    ]
        .map(
            ({
                id,
                harvestLevel,
                blockHarvest,
                blockSFX,
                oreHarvest,
                oreSFX,
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
