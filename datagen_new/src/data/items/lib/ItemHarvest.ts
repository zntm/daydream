export class ItemHarvest {
    private hardness: number | string;
    private level?: number | string;

    constructor(hardness: number | string, level?: number | string) {
        this.hardness = hardness;

        if (level !== undefined) {
            this.level = level;
        }
    }
}
