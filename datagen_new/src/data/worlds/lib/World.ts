/**
 * Region transition configuration for smooth terrain blending
 */
export interface RegionTransition {
    /** Width of the transition zone (in blocks) */
    width: number;
    /** Noise scale for jagged transition edges (optional) */
    noise_scale?: number;
    /** Noise amplitude for transition edge variation (optional) */
    noise_amplitude?: number;
}

/**
 * World - Top-level world configuration
 */
export class World {
    private _id: string;
    private _world_height: number = 1024;
    private _spawn_interval: number = 14;

    // Region transition settings
    private _region_transition: RegionTransition = {
        width: 32,
        noise_scale: 0.05,
        noise_amplitude: 8,
    };

    // Surface biome map reference
    private _surface_biome_map?: string;

    constructor(id: string) {
        this._id = id;
    }

    setWorldHeight(height: number): World {
        this._world_height = height;
        return this;
    }

    setSpawnInterval(interval: number): World {
        this._spawn_interval = interval;
        return this;
    }

    setRegionTransition(config: Partial<RegionTransition>): World {
        this._region_transition = {
            ...this._region_transition,
            ...config,
        };
        return this;
    }

    setSurfaceBiomeMap(mapId: string): World {
        this._surface_biome_map = mapId;
        return this;
    }

    /**
     * Get the ID for destination path
     */
    getId(): string {
        return this._id;
    }

    /**
     * Serialize to JSON
     */
    toJSON(): any {
        const data: any = {
            id: this._id,
            world_height: this._world_height,
            spawn_interval: this._spawn_interval,
            region_transition: this._region_transition,
        };

        if (this._surface_biome_map) {
            data.surface_biome_map = this._surface_biome_map;
        }

        return data;
    }
}
