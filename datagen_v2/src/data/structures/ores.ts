import type { SmartValueIntRandom } from "../../../../datagen/src/lib";
import { DatagenReturnData, SmartValue } from "../../lib";

import {
    Structure,
    StructureFunction,
    StructureParameterTile,
    StructurePlacement,
    StructurePlacementType,
} from "./lib/Structure";

export class StructureParameter {
    private tile: StructureParameterTile;
    private threshold: number | string | SmartValueIntRandom;
    private clumpiness: number | string | SmartValueIntRandom;
    private roundedness: number | string | SmartValueIntRandom;

    constructor(
        tile: StructureParameterTile,
        threshold: number | string | SmartValueIntRandom,
        clumpiness: number | string | SmartValueIntRandom,
        roundedness: number | string | SmartValueIntRandom,
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
        "ore/coal.json",

        new Structure(
            SmartValue.IntRandom(2, 6),
            SmartValue.IntRandom(2, 6),
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
        "ore/copper.json",

        new Structure(
            SmartValue.IntRandom(1, 4),
            SmartValue.IntRandom(1, 4),
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
        "ore/iron.json",

        new Structure(
            SmartValue.IntRandom(2, 4),
            SmartValue.IntRandom(2, 4),
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
        "ore/gold.json",

        new Structure(
            SmartValue.IntRandom(1, 4),
            SmartValue.IntRandom(1, 4),
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
        "ore/platinum.json",

        new Structure(
            SmartValue.IntRandom(1, 3),
            SmartValue.IntRandom(1, 3),
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
