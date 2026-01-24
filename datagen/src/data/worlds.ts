import { DatagenReturnData, Noise, type SmartValue } from "../../index";

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
    }
}

export class WorldSurface {
    private start: number;
    private noise_offset: Noise;

    constructor(start: number, noiseOffset: Noise) {
        this.start = start;
        this.noise_offset = noiseOffset;
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

export class WorldCave {
    start: Noise;
    system: WorldCaveSystem[];

    constructor(start: Noise, system: WorldCaveSystem[]) {
        this.start = start;
        this.system = system;
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

    constructor(
        world_height: number,
        spawn_interval: number,
        vignette: WorldVignette,
        time: WorldTime,
        celestials: WorldCelestial[],
        biome: WorldBiome,
        surface: WorldSurface,
        cave: WorldCave,
    ) {
        this.world_height = world_height;
        this.spawn_interval = spawn_interval;
        this.vignette = vignette;
        this.time = time;
        this.celestials = celestials;
        this.biome = biome;
        this.surface = surface;
        this.cave = cave;
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
            // BIOME DATA (Simplified)
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
                new Noise(4),
                [],
                new Noise(4.5), // Heat
                new Noise(2.75), // Humidity
                "phantasia:world/playground/map",
                new Noise(2, 22, 34), // Surface Offset
                new Noise(4.5),
                new Noise(2.75),
                "phantasia:world/playground/map",
            ),
            // SURFACE DATA (Simplified Heightmap)
            // Start at y=400, noise range 40-120
           new WorldSurface(400, new Noise(4, 40, 120)),
            // CAVE DATA (Simplified)
            new WorldCave(new Noise(0, 12, 2), [
                // Upper caves
                new WorldCaveSystem(420, 1000, new Noise(3, 45, 55)),
                // Deep caves
                new WorldCaveSystem(600, 1000, new Noise(4, 50, 60)),
            ]),
        ),
    ),
];
