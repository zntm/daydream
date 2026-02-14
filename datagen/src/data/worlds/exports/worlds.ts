import { DatagenReturnData, Noise, Spline, SplinePoint, SplineEasing } from "../../../lib";
import {
    World,
    WorldVignette,
    WorldTime,
    WorldTimeDiurnal,
    WorldCelestial,
    WorldBiome,
    WorldCaveBiome,
    WorldCaveBiomeTransitionType,
    WorldSky,
    WorldSurface,
    WorldCave,
    WorldCaveSystem,
    WorldAquifer
} from "../lib/World";

export default [
    new DatagenReturnData(
        "worlds/playground.json",
        new World(
            1024,
            14,
            new WorldVignette(768, 1024, "#000000"),
            new WorldTime(240, [
                new WorldTimeDiurnal("dawn", 0, 240),
                new WorldTimeDiurnal("day", 240, 820),
                new WorldTimeDiurnal("dusk", 820, 890),
                new WorldTimeDiurnal("night", 890, 1200),
            ], 1200),
            [
                new WorldCelestial(
                    "phantasia:world/playground/celestial/sun",
                    0,
                    890,
                ),
                new WorldCelestial(
                    "phantasia:world/playground/celestial/moon",
                    890,
                    1200,
                ),
            ],
            new WorldBiome(
                [
                    new WorldCaveBiome("phantasia:cave/depths", 768, 1024, {
                        type: WorldCaveBiomeTransitionType.Random,
                        ...new Noise(4, 2, 22),
                    }),
                    new WorldCaveBiome("phantasia:cave/chasm", 0, 800, {
                        type: WorldCaveBiomeTransitionType.Random,
                        ...new Noise(0, 2, 22),
                    }),
                ],
                new Noise(4).setScale(0.005).setSplineY(new Spline([
                    new SplinePoint(0, -1, SplineEasing.Linear),
                    new SplinePoint(1024, 1, SplineEasing.Linear),
                ])),
                [],
                new Noise(4.5).setScale(0.005).setSplineX(new Spline([
                    new SplinePoint(0, -1, SplineEasing.Linear),
                    new SplinePoint(1024, 1, SplineEasing.Linear),
                ])),
                new Noise(2.75).setScale(0.005),
                "phantasia:world/playground/map",
                new Noise(2, 22, 34),
                // Use surface logic for caves for now (placeholder values)
                new Noise(4.5),
                new Noise(2.75),
                undefined,
                new WorldSky()
            ),
            new WorldSurface(512, new Noise(4, 40, 96)),
            new WorldCave(new Noise(0, 12, 2), [
                new WorldCaveSystem(50, 70, new Noise(4)),
                new WorldCaveSystem(116, 140, new Noise(4)),
            ], [
                // Water aquifers: shallow caves (20-200 blocks below surface)
                new WorldAquifer("phantasia:water", 20, 200, 200, 3, 8),
                // Lava aquifers: deep caves (350-450 blocks below surface)
                new WorldAquifer("phantasia:lava", 350, 450, 220, 2, 8),
            ], new Spline([
                // Depth smoothing: caves scale from 0 at surface to 1 at depth
                new SplinePoint(0, 0, SplineEasing.EaseOut),   // At surface: no caves (ease out for gradual start)
                new SplinePoint(16, 0.3),                      // 16 blocks deep: 30% cave size
                new SplinePoint(64, 1),                        // 64 blocks deep: full caves
            ])),
            0.5,
            [
                "emeraldine",
                "rotfens",
                "dustbunny",
                "borea",
                "glacien"
            ]
        ),
    ),
];
