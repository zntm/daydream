import { type SmartValue, Sound } from "../../index";
import { join } from "path";
import { readdirSync } from "fs";

export class Biome {
    private background: BiomeBackground;
    private map_colour: string;
    private sky_colour: any;
    private light_colour: any;
    private tile: {
        [key: string]: MaterialProvider;
    };
    private music?: Sound[];
    private creatures?: BiomeCreature[];
    private foliage?: BiomeFoliage[];
    private structures?: BiomeStructure[];
    private terrain_modifier?: BiomeTerrainModifier;
    private is_ocean?: boolean;
    private shore_tiles?: MaterialProvider;
    private is_skyland?: boolean;
    private salt?: number;
    private tags?: string[];

    constructor(
        background: BiomeBackground,
        mapColor: string,
        skyColor: any,
        lightColor: any,
        tile: {
            [key: string]: MaterialProvider;
        },
    ) {
        this.background = background;
        this.map_colour = mapColor;
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

    setShoreTiles(tiles: MaterialProvider) {
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

    setTags(tags: string[]) {
        this.tags = tags;
        return this;
    }
}

export class BiomeTerrainModifier {
    // Legacy height offset
    private height_offset: number;
    
    // NEW: Biome blending control
    private influence?: number;    // How much these modifiers affect generation (0-1)
    private smoothing?: number;    // Blend radius in blocks for smooth biome edges
    
    // NEW: WorldGen modifiers (multipliers that blend at biome edges)
    private erosion_modifier?: number;       // Multiplier for erosion (flatness)
    private squash_modifier?: number;        // Multiplier for squash factor
    private cave_density_modifier?: number;  // Multiplier for cave density
    private continentalness_modifier?: number; // Modifier for continentalness

    constructor(
        heightOffset: number
    ) {
        this.height_offset = heightOffset;
    }
    
    /** Set how much this biome's modifiers affect worldgen (0-1) */
    setInfluence(influence: number) {
        this.influence = influence;
        return this;
    }
    
    /** Set blend radius for smooth biome edge transitions (in blocks) */
    setSmoothing(smoothing: number) {
        this.smoothing = smoothing;
        return this;
    }
    
    /** Set erosion modifier (1.0 = normal, <1 = more mountainous, >1 = flatter) */
    setErosionModifier(modifier: number) {
        this.erosion_modifier = modifier;
        return this;
    }
    
    /** Set squash modifier (1.0 = normal, <1 = less squash, >1 = more squash) */
    setSquashModifier(modifier: number) {
        this.squash_modifier = modifier;
        return this;
    }
    
    /** Set cave density modifier (1.0 = normal, <1 = fewer caves, >1 = more caves) */
    setCaveDensityModifier(modifier: number) {
        this.cave_density_modifier = modifier;
        return this;
    }
    
    /** Set continentalness modifier (additive offset to base continentalness) */
    setContinentalnessModifier(modifier: number) {
        this.continentalness_modifier = modifier;
        return this;
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

export class BiomeSkyColor {
    private base: string;
    private gradient: string;

    constructor(base: string, gradient: string) {
        this.base = /\#[0-9a-fA-F]{6}/.test(base) ? base.toUpperCase() : base;
        this.gradient = /\#[0-9a-fA-F]{6}/.test(gradient)
            ? gradient.toUpperCase()
            : gradient;
    }
}

export class MaterialRule {
    private type: string;
    private params: any;

    constructor(type: string, params: any = {}) {
        this.type = type;
        this.params = params;
    }
}

export class RuleDepth extends MaterialRule {
    constructor(min: number, max: number) {
        super("RuleDepth", { min, max });
    }
}

export class RuleAirAbove extends MaterialRule {
    constructor(min_blocks: number) {
        super("RuleAirAbove", { min_blocks });
    }
}

export class RuleCaveBiome extends MaterialRule {
    constructor(biome_id: string) {
        super("RuleCaveBiome", { biome_id });
    }
}

export class RuleSolidAbove extends MaterialRule {
    constructor(max_blocks: number) {
        super("RuleSolidAbove", { max_blocks });
    }
}

export class RuleAdjacent extends MaterialRule {
    constructor(tile_id: string | string[]) {
        super("RuleAdjacent", { tile_id: Array.isArray(tile_id) ? tile_id : [tile_id] });
    }
}

export class RuleNotAdjacent extends MaterialRule {
    constructor(tile_id: string | string[]) {
        super("RuleNotAdjacent", { tile_id: Array.isArray(tile_id) ? tile_id : [tile_id] });
    }
}

export class MaterialItem {
    id: string;
    rules: MaterialRule[];
    noise_min?: number;
    noise_max?: number;

    constructor(id: string, rules: MaterialRule[] = []) {
        this.id = id;
        this.rules = rules;
    }

    setNoiseRange(min: number, max: number) {
        this.noise_min = min;
        this.noise_max = max;
        return this;
    }
}

export class MaterialProvider {
    items: MaterialItem[];
    default_id?: string;

    constructor() {
        this.items = [];
    }

    addItem(id: string, rules: MaterialRule[] = []) {
        this.items.push(new MaterialItem(id, rules));
        return this;
    }

    addItemNoise(id: string, min: number, max: number, rules: MaterialRule[] = []) {
        const item = new MaterialItem(id, rules);
        item.setNoiseRange(min, max);
        this.items.push(item);
        return this;
    }

    setDefault(id: string) {
        this.default_id = id;
        return this;
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

export default readdirSync(join(__dirname, "./biomes"))
    .map((type) => import.meta.require(`./biomes/${type}`).default)
    .filter((biome) => biome)
    .flat();
