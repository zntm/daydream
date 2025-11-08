import { SmartValue, Sound } from "../index";
import { join } from "path";
import { readdirSync } from "fs";

export class Biome {
    private background: BiomeBackground;
    private map_colour: string;
    private sky_colour: any;
    private light_colour: any;
    private tile: {
        [key: string]: BiomeTile;
    };
    private music?: Sound[];
    private creatures?: BiomeCreature[];
    private foliage?: BiomeFoliage[];
    private structures?: BiomeStructure[];

    constructor(
        background: BiomeBackground,
        mapColor: string,
        skyColor: any,
        lightColor: any,
        tile: {
            [key: string]: BiomeTile;
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
        this.base = base.toUpperCase();
        this.gradient = gradient.toUpperCase();
    }
}

export class BiomeTile {
    private base: {
        id: string;
    };

    private wall: {
        id: string;
    };

    constructor(base: string, id: string) {
        this.base = {
            id: base,
        };
        this.wall = {
            id: id,
        };
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
    private id: string;
    private chance: number;
    private generate_on?: string | string[];
    private range_min?: number;
    private range_max?: number;

    constructor(id: string, chance: number) {
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
