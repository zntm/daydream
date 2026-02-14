import { readdirSync } from "fs";
import { join } from "path";
import type { SmartValue } from "../../index";

export class StructurePlacementClearanceCondition {
    xoffset: number | string | SmartValue;
    yoffset: number | string | SmartValue;
    width: number | string | SmartValue;
    height: number | string | SmartValue;

    constructor(
        xoffset: number | string | SmartValue,
        yoffset: number | string | SmartValue,
        width: number | string | SmartValue,
        height: number | string | SmartValue,
    ) {
        this.xoffset = xoffset;
        this.yoffset = yoffset;
        this.width = width;
        this.height = height;
    }
}

export enum StructurePlacementType {
    Floor = "floor",
    Ceiling = "ceiling",
    Inside = "inside",
}

export class StructurePlacement {
    type: StructurePlacementType;
    xoffset: number | string | SmartValue;
    yoffset: number | string | SmartValue;
    clearance_condition?: StructurePlacementClearanceCondition[];

    constructor(
        type: StructurePlacementType,
        xoffset: number | string | SmartValue,
        yoffset: number | string | SmartValue,
        clearance_condition?: StructurePlacementClearanceCondition[],
    ) {
        this.type = type;
        this.xoffset = xoffset;
        this.yoffset = yoffset;
        this.clearance_condition = clearance_condition;
    }
}

export enum StructureTerrainModifierType {
    Clear = "clear",      // Village-style: clear surface above structure
    Carve = "carve",      // Trial chamber-style: carve into terrain
    Elevate = "elevate",  // Raise terrain around structure
}

export class StructureTerrainModifier {
    private type: StructureTerrainModifierType;
    private depth: number;        // How deep to carve / how high to elevate
    private radius?: number;      // Horizontal radius around structure to affect
    private blend?: boolean;      // Smooth transition at edges

    constructor(
        type: StructureTerrainModifierType,
        depth: number,
        radius?: number,
        blend: boolean = true
    ) {
        this.type = type;
        this.depth = depth;
        if (radius) this.radius = radius;
        if (!blend) this.blend = false;
    }
}

export class Structure {
    public width: number | string | SmartValue;
    public height: number | string | SmartValue;
    public placement: StructurePlacement;
    public function: StructureFunction;
    private terrain_modifier?: StructureTerrainModifier;

    constructor(
        width: number | string | SmartValue,
        height: number | string | SmartValue,
        placement: StructurePlacement,
        data: StructureFunction,
    ) {
        this.width = width;
        this.height = height;
        this.placement = placement;
        this.function = data;
    }

    setTerrainModifier(modifier: StructureTerrainModifier) {
        this.terrain_modifier = modifier;
        return this;
    }
}

export class StructureParameterTile {
    private id: string;
    private index?: number | string | SmartValue;

    constructor(id: string, index?: number | string | SmartValue) {
        this.id = id;
        this.index = index;
    }
}

export class StructureFunction {
    private id: string;
    private parameters: any;

    constructor(id: string, parameters: any) {
        this.id = id;
        this.parameters = parameters;
    }
}

export default readdirSync(join(__dirname, "./structures"))
    .map((file) => {
        try {
            return import.meta.require(`./structures/${file}`).default;
        } catch (e) {
            console.error(`Error loading structure file ${file}:`, e);
            return null;
        }
    })
    .filter((structure) => structure)
    .flat();
