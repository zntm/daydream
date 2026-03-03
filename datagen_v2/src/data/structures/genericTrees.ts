import type { SmartValueIntRandom } from "../../../../datagen/src/lib";
import { DatagenReturnData, SmartValue } from "../../lib";

import {
    Structure,
    StructureFunction,
    StructureParameterTile,
    StructurePlacement,
    StructurePlacementClearanceCondition,
    StructurePlacementType,
} from "./lib/Structure";

const { StructureParameter: StructureOreParameter } = import.meta.require(
    "./ores",
);

class StructureParameter {
    private tile_wood: StructureParameterTile;
    private tile_leaves: StructureParameterTile;
    private index: number | string | SmartValueIntRandom;
    private index_top: number;
    private index_bottom: number;
    private layers: Array<{
        width: number;
        index_offset: number;
        xscale?: number;
        yscale?: number;
    }>;

    constructor(
        tileWood: StructureParameterTile,
        tileLeaves: StructureParameterTile,
        index: number | string | SmartValueIntRandom,
        indexTop: number,
        indexBottom: number,
        layers: Array<{
            width: number;
            index_offset: number;
            xscale?: number;
            yscale?: number;
        }>,
    ) {
        this.tile_wood = tileWood;
        this.tile_leaves = tileLeaves;
        this.index = index;
        this.index_top = indexTop;
        this.index_bottom = indexBottom;
        this.layers = layers;
    }
}

export default [
    // Birch
    new DatagenReturnData(
        "tree/birch.json",
        new Structure(
            7,
            SmartValue.IntRandom(9, 12),
            new StructurePlacement(
                StructurePlacementType.Floor,
                -3,
                "-height",
                [
                    new StructurePlacementClearanceCondition(
                        -3,
                        "-height",
                        "width",
                        4,
                    ),
                ],
                true,
            ),
            new StructureFunction(
                "phantasia:tree/generic",
                new StructureParameter(
                    new StructureParameterTile("phantasia:birch"),
                    new StructureParameterTile("phantasia:birch_leaves"),
                    SmartValue.IntRandom(1, 3),
                    4,
                    5,
                    [
                        { width: 5, index_offset: 0 },
                        { width: 5, yscale: 1, index_offset: 5 },
                        { width: 7, index_offset: 0 },
                        { width: 7, yscale: 1, index_offset: 5 },
                    ],
                ),
            ),
        ),
    ),
    // Mangrove
    new DatagenReturnData(
        "tree/mangrove.json",
        new Structure(
            7,
            SmartValue.IntRandom(7, 10),
            new StructurePlacement(
                StructurePlacementType.Floor,
                -3,
                "-height",
                [
                    new StructurePlacementClearanceCondition(
                        -3,
                        "-height",
                        "width",
                        6,
                    ),
                ],
                true,
            ),
            new StructureFunction(
                "phantasia:tree/generic",
                new StructureParameter(
                    new StructureParameterTile("phantasia:mangrove"),
                    new StructureParameterTile("phantasia:mangrove_leaves"),
                    SmartValue.IntRandom(1, 3),
                    4,
                    5,
                    [
                        { width: 3, index_offset: 0 },
                        { width: 3, yscale: 1, index_offset: 5 },
                        { width: 5, index_offset: 0 },
                        { width: 5, yscale: 1, index_offset: 5 },
                    ],
                ),
            ),
        ),
    ),
    // Mangrove Roots
    new DatagenReturnData(
        "tree/mangrove_roots.json",
        new Structure(
            5,
            5,
            new StructurePlacement(StructurePlacementType.Floor, -2, -1),
            new StructureFunction(
                "phantasia:ore",
                new StructureOreParameter(
                    new StructureParameterTile("phantasia:mangrove_roots"),
                    0.4,
                    0.8,
                    0.8,
                ),
            ),
        ),
    ),
    // Oak
    new DatagenReturnData(
        "tree/oak.json",
        new Structure(
            5,
            SmartValue.IntRandom(6, 9),
            new StructurePlacement(
                StructurePlacementType.Floor,
                -2,
                "-height",
                [
                    new StructurePlacementClearanceCondition(
                        -2,
                        "-height",
                        "width",
                        4,
                    ),
                ],
                true,
            ),
            new StructureFunction(
                "phantasia:tree/generic",
                new StructureParameter(
                    new StructureParameterTile("phantasia:oak"),
                    new StructureParameterTile("phantasia:oak_leaves"),
                    SmartValue.IntRandom(1, 3),
                    4,
                    5,
                    [
                        { width: 3, index_offset: 0 },
                        { width: 3, yscale: 1, index_offset: 5 },
                        { width: 5, index_offset: 0 },
                        { width: 5, yscale: 1, index_offset: 5 },
                    ],
                ),
            ),
        ),
    ),
];
