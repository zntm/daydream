export class ItemHarvest {
    private hardness: number;
    private level?: number;

    constructor(hardness: number, level?: number) {
        this.hardness = hardness;

        if (level !== undefined) {
            this.level = level;
        }
    }
}
