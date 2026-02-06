export class ItemCooldown {
    private id: string;
    private seconds: number;

    constructor(id: string, seconds: number) {
        this.id = id;
        this.seconds = seconds;
    }
}
