import { ColorGradient } from "../../../lib/ColorGradient";
import { DatagenReturnData } from "../../../lib";

/**
 * Cave biome rule for depth-based or noise-based cave biome selection
 */
export class CaveBiomeRule {
    biome: string;
    min_depth?: number;
    max_depth?: number;
    noise_threshold?: number;
    noise_scale?: number;
    weight?: number;
    z_layer?: number;

    constructor(biome: string) {
        this.biome = biome;
    }

    setDepthRange(min: number, max?: number): CaveBiomeRule {
        this.min_depth = min;
        if (max !== undefined) this.max_depth = max;
        return this;
    }

    setNoiseThreshold(threshold: number, scale?: number): CaveBiomeRule {
        this.noise_threshold = threshold;
        if (scale !== undefined) this.noise_scale = scale;
        return this;
    }

    setWeight(weight: number): CaveBiomeRule {
        this.weight = weight;
        return this;
    }

    setZLayer(layer: number): CaveBiomeRule {
        this.z_layer = layer;
        return this;
    }
}

/**
 * Region - A collection of biomes with shared terrain and visual properties
 * Regions are large areas determined by Voronoi-like noise based on heat/humidity
 */
export class Region {
    private id: string;
    private biomes: string[] = [];
    private biome_noise_scale: number = 0.008;

    // Terrain properties
    private height_offset: number = 0;
    private base_height: number = 400;
    private amplitude_min: number = 30;
    private amplitude_max: number = 60;
    private terrain_noise_scale: number = 0.015625;
    private gradient_strength: number = 0.015;

    // Visual properties
    private sky_base: ColorGradient = new ColorGradient();
    private sky_gradient: ColorGradient = new ColorGradient();
    private light_colour: ColorGradient = new ColorGradient();
    private fog_color?: string;
    private fog_density?: number;

    private cave_biomes: CaveBiomeRule[] = [];
    private cave_biome_default: string = "phantasia:cave/chasm";
    private voronoi?: {
        cell_size: number;
        jitter: number;
    };

    constructor(id: string) {
        this.id = id;
    }

    setBiomes(biomes: string[]): Region {
        this.biomes = biomes;
        return this;
    }

    addBiome(biome: string): Region {
        this.biomes.push(biome);
        return this;
    }

    setBiomeNoiseScale(scale: number): Region {
        this.biome_noise_scale = scale;
        return this;
    }

    setTerrain(config: {
        height_offset?: number;
        base_height?: number;
        amplitude_min?: number;
        amplitude_max?: number;
        noise_scale?: number;
        gradient_strength?: number;
    }): Region {
        if (config.height_offset !== undefined) this.height_offset = config.height_offset;
        if (config.base_height !== undefined) this.base_height = config.base_height;
        if (config.amplitude_min !== undefined) this.amplitude_min = config.amplitude_min;
        if (config.amplitude_max !== undefined) this.amplitude_max = config.amplitude_max;
        if (config.noise_scale !== undefined) this.terrain_noise_scale = config.noise_scale;
        if (config.gradient_strength !== undefined) this.gradient_strength = config.gradient_strength;
        return this;
    }

    setSkyBaseColorGradient(gradient: ColorGradient): Region {
        this.sky_base = gradient;
        return this;
    }

    setSkyGradientColorGradient(gradient: ColorGradient): Region {
        this.sky_gradient = gradient;
        return this;
    }

    setLightColorGradient(gradient: ColorGradient): Region {
        this.light_colour = gradient;
        return this;
    }

    setFog(color: string, density: number): Region {
        this.fog_color = color;
        this.fog_density = density;
        return this;
    }

    addCaveBiome(rule: CaveBiomeRule): Region {
        this.cave_biomes.push(rule);
        return this;
    }

    setCaveDefault(biomeId: string): Region {
        this.cave_biome_default = biomeId;
        return this;
    }

    setVoronoi(cellSize: number, jitter: number): Region {
        this.voronoi = {
            cell_size: cellSize,
            jitter: jitter,
        };
        return this;
    }

    getId(): string {
        return this.id;
    }

    toJSON(): any {
        const data: any = {
            id: this.id,
            biomes: this.biomes,
            biome_noise_scale: this.biome_noise_scale,
            terrain: {
                height_offset: this.height_offset,
                base_height: this.base_height,
                amplitude_min: this.amplitude_min,
                amplitude_max: this.amplitude_max,
                noise_scale: this.terrain_noise_scale,
                gradient_strength: this.gradient_strength,
            },
            visuals: {
                sky_base: this.sky_base,
                sky_gradient: this.sky_gradient,
                light_colour: this.light_colour,
            },
            cave_biome_default: this.cave_biome_default,
            cave_biomes: this.cave_biomes,
        };

        if (this.fog_color) {
            data.visuals.fog_color = this.fog_color;
            data.visuals.fog_density = this.fog_density;
        }

        if (this.voronoi) {
            data.voronoi = this.voronoi;
        }

        return data;
    }
}
