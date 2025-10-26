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
    StructurePlacementClearanceCondition,
    StructurePlacementType,
} from "../structures";

class StructureParameter {
    private tile_wood: StructureParameterTile;
    private tile_leaves: StructureParameterTile;
    private index: number | string | SmartValue;
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
        index: number | string | SmartValue,
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
        "generated/data/structures/tree/birch.json",
        new Structure(
            7,
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(9, 12),
            ),
            new StructurePlacement(StructurePlacementType.Floor, 0, "-height", [
                new StructurePlacementClearanceCondition(
                    -3,
                    "-height",
                    "width",
                    4,
                ),
            ]),
            new StructureFunction(
                "phantasia:tree/generic",
                new StructureParameter(
                    new StructureParameterTile("phantasia:birch"),
                    new StructureParameterTile("phantasia:birch_leaves"),
                    new SmartValue(
                        SmartValueType.IntRandom,
                        new SmartValueRandom(1, 3),
                    ),
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
    // Oak
    new DatagenReturnData(
        "generated/data/structures/tree/oak.json",
        new Structure(
            5,
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(6, 9),
            ),
            new StructurePlacement(StructurePlacementType.Floor, 0, "-height", [
                new StructurePlacementClearanceCondition(
                    -2,
                    "-height",
                    "width",
                    4,
                ),
            ]),
            new StructureFunction(
                "phantasia:tree/generic",
                new StructureParameter(
                    new StructureParameterTile("phantasia:oak"),
                    new StructureParameterTile("phantasia:oak_leaves"),
                    new SmartValue(
                        SmartValueType.IntRandom,
                        new SmartValueRandom(1, 3),
                    ),
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
