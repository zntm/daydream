import { Spline } from "./Spline";

export class Noise {
    octaves: number;
    min?: number;
    max?: number;
    scale?: number; // For noise_scale
    offset?: number; // For generic offset (seed or other)
    y_offset?: number; // For specific Y offset
    range?: number; // For noise range (e.g. 0-255 vs 0-63)
    noise_scale_x?: number; // Specific X scale
    noise_scale_y?: number; // Specific Y scale
    octaves_offset?: number; // Octave offset
    spline_x?: Spline;
    spline_y?: Spline;

    constructor(
        octaves: number,
        min?: number,
        max?: number,
        scale?: number,
        offset?: number,
        y_offset?: number,
        range?: number,
    ) {
        this.octaves = octaves;
        this.min = min;
        this.max = max;
        this.scale = scale;
        this.offset = offset;
        this.y_offset = y_offset;
        this.range = range;
    }

    setScale(scale: number) {
        this.scale = scale;
        return this;
    }

    setOffset(offset: number) {
        this.offset = offset;
        return this;
    }

    setYOffset(y_offset: number) {
        this.y_offset = y_offset;
        return this;
    }

    setRange(range: number) {
        this.range = range;
        return this;
    }

    setNoiseScale(x: number, y: number) {
        this.noise_scale_x = x;
        this.noise_scale_y = y;
        return this;
    }

    setOctaveOffset(offset: number) {
        this.octaves_offset = offset;
        return this;
    }

    setSplineX(spline: Spline) {
        this.spline_x = spline;
        return this;
    }

    setSplineY(spline: Spline) {
        this.spline_y = spline;
        return this;
    }
}
