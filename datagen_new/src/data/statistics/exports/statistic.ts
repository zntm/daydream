import { DatagenReturnData } from "../../../lib";
import { Statistic, StatisticCategory, StatisticType } from "../lib/Statistic";

export default [
    // Block statistics
    new DatagenReturnData(
        "tiles_broken.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Blocks),
    ),
    new DatagenReturnData(
        "tiles_placed.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Blocks),
    ),

    // Combat statistics
    new DatagenReturnData(
        "mobs_killed.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Combat),
    ),
    new DatagenReturnData(
        "damage_dealt.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Combat),
    ),
    new DatagenReturnData(
        "damage_taken.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Combat),
    ),
    new DatagenReturnData(
        "deaths.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Combat),
    ),

    // Movement statistics
    new DatagenReturnData(
        "distance_walked.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Movement),
    ),
    new DatagenReturnData(
        "distance_fallen.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Movement),
    ),
    new DatagenReturnData(
        "jumps.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Movement),
    ),

    // Crafting statistics
    new DatagenReturnData(
        "items_crafted.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Crafting),
    ),

    // Exploration statistics
    new DatagenReturnData(
        "chunks_explored.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Exploration),
    ),

    // Time statistics
    new DatagenReturnData(
        "playtime.json",
        new Statistic(StatisticType.Timer, StatisticCategory.Misc),
    ),

    // Misc statistics
    new DatagenReturnData(
        "items_collected.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Misc),
    ),
];
