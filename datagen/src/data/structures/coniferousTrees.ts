import {
    DatagenReturnData,
    SmartValueFloatRandom,
    SmartValueIntRandom,
} from "../../../index";

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
    private index: number | string | SmartValueIntRandom;
    private index_top: number;
    private index_bottom: number;
    private cone_steepness: number | string | SmartValueFloatRandom;
    private cone_roundness: number | string | SmartValueFloatRandom;
    private cone_width: number | string | SmartValueFloatRandom;
    private cone_offset: number | string | SmartValueFloatRandom;

    constructor(
        tileWood: StructureParameterTile,
        tileLeaves: StructureParameterTile,
        index: number | string | SmartValueIntRandom,
        indexTop: number,
        indexBottom: number,
        coneSteepness: number | string | SmartValueFloatRandom,
        coneRoundness: number | string | SmartValueFloatRandom,
        coneWidth: number | string | SmartValueFloatRandom,
        coneOffset: number | string | SmartValueFloatRandom,
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
            new SmartValueIntRandom(9, 14),
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
                    new SmartValueFloatRandom(0.1, 0.3),
                    new SmartValueFloatRandom(1, 3),
                    1,
                    new SmartValueFloatRandom(-0.2, 0),
                ),
            ),
        ),
    ),
];
