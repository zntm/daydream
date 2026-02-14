import { DatagenReturnData } from "../../../lib";
import {
    WorldPattern,
    PatternRuleChance,
    PatternRuleAboveCave,
    PatternRuleBiome,
    PatternActionPlaceTile
} from "../lib/Pattern";

export default [
    // Example: Tree roots over cave pattern
    new DatagenReturnData(
        "patterns/tree_root_cave.json",
        new WorldPattern(
            "phantasia:pattern/tree_root_cave",
            [
                new PatternRuleChance(0.1),
                new PatternRuleAboveCave(2),
            ],
            [
                // Actions would go here
            ]
        )
    ),

    // Example: Mushroom cluster around cave entrance
    new DatagenReturnData(
        "patterns/cave_mushrooms.json",
        new WorldPattern(
            "phantasia:pattern/cave_mushrooms",
            [
                new PatternRuleChance(0.15),
                new PatternRuleAboveCave(1),
                new PatternRuleBiome(["phantasia:surface/forest", "phantasia:surface/swamp"]),
            ],
            [
                new PatternActionPlaceTile("phantasia:mushroom", 0, -1),
                new PatternActionPlaceTile("phantasia:mushroom", 1, -1),
            ]
        )
    ),
];
