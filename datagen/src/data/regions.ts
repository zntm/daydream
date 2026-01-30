import { DatagenReturnData } from "../../index";

export class RegionTerrain {
    height_offset?: number;
    base_height?: number;
    amplitude_min?: number;
    amplitude_max?: number;
    noise_scale?: number;
    gradient_strength?: number;

    constructor(opts: {
        heightOffset?: number,
        baseHeight?: number,
        amplitudeMin?: number,
        amplitudeMax?: number,
        noiseScale?: number,
        gradientStrength?: number
    } = {}) {
        if (opts.heightOffset !== undefined) this.height_offset = opts.heightOffset;
        if (opts.baseHeight !== undefined) this.base_height = opts.baseHeight;
        if (opts.amplitudeMin !== undefined) this.amplitude_min = opts.amplitudeMin;
        if (opts.amplitudeMax !== undefined) this.amplitude_max = opts.amplitudeMax;
        if (opts.noiseScale !== undefined) this.noise_scale = opts.noiseScale;
        if (opts.gradientStrength !== undefined) this.gradient_strength = opts.gradientStrength;
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

export class Region {
    id: string;
    category?: string;
    surface_biome: string;
    cave_biome_default: string;
    cave_biomes?: RegionCaveBiome[];
    terrain?: RegionTerrain;
    fog_color?: number;
    fog_density?: number;

    constructor(id: string, opts: {
        category?: string,
        surfaceBiome?: string,
        caveBiomeDefault?: string,
        caveBiomes?: RegionCaveBiome[],
        terrain?: RegionTerrain,
        fogColor?: number,
        fogDensity?: number
    }) {
        this.id = id;
        this.category = opts.category;
        this.surface_biome = opts.surfaceBiome ?? "phantasia:surface/forest";
        this.cave_biome_default = opts.caveBiomeDefault ?? "phantasia:cave/chasm";
        if (opts.caveBiomes) this.cave_biomes = opts.caveBiomes;
        if (opts.terrain) this.terrain = opts.terrain;
        if (opts.fogColor !== undefined) this.fog_color = opts.fogColor;
        if (opts.fogDensity !== undefined) this.fog_density = opts.fogDensity;
    }
}

export default [
    new DatagenReturnData(
        "generated/data/regions/regions.json",
        [
            new Region("forest", {
                category: "temperate",
                surfaceBiome: "phantasia:surface/forest",
                caveBiomeDefault: "phantasia:cave/chasm",
                caveBiomes: [
                    new RegionCaveBiome("phantasia:cave/depths", { minDepth: 150, noiseThreshold: 0.7, noiseScale: 0.015 })
                ]
            }),
            new Region("desert", {
                category: "arid",
                surfaceBiome: "phantasia:surface/desert",
                caveBiomeDefault: "phantasia:cave/chasm",
                terrain: new RegionTerrain({
                    heightOffset: 10, 
                    baseHeight: 410, 
                    amplitudeMin: 15, 
                    amplitudeMax: 35 
                }),
                caveBiomes: [
                    new RegionCaveBiome("phantasia:cave/depths", { minDepth: 250, noiseThreshold: 0.6 })
                ]
            }),
            new Region("taiga", {
                category: "cold",
                surfaceBiome: "phantasia:surface/taiga",
                caveBiomeDefault: "phantasia:cave/chasm",
                terrain: new RegionTerrain({
                    heightOffset: -20,
                    baseHeight: 380,
                    amplitudeMin: 20,
                    amplitudeMax: 50
                }),
                caveBiomes: [
                    new RegionCaveBiome("phantasia:cave/depths", { minDepth: 100, noiseThreshold: 0.5 })
                ]
            })
        ]
    )
];
