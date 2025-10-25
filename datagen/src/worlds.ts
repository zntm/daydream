import { DatagenReturnData, Noise, SmartValue } from "../index";

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
    private time_start: number;
    private time_end: number;

    constructor(start: number, end: number) {
        this.time_start = start;
        this.time_end = end;
    }
}

export class WorldTime {
    private start: number;
    private diurnal: { [key: string]: WorldTimeDiurnal };

    constructor(start: number, diurnal: { [key: string]: WorldTimeDiurnal }) {
        this.start = start;
        this.diurnal = diurnal;
    }
}

export class WorldCelestial {
    private time_start: number;
    private time_end: number;

    constructor(timeStart: number, timeEnd: number) {
        this.time_start = timeStart;
        this.time_end = timeEnd;
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
    };

    private surface: {
        heat: Noise;
        humidity: Noise;
        offset: Noise;
    };

    constructor(
        defaultCaveBiomes: WorldCaveBiome[],
        caveNoise: Noise,
        caveOptions: any[] = [],
        surfaceHeat: Noise,
        surfaceHumidity: Noise,
        surfaceOffset: Noise,
    ) {
        this.cave = {
            default: defaultCaveBiomes,
            noise: caveNoise,
            options: caveOptions,
        };
        this.surface = {
            heat: surfaceHeat,
            humidity: surfaceHumidity,
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
    private celestial: { [key: string]: WorldCelestial };
    private biome: WorldBiome;
    private surface: WorldSurface;
    private cave: WorldCave;

    constructor(
        world_height: number,
        spawn_interval: number,
        vignette: WorldVignette,
        time: WorldTime,
        celestial: { [key: string]: WorldCelestial },
        biome: WorldBiome,
        surface: WorldSurface,
        cave: WorldCave,
    ) {
        this.world_height = world_height;
        this.spawn_interval = spawn_interval;
        this.vignette = vignette;
        this.time = time;
        this.celestial = celestial;
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
            new WorldTime(180, {
                dawn: new WorldTimeDiurnal(0, 240),
                day: new WorldTimeDiurnal(240, 820),
                dusk: new WorldTimeDiurnal(820, 890),
                night: new WorldTimeDiurnal(890, 1200),
            }),
            {
                sun: new WorldCelestial(0, 890),
                moon: new WorldCelestial(890, 1200),
            },
            new WorldBiome(
                [
                    new WorldCaveBiome("phantasia:depths", 768, 1024, {
                        type: WorldCaveBiomeTransitionType.Random,
                        ...new Noise(4, 2, 22),
                    }),
                    new WorldCaveBiome("phantasia:chasm", 0, 800, {
                        type: WorldCaveBiomeTransitionType.Random,
                        ...new Noise(0),
                    }),
                ],
                new Noise(4),
                [],
                new Noise(1),
                new Noise(1),
                new Noise(2, 22, 34),
            ),
            new WorldSurface(512, new Noise(4, 40, 96)),
            new WorldCave(new Noise(0, 12, 2), [
                new WorldCaveSystem(512, 1000, new Noise(4, 50, 60)),
                new WorldCaveSystem(600, 1000, new Noise(4, 116, 130)),
            ]),
        ),
    ),
];
