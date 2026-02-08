import { Noise, Spline } from "../../../lib";

export class WorldVignette {
    private ystart: number;
    private yend: number;
    private colour: string;

    constructor(start: number, end: number, colour: string) {
        this.ystart = start;
        this.yend = end;
        this.colour = colour;
    }
}

export class WorldTimeDiurnal {
    private id: string;
    private time_range_min: number;
    private time_range_max: number;

    constructor(id: string, start: number, end: number) {
        this.id = id;
        this.time_range_min = start;
        this.time_range_max = end;
    }
}

export class WorldTime {
    private start: number;
    private diurnal: WorldTimeDiurnal[];
    private length: number;

    constructor(start: number, diurnal: WorldTimeDiurnal[], length: number) {
        this.start = start;
        this.diurnal = diurnal;
        this.length = length;
    }
}

export class WorldCelestial {
    private id: string;
    private time_range_min: number;
    private time_range_max: number;

    constructor(id: string, timeStart: number, timeEnd: number) {
        this.id = id;
        this.time_range_min = timeStart;
        this.time_range_max = timeEnd;
    }
}

export enum WorldCaveBiomeTransitionType {
    Random = "random",
    Noise = "noise",
}

export class WorldCaveBiome {
    private id: string;
    private start: number;
    private end: number;
    private transition: Noise | { type: WorldCaveBiomeTransitionType };

    constructor(
        id: string,
        start: number,
        end: number,
        transition: Noise | { type: WorldCaveBiomeTransitionType },
    ) {
        this.id = id;
        this.start = start;
        this.end = end;
        this.transition = transition;
    }
}

export class WorldSky {
    private enabled: boolean;
    private id: string;
    private threshold: number;
    private spacing: number;
    private radius: number;
    private thickness: number;
    private noise_scale_region: number;
    private noise_scale_edge: number;
    private noise_scale_detail: number;
    private region_offset_y?: number;
    private region_range?: number;
    private region_octaves?: number;
    private region_threshold?: number;
    private edge_noise_amplitude?: number;
    private edge_noise_octaves?: number;
    private detail_noise_amplitude?: number;
    private detail_noise_octaves?: number;

    constructor(
        enabled: boolean = true,
        id: string = "phantasia:sky/floating_islands",
    ) {
        this.enabled = enabled;
        this.id = id;
        this.threshold = 256;
        this.spacing = 32;
        this.radius = 18;
        this.thickness = 10;
        this.noise_scale_region = 0.12;
        this.noise_scale_edge = 0.15;
        this.noise_scale_detail = 0.3;
    }

    setRegionNoise(
        offsetY: number,
        range: number,
        octaves: number,
        threshold: number,
    ): this {
        this.region_offset_y = offsetY;
        this.region_range = range;
        this.region_octaves = octaves;
        this.region_threshold = threshold;
        return this;
    }

    setEdgeNoise(amplitude: number, octaves: number): this {
        this.edge_noise_amplitude = amplitude;
        this.edge_noise_octaves = octaves;
        return this;
    }

    setDetailNoise(amplitude: number, octaves: number): this {
        this.detail_noise_amplitude = amplitude;
        this.detail_noise_octaves = octaves;
        return this;
    }
}

export class WorldBiome {
    private cave: {
        default: WorldCaveBiome[];
        noise: Noise;
        options: any[];
        heat?: Noise;
        humidity?: Noise;
        map?: string;
    };

    private surface: {
        heat: Noise;
        humidity: Noise;
        map: string;
        offset: Noise;
    };

    private sky?: WorldSky;

    constructor(
        defaultCaveBiomes: WorldCaveBiome[],
        caveNoise: Noise,
        surfaceHeat: Noise,
        surfaceHumidity: Noise,
        surfaceMap: string,
        surfaceOffset: Noise,
    ) {
        this.cave = {
            default: defaultCaveBiomes,
            noise: caveNoise,
            options: [],
        };
        this.surface = {
            heat: surfaceHeat,
            humidity: surfaceHumidity,
            map: surfaceMap,
            offset: surfaceOffset,
        };
    }

    setCaveMetadata(heat?: Noise, humidity?: Noise, map?: string): this {
        this.cave.heat = heat;
        this.cave.humidity = humidity;
        this.cave.map = map;
        return this;
    }

    setSky(sky: WorldSky): this {
        this.sky = sky;
        return this;
    }
}

export class WorldSurfaceSmoothing {
    private range: number;
    private factor: number;

    constructor(range: number = 32, factor: number = 0.6) {
        this.range = range;
        this.factor = factor;
    }
}

export class WorldSurface {
    private start: number;
    private noise_offset: Noise;
    private smoothing: WorldSurfaceSmoothing;
    private noise_scale: number;
    private seed_offset: number;
    private min_depth: number;
    private bedrock_depth: number;
    private bedrock_noise_scale: number;
    private tile_variation_noise_scale: number;
    private biome_blend_range: number;
    private biome_blend_noise_scale: number;

    constructor(start: number, noiseOffset: Noise) {
        this.start = start;
        this.noise_offset = noiseOffset;
        this.smoothing = new WorldSurfaceSmoothing();
        this.noise_scale = 0.015625;
        this.seed_offset = -40;
        this.min_depth = 8;
        this.bedrock_depth = 3;
        this.bedrock_noise_scale = 0.3;
        this.tile_variation_noise_scale = 0.05;
        this.biome_blend_range = 24;
        this.biome_blend_noise_scale = 0.08;
    }

    setSmoothing(range: number, factor: number): this {
        this.smoothing = new WorldSurfaceSmoothing(range, factor);
        return this;
    }

    setAdvanced(config: {
        noise_scale?: number;
        seed_offset?: number;
        min_depth?: number;
        bedrock_depth?: number;
        bedrock_noise_scale?: number;
        tile_variation?: number;
        biome_blend_range?: number;
        biome_blend_noise?: number;
    }): this {
        if (config.noise_scale !== undefined)
            this.noise_scale = config.noise_scale;
        if (config.seed_offset !== undefined)
            this.seed_offset = config.seed_offset;
        if (config.min_depth !== undefined) this.min_depth = config.min_depth;
        if (config.bedrock_depth !== undefined)
            this.bedrock_depth = config.bedrock_depth;
        if (config.bedrock_noise_scale !== undefined)
            this.bedrock_noise_scale = config.bedrock_noise_scale;
        if (config.tile_variation !== undefined)
            this.tile_variation_noise_scale = config.tile_variation;
        if (config.biome_blend_range !== undefined)
            this.biome_blend_range = config.biome_blend_range;
        if (config.biome_blend_noise !== undefined)
            this.biome_blend_noise_scale = config.biome_blend_noise;
        return this;
    }
}

export class WorldCaveSystem {
    private range_min: number;
    private range_max: number;
    private threshold: Noise;

    constructor(rangeMin: number, rangeMax: number, threshold: Noise) {
        this.range_min = rangeMin;
        this.range_max = rangeMax;
        this.threshold = threshold;
    }
}

export class WorldAquifer {
    private type: string; // Liquid tile ID (e.g., "phantasia:water")
    private depth_min: number; // Min depth from surface
    private depth_max: number; // Max depth from surface
    private threshold: number; // Noise threshold (0-255, higher = rarer)
    private octaves: number; // Noise octaves
    private fill_level: number; // Liquid fill level (1-8)
    private noise_scale: number; // Noise scale
    private range?: number; // Noise range (0-255)

    constructor(
        type: string,
        depthMin: number,
        depthMax: number,
        threshold: number,
        octaves: number = 3,
        fillLevel: number = 8,
        noiseScale: number = 0.02,
        range: number = 255,
    ) {
        this.type = type;
        this.depth_min = depthMin;
        this.depth_max = depthMax;
        this.threshold = threshold;
        this.octaves = octaves;
        this.fill_level = fillLevel;
        this.noise_scale = noiseScale;
        this.range = range;
    }
}

export class WorldCave {
    private start: Noise;
    private system: WorldCaveSystem[];
    private aquifers?: WorldAquifer[];
    private depth_smoothing?: Spline;
    private noise_scale: number;
    private breach_threshold: number;
    private breach_depth: number;
    private transition_threshold: number;
    private breach_noise_scale_x: number;
    private breach_noise_scale_y: number;
    private breach_noise_offset_y: number;
    private breach_noise_range: number;
    private breach_noise_octaves: number;
    private transition_noise_scale_x: number;
    private transition_noise_scale_y: number;
    private transition_noise_range: number;
    private transition_noise_octaves: number;

    constructor(start: Noise, system: WorldCaveSystem[]) {
        this.start = start;
        this.system = system;
        this.noise_scale = 0.015625;
        this.breach_threshold = 242;
        this.breach_depth = -8;
        this.transition_threshold = 220;
        this.breach_noise_scale_x = 0.03;
        this.breach_noise_scale_y = 0.03;
        this.breach_noise_offset_y = 1000;
        this.breach_noise_range = 255;
        this.breach_noise_octaves = 2;
        this.transition_noise_scale_x = 0.02;
        this.transition_noise_scale_y = 0.02;
        this.transition_noise_range = 255;
        this.transition_noise_octaves = 3;
    }

    setAquifers(aquifers: WorldAquifer[]): this {
        this.aquifers = aquifers;
        return this;
    }

    setDepthSmoothing(smoothing: Spline): this {
        this.depth_smoothing = smoothing;
        return this;
    }
}

/**
 * Region transition configuration for smooth terrain blending
 */
export interface RegionTransition {
    /** Width of the transition zone (in blocks) */
    width: number;
    /** Noise scale for jagged transition edges (optional) */
    noise_scale?: number;
    /** Noise amplitude for transition edge variation (optional) */
    noise_amplitude?: number;
}

/**
 * World - Top-level world configuration
 */
export class World {
    private id: string;
    private world_height: number = 1024;
    private spawn_interval: number = 14;
    private region_transition: RegionTransition = {
        width: 32,
        noise_scale: 0.05,
        noise_amplitude: 8,
    };

    private vignette?: WorldVignette;
    private time?: WorldTime;
    private celestials: WorldCelestial[] = [];
    private biome?: WorldBiome;
    private surface?: WorldSurface;
    private cave?: WorldCave;

    constructor(id: string) {
        this.id = id;
    }

    setWorldHeight(height: number): this {
        this.world_height = height;
        return this;
    }

    setSpawnInterval(interval: number): this {
        this.spawn_interval = interval;
        return this;
    }

    setRegionTransition(config: Partial<RegionTransition>): this {
        this.region_transition = {
            ...this.region_transition,
            ...config,
        };
        return this;
    }

    setVignette(vignette: WorldVignette): this {
        this.vignette = vignette;
        return this;
    }

    setTime(time: WorldTime): this {
        this.time = time;
        return this;
    }

    addCelestial(celestial: WorldCelestial): this {
        this.celestials.push(celestial);
        return this;
    }

    setBiome(biome: WorldBiome): this {
        this.biome = biome;
        return this;
    }

    setSurface(surface: WorldSurface): this {
        this.surface = surface;
        return this;
    }

    setCave(cave: WorldCave): this {
        this.cave = cave;
        return this;
    }

    getId(): string {
        return this.id;
    }
}
