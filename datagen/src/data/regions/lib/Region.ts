export class RegionTerrain {
    height_offset?: number;
    base_height?: number;
    amplitude_min?: number;
    amplitude_max?: number;
    noise_scale?: number;

    constructor(opts: {
        heightOffset?: number,
        baseHeight?: number,
        amplitudeMin?: number,
        amplitudeMax?: number,
        noiseScale?: number,
    } = {}) {
        if (opts.heightOffset !== undefined) this.height_offset = opts.heightOffset;
        if (opts.baseHeight !== undefined) this.base_height = opts.baseHeight;
        if (opts.amplitudeMin !== undefined) this.amplitude_min = opts.amplitudeMin;
        if (opts.amplitudeMax !== undefined) this.amplitude_max = opts.amplitudeMax;
        if (opts.noiseScale !== undefined) this.noise_scale = opts.noiseScale;
    }
}

export class RegionCaveBiome {
    biome: string;
    min_depth?: number;
    max_depth?: number;
    noise_threshold?: number;
    noise_scale?: number;
    weight?: number;
    z_layer?: number;

    constructor(biome: string, opts: {
        minDepth?: number,
        maxDepth?: number,
        noiseThreshold?: number,
        noiseScale?: number,
        weight?: number,
        zLayer?: number
    } = {}) {
        this.biome = biome;
        if (opts.minDepth !== undefined) this.min_depth = opts.minDepth;
        if (opts.maxDepth !== undefined) this.max_depth = opts.maxDepth;
        if (opts.noiseThreshold !== undefined) this.noise_threshold = opts.noiseThreshold;
        if (opts.noiseScale !== undefined) this.noise_scale = opts.noiseScale;
        if (opts.weight !== undefined) this.weight = opts.weight;
        if (opts.zLayer !== undefined) this.z_layer = opts.zLayer;
    }
}

export type TerrainPreference = "flat" | "hilly" | "any";

export class RegionBiome {
    id: string;
    weight: number;
    terrain_preference: TerrainPreference;

    constructor(id: string, weight: number = 1, terrainPreference: TerrainPreference = "any") {
        this.id = id;
        this.weight = weight;
        this.terrain_preference = terrainPreference;
    }
}

export class Region {
    id: string;
    category?: string;
    biomes: RegionBiome[];
    cave_biome_default: string;
    cave_biomes?: RegionCaveBiome[];
    terrain?: RegionTerrain;
    biome_noise_scale?: number;
    map_color: string;

    constructor(id: string, opts: {
        category?: string,
        biomes: RegionBiome[],
        caveBiomeDefault?: string,
        caveBiomes?: RegionCaveBiome[],
        terrain?: RegionTerrain,
        biomeNoiseScale?: number,
        mapColor?: string,
    }) {
        this.id = id;
        this.category = opts.category;
        this.biomes = opts.biomes;
        this.map_color = opts.mapColor ?? "#000000";
        this.cave_biome_default = opts.caveBiomeDefault ?? "phantasia:cave/chasm";
        if (opts.caveBiomes) this.cave_biomes = opts.caveBiomes;
        if (opts.terrain) this.terrain = opts.terrain;
        if (opts.biomeNoiseScale !== undefined) this.biome_noise_scale = opts.biomeNoiseScale;
    }
}
