import { DatagenReturnData } from "../../../lib";
import { Statistic, StatisticType, StatisticCategory } from "../lib/Statistic";

export default [
    // Block statistics
    new DatagenReturnData(
        "statistics/tiles_broken.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Blocks)
    ),
    new DatagenReturnData(
        "statistics/tiles_placed.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Blocks)
    ),

    // Combat statistics
    new DatagenReturnData(
        "statistics/mobs_killed.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Combat)
    ),
    new DatagenReturnData(
        "statistics/damage_dealt.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Combat)
    ),
    new DatagenReturnData(
        "statistics/damage_taken.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Combat)
    ),
    new DatagenReturnData(
        "statistics/deaths.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Combat)
    ),

    // Movement statistics
    new DatagenReturnData(
        "statistics/distance_walked.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Movement)
    ),
    new DatagenReturnData(
        "statistics/distance_fallen.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Movement)
    ),
    new DatagenReturnData(
        "statistics/jumps.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Movement)
    ),

    // Crafting statistics
    new DatagenReturnData(
        "statistics/items_crafted.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Crafting)
    ),

    // Exploration statistics
    new DatagenReturnData(
        "statistics/chunks_explored.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Exploration)
    ),

    // Time statistics
    new DatagenReturnData(
        "statistics/playtime.json",
        new Statistic(StatisticType.Timer, StatisticCategory.Misc)
    ),

    // Misc statistics
    new DatagenReturnData(
        "statistics/items_collected.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Misc)
    ),
];
