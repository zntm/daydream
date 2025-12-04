export class Noise {
    octaves: number;
    min?: number;
    max?: number;

    constructor(octaves: number, min?: number, max?: number) {
        this.octaves = octaves;
        this.min = min;
        this.max = max;
    }
}
