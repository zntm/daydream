import { DatagenReturnData } from "../../../lib";
import { SmartValue, type SmartValueValueType } from "../../../lib/SmartValue";

/**
 * Tile entry with optional weight and noise range
 */
export class BiomeTileEntry {
    id: string;
    weight?: number;
    noise_min?: number;
    noise_max?: number;

    constructor(id: string, weight?: number) {
        this.id = id;
        if (weight !== undefined) this.weight = weight;
    }

    setNoiseRange(min: number, max?: number): this {
        this.noise_min = min;
        if (max !== undefined) this.noise_max = max;
        return this;
    }
}

/**
 * Tile layer (base + wall tiles)
 */
export class BiomeTileLayer {
    base: BiomeTileEntry[];
    wall: BiomeTileEntry[];

    constructor(base: BiomeTileEntry[], wall: BiomeTileEntry[]) {
        this.base = base;
        this.wall = wall;
    }
}

/**
 * Full tile configuration for a biome
 */
export class BiomeTile {
    top_layer: BiomeTileLayer;
    middle_layer: BiomeTileLayer;
    bottom_layer: BiomeTileLayer;

    constructor(
        top: BiomeTileLayer,
        middle: BiomeTileLayer,
        bottom: BiomeTileLayer,
    ) {
        this.top_layer = top;
        this.middle_layer = middle;
        this.bottom_layer = bottom;
    }
}

/**
 * Foliage entry for surface decoration
 */
export class BiomeFoliage {
    id: string;
    chance: number;
    generate_on: string;
    range_min?: number;
    range_max?: number;

    constructor(
        id: string,
        chance: number,
        generateOn = "#phantasia:tile/placement/plant_on",
    ) {
        this.id = id;
        this.chance = chance;
        this.generate_on = generateOn;
    }

    setRange(min: number, max: number): this {
        this.range_min = min;
        this.range_max = max;
        return this;
    }
}

/**
 * Creature spawn entry
 */
export class BiomeCreature {
    id: string;
    amount: SmartValueValueType | number;
    chance: number;
    time_range_min?: number;
    time_range_max?: number;
    tile?: string;
    variant?: SmartValueValueType;

    constructor(
        id: string,
        amount: SmartValueValueType | number,
        chance: number,
    ) {
        this.id = id;
        this.amount = amount;
        this.chance = chance;
    }

    setTimeRange(min: number, max: number): this {
        this.time_range_min = min;
        this.time_range_max = max;
        return this;
    }

    setTile(tile: string): this {
        this.tile = tile;
        return this;
    }

    setVariant(variant: SmartValueValueType): this {
        this.variant = variant;
        return this;
    }
}

/**
 * Structure generation entry
 */
export class BiomeStructure {
    id: string;
    chance: number;
    generate_on: string;
    range_min?: number;
    range_max?: number;

    constructor(
        id: string,
        chance: number,
        generateOn = "#phantasia:tile/placement/plant_on",
    ) {
        this.id = id;
        this.chance = chance;
        this.generate_on = generateOn;
    }

    setRange(min: number, max: number): this {
        this.range_min = min;
        this.range_max = max;
        return this;
    }
}

/**
 * Music entry
 */
export class BiomeMusic {
    id: string;
    gain: number;

    constructor(id: string, gain = 0.7) {
        this.id = id;
        this.gain = gain;
    }
}

/**
 * Biome - Contains tile, foliage, creature, structure data
 * Note: Color properties (sky_colour, light_colour, map_colour) moved to Region
 */
export class Biome {
    private id: string;
    private background?: { id: string; blend: number };
    private tile?: BiomeTile;
    private foliage: BiomeFoliage[] = [];
    private creatures: BiomeCreature[] = [];
    private structures: BiomeStructure[] = [];
    private music: BiomeMusic[] = [];
    private shore_tiles?: BiomeTileLayer;
    private terrain_modifier?: {
        height_offset?: number;
        amplitude_scale?: number;
    };
    private is_ocean?: boolean;
    private is_skyland?: boolean;

    constructor(id: string) {
        this.id = id;
    }

    setBackground(id: string, blend = 0.7): this {
        this.background = { id, blend };
        return this;
    }

    setTile(tile: BiomeTile): this {
        this.tile = tile;
        return this;
    }

    addFoliage(foliage: BiomeFoliage): this {
        this.foliage.push(foliage);
        return this;
    }

    addCreature(creature: BiomeCreature): this {
        this.creatures.push(creature);
        return this;
    }

    addStructure(structure: BiomeStructure): this {
        this.structures.push(structure);
        return this;
    }

    addMusic(music: BiomeMusic): this {
        this.music.push(music);
        return this;
    }

    setShoreTiles(layer: BiomeTileLayer): this {
        this.shore_tiles = layer;
        return this;
    }

    setTerrainModifier(heightOffset?: number, amplitudeScale?: number): this {
        this.terrain_modifier = {};
        if (heightOffset !== undefined)
            this.terrain_modifier.height_offset = heightOffset;
        if (amplitudeScale !== undefined)
            this.terrain_modifier.amplitude_scale = amplitudeScale;
        return this;
    }

    setIsOcean(value = true): this {
        this.is_ocean = value;
        return this;
    }

    setIsSkyland(value = true): this {
        this.is_skyland = value;
        return this;
    }

    /**
     * Build the biome into a DatagenReturnData for export.
     * Only includes fields that have values - no empty arrays or undefined.
     */
    build(category = "surface"): DatagenReturnData {
        const data: Record<string, unknown> = {};

        // Helper to conditionally add non-empty arrays
        const addIfNotEmpty = (key: string, arr: unknown[]) => {
            if (arr.length) data[key] = arr;
        };

        // Helper to conditionally add truthy values
        const addIfPresent = (key: string, val: unknown) => {
            if (val !== undefined) data[key] = val;
        };

        addIfPresent("background", this.background);
        addIfPresent("tile", this.tile);
        addIfNotEmpty("foliage", this.foliage);
        addIfNotEmpty("creatures", this.creatures);
        addIfNotEmpty("structures", this.structures);
        addIfNotEmpty("music", this.music);
        addIfPresent("shore_tiles", this.shore_tiles);
        addIfPresent("terrain_modifier", this.terrain_modifier);
        addIfPresent("is_ocean", this.is_ocean);
        addIfPresent("is_skyland", this.is_skyland);

        const biomeName = this.id.split("/").pop() || this.id;
        return new DatagenReturnData(`${category}/${biomeName}.json`, data);
    }
}
