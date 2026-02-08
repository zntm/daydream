export class EffectParticle {
    id: string;
    chance: number;
    colour?: string;

    constructor(id: string, chance: number, colour?: string) {
        this.id = id;
        this.chance = chance;
        if (colour !== undefined) this.colour = colour;
    }

    static sprite(id: string, chance: number, color?: string): EffectParticle {
        return new EffectParticle(id, chance, color);
    }
}

// Factory function alias
export const particle = (id: string, chance: number, colour?: string) =>
    new EffectParticle(id, chance, colour);
