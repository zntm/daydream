class WoodRegistry {
    namespace: string;
    id: string;
    leavesParticles: string[];
    logParticles: string[];
    planksParticles: string[];
    leafVariants?: string[];

    constructor(
        namespace: string,
        id: string,
        leavesParticles: string[],
        logParticles: string[],
        planksParticles: string[],
    ) {
        this.namespace = namespace;
        this.id = id;
        this.leavesParticles = leavesParticles;
        this.logParticles = logParticles;
        this.planksParticles = planksParticles;
    }

    addLeafVariants(variants: string[]) {
        this.leafVariants = variants;

        return this;
    }
}

export default [
    new WoodRegistry(
        "phantasia",
        "birch",
        ["#051417", "#041013"],
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
        ["#122D2B", "#0B2021"],
        ["#381D1E", "#301A1C"],
        ["#381D1E", "#301A1C"],
    ),
];
