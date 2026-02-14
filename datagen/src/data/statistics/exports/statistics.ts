import { DatagenReturnData } from "../../../lib";
<<<<<<< HEAD:datagen_new/src/data/statistics/exports/statistic.ts
import { Statistic, StatisticCategory, StatisticType } from "../lib/Statistic";
=======
import { Statistic, StatisticType, StatisticCategory } from "../lib/Statistic";
>>>>>>> region:datagen/src/data/statistics/exports/statistics.ts

export default [
    // Block statistics
    new DatagenReturnData(
<<<<<<< HEAD:datagen_new/src/data/statistics/exports/statistic.ts
        "tiles_broken.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Blocks),
    ),
    new DatagenReturnData(
        "tiles_placed.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Blocks),
=======
        "statistics/tiles_broken.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Blocks)
    ),
    new DatagenReturnData(
        "statistics/tiles_placed.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Blocks)
>>>>>>> region:datagen/src/data/statistics/exports/statistics.ts
    ),

    // Combat statistics
    new DatagenReturnData(
<<<<<<< HEAD:datagen_new/src/data/statistics/exports/statistic.ts
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
=======
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
>>>>>>> region:datagen/src/data/statistics/exports/statistics.ts
    ),

    // Movement statistics
    new DatagenReturnData(
<<<<<<< HEAD:datagen_new/src/data/statistics/exports/statistic.ts
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
=======
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
>>>>>>> region:datagen/src/data/statistics/exports/statistics.ts
    ),

    // Crafting statistics
    new DatagenReturnData(
<<<<<<< HEAD:datagen_new/src/data/statistics/exports/statistic.ts
        "items_crafted.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Crafting),
=======
        "statistics/items_crafted.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Crafting)
>>>>>>> region:datagen/src/data/statistics/exports/statistics.ts
    ),

    // Exploration statistics
    new DatagenReturnData(
<<<<<<< HEAD:datagen_new/src/data/statistics/exports/statistic.ts
        "chunks_explored.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Exploration),
=======
        "statistics/chunks_explored.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Exploration)
>>>>>>> region:datagen/src/data/statistics/exports/statistics.ts
    ),

    // Time statistics
    new DatagenReturnData(
<<<<<<< HEAD:datagen_new/src/data/statistics/exports/statistic.ts
        "playtime.json",
        new Statistic(StatisticType.Timer, StatisticCategory.Misc),
=======
        "statistics/playtime.json",
        new Statistic(StatisticType.Timer, StatisticCategory.Misc)
>>>>>>> region:datagen/src/data/statistics/exports/statistics.ts
    ),

    // Misc statistics
    new DatagenReturnData(
<<<<<<< HEAD:datagen_new/src/data/statistics/exports/statistic.ts
        "items_collected.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Misc),
=======
        "statistics/items_collected.json",
        new Statistic(StatisticType.Counter, StatisticCategory.Misc)
>>>>>>> region:datagen/src/data/statistics/exports/statistics.ts
    ),
];
