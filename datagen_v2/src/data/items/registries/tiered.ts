export class EquipmentRegistry {
    namespace: string;
    id: string;
    helmet: AccessoryRegistry;
    breastplate: AccessoryRegistry;
    leggings: AccessoryRegistry;
    sword: ToolRegistry;
    pickaxe: ToolRegistry;
    axe: ToolRegistry;
    shovel: ToolRegistry;
    bow: ToolRegistry;
    harvest: HarvestRegistry;

    constructor(
        namespace: string,
        id: string,
        helmet: AccessoryRegistry,
        breastplate: AccessoryRegistry,
        leggings: AccessoryRegistry,
        sword: ToolRegistry,
        pickaxe: ToolRegistry,
        axe: ToolRegistry,
        shovel: ToolRegistry,
        bow: ToolRegistry,
        harvest: HarvestRegistry,
    ) {
        this.namespace = namespace;
        this.id = id;
        this.helmet = helmet;
        this.breastplate = breastplate;
        this.leggings = leggings;
        this.sword = sword;
        this.pickaxe = pickaxe;
        this.axe = axe;
        this.shovel = shovel;
        this.bow = bow;
        this.harvest = harvest;
    }
}

export class AccessoryRegistry {
    defense: number;
    durability: number;

    constructor(defense: number, durability: number) {
        this.defense = defense;
        this.durability = durability;
    }
}

export class ToolRegistry {
    damage: number;
    durability: number;

    constructor(damage: number, durability: number) {
        this.damage = damage;
        this.durability = durability;
    }
}

export class HarvestRegistry {
    hardness: number;
    level: number;

    constructor(hardness: number, level: number) {
        this.hardness = hardness;
        this.level = level;
    }
}

export default [
    new EquipmentRegistry(
        "phantasia",
        "copper",
        new AccessoryRegistry(2, 100),
        new AccessoryRegistry(4, 136),
        new AccessoryRegistry(3, 108),
        new ToolRegistry(5, 162),
        new ToolRegistry(4, 141),
        new ToolRegistry(4, 133),
        new ToolRegistry(3, 125),
        new ToolRegistry(4, 150),
        new HarvestRegistry(1.12, 2),
    ),
    new EquipmentRegistry(
        "phantasia",
        "iron",
        new AccessoryRegistry(4, 277),
        new AccessoryRegistry(7, 308),
        new AccessoryRegistry(5, 244),
        new ToolRegistry(7, 367),
        new ToolRegistry(6, 319),
        new ToolRegistry(6, 300),
        new ToolRegistry(4, 283),
        new ToolRegistry(6, 340),
        new HarvestRegistry(1.12, 2),
    ),
    new EquipmentRegistry(
        "phantasia",
        "gold",
        new AccessoryRegistry(6, 494),
        new AccessoryRegistry(11, 671),
        new AccessoryRegistry(8, 531),
        new ToolRegistry(8, 799),
        new ToolRegistry(7, 695),
        new ToolRegistry(7, 653),
        new ToolRegistry(5, 616),
        new ToolRegistry(7, 740),
        new HarvestRegistry(1.12, 2),
    ),
    new EquipmentRegistry(
        "phantasia",
        "platinum",
        new AccessoryRegistry(7, 766),
        new AccessoryRegistry(13, 1041),
        new AccessoryRegistry(9, 823),
        new ToolRegistry(13, 1239),
        new ToolRegistry(11, 1078),
        new ToolRegistry(10, 1012),
        new ToolRegistry(7, 955),
        new ToolRegistry(11, 1150),
        new HarvestRegistry(1.12, 2),
    ),
];
