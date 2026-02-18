import { ItemFunction } from "./ItemFunction";

/**
 * Script reference for Proglang scripts.
 * Uses @ prefix to indicate a script file.
 * @example new ItemScript("@phantasia:items/spawn_particle", { id: "..." })
 */
export class ItemScript extends ItemFunction {
    constructor(script: string, parameters?: any, chance?: string | number, repeat?: string | number) {
        super("@phantasia:" + script, parameters, chance, repeat);
    }
}

// Legacy alias for backwards compatibility
export class ProgLang extends ItemScript {
    constructor(script: string, chance?: string | number, repeat?: string | number) {
        super(script, undefined, chance, repeat);
    }
}
