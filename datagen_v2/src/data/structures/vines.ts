import {
    DatagenReturnData,
    SmartValue,
} from "../../lib";

import {
    Structure,
    StructureFunction,
    StructureParameterTile,
    StructurePlacement,
    StructurePlacementClearanceCondition,
    StructurePlacementType,
} from "./lib/Structure";

class StructureParameter {
    private tile_top: StructureParameterTile;
    private tile_middle: StructureParameterTile;
    private tile_bottom: StructureParameterTile;

    constructor(
        tileTop: StructureParameterTile,
        tileMiddle: StructureParameterTile,
        tileBottom: StructureParameterTile,
    ) {
        this.tile_top = tileTop;
        this.tile_middle = tileMiddle;
        this.tile_bottom = tileBottom;
    }
}

export default [
    // Vine
    ...["vine", "lumin_vine"].map(id =>
        new DatagenReturnData(
            `tall_foliage/${id}.json`,
            new Structure(
                1,
                SmartValue.IntRandom(3, 8),
                new StructurePlacement(
                    StructurePlacementType.Ceiling,
                    0,
                    0,
                    [
                        new StructurePlacementClearanceCondition(
                            0,
                            0,
                            1,
                            "height",
                        ),
                    ],
                    true,
                ),
                new StructureFunction(
                    "phantasia:vine",
                    new StructureParameter(
                        new StructureParameterTile(`phantasia:${id}`, 0),
                        new StructureParameterTile(`phantasia:${id}`, 1),
                        new StructureParameterTile(`phantasia:${id}`, 2),
                    ),
                ),
            ),
        )
    ),
];
