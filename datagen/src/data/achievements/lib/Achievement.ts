export enum AchievementTrigger {
    TileChanged = "TILE_CHANGED",
    EntityDeath = "ENTITY_DEATH",
    ItemCollected = "ITEM_COLLECTED",
    CraftingComplete = "CRAFTING_COMPLETE",
    StatisticReached = "STATISTIC_REACHED"
}

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
