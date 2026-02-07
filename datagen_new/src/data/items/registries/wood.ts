class LeafRegistry {
    id: string;
    particles: string[];

    constructor(id: string, particles: string[]) {
        this.id = id;
        this.particles = particles;
    }
}

class WoodRegistry {
    namespace: string;
    id: string;
    leaves: LeafRegistry[];
    logParticles: string[];
    planksParticles: string[];

    constructor(
        namespace: string,
        id: string,
        leaves: LeafRegistry[] | string[],
        logParticles: string[],
        planksParticles: string[],
    ) {
        this.namespace = namespace;
        this.id = id;
        this.logParticles = logParticles;
        this.planksParticles = planksParticles;

        if (Array.isArray(leaves)) {
            if (leaves.length > 0 && typeof leaves[0] === "string") {
                this.leaves = [new LeafRegistry(`${id}_leaves`, leaves as string[])];
            } else {
                this.leaves = leaves as LeafRegistry[];
            }
        } else {
            this.leaves = [leaves as LeafRegistry];
        }
    }
}

export default [
    new WoodRegistry(
        "phantasia",
        "birch",
        [
            new LeafRegistry("birch_leaves", ["#051417", "#041013"]),
            new LeafRegistry("golden_birch_leaves", ["#FFBC00", "#FFD700"]),
        ],
        ["#4F5263", "#3E4051"],
        ["#4F5263", "#3E4051"],
    ),
    new WoodRegistry(
        "phantasia",
        "mangrove",
        ["#122D2B", "#0B2021"],
        ["#4D2D0B", "#3F2207"],
        ["#4D2D0B", "#3F2207"],
    ),
    new WoodRegistry(
        "phantasia",
        "oak",
        ["#122D2B", "#0B2021"],
        ["#3B160A", "#2D0B04"],
        ["#3B160A", "#2D0B04"],
    ),
    new WoodRegistry(
        "phantasia",
        "pine",
        [
            new LeafRegistry("pine_leaves", ["#122D2B", "#0B2021"]),
            new LeafRegistry("silver_pine_leaves", ["#C0C0C0", "#E0E0E0"]),
        ],
        ["#381D1E", "#301A1C"],
        ["#381D1E", "#301A1C"],
    ),
];
