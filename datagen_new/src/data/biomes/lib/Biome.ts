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

    setNoiseRange(min: number, max?: number): BiomeTileEntry {
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
        bottom: BiomeTileLayer
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

    constructor(id: string, chance: number, generateOn: string = "#phantasia:tile/placement/plant_on") {
        this.id = id;
        this.chance = chance;
        this.generate_on = generateOn;
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

    constructor(id: string, amount: SmartValueValueType | number, chance: number) {
        this.id = id;
        this.amount = amount;
        this.chance = chance;
    }

    setTimeRange(min: number, max: number): BiomeCreature {
        this.time_range_min = min;
        this.time_range_max = max;
        return this;
    }

    setTile(tile: string): BiomeCreature {
        this.tile = tile;
        return this;
    }

    setVariant(variant: SmartValueValueType): BiomeCreature {
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

    constructor(id: string, chance: number, generateOn: string = "#phantasia:tile/placement/plant_on") {
        this.id = id;
        this.chance = chance;
        this.generate_on = generateOn;
    }
}

/**
 * Music entry
 */
export class BiomeMusic {
    id: string;
    gain: number;

    constructor(id: string, gain: number = 0.7) {
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
    private terrain_modifier?: { height_offset?: number; amplitude_scale?: number };

    constructor(id: string) {
        this.id = id;
    }

    setBackground(id: string, blend: number = 0.7): Biome {
        this.background = { id, blend };
        return this;
    }

    setTile(tile: BiomeTile): Biome {
        this.tile = tile;
        return this;
    }

    addFoliage(foliage: BiomeFoliage): Biome {
        this.foliage.push(foliage);
        return this;
    }

    addCreature(creature: BiomeCreature): Biome {
        this.creatures.push(creature);
        return this;
    }

    addStructure(structure: BiomeStructure): Biome {
        this.structures.push(structure);
        return this;
    }

    addMusic(music: BiomeMusic): Biome {
        this.music.push(music);
        return this;
    }

    setShoreTiles(layer: BiomeTileLayer): Biome {
        this.shore_tiles = layer;
        return this;
    }

    setTerrainModifier(heightOffset?: number, amplitudeScale?: number): Biome {
        this.terrain_modifier = {};
        if (heightOffset !== undefined) this.terrain_modifier.height_offset = heightOffset;
        if (amplitudeScale !== undefined) this.terrain_modifier.amplitude_scale = amplitudeScale;
        return this;
    }

    /**
     * Build the biome into a DatagenReturnData for export
     */
    build(category: string = "surface"): DatagenReturnData {
        const data: any = {};

        if (this.background) {
            data.background = this.background;
        }

        if (this.tile) {
            data.tile = this.tile;
        }

        if (this.foliage.length > 0) {
            data.foliage = this.foliage;
        }

        if (this.creatures.length > 0) {
            data.creatures = this.creatures;
        }

        if (this.structures.length > 0) {
            data.structures = this.structures;
        }

        if (this.music.length > 0) {
            data.music = this.music;
        }

        if (this.shore_tiles) {
            data.shore_tiles = this.shore_tiles;
        }

        if (this.terrain_modifier) {
            data.terrain_modifier = this.terrain_modifier;
        }

        // Extract biome name from ID (e.g., "phantasia:surface/greenia" -> "greenia")
        const biomeName = this.id.split("/").pop() || this.id;

        return new DatagenReturnData(
            `${category}/${biomeName}.json`,
            data
        );
    }
}
