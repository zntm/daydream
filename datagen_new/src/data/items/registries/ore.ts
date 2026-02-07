export class OreRegistry {
    namespace: string;
    id: string;
    harvestLevel: number;
    blockHardness: number;
    oreHardness: number;
    particles: string;
    hasRawItem: boolean;

    constructor(
        namespace: string,
        id: string,
        harvestLevel: number,
        blockHardness: number,
        oreHardness: number,
        particles: string,
        hasRawItem: boolean = false,
    ) {
        this.namespace = namespace;
        this.id = id;
        this.harvestLevel = harvestLevel;
        this.blockHardness = blockHardness;
        this.oreHardness = oreHardness;
        this.particles = particles;
        this.hasRawItem = hasRawItem;
    }
}

export default [
    new OreRegistry(
        "phantasia",
        "coal",
        1,
        0.58,
        0.38,
        "#phantasia:tile/particle_colour/stone",
    ),
    new OreRegistry(
        "phantasia",
        "copper",
        1,
        0.68,
        0.42,
        "#phantasia:tile/particle_colour/stone",
        true,
    ),
    new OreRegistry(
        "phantasia",
        "iron",
        1,
        0.78,
        0.48,
        "#phantasia:tile/particle_colour/stone",
        true,
    ),
    new OreRegistry(
        "phantasia",
        "gold",
        1,
        0.88,
        0.56,
        "#phantasia:tile/particle_colour/stone",
        true,
    ),
    new OreRegistry(
        "phantasia",
        "platinum",
        1,
        0.98,
        0.72,
        "#phantasia:tile/particle_colour/stone",
        true,
    ),
];
