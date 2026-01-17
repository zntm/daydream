import { DatagenReturnData, Noise, Spline, SplinePoint, SplineEasing, type SmartValue } from "../../index";

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

export class WorldBiomeTransitionRule {
    public require_any: string[]; // Pair must contain at least one of these (tag or ID)
    public require_all?: string[]; // Pair must contain ALL of these
    public exclude?: string[];     // Pair must NOT contain any of these
    public result: string;         // Resulting transition biome

    constructor(result: string, requireAny: string[], requireAll?: string[], exclude?: string[]) {
        this.result = result;
        this.require_any = requireAny;
        this.require_all = requireAll;
        this.exclude = exclude;
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
        transitions?: WorldBiomeTransitionRule[];
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
        surfaceTransitions?: WorldBiomeTransitionRule[]
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
            transitions: surfaceTransitions,
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
    private bedrock_depth?: number;
    private bedrock_noise_scale?: number;
    private tile_variation_noise_scale?: number;
    private biome_blend_range?: number;
    private biome_blend_noise_scale?: number;

    constructor(
        start: number, 
        bedrockDepth: number = 3,
        bedrockNoiseScale: number = 0.3,
        tileVariationNoiseScale: number = 0.05,
        biomeBlendRange: number = 24,
        biomeBlendNoiseScale: number = 0.08
    ) {
        this.start = start;
        this.bedrock_depth = bedrockDepth;
        this.bedrock_noise_scale = bedrockNoiseScale;
        this.tile_variation_noise_scale = tileVariationNoiseScale;
        this.biome_blend_range = biomeBlendRange;
        this.biome_blend_noise_scale = biomeBlendNoiseScale;
    }
}


export class WorldAquifer {
    private type: string;           // Liquid tile ID (e.g., "phantasia:water")
    private depth_min: number;      // Min depth from surface
    private depth_max: number;      // Max depth from surface
    private threshold: number;      // Noise threshold (0-255, higher = rarer)
    private octaves: number;        // Noise octaves
    private fill_level: number;     // Liquid fill level (1-8)
    private noise_scale: number;    // Noise scale
    private range?: number;         // Noise range (0-255)
    private edge_tile?: string;     // Solid tile for aquifer edges (e.g., "phantasia:stone")
    private edge_width?: number;    // Width of edge in noise units (default 10)

    constructor(
        type: string,
        depthMin: number,
        depthMax: number,
        threshold: number,
        octaves: number = 3,
        fillLevel: number = 8,
        noiseScale: number = 0.02,
        range: number = 255,
        edgeTile?: string,
        edgeWidth: number = 10
    ) {
        this.type = type;
        this.depth_min = depthMin;
        this.depth_max = depthMax;
        this.threshold = threshold;
        this.octaves = octaves;
        this.fill_level = fillLevel;
        this.noise_scale = noiseScale;
        this.range = range;
        if (edgeTile) this.edge_tile = edgeTile;
        if (edgeTile) this.edge_width = edgeWidth;
    }
}

export class WorldCave {
    private aquifers?: WorldAquifer[];

    constructor(
        aquifers?: WorldAquifer[]
    ) {
        if (aquifers) this.aquifers = aquifers;
    }
}

// ============================================================================
// WORLDGEN - New unified spline-based world generation config
// ============================================================================

export class WorldGen {
    // Surface shape
    private erosion_scale?: number;
    private continentalness_scale?: number;
    private continentalness_amplitude?: number;
    private squash_spline?: Spline;
    
    // Cave shape
    private cave_noise_scale?: number;
    private cave_noise_range_spline?: Spline;
    private cave_density_spline?: Spline;
    private cave_smoothness_spline?: Spline;

    constructor(opts: {
        erosionScale?: number;
        continentalnessScale?: number;
        continentalnessAmplitude?: number;
        squashSpline?: Spline;
        caveNoiseScale?: number;
        caveNoiseRangeSpline?: Spline;
        caveDensitySpline?: Spline;
        caveSmoothnessSpline?: Spline;
    } = {}) {
        if (opts.erosionScale !== undefined) this.erosion_scale = opts.erosionScale;
        if (opts.continentalnessScale !== undefined) this.continentalness_scale = opts.continentalnessScale;
        if (opts.continentalnessAmplitude !== undefined) this.continentalness_amplitude = opts.continentalnessAmplitude;
        if (opts.squashSpline !== undefined) this.squash_spline = opts.squashSpline;
        if (opts.caveNoiseScale !== undefined) this.cave_noise_scale = opts.caveNoiseScale;
        if (opts.caveNoiseRangeSpline !== undefined) this.cave_noise_range_spline = opts.caveNoiseRangeSpline;
        if (opts.caveDensitySpline !== undefined) this.cave_density_spline = opts.caveDensitySpline;
        if (opts.caveSmoothnessSpline !== undefined) this.cave_smoothness_spline = opts.caveSmoothnessSpline;
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
    private worldgen?: WorldGen;

    constructor(
        world_height: number,
        spawn_interval: number,
        vignette: WorldVignette,
        time: WorldTime,
        celestials: WorldCelestial[],
        biome: WorldBiome,
        surface: WorldSurface,
        cave: WorldCave,
        worldgen?: WorldGen,
    ) {
        this.world_height = world_height;
        this.spawn_interval = spawn_interval;
        this.vignette = vignette;
        this.time = time;
        this.celestials = celestials;
        this.biome = biome;
        this.surface = surface;
        this.cave = cave;
        if (worldgen) this.worldgen = worldgen;
    }
}

export default [
    new DatagenReturnData(
        "generated/data/worlds/playground.json",
        new World(
            1024,
            14,
            new WorldVignette(768, 1024, "#000000"),
            new WorldTime(240, [
                new WorldTimeDiurnal("dawn", 0, 240),
                new WorldTimeDiurnal("day", 240, 820),
                new WorldTimeDiurnal("dusk", 820, 890),
                new WorldTimeDiurnal("night", 890, 1200),
            ], 1200),
            [
                new WorldCelestial(
                    "phantasia:world/playground/celestial/sun",
                    0,
                    890,
                ),
                new WorldCelestial(
                    "phantasia:world/playground/celestial/moon",
                    890,
                    1200,
                ),
            ],
            new WorldBiome(
                [
                    new WorldCaveBiome("phantasia:cave/depths", 768, 1024, {
                        type: WorldCaveBiomeTransitionType.Random,
                        ...new Noise(4, 2, 22),
                    }),
                    new WorldCaveBiome("phantasia:cave/chasm", 0, 800, {
                        type: WorldCaveBiomeTransitionType.Random,
                        ...new Noise(0, 2, 22),
                    }),
                ],
                new Noise(4).setScale(0.005).setSplineY(new Spline([
                    new SplinePoint(0, -1, SplineEasing.Linear),
                    new SplinePoint(1024, 1, SplineEasing.Linear),
                ])),
                [],
                new Noise(4.5).setScale(0.005).setSplineX(new Spline([
                    new SplinePoint(0, -1, SplineEasing.Linear),
                    new SplinePoint(1024, 1, SplineEasing.Linear),
                ])),
                new Noise(2.75).setScale(0.005),
                "phantasia:world/playground/map",
                new Noise(2, 22, 34),
                // Use surface logic for caves for now (placeholder values)
                new Noise(4.5),
                new Noise(2.75),
                undefined, // caveMap removed
                new WorldSky(), // Default sky configuration
                [
                    // Rule: Water + Lush/Sand -> Beach
                    new WorldBiomeTransitionRule(
                        "phantasia:surface/beach",
                        ["water"], // Must have water
                        undefined,
                        undefined // No exclusions
                    ),
                    
                    // Rule: Sand + Lush -> Savanna
                    new WorldBiomeTransitionRule(
                        "phantasia:surface/savanna",
                        ["sand"], 
                        ["lush"] // Must have sand AND lush (one has sand, other has lush)
                    ),

                     // Rule: Snow + Forest -> Taiga (Transition zone)
                    new WorldBiomeTransitionRule(
                         "phantasia:surface/taiga",
                         ["snow"],
                         ["forest"]
                    )
                ]
            ),
            new WorldSurface(512),
            new WorldCave([
                // Water aquifers: shallow caves (20-200 blocks below surface)
                new WorldAquifer("phantasia:water", 20, 200, 200, 3, 8, 0.02, 255, "phantasia:stone", 15),
                // Lava aquifers: deep caves (350-450 blocks below surface)
                new WorldAquifer("phantasia:lava", 350, 450, 220, 2, 8, 0.02, 255, "phantasia:stone", 12),
            ]),
            // NEW: WorldGen spline-based configuration
            new WorldGen({
                // Surface shape
                erosionScale: 0.008,
                continentalnessScale: 0.0012,
                continentalnessAmplitude: 180,
                squashSpline: new Spline([
                    new SplinePoint(0, 8.0, SplineEasing.EaseOut),      // Near surface: very flat overhangs
                    new SplinePoint(150, 4.0, SplineEasing.EaseInOut),  // Shallow: moderately flat
                    new SplinePoint(400, 1.0),                          // Deep: normal caves
                ]),
                // Cave shape
                caveNoiseScale: 0.016,
                caveNoiseRangeSpline: new Spline([
                    new SplinePoint(0, 0.1, SplineEasing.EaseOut),      // Surface: tiny pockets
                    new SplinePoint(100, 0.25, SplineEasing.EaseInOut), // Shallow: small caves
                    new SplinePoint(300, 0.45),                         // Mid: medium caves
                    new SplinePoint(600, 0.55),                         // Deep: large Swiss-cheese caves
                ]),
                caveDensitySpline: new Spline([
                    new SplinePoint(0, 0.15, SplineEasing.EaseOut),     // Surface: mostly solid
                    new SplinePoint(200, 0.35, SplineEasing.EaseInOut), // Mid: balanced
                    new SplinePoint(600, 0.6),                          // Deep: more porous
                ]),
                caveSmoothnessSpline: new Spline([
                    new SplinePoint(0, 2.0, SplineEasing.Linear),       // Surface: jagged edges
                    new SplinePoint(400, 4.0),                          // Deep: smooth tunnel surfaces
                ]),
            }),
        ),
    ),
];
