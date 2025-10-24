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
    private tile_base: StructureParameterTile;
    private tile_wall: StructureParameterTile;

    constructor(
        tileBase: StructureParameterTile,
        tileWall: StructureParameterTile,
    ) {
        this.tile_base = tileBase;
        this.tile_wall = tileWall;
    }
}

export default [
    // Moss
    new DatagenReturnData(
        "generated/data/structures/clump/moss.json",
        new Structure(
            5,
            5,
            new StructurePlacement(StructurePlacementType.Floor, -2, -3),
            new StructureFunction(
                "phantasia:clump",
                new StructureParameter(
                    new StructureParameterTile("phantasia:moss"),
                    new StructureParameterTile("phantasia:moss_wall"),
                ),
            ),
        ),
    ),
];
