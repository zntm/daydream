import { DatagenReturnData } from "../../../lib";
import { Achievement, AchievementCondition, AchievementTrigger } from "../lib/Achievement";

export default [
    // Getting Started achievements
    new DatagenReturnData(
        "achievements/first_wood.json",
        new Achievement(
            "phantasia:achievement/first_wood",
            new AchievementCondition()
                .setEvent(AchievementTrigger.TileChanged)
                .setItemId("phantasia:oak_log")
                .setCount(1)
        )
    ),

    new DatagenReturnData(
        "achievements/craft_hatchet.json",
        new Achievement(
            "phantasia:achievement/craft_hatchet",
            new AchievementCondition()
                .setEvent(AchievementTrigger.CraftingComplete)
                .setItemId([
                    "phantasia:wooden_axe",
                    "phantasia:stone_axe",
                    "phantasia:copper_axe"
                ])
                .setCount(1)
        )
    ),

    new DatagenReturnData(
        "achievements/mine_stone.json",
        new Achievement(
            "phantasia:achievement/mine_stone",
            new AchievementCondition()
                .setEvent(AchievementTrigger.TileChanged)
                .setItemId("phantasia:stone")
                .setCount(1)
        )
    ),

    new DatagenReturnData(
        "achievements/craft_pickaxe.json",
        new Achievement(
            "phantasia:achievement/craft_pickaxe",
            new AchievementCondition()
                .setEvent(AchievementTrigger.CraftingComplete)
                .setItemId([
                    "phantasia:wooden_pickaxe",
                    "phantasia:stone_pickaxe",
                    "phantasia:copper_pickaxe"
                ])
                .setCount(1)
        )
    ),

    new DatagenReturnData(
        "achievements/copper_tools.json",
        new Achievement(
            "phantasia:achievement/copper_tools",
            new AchievementCondition()
                .setEvent(AchievementTrigger.CraftingComplete)
                .setItemId("phantasia:copper_pickaxe")
                .setCount(1)
        )
    ),

    // Combat achievements  
    new DatagenReturnData(
        "achievements/first_kill.json",
        new Achievement(
            "phantasia:achievement/first_kill",
            new AchievementCondition()
                .setStatistic("mobs_killed", 1)
        )
    ),

    new DatagenReturnData(
        "achievements/monster_hunter.json",
        new Achievement(
            "phantasia:achievement/monster_hunter",
            new AchievementCondition()
                .setStatistic("mobs_killed", 50)
        )
    ),

    // Mining achievements
    new DatagenReturnData(
        "achievements/miner.json",
        new Achievement(
            "phantasia:achievement/miner",
            new AchievementCondition()
                .setStatistic("tiles_broken", 100)
        )
    ),

    new DatagenReturnData(
        "achievements/deep_miner.json",
        new Achievement(
            "phantasia:achievement/deep_miner",
            new AchievementCondition()
                .setStatistic("tiles_broken", 1000)
        )
    ),

    // Exploration achievements
    new DatagenReturnData(
        "achievements/explorer.json",
        new Achievement(
            "phantasia:achievement/explorer",
            new AchievementCondition()
                .setStatistic("chunks_explored", 25)
        )
    ),
];
