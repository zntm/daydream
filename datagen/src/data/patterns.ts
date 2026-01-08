import { DatagenReturnData } from "../../index";

// ============================================================================
// PATTERN RULES - Composable conditions for pattern matching
// ============================================================================

export enum PatternRuleType {
    Chance = "chance",
    Biome = "biome",
    Height = "height",
    Block = "block",
    AboveCave = "above_cave",
    And = "and",
    Or = "or",
}

export enum PatternBlockCheckType {
    Air = "air",
    Solid = "solid",
    Cave = "cave",
    Tile = "tile",
}

export abstract class PatternRule {
    abstract type: PatternRuleType;
}

export class PatternRuleChance extends PatternRule {
    type = PatternRuleType.Chance;
    private probability: number;

    constructor(probability: number) {
        super();
        this.probability = probability;
    }
}

export class PatternRuleBiome extends PatternRule {
    type = PatternRuleType.Biome;
    private biome_ids: string[];

    constructor(biomeIds: string | string[]) {
        super();
        this.biome_ids = Array.isArray(biomeIds) ? biomeIds : [biomeIds];
    }
}

export class PatternRuleHeight extends PatternRule {
    type = PatternRuleType.Height;
    private min_y: number;
    private max_y: number;

    constructor(minY: number, maxY: number) {
        super();
        this.min_y = minY;
        this.max_y = maxY;
    }
}

export class PatternRuleBlock extends PatternRule {
    type = PatternRuleType.Block;
    private offset_x: number;
    private offset_y: number;
    private check_type: PatternBlockCheckType;
    private tile_id?: string;

    constructor(offsetX: number, offsetY: number, checkType: PatternBlockCheckType, tileId?: string) {
        super();
        this.offset_x = offsetX;
        this.offset_y = offsetY;
        this.check_type = checkType;
        if (tileId) this.tile_id = tileId;
    }
}

export class PatternRuleAboveCave extends PatternRule {
    type = PatternRuleType.AboveCave;
    private depth_check: number;

    constructor(depthCheck: number = 2) {
        super();
        this.depth_check = depthCheck;
    }
}

export class PatternRuleAnd extends PatternRule {
    type = PatternRuleType.And;
    private rules: PatternRule[];

    constructor(rules: PatternRule[]) {
        super();
        this.rules = rules;
    }
}

export class PatternRuleOr extends PatternRule {
    type = PatternRuleType.Or;
    private rules: PatternRule[];

    constructor(rules: PatternRule[]) {
        super();
        this.rules = rules;
    }
}

// ============================================================================
// PATTERN ACTIONS - Things to do when a pattern matches
// ============================================================================

export enum PatternActionType {
    PlaceTile = "place_tile",
    SpawnStructure = "spawn_structure",
    Chain = "chain",
    Sequence = "sequence",
}

export abstract class PatternAction {
    abstract type: PatternActionType;
}

export class PatternActionPlaceTile extends PatternAction {
    type = PatternActionType.PlaceTile;
    private tile_id: string;
    private offset_x: number;
    private offset_y: number;
    private depth: number;

    constructor(tileId: string, offsetX: number = 0, offsetY: number = 0, depth: number = 0) {
        super();
        this.tile_id = tileId;
        this.offset_x = offsetX;
        this.offset_y = offsetY;
        this.depth = depth;
    }
}

export class PatternActionSpawnStructure extends PatternAction {
    type = PatternActionType.SpawnStructure;
    private structure_id: string;
    private offset_x: number;
    private offset_y: number;

    constructor(structureId: string, offsetX: number = 0, offsetY: number = 0) {
        super();
        this.structure_id = structureId;
        this.offset_x = offsetX;
        this.offset_y = offsetY;
    }
}

export class PatternActionChain extends PatternAction {
    type = PatternActionType.Chain;
    private pattern_id: string;
    private offset_x: number;
    private offset_y: number;

    constructor(patternId: string, offsetX: number = 0, offsetY: number = 0) {
        super();
        this.pattern_id = patternId;
        this.offset_x = offsetX;
        this.offset_y = offsetY;
    }
}

export class PatternActionSequence extends PatternAction {
    type = PatternActionType.Sequence;
    private actions: PatternAction[];

    constructor(actions: PatternAction[]) {
        super();
        this.actions = actions;
    }
}

// ============================================================================
// WORLD PATTERN - Composable pattern using rules and actions
// ============================================================================

export class WorldPattern {
    private id: string;
    private rules: PatternRule[];
    private actions: PatternAction[];

    constructor(id: string, rules: PatternRule[] = [], actions: PatternAction[] = []) {
        this.id = id;
        this.rules = rules;
        this.actions = actions;
    }
}

// ============================================================================
// EXAMPLE PATTERNS
// ============================================================================

export default [
    // Example: Tree roots over cave pattern
    new DatagenReturnData(
        "generated/data/patterns/tree_root_cave.json",
        new WorldPattern(
            "phantasia:pattern/tree_root_cave",
            [
                new PatternRuleChance(0.1),
                new PatternRuleAboveCave(2),
            ],
            [
                // Actions would go here
                // new PatternActionSpawnStructure("phantasia:tree/pine_roots"),
            ]
        )
    ),
    
    // Example: Mushroom cluster around cave entrance
    new DatagenReturnData(
        "generated/data/patterns/cave_mushrooms.json",
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
