class WoodRegistry {
    namespace: string;
    id: string;
    logParticles: string[];
    planksParticles: string[];
    leafRegistries?: LeafRegistry[];

    constructor(
        namespace: string,
        id: string,
        logParticles: string[],
        planksParticles: string[],
    ) {
        this.namespace = namespace;
        this.id = id;
        this.logParticles = logParticles;
        this.planksParticles = planksParticles;
    }

    addLeafRegistry(leaf: LeafRegistry) {
        this.leafRegistries ??= [];
        this.leafRegistries.push(leaf);

        return this;
    }
}

class LeafRegistry {
    id: string;
    particles: string[];

    constructor(id: string, particles: string[]) {
        this.id = id;
        this.particles = particles;
    }
}

export default [
    new WoodRegistry(
        "phantasia",
        "birch",
        ["#4F5263", "#3E4051"],
        ["#4F5263", "#3E4051"],
    )
        .addLeafRegistry(new LeafRegistry("", ["#051417", "#041013"]))
        .addLeafRegistry(new LeafRegistry("golden", ["#6A2919", "#572016"])),
    new WoodRegistry(
        "phantasia",
        "cherry",
        ["#5E3A24", "#4A2E1C"],
        ["#5E3A24", "#4A2E1C"],
    )
        .addLeafRegistry(new LeafRegistry("", ["#E8A0C0", "#D890B0"]))
        .addLeafRegistry(new LeafRegistry("golden", ["#C56052", "#B64845"])),
    new WoodRegistry(
        "phantasia",
        "mangrove",
        ["#4D2D0B", "#3F2207"],
        ["#4D2D0B", "#3F2207"],
    ).addLeafRegistry(new LeafRegistry("", ["#122D2B", "#0B2021"])),
    new WoodRegistry(
        "phantasia",
        "oak",
        ["#3B160A", "#2D0B04"],
        ["#3B160A", "#2D0B04"],
    ).addLeafRegistry(new LeafRegistry("", ["#122D2B", "#0B2021"])),
    new WoodRegistry(
        "phantasia",
        "pine",
        ["#381D1E", "#301A1C"],
        ["#381D1E", "#301A1C"],
    )
        .addLeafRegistry(new LeafRegistry("", ["#122D2B", "#0B2021"]))
        .addLeafRegistry(new LeafRegistry("silver", ["#142A33", "#10202B"])),
];
