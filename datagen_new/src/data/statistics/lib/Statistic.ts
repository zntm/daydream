export enum StatisticType {
    Counter = "counter", // Increments (e.g., tiles broken)
    Max = "max", // Track maximum (e.g., highest jump)
    Min = "min", // Track minimum (e.g., fastest completion)
    Timer = "timer", // Track time (e.g., playtime)
}

export enum StatisticCategory {
    Blocks = "blocks",
    Combat = "combat",
    Movement = "movement",
    Crafting = "crafting",
    Exploration = "exploration",
    Misc = "misc",
}

export class Statistic {
    private type: StatisticType;
    private category: StatisticCategory;
    private default_value?: number;

    constructor(
        type: StatisticType,
        category: StatisticCategory,
        defaultValue?: number
    ) {
        this.type = type;
        this.category = category;
        this.default_value = defaultValue;
    }
}
