export class CaveRegionBiome {
    id: string;
    weight: number;

    constructor(id: string, weight: number = 1) {
        this.id = id;
        this.weight = weight;
    }
}

export class CaveRegion {
    id: string;
    biomes: CaveRegionBiome[];
    biome_noise_scale?: number;
    noise_scale?: number;
    noise_threshold?: number;
    min_depth?: number;
    max_depth?: number;
    salt?: number;

    constructor(id: string, opts: {
        biomes: CaveRegionBiome[],
        biomeNoiseScale?: number,
        noiseScale?: number,
        noiseThreshold?: number,
        minDepth?: number,
        maxDepth?: number,
        salt?: number,
    }) {
        this.id = id;
        this.biomes = opts.biomes;
        if (opts.biomeNoiseScale !== undefined) this.biome_noise_scale = opts.biomeNoiseScale;
        if (opts.noiseScale !== undefined) this.noise_scale = opts.noiseScale;
        if (opts.noiseThreshold !== undefined) this.noise_threshold = opts.noiseThreshold;
        if (opts.minDepth !== undefined) this.min_depth = opts.minDepth;
        if (opts.maxDepth !== undefined) this.max_depth = opts.maxDepth;
        if (opts.salt !== undefined) this.salt = opts.salt;
    }
}
