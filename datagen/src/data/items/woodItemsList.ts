const { default: woodItems } = import.meta.require("./woodItems");

export default [
    ...[
        {
            id: "birch",
            leavesParticleId: ["#051417", "#041013"],
            logParticleId: ["#4F5263", "#3E4051"],
        },
        {
            id: "oak",
            leavesParticleId: ["#122D2B", "#0B2021"],
            logParticleId: ["#3B160A", "#2D0B04"],
        },
        {
            id: "pine",
            leavesParticleId: ["#122D2B", "#0B2021"],
            logParticleId: ["#381D1E", "#301A1C"],
        },
    ]
        .map(({ id, leavesParticleId, logParticleId }): any =>
            woodItems(id, leavesParticleId, logParticleId),
        )
        .flat(),
];
