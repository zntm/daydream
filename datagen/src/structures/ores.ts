import {
    DatagenReturnData,
    SmartValue,
    SmartValueRandom,
    SmartValueType,
} from "../../index";

import {
    Structure,
    StructureFunction,
    StructureParameterTile,
    StructurePlacement,
    StructurePlacementType,
} from "../structures";

class StructureParameter {
    private tile: StructureParameterTile;
    private threshold: number | string | SmartValue;
    private clumpiness: number | string | SmartValue;
    private roundedness: number | string | SmartValue;

    constructor(
        tile: StructureParameterTile,
        threshold: number | string | SmartValue,
        clumpiness: number | string | SmartValue,
        roundedness: number | string | SmartValue,
    ) {
        this.tile = tile;
        this.threshold = threshold;
        this.clumpiness = clumpiness;
        this.roundedness = roundedness;
    }
}

export default [
    // Coal
    new DatagenReturnData(
        "generated/data/structures/ore/coal.json",
        new Structure(
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(2, 6),
            ),
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(2, 6),
            ),
            new StructurePlacement(StructurePlacementType.Inside, 0, 0),
            new StructureFunction(
                "phantasia:ore",
                new StructureParameter(
                    new StructureParameterTile("phantasia:coal_ore"),
                    0.6,
                    0.6,
                    0.4,
                ),
            ),
        ),
    ),
    // Copper
    new DatagenReturnData(
        "generated/data/structures/ore/copper.json",
        new Structure(
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(1, 4),
            ),
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(1, 4),
            ),
            new StructurePlacement(StructurePlacementType.Inside, 0, 0),
            new StructureFunction(
                "phantasia:ore",
                new StructureParameter(
                    new StructureParameterTile("phantasia:copper_ore"),
                    0.7,
                    0.6,
                    0.4,
                ),
            ),
        ),
    ),
    // Iron
    new DatagenReturnData(
        "generated/data/structures/ore/iron.json",
        new Structure(
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(2, 4),
            ),
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(2, 4),
            ),
            new StructurePlacement(StructurePlacementType.Inside, 0, 0),
            new StructureFunction(
                "phantasia:ore",
                new StructureParameter(
                    new StructureParameterTile("phantasia:iron_ore"),
                    0.7,
                    0.6,
                    0.4,
                ),
            ),
        ),
    ),
    // Gold
    new DatagenReturnData(
        "generated/data/structures/ore/gold.json",
        new Structure(
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(1, 4),
            ),
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(1, 4),
            ),
            new StructurePlacement(StructurePlacementType.Inside, 0, 0),
            new StructureFunction(
                "phantasia:ore",
                new StructureParameter(
                    new StructureParameterTile("phantasia:gold_ore"),
                    0.7,
                    0.5,
                    0.4,
                ),
            ),
        ),
    ),
    // Platinum
    new DatagenReturnData(
        "generated/data/structures/ore/platinum.json",
        new Structure(
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(1, 3),
            ),
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(1, 3),
            ),
            new StructurePlacement(StructurePlacementType.Inside, 0, 0),
            new StructureFunction(
                "phantasia:ore",
                new StructureParameter(
                    new StructureParameterTile("phantasia:platinum_ore"),
                    0.6,
                    0.2,
                    0.5,
                ),
            ),
        ),
    ),
];
