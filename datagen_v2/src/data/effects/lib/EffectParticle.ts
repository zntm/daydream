/**
 * Particle effect configuration for status effects.
 */
export class EffectParticle {
    public id: string;
    public chance: number;
    public colour?: string;

    /**
     * @param id - Particle ID (e.g., "phantasia:effect", "phantasia:inkdrop")
     * @param chance - Spawn chance per tick (0.0 - 1.0)
     * @param colour - Optional hex color (e.g., "#B57F5E")
     */
    constructor(id: string, chance: number, colour?: string) {
        this.id = id;
        this.chance = chance;

        if (colour !== undefined) {
            this.colour = colour;
        }
    }

    static sprite(id: string, chance: number, color?: string) {
        return new EffectParticle(id, chance, color);
    }
}
