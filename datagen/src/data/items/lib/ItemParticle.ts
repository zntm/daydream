export class ItemParticle {
    private colour: string | string[];
    private frequency: string | number;

    constructor(colour: string | string[], frequency: string | number) {
        this.colour = colour;
        this.frequency = frequency;
    }
}
