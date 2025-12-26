import { ItemFunction } from "./ItemFunction";

export class ProgLang extends ItemFunction {
    constructor(script: string, chance?: string | number, repeat?: string | number) {
        super("$proglang:" + script, undefined, chance, repeat);
    }
}
