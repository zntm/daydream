export class WoodRegistry {
    id: string;
    leavesParticles: string[];
    logParticles: string[];
    planksParticles: string[];

    constructor(
        id: string,
        leavesParticles: string[],
        logParticles: string[],
        planksParticles: string[],
    ) {
        this.id = id;
        this.leavesParticles = leavesParticles;
        this.logParticles = logParticles;
        this.planksParticles = planksParticles;
    }
}

export default [
    new WoodRegistry(
        "birch",
        ["#051417", "#041013"],
        ["#4F5263", "#3E4051"],
        ["#4F5263", "#3E4051"],
    ),
    new WoodRegistry(
        "mangrove",
        ["#122D2B", "#0B2021"],
        ["#4D2D0B", "#3F2207"],
        ["#4D2D0B", "#3F2207"],
    ),
    new WoodRegistry(
        "oak",
        ["#122D2B", "#0B2021"],
        ["#3B160A", "#2D0B04"],
        ["#3B160A", "#2D0B04"],
    ),
    new WoodRegistry(
        "pine",
        ["#122D2B", "#0B2021"],
        ["#381D1E", "#301A1C"],
        ["#381D1E", "#301A1C"],
    ),
    new WoodRegistry(
        "cherry",
        ["#E8A0C0", "#D890B0"],
        ["#5E3A24", "#4A2E1C"],
        ["#5E3A24", "#4A2E1C"],
    ),
];
