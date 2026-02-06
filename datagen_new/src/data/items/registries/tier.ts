import { ArmorDataRegistry } from "../lib/groups/accessory.armor";

class ToolDataRegistry {
    damage: number;
    durability: number;

    constructor(damage: number, durability: number) {
        this.damage = damage;
        this.durability = durability;
    }
}

class HarvestRegistry {
    hardness: number;
    level: number;

    constructor(hardness: number, level: number) {
        this.hardness = hardness;
        this.level = level;
    }
}

class TierRegistry {
    namespace: string;
    id: string;
    armor: {
        helmet: ArmorDataRegistry;
        breastplate: ArmorDataRegistry;
        leggings: ArmorDataRegistry;
    };
    tools: {
        sword: ToolDataRegistry;
        pickaxe: ToolDataRegistry;
        axe: ToolDataRegistry;
        shovel: ToolDataRegistry;
    };
    harvest: HarvestRegistry;

    constructor(
        namespace: string,
        id: string,
        armor: {
            helmet: ArmorDataRegistry;
            breastplate: ArmorDataRegistry;
            leggings: ArmorDataRegistry;
        },
        tools: {
            sword: ToolDataRegistry;
            pickaxe: ToolDataRegistry;
            axe: ToolDataRegistry;
            shovel: ToolDataRegistry;
        },
        harvest: HarvestRegistry,
    ) {
        this.namespace = namespace;
        this.id = id;
        this.armor = armor;
        this.tools = tools;
        this.harvest = harvest;
    }
}

export default [
    new TierRegistry("phantasia", "copper", {
        helmet: new ArmorDataRegistry(2, 100),
        breastplate: new ArmorDataRegistry(4, 136),
        leggings: new ArmorDataRegistry(3, 108),
    }, {
        sword: new ToolDataRegistry(5, 162),
        pickaxe: new ToolDataRegistry(4, 141),
        axe: new ToolDataRegistry(4, 133),
        shovel: new ToolDataRegistry(3, 125),
    }, new HarvestRegistry(1.12, 2)),
    new TierRegistry("phantasia", "iron", {
        helmet: new ArmorDataRegistry(4, 277),
        breastplate: new ArmorDataRegistry(7, 308),
        leggings: new ArmorDataRegistry(5, 244),
    }, {
        sword: new ToolDataRegistry(7, 367),
        pickaxe: new ToolDataRegistry(6, 319),
        axe: new ToolDataRegistry(6, 300),
        shovel: new ToolDataRegistry(4, 283),
    }, new HarvestRegistry(1.19, 3)),
    new TierRegistry("phantasia", "gold", {
        helmet: new ArmorDataRegistry(6, 494),
        breastplate: new ArmorDataRegistry(11, 671),
        leggings: new ArmorDataRegistry(8, 531),
    }, {
        sword: new ToolDataRegistry(8, 799),
        pickaxe: new ToolDataRegistry(7, 695),
        axe: new ToolDataRegistry(7, 653),
        shovel: new ToolDataRegistry(5, 616),
    }, new HarvestRegistry(1.25, 4)),
    new TierRegistry("phantasia", "platinum", {
        helmet: new ArmorDataRegistry(7, 766),
        breastplate: new ArmorDataRegistry(13, 1041),
        leggings: new ArmorDataRegistry(9, 823),
    }, {
        sword: new ToolDataRegistry(13, 1239),
        pickaxe: new ToolDataRegistry(11, 1078),
        axe: new ToolDataRegistry(10, 1012),
        shovel: new ToolDataRegistry(7, 955),
    }, new HarvestRegistry(1.31, 5)),
];