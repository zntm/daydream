import { Noise, Spline, type SmartValue } from "../../../lib";

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
        threshold: number = 256,
        spacing: number = 32,
        radius: number = 18,
        thickness: number = 10,
        noiseScaleRegion: number = 0.12,
        noiseScaleEdge: number = 0.15,
        noiseScaleDetail: number = 0.3,
        regionOffsetY: number = 1000,
        regionRange: number = 255,
        regionOctaves: number = 2,
        regionThreshold: number = 60,
        edgeNoiseAmplitude: number = 0.5,
        edgeNoiseOctaves: number = 3,
        detailNoiseAmplitude: number = 0.25,
        detailNoiseOctaves: number = 2
    ) {
        this.enabled = enabled;
        this.id = id;
        this.threshold = threshold;
        this.spacing = spacing;
        this.radius = radius;
        this.thickness = thickness;
        this.noise_scale_region = noiseScaleRegion;
        this.noise_scale_edge = noiseScaleEdge;
        this.noise_scale_detail = noiseScaleDetail;
        this.region_offset_y = regionOffsetY;
        this.region_range = regionRange;
        this.region_octaves = regionOctaves;
        this.region_threshold = regionThreshold;
        this.edge_noise_amplitude = edgeNoiseAmplitude;
        this.edge_noise_octaves = edgeNoiseOctaves;
        this.detail_noise_amplitude = detailNoiseAmplitude;
        this.detail_noise_octaves = detailNoiseOctaves;
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
        caveOptions: any[] = [],
        surfaceHeat: Noise,
        surfaceHumidity: Noise,
        surfaceMap: string,
        surfaceOffset: Noise,
        caveHeat?: Noise,
        caveHumidity?: Noise,
        caveMap?: string,
        sky?: WorldSky,
    ) {
        this.cave = {
            default: defaultCaveBiomes,
            noise: caveNoise,
            options: caveOptions,
            heat: caveHeat,
            humidity: caveHumidity,
            map: caveMap,
        };
        this.surface = {
            heat: surfaceHeat,
            humidity: surfaceHumidity,
            map: surfaceMap,
            offset: surfaceOffset,
        };
        this.sky = sky;
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
    private seed_offset?: number;
    private min_depth?: number;
    private bedrock_depth?: number;
    private bedrock_noise_scale?: number;
    private tile_variation_noise_scale?: number;
    private biome_blend_range?: number;
    private biome_blend_noise_scale?: number;

    constructor(
        start: number,
        noiseOffset: Noise,
        smoothing: WorldSurfaceSmoothing = new WorldSurfaceSmoothing(),
        noiseScale: number = 0.015625,
        seedOffset: number = -40,
        minDepth: number = 8,
        bedrockDepth: number = 3,
        bedrockNoiseScale: number = 0.3,
        tileVariationNoiseScale: number = 0.05,
        biomeBlendRange: number = 24,
        biomeBlendNoiseScale: number = 0.08
    ) {
        this.start = start;
        this.noise_offset = noiseOffset;
        this.smoothing = smoothing;
        this.noise_scale = noiseScale;
        this.seed_offset = seedOffset;
        this.min_depth = minDepth;
        this.bedrock_depth = bedrockDepth;
        this.bedrock_noise_scale = bedrockNoiseScale;
        this.tile_variation_noise_scale = tileVariationNoiseScale;
        this.biome_blend_range = biomeBlendRange;
        this.biome_blend_noise_scale = biomeBlendNoiseScale;
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
    private type: string;
    private depth_min: number;
    private depth_max: number;
    private threshold: number;
    private octaves: number;
    private fill_level: number;
    private noise_scale: number;
    private range?: number;

    constructor(
        type: string,
        depthMin: number,
        depthMax: number,
        threshold: number,
        octaves: number = 3,
        fillLevel: number = 8,
        noiseScale: number = 0.02,
        range: number = 255
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
    private breach_noise_scale_x?: number;
    private breach_noise_scale_y?: number;
    private breach_noise_offset_y?: number;
    private breach_noise_range?: number;
    private breach_noise_octaves?: number;
    private transition_noise_scale_x?: number;
    private transition_noise_scale_y?: number;
    private transition_noise_range?: number;
    private transition_noise_octaves?: number;

    constructor(
        start: Noise,
        system: WorldCaveSystem[],
        aquifers?: WorldAquifer[],
        depthSmoothing?: Spline,
        noiseScale: number = 0.015625,
        breachThreshold: number = 242,
        breachDepth: number = -8,
        transitionThreshold: number = 220,
        breachNoiseScaleX: number = 0.03,
        breachNoiseScaleY: number = 0.03,
        breachNoiseOffsetY: number = 1000,
        breachNoiseRange: number = 255,
        breachNoiseOctaves: number = 2,
        transitionNoiseScaleX: number = 0.02,
        transitionNoiseScaleY: number = 0.02,
        transitionNoiseRange: number = 255,
        transitionNoiseOctaves: number = 3
    ) {
        this.start = start;
        this.system = system;
        if (aquifers) this.aquifers = aquifers;
        if (depthSmoothing) this.depth_smoothing = depthSmoothing;
        this.noise_scale = noiseScale;
        this.breach_threshold = breachThreshold;
        this.breach_depth = breachDepth;
        this.transition_threshold = transitionThreshold;
        this.breach_noise_scale_x = breachNoiseScaleX;
        this.breach_noise_scale_y = breachNoiseScaleY;
        this.breach_noise_offset_y = breachNoiseOffsetY;
        this.breach_noise_range = breachNoiseRange;
        this.breach_noise_octaves = breachNoiseOctaves;
        this.transition_noise_scale_x = transitionNoiseScaleX;
        this.transition_noise_scale_y = transitionNoiseScaleY;
        this.transition_noise_range = transitionNoiseRange;
        this.transition_noise_octaves = transitionNoiseOctaves;
    }
}

export class World {
    private world_height: number;
    private spawn_interval: number;
    private vignette: WorldVignette;
    private time: WorldTime;
    private celestials: WorldCelestial[];
    private biome: WorldBiome;
    private surface: WorldSurface;
    private cave: WorldCave;
    private biome_transition_smoothing: number;
    private regions: string[];

    constructor(
        world_height: number,
        spawn_interval: number,
        vignette: WorldVignette,
        time: WorldTime,
        celestials: WorldCelestial[],
        biome: WorldBiome,
        surface: WorldSurface,
        cave: WorldCave,
        biomeTransitionSmoothing: number = 0.5,
        regions: string[] = [],
    ) {
        this.world_height = world_height;
        this.spawn_interval = spawn_interval;
        this.vignette = vignette;
        this.time = time;
        this.celestials = celestials;
        this.biome = biome;
        this.surface = surface;
        this.cave = cave;
        this.biome_transition_smoothing = biomeTransitionSmoothing;
        this.regions = regions;
    }
}
