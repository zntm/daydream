import {
    type SmartValue,
    type SmartValueValueType,
    Sound,
    ColorGradient,
} from "../../../lib";

export class Biome {
    private background: BiomeBackground;
    private map_colour?: string;
    private sky_colour: ColorGradient;
    private light_colour: ColorGradient;
    private tile: {
        [key: string]: BiomeTile;
    };
    private music?: Sound[];
    private creatures?: BiomeCreature[];
    private foliage?: BiomeFoliage[];
    private structures?: BiomeStructure[];
    private terrain_modifier?: BiomeTerrainModifier;
    private is_ocean?: boolean;
    private shore_tiles?: BiomeTile;
    private is_skyland?: boolean;
    private salt?: number;
    private sky_script?: string;

    constructor(
        background: BiomeBackground,
        mapColor: string | undefined,
        skyColor: ColorGradient,
        lightColor: ColorGradient,
        tile: {
            [key: string]: BiomeTile;
        },
    ) {
        this.background = background;
        if (mapColor) this.map_colour = mapColor;
        this.sky_colour = skyColor;
        this.light_colour = lightColor;
        this.tile = tile;
    }

    setMusic(music: Sound[]) {
        this.music = music;

        return this;
    }

    setCreatures(creature: BiomeCreature[]) {
        this.creatures = creature;

        return this;
    }

    setFoliage(foliage: BiomeFoliage[]) {
        this.foliage = foliage;

        return this;
    }

    setStructures(structure: BiomeStructure[]) {
        this.structures = structure;

        return this;
    }

    setTerrainModifier(modifier: BiomeTerrainModifier) {
        this.terrain_modifier = modifier;

        return this;
    }

    setIsOcean(value: boolean = true) {
        this.is_ocean = value;

        return this;
    }

    setShoreTiles(tiles: BiomeTile) {
        this.shore_tiles = tiles;

        return this;
    }

    setIsSkyland(value: boolean = true) {
        this.is_skyland = value;

        return this;
    }

    setSalt(salt: number) {
        this.salt = salt;

        return this;
    }

    setSkyScript(script: string) {
        this.sky_script = script;

        return this;
    }
}

export class BiomeTerrainModifier {
    private height_offset: number;
    private amplitude_scale?: number;

    constructor(heightOffset: number, amplitudeScale: number = 1.0) {
        this.height_offset = heightOffset;
        if (amplitudeScale !== 1.0) this.amplitude_scale = amplitudeScale;
    }
}

export class BiomeBackground {
    private id: string;
    private blend: number;

    constructor(id: string, blend: number) {
        this.id = id;
        this.blend = blend;
    }
}

export class TileEntry {
    private id: string | SmartValueValueType;
    private weight?: number;
    private noise_min?: number;
    private noise_max?: number;
    private context?: string[];

    constructor(
        id: string | SmartValueValueType,
        weight: number = 1,
        context?: string[],
    ) {
        this.id = id;
        if (weight !== 1) this.weight = weight;
        if (context) this.context = context;
    }

    setNoiseRange(min: number, max: number) {
        this.noise_min = min;
        this.noise_max = max;
        return this;
    }
}

export class BiomeTile {
    private base: TileEntry[];
    private wall: TileEntry[];

    constructor(base: string | TileEntry[], wall: string | TileEntry[]) {
        // Support both legacy string format and new array format
        this.base = typeof base === "string" ? [new TileEntry(base)] : base;
        this.wall = typeof wall === "string" ? [new TileEntry(wall)] : wall;
    }
}

export class BiomeCreature {
    private id: string;
    private variant?: string | SmartValue;
    private amount: number | SmartValue;
    private chance: number;
    private time_range_min?: number;
    private time_range_max?: number;
    private tile?: string | string[];

    constructor(id: string, amount: number | SmartValue, chance: number) {
        this.id = id;
        this.amount = amount;
        this.chance = chance;
    }

    setTile(tile: string | string[]) {
        this.tile = tile;

        return this;
    }

    setVariant(variant: string | SmartValue) {
        this.variant = variant;

        return this;
    }

    setTimeRange(min: number, max: number) {
        this.time_range_min = min;
        this.time_range_max = max;

        return this;
    }
}

export class BiomeFeature {
    private id: string | string[];
    private chance: number;
    private generate_on?: string | string[];
    private range_min?: number;
    private range_max?: number;

    constructor(id: string | string[], chance: number) {
        this.id = id;
        this.chance = chance;
    }

    setGenerateOn(placeableOn: string | string[]) {
        this.generate_on = placeableOn;

        return this;
    }

    setRange(range_min?: number, range_max?: number) {
        this.range_min = range_min;
        this.range_max = range_max;

        return this;
    }
}

export class BiomeFoliage extends BiomeFeature {}
export class BiomeStructure extends BiomeFeature {}
