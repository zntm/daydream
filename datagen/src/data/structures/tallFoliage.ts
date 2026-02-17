import {
    DatagenReturnData,
    type SmartValue,
    ChooseWeightedOption,
} from "../../lib";
import {
    SmartValueChooseWeighted,
    SmartValueIntRandom,
} from "../../lib/SmartValue";

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
    // Cactus
    new DatagenReturnData(
        "tall_foliage/cactus.json",
        new Structure(
            1,
            new SmartValueIntRandom(2, 6),
            new StructurePlacement(StructurePlacementType.Floor, 0, "-height", [
                new StructurePlacementClearanceCondition(
                    0,
                    "-height",
                    1,
                    "height",
                ),
            ], true),
            new StructureFunction(
                "phantasia:tall_foliage",
                new StructureParameter(
                    new StructureParameterTile("phantasia:cactus", 5),
                    new StructureParameterTile(
                        "phantasia:cactus",
                        new SmartValueIntRandom(1, 4),
                    ),
                    new StructureParameterTile(
                        "phantasia:cactus",
                        new SmartValueIntRandom(1, 4),
                    ),
                ),
            ),
        ),
    ),
    // Cattail
    new DatagenReturnData(
        "tall_foliage/cattail.json",
        new Structure(
            1,
            new SmartValueIntRandom(3, 8),
            new StructurePlacement(StructurePlacementType.Floor, 0, "-height", [
                new StructurePlacementClearanceCondition(
                    0,
                    "-height",
                    1,
                    "height",
                ),
            ], true),
            new StructureFunction(
                "phantasia:tall_foliage",
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
        "tall_foliage/sunflower.json",
        new Structure(
            1,
            new SmartValueIntRandom(3, 6),
            new StructurePlacement(StructurePlacementType.Floor, 0, "-height", [
                new StructurePlacementClearanceCondition(
                    0,
                    "-height",
                    1,
                    "height",
                ),
            ], true),
            new StructureFunction(
                "phantasia:tall_foliage",
                new StructureParameter(
                    new StructureParameterTile("phantasia:sunflower", 0),
                    new StructureParameterTile(
                        "phantasia:sunflower",
                        new SmartValueChooseWeighted([
                            new ChooseWeightedOption(2, 1),
                            new ChooseWeightedOption(3, 3),
                        ]),
                    ),
                    new StructureParameterTile("phantasia:sunflower", 1),
                ),
            ),
        ),
    ),
    // Bamboo
    new DatagenReturnData(
        "tall_foliage/bamboo.json",
        new Structure(
            1,
            new SmartValueIntRandom(4, 10),
            new StructurePlacement(StructurePlacementType.Floor, 0, "-height", [
                new StructurePlacementClearanceCondition(
                    0,
                    "-height",
                    1,
                    "height",
                ),
            ], true),
            new StructureFunction(
                "phantasia:tall_foliage",
                new StructureParameter(
                    new StructureParameterTile("phantasia:bamboo", 4),
                    new StructureParameterTile(
                        "phantasia:bamboo",
                        new SmartValueChooseWeighted([
                            new ChooseWeightedOption(1, 4),
                            new ChooseWeightedOption(2, 4),
                            new ChooseWeightedOption(3, 1),
                        ]),
                    ),
                    new StructureParameterTile(
                        "phantasia:bamboo",
                        new SmartValueChooseWeighted([
                            new ChooseWeightedOption(1, 1),
                            new ChooseWeightedOption(2, 1),
                        ]),
                    ),
                ),
            ),
        ),
    ),
];
