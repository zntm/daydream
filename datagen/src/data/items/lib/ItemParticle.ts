export class ItemParticle {
    private id: string | string[];
    private frequency: string | number;

    constructor(id: string | string[], frequency: string | number) {
        this.id = id;
        this.frequency = frequency;
    }
}
