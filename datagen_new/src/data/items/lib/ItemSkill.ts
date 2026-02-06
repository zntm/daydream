import { ItemScript } from "./ItemScript";

export class ItemSkill {
    private type: string;
    private threshold: number;
    private stamina_cost: number;
    private on_trigger: ItemScript;

    constructor(
        type: string,
        threshold: number,
        stamina_cost: number,
        on_trigger: ItemScript,
    ) {
        this.type = type;
        this.threshold = threshold;
        this.stamina_cost = stamina_cost;
        this.on_trigger = on_trigger;
    }
}
