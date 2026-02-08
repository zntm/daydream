export class ItemParticle {
    private id: string;
    private frequency: string | number;

    constructor(id: string, frequency: string | number) {
        this.id = id;
        this.frequency = frequency;
    }
}
