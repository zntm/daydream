import { DatagenReturnData } from "../lib/DatagenReturnData";

/**
 * Achievement trigger types
 */
export enum AchievementTrigger {
    TileChanged = "TILE_CHANGED",
    EntityDeath = "ENTITY_DEATH",
    ItemCollected = "ITEM_COLLECTED",
    CraftingComplete = "CRAFTING_COMPLETE",
    StatisticReached = "STATISTIC_REACHED"
}

/**
 * Achievement condition for triggering
 */
export class AchievementCondition {
    private event?: AchievementTrigger;
    private statistic?: string;
    private item_id?: string;
    private entity_id?: string;
    private count?: number;

    setEvent(event: AchievementTrigger) {
        this.event = event;
        return this;
    }

    setStatistic(stat_id: string, count: number) {
        this.statistic = stat_id;
        this.count = count;
        return this;
    }

    setItemId(id: string | string[]) {
        this.item_id = Array.isArray(id) ? id.join(",") : id;
        return this;
    }

    setEntityId(id: string) {
        this.entity_id = id;
        return this;
    }

    setCount(count: number) {
        this.count = count;
        return this;
    }
}

/**
 * Achievement class
 */
export class Achievement {
    private icon: string;
    private condition: AchievementCondition;
    private reward?: {
        item?: string;
        amount?: number;
    };
    private hidden?: boolean;

    constructor(icon: string, condition: AchievementCondition) {
        this.icon = icon;
        this.condition = condition;
    }

    setReward(itemId: string, amount: number = 1) {
        this.reward = { item: itemId, amount };
        return this;
    }

    setHidden(hidden: boolean = true) {
        this.hidden = hidden;
        return this;
    }
}

export default [
    // Getting Started achievements
    new DatagenReturnData(
        "generated/data/achievements/first_wood.json",
        new Achievement(
            "phantasia:achievement/first_wood",
            new AchievementCondition()
                .setEvent(AchievementTrigger.TileChanged)
                .setItemId("phantasia:oak_log")
                .setCount(1)
        )
    ),

    new DatagenReturnData(
        "generated/data/achievements/craft_hatchet.json",
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
        "generated/data/achievements/mine_stone.json",
        new Achievement(
            "phantasia:achievement/mine_stone",
            new AchievementCondition()
                .setEvent(AchievementTrigger.TileChanged)
                .setItemId("phantasia:stone")
                .setCount(1)
        )
    ),

    new DatagenReturnData(
        "generated/data/achievements/craft_pickaxe.json",
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
        "generated/data/achievements/copper_tools.json",
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
        "generated/data/achievements/first_kill.json",
        new Achievement(
            "phantasia:achievement/first_kill",
            new AchievementCondition()
                .setStatistic("mobs_killed", 1)
        )
    ),

    new DatagenReturnData(
        "generated/data/achievements/monster_hunter.json",
        new Achievement(
            "phantasia:achievement/monster_hunter",
            new AchievementCondition()
                .setStatistic("mobs_killed", 50)
        )
    ),

    // Mining achievements
    new DatagenReturnData(
        "generated/data/achievements/miner.json",
        new Achievement(
            "phantasia:achievement/miner",
            new AchievementCondition()
                .setStatistic("tiles_broken", 100)
        )
    ),

    new DatagenReturnData(
        "generated/data/achievements/deep_miner.json",
        new Achievement(
            "phantasia:achievement/deep_miner",
            new AchievementCondition()
                .setStatistic("tiles_broken", 1000)
        )
    ),

    // Exploration achievements
    new DatagenReturnData(
        "generated/data/achievements/explorer.json",
        new Achievement(
            "phantasia:achievement/explorer",
            new AchievementCondition()
                .setStatistic("chunks_explored", 25)
        )
    ),
];
