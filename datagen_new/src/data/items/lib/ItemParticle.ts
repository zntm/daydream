export class ItemParticle {
    private colour: string | string[];
    private frequency: number | string;

    constructor(colour: string | string[], frequency: number | string) {
        this.colour = colour;
        this.frequency = frequency;
    }
}
