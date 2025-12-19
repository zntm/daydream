import { DatagenReturnData } from "../lib/DatagenReturnData";

/**
 * Statistic types for tracking
 */
export enum StatisticType {
    Counter = "counter",    // Increments (e.g., tiles broken)
    Max = "max",            // Track maximum (e.g., highest jump)
    Min = "min",            // Track minimum (e.g., fastest completion)
    Timer = "timer"         // Track time (e.g., playtime)
}

/**
 * Statistic categories for organization
 */
export enum StatisticCategory {
    Blocks = "blocks",
    Combat = "combat",
    Movement = "movement",
    Crafting = "crafting",
    Exploration = "exploration",
    Misc = "misc"
}

/**
 * Statistic definition class
 */
export class Statistic {
    private type: StatisticType;
    private category: StatisticCategory;
    private default_value?: number;

    constructor(type: StatisticType, category: StatisticCategory, defaultValue?: number) {
        this.type = type;
        this.category = category;
        this.default_value = defaultValue;
    }
}

export default [
    // Block statistics
    new DatagenReturnData(
        "generated/data/statistics/tiles_broken.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Blocks)
    ),
    new DatagenReturnData(
        "generated/data/statistics/tiles_placed.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Blocks)
    ),

    // Combat statistics
    new DatagenReturnData(
        "generated/data/statistics/mobs_killed.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Combat)
    ),
    new DatagenReturnData(
        "generated/data/statistics/damage_dealt.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Combat)
    ),
    new DatagenReturnData(
        "generated/data/statistics/damage_taken.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Combat)
    ),
    new DatagenReturnData(
        "generated/data/statistics/deaths.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Combat)
    ),

    // Movement statistics
    new DatagenReturnData(
        "generated/data/statistics/distance_walked.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Movement)
    ),
    new DatagenReturnData(
        "generated/data/statistics/distance_fallen.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Movement)
    ),
    new DatagenReturnData(
        "generated/data/statistics/jumps.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Movement)
    ),

    // Crafting statistics
    new DatagenReturnData(
        "generated/data/statistics/items_crafted.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Crafting)
    ),

    // Exploration statistics
    new DatagenReturnData(
        "generated/data/statistics/chunks_explored.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Exploration)
    ),

    // Time statistics
    new DatagenReturnData(
        "generated/data/statistics/playtime.json",
        new Statistic(StatisticType.Timer, StatisticCategory.Misc)
    ),

    // Misc statistics
    new DatagenReturnData(
        "generated/data/statistics/items_collected.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Misc)
    ),
];
