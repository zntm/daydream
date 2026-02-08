import {
    World,
    WorldVignette,
    WorldTime,
    WorldTimeDiurnal,
    WorldCelestial,
    WorldBiome,
    WorldCaveBiome,
    WorldCaveBiomeTransitionType,
    WorldSurface,
    WorldCave,
    WorldCaveSystem,
    WorldAquifer,
    WorldSky,
} from "../lib";
import {
    DatagenReturnData,
    Noise,
    Spline,
    SplinePoint,
    SplineEasing,
} from "../../../lib";

/**
 * Playground - Main test world ported with full parity
 */
const playground = new World("playground")
    .setWorldHeight(1024)
    .setSpawnInterval(14)
    .setRegionTransition({
        width: 32,
        noise_scale: 0.05,
        noise_amplitude: 8,
    })
    .setVignette(new WorldVignette(768, 1024, "#000000"))
    .setTime(
        new WorldTime(
            240,
            [
                new WorldTimeDiurnal("dawn", 0, 240),
                new WorldTimeDiurnal("day", 240, 820),
                new WorldTimeDiurnal("dusk", 820, 890),
                new WorldTimeDiurnal("night", 890, 1200),
            ],
            1200,
        ),
    )
    .addCelestial(
        new WorldCelestial("phantasia:world/playground/celestial/sun", 0, 890),
    )
    .addCelestial(
        new WorldCelestial(
            "phantasia:world/playground/celestial/moon",
            890,
            1200,
        ),
    )
    .setBiome(
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
            new Noise(4)
                .setScale(0.005)
                .setSplineY(
                    new Spline([
                        new SplinePoint(0, -1, SplineEasing.Linear),
                        new SplinePoint(1024, 1, SplineEasing.Linear),
                    ]),
                ),
            new Noise(4.5)
                .setScale(0.005)
                .setSplineX(
                    new Spline([
                        new SplinePoint(0, -1, SplineEasing.Linear),
                        new SplinePoint(1024, 1, SplineEasing.Linear),
                    ]),
                ),
            new Noise(2.75).setScale(0.005),
            "phantasia:world/playground/map",
            new Noise(2, 22, 34),
        )
            .setCaveMetadata(new Noise(4.5), new Noise(2.75))
            .setSky(new WorldSky()),
    )
    .setSurface(new WorldSurface(512, new Noise(4, 40, 96)))
    .setCave(
        new WorldCave(new Noise(0, 12, 2), [
            new WorldCaveSystem(50, 70, new Noise(4)),
            new WorldCaveSystem(116, 140, new Noise(4)),
        ])
            .setAquifers([
                new WorldAquifer("phantasia:water", 20, 200, 200, 3, 8),
                new WorldAquifer("phantasia:lava", 350, 450, 220, 2, 8),
            ])
            .setDepthSmoothing(
                new Spline([
                    new SplinePoint(0, 0, SplineEasing.EaseOut),
                    new SplinePoint(16, 0.3),
                    new SplinePoint(64, 1),
                ]),
            ),
    );

export default [
    new DatagenReturnData(`${playground.getId()}.json`, playground),
];
