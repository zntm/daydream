import { ItemScript, ItemSkill } from "../lib";
import { ArmorDataRegistry } from "../lib/groups/accessory.armor";

// Simple data interfaces instead of classes
interface ToolData {
    damage: number;
    durability: number;
    skill?: ItemSkill;
}

interface HarvestData {
    hardness: number;
    level: number;
}

interface ArmorSet {
    helmet: ArmorDataRegistry;
    breastplate: ArmorDataRegistry;
    leggings: ArmorDataRegistry;
}

interface ToolSet {
    sword: ToolData;
    pickaxe: ToolData;
    axe: ToolData;
    shovel: ToolData;
}

export interface TierData {
    namespace: string;
    id: string;
    armor: ArmorSet;
    tools: ToolSet;
    harvest: HarvestData;
}

// Helper to create sword skill
const swordSkill = (power: number) =>
    new ItemSkill(
        "charge",
        0.5,
        20,
        new ItemScript("@phantasia:item/tool/sword_dash", { power }),
    );

// Helper to create pickaxe skill
const pickaxeSkill = (count: number) =>
    new ItemSkill(
        "charge",
        1.0,
        25,
        new ItemScript("@phantasia:item/tool/mine_area", { count }),
    );

// Plain data - no class constructors needed
const TIERS: TierData[] = [
    {
        namespace: "phantasia",
        id: "copper",
        armor: {
            helmet: new ArmorDataRegistry(2, 100),
            breastplate: new ArmorDataRegistry(4, 136),
            leggings: new ArmorDataRegistry(3, 108),
        },
        tools: {
            sword: { damage: 5, durability: 162, skill: swordSkill(6) },
            pickaxe: { damage: 4, durability: 141, skill: pickaxeSkill(2) },
            axe: { damage: 4, durability: 133 },
            shovel: { damage: 3, durability: 125 },
        },
        harvest: { hardness: 1.12, level: 2 },
    },
    {
        namespace: "phantasia",
        id: "iron",
        armor: {
            helmet: new ArmorDataRegistry(4, 277),
            breastplate: new ArmorDataRegistry(7, 308),
            leggings: new ArmorDataRegistry(5, 244),
        },
        tools: {
            sword: { damage: 7, durability: 367, skill: swordSkill(8) },
            pickaxe: { damage: 6, durability: 319, skill: pickaxeSkill(3) },
            axe: { damage: 6, durability: 300 },
            shovel: { damage: 4, durability: 283 },
        },
        harvest: { hardness: 1.19, level: 3 },
    },
    {
        namespace: "phantasia",
        id: "gold",
        armor: {
            helmet: new ArmorDataRegistry(6, 494),
            breastplate: new ArmorDataRegistry(11, 671),
            leggings: new ArmorDataRegistry(8, 531),
        },
        tools: {
            sword: { damage: 8, durability: 799, skill: swordSkill(10) },
            pickaxe: { damage: 7, durability: 695, skill: pickaxeSkill(4) },
            axe: { damage: 7, durability: 653 },
            shovel: { damage: 5, durability: 616 },
        },
        harvest: { hardness: 1.25, level: 4 },
    },
    {
        namespace: "phantasia",
        id: "platinum",
        armor: {
            helmet: new ArmorDataRegistry(7, 766),
            breastplate: new ArmorDataRegistry(13, 1041),
            leggings: new ArmorDataRegistry(9, 823),
        },
        tools: {
            sword: { damage: 13, durability: 1239, skill: swordSkill(11) },
            pickaxe: { damage: 11, durability: 1078, skill: pickaxeSkill(5) },
            axe: { damage: 10, durability: 1012 },
            shovel: { damage: 7, durability: 955 },
        },
        harvest: { hardness: 1.31, level: 5 },
    },
];

export default TIERS;
