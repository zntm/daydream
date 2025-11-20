export class Noise {
    private min?: number;
    private max?: number;
    private octaves: number;

    constructor(octaves: number, min?: number, max?: number) {
        this.octaves = octaves;
        this.min = min;
        this.max = max;
    }
}
