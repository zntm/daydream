import {
    DatagenReturnData,
    SmartValue,
    SmartValueChooseWeightedOption,
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
    // Cactus
    new DatagenReturnData(
        "generated/data/structures/tall_foliage/cactus.json",
        new Structure(
            1,
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(4, 8),
            ),
            new StructurePlacement(StructurePlacementType.Floor, 0, "-height", [
                new StructurePlacementClearanceCondition(
                    0,
                    "-height",
                    1,
                    "height",
                ),
            ]),
            new StructureFunction(
                "phantasia:tall_foliage",
                new StructureParameter(
                    new StructureParameterTile("phantasia:cactus", 5),
                    new StructureParameterTile(
                        "phantasia:cactus",
                        new SmartValue(
                            SmartValueType.IntRandom,
                            new SmartValueRandom(1, 4),
                        ),
                    ),
                    new StructureParameterTile(
                        "phantasia:cactus",
                        new SmartValue(
                            SmartValueType.IntRandom,
                            new SmartValueRandom(1, 4),
                        ),
                    ),
                ),
            ),
        ),
    ),
    // Cattail
    new DatagenReturnData(
        "generated/data/structures/tall_foliage/cattail.json",
        new Structure(
            1,
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(3, 6),
            ),
            new StructurePlacement(StructurePlacementType.Floor, 0, "-height", [
                new StructurePlacementClearanceCondition(
                    0,
                    "-height",
                    1,
                    "height",
                ),
            ]),
            new StructureFunction(
                "phantasia:tree/generic",
                new StructureParameter(
                    new StructureParameterTile("phantasia:cattail", 2),
                    new StructureParameterTile("phantasia:cattail", 1),
                    new StructureParameterTile("phantasia:cattail", 1),
                ),
            ),
        ),
    ),
    // Sunflower
    new DatagenReturnData(
        "generated/data/structures/tall_foliage/sunflower.json",
        new Structure(
            1,
            new SmartValue(
                SmartValueType.IntRandom,
                new SmartValueRandom(3, 6),
            ),
            new StructurePlacement(StructurePlacementType.Floor, 0, "-height", [
                new StructurePlacementClearanceCondition(
                    0,
                    "-height",
                    1,
                    "height",
                ),
            ]),
            new StructureFunction(
                "phantasia:tree/generic",
                new StructureParameter(
                    new StructureParameterTile("phantasia:sunflower", 0),
                    new StructureParameterTile(
                        "phantasia:sunflower",
                        new SmartValue(SmartValueType.ChooseWeighted, [
                            new SmartValueChooseWeightedOption(2, 1),
                            new SmartValueChooseWeightedOption(3, 3),
                        ]),
                    ),
                    new StructureParameterTile("phantasia:sunflower", 1),
                ),
            ),
        ),
    ),
];
