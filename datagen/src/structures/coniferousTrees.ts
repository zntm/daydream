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
    private cone_steepness: number | string | SmartValue;
    private cone_roundness: number | string | SmartValue;
    private cone_width: number | string | SmartValue;
    private cone_offset: number | string | SmartValue;

    constructor(
        tileWood: StructureParameterTile,
        tileLeaves: StructureParameterTile,
        index: number | string | SmartValue,
        indexTop: number,
        indexBottom: number,
        coneSteepness: number | string | SmartValue,
        coneRoundness: number | string | SmartValue,
        coneWidth: number | string | SmartValue,
        coneOffset: number | string | SmartValue,
    ) {
        this.tile_wood = tileWood;
        this.tile_leaves = tileLeaves;
        this.index = index;
        this.index_top = indexTop;
        this.index_bottom = indexBottom;
        this.cone_steepness = coneSteepness;
        this.cone_roundness = coneRoundness;
        this.cone_width = coneWidth;
        this.cone_offset = coneOffset;
    }
}

export default [
    // Pine
    new DatagenReturnData(
        "generated/data/structures/tree/pine.json",
        new Structure(
            9,
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(9, 14),
            ),
            new StructurePlacement(StructurePlacementType.Floor, 0, "-height", [
                new StructurePlacementClearanceCondition(
                    -4,
                    "-height",
                    "width",
                    8,
                ),
            ]),
            new StructureFunction(
                "phantasia:tree/coniferous",
                new StructureParameter(
                    new StructureParameterTile("phantasia:pine"),
                    new StructureParameterTile("phantasia:pine_leaves"),
                    1,
                    2,
                    3,
                    new SmartValue(
                        SmartValueType.FloatRandom,
                        new SmartValueRandom(0.1, 0.3),
                    ),
                    new SmartValue(
                        SmartValueType.FloatRandom,
                        new SmartValueRandom(1, 3),
                    ),
                    1,
                    new SmartValue(
                        SmartValueType.FloatRandom,
                        new SmartValueRandom(-0.2, 0),
                    ),
                ),
            ),
        ),
    ),
];
