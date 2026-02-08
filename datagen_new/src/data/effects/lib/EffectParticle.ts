export class EffectParticle {
    public id: string;
    public chance: number;
    public colour?: string;

    constructor(id: string, chance: number, colour?: string) {
        this.id = id;
        this.chance = chance;
        if (colour !== undefined) {
            this.colour = colour;
        }
    }

    static sprite(id: string, chance: number, color?: string): EffectParticle {
        return new EffectParticle(id, chance, color);
    }
}
