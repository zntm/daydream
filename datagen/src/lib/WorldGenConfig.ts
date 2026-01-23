/**
 * WorldGenConfig - Simplified world generation configuration
 * Replaces the verbose World/WorldCave/WorldSurface structure with a cleaner API.
 */

import { Spline, SplinePoint, SplineEasing } from "../lib/Spline";

// ============================================================================
// SURFACE SHAPE
// ============================================================================

export class SurfaceShape {
    /** Base height of the surface (in tiles) */
    base_height: number;

    /** Peaks/Valleys: local height variation */
    peaks_scale: number;
    peaks_amplitude: number;

    /** Squashing spline: how much caves are flattened at different depths */
    squash_spline: Spline;

    constructor(
        baseHeight: number = 400,
        opts: {
            peaksScale?: number;
            peaksAmplitude?: number;
            squashSpline?: Spline;
        } = {},
    ) {
        this.base_height = baseHeight;
        this.peaks_scale = opts.peaksScale ?? 0.04;
        this.peaks_amplitude = opts.peaksAmplitude ?? 100;
        this.squash_spline =
            opts.squashSpline ??
            new Spline([
                new SplinePoint(0, 8.0, SplineEasing.EaseOut),
                new SplinePoint(200, 4.0, SplineEasing.EaseInOut),
                new SplinePoint(600, 1.0),
            ]);
    }
}

// ============================================================================
// CAVE SHAPE
// ============================================================================

export class CaveShape {
    /** 3D noise scale for cave generation */
    noise_scale: number;

    /** Density threshold for solid/air boundary */
    threshold: number;

    /** Z-offset for wall extension (creates overhangs) */
    z_offset_wall: number;
    z_range_wall: number;

    /** Z-offset for material variation */
    z_offset_material: number;

    /** Noise range spline: what noise values carve out caves (varies by depth) */
    noise_range_spline: Spline;

    /** Density spline: solid/air ratio at different depths */
    density_spline: Spline;

    /** Smoothness spline: how smooth cave edges are */
    smoothness_spline: Spline;

    constructor(
        opts: {
            noiseScale?: number;
            threshold?: number;
            zOffsetWall?: number;
            zRangeWall?: number;
            zOffsetMaterial?: number;
            noiseRangeSpline?: Spline;
            densitySpline?: Spline;
            smoothnessSpline?: Spline;
        } = {},
    ) {
        this.noise_scale = opts.noiseScale ?? 0.015;
        this.threshold = opts.threshold ?? 0.0;
        this.z_offset_wall = opts.zOffsetWall ?? 0.075;
        this.z_range_wall = opts.zRangeWall ?? 0.05;
        this.z_offset_material = opts.zOffsetMaterial ?? 0.5;

        this.noise_range_spline =
            opts.noiseRangeSpline ??
            new Spline([
                new SplinePoint(0, 0.1, SplineEasing.EaseOut),
                new SplinePoint(100, 0.3, SplineEasing.EaseInOut),
                new SplinePoint(400, 0.5),
            ]);

        this.density_spline =
            opts.densitySpline ??
            new Spline([
                new SplinePoint(0, 0.2, SplineEasing.EaseOut),
                new SplinePoint(200, 0.4, SplineEasing.EaseInOut),
                new SplinePoint(600, 0.6),
            ]);

        this.smoothness_spline =
            opts.smoothnessSpline ??
            new Spline([
                new SplinePoint(0, 2, SplineEasing.Linear),
                new SplinePoint(400, 4),
            ]);
    }
}

// ============================================================================
// PLACEMENT RULES (for complex tile placement conditions)
// ============================================================================

export type PlacementRuleType =
    | "depth_range" // min/max depth from surface
    | "air_above" // requires N blocks of air above
    | "solid_above" // requires NO solid blocks within N blocks above
    | "cave_biome" // specific cave biome required
    | "noise_range" // noise value must be in range
    | "adjacent" // requires adjacent tile of type
    | "not_adjacent"; // requires NO adjacent tile of type

export class PlacementRule {
    type: PlacementRuleType;
    params: Record<string, any>;

    constructor(type: PlacementRuleType, params: Record<string, any> = {}) {
        this.type = type;
        this.params = params;
    }
}

/** Tile only places if depth from surface is within range */
export class RuleDepthRange extends PlacementRule {
    constructor(min: number, max: number) {
        super("depth_range", { min, max });
    }
}

/** Tile only places if there are at least N blocks of air above */
export class RuleAirAbove extends PlacementRule {
    constructor(minBlocks: number) {
        super("air_above", { min_blocks: minBlocks });
    }
}

/** Tile only places if there are NO solid blocks within N blocks above */
export class RuleSolidAbove extends PlacementRule {
    constructor(maxBlocks: number) {
        super("solid_above", { max_blocks: maxBlocks });
    }
}

/** Tile only places if noise value is within range */
export class RuleNoiseRange extends PlacementRule {
    constructor(min: number, max: number) {
        super("noise_range", { min, max });
    }
}

/** Tile only places in specific cave biome */
export class RuleCaveBiome extends PlacementRule {
    constructor(biomeId: string) {
        super("cave_biome", { biome_id: biomeId });
    }
}

/** Tile only places if there's an adjacent tile of specified type */
export class RuleAdjacent extends PlacementRule {
    constructor(tileId: string | string[]) {
        super("adjacent", {
            tile_id: Array.isArray(tileId) ? tileId : [tileId],
        });
    }
}

/** Tile only places if there's NO adjacent tile of specified type */
export class RuleNotAdjacent extends PlacementRule {
    constructor(tileId: string | string[]) {
        super("not_adjacent", {
            tile_id: Array.isArray(tileId) ? tileId : [tileId],
        });
    }
}

// ============================================================================
// BIOME MODIFIERS
// ============================================================================

export class BiomeModifier {
    /** How much this biome influences the base parameters (0-1) */
    influence: number;

    /** How smooth the biome edges are */
    smoothing: number;

    /** Height offset for this biome */
    height_offset?: number;

    /** Squashing modifier (multiplier) */
    squash_modifier?: number;

    /** Cave density modifier (multiplier) */
    cave_density_modifier?: number;

    constructor(
        opts: {
            influence?: number;
            smoothing?: number;
            heightOffset?: number;
            squashModifier?: number;
            caveDensityModifier?: number;
        } = {},
    ) {
        this.influence = opts.influence ?? 1.0;
        this.smoothing = opts.smoothing ?? 16;
        if (opts.heightOffset !== undefined)
            this.height_offset = opts.heightOffset;
        if (opts.squashModifier !== undefined)
            this.squash_modifier = opts.squashModifier;
        if (opts.caveDensityModifier !== undefined)
            this.cave_density_modifier = opts.caveDensityModifier;
    }
}

// ============================================================================
// MAIN CONFIG
// ============================================================================

export class WorldGenConfig {
    surface: SurfaceShape;
    cave: CaveShape;

    constructor(surface?: SurfaceShape, cave?: CaveShape) {
        this.surface = surface ?? new SurfaceShape();
        this.cave = cave ?? new CaveShape();
    }
}
